local _OnCommandIssued = OnCommandIssued
function OnCommandIssued(command)
    if command.CommandType == 'Script' and command.LuaParams.TaskName == 'JumpInJack' then
        SimCallback({
            Func = 'jumpinjack',
            Args = {
                owner = GetFocusArmy(),
                Position = command.Target.Position,
                Clear = command.Clear,
                height = modeData.height,
                formation = modeData.formation,
                range = modeData.range
            }
        }, true)
        AddDefaultCommandFeedbackBlips(command.Target.Position)
    end
    return _OnCommandIssued(command)
end
