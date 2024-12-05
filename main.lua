-- CurseHelper
-- Klehrik

local envy = mods["MGReturns-ENVY"]
envy.auto()
mods["RoRRModdingToolkit-RoRR_Modding_Toolkit"].auto()

require("./curse")



-- ========== ENVY Setup ==========

function public.setup(env)
    if env == nil then
        env = envy.getfenv(2)
    end
    local wrapper = {}
    for k, v in pairs(Curse) do
        wrapper[k] = v
    end
    return wrapper
end