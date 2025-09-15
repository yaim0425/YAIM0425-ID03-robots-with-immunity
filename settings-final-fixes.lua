---------------------------------------------------------------------------
---[ settings-final-fixes.lua ]---
---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Cargar las funciones de GMOD ]---
---------------------------------------------------------------------------

require("__" .. "YAIM0425-i5MOD50-core" .. "__.settings-final-fixes")

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Contenedor de este archivo ]---
---------------------------------------------------------------------------

local This_MOD = GMOD.get_id_and_name()
if not This_MOD then return end
GMOD[This_MOD.id] = This_MOD

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Opciones ]---
---------------------------------------------------------------------------

--- Opciones
This_MOD.setting = {}

--- Opcion: time
table.insert(This_MOD.setting, {
    type = "int",
    name = "time",
    localised_name = { "description.crafting-time" },
    localised_description = "Min. 1 [ 1seg ] \nMax. 65k [ 18h ] \nDef. 900 [5min]\n\n 15min * 60seg = 900seg",
    minimum_value = 1,     --- 1 segundo
    maximum_value = 65000, --- 18 horas
    default_value = 900    --- 15 minutos
})

--- Opcion: armor_base
table.insert(This_MOD.setting, {
    type = "string",
    name = "armor_base",
    localised_name = { "gui.armor" },
    default_value = "light-armor",
    allowed_values = {
        "light-armor",
        "heavy-armor",
        "modular-armor",
        "power-armor",
        "power-armor-mk2"
    }
})

--- Renombrar
local Armor_base = This_MOD.setting[#This_MOD.setting]

---------------------------------------------------------------------------------------------------

--- Factorio+
if mods["factorioplus"] then
    table.insert(Armor_base.allowed_values, "backpack")
    table.insert(Armor_base.allowed_values, "backpack-2")
    table.insert(Armor_base.allowed_values, "explosive-armor")
    table.insert(Armor_base.allowed_values, "acid-armor")
end

--- Krastorio 2
if mods["Krastorio2"] then
    table.insert(Armor_base.allowed_values, "kr-power-armor-mk3")
    table.insert(Armor_base.allowed_values, "kr-power-armor-mk4")
end

--- Youki Industries
if mods["Yuoki"] then
    table.insert(Armor_base.allowed_values, "yi_armor_gray")
    table.insert(Armor_base.allowed_values, "yi_armor_red")
    table.insert(Armor_base.allowed_values, "yi_armor_gold")
    table.insert(Armor_base.allowed_values, "yi_walker_a")
    table.insert(Armor_base.allowed_values, "yi_walker_c")
end

--- Bob's Warfare mod
if mods["bobwarfare"] then
    table.insert(Armor_base.allowed_values, "bob-power-armor-3")
    table.insert(Armor_base.allowed_values, "bob-power-armor-4")
    table.insert(Armor_base.allowed_values, "bob-power-armor-5")
end

--- Space Age
if mods["space-age"] then
    table.insert(Armor_base.allowed_values, "mech-armor")
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Completar las opciones ]---
---------------------------------------------------------------------------

--- Información adicional
for order, setting in pairs(This_MOD.setting) do
    setting.type = setting.type .. "-setting"
    setting.name = This_MOD.prefix .. setting.name
    setting.order = GMOD.pad_left_zeros(GMOD.digit_count(order), order)
    setting.setting_type = "startup"
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
--- Cargar la configuración ---
---------------------------------------------------------------------------

data:extend(This_MOD.setting)

---------------------------------------------------------------------------
