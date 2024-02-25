if Config.Framework == 1 then
    ESX = nil
    TriggerEvent(Config.getSharedObject, function(obj) ESX = obj end)
elseif Config.Framework == 2 then 
    ESX = exports[Config.Extended_Name]:getSharedObject()
end

isPlayerAdmin = function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    for _,v in pairs(Config.Access) do 
        if xPlayer.group == v then 
            return true
        end
    end
    return false
end

RegisterCommand('manageCardealer', function(source, args, user)
    if not isPlayerAdmin(source) then
        return TriggerClientEvent('eManageCarDealer:SendNotif', source, "Vous n'avez pas la permission pour ouvrir la gestion concessionnaire", "error")
    end
    TriggerClientEvent('openManageCardealer', source)
end, false)

ESX.RegisterServerCallback('getVehicleCategories', function(source, cb)
    local query = 'SELECT * FROM '..Config.Categorie_Table..''
    ExecuteSql(query, {}, function(result)
        cb(result)
    end)
end)

ESX.RegisterServerCallback('getVehiclesByCategory', function(source, cb, categoryName)
    local query = 'SELECT * FROM '..Config.Vehicle_Table..' WHERE category = @categoryName'
    local params = {['@categoryName'] = categoryName}
    
    ExecuteSql(query, params, function(result)
        cb(result)
    end)
end)

RegisterNetEvent('renameVehicleCategory')
AddEventHandler('renameVehicleCategory', function(oldName, newName)
    local source = source 
    if not isPlayerAdmin(source) then
        return TriggerClientEvent('eManageCarDealer:SendNotif', source, "Vous n'avez pas les permissions pour cela", "error")
    end
    local query = 'UPDATE '..Config.Categorie_Table..' SET label = @newName WHERE label = @oldName'
    local params = {['@oldName'] = oldName, ['@newName'] = newName}
    ExecuteSql(query, params, function(rowsChanged)
        if rowsChanged and rowsChanged > 0 then
            TriggerClientEvent('eManageCarDealer:SendNotif', source, "Catégorie renommée avec succès", "success")
        else
            TriggerClientEvent('eManageCarDealer:SendNotif', source, "Erreur lors du renommage de la catégorie", "error")
        end
    end)
end)

RegisterNetEvent('deleteVehicleCategory')
AddEventHandler('deleteVehicleCategory', function(categoryName)
    local source = source 
    if not isPlayerAdmin(source) then
        return TriggerClientEvent('eManageCarDealer:SendNotif', source, "Vous n'avez pas les permissions pour cela", "error")
    end
    local query = 'DELETE FROM '..Config.Categorie_Table..' WHERE label = @categoryName'
    local params = {['@categoryName'] = categoryName}
    ExecuteSql(query, params, function(rowsChanged)
        if rowsChanged then
            TriggerClientEvent('eManageCarDealer:SendNotif', source, "Catégorie supprimée avec succès", "success")
        else
            TriggerClientEvent('eManageCarDealer:SendNotif', source, "Erreur lors de la suppression de la catégorie", "error")
        end
    end)
end)

RegisterNetEvent("createVehicleCategory")
AddEventHandler("createVehicleCategory", function(catName, catLabel)
    local source = source 
    if not isPlayerAdmin(source) then
        return TriggerClientEvent('eManageCarDealer:SendNotif', source, "Vous n'avez pas les permissions pour cela", "error")
    end
    local query = 'INSERT INTO '..Config.Categorie_Table..' (name, label) VALUES (@name, @label)'
    local params = {['@name'] = catName, ['@label'] = catLabel}
    ExecuteSql(query, params, function(result)
        if result and result.affectedRows > 0 then
            TriggerClientEvent('eManageCarDealer:SendNotif', source, "Catégorie ajoutée avec succès", "success")
        else
            TriggerClientEvent('eManageCarDealer:SendNotif', source, "Erreur lors de l'ajout de la catégorie", "error")
        end
    end)
end)

RegisterNetEvent("updateVehData")
AddEventHandler("updateVehData", function(model, data)
    local source = source 
    if not isPlayerAdmin(source) then
        return TriggerClientEvent('eManageCarDealer:SendNotif', source, "Vous n'avez pas les permissions pour cela", "error")
    end
    local query = 'UPDATE '..Config.Vehicle_Table..' SET '
    local queryParams = {}
    local firstParam = true

    for key, value in pairs(data) do
        if not firstParam then
            query = query .. ', '
        end
        query = query .. key .. ' = @' .. key
        queryParams['@' .. key] = value
        firstParam = false
    end

    query = query .. ' WHERE model = @model'
    queryParams['@model'] = model

    ExecuteSql(query, queryParams, function(rowsChanged)
        if rowsChanged then
            TriggerClientEvent('eManageCarDealer:SendNotif', source, "Véhicule modifié avec succès", "success")
        else
            TriggerClientEvent('eManageCarDealer:SendNotif', source, "Erreur lors de la mise à jour du véhicule", "error")
        end
    end)
end)


RegisterNetEvent("deleteVehicleFromConcess")
AddEventHandler("deleteVehicleFromConcess", function(model)
    local source = source 
    if not isPlayerAdmin(source) then
        return TriggerClientEvent('eManageCarDealer:SendNotif', source, "Vous n'avez pas les permissions pour cela", "error")
    end
    local query = 'DELETE FROM '..Config.Vehicle_Table..' WHERE model = @model'
    local params = {['@model'] = model}
    ExecuteSql(query, params, function(rowsChanged)
        if rowsChanged then
            TriggerClientEvent('eManageCarDealer:SendNotif', source, "Véhicule supprimé avec succès", "success")
        else
            TriggerClientEvent('eManageCarDealer:SendNotif', source, "Erreur lors de la suppression du véhicule", "error")
        end
    end)
end)


RegisterNetEvent("addVehicleToConcess")
AddEventHandler("addVehicleToConcess", function(modelName, vehicleName, price, category)
    local source = source 
    if not isPlayerAdmin(source) then
        return TriggerClientEvent('eManageCarDealer:SendNotif', source, "Vous n'avez pas les permissions pour cela", "error")
    end
    local query = 'INSERT INTO '..Config.Vehicle_Table..' (model, name, price, category) VALUES (@model, @name, @price, @category)'
    local params = {['@model'] = modelName, ['@name'] = vehicleName, ['@price'] = price, ['@category'] = category}
    ExecuteSql(query, params, function(rowsChanged)
        if rowsChanged then
            TriggerClientEvent('eManageCarDealer:SendNotif', source, "Véhicule ajouté avec succès", "success")
        else
            TriggerClientEvent('eManageCarDealer:SendNotif', source, "Erreur lors de l'ajout du véhicule", "error")
        end
    end)
end)

function ExecuteSql(query, params, cb)
    if Config.Mysql == 3 then
        exports.oxmysql:execute(query, params, cb)
    elseif Config.Mysql == 2 then
        exports.ghmattimysql:execute(query, params, cb)
    elseif Config.Mysql == 1 then
        MySQL.Async.fetchAll(query, params, cb)
    else
        print("Erreur : Aucun driver SQL a été détecté")
    end
end
