

-- Call every 10 seconds till the end of time
local lfgScannerTimer = C_Timer.NewTicker(10, function()
    RequestLFDPlayerLockInfo()
end, nil)


-- No args passed

local lfgState = {}
local lfgStateFirstRun = true

local lfgScanner = function(...)
    -- Get a list of all the random dungeons and their ids
    -- for i = 1, GetNumRandomDungeons() do
    --     local id, name = GetLFGRandomDungeonInfo(i)
    --     print(id .. ": " .. name)
    -- end

    -- First run get a list of all valid random dungeons
    if lfgStateFirstRun then
        for i = 1, GetNumRandomDungeons() do
            local id, name = GetLFGRandomDungeonInfo(i)

            -- 1045 is Random Legion Dungeon, and game keeps saying there is a reward, but the UI says there is not?
            if id ~= 1045 then
                lfgState[id] = {name=name, forTank=false, forHealer=false, forDamage=false }
            end
        end
        lfgStateFirstRun = false
    end

    for randomDungeonId, randomDuneonDetails in pairs(lfgState) do
        local eligible, forTank, forHealer, forDamage, itemCount, money, xp = GetLFGRoleShortageRewards(randomDungeonId, 1)

        if randomDuneonDetails['forTank'] == true and forTank == false then
            print('LookingForLoot LFG Scanner  --  |cFFC00000Tank Full|r  for  |cFFFFD000' .. randomDuneonDetails['name'] .. '|r')
        elseif randomDuneonDetails['forTank'] == false and forTank == true then
            print('LookingForLoot LFG Scanner  --  |cFF00C000Tank Needeed|r  for  |cFFFFD000' .. randomDuneonDetails['name'] .. '|r')
            PlaySoundKitID(1277) -- fx_chest_openwooden
        end

        if randomDuneonDetails['forHealer'] == true and forHealer == false then
            print('LookingForLoot LFG Scanner  --  |cFFC00000Healer Full|r  for  |cFFFFD000' .. randomDuneonDetails['name'] .. '|r')
        elseif randomDuneonDetails['forHealer'] == false and forHealer == true then
            print('LookingForLoot LFG Scanner  --  |cFF00C000Healer Needeed|r  for  |cFFFFD000' .. randomDuneonDetails['name'] .. '|r')
            PlaySoundKitID(1277) -- fx_chest_openwooden
        end

        if randomDuneonDetails['forDamage'] == true and forDamage == false then
            print('LookingForLoot LFG Scanner  --  |cFFC00000Damage Full|r  for  |cFFFFD000' .. randomDuneonDetails['name'] .. '|r')
        elseif randomDuneonDetails['forDamage'] == false and forDamage == true then
            print('LookingForLoot LFG Scanner  --  |cFF00C000Damage Needeed|r  for  |cFFFFD000' .. randomDuneonDetails['name'] .. '|r')
            PlaySoundKitID(1277) -- fx_chest_openwooden
        end

        lfgState[randomDungeonId]['forTank'] = forTank
        lfgState[randomDungeonId]['forHealer'] = forHealer
        lfgState[randomDungeonId]['forDamage'] = forDamage
    end
end



local rfState = {}

local rfScanner = function(...)
    for i=1, GetNumRFDungeons() do
        local rf_id, rf_name = GetRFDungeonInfo(i)
        local eligible, forTank, forHealer, forDamage, itemCount, money, xp = GetLFGRoleShortageRewards(rf_id, 1)

        if rf_id ~= nil and eligible then
            
            if rfState[rf_id] == nil then
                rfState[rf_id] = {forTank=false, forHealer=false, forDamage=false}
            end
            
            if rfState[rf_id]['forTank'] == false and forTank == true then
                print('LookingForLoot RF Scanner  --  |cFF00C000Tank Needeed|r  for  |cFFFFD000' .. rf_name .. '|r')
            elseif rfState[rf_id]['forTank'] == true and forTank == false then
                print('LookingForLoot RF Scanner  --  |cFF00C000Tank Full|r  for  |cFFFFD000' .. rf_name .. '|r')
            end

            if rfState[rf_id]['forHealer'] == false and forHealer == true then
                print('LookingForLoot RF Scanner  --  |cFF00C000Healer Needeed|r  for  |cFFFFD000' .. rf_name .. '|r')
            elseif rfState[rf_id]['forHealer'] == true and forHealer == false then
                print('LookingForLoot RF Scanner  --  |cFF00C000Healer Full|r  for  |cFFFFD000' .. rf_name .. '|r')
            end
            
            if rfState[rf_id]['forDamage'] == false and forDamage == true then
                print('LookingForLoot RF Scanner  --  |cFF00C000Damage Needeed|r  for  |cFFFFD000' .. rf_name .. '|r')
            elseif rfState[rf_id]['forDamage'] == true and forDamage == false then
                print('LookingForLoot RF Scanner  --  |cFF00C000Damage Full|r  for  |cFFFFD000' .. rf_name .. '|r')
            end
        end
                
        rfState[rf_id] = {forTank=forTank, forHealer=forHealer, forDamage=forDamage}
        
    end
end




-- Default settings
if LookingForLootSettings == nil then LookingForLootSettings = {} end
if LookingForLootSettings.Enabled == nil then LookingForLootSettings.Enabled = true end


-- Slash commands
SLASH_LookingForLoot1 = '/lfl'
SlashCmdList['LookingForLoot'] = function(msg, editbox)
    if msg == 'hide' then      
        print('LookingForLoot hiding')
        LookingForLootSettings.Enabled = false
    elseif msg == 'show' then
        print('LookingForLoot showing')
        LookingForLootSettings.Enabled = true
    else
        print('LookingForLoot (version: |cFFFFD000' .. GetAddOnMetadata('LookingForLoot', 'Version') .. '|r) - Commands:')
		print('  /lfl show - Announce messages')
		print('  /lfl hide - Supress messages')
    end
end


-- Default Frame
local lookingForLootPanel = CreateFrame('Frame', 'lookingForLootPanel', UIParent)
lookingForLootPanel:Hide()
lookingForLootPanel:RegisterEvent('LFG_UPDATE_RANDOM_INFO')


lookingForLootPanel:SetScript('OnEvent', function(self, event, ...)
    if event == 'LFG_UPDATE_RANDOM_INFO' and LookingForLootSettings.Enabled then
        lfgScanner(...)
        rfScanner(...)
    end
end)
