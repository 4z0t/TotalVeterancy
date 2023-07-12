local oldXRB3301 = XRB3301
XRB3301 = Class(oldXRB3301) {
    OnCreate = function(self) oldXRB3301.OnCreate(self)
        self.MaxVisionRadius = self.Blueprint.Intel.MaxVisionRadius
        self.MinVisionRadius = self.Blueprint.Intel.MinVisionRadius
    end,

    ExpandingVision = State {
        Main = function(self)
            WaitTicks(1)
            while true do
                if self:GetResourceConsumed() ~= 1 then
                    self.ExpandingVisionEnergyCheck = true
                    self:OnIntelDisabled()
                end
                local curRadius = self:GetIntelRadius('vision')
                local targetRadius = self.MaxVisionRadius
                if curRadius < targetRadius then
                    curRadius = curRadius + 1
                    if curRadius >= targetRadius then
                        self:SetIntelRadius('vision', targetRadius)
                    else
                        self:SetIntelRadius('vision', curRadius)
                    end
                end
                WaitTicks(1)
            end
        end,
    },
    ContractingVision = State {
        Main = function(self)
            while true do
                if self:GetResourceConsumed() == 1 then
                    if self.ExpandingVisionEnergyCheck then
                        self:OnIntelEnabled()
                    else
                        self:OnIntelDisabled()
                        self.ExpandingVisionEnergyCheck = true
                    end
                end
                local curRadius = self:GetIntelRadius('vision')
                local targetRadius = self.MinVisionRadius
                if curRadius > targetRadius then
                    curRadius = curRadius - 1
                    if curRadius <= targetRadius then
                        self:SetIntelRadius('vision', targetRadius)
                    else
                        self:SetIntelRadius('vision', curRadius)
                    end
                end
                WaitTicks(1)
            end
        end,
    },
}
TypeClass = XRB3301
