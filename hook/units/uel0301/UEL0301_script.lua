local Buff = import('/lua/sim/Buff.lua')
local oldUEL0301 = UEL0301
UEL0301 = Class(oldUEL0301) {
    CreateEnhancement = function(self, enh)
        CommandUnit.CreateEnhancement(self, enh)
        local bp = self.Blueprint.Enhancements[enh]
        if not bp then
            return
        end
        if enh == 'ResourceAllocation' then
            if not Buffs['UefSCUResourceAllocation'] then
                BuffBlueprint {
                    Name = 'UefSCUResourceAllocation',
                    DisplayName = 'UefSCUResourceAllocation',
                    BuffType = 'UefSCUResourceAllocation',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MassProductionBuf = {
                            Add = bp.ProductionPerSecondMass,
                        },
                        EnergyProductionBuf = {
                            Add = bp.ProductionPerSecondEnergy,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'UefSCUResourceAllocation')
        elseif enh == 'ResourceAllocationRemove' then
            Buff.RemoveBuff(self, 'UefSCUResourceAllocation', false)
        elseif enh == 'SensorRangeEnhancer' then
            if not Buffs['UefSCUSensorRangeEnhancer'] then
                BuffBlueprint {
                    Name = 'UefSCUSensorRangeEnhancer',
                    DisplayName = 'UefSCUSensorRangeEnhancer',
                    BuffType = 'UefSCUSensorRangeEnhancer',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        VisionRadius = {
                            Add = bp.NewVisionRadius, },
                        OmniRadius = {
                            Add = bp.NewOmniRadius, }, }, }
            end
            Buff.ApplyBuff(self, 'UefSCUSensorRangeEnhancer')
        elseif enh == 'SensorRangeEnhancerRemove' then
            Buff.RemoveBuff(self, 'UefSCUSensorRangeEnhancer', false)
        elseif enh == 'AdvancedCoolingUpgrade' then
            if not Buffs['UefSCUAdvancedCoolingUpgrade'] then
                BuffBlueprint {
                    Name = 'UefSCUAdvancedCoolingUpgrade',
                    DisplayName = 'UefSCUAdvancedCoolingUpgrade',
                    BuffType = 'UefSCUAdvancedCoolingUpgrade',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        RateOfFireBuf = {
                            Add = bp.NewRateOfFire, ByName = {
                                RightHeavyPlasmaCannon = true, }, }, }, }
            end
            Buff.ApplyBuff(self, 'UefSCUAdvancedCoolingUpgrade')
        elseif enh == 'AdvancedCoolingUpgradeRemove' then
            Buff.RemoveBuff(self, 'UefSCUAdvancedCoolingUpgrade', false)
        elseif enh == 'HighExplosiveOrdnance' then
            if not Buffs['UefSCUHighExplosiveOrdnance'] then
                BuffBlueprint {
                    Name = 'HighExplosiveOrdnance',
                    DisplayName = 'HighExplosiveOrdnance',
                    BuffType = 'HighExplosiveOrdnance',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        Damage = {
                            Add = bp.NewDamageRadius,
                            ByName = {
                                RightHeavyPlasmaCannon = true,
                            },
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'HighExplosiveOrdnance')
        elseif enh == 'HighExplosiveOrdnanceRemove' then
            Buff.RemoveBuff(self, 'UefSCUHighExplosiveOrdnance', false)
        elseif enh == 'Pod' then
            local location = self:GetPosition('AttachSpecial01')
            local pod = CreateUnitHPR('UEA0003', self:GetArmy(), location[1], location[2
                ], location[3], 0, 0, 0)
            pod:SetParent(self, 'Pod')
            pod:SetCreator(self)
            pod:AddBuildRestriction(categories.UEF *
                (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER))
            if self.LevelProgress and self.LevelProgress > 1 then
                pod:AddLevels(self.LevelProgress - 1)
            end
            self.Trash:Add(pod)
            self.Pod = pod
        else
            oldUEL0301.CreateEnhancement(self, enh)
        end
    end,
}
TypeClass = UEL0301
