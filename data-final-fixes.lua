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
    for _, spaces in pairs(This_MOD.to_be_processed) do
        for _, space in pairs(spaces) do
            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

            --- Crear los elementos
            This_MOD.create_subgroup(space)
            This_MOD.create_item(space)
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

    This_MOD.indicator = { icon = Indicator, scale = 0.15, shift = { 12, -12 } }
    This_MOD.indicator_bg = { icon = GMOD.color.black, scale = 0.15, shift = { 12, -12 } }

    This_MOD.indicator_tech = { icon = Indicator, scale = 0.50, shift = { 50, -50 } }
    This_MOD.indicator_tech_bg = { icon = GMOD.color.black, scale = 0.50, shift = { 50, -50 } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en este MOD
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Daños a procesar
    This_MOD.damages = {}

    --- Digitos necesarios para ordenar
    This_MOD.digits = 0

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
    This_MOD.damages = (function()
        local Damages = {}
        for damage, _ in pairs(data.raw["damage-type"]) do
            table.insert(Damages, damage)
        end
        return Damages
    end)()

    --- Cantidad de digitod
    This_MOD.digits = GMOD.digit_count(#This_MOD.damages) + 1

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Función para analizar cada elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function valide_armor(item)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Validar el item
        if not item then return end

        --- Validar el tipo
        if item.type ~= "armor" then return end

        --- Validar si ya fue procesado
        local That_MOD =
            GMOD.get_id_and_name(item.name) or
            { ids = "-", name = item.name }

        local Name =
            GMOD.name .. That_MOD.ids ..
            This_MOD.id .. "-" ..
            That_MOD.name .. "-"

        local Processed = true
        for _, damage in pairs(This_MOD.damages) do
            Processed = Processed and GMOD.items[Name .. damage] ~= nil
            if not Processed then break end
        end
        if Processed then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Valores para el proceso
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Space = {}
        Space.item = item
        Space.name = Name

        Space.recipe = GMOD.recipes[item.name]
        Space.tech = GMOD.get_technology(Space.recipe)
        Space.recipe = Space.recipe and Space.recipe[1] or nil

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Guardar la información
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        This_MOD.to_be_processed[item.type] = This_MOD.to_be_processed[item.type] or {}
        This_MOD.to_be_processed[item.type][item.name] = Space

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Preparar los datos a usar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    valide_armor(GMOD.items[This_MOD.setting.armor_base])

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
    local New = string.sub(space.name, 1, -2)
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
    --- Crear para cada tipo de daño
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function one(i, damage)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Nombre a usar
        local Name = space.name .. (damage or "all")

        --- Renombrar
        local Item = GMOD.items[Name]

        --- Actualizar order
        if Item then
            Item.order = GMOD.pad_left_zeros(This_MOD.digits, i) .. "0"
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
        Item.name = Name

        --- Apodo y descripción
        Item.localised_name = GMOD.copy(space.item.localised_name)
        table.insert(Item.localised_name, " - ")
        table.insert(Item.localised_name,
            damage and
            { "damage-type-name." .. damage } or
            { "gui.all" }
        )
        Item.localised_description = { "" }

        --- Subgrupo y Order
        Item.subgroup = string.sub(space.name, 1, -2)
        Item.order = GMOD.pad_left_zeros(This_MOD.digits, i) .. "0"

        --- Agregar indicador del MOD
        table.insert(Item.icons, This_MOD.indicator_bg)
        table.insert(Item.icons, This_MOD.indicator)

        --- Inmunidad de la armadura
        Item.resistances = {}
        if damage then
            table.insert(Item.resistances, {
                type = damage,
                decrease = 0,
                percent = 100
            })
        end

        --- Vista previa
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

        --- Nombre a usar
        local Name = space.name .. "all"

        --- Crear la armadura
        if not GMOD.items[Name] then
            one(#This_MOD.damages + 1)
        end

        --- Renombrar
        local Item = GMOD.items[Name]

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        for _, resistance in pairs(Item.resistances) do
            if resistance.type == damage then
                return
            end
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Agregar la resistencia
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        table.insert(Item.resistances, { type = damage, percent = 100 })

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

        --- Renombrar
        local Recipe = data.raw.recipe[Name]

        --- Actualizar order
        if Recipe then
            Recipe.order = GMOD.pad_left_zeros(This_MOD.digits, i) .. "0"
            return
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
        Recipe.localised_name = GMOD.copy(space.item.localised_name)
        table.insert(Recipe.localised_name, " - ")
        table.insert(Recipe.localised_name,
            damage and
            { "damage-type-name." .. damage } or
            { "gui.all" }
        )
        Recipe.localised_description = { "" }

        --- Tiempo de fabricación
        Recipe.energy_required = 3 * (Recipe.energy_required or 0.5)

        --- Elimnar propiedades inecesarias
        Recipe.main_product = nil

        --- Productividad
        Recipe.allow_productivity = true
        Recipe.maximum_productivity = 1000000

        --- Agregar indicador del MOD
        Recipe.icons = GMOD.copy(space.item.icons)
        table.insert(Recipe.icons, This_MOD.indicator_bg)
        table.insert(Recipe.icons, This_MOD.indicator)

        --- Habilitar la receta
        Recipe.enabled = space.tech == nil

        --- Subgrupo y Order
        Recipe.subgroup = string.sub(space.name, 1, -2)
        Recipe.order = GMOD.pad_left_zeros(This_MOD.digits, i) .. "0"

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
            name = Recipe.name,
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

        --- Nombre a usar
        local Name = space.name .. "all"

        --- Crear la receta para la armadura
        if not data.raw.recipe[Name] then
            one(#This_MOD.damages + 1)
        end

        --- Renombrar
        local Recipe = data.raw.recipe[Name]

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        for _, ingredient in pairs(Recipe.ingredients) do
            if ingredient.name == space.name .. damage then
                return
            end
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

        --- Tech creada 
        if data.raw.technology[Name] then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Duplicar el elemento
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        Tech = GMOD.copy(space.tech)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar algunas propiedades
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Nombre
        Tech.name = Name

        --- Apodo y descripción
        Tech.localised_name = GMOD.copy(space.item.localised_name)
        table.insert(Tech.localised_name, " - ")
        table.insert(Tech.localised_name,
            damage and
            { "damage-type-name." .. damage } or
            { "gui.all" }
        )
        Tech.localised_description = nil

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
                    space.name .. (
                        damage or
                        This_MOD.damages[math.random(1, #This_MOD.damages)]
                    ),
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
        --- Validar si se creó "all"
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Nombre a usar
        local Name = space.name .. "all-tech"

        --- Crear la receta para la armadura
        if not data.raw.technology[Name] then
            one()
        end

        --- Renombrar
        local Tech = data.raw.technology[Name]

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        for _, prerequisite in pairs(Tech.prerequisites) do
            if prerequisite == space.name .. damage .. "-tech" then
                return
            end
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
