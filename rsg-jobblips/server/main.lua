local RSGCore = exports['rsg-core']:GetCoreObject()
local playerBlips = {}
local function UpdatePlayerBlip(playerId)
    local Player = RSGCore.Functions.GetPlayer(playerId)
    if not Player then return end
    
    local jobName = Player.PlayerData.job.name
    local jobConfig = Config.Jobs[jobName] or {}
    local isTracked = jobConfig.tracked or false
    
    if Config.BlipsEnabled and isTracked then
        local ped = GetPlayerPed(playerId)
        if DoesEntityExist(ped) then
            local coords = GetEntityCoords(ped)
            local firstName = Player.PlayerData.charinfo.firstname
            local lastName = Player.PlayerData.charinfo.lastname
            local displayJobName = jobName == 'vallaw' and 'Sheriff' or 
                                   jobName == 'medic' and 'Medic' or 
                                   jobName
            local blipName = string.format("%s %s (%s)", firstName, lastName, displayJobName)
            playerBlips[playerId] = {
                coords = coords,
                blipColor = jobConfig.blipColor or Config.DefaultBlipColor,
                name = blipName,
                job = jobName
            }
        end
    else
        playerBlips[playerId] = nil
    end
end
local function UpdateAllPlayerBlips()
    for _, playerId in ipairs(GetPlayers()) do
        UpdatePlayerBlip(tonumber(playerId))
    end
end
local function SendBlipDataToAllClients()
    TriggerClientEvent('phil:client:UpdateAllBlips', -1, playerBlips)
end
Citizen.CreateThread(function()
    while true do
        UpdateAllPlayerBlips()
        SendBlipDataToAllClients()
        Citizen.Wait(5000) -- Update every 5 seconds
    end
end)
RegisterNetEvent('RSGCore:Server:OnPlayerLoaded', function(source)
    UpdatePlayerBlip(source)
    SendBlipDataToAllClients()
end)
AddEventHandler('playerDropped', function(reason)
    playerBlips[source] = nil
    SendBlipDataToAllClients()
end)
RegisterNetEvent('phil:server:UpdateJob', function()
    local src = source
    UpdatePlayerBlip(src)
    SendBlipDataToAllClients()
end)
RSGCore.Functions.CreateCallback('phil:server:GetAllBlipData', function(source, cb)
    local Player = RSGCore.Functions.GetPlayer(source)
    local playerJob = Player.PlayerData.job.name
    cb(playerBlips, playerJob)
end)
RSGCore.Functions.CreateCallback('phil:server:GetPlayerJob', function(source, cb)
    local Player = RSGCore.Functions.GetPlayer(source)
    if Player then
        cb(Player.PlayerData.job.name)
    else
        cb(nil)
    end
end)
RegisterNetEvent('RSGCore:Server:OnJobUpdate', function(source, job)
    UpdatePlayerBlip(source)
    SendBlipDataToAllClients()
end)

RegisterCommand('toggleblips', function(source, args, rawCommand)
    local Player = RSGCore.Functions.GetPlayer(source)
    
    -- Check if player has admin permissions
    if RSGCore.Functions.HasPermission(source, 'admin') then
        Config.BlipsEnabled = not Config.BlipsEnabled
        TriggerClientEvent('RSGCore:Notify', source, 'Job Blips ' .. (Config.BlipsEnabled and 'Enabled' or 'Disabled'))
        
        -- Immediately update blips for all players
        UpdateAllPlayerBlips()
        SendBlipDataToAllClients()
    else
        TriggerClientEvent('RSGCore:Notify', source, 'You do not have permission to use this command')
    end
end)