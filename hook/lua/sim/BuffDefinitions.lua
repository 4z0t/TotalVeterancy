import('/lua/sim/AdjacencyBuffs.lua')
import('/lua/sim/CheatBuffs.lua')

BuffBlueprint {
    Name = 'VeterancyHealthRegen',
    DisplayName = 'VeterancyHealthRegen',
    BuffType = 'VETERANCYHEALTHREGEN',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Mult = 1.1,
        },
        Regen = {
            Mult = 1.1000001,
        },
    },
}
BuffBlueprint {
    Name = 'VeterancyDamageRoF',
    DisplayName = 'VeterancyDamageRoF',
    BuffType = 'VETERANCYDAMAGEROF',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        Damage = {
            Mult = 1.1000001,
        },
        RateOfFireBuf = {
            Mult = 1.0100001,
        },
    },
}
BuffBlueprint {
    MaxLevel = 20,
    Name = 'VeterancyDamageArea',
    DisplayName = 'VeterancyDamageArea',
    BuffType = 'VETERANCYDAMAGEAREA',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        DamageRadius = {
            Mult = 1.0500001,
        },
    },
}
BuffBlueprint {
    MaxLevel = 100,
    Name = 'VeterancyRange',
    DisplayName = 'VeterancyRange',
    BuffType = 'VETERANCYRANGE',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MaxRadius = {
            Mult = 1.0100001,
        },
    },
}
BuffBlueprint {
    MaxLevel = 100,
    Name = 'VeterancySpeed',
    DisplayName = 'VeterancySpeed',
    BuffType = 'VETERANCYSPEED',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MoveMult = {
            Mult = 1.0100001,
        },
    },
}
BuffBlueprint {
    Name = 'VeterancyFuel',
    DisplayName = 'VeterancyFuel',
    BuffType = 'VETERANCYFUEL',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        Fuel = {
            Mult = 1.0500001,
        },
    },
}
BuffBlueprint {
    Name = 'VeterancyShield',
    DisplayName = 'VeterancyShield',
    BuffType = 'VETERANCYSHIELD',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        ShieldHP = {
            Mult = 1.1, 
        },
        ShieldRegen = {
            Mult = 1.100001,
        },
    },
}
BuffBlueprint {
    MaxLevel = 40,
    Name = 'VeterancyVision',
    DisplayName = 'VeterancyVision',
    BuffType = 'VETERANCYVISION',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        VisionRadius = {
            Mult = 1.02500001,
        },
    },
}
BuffBlueprint {
    MaxLevel = 40,
    Name = 'VeterancyOmniRadius',
    DisplayName = 'VeterancyOmniRadius',
    BuffType = 'VETERANCYOMNIRADIUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        OmniRadius = {
            Mult = 1.02500001,
        },
    },
}
BuffBlueprint {
    MaxLevel = 40,
    Name = 'VeterancyRadar',
    DisplayName = 'VeterancyRadar',
    BuffType = 'VETERANCYRADAR',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        RadarRadius = {
            Mult = 1.02500001,
        },
    },
}
BuffBlueprint {
    MaxLevel = 40,
    Name = 'VeterancySonar',
    DisplayName = 'VeterancySonar',
    BuffType = 'VETERANCYSONAR',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        SonarRadius = {
            Mult = 1.02500001,
        },
    },
}
BuffBlueprint {
    Name = 'VeterancyBuildRate',
    DisplayName = 'VeterancyBuildRate',
    BuffType = 'VETERANCYBUILDRATE',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        BuildRate = {
            Mult = 1.100001,
        },
    },
}
BuffBlueprint {
    Name = 'VeterancyResourceProduction',
    DisplayName = 'VeterancyResourceProduction',
    BuffType = 'VeterancyResourceProduction',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        EnergyProductionBuf = {
            Mult = 1.200001,
        },
        MassProductionBuf = {
            Mult = 1.1000001,
        },
    },
}
BuffBlueprint {
    Name = 'VeterancyCommandProduction',
    DisplayName = 'VeterancyCommandProduction',
    BuffType = 'VETERANCYCOMMANDPRODUCTION',
    Stacks = 'ALWAYS',
    Duration = -1,
    MaxLevel = 20,
    Affects = {
        EnergyProductionBuf = {
            Add = 50,
        },
        MassProductionBuf = {
            Add = 0.5,
        },
    },
}
BuffBlueprint {
    MinLevel = 40,
    MaxLevel = 940,
    Name = 'VeterancySpeed2',
    DisplayName = 'VeterancySpeed2',
    BuffType = 'VETERANCYSPEED2',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MoveMult = {
            Mult = 1.0100001,
        },
    },
}
BuffBlueprint {
    Name = 'VeterancyStorageBuff',
    DisplayName = 'VeterancyStorageBuff',
    BuffType = 'VETERANCYSTORAGEBUFF',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        EnergyStorageBuf = {
            Mult = 1.4000001,
        },
        MassStorageBuf = {
            Mult = 1.4000001,
        },
    },
}
__moduleinfo.auto_reload = true
