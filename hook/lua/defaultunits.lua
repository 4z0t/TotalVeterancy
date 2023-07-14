local oldStructureUnit = StructureUnit
StructureUnit = Class(oldStructureUnit) {
    OnStartBuild = function(self, unitBeingBuilt, order)
        oldStructureUnit.OnStartBuild(self, unitBeingBuilt, order)
        if unitBeingBuilt:GetUnitId() == self:GetBlueprint().General.UpgradesTo and order == 'Upgrade' then
            self.upgrading = true
        else
            self.upgrading = nil
        end
    end,
    OnStopBeingBuilt = function(self, builder, layer)
        if builder.upgrading then
            self:AddLevels(builder.LevelProgress)
        end
        oldStructureUnit.OnStopBeingBuilt(self, builder, layer)
    end,
    OnFailedToBeBuilt = function(self)
        self.upgrading = nil
        oldStructureUnit.OnFailedToBeBuilt(self)
    end,
    OnStopBuild = function(self, unitBuilding)
        self.upgrading = nil
        oldStructureUnit.OnStopBuild(self, unitBuilding)
    end,
}
local oldShieldStructureUnit = ShieldStructureUnit
ShieldStructureUnit = Class(oldShieldStructureUnit) {
    UpgradingState = State(oldShieldStructureUnit.UpgradingState) {
        Main = function(self)
            oldShieldStructureUnit.UpgradingState.Main(self)
        end,
        OnStopBuild = function(self, unitBuilding)
            if unitBuilding:GetFractionComplete() == 1 then
                unitBuilding:AddLevels(self.LevelProgress)
            end
            oldShieldStructureUnit.UpgradingState.OnStopBuild(self, unitBuilding)
        end,
        OnFailedToBuild = function(self)
            oldShieldStructureUnit.UpgradingState.OnFailedToBuild(self)
        end,
    }
}
local oldMassCollectionUnit = MassCollectionUnit
MassCollectionUnit = Class(oldMassCollectionUnit) {
    WatchUpgradeConsumption = function(self)

        local bp = self.Blueprint
        local massConsumption = self:GetConsumptionPerSecondMass()

        local aiBrain = self:GetAIBrain()

        local CalcEnergyFraction = function()
            local fraction = 1
            if aiBrain:GetEconomyStored('ENERGY') < self:GetConsumptionPerSecondEnergy() then
                fraction = math.min(1, aiBrain:GetEconomyIncome('ENERGY') / aiBrain:GetEconomyRequested('ENERGY'))
            end
            return fraction
        end

        local CalcMassFraction = function()
            local fraction = 1
            if aiBrain:GetEconomyStored('MASS') < self:GetConsumptionPerSecondMass() then
                fraction = math.min(1, aiBrain:GetEconomyIncome('MASS') / aiBrain:GetEconomyRequested('MASS'))
            end
            return fraction
        end

        while not self.Dead do
            local massProduction = bp.Economy.ProductionPerSecondMass * (self.MassProdAdjMod or 1)
            if self:IsPaused() then
                self:SetConsumptionPerSecondMass(0)
                self:SetProductionPerSecondMass(massProduction * CalcEnergyFraction())
            elseif aiBrain and aiBrain:GetEconomyStored('ENERGY') <= 1 then
                self:SetConsumptionPerSecondMass(massConsumption)
                self:SetProductionPerSecondMass(massProduction / CalcMassFraction())
            else
                self:SetConsumptionPerSecondMass(massConsumption)
                self:SetProductionPerSecondMass(massProduction * CalcEnergyFraction())
            end

            WaitTicks(1)
        end
    end,
}
local oldRadarUnit = RadarUnit
RadarUnit = Class(oldRadarUnit) {
    UpgradingState = State(oldRadarUnit.UpgradingState) {
        Main = function(self) oldRadarUnit.UpgradingState.Main(self)
        end,
        OnStopBuild = function(self, unitBuilding)
            if unitBuilding:GetFractionComplete() == 1 then
                unitBuilding:AddLevels(self.LevelProgress)
            end
            oldRadarUnit.UpgradingState.OnStopBuild(self, unitBuilding)
        end,
        OnFailedToBuild = function(self)
            oldRadarUnit.UpgradingState.OnFailedToBuild(self)
        end,
    }
}
local oldSonarUnit = SonarUnit
SonarUnit = Class(oldSonarUnit) {
    UpgradingState = State(oldSonarUnit.UpgradingState) {
        Main = function(self) oldSonarUnit.UpgradingState.Main(self)
        end,
        OnStopBuild = function(self, unitBuilding)
            if unitBuilding:GetFractionComplete() == 1 then
                unitBuilding:AddLevels(self.LevelProgress)
            end
            oldSonarUnit.UpgradingState.OnStopBuild(self, unitBuilding)
        end,
        OnFailedToBuild = function(self) oldSonarUnit.UpgradingState.OnFailedToBuild(self)
        end,
    }
}
