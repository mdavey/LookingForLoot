
local COLOR_CLASS_NEEDED = 'FF00C000'   -- dark greenish
local COLOR_CLASS_FULL = 'FFC00000'     -- dark red
local COLOR_INSTANCE_NAME = 'FFFFD000'  -- yellowish
local SOUND_ID_NEEDED = 1277 -- fx_chest_openwooden


local printUpdate = function(className, instanceName, isNeeded)
    local classColor = COLOR_CLASS_FULL
    local isNeededString = 'Full'

    if isNeeded then
        isNeededString = 'Needed'
        classColor = COLOR_CLASS_NEEDED
        PlaySoundKitID(SOUND_ID_NEEDED)
    end

    print(string.format('LookingForLoot:  |c%s%s|r  -  |c%s%s %s|r', COLOR_INSTANCE_NAME, instanceName, classColor, className, isNeededString))
end


-- Call every 10 seconds till the end of time
local lfgScannerTimer = C_Timer.NewTicker(10, function()
    RequestLFDPlayerLockInfo()
end, nil)


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
            printUpdate('Tank', randomDuneonDetails['name'], false)
        elseif randomDuneonDetails['forTank'] == false and forTank == true then
            printUpdate('Tank', randomDuneonDetails['name'], true)
        end

        if randomDuneonDetails['forHealer'] == true and forHealer == false then
            printUpdate('Healer', randomDuneonDetails['name'], false)
        elseif randomDuneonDetails['forHealer'] == false and forHealer == true then
            printUpdate('Healer', randomDuneonDetails['name'], true)
        end

        if randomDuneonDetails['forDamage'] == true and forDamage == false then
            printUpdate('Damage', randomDuneonDetails['name'], false)
        elseif randomDuneonDetails['forDamage'] == false and forDamage == true then
            printUpdate('Damage', randomDuneonDetails['name'], true)
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
                printUpdate('Tank', rf_name, true)
            elseif rfState[rf_id]['forTank'] == true and forTank == false then
                printUpdate('Tank', rf_name, false)
            end

            if rfState[rf_id]['forHealer'] == false and forHealer == true then
                printUpdate('Healer', rf_name, true)
            elseif rfState[rf_id]['forHealer'] == true and forHealer == false then
                printUpdate('Healer', rf_name, false)
            end
            
            if rfState[rf_id]['forDamage'] == false and forDamage == true then
                printUpdate('Damage', rf_name, true)
            elseif rfState[rf_id]['forDamage'] == true and forDamage == false then
                printUpdate('Damage', rf_name, false)
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
