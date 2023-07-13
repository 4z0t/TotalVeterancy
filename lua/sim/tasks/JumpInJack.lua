--*****************************************************************************
--* File: lua/sim/tasks/JumpInJack.lua
--*
--* Dummy task for the JumpInJack Move button
--*****************************************************************************
local ScriptTask = import("/lua/sim/scripttask.lua").ScriptTask
local TASKSTATUS = import("/lua/sim/scripttask.lua").TASKSTATUS
local AIRESULT = import("/lua/sim/scripttask.lua").AIRESULT

---@class JumpInJack : ScriptTask
JumpInJack = Class(ScriptTask) {

    ---@param self AttackMove
    ---@return integer
    TaskTick = function(self)
        self:SetAIResult(AIRESULT.Success)
        return TASKSTATUS.Done
    end,
}