---@type ScenarioOption[]
AIOpts = {}
do
    local VetBuffs = {
        'VeterancyHealthRegen',
        'VeterancyStorageBuff',
        'VeterancyDamageRoF',
        'VeterancyDamageArea',
        'VeterancyRange',
        'VeterancySpeed',
        'VeterancyFuel',
        'VeterancyShield',
        'VeterancyVision',
        'VeterancyOmniRadius',
        'VeterancyRadar',
        'VeterancySonar',
        'VeterancyBuildRate',
        'VeterancyResourceProduction',
        'VeterancyCommandProduction',
        'VeterancySpeed2',
    }

    for _, vetBuff in VetBuffs do
        table.insert(AIOpts,
            {
                default = 2,
                label = vetBuff .. " buff",
                help = "Enable " .. vetBuff .. " buff",
                key = vetBuff,
                values = {
                    {
                        text = "<LOC _Off>Off",
                        help = "Disabled",
                        key = 'false',
                    },
                    {
                        text = "<LOC _On>On",
                        help = "Enabled",
                        key = 'true',
                    },
                },
            })
    end

end
