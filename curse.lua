-- Curse

Curse = Proxy.new()

local disable_shield_regen_sfx = 0
local packet_apply, packet_remove



-- ========== Initialize ==========

Initialize(function()
    packet_apply = Packet.new()
    packet_apply:onReceived(function(message, player)
        local actor = message:read_instance()
        local id = message:read_string()
        local amount = message:read_float()

        -- Received by host
        if Net.is_host() then
            Curse.apply(actor, id, amount)
            return
        end

        -- Receive by client
        apply_curse_internal(actor, id, amount)
    end)


    packet_remove = Packet.new()
    packet_remove:onReceived(function(message, player)
        local actor = message:read_instance()
        local id = message:read_string()

        -- Received by host
        if Net.is_host() then
            Curse.remove(actor, id, amount)
            return
        end

        -- Receive by client
        remove_curse_internal(actor, id, amount)
    end)
end)



-- ========== Static Methods ==========

Curse.apply = function(actor, id, amount)
    apply_curse_internal(actor, id, amount)

    -- Sync
    if Net.is_host() then
        local message = packet_apply:message_begin()
        message:write_instance(actor)
        message:write_string(id)
        message:write_float(amount)
        message:send_to_all()

    elseif Net.is_client() then
        local message = packet_apply:message_begin()
        message:write_instance(actor)
        message:write_string(id)
        message:write_float(amount)
        message:send_to_host()

    end
end


Curse.remove = function(actor, id)
    remove_curse_internal(actor, id)

    -- Sync
    if Net.is_host() then
        local message = packet_remove:message_begin()
        message:write_instance(actor)
        message:write_string(id)
        message:send_to_all()

    elseif Net.is_client() then
        local message = packet_remove:message_begin()
        message:write_instance(actor)
        message:write_string(id)
        message:send_to_host()

    end
end


Curse.get_effective = function(actor)
    local actorData = actor:get_data()
    if not actorData["curseHelper-maxhp"] then return actor.maxhp, actor.maxshield, actor.maxbarrier end
    local maxhp = actorData["curseHelper-maxhp"]
    return actor.maxhp * maxhp, actor.maxshield * maxhp, actor.maxbarrier * maxhp
end



-- ========== Internal ==========

function calc_curse(table)
    local maxhp = 1.0
    for k, v in pairs(table) do
        if k ~= "curseHelper-maxhp" then
            maxhp = maxhp * (1 - v)
        end
    end
    table["curseHelper-maxhp"] = maxhp
    return maxhp
end


function apply_curse_internal(actor, id, amount)
    actor = Wrap.wrap(actor)

    if not Instance.exists(actor.value) then log.error("Actor does not exist", 2) end
    if not id then log.error("ID unspecified", 2) end
    if not amount then log.error("Amount unspecified", 2) end
    if amount <= 0 then return end

    local actorData = actor:get_data()
    actorData[id] = math.min(amount, 1.0)

    local maxhp = calc_curse(actorData)
    actor:recalculate_stats()
    add_curse_callbacks(actor, maxhp)
end


function remove_curse_internal(actor, id)
    actor = Wrap.wrap(actor)

    if not Instance.exists(actor.value) then log.error("Actor does not exist", 2) end
    if not id then log.error("ID unspecified", 2) end

    local actorData = actor:get_data()
    actorData[id] = nil

    local maxhp = calc_curse(actorData)
    actor:recalculate_stats()
    add_curse_callbacks(actor, maxhp)
end


function add_curse_callbacks(actor, maxhp)
    actor:remove_callback("curseHelper-hpCap")
    -- actor:remove_callback("curseHelper-healReduction")

    if maxhp < 1.0 then
        actor:onPostStep("curseHelper-hpCap", function(actor)
            actor.hp = math.min(actor.hp, actor.maxhp * maxhp)
            actor.barrier = math.min(actor.barrier, actor.maxbarrier * maxhp)

            if actor.shield > actor.maxshield * maxhp then
                actor.shield = actor.maxshield * maxhp
                disable_shield_regen_sfx = 2
            else disable_shield_regen_sfx = 0
            end
        end)

        -- actor:onHeal("curseHelper-healReduction", function(actor, heal_amount)
        --     return heal_amount * maxhp
        -- end)

    else disable_shield_regen_sfx = 0
    end
end


Callback.add("onPlayerHUDDraw", "curseHelper-playerCurseDisplay", function(player, hud_x, hud_y)
    local pData = player:get_data()
    if  pData["curseHelper-maxhp"]
    and pData["curseHelper-maxhp"] < 1.0 then
        gm.draw_rectangle(hud_x + 139 - ((1 - pData["curseHelper-maxhp"]) * 157), hud_y + 39, hud_x + 139, hud_y + 45, true)
    end
end)


-- Contribution by @0n_x
gm.post_script_hook(gm.constants.hud_draw_health, function(self, other, result, args)
    local actor = Instance.wrap(args[1].value)
    if  self
    and self.object_index == gm.constants.oP
    and actor.m_id == Player.get_client().m_id
    and actor.maxhp ~= Curse.get_effective(actor) then
        gm.draw_set_color(Color.WHITE)
        gm.draw_rectangle(math.floor(actor.x + 0.5 + 37) - 75 * (1 - Curse.get_effective(actor) / actor.maxhp),
            math.floor(actor.y + 0.5 - 74), math.floor(actor.x + 0.5 + 37), math.floor(actor.y + 0.5 - 69), true)
    end
end)


gm.pre_script_hook(gm.constants.sound_play_at, function(self, other, result, args)
    if disable_shield_regen_sfx >= 2 and args[1].value == 282.0 then
        disable_shield_regen_sfx = 2
        return false
    end
end)


gm.post_script_hook(gm.constants.run_destroy, function(self, other, result, args)
    disable_shield_regen_sfx = 0
end)



return Curse:lock()