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

    table.insert(AIOpts,
        {
            default = 2,
            label = "=====Total Veterancy=====",
            help = "Total Veterancy options section",
            key = "",
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
    table.insert(AIOpts,
        {
            default = 10,
            label = "XP gain multiplier",
            help = "How fast unit gains XP",
            key = 'XPGainMult',
            value_text = "%s",
            value_help = "XP gain multiplier of %s",
            values = {
                '0.1', '0.2', '0.3', '0.4', '0.5',
                '0.6', '0.7', '0.8', '0.9', '1.0',
                '1.1', '1.2', '1.3', '1.4', '1.5',
                '1.6', '1.7', '1.8', '1.9', '2.0',
                '2.1', '2.2', '2.3', '2.4', '2.5',
                '2.6', '2.7', '2.8', '2.9', '3.0',
                '3.1', '3.2', '3.3', '3.4', '3.5',
                '3.6', '3.7', '3.8', '3.9', '4.0',
                '4.1', '4.2', '4.3', '4.4', '4.5',
                '4.6', '4.7', '4.8', '4.9', '5.0',
                '5.1', '5.2', '5.3', '5.4', '5.5',
                '5.6', '5.7', '5.8', '5.9', '6.0'
            },
        })
    table.insert(AIOpts,
        {
            default = 2,
            label = "Jump abilities",
            help = "Enable Jump abilities of ACU and SACU",
            key = "IsJumpEnabled",
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
