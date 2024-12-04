local RSGCore = exports['rsg-core']:GetCoreObject()
local playerJob = nil
local blips = {}
local function CreateOrUpdateBlip(playerId, blipData)
    if blips[playerId] then
        RemoveBlip(blips[playerId])
    end
    local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, blipData.coords.x, blipData.coords.y, blipData.coords.z)
    
    if blip then
        local jobConfig = Config.Jobs[blipData.job] or {}
        local blipSprite = jobConfig.blipSprite or Config.DefaultBlipSprite
        local blipColor = jobConfig.blipColor or Config.DefaultBlipColor
        
        Citizen.InvokeNative(0x74F74D3207ED525C, blip, blipSprite, 1) -- SetBlipSprite
        Citizen.InvokeNative(0xD3F08C6ECD625A16, blip, Config.DefaultBlipScale) -- SetBlipScale
        Citizen.InvokeNative(0x662D364ABF16DE2F, blip, blipColor) -- SetBlipColor
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, blipData.name) -- SetBlipName
        
        blips[playerId] = blip
    end
end
RegisterNetEvent('phil:client:UpdateAllBlips', function(blipData)
    for playerId, data in pairs(blipData) do
        if tonumber(playerId) ~= GetPlayerServerId(PlayerId()) then
            CreateOrUpdateBlip(playerId, data)
        end
    end
    
    for playerId, blip in pairs(blips) do
        if not blipData[playerId] then
            RemoveBlip(blip)
            blips[playerId] = nil
        end
    end
end)
RegisterNetEvent('RSGCore:Client:OnPlayerLoaded', function()
    RSGCore.Functions.TriggerCallback('phil:server:GetPlayerJob', function(job)
        playerJob = job
        RSGCore.Functions.TriggerCallback('phil:server:GetAllBlipData', function(blipData)
            for playerId, data in pairs(blipData) do
                if tonumber(playerId) ~= GetPlayerServerId(PlayerId()) then
                    CreateOrUpdateBlip(playerId, data)
                end
            end
        end)
    end)
end)
RegisterNetEvent('RSGCore:Client:OnJobUpdate', function(job)
    playerJob = job.name
    RSGCore.Functions.TriggerCallback('phil:server:GetAllBlipData', function(blipData)
        for playerId, data in pairs(blipData) do
            if tonumber(playerId) ~= GetPlayerServerId(PlayerId()) then
                CreateOrUpdateBlip(playerId, data)
            end
        end
    end)
end)