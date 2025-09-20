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
            This_MOD.create_subgroup(space)
            This_MOD.create_item(space)
            This_MOD.create_entity(space)
            This_MOD.create_recipe(space)
            This_MOD.create_tech(space)

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
    This_MOD.indicator = { icon = Indicator, scale = 0.15, shift = { 0, -12 } }
    This_MOD.indicator_bg = { icon = GMOD.color.black, scale = 0.15, shift = { 0, -12 } }
    This_MOD.indicator_tech = { icon = Indicator, scale = 0.50, shift = { 0, -50 } }
    This_MOD.indicator_tech_bg = { icon = GMOD.color.black, scale = 0.50, shift = { 0, -50 } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en este MOD
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Daños a procesar
    This_MOD.damages = {}
    for damage, _ in pairs(data.raw["damage-type"]) do
        table.insert(This_MOD.damages, damage)
    end

    --- Digitos necesarios para ordenar
    This_MOD.damages_digits = GMOD.digit_count(#This_MOD.damages) + 1

    --- Tipos a afectar
    This_MOD.types = {
        ["construction-robot"] = true,
        ["logistic-robot"] = true
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Funciones locales ]---
---------------------------------------------------------------------------

function This_MOD.get_elements()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Función para analizar cada entidad
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function valide(item, entity)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Validar el item
        if not item then return end

        --- Validar el tipo
        if not This_MOD.types[entity.type] then return end

        --- Validar si ya fue procesado
        if
            This_MOD.processed[entity.type] and
            This_MOD.processed[entity.type][item.name]
        then
            return
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Valores para el proceso
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Space = {}
        Space.item = item
        Space.entity = entity

        Space.recipe = GMOD.recipes[Space.item.name]
        Space.tech = GMOD.get_technology(Space.recipe)
        Space.recipe = Space.recipe and Space.recipe[1] or nil

        Space.part =
            GMOD.get_id_and_name(Space.item.subgroup) or
            { name = Space.item.subgroup }
        Space.subgroup =
            This_MOD.prefix ..
            Space.part.name .. "-" ..
            Space.entity.type

        Space.part =
            GMOD.get_id_and_name(entity.name) or
            { ids = "-", name = entity.name }
        Space.prefix =
            GMOD.name ..
            Space.part.ids ..
            This_MOD.id .. "-" ..
            Space.part.name .. "-"

        Space.part = nil

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Guardar la información
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        This_MOD.to_be_processed[entity.type] = This_MOD.to_be_processed[entity.type] or {}
        This_MOD.to_be_processed[entity.type][entity.name] = Space

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Buscar las entidades a afectar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for item_name, entity in pairs(GMOD.entities) do
        valide(GMOD.items[item_name], entity)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------

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
    local New = space.subgroup
    GMOD.duplicate_subgroup(Old, New)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_item(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.item then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear los items
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function create_item(i, damage)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Duplicar el elemento
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Item = GMOD.copy(space.item)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar algunas propiedades
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        Item.name = space.prefix .. (damage or "all")

        Item.localised_description = { "" }

        Item.localised_name = GMOD.copy(space.entity.localised_name)
        table.insert(Item.localised_name, " - ")
        table.insert(Item.localised_name,
            damage and
            { "damage-type-name." .. damage } or
            { "gui.all" }
        )

        table.insert(Item.icons, This_MOD.indicator_bg)
        table.insert(Item.icons, This_MOD.indicator)

        Item.subgroup = space.subgroup

        Item.order = GMOD.pad_left_zeros(This_MOD.damages_digits, i) .. "0"

        Item.place_result = Item.name

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

    create_item(#This_MOD.damages + 1)
    for key, damage in pairs(This_MOD.damages) do
        create_item(key, damage)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_entity(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.entity then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear para cada tipo de daño
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function one(damage)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Duplicar el elemento
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Entity = GMOD.copy(space.entity)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar algunas propiedades
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        Entity.name = space.prefix .. (damage or "all")

        Entity.localised_description = { "" }

        Entity.localised_name = GMOD.copy(space.entity.localised_name)
        table.insert(Entity.localised_name, " - ")
        table.insert(Entity.localised_name,
            damage and
            { "damage-type-name." .. damage } or
            { "gui.all" }
        )

        Entity.icons = GMOD.copy(space.item.icons)
        table.insert(Entity.icons, This_MOD.indicator_bg)
        table.insert(Entity.icons, This_MOD.indicator)

        Entity.minable.results = { {
            type = "item",
            name = Entity.name,
            amount = 1
        } }

        Entity.resistances = {}

        if damage then
            table.insert(
                Entity.resistances,
                { type = damage, percent = 100 }
            )
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Crear el prototipo
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        GMOD.extend(Entity)

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

        if not GMOD.entities[space.prefix .. "all"] then
            one()
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Agregar el ingrediente a la receta existente
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        table.insert(
            GMOD.entities[space.prefix .. "all"].resistances,
            { type = damage, percent = 100 }
        )

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
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

        Recipe.name = space.prefix .. (damage or "all")

        Recipe.main_product = nil
        Recipe.maximum_productivity = 1000000

        Recipe.localised_description = { "" }

        Recipe.localised_name = GMOD.copy(space.entity.localised_name)
        table.insert(Recipe.localised_name, " - ")
        table.insert(Recipe.localised_name,
            damage and
            { "damage-type-name." .. damage } or
            { "gui.all" }
        )

        Recipe.icons = GMOD.copy(space.item.icons)
        table.insert(Recipe.icons, This_MOD.indicator)

        Recipe.enabled = space.tech == nil

        Recipe.subgroup = space.subgroup

        Recipe.order = GMOD.pad_left_zeros(This_MOD.damages_digits, i) .. "0"

        Recipe.energy_required = This_MOD.setting.time

        Recipe.results = { {
            type = "item",
            name = Recipe.name,
            amount = 1
        } }

        Recipe.ingredients = {}
        if damage then
            table.insert(Recipe.ingredients, {
                type = "item",
                name = space.item.name,
                amount = 1
            })
        end

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

        if not data.raw.recipe[space.prefix .. "all"] then
            one(#This_MOD.damages + 1)
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Agregar el ingrediente a la receta existente
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        table.insert(data.raw.recipe[space.prefix .. "all"].ingredients, {
            type = "item",
            name = space.prefix .. damage,
            amount = 1
        })

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
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Duplicar el elemento
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Tech = GMOD.copy(space.tech)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar algunas propiedades
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        Tech.name = space.prefix .. (damage or "all") .. "-tech"

        Tech.icons = GMOD.copy(space.item.icons)
        table.insert(Tech.icons, This_MOD.indicator_tech_bg)
        table.insert(Tech.icons, This_MOD.indicator_tech)

        Tech.localised_name = GMOD.copy(space.entity.localised_name)
        table.insert(Tech.localised_name, " - ")
        table.insert(Tech.localised_name,
            damage and
            { "damage-type-name." .. damage } or
            { "gui.all" }
        )

        Tech.localised_description = { "" }

        Tech.prerequisites = {}
        if damage then
            table.insert(Tech.prerequisites, space.tech.name)
        end

        Tech.effects = { {
            type = "unlock-recipe",
            recipe = space.prefix .. (damage or "all")
        } }

        if Tech.research_trigger then
            Tech.research_trigger = {
                type = "craft-item",
                item =
                    space.prefix .. (
                        damage or
                        This_MOD.damages[math.random(1, #This_MOD.damages)]
                    ),
                count = 1
            }
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Crear el prototipo
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        GMOD.extend(Tech)

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

        if not data.raw.technology[space.prefix .. "all-tech"] then
            one()
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Agregar el prerequisito a la tech existente
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        table.insert(data.raw.technology[space.prefix .. "all-tech"].prerequisites,
            space.prefix .. damage .. "-tech"
        )

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
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

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Iniciar el MOD ]---
---------------------------------------------------------------------------

This_MOD.start()

---------------------------------------------------------------------------
