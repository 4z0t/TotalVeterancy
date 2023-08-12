---@param unit UserUnit
---@return number
---@return number
---@return number
---@return number
---@return number
local function CalcVetStats(unit)
    local bp = unit:GetBlueprint()
    local vetLevel = unit:GetStat('VetLevel', 0).Value
    local vetExperience = unit:GetStat('VetExperience', 0).Value
    local XPnextLevel = unit:GetStat('XPnextLevel', 0).Value
    local levelProgress = unit:GetStat('LevelProgress', 0).Value
    local percent = vetExperience / XPnextLevel
    local worth = bp.Economy.xpValue * (math.log10(vetLevel) + 1)
    if worth > 1000000 then
        worth = 0
    end
    return vetLevel, vetExperience, XPnextLevel - vetExperience, percent, worth
end

local OldUpdateWindow = UpdateWindow
function UpdateWindow(info)
    OldUpdateWindow(info)
    if info.blueprintId == 'unknown' then
        controls.XPText:Hide()
        controls.vetXPBar:Hide()
        controls.vetXPText:Hide()
        controls.vetRevive:Hide()
        controls.vetToggleDisplay:Hide()
        return
    end

    for i = 1, 5 do
        controls.vetIcons[i]:Hide()
    end
    controls.XPText:Hide()
    controls.vetXPBar:Hide()
    controls.vetXPText:Hide()
    controls.shieldText:Hide()
    controls.vetRevive:Hide()
    controls.vetToggleDisplay:Hide()
    local bp = __blueprints[info.blueprintId]
    if info.entityId == nil and info.maxHealth and bp.Defense.MaxHealth and bp.Economy.xpValue then
        if table.find(bp.Categories, 'COMMAND') or table.find(bp.Categories, 'SUBCOMMANDER') then
            controls.vetXPText:SetText('Level ???')
            controls.vetXPText:Show()
        else
            local level = info.maxHealth / bp.Defense.MaxHealth
            local killxp = bp.Economy.xpValue
            if level > 1 then
                level = 10 * (level - 0.9)
                killxp = killxp * level * 0.25
                if killxp > 1000000000 then
                    killxp = 0
                end
                controls.vetXPText:SetText(string.format('Level~%d worth ~%d XP', level, killxp))
                controls.vetXPText:Show()
            else
                killxp = killxp * level * 0.25
                controls.vetXPText:SetText(string.format('Level~%d worth ~%d XP', level, killxp))
                controls.vetXPText:Show()
            end
        end
    end
    if info.entityId == nil and bp.Economy.xpValue and info.maxHealth then
        local basexp = bp.Economy.xpValue * 0.25
        controls.shieldText:SetText(string.format('BaseXP %d', basexp))
        controls.shieldText:Show()
    end
    if UnitData[info.entityId].vetBuild and UnitData[info.entityId].vetBuild > 0 then
        levelProgress = UnitData[info.entityId].vetBuild * .05
    end

    if not info.entityId then
        return
    end

    local unit = GetUnitById(info.entityId)

    if not unit then
        return
    end

    local bp = unit:GetBlueprint()

    local vetLevel, curProgress, nextProgress, percent, worth = CalcVetStats(unit)

    controls.XPText:SetText(string.format('current XP %d / next Level %d / worth %d', curProgress, nextProgress,
        worth))
    controls.XPText:Show()
    controls.vetXPBar:SetValue(percent)
    controls.vetXPText:SetText(string.format('Level %d', vetLevel))
    if UnitData[info.entityId].Revive then
        controls.vetRevive:SetText(string.format('%d', UnitData[info.entityId].Revive))
        controls.vetRevive:SetColor('FF009900')
        if UnitData[info.entityId].Revive < math.floor((vetLevel + 10) * 0.04) then
            controls.vetRevive:SetColor('FFFF9900')
        end
        if UnitData[info.entityId].Revive == 0 then
            controls.vetRevive:SetColor('FFFF0000')
        end
        controls.vetRevive:Show()
    end
    if UnitData[info.entityId].vetToggle == 4 then
        controls.vetToggleDisplay:SetText('On')
        controls.vetToggleDisplay:SetColor('FFFF0000')
        controls.vetToggleDisplay:Show()
    else
        controls.vetToggleDisplay:Hide()
    end
    controls.vetXPText:Show()
    controls.vetXPBar:Show()

    if info.health and UnitData[info.entityId].RegenRate then
        controls.health:SetText(string.format("%d / %d +%d/s", info.health, info.maxHealth,
            math.floor(UnitData[info.entityId].RegenRate)))
    end
    if info.shieldRatio > 0 and UnitData[info.entityId].ShieldMaxHp then
        controls.shieldText:Show()
        if UnitData[info.entityId].ShieldRegen then
            controls.shieldText:SetText(string.format("%d / %d +%d/s",
                math.floor(UnitData[info.entityId].ShieldMaxHp * info.shieldRatio),
                UnitData[info.entityId].ShieldMaxHp, UnitData[info.entityId].ShieldRegen))
        else
            controls.shieldText:SetText(string.format("%d / %d",
                math.floor(UnitData[info.entityId].ShieldMaxHp * info.shieldRatio),
                UnitData[info.entityId].ShieldMaxHp))
        end
    end

end

local OldCreateUI = CreateUI
function CreateUI()
    OldCreateUI()
    controls.vetXPBar = StatusBar(controls.bg, 0, 1, false, false, nil, nil, true)
    controls.vetXPText = UIUtil.CreateText(controls.bg, '', 12, UIUtil.bodyFont)
    controls.vetRevive = UIUtil.CreateText(controls.bg, '', 20, UIUtil.bodyFont)
    controls.vetToggleDisplay = UIUtil.CreateText(controls.bg, '', 18, UIUtil.bodyFont)
    controls.shieldText = UIUtil.CreateText(controls.bg, '', 13, UIUtil.bodyFont)
    controls.XPText = UIUtil.CreateText(controls.bg, '', 12, UIUtil.bodyFont)
    local Tooltip = import('/lua/ui/game/tooltip.lua')
    Tooltip.AddControlTooltip(controls.vetRevive, 'AutoRevive', 0)
    Tooltip.AddControlTooltip(controls.vetToggleDisplay, 'ToggleVetIsOn', 0)
    Tooltip.AddControlTooltip(controls.XPText, 'XpNumericals', 0)
    Tooltip.AddControlTooltip(controls.vetXPText, 'Level', 0)
end
