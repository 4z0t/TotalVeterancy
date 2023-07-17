Callbacks.ToggleMEStorage = function(data)
    if OkayToMessWithArmy(data.owner) and data.owner ~= -1 then
        local brain = ArmyBrains[data.owner]
        if brain.ME ~= "Energy" then
            brain.ME = "Energy"
            if brain.StorageEnergyTotal ~= nil then
                brain:GiveStorage("ENERGY", brain.StorageEnergyTotal)
            end
        else
            brain.ME = "Mass"
            if brain.StorageMassTotal ~= nil then
                brain:GiveStorage("MASS", brain.StorageMassTotal)
            end
        end
        PrintText(brain.ME .. ' Storage Buff set!', 18, 'ffbfbfbf', 4, 'center', data.owner)
    end
end

local buffed = 0
Callbacks.BuffAIs = function(data)
    if data.owner ~= -1 then
        local hum = 0
        for k, v in ArmyBrains do
            if v.BrainType == 'Human' then
                hum = hum + 1
            end
        end
        if hum == 1 then
            for k, v in ArmyBrains do
                if v.BrainType == 'AI' then
                    local units = v:GetListOfUnits(categories.MOBILE - categories.AIR - categories.UNSELECTABLE -
                        categories.UNTARGETABLE - categories.INSIGNIFICANTUNIT, false)
                    if table.getn(units) > 0 then
                        for i, unit in units do
                            unit:AddLevels(1)
                        end
                    end
                end
            end
            buffed = buffed + 1
            PrintText('Increased Land AI Levels by ' .. buffed .. '!', 18, 'ffbfbfbf', 4, 'center')
        end
    end
end

local buffedDef = 0
Callbacks.BuffButtonDef = function(data)
    if data.owner ~= -1 then
        local hum = 0
        for k, v in ArmyBrains do
            if v.BrainType == 'Human' then
                hum = hum + 1
            end
        end
        if hum == 1 then
            for k, v in ArmyBrains do
                if v.BrainType == 'AI' then
                    local units = v:GetListOfUnits(categories.STRUCTURE * categories.DEFENSE + categories.FACTORY -
                        categories.UNSELECTABLE - categories.UNTARGETABLE - categories.INSIGNIFICANTUNIT, false)
                    if table.getn(units) > 0 then
                        for i, unit in units do
                            unit:AddLevels(1)
                        end
                    end
                end
            end
            buffedDef = buffedDef + 1
            PrintText('Increased AI defense Levels by ' .. buffedDef .. '!', 18, 'ffbfbfbf', 4, 'center')
        end
    end
end

local bBBase = 0
Callbacks.bBBase = function(data)
    if data.owner ~= -1 then
        local hum = 0
        for k, v in ArmyBrains do
            if v.BrainType == 'Human' then
                hum = hum + 1
            end
        end
        if hum == 1 then
            for k, v in ArmyBrains do
                if v.BrainType == 'AI' then
                    local units = v:GetListOfUnits(categories.STRUCTURE - categories.UNSELECTABLE -
                        categories.UNTARGETABLE - categories.INSIGNIFICANTUNIT, false)
                    if table.getn(units) > 0 then
                        for i, unit in units do
                            unit:AddLevels(1)
                        end
                    end
                end
            end
            bBBase = bBBase + 1
            PrintText('Increased AI Base Levels by ' .. bBBase .. '!', 18, 'ffbfbfbf', 4, 'center')
        end
    end
end

Callbacks.ToggleVeteranBuilding2 = function(data)
    if OkayToMessWithArmy(data.owner) and data.owner ~= -1 then
        local selectedBuilders = {}
        local i = 1
        for k, v in data.units do
            selectedBuilders[i] = GetUnitById(v)
            i = i + 1
        end
        if table.getsize(selectedBuilders) > 0 then
            if selectedBuilders[1].vetToggle ~= 4 then
                for k, v in selectedBuilders do
                    v.vetToggle = 4
                    v.Sync.vetToggle = 4
                end
            else
                for k, v in selectedBuilders do
                    v.vetToggle = 0
                    v.Sync.vetToggle = 0
                end
            end
        end
    end
end

local buffedSea = 0
Callbacks.BuffAIsSea = function(data)
    if data.owner ~= -1 then
        local hum = 0
        for k, v in ArmyBrains do
            if v.BrainType == 'Human' then
                hum = hum + 1
            end
        end
        if hum == 1 then
            for k, v in ArmyBrains do
                if v.BrainType == 'AI' then
                    local units = v:GetListOfUnits(categories.NAVAL - categories.AIR - categories.UNSELECTABLE -
                        categories.UNTARGETABLE - categories.INSIGNIFICANTUNIT, false)
                    if table.getn(units) > 0 then
                        for i, unit in units do
                            unit:AddLevels(1)
                        end
                    end
                end
            end
            buffedSea = buffedSea + 1
            PrintText('Increased Naval AI Levels by ' .. buffedSea .. '!', 18, 'ffbfbfbf', 4, 'center')
        end
    end
