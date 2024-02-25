Config = {

    --------------------------------------------------------
    --------------------------------------------------------
    -- 1 = ESX 1.1 (Old ESX With trigger) 
    -- 2 = (New ESX With Export) 
    Framework = 1, 
    Extended_Name = "es_extended",
    getSharedObject = "esx:getSharedObject",

    -- 1 = mysql-async
    -- 2 = ghmattimysql
    -- 3 = oxmysql
    -- (don't forget to change in the fxmanifest)
    Mysql = 3,

    Categorie_Table = "vehicle_categories",
    Vehicle_Table = "vehicles",
    --------------------------------------------------------
    --------------------------------------------------------

    Access = {"admin", "dev"}, 

    Language = {
        MenuName = "Concessionnaire",
        MenuSubName = "Gestion",
    },

}

Config.Notification = function(message, type)
    if type == "success" then
        TriggerEvent('esx:showNotification', "~g~"..message)
    elseif type == "error" then
        TriggerEvent('esx:showNotification', "~r~"..message)
    end
end

Config.KeyboardInput = function(TextEntry, ExampleText)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    blockinput = true
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", 30)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Wait(0)
    end 
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end