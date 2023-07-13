oldUAL0301 = UAL0301
UAL0301 = Class(oldUAL0301) {
    CreateEnhancement = function(self, enh)
        CommandUnit.CreateEnhancement(self, enh)
        local bp = self.Blueprint.Enhancements[enh]
        if not bp then
            return
        end
        if enh == 'ResourceAllocation' then
            if not Buffs['AeonSCUResourceAllocation'] then
                BuffBlueprint {
                    Name = 'AeonSCUResourceAllocation',
                    DisplayName = 'AeonSCUResourceAllocation',
                    BuffType = 'AeonSCUResourceAllocation',
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
            Buff.ApplyBuff(self, 'AeonSCUResourceAllocation')
        elseif enh == 'ResourceAllocationRemove' then
            Buff.RemoveBuff(self, 'AeonSCUResourceAllocation', false)
        elseif enh == 'EngineeringFocusingModule' then
            if not Buffs['AeonSCUBuildRate'] then
                BuffBlueprint {
                    Name = 'AeonSCUBuildRate',
                    DisplayName = 'AeonSCUBuildRate',
                    BuffType = 'SCUBUILDRATE',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add = bp.NewBuildRate,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'AeonSCUBuildRate')
        elseif enh == 'EngineeringFocusingModuleRemove' then
            if Buff.HasBuff(self, 'AeonSCUBuildRate') then
                Buff.RemoveBuff(self, 'AeonSCUBuildRate')
            end
        elseif enh == 'SystemIntegrityCompensator' then
            if not Buffs['AeonSCURegen'] then
                BuffBlueprint {
                    Name = 'AeonSCURegen',
                    DisplayName = 'AeonSCURegen',
                    BuffType = 'ACUBUILDRATE',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        Regen = {
                            Add = bp.NewRegenRate,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'AeonSCURegen')
        elseif enh == 'SystemIntegrityCompensatorRemove' then
            if Buff.HasBuff(self, 'AeonSCURegen') then
                Buff.RemoveBuff(self, 'AeonSCURegen')
            end
        elseif enh == 'StabilitySuppressant' then
            if not Buffs['AeonSCUStabilitySuppressant'] then
                BuffBlueprint {
                    Name = 'AeonSCUStabilitySuppressant',
                    DisplayName = 'AeonSCUStabilitySuppressant',
                    BuffType = 'AeonSCUStabilitySuppressant',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        DamageRadius = {
                            Add = bp.NewDamageRadiusMod,
                            ByName = {
                                RightReactonCannon = true,
                            },
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'AeonSCUStabilitySuppressant')
        elseif enh == 'StabilitySuppressantRemove' then
            if Buff.HasBuff(self, 'AeonSCUStabilitySuppressant') then
                Buff.RemoveBuff(self, 'AeonSCUStabilitySuppressant')
            end
        else
            oldUAL0301.CreateEnhancement(self, enh)
        end
    end,
}
TypeClass = UAL0301