end

local buffedAir = 0
Callbacks.BuffAIsAir = function(data)
    if data.owner ~= -1 then
        local hum = 0
        for k, v in ArmyBrains do
            if v.BrainType == 'Human' then
                hum = hum + 1
            end
        end
        if hum == 1 then
            for k, v in ArmyBrains do
                if v.BrainType == 'AI' then
                    local units = v:GetListOfUnits(categories.AIR - categories.UNSELECTABLE - categories.UNTARGETABLE -
                        categories.INSIGNIFICANTUNIT, false)
                    if table.getn(units) > 0 then
                        for i, unit in units do
                            unit:AddLevels(1)
                        end
                    end
                end
            end
            buffedAir = buffedAir + 1
            PrintText('Increased Air AI Levels by ' .. buffedAir .. '!', 18, 'ffbfbfbf', 4, 'center')
        end
    end
end

Callbacks.BuildXPEnabled = function(data)
    if data.owner ~= -1 then
        local hum = 0
        for k, v in ArmyBrains do
            if v.BrainType == 'Human' then
                hum = hum + 1
            end
        end
        if hum == 1 then
            for k, v in ArmyBrains do
                local units = v:GetListOfUnits(categories.CONSTRUCTION + categories.ENGINEER + categories.ENGINEER +
                    categories.FACTORY + categories.SILO - categories.UNSELECTABLE - categories.UNTARGETABLE -
                    categories.INSIGNIFICANTUNIT, false)
                if table.getn(units) > 0 then
                    for i, unit in units do
                        unit:GetBlueprint().Economy.BuildXPLevelpSecond = data.enabled
                    end
                end
            end
            if data.enabled ~= 0 then
                PrintText('BuildXP Enabled!', 18, 'ffbfbfbf', 4, 'center')
            else
                PrintText('BuildXP Disabled!', 18, 'ffbfbfbf', 4, 'center')
            end
        end
    end
end

Callbacks.ShareXPEnabled = function(data)
    if data.owner ~= -1 then
        local hum = 0
        for k, v in ArmyBrains do
            if v.BrainType == 'Human' then
                hum = hum + 1
            end
        end
        if hum == 1 then
            ScenarioInfo.ShareEXP = data.enabled
            if ScenarioInfo.ShareEXP ~= false then
                PrintText('ShareXP Set!', 18, 'ffbfbfbf', 4, 'center')
            else
                PrintText('ShareXP disabled!', 18, 'ffbfbfbf', 4, 'center')
            end
            LOG('***ShareXP state ' .. tostring(ScenarioInfo.ShareEXP))
        end
    end
end
Callbacks.AIVetBuildEnabled = function(data)
    if data.owner ~= -1 then
        local hum = 0
        for k, v in ArmyBrains do
            if v.BrainType == 'Human' then
                hum = hum + 1
            end
        end
        if hum == 1 then
            for k, v in ArmyBrains do
                if v.BrainType ~= 'Human' then
                    local units = v:GetListOfUnits(categories.CONSTRUCTION + categories.ENGINEER + categories.ENGINEER +
                        categories.FACTORY + categories.SILO - categories.UNSELECTABLE - categories.UNTARGETABLE -
                        categories.INSIGNIFICANTUNIT, false)
                    if table.getn(units) > 0 then
                        for i, unit in units do
                            unit.vetToggle = data.enabled
                        end
                    end
                end
            end
            if data.enabled ~= 0 then
                ScenarioInfo.AItoggle = true
                PrintText('AI Veteranbuilding Enabled!', 18, 'ffbfbfbf', 4, 'center')
            else
                ScenarioInfo.AItoggle = false
                PrintText('AI Veteranbuilding Disabled!', 18, 'ffbfbfbf', 4, 'center')
            end
        end
    end
end
Callbacks.ToggleBalance = function(data)
    if data.owner ~= -1 then
        local hum = 0
        for k, v in ArmyBrains do
            if v.BrainType == 'Human' then
                hum = hum + 1
            end
        end
        if hum == 1 then
            ScenarioInfo.ALLies = data.ToggleBalance
            if ScenarioInfo.ALLies ~= false then
                PrintText('Singleplayer Balance Set!', 18, 'ffbfbfbf', 4, 'center')
                Sync.UnitData.ALLies = true
            else
                PrintText('Multiplayer Balance Set!', 18, 'ffbfbfbf', 4, 'center')
                Sync.UnitData.ALLies = false
            end
            LOG('*** SP Balance set ' .. tostring(ScenarioInfo.ALLies))
        end
    end
end
