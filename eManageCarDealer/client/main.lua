if Config.Framework == 1 then
    ESX = nil
    Citizen.CreateThread(function()
        while ESX == nil do
            TriggerEvent(Config.getSharedObject, function(obj) ESX = obj end)
            Citizen.Wait(500)
        end
    end)
elseif Config.Framework == 2 then 
    ESX = exports[Config.Extended_Name]:getSharedObject()
end

RegisterNetEvent('openManageCardealer')
AddEventHandler('openManageCardealer', function()
    ESX.TriggerServerCallback('getVehicleCategories', function(categories)
        MenuGestion(categories)
    end)
end)

function MenuGestion(categories)
    local Indexx = 1
    local Indexx2 = 1
    local vehiclesToShow = {}
    local main_gestion = RageUI.CreateMenu(Config.Language.MenuName, Config.Language.MenuSubName)
    local sub_gestion = RageUI.CreateSubMenu(main_gestion, Config.Language.MenuName, Config.Language.MenuSubName)
    local three_gestion = RageUI.CreateSubMenu(main_gestion, Config.Language.MenuName, Config.Language.MenuSubName)
    local veh_gestion = RageUI.CreateSubMenu(sub_gestion, Config.Language.MenuName, Config.Language.MenuSubName)
    local choose_cat = RageUI.CreateSubMenu(veh_gestion, Config.Language.MenuName, Config.Language.MenuSubName)
    RageUI.Visible(main_gestion, not RageUI.Visible(main_gestion))

    while main_gestion do
        Citizen.Wait(0)
        RageUI.IsVisible(main_gestion, true, true, true, function()

            RageUI.Line(255,0,0)
            RageUI.ButtonWithStyle("→ Gestion catégorie", nil, {}, true, function(Hovered, Active, Selected)
                if Selected then
                    ESX.TriggerServerCallback('getVehicleCategories', function(categories)
                        categories = categories
                    end)
                end
            end, three_gestion)
            RageUI.Line(255,0,0)

            RageUI.Separator("↓ ~r~Les catégories~s~ ↓")

            for k,v in pairs(categories) do
                RageUI.ButtonWithStyle(v.label, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
                        vehiclesToShow = {}
                        selectedCategory = v.name
                        selectedCategoryLabel = v.label
                        ESX.TriggerServerCallback('getVehiclesByCategory', function(vehicles)
                            Wait(500)
                            vehiclesToShow = vehicles
                        end, selectedCategory)
                    end
                end, sub_gestion)
            end

        end)

        RageUI.IsVisible(sub_gestion, true, true, true, function()

            if json.encode(vehiclesToShow) == "[]" then
                RageUI.Separator("~o~Chargement en cours")
            else
                RageUI.Line(255,0,0)
                RageUI.ButtonWithStyle("→ Ajouter un véhicule", nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
                        local modelName = Config.KeyboardInput("Entrez le modèle du véhicule", "")
                        local vehicleName = Config.KeyboardInput("Entrez le nom du véhicule", "")
                        local price = Config.KeyboardInput("Entrez le prix du véhicule", "")
                        local category = selectedCategory
                
                        if modelName ~= "" and vehicleName ~= "" and price ~= "" and tonumber(price) then
                            TriggerServerEvent("addVehicleToConcess", modelName, vehicleName, price, category)
                            vehiclesToShow = "[]"
                            Wait(100)
                            ESX.TriggerServerCallback('getVehiclesByCategory', function(vehicles)
                                vehiclesToShow = vehicles
                            end, selectedCategory)
                            Wait(100)
                        end
                    end
                end)
                RageUI.Line(255,0,0)
                RageUI.Separator("↓ ~r~Véhicules de la catégorie ~s~→ ~b~" .. selectedCategoryLabel.." ~s~↓")
                for _, vehicle in pairs(vehiclesToShow) do
                    RageUI.ButtonWithStyle("→ "..vehicle.name, nil, {RightLabel = vehicle.price.."$"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            data = vehicle
                        end
                    end, veh_gestion)
                end
            end

        end)

        RageUI.IsVisible(veh_gestion, true, true, true, function()

            RageUI.Line(255,0,0)
            RageUI.Separator("Prix → "..data.price.."$")
            RageUI.Separator("Nom → "..data.name)
            RageUI.Separator("Modèle → "..data.model)
            RageUI.Separator("Catégorie → "..data.category)
            RageUI.Line(255,0,0)

            RageUI.List("→ Modifier", {"Prix", "Nom"}, Indexx2, nil, {}, true, function(Hovered, Active, Selected, Index)
                Indexx2 = Index
                if Selected then
                    if Index == 1 then 
                        local newPrice = Config.KeyboardInput("Entrez le nouveau prix", "")
                        if newPrice ~= "" and tonumber(newPrice) then
                            TriggerServerEvent("updateVehData", data.model, {price = newPrice})
                            data.price = tonumber(newPrice)
                        end
                    elseif Index == 2 then
                        local newName = Config.KeyboardInput("Entrez le nouveau nom", "")
                        if newName ~= "" or newName ~= " " then
                            TriggerServerEvent("updateVehData", data.model, {name = newName})
                            data.name = newName
                        end
                    end

                end
            end)

            RageUI.ButtonWithStyle("→ Modifier la catégorie", nil, {}, true, function(Hovered, Active, Selected)
            end, choose_cat)

            RageUI.ButtonWithStyle("→ Supprimer le véhicule", nil, {}, true, function(Hovered, Active, Selected)
                if Selected then 
                    local Confirm = Config.KeyboardInput("Entrez 'oui' pour confirmer", "")
                    if Confirm and Confirm ~= "oui" then 
                        print("Annuler")
                    else
                        TriggerServerEvent("deleteVehicleFromConcess", data.model)
                        vehiclesToShow = "[]"
                        Wait(100)
                        ESX.TriggerServerCallback('getVehiclesByCategory', function(vehicles)
                            vehiclesToShow = vehicles
                        end, selectedCategory)
                        Wait(100)
                        RageUI.GoBack()
                    end
                end
            end)

        end)

        RageUI.IsVisible(choose_cat, true, true, true, function()

            for k,v in pairs(categories) do
                RageUI.ButtonWithStyle("→ "..v.label, nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent("updateVehData", data.model, {category = v.name})
                        data.category = v.name
                        RageUI.GoBack()
                    end
                end)
            end
        end)

        RageUI.IsVisible(three_gestion, true, true, true, function()

            RageUI.Line(255,0,0)
            RageUI.ButtonWithStyle("→ Ajouter une catégorie", nil, {}, true, function(Hovered, Active, Selected)
                if Selected then
                    local catName = Config.KeyboardInput("Entrez le nom de la catégorie", "")
                    local catLabel = Config.KeyboardInput("Entrez le label de la catégorie", "")
                    if catName ~= "" and catLabel ~= "" then
                        TriggerServerEvent("createVehicleCategory", catName, catLabel)
                        Wait(100)
                        ESX.TriggerServerCallback('getVehicleCategories', function(updatedCategories)
                            categories = updatedCategories
                        end)
                    end
                end
            end)
            RageUI.Line(255,0,0)

            RageUI.Separator("↓ ~r~Les catégories~s~ ↓")

            for k,v in pairs(categories) do
                RageUI.List(v.label, {"Renommer", "Supprimer"}, Indexx, nil, {}, true, function(Hovered, Active, Selected, Index)
                    Indexx = Index
                    if Selected then
                        if Index == 1 then 
                            local categoryName = v.label
                            local newName = Config.KeyboardInput("Nouveau nom pour la catégorie: " .. categoryName, "")
                            if newName and newName ~= "" and newName ~= " " then 
                                TriggerServerEvent("renameVehicleCategory", categoryName, newName)
                                Wait(100)
                                ESX.TriggerServerCallback('getVehicleCategories', function(updatedCategories)
                                    categories = updatedCategories
                                end)
                            end
                        elseif Index == 2 then

                            local categoryName = v.label
                            local Confirm = Config.KeyboardInput("Entrez 'oui' pour confirmer", "")
                            if Confirm and Confirm ~= "oui" then 
                                print("Annuler")
                            else
                                TriggerServerEvent("deleteVehicleCategory", categoryName)
                                Wait(100)
                                ESX.TriggerServerCallback('getVehicleCategories', function(updatedCategories)
                                    categories = updatedCategories
                                end)
                            end

                        end
                    end
                end)
            end

        end)

        if not RageUI.Visible(main_gestion) and not RageUI.Visible(sub_gestion) and not RageUI.Visible(three_gestion) and not RageUI.Visible(veh_gestion) and not RageUI.Visible(choose_cat) then
            main_gestion = RMenu:DeleteType(Config.Language.MenuName, true)
        end
    end
end

RegisterNetEvent('eManageCarDealer:SendNotif', function(message, type)
    Config.Notification(message, type)
end)