local oldUAL0001 = UAL0001
UAL0001 = Class(oldUAL0001) {
    CreateEnhancement = function(self, enh)
        ACUUnit.CreateEnhancement(self, enh)
        local bp = self.Blueprint.Enhancements[enh]
        if not bp then
            return
        end
        if enh == 'ResourceAllocation' then
            if not Buffs['AeonACUTResourceAllocation'] then
                BuffBlueprint {
                    Name = 'AeonACUTResourceAllocation',
                    DisplayName = 'AeonACUTResourceAllocation',
                    BuffType = 'AeonACUTResourceAllocation',
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
            Buff.ApplyBuff(self, 'AeonACUTResourceAllocation')
        elseif enh == 'ResourceAllocationRemove' then
            Buff.RemoveBuff(self, 'AeonACUTResourceAllocation', false)
        elseif enh == 'ResourceAllocationAdvanced' then
            if Buffs['AeonACUTResourceAllocation'] then
                Buff.RemoveBuff(self, 'AeonACUTResourceAllocation', false)
            end
            if not Buffs['AeonACUTResourceAllocationAdvanced'] then
                BuffBlueprint {
                    Name = 'AeonACUTResourceAllocationAdvanced',
                    DisplayName = 'AeonACUTResourceAllocationAdvanced',
                    BuffType = 'AeonACUTResourceAllocationAdvanced',
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
            Buff.ApplyBuff(self, 'AeonACUTResourceAllocationAdvanced')
        elseif enh == 'ResourceAllocationAdvancedRemove' then
            Buff.RemoveBuff(self, 'AeonACUTResourceAllocationAdvanced', false)
        elseif enh == 'AdvancedEngineering' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['AeonACUT2BuildRate'] then
                BuffBlueprint {
                    Name = 'AeonACUT2BuildRate',
                    DisplayName = 'AeonACUT2BuildRate',
                    BuffType = 'ACUBUILDRATE',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add = bp.NewBuildRate,
                        },
                        MaxHealth = {
                            Add = bp.NewHealth,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'AeonACUT2BuildRate')
        elseif enh == 'AdvancedEngineeringRemove' then
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction(categories.AEON *
                (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER))
            if Buff.HasBuff(self, 'AeonACUT2BuildRate') then
                Buff.RemoveBuff(self, 'AeonACUT2BuildRate')
            end
        elseif enh == 'T3Engineering' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['AeonACUT3BuildRate'] then
                BuffBlueprint {
                    Name = 'AeonACUT3BuildRate',
                    DisplayName = 'AeonCUT3BuildRate',
                    BuffType = 'ACUBUILDRATE',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add = bp.NewBuildRate,
                        },
                        MaxHealth = {
                            Add = bp.NewHealth,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                        },
                    },
                }
            end
            if Buff.HasBuff(self, 'AeonACUT2BuildRate') then
                Buff.RemoveBuff(self, 'AeonACUT2BuildRate')
            end
            Buff.ApplyBuff(self, 'AeonACUT3BuildRate')
        elseif enh == 'T3EngineeringRemove' then
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction(categories.AEON *
                (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER))
            if Buff.HasBuff(self, 'AeonACUT3BuildRate') then
                Buff.RemoveBuff(self, 'AeonACUT3BuildRate')
            end
        elseif enh == 'CrysalisBeam' then
            if not Buffs['AeonACURangeEnhance'] then
                BuffBlueprint {
                    Name = 'AeonACURangeEnhance',
                    DisplayName = 'AeonACURangeEnhance',
                    BuffType = 'AeonACURangeEnhance',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxRadius = {
                            Add =
                            bp.NewMaxRadius,
                            ByName = {
                                RightDisruptor =
                                true,
                                OverCharge = true,
                            },
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'AeonACURangeEnhance')
        elseif enh == 'CrysalisBeamRemove' then
            if Buff.HasBuff(self, 'AeonACURangeEnhance') then
                Buff.RemoveBuff(self, 'AeonACURangeEnhance')
            end
        elseif enh == 'HeatSink' then
            if not Buffs['AeonACUHeatSink'] then
                BuffBlueprint {
                    Name = 'AeonACUHeatSink',
                    DisplayName = 'AeonACUHeatSink',
                    BuffType = 'AeonACUHeatSink',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        RateOfFireBuf = {
                            Add =
                            bp.NewRateOfFire,
                            ByName = {
                                RightDisruptor = true,
                            },
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'AeonACUHeatSink')
        elseif enh == 'HeatSinkRemove' then
            if Buff.HasBuff(self, 'AeonACUHeatSink') then
                Buff.RemoveBuff(self, 'AeonACUHeatSink')
            end
        elseif enh == 'EnhancedSensors' then
            if not Buffs['AeonACUSendorEnhance'] then
                BuffBlueprint {
                    Name = 'AeonACUSendorEnhance',
                    DisplayName = 'AeonACUSendorEnhance',
                    BuffType = 'AeonACUSendorEnhance',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        OmniRadius = {
                            Add = bp.NewOmniRadius,
                        },
                        VisionRadius = {
                            Add = bp.NewVisionRadius,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'AeonACUSendorEnhance')
        elseif enh == 'EnhancedSensorsRemove' then
            if Buff.HasBuff(self, 'AeonACUSendorEnhance') then
                Buff.RemoveBuff(self, 'AeonACUSendorEnhance')
            end
        else
            oldUAL0001.CreateEnhancement(self, enh)
        end
    end,
}
TypeClass = UAL0001
