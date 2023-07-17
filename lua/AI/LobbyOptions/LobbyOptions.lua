---@type ScenarioOption[]
AIOpts = {}
do
    local TableInsert = table.insert
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

    local VetBuffsMultValues = {
        ['VeterancyHealthRegen'] = {
            MaxHealth = { 10, 100, 10 },
            Regen = { 10, 100, 10 },
        },
        ['VeterancyDamageRoF'] = {
            Damage = { 10, 100, 10 },
            RateOfFireBuf = { 1, 10, 1 },
        },
        ['VeterancyDamageArea'] = {
            DamageRadius = { 5, 100, 5 },
        },
        ['VeterancyRange'] = {
            MaxRadius = { 1, 10, 1 },
        },
        ['VeterancySpeed'] = {
            MoveMult = { 1, 10, 1 },
        },
        ['VeterancyFuel'] = {
            Fuel = { 5, 100, 5 },
        },
        ['VeterancyShield'] = {
            ShieldHP = { 10, 100, 10 },
            ShieldRegen = { 10, 100, 10 },
        },
        ['VeterancyVision'] = {
            VisionRadius = { 2.5, 100, 2.5 },
        },
        ['VeterancyOmniRadius'] = {
            OmniRadius = { 2.5, 100, 2.5 },
        },
        ['VeterancyRadar'] = {
            RadarRadius = { 2.5, 100, 2.5 },
        },
        ['VeterancySonar'] = {
            SonarRadius = { 2.5, 100, 2.5 },
        },
        ['VeterancyBuildRate'] = {
            BuildRate = { 10, 100, 10 },
        },
        ['VeterancyResourceProduction'] = {
            EnergyProductionBuf = { 20, 100, 20 },
            MassProductionBuf = { 10, 100, 10 },
        },
        ['VeterancySpeed2'] = {
            MoveMult = { 1, 10, 1 },
        },
        ['VeterancyStorageBuff'] = {
            EnergyStorageBuf = { 40, 200, 40 },
            MassStorageBuf = { 40, 200, 40 },
        },
    }
    TableInsert(AIOpts,
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
    TableInsert(AIOpts,
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
    local function BuffMultOptionValue(startValue, endValue, stepValue)
        local values = {}
        for i = startValue, endValue, stepValue do
            TableInsert(values, i)
        end
        return values
    end

    for _, vetBuff in VetBuffs do
        TableInsert(AIOpts,
            {
                default = 2,
                label = vetBuff,
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
        if VetBuffsMultValues[vetBuff] then
            for affect, values in VetBuffsMultValues[vetBuff] do
                TableInsert(AIOpts,
                    {
                        default = 1,
                        label = vetBuff .. " " .. affect,
                        help = "Sets " .. vetBuff .. " " .. affect .. " mult percentage",
                        key = vetBuff .. affect,
                        value_text = "%.2f%%",
                        value_help = "Buff multiplier percentage",
                        values = BuffMultOptionValue(unpack(values))
                    })
            end
        end
    end
end
