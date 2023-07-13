do
    local oldXSL0301 = XSL0301
    XSL0301 = Class(oldXSL0301) {
        CreateEnhancement = function(self, enh)
            CommandUnit.CreateEnhancement(self, enh)
            local bp = self.Blueprint.Enhancements[enh]
            if not bp then
                return
            end
            if enh == 'EngineeringThroughput' then
                if not Buffs['SeraphimSCUBuildRate'] then
                    BuffBlueprint {
                        Name = 'SeraphimSCUBuildRate',
                        DisplayName = 'SeraphimSCUBuildRate',
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
                Buff.ApplyBuff(self, 'SeraphimSCUBuildRate')
            elseif enh == 'EnhancedSensors' then
                if not Buffs['SeraSCUEnhancedSensors'] then
                    BuffBlueprint {
                        Name = 'SeraSCUEnhancedSensors',
                        DisplayName = 'SeraSCUEnhancedSensors',
                        BuffType = 'SeraSCUEnhancedSensors',
                        Stacks = 'ALWAYS',
                        Duration = -1,
                        Affects = {
                            VisionRadius = {
                                Add = bp.NewVisionRadius,
                            },
                            OmniRadius = {
                                Add = bp.NewOmniRadius,
                            },
                        },
                    }
                end
                Buff.ApplyBuff(self, 'SeraSCUEnhancedSensors')
            elseif enh == 'EnhancedSensorsRemove' then
                Buff.RemoveBuff(self, 'SeraSCUEnhancedSensors', false)
            else
                oldXSL0301.CreateEnhancement(self, enh)
            end
        end,
    }
    TypeClass = XSL0301
end
