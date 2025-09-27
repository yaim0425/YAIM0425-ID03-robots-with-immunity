---------------------------------------------------------------------------
---[ data-final-fixes.lua ]---
---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Contenedor de este archivo ]---
---------------------------------------------------------------------------

local This_MOD = GMOD.get_id_and_name()
if not This_MOD then return end
GMOD.mods[This_MOD.id] = This_MOD

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
    for _, spaces in pairs(This_MOD.to_be_processed) do
        for _, space in pairs(spaces) do
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
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contenedor de los elementos que el MOD modoficará
    This_MOD.to_be_processed = {}

    --- Validar si se cargó antes
    if This_MOD.setting then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en todos los MODs
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cargar la configuración
    This_MOD.setting = GMOD.setting[This_MOD.id] or {}

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
    --- Actualizar los tipos de daños
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Tipos de daños a usar
    This_MOD.damages = {}
    for damage, _ in pairs(data.raw["damage-type"]) do
        table.insert(This_MOD.damages, damage)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Función para analizar cada entidad
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function validate_entity(item, entity)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Validar el item
        if not item then return end

        --- Validar el tipo
        if not This_MOD.types[entity.type] then return end

        --- Validar si ya fue procesado
        if GMOD.has_id(entity.name, This_MOD.id) then return end

        local That_MOD =
            GMOD.get_id_and_name(entity.name) or
            { ids = "-", name = entity.name }

        local Name =
            GMOD.name .. That_MOD.ids ..
            This_MOD.id .. "-" ..
            That_MOD.name .. "-"

        local Processed
        for _, damage in pairs(This_MOD.damages) do
            Processed = GMOD.entities[Name .. damage] ~= nil
            if not Processed then break end
        end
        if Processed then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Valores para el proceso
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Space = {}
        Space.item = item
        Space.entity = entity
        Space.name = Name

        Space.recipe = GMOD.recipes[Space.item.name]
        Space.tech = GMOD.get_technology(Space.recipe)
        Space.recipe = Space.recipe and Space.recipe[1] or nil

        Space.digits = 1 + GMOD.digit_count(#This_MOD.damages + 1)
        Space.subgroup =
            GMOD.name ..
            (
                GMOD.get_id_and_name(Space.item.subgroup) or
                { ids = "-" }
            ).ids ..
            This_MOD.id .. "-" ..
            That_MOD.name

        Space.order = item.order

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
        validate_entity(GMOD.items[item_name], entity)
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
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Nombre a usar
        local Name = space.name .. (damage or "all")

        --- Order a usar
        local Order =
            GMOD.pad_left_zeros(
                space.digits,
                i or #This_MOD.damages + 1
            ) .. "0"

        --- Renombrar
        local Item = GMOD.items[Name]

        --- Existe
        if Item then
            Item.order = Order
            return
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Duplicar el elemento
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        Item = GMOD.copy(space.item)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar algunas propiedades
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Nombre
        Item.name = space.name .. (damage or "all")

        --- Apodo y descripción
        Item.localised_name = GMOD.copy(space.entity.localised_name)
        table.insert(Item.localised_name, " - ")
        table.insert(Item.localised_name,
            damage and
            { "damage-type-name." .. damage } or
            { "gui.all" }
        )
        Item.localised_description = { "" }

        --- Entidad a crear
        Item.place_result = Item.name

        --- Agregar indicador del MOD
        table.insert(Item.icons, This_MOD.indicator_bg)
        table.insert(Item.icons, This_MOD.indicator)

        --- Subgrupo y Order
        Item.subgroup = space.subgroup
        Item.order = Order

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

    create_item()
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
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Nombre a usar
        local Name = space.name .. (damage or "all")

        --- Renombrar
        local Entity = GMOD.entities[Name]

        --- Existe
        if Entity then
            return Entity
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Duplicar el elemento
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        Entity = GMOD.copy(space.entity)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar algunas propiedades
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Nombre
        Entity.name = Name

        --- Apodo y descripción
        Entity.localised_name = GMOD.copy(space.entity.localised_name)
        table.insert(Entity.localised_name, " - ")
        table.insert(Entity.localised_name,
            damage and
            { "damage-type-name." .. damage } or
            { "gui.all" }
        )
        Entity.localised_description = { "" }

        --- Agregar indicador del MOD
        Entity.icons = GMOD.copy(space.item.icons)
        table.insert(Entity.icons, This_MOD.indicator_bg)
        table.insert(Entity.icons, This_MOD.indicator)

        --- Objeto a minar
        Entity.minable.results = { {
            type = "item",
            name = Name,
            amount = 1
        } }

        --- Inmunidad del robot
        Entity.resistances = {}
        if damage then
            table.insert(Entity.resistances, {
                type = damage,
                percent = 100
            })
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Crear el prototipo
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        GMOD.extend(Entity)
        return Entity

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear para todos los tipos de daño
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function all(damage)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Cargar o crear de ser necesario
        local Entity = one()

        --- Tiene el valor a agregar
        if
            GMOD.get_tables(
                Entity.resistances,
                "type",
                damage
            )
        then
            return
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Agregar el ingrediente a la receta existente
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        table.insert(Entity.resistances, {
            type = damage,
            percent = 100
        })

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
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Nombre a usar
        local Name = space.name .. (damage or "all")

        --- Order a usar
        local Order =
            GMOD.pad_left_zeros(
                space.digits,
                i or #This_MOD.damages + 1
            ) .. "0"

        --- Renombrar
        local Recipe = data.raw.recipe[Name]

        --- Existe
        if Recipe then
            Recipe.order = Order
            return Recipe
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Duplicar el elemento
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        Recipe = GMOD.copy(space.recipe)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar algunas propiedades
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Nombre
        Recipe.name = Name

        --- Apodo y descripción
        Recipe.localised_name = GMOD.copy(space.entity.localised_name)
        table.insert(Recipe.localised_name, " - ")
        table.insert(Recipe.localised_name,
            damage and
            { "damage-type-name." .. damage } or
            { "gui.all" }
        )
        Recipe.localised_description = { "" }

        --- Tiempo de fabricación
        Recipe.energy_required = 3 * Recipe.energy_required

        --- Elimnar propiedades inecesarias
        Recipe.main_product = nil

        --- Productividad
        Recipe.allow_productivity = true
        Recipe.maximum_productivity = 1000000

        --- Agregar indicador del MOD
        Recipe.icons = GMOD.copy(space.item.icons)
        table.insert(Recipe.icons, This_MOD.indicator)

        --- Receta desbloqueada por tecnología
        Recipe.enabled = space.tech == nil

        --- Subgrupo y Order
        Recipe.subgroup = space.subgroup
        Recipe.order = Order

        --- Ingredientes
        Recipe.ingredients = {}
        if damage then
            table.insert(Recipe.ingredients, {
                type = "item",
                name = space.item.name,
                amount = 1
            })
        end

        --- Resultados
        Recipe.results = { {
            type = "item",
            name = Name,
            amount = 1
        } }

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Crear el prototipo
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        GMOD.extend(Recipe)
        return Recipe

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear para todos los tipos de daño
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function all(damage)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Cargar o crear de ser necesario
        local Recipe = one()

        --- Tiene el valor a agregar
        if
            GMOD.get_tables(
                Recipe.ingredients,
                "name",
                space.name .. damage
            )
        then
            return
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Agregar el ingrediente a la receta existente
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        table.insert(Recipe.ingredients, {
            type = "item",
            name = space.name .. damage,
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
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Nombre a usar
        local Name = space.name .. (damage or "all") .. "-tech"

        --- Renombrar
        local Tech = data.raw.technology[Name]

        --- Existe
        if Tech then
            return Tech
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Duplicar el elemento
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        Tech = GMOD.copy(space.tech)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar algunas propiedades
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Nombre
        Tech.name = Name

        --- Apodo y descripción
        Tech.localised_name = GMOD.copy(space.entity.localised_name)
        table.insert(Tech.localised_name, " - ")
        table.insert(Tech.localised_name,
            damage and
            { "damage-type-name." .. damage } or
            { "gui.all" }
        )
        Tech.localised_description = { "" }

        --- Cambiar icono
        Tech.icons = GMOD.copy(space.item.icons)
        table.insert(Tech.icons, This_MOD.indicator_tech_bg)
        table.insert(Tech.icons, This_MOD.indicator_tech)

        --- Tech previas
        Tech.prerequisites = {}
        if damage then
            table.insert(Tech.prerequisites, space.tech.name)
        end

        --- Efecto de la tech
        Tech.effects = { {
            type = "unlock-recipe",
            recipe = space.name .. (damage or "all")
        } }

        --- Tech se activa con una fabricación
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
        return Tech

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

        --- Cargar o crear de ser necesario
        local Tech = one()

        --- Tiene el valor a agregar
        if
            GMOD.get_key(
                Tech.prerequisites,
                space.name .. damage .. "-tech"
            )
        then
            return
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Agregar el prerequisito a la tech existente
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        table.insert(Tech.prerequisites,
            space.name .. damage .. "-tech"
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
