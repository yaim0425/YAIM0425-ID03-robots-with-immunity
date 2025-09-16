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

    --- Modificar los elementos
    for iKey, spaces in pairs(This_MOD.to_be_processed) do
        for jKey, space in pairs(spaces) do
            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

            --- Marcar como procesado
            This_MOD.processed[iKey] = This_MOD.processed[iKey] or {}
            This_MOD.processed[iKey][jKey] = true

            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

            --- Crear los elementos
            This_MOD.create_recipe(space)
            This_MOD.create_item(space)
            This_MOD.create_tech(space)
            This_MOD.create_subgroup(space)

            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        end
    end

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

    --- Daños a procesar
    This_MOD.damages = {}
    for damage, _ in pairs(data.raw["damage-type"]) do
        table.insert(This_MOD.damages, damage)
    end

    ---Digitos necesarios para ordenar
    This_MOD.damages_count = GMOD.digit_count(#This_MOD.damages) + 1

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

    if not space.recipe then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear para cada tipo de daño
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function one(i, damage)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Duplicar el elemento
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Recipe = GMOD.copy(space.recipe)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar algunas propiedades
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        Recipe.name = This_MOD.prefix .. damage

        Recipe.localised_description = { "" }

        Recipe.localised_name = GMOD.copy(space.item.localised_name)
        table.insert(Recipe.localised_name, " - ")
        table.insert(Recipe.localised_name, { "damage-type-name." .. damage })

        Recipe.icons = GMOD.copy(space.item.icons)
        table.insert(Recipe.icons, This_MOD.indicator)

        Recipe.enabled = space.tech == nil

        Recipe.subgroup = This_MOD.prefix .. space.item.name

        Recipe.order = GMOD.pad_left_zeros(This_MOD.damages_count, i) .. "0"

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

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear para todos los tipos de daño
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function all(damage)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validar si se creó "all"
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        if data.raw.recipe[This_MOD.prefix .. "all"] then
            --- Agregar el ingrediente a la receta existente
            table.insert(
                data.raw.recipe[This_MOD.prefix .. "all"].ingredients,
                {
                    type = "item",
                    name = This_MOD.prefix .. damage,
                    amount = 1
                }
            )
            return
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Duplicar el elemento
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Recipe = GMOD.copy(space.recipe)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar algunas propiedades
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        Recipe.name = This_MOD.prefix .. "all"

        Recipe.localised_description = { "" }

        Recipe.localised_name = GMOD.copy(space.item.localised_name)
        table.insert(Recipe.localised_name, " - ")
        table.insert(Recipe.localised_name, { "gui.all" })

        Recipe.icons = GMOD.copy(space.item.icons)
        table.insert(Recipe.icons, This_MOD.indicator)

        Recipe.enabled = space.tech == nil

        Recipe.subgroup = This_MOD.prefix .. space.item.name

        Recipe.order = GMOD.pad_left_zeros(This_MOD.damages_count, #This_MOD.damages + 1) .. "0"

        Recipe.energy_required = This_MOD.setting.time

        Recipe.results = { {
            type = "item",
            name = Recipe.name,
            amount = 1
        } }

        Recipe.ingredients = { {
            type = "item",
            name = This_MOD.prefix .. damage,
            amount = 1
        } }

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Crear el prototipo
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        GMOD.extend(Recipe)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Recorrer los daños
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for key, damage in pairs(This_MOD.damages) do
        one(key, damage)
        all(damage)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_item(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.item then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear para cada tipo de daño
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function one(i, damage)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Duplicar el elemento
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Item = GMOD.copy(space.item)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar algunas propiedades
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        Item.name = This_MOD.prefix .. damage

        Item.localised_description = { "" }

        Item.localised_name = GMOD.copy(space.item.localised_name)
        table.insert(Item.localised_name, " - ")
        table.insert(Item.localised_name, { "damage-type-name." .. damage })

        Item.icons = GMOD.copy(space.item.icons)
        table.insert(Item.icons, This_MOD.indicator)

        Item.subgroup = This_MOD.prefix .. space.item.name

        Item.order = GMOD.pad_left_zeros(This_MOD.damages_count, i) .. "0"

        Item.resistances = { {
            type = damage,
            decrease = 0,
            percent = 100
        } }

        Item.factoriopedia_simulation = {
            init =
                'game.simulation.camera_zoom = 4' ..
                'game.simulation.camera_position = {0.5, -0.25}' ..
                'local character = game.surfaces[1].create_entity{name = "character", position = {0.5, 0.5}, force = "player", direction = defines.direction.south}' ..
                'character.insert{name = "' .. Item.name .. '"}'
        }

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Crear el prototipo
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        GMOD.extend(Item)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear para todos los tipos de daño
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function all(damage)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validar si se creó "all"
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        if GMOD.items[This_MOD.prefix .. "all"] then
            --- Agregar el ingrediente a la receta existente
            table.insert(
                GMOD.items[This_MOD.prefix .. "all"].resistances,
                {
                    type = damage,
                    decrease = 0,
                    percent = 100
                }
            )
            return
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Duplicar el elemento
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Item = GMOD.copy(space.item)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar algunas propiedades
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        Item.name = This_MOD.prefix .. "all"

        Item.localised_description = { "" }

        Item.localised_name = GMOD.copy(space.item.localised_name)
        table.insert(Item.localised_name, " - ")
        table.insert(Item.localised_name, { "gui.all" })

        Item.icons = GMOD.copy(space.item.icons)
        table.insert(Item.icons, This_MOD.indicator)

        Item.subgroup = This_MOD.prefix .. space.item.name

        Item.order = GMOD.pad_left_zeros(This_MOD.damages_count, #This_MOD.damages + 1) .. "0"

        Item.resistances = { {
            type = damage,
            decrease = 0,
            percent = 100
        } }

        Item.factoriopedia_simulation = {
            init =
                'game.simulation.camera_zoom = 4' ..
                'game.simulation.camera_position = {0.5, -0.25}' ..
                'local character = game.surfaces[1].create_entity{name = "character", position = {0.5, 0.5}, force = "player", direction = defines.direction.south}' ..
                'character.insert{name = "' .. Item.name .. '"}'
        }

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Crear el prototipo
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        GMOD.extend(Item)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Recorrer los daños
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for key, damage in pairs(This_MOD.damages) do
        one(key, damage)
        all(damage)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_tech(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.tech then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear para cada tipo de daño
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function one(damage)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Duplicar el elemento
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Tech = GMOD.copy(space.tech)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar algunas propiedades
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        Tech.name = This_MOD.prefix .. "-" .. damage .. "--tech"

        Tech.icons = GMOD.copy(space.item.icons)
        table.insert(Tech.icons, This_MOD.indicator_tech_bg)
        table.insert(Tech.icons, This_MOD.indicator_tech)

        Tech.localised_name = GMOD.copy(space.item.localised_name)
        table.insert(Tech.localised_name, " - ")
        table.insert(Tech.localised_name, { "damage-type-name." .. damage })

        Tech.localised_description = nil

        Tech.prerequisites = { space.tech.name }

        Tech.effects = { {
            type = "unlock-recipe",
            recipe = This_MOD.prefix .. damage
        } }

        if Tech.research_trigger then
            Tech.research_trigger = {
                type = "craft-item",
                item = space.item.name,
                count = 1
            }
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Crear el prototipo
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        GMOD.extend(Tech)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear para todos los tipos de daño
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function all(damage)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validar si se creó la tech "all"
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Tech_name = This_MOD.prefix .. "-" .. "all" .. "--tech"
        if data.raw.technology[Tech_name] then
            --- Agregar el ingrediente a la receta existente
            table.insert(
                data.raw.technology[Tech_name].prerequisites,
                This_MOD.prefix .. "-" .. damage .. "--tech"
            )
            return
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Duplicar el elemento
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Tech = GMOD.copy(space.tech)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar algunas propiedades
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        Tech.name = Tech_name

        Tech.icons = GMOD.copy(space.item.icons)
        table.insert(Tech.icons, This_MOD.indicator_tech_bg)
        table.insert(Tech.icons, This_MOD.indicator_tech)

        Tech.localised_name = GMOD.copy(space.item.localised_name)
        table.insert(Tech.localised_name, " - ")
        table.insert(Tech.localised_name, { "gui.all" })

        Tech.localised_description = nil

        Tech.prerequisites = { This_MOD.prefix .. "-" .. damage .. "--tech" }

        Tech.effects = { {
            type = "unlock-recipe",
            recipe = This_MOD.prefix .. "all"
        } }

        if Tech.research_trigger then
            Tech.research_trigger = {
                type = "craft-item",
                item = space.item.name,
                count = 1
            }
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Crear el prototipo
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        GMOD.extend(Tech)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Recorrer los daños
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for _, damage in pairs(This_MOD.damages) do
        one(damage)
        all(damage)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_subgroup(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.item then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear un nuevo subgrupo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Old = space.item.subgroup
    local New = This_MOD.prefix .. space.item.name
    GMOD.duplicate_subgroup(Old, New)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Iniciar el MOD ]---
---------------------------------------------------------------------------

This_MOD.start()

---------------------------------------------------------------------------
