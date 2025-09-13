---------------------------------------------------------------------------
---[ data-final-fixes.lua ]---
---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Contenedor de este archivo ]---
---------------------------------------------------------------------------

local This_MOD = GMOD.get_id_and_name()
if not This_MOD then return end
GMOD[This_MOD.id] = This_MOD

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Inicio del MOD ]---
---------------------------------------------------------------------------

function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores de la referencia
    This_MOD.setting_mod()

    --- Obtener los elementos
    This_MOD.get_elements()

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Valores de la referencia ]---
---------------------------------------------------------------------------

function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validar si se cargó antes
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if This_MOD.processed then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en todos los MODs
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contenedor de los elementos que el MOD modoficó o modificará
    This_MOD.to_be_processed = {}
    This_MOD.processed = {}

    --- Cargar la configuración
    This_MOD.setting = GMOD.setting[This_MOD.id]

    --- Indicador del mod
    local Indicator = data.raw["virtual-signal"]["signal-heart"].icons[1].icon

    This_MOD.indicator = {
        icon = Indicator,
        scale = 0.15,
        shift = { 12, -12 }
    }

    This_MOD.indicator_tech = {
        icon = Indicator,
        scale = 0.50,
        shift = { 50, 50 }
    }

    This_MOD.indicator_tech_bg = {
        icon = GMOD.color.black,
        scale = 0.50,
        shift = { 50, 50 }
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en este MOD
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Tiempo de creación de las recetas
    This_MOD.time = This_MOD.setting.time
    --- Min. 1 (1s)
    --- Max. 65000 (18h)
    --- Def. 900 (15m)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Funciones locales ]---
---------------------------------------------------------------------------

function This_MOD.get_elements()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Función para analizar cada elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function valide(element)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Validar el tipo
        if not element then return end
        if element.type ~= "armor" then return end

        --- Validar si ya fue procesado
        if
            This_MOD.processed[element.type] and
            This_MOD.processed[element.type][element.name]
        then
            return
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Valores para el proceso
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Space = {}
        Space.item = element
        Space.recipe = GMOD.recipes[element.name]
        Space.tech = GMOD.get_technology(Space.recipe)
        Space.recipe = Space.recipe and Space.recipe[1] or nil

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Guardar la información
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        This_MOD.to_be_processed[element.type] = This_MOD.to_be_processed[element.type] or {}
        This_MOD.to_be_processed[element.type][element.name] = Space

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Buscar las entidades a afectar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.to_be_processed = {}
    valide(GMOD.items[This_MOD.setting.armor_base or "light-armor"])

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------

function This_MOD.create_recipe(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.item then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear la receta para cada tipo de daño
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function one_resistance(damage_type)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Duplicar el elemento
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Recipe = GMOD.copy(This_MOD.recipe)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar algunas propiedades
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        Recipe.name = This_MOD.prefix .. damage_type

        Recipe.localised_description = { "" }

        Recipe.localised_name = GMOD.copy(space.item.localised_name)
        table.insert(Recipe.localised_name, " - ")
        table.insert(Recipe.localised_name, { "damage-type-name." .. damage })

        Recipe.icons = GMOD.copy(space.item.icons)
        table.insert(Recipe.icons, This_MOD.indicator)

        Recipe.subgroup = This_MOD.prefix .. This_MOD.name

        Recipe.energy_required = This_MOD.setting.time

        Recipe.results = { {
            type = "item",
            name = Recipe.name,
            amount = 1
        } }

        Recipe.ingredients = { {
            type = "item",
            name = space.item.name,
            amount = 1
        } }

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Crear el prototipo
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        GMOD.extend(Recipe)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    -- local function all_resistance()
    --     --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --     --- Nueva receta
    --     local Recipe = GPrefix.copy(This_MOD.recipe)
    --     local Count = GPrefix.get_length(This_MOD.damages) + 1

    --     --- Actualizar los valores
    --     Recipe.results[1].name = Recipe.name .. "all"
    --     Recipe.name = Recipe.name .. "all"
    --     Recipe.order = GPrefix.pad_left_zeros(This_MOD.digit, Count) .. "0"
    --     table.insert(Recipe.localised_name, { "gui.all" })
    --     table.insert(Recipe.icons, This_MOD.icon.other)

    --     --- Agregar los ingredientes
    --     Recipe.ingredients = {}
    --     for damage, _ in pairs(This_MOD.damages) do
    --         table.insert(Recipe.ingredients, {
    --             type = "item",
    --             name = This_MOD.recipe.name .. damage,
    --             amount = 1
    --         })
    --     end

    --     --- Agregar la receta
    --     GPrefix.extend(Recipe)

    --     --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    -- end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear las recetas
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for damage, _ in pairs(data.raw["damage-type"]) do
        one_resistance(damage)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------

--- Iniciar el MOD
This_MOD.start()

---------------------------------------------------------------------------
