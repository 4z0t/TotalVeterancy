local controls = import('/lua/ui/game/orders.lua').controls
local jumpers = {}
local form, tp = false, nil
local heightx = 1
local range = 'default'
local function jump()
    ConExecute('IssueCommand Stop')
    local dot2 = import('/lua/ui/uimain.lua').RemoveOnMouseClickedFunc
    SimCallback({
        Func = 'jumpinjack',
        Args = {
            owner = GetFocusArmy(),
            units = jumpers,
            jumpto = GetMouseWorldPos(),
            height = heightx,
            formation = form,
            range = range
        }
    })
    ForkThread(function()
        dot2(jump)
    end)
end

local function JumpButtoncr()
    local UIUtil = import('/lua/ui/uiutil.lua')
    local Tooltip = import('/lua/ui/game/tooltip.lua')
    local Lh = import('/lua/maui/layouthelpers.lua')
    controls.bg.jb = UIUtil.CreateButtonStd(controls.bg, '/game/orders/stand-ground')
    controls.bg.jb.Left:Set(function()
        return controls.bg.Left() + 16
    end)
    controls.bg.jb.Bottom:Set(function()
        return controls.bg.Top() + 10
    end)
    controls.bg.jb.OnClick = function(self, modifiers)
        local dot = import('/lua/ui/uimain.lua').AddOnMouseClickedFunc
        local dot2 = import('/lua/ui/uimain.lua').RemoveOnMouseClickedFunc
        dot2()
        range = false
        local function cb()
            SimCallback({
                Func = 'jumpinjack',
                Args = {
                    owner = GetFocusArmy(),
                    units = jumpers,
                    jumpto = GetMouseWorldPos(),
                    height = heightx,
                    formation = form,
                    range = range
                }
            })
        end

        --TODO FIX STUPID SHIT!
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
            cb()
            return
        end
        if modifiers.Middle then
            range = 'longrange'
        end
        if modifiers.Alt then
            range = 'danceofdeath'
            cb()
            return
        end
        ConExecute('IssueCommand Stop')
        ConExecute('StartCommandMode order RULEUCC_Move')
        SimCallback({
            Func = 'rangerings',
            Args = {
                owner = GetFocusArmy(),
                units = jumpers,
                range = range
            }
        })
        dot(jump)
    end
    controls.bg.jb.Depth:Set(1000)
    controls.bg.jb:EnableHitTest(true)
    controls.bg.jb:Hide()
    Tooltip.AddButtonTooltip(controls.bg.jb, 'Jump', 0.9)
end

local function mew(availableOrders, availableToggles, newSelection, run)
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

local run = true
local oldSetAvailableOrders = SetAvailableOrders
function SetAvailableOrders(availableOrders, availableToggles, newSelection)
    oldSetAvailableOrders(availableOrders, availableToggles, newSelection)
    mew(availableOrders, availableToggles, newSelection, run)
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
defaultOrdersTable.JumpInJack = { helpText = "jump_in_jack", bitmapId = 'stand-ground', preferredSlot = 1,
    behavior = JumpButtonBehavior }

commonOrders.JumpInJack = true
do
    for k, data in defaultOrdersTable do
        if k == "JumpInJack" then
            continue
        end
        data.preferredSlot = data.preferredSlot + 1
    end
end
