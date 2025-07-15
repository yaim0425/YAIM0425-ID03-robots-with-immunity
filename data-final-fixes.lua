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

    --- Ingredientes a usar
    This_MOD.build_ingredients()

    --- Entidades a afectar
    This_MOD.build_info()

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

    --- Información de referencia
    This_MOD.info = {}
    This_MOD.ingredients = {}
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
function This_MOD.build_ingredients()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Lista de ingredientes 
    local Ingredients = {}
    Ingredients["battery"] = {
        amount = 3,
        eval = function(equipment)
            if equipment.type ~= "battery-equipment" then return end
            if not equipment.energy_source then return end
            if not equipment.energy_source.buffer_capacity then return end
            return GPrefix.number_unit(equipment.energy_source.buffer_capacity)
        end
    }
    Ingredients["solar-panel"] = {
        amount = 3,
        eval = function(equipment)
            if equipment.type ~= "solar-panel-equipment" then return end
            if not equipment.power then return end
            return GPrefix.number_unit(equipment.power)
        end
    }
    Ingredients["energy-shield"] = {
        amount = 3,
        eval = function(equipment)
            if equipment.type ~= "energy-shield-equipment" then return end
            if not equipment.max_shield_value then return end
            if equipment.max_shield_value == 0 then return end
            return equipment.max_shield_value
        end
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Recorrer los ingredientes
    for _, ingredient in pairs(Ingredients) do
        --- Valores de referencia
        local Now_value = 0
        local Equipment_name = ""

        --- Buscar el mejor equipo
        for _, equipment in pairs(GPrefix.Equipments) do
            repeat
                local New_value = ingredient.eval(equipment)
                if not New_value then break end
                if Now_value < New_value then
                    Equipment_name = equipment.name
                    Now_value = New_value
                end
            until true
        end

        --- No se encontró equipo
        if Now_value == 0 then return end

        --- Agregar el muevo ingrediente
        table.insert(
            This_MOD.ingredients,
            {
                type = "item",
                name = Equipment_name,
                amount = ingredient.amount
            }
        )
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

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
                        local Item = GPrefix.Items[result.name]
                        if Item.place_result == robot.name then
                            --- Crear el espacio para la entidad
                            This_MOD.info[type] = This_MOD.info[type] or {}
                            local Space = This_MOD.info[type][robot.name] or {}
                            This_MOD.info[type][robot.name] = Space

                            --- Guardar la información
                            Space.item = Item
                            Space.entity = robot
                            Space.recipe = GPrefix.Recipes[result.name][1]
                            Space.technology = GPrefix.get_technology(Space.recipe)

                            robot.factoriopedia_simulation = nil
                        end
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

---------------------------------------------------------------------------------------------------

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
