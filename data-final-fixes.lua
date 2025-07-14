---------------------------------------------------------------------------------------------------
---> data-final-fixes.lua <---
---------------------------------------------------------------------------------------------------

--- Contenedor de funciones y datos usados
--- unicamente en este archivo
local This_MOD = {}

---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Obtener información desde el nombre de MOD
    GPrefix.split_name_folder(This_MOD)

    --- Valores de la referencia
    This_MOD.setting_mod()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Entidades a afectar
    This_MOD.build_info()

    -- --- Ingredientes a usar
    -- This_MOD.BuildIngredients()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    -- --- Crear los nuevos prototipos
    -- for _, Type in pairs(This_MOD.info) do
    --     for _, Space in pairs(Type) do
    --         This_MOD.CreateRecipe(Space)
    --         This_MOD.CreateItem(Space)
    --         This_MOD.CreateEntity(Space)
    --     end
    -- end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Valores de la referencia
function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    -- --- Indicador
    -- This_MOD.localised_name = { "entity-description." .. This_MOD.prefix .. "with-immunity" }

    --- Información de referencia
    This_MOD.info = {}
    This_MOD.ingredients = {}
    -- This_MOD.oldItemName = {}
    This_MOD.resistances = {}

    --- Referencia
    This_MOD.types = {}
    table.insert(This_MOD.types, "construction-robot")
    table.insert(This_MOD.types, "logistic-robot")

    --- Indicador de mod
    This_MOD.indicator = {
        icon = data.raw["virtual-signal"]["signal-heart"].icons[1].icon,
        shift = { 4, -14 },
        scale = 0.15
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Crear ThisMOD.Ingredients
function This_MOD.BuildIngredients()
    --- Ingredientes a usar
    This_MOD.oldItemName = {
        This_MOD.getEnergyShield(),
        This_MOD.getBattery(),
        This_MOD.getSolarPanel()
    }

    --- Dar el formaro deseado
    for _, value in pairs(This_MOD.oldItemName) do
        table.insert(
            This_MOD.ingredients,
            {
                type   = "item",
                name   = value,
                amount = 3
            }
        )
    end
end

--- Buscar los ingredientes a usar
function This_MOD.getBattery()
    local equipment = { energy_source = { buffer_capacity = "1j" } }
    local now = GPrefix.getNumber(equipment.energy_source.buffer_capacity)
    for _, Equipment in pairs(GPrefix.Equipments) do
        if Equipment.type == "battery-equipment" then
            local next = GPrefix.getNumber(Equipment.energy_source.buffer_capacity)
            if next > now then
                equipment = Equipment
                now = next
            end
        end
    end
    return equipment.name
end

function This_MOD.getSolarPanel()
    local equipment = { power = "1j" }
    local now = GPrefix.getNumber(equipment.power)
    for _, Equipment in pairs(GPrefix.Equipments) do
        if Equipment.type == "solar-panel-equipment" then
            local next = GPrefix.getNumber(Equipment.power)
            if next > now then
                equipment = Equipment
                now = next
            end
        end
    end
    return equipment.name
end

function This_MOD.getEnergyShield()
    local equipment = { max_shield_value = 0 }
    local now = equipment.max_shield_value
    for _, Equipment in pairs(GPrefix.Equipments) do
        if Equipment.type == "energy-shield-equipment" then
            local next = Equipment.max_shield_value
            if next > now then
                equipment = Equipment
                now = next
            end
        end
    end
    return equipment.name
end

---------------------------------------------------------------------------------------------------

--- Información de referencia
function This_MOD.build_info()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Cargar las entidades a duplicar
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for _, type in pairs(This_MOD.types) do
        for _, robot in pairs(data.raw[type]) do
            repeat
                --- Validación
                if robot.hidden then break end
                if not robot.minable then break end
                if not robot.minable.results then break end

                for _, result in pairs(robot.minable.results) do
                    if result.type == "item" then
                        --- Crear el espacio para la entidad
                        This_MOD.info[type] = This_MOD.info[type] or {}
                        local Space = This_MOD.info[type][robot.name] or {}
                        This_MOD.info[type][robot.name] = Space

                        --- Guardar la información
                        table.insert(Space, {
                            recipe = GPrefix.Recipes[result.name][1],
                            item = GPrefix.Items[result.name],
                            entity = robot
                        })
                    end
                end
            until true
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Recistencias
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for damage, _ in pairs(data.raw["damage-type"]) do
        table.insert(
            This_MOD.resistances,
            {
                type = damage,
                percent = 100
            }
        )
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Crear las recetas
function This_MOD.CreateRecipe(space)
    --- Duplicar la receta
    local recipe   = util.copy(space.recipe)

    --- Actualizar propiedades
    recipe.name    = GPrefix.delete_prefix(space.recipe.name)
    recipe.name    = This_MOD.prefix .. recipe.name

    recipe.icons   = util.copy(space.item.icons)
    recipe.enabled = false
    table.insert(recipe.icons, This_MOD.indicator)

    local Order         = tonumber(recipe.order) + 1
    recipe.order        = GPrefix.pad_left(#recipe.order, Order)

    recipe.main_product = nil

    recipe.ingredients  = util.copy(This_MOD.ingredients)
    table.insert(
        recipe.ingredients,
        {
            type   = "item",
            name   = space.item.name,
            amount = 1
        }
    )

    recipe.results = { {
        type   = "item",
        name   = This_MOD.prefix .. GPrefix.delete_prefix(space.item.name),
        amount = 1
    } }

    --- Crear el prototipo
    GPrefix.addDataRaw({ recipe })

    --- Agregar las recetas en la tecnologia
    for _, oldItemName in pairs(This_MOD.oldItemName) do
        GPrefix.addRecipeToTechnology(oldItemName, nil, recipe)
        if not recipe.enabled then break end
    end
end

--- Crear los objetos
function This_MOD.CreateItem(space)
    --- Crear la entidad
    local item        = util.copy(space.item)

    item.name         = This_MOD.prefix .. GPrefix.delete_prefix(space.item.name)
    item.place_result = This_MOD.prefix .. GPrefix.delete_prefix(space.item.place_result)

    local Order       = tonumber(item.order) + 1
    item.order        = GPrefix.pad_left(#item.order, Order)

    --- Agregar el indicador
    table.insert(item.icons, This_MOD.indicator)

    --- Crear el prototipo
    GPrefix.addDataRaw({ item })
end

--- Crear las entidades
function This_MOD.CreateEntity(space)
    --- Crear la entidad
    local robot  = util.copy(space.entity)
    local result = robot.minable.results[1]

    --- Actualizar propiedades
    robot.name   = This_MOD.prefix .. GPrefix.delete_prefix(space.entity.name)
    result.name  = This_MOD.prefix .. GPrefix.delete_prefix(result.name)

    --- Agregar el indicador
    table.insert(robot.icons, This_MOD.indicator)

    --- Agregar la inmunidad al robot
    robot.resistances = This_MOD.resistances

    --- Crear el prototipo
    GPrefix.addDataRaw({ robot })
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
This_MOD.start()
GPrefix.var_dump(This_MOD)
ERROR()

---------------------------------------------------------------------------------------------------
