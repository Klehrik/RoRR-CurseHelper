Allows for applying visible maximum health reduction.  

![CurseHelperShowcase.png](https://github.com/Klehrik/RoRR-CurseHelper/blob/main/CurseHelperShowcase.png?raw=true)

Import line:  
```lua
Curse = mods["Klehrik-CurseHelper"].setup()

```

---

### Functions

```lua
Curse.apply(actor, id, amount) -> nil
```

Applies an instance of maximum health reduction to the actor.  
Works multiplicatively with other curse applications  
(e.g., 2 applications of `0.5` will result in 25% maximum health remaining).  
Specifying an existing ID will override it.  

**Parameters:**  
| **Parameter** | **Type** | **Description** |
| ------------- | -------- | --------------- |
| `actor`       | CInstance or Actor object | The actor to apply curse to. |
| `id`          | string  | The identifier for the curse application. |
| `amount`      | number  | The amount of curse to apply (between `0` (none) and `1` (all health)). |

<br>

```lua
Curse.remove(actor, id) -> nil
```

Removes an instance of maximum health reduction from the actor.  

**Parameters:**  
| **Parameter** | **Type** | **Description** |
| ------------- | -------- | --------------- |
| `actor`       | CInstance or Actor object | The actor to remove curse from. |
| `id`          | string  | The identifier for the curse application. |

<br>

```lua
Curse.get_effective(actor) -> number, number, number
```

Returns the actor's effective (i.e., after curse) maximum health, shield, and barrier as unpacked values.  
`maximum health`, `maximum shield`, `maximum barrier`  

**Parameters:**  
| **Parameter** | **Type** | **Description** |
| ------------- | -------- | --------------- |
| `actor`       | CInstance or Actor object | The actor to check. |

---

### Installation Instructions
Follow the instructions [listed here](https://docs.google.com/document/d/1NgLwb8noRLvlV9keNc_GF2aVzjARvUjpND2rxFgxyfw/edit?usp=sharing).  
Join the [Return of Modding server](https://discord.gg/VjS57cszMq) for support.  