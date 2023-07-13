local oldUEL0001 = UEL0001
UEL0001 = Class(oldUEL0001) {
    CreateEnhancement = function(self, enh)
        ACUUnit.CreateEnhancement(self, enh)
        local bp = self.Blueprint.Enhancements[enh]
        if not bp then
            return
        end
        if enh == 'AdvancedEngineering' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['UEFACUT2BuildRate'] then
                BuffBlueprint {
                    Name = 'UEFACUT2BuildRate',
                    DisplayName = 'UEFACUT2BuildRate',
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
            Buff.ApplyBuff(self, 'UEFACUT2BuildRate')
        elseif enh == 'AdvancedEngineeringRemove' then
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction(categories.UEF *
                (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER))
            if Buff.HasBuff(self, 'UEFACUT2BuildRate') then
                Buff.RemoveBuff(self, 'UEFACUT2BuildRate')
            end
        elseif enh == 'T3Engineering' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['UEFACUT3BuildRate'] then
                BuffBlueprint {
                    Name = 'UEFACUT3BuildRate',
                    DisplayName = 'UEFCUT3BuildRate',
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
            Buff.ApplyBuff(self, 'UEFACUT3BuildRate')
            if Buff.HasBuff(self, 'UEFACUT2BuildRate') then
                Buff.RemoveBuff(self, 'UEFACUT2BuildRate')
            end
        elseif enh == 'T3EngineeringRemove' then
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction(categories.UEF *
                (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER))
            if Buff.HasBuff(self, 'UEFACUT3BuildRate') then
                Buff.RemoveBuff(self, 'UEFACUT3BuildRate')
            end
        elseif enh == 'DamageStablization' then
            if not Buffs['UEFACUDamageStablization'] then
                BuffBlueprint {
                    Name = 'UEFACUDamageStablization',
                    DisplayName = 'UEFACUDamageStablization',
                    BuffType = 'ACUREGEN',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        Regen = {
                            Add = bp.NewRegenRate,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'UEFACUDamageStablization')
        elseif enh == 'DamageStablizationRemove' then
            Buff.RemoveBuff(self, 'UEFACUDamageStablization', false)
        elseif enh == 'HeavyAntiMatterCannon' then
            if not Buffs['UefACUHeavyAntiMatterCannon'] then
                BuffBlueprint {
                    Name = 'UefACUHeavyAntiMatterCannon',
                    DisplayName = 'UefACUHeavyAntiMatterCannon',
                    BuffType = 'UefACUHeavyAntiMatterCannon',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        Damage = {
                            Add = bp.ZephyrDamageMod,
                            ByName = {
                                RightZephyr = true,
                            },
                        },
                        MaxRadius = {
                            Add = bp.NewMaxRadius,
                            ByName = {
                                RightZephyr = true,
                                OverCharge = true,
                            },
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'UefACUHeavyAntiMatterCannon')
        elseif enh == 'HeavyAntiMatterCannonRemove' then
            Buff.RemoveBuff(self, 'UefACUHeavyAntiMatterCannon', false)
        elseif enh == 'ResourceAllocation' then
            if not Buffs['UefACUResourceAllocation'] then
                BuffBlueprint {
                    Name = 'UefACUResourceAllocation',
                    DisplayName = 'UefACUResourceAllocation',
                    BuffType = 'UefACUResourceAllocation',
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
            Buff.ApplyBuff(self, 'UefACUResourceAllocation')
        elseif enh == 'ResourceAllocationRemove' then
            Buff.RemoveBuff(self, 'UefACUResourceAllocation', false)
        elseif enh == 'LeftPod' then
            local location = self:GetPosition('AttachSpecial02')
            local pod = CreateUnitHPR('UEA0001', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
            pod:SetParent(self, 'LeftPod')
            pod:SetCreator(self)
            pod:AddBuildRestriction(categories.UEF *
                (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER))
            if self.LevelProgress and self.LevelProgress > 1 then
                pod:AddLevels(self.LevelProgress - 1)
            end
            self.Trash:Add(pod)
            self.HasLeftPod = true
            self.LeftPod = pod
        elseif enh == 'RightPod' then
            local location = self:GetPosition('AttachSpecial01')
            local pod = CreateUnitHPR('UEA0001', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
            pod:SetParent(self, 'RightPod')
            pod:SetCreator(self)
            pod:AddBuildRestriction(categories.UEF *
                (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER))
            if self.LevelProgress and self.LevelProgress > 1 then
                pod:AddLevels(self.LevelProgress - 1)
            end
            self.Trash:Add(pod)
            self.HasRightPod = true
            self.RightPod = pod
        else
            oldUEL0001.CreateEnhancement(self, enh)
        end
    end,
}
TypeClass = UEL0001
