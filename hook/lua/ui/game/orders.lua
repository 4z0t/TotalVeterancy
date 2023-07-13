local function mew(availableOrders, availableToggles, newSelection)
    if table.empty(newSelection) then
        return
    end

    local found = false
    local list = ValidateUnitsList(EntityCategoryFilterDown(categories.COMMAND + categories.SUBCOMMANDER +
        categories.uel0106, newSelection))
    if list then
        for k, v in list do
            local id = v:GetEntityId()
            local bp = v:GetBlueprint().Categories
            if UnitData.ALLies or
                (UnitData[id].LevelProgress > 5 and EntityCategoryContains(categories.SUBCOMMANDER, v)) or
                (UnitData[id].LevelProgress > 31 and EntityCategoryContains(categories.COMMAND, v)) or
                EntityCategoryContains(categories.uel0106, v) then
                found = true
                break
            end
        end
    end
    if found then
        orderCheckboxMap["JumpInJack"]:Enable()
    else
        orderCheckboxMap["JumpInJack"]:Disable()
    end
end


local oldSetAvailableOrders = SetAvailableOrders
function SetAvailableOrders(availableOrders, availableToggles, newSelection)
    oldSetAvailableOrders(availableOrders, availableToggles, newSelection)
    mew(availableOrders, availableToggles, newSelection)
end

local function JumpButtonBehavior(self, modifiers)
    if self:IsChecked() then
        CommandMode.EndCommandMode(true)
    else
        local form = false
        local heightx = 1
        local range = 'default'
        if modifiers.Right then
            form = true
        else
            form = false
        end
        if modifiers.Shift then
            heightx = 0.5
        else
            heightx = 1
        end
        if modifiers.Ctrl then
            range = 'howlingfury'
        end
        if modifiers.Middle then
            range = 'longrange'
        end
        if modifiers.Alt then
            range = 'danceofdeath'
        end
        local modeData = {
            name = "RULEUCC_Script",
            AbilityName = "JumpInJack",
            TaskName = "JumpInJack",
            Cursor = "RULEUCC_Move",
            height = heightx,
            formation = form,
            range = range
        }
        CommandMode.StartCommandMode("order", modeData)
    end
end

numSlots = 16
firstAltSlot = 9
defaultOrdersTable.JumpInJack = {
    helpText = "jump_in_jack",
    bitmapId = 'stand-ground',
    preferredSlot = 1,
    behavior = JumpButtonBehavior
}

commonOrders.JumpInJack = true
do
    for k, data in defaultOrdersTable do
        if k == "JumpInJack" then
            continue
        end
        if commonOrders[k] then
            data.preferredSlot = data.preferredSlot + 1
        else
            data.preferredSlot = data.preferredSlot + 2
        end
    end
end
