do
    local TPodTowerUnitCreatePod = TPodTowerUnit.CreatePod
    TPodTowerUnit = Class(TPodTowerUnit) {
        CreatePod = function(self, podName)
            TPodTowerUnitCreatePod(self, podName)
            if self.LevelProgress and self.LevelProgress > 1.01 then
                self.PodData[podName].PodHandle:AddLevels(self.LevelProgress - 1)
            end
        end,
    }
end
