local RSGCore = exports['rsg-core']:GetCoreObject()
local playerBlips = {}
local function UpdatePlayerBlip(playerId)
    local Player = RSGCore.Functions.GetPlayer(playerId)
    if not Player then return end
    
    local jobName = Player.PlayerData.job.name
    local jobConfig = Config.Jobs[jobName] or {}
    local isTracked = jobConfig.tracked or false
    
    -- Only create blips if globally enabled and job is tracked
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
    -- Iterate through all players
    for _, playerId in ipairs(GetPlayers()) do
        local Player = RSGCore.Functions.GetPlayer(tonumber(playerId))
        if Player then
            local playerJob = Player.PlayerData.job.name
            
            -- If player is unemployed, send empty blips table
            if playerJob == 'unemployed' then
                TriggerClientEvent('phil:client:UpdateAllBlips', playerId, {})
            else
                -- Send full blips data to non-unemployed players
                TriggerClientEvent('phil:client:UpdateAllBlips', playerId, playerBlips)
            end
        end
    end
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
    
    -- If player is unemployed, return empty blips
    if playerJob == 'unemployed' then
        cb({}, playerJob)
    else
        cb(playerBlips, playerJob)
    end
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
    Config.BlipsEnabled = not Config.BlipsEnabled
    
    -- Use rNotify style notification
    local message = Config.BlipsEnabled and "Job Blips Enabled" or "Job Blips Disabled"
    TriggerClientEvent('rNotify:ShowSimpleCenterText', source, message, 4000)
    
    -- Update blips for all players
    UpdateAllPlayerBlips()
    SendBlipDataToAllClients()
end)