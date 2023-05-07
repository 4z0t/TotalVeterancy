function FocusArmyChanged()
    for i, control in controls.avatars do
        local index = i
        if controls.avatars[index] then
            controls.avatars[index]:Destroy()
            controls.avatars[index] = nil
        end
    end
    local g = GetFocusArmy()
    if g == -1 or not GetArmiesTable()[g].human then
        GameMain.RemoveBeatFunction(AvatarUpdate)
        recievingBeatUpdate = false
    elseif not recievingBeatUpdate then
        recievingBeatUpdate = true
        GameMain.AddBeatFunction(AvatarUpdate)
    end
end
