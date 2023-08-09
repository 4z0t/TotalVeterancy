local oldXSL0001 = XSL0001
XSL0001 = Class(oldXSL0001) {

    CreateEnhancement = function(self, enh)
        ACUUnit.CreateEnhancement(self, enh)
        local bp = self.Blueprint.Enhancements[enh]
        if not bp then return end
        if enh == 'ResourceAllocation' then
            if not Buffs['SeraACUResourceAllocation'] then
                BuffBlueprint {
                    Name = 'SeraACUResourceAllocation',
                    DisplayName = 'SeraACUResourceAllocation',
                    BuffType = 'SeraACUResourceAllocation',
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
            Buff.ApplyBuff(self, 'SeraACUResourceAllocation')
        elseif enh == 'ResourceAllocationRemove' then
            Buff.RemoveBuff(self, 'SeraACUResourceAllocation', false)
        elseif enh == 'ResourceAllocationAdvanced' then
            if Buffs['SeraACUResourceAllocation'] then
                Buff.RemoveBuff(self, 'SeraACUResourceAllocation', false)
            end
            if not Buffs['SeraACUResourceAllocationAdvanced'] then
                BuffBlueprint {
                    Name = 'SeraACUResourceAllocationAdvanced',
                    DisplayName = 'SeraACUResourceAllocationAdvanced',
                    BuffType = 'SeraACUResourceAllocationAdvanced',
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
            Buff.ApplyBuff(self, 'SeraACUResourceAllocationAdvanced')
        elseif enh == 'ResourceAllocationAdvancedRemove' then
            Buff.RemoveBuff(self, 'SeraACUResourceAllocationAdvanced', false)
        elseif enh == 'AdvancedEngineering' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['SeraphimACUT2BuildRate'] then
                BuffBlueprint {
                    Name = 'SeraphimACUT2BuildRate',
                    DisplayName = 'SeraphimACUT2BuildRate',
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
            Buff.ApplyBuff(self, 'SeraphimACUT2BuildRate')
        elseif enh == 'T3Engineering' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['SeraphimACUT3BuildRate'] then
                BuffBlueprint {
                    Name = 'SeraphimACUT3BuildRate',
                    DisplayName = 'SeraphimCUT3BuildRate',
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
            Buff.ApplyBuff(self, 'SeraphimACUT3BuildRate')
            if Buff.HasBuff(self, 'SeraphimACUT2BuildRate') then
                Buff.RemoveBuff(self, 'SeraphimACUT2BuildRate')
            end
        elseif enh == 'BlastAttack' then
            if not Buffs['SeraACUBlastAttack'] then
                BuffBlueprint {
                    Name = 'SeraACUBlastAttack',
                    DisplayName = 'SeraACUBlastAttack',
                    BuffType = 'SeraACUBlastAttack',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        Damage = {
                            Add = bp.AdditionalDamage,
                            ByName = {
                                ChronotronCannon = true,
                            },
                        },
                        MaxRadius = {
                            Add = bp.NewMaxRadius,
                            ByName = {
                                ChronotronCannon = true,
                                OverCharge = true,
                            },
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'SeraACUBlastAttack')
        elseif enh == 'BlastAttackRemove' then
            if Buff.HasBuff(self, 'SeraACUBlastAttack') then
                Buff.RemoveBuff(self, 'SeraACUBlastAttack')
            end
        elseif enh == 'RateOfFire' then
            if not Buffs['SeraACURateOfFire'] then
                BuffBlueprint {
                    Name = 'SeraACURateOfFire',
                    DisplayName = 'SeraACURateOfFire',
                    BuffType = 'SeraACURateOfFire',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        RateOfFireBuf = {
                            Add = bp.NewRateOfFire,
                            ByName = {
                                ChronotronCannon = true,
                            },
                        },
                        MaxRadius = {
                            Add = bp.NewMaxRadius,
                            ByName = {
                                ChronotronCannon = true,
                                OverCharge = true,
                            },
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'SeraACURateOfFire')
        elseif enh == 'RateOfFireRemove' then
            if Buff.HasBuff(self, 'SeraACURateOfFire') then
                Buff.RemoveBuff(self, 'SeraACURateOfFire')
            end
        else
            return oldXSL0001.CreateEnhancement(self, enh)
        end
    end,

    GetUnitsToBuff = function(self, bp)
        local unitCat = ParseEntityCategory(bp.UnitCategory or
            'BUILTBYTIER3FACTORY + BUILTBYQUANTUMGATE + NEEDMOBILEBUILD')
        local brain = self:GetAIBrain()

        local radiusMult = Buffs.VeterancyDamageArea.Affects.DamageRadius.Mult - 1
        local radiusMaxLevel = Buffs.VeterancyDamageArea.MaxLevel
        local radius = bp.Radius + (radiusMult * math.min(radiusMaxLevel, self.VetLevel - 1) * bp.Radius)

        local all = brain:GetUnitsAroundPoint(unitCat, self:GetPosition(), radius, 'Ally')
        local units = {}

        for _, u in all do
            if not u.Dead and not u:IsBeingBuilt() then
                table.insert(units, u)
            end
        end

        return units
    end,
}
TypeClass = XSL0001
