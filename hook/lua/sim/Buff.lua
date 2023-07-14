local MathCeil, MathAbs, MathFloor, MathRound = math.ceil, math.abs, math.floor, math.round
function BuffCalculate(unit, buffName, affectType, initialVal, initialBool)
    local adds = 0
    local mults = 1.0
    local exists = false
    local divs = 1.0
    local bool = initialBool or false
    local highestCeil = false
    local lowestFloor = false
    if not unit.Buffs.Affects[affectType] then
        return initialVal, bool, exists
    end
    for k, v in unit.Buffs.Affects[affectType] do
        exists = true
        if v.Add and v.Add ~= 0 then
            adds = adds + (v.Add * v.Count)
        end
        if v.Mult then
            for i = 1, v.Count do
                if v.Mult >= 1 then
                    mults = mults + v.Mult - 1
                else
                    divs = divs * v.Mult
                end
            end
        end
        if not v.Bool then
            bool = false
        else
            bool = true
        end
        if v.Ceil and (not highestCeil or highestCeil < v.Ceil) then
            highestCeil = v.Ceil
        end
        if v.Floor and (not lowestFloor or lowestFloor > v.Floor) then
            lowestFloor = v.Floor
        end
    end
    local
    returnVal = (initialVal + adds) * mults * divs
    if lowestFloor and
        returnVal < lowestFloor then
        returnVal = lowestFloor
    end
    if highestCeil and
        returnVal > highestCeil then
        returnVal = highestCeil
    end
    return returnVal, bool, exists
end

---@alias BuffProcessor fun(unit:Unit, instigator:Unit, vals:BlueprintBuffAffect,  buffDef:BlueprintBuff, afterRemove:boolean)


---@type table<string, BuffProcessor>
local BuffProcessors = {
    ---@param unit Unit
    ---@param instigator Unit
    ---@param buffDef BlueprintBuff
    Health = function(unit, instigator, vals, buffDef, afterRemove)
        local health = unit:GetHealth()
        local val = ((vals.Add or 0) + health) * (vals.Mult or 1)
        local healthadj = val - health
        if healthadj < 0 then
            unit:DoTakeDamage(instigator, -healthadj, VDiff(instigator:GetPosition(), unit:GetPosition()),
                buffDef.DamageType or 'Spell')
        else
            unit:AdjustHealth(instigator, healthadj)
        end
    end,

    MaxHealth = function(unit, instigator, vals, buffDef, afterRemove)
        if not unit.basehp then
            unit.basehp = unit:GetMaxHealth()
        end
        local ratio = unit:GetMaxHealth() - unit:GetHealth()
        local val = BuffCalculate(unit, nil, 'MaxHealth', unit.basehp)
        val = MathCeil(val)
        if val < ratio then
            ratio = val - 1
        end
        unit:SetMaxHealth(val)
        unit:SetHealth(unit, val - ratio)
    end,

    RegenPercent = function(unit, instigator, vals, buffDef, afterRemove)
        local bpregn = unit:GetBlueprint().Defense.RegenRate or 0
        local val = BuffCalculate(unit, nil, 'Regen', bpregn)
        local regenperc, _, exists = BuffCalculate(unit, nil, 'RegenPercent', unit:GetMaxHealth())
        if exists then
            val = val + regenperc
        end
        unit:SetRegenRate(val)
        unit.Sync.RegenRate = val
    end,

    ShieldHP = function(unit, instigator, vals, buffDef, afterRemove)
        local shield = unit:GetShield()
        if not shield then
            return
        end
        local ratio = shield:GetMaxHealth() - shield:GetHealth()
        if ScenarioInfo.ALLies ~= false then
            ratio = 0
        end
        local val = BuffCalculate(unit, nil, "ShieldHP", shield.spec.ShieldMaxHealth)
        val = MathCeil(val)
        shield:SetMaxHealth(val)
        shield:SetHealth(shield, val - ratio)
        unit.Sync.ShieldMaxHp = val
    end,

    ShieldRegen = function(unit, instigator, vals, buffDef, afterRemove)
        local shield = unit:GetShield()
        if not shield then
            return
        end
        local valregen = shield.spec.ShieldRegenRate
        valregen = BuffCalculate(unit, nil, "ShieldRegen", valregen)
        unit.Sync.ShieldRegen = valregen
        shield:SetShieldRegenRate(valregen)
    end,

    Damage = function(unit, instigator, vals, buffDef, afterRemove)
        for i = 1, unit:GetWeaponCount() do
            local wep = unit:GetWeapon(i)
            local wepbp = wep:GetBlueprint()

            if wep.Label == 'DeathWeapon' or wep.Label == 'DeathImpact' then
                return
            end

            if wepbp.WeaponCategory == 'Death' or vals.ByName and not vals.ByName[wepbp.Label] then
                return
            end

            local wepbp = wep:GetBlueprint()
            wep.Damage = MathRound(BuffCalculate(unit, nil, "Damage", wepbp.Damage))
            if wepbp.EnergyDrainPerSecond and wepbp.EnergyDrainPerSecond > 0 then
                wep.nrgd = MathRound(BuffCalculate(unit, nil, "Damage", wepbp.EnergyDrainPerSecond))
            end
            if wepbp.EnergyRequired and wepbp.EnergyRequired > 0 then
                wep.nrgq = MathRound(BuffCalculate(unit, nil, "Damage", wepbp.EnergyRequired))
            end
            if wepbp.NukeOuterRingDamage and wepbp.NukeInnerRingDamage then
                wep.NukeOuterRingDamage = BuffCalculate(unit, nil, "Damage", wepbp.NukeOuterRingDamage)
                wep.NukeInnerRingDamage = BuffCalculate(unit, nil, "Damage", wepbp.NukeInnerRingDamage)
            end

        end
    end,

    DamageRadius = function(unit, instigator, vals, buffDef, afterRemove)
        for i = 1, unit:GetWeaponCount() do
            local wep = unit:GetWeapon(i)
            local wepbp = wep:GetBlueprint()
            if not (wepbp.WeaponCategory == 'Death' or
                vals.ByName and not vals.ByName[wepbp.Label]) then
                local val = BuffCalculate(unit, nil, "DamageRadius", wepbp.DamageRadius)
                wep.DamageRadius = val
            end
        end
    end,

    MaxRadius = function(unit, instigator, vals, buffDef, afterRemove)
        for i = 1, unit:GetWeaponCount() do
            local wep = unit:GetWeapon(i)
            local wepbp = wep:GetBlueprint()
            if not
                (
                wepbp.WeaponCategory == 'Death' or
                    vals.ByName and not vals.ByName[wepbp.Label]) then
                local val = BuffCalculate(unit, nil, "MaxRadius", wepbp.MaxRadius)
                wep:ChangeMaxRadius(val)
                wep.rangeMod = val / wepbp.MaxRadius
            end
        end
    end,

    RateOfFireBuf = function(unit, instigator, vals, buffDef, afterRemove)
        for i = 1, unit:GetWeaponCount() do
            local wep = unit:GetWeapon(i)
            local wepbp = wep:GetBlueprint()
            if not
                (
                wepbp.WeaponCategory == 'Death' or
                    vals.ByName and not vals.ByName[wepbp.Label]) then
                local val = BuffCalculate(unit, nil, "RateOfFireBuf", wepbp.RateOfFire)
                wep.bufRoF = val
                wep:ChangeRateOfFire(val / wep.adjRoF)
            end
        end
    end,

    MoveMult = function(unit, instigator, vals, buffDef, afterRemove)
        if not EntityCategoryContains(categories.AIR, unit) then
            local val = BuffCalculate(unit, nil, 'MoveMult', 1)
            unit:SetSpeedMult(val)
            unit:SetAccMult(val)
            unit:SetTurnMult(val)
        end
    end,
    Stun = function(unit, instigator, vals, buffDef, afterRemove)
        if afterRemove then
            return
        end
        unit:SetStunned(buffDef.Duration or 1, instigator)
        if unit.Anims then
            for k, manip in unit.Anims do
                manip:SetRate(0)
            end
        end
    end,
    WeaponsEnable = function(unit, instigator, vals, buffDef, afterRemove)
        for i = 1, unit:GetWeaponCount() do
            local wep = unit:GetWeapon(i)
            local val, bool = BuffCalculate(unit, nil, 'WeaponsEnable', 0, true)
            wep:SetWeaponEnabled(bool)
        end
    end,
    VisionRadius = function(unit, instigator, vals, buffDef, afterRemove)
        local intelbp = unit:GetBlueprint().Intel
        local val
        if (intelbp.MaxVisionRadius and intelbp.MinVisionRadius) then
            val = BuffCalculate(unit, nil, 'VisionRadius',
                intelbp.MaxVisionRadius or 0)
            unit.MaxVisionRadius = val
            unit:SetIntelRadius('Vision', val)
            val = BuffCalculate(unit, nil, 'VisionRadius',
                intelbp.MinVisionRadius or 0)
            unit.MinVisionRadius = val
        else
            val = BuffCalculate(unit, nil, 'VisionRadius',
                intelbp.VisionRadius or 0)
            unit:SetIntelRadius('Vision', val)
        end
    end,
    RadarRadius = function(unit, instigator, vals, buffDef, afterRemove)
        local val = BuffCalculate(unit, nil, 'RadarRadius',
            unit:GetBlueprint().Intel.RadarRadius or 0)
        if val <= 0 then
            unit:DisableIntel('Radar')
            return
        end
        if not unit:IsIntelEnabled('Radar') then
            unit:InitIntel(unit:GetArmy(), 'Radar', val)
            unit:EnableIntel('Radar')
        else
            unit:SetIntelRadius('Radar', val)
            unit:EnableIntel('Radar')
        end
    end,
    SonarRadius = function(unit, instigator, vals, buffDef, afterRemove)
        if not unit:GetBlueprint().Intel.SonarRadius then
            return
        end
        local val = BuffCalculate(unit, nil,
            'SonarRadius',
            unit:GetBlueprint().Intel.SonarRadius or 0)
        if val <= 0 then
            unit:DisableIntel('Sonar')
            return
        end
        if not unit:IsIntelEnabled('Sonar') then
            unit:InitIntel(unit:GetArmy(), 'Sonar', val)
            unit:EnableIntel('Sonar')
        else
            unit:SetIntelRadius('Sonar', val)
            unit:EnableIntel('Sonar')
        end
    end,
    OmniRadius = function(unit, instigator, vals, buffDef, afterRemove)
        local val = BuffCalculate(unit, nil,
            'OmniRadius',
            unit:GetBlueprint().Intel.OmniRadius or 0)
        if val <= 0 then
            unit:DisableIntel('Omni')
            return
        end
        if not unit:IsIntelEnabled('Omni') then
            unit:InitIntel(unit:GetArmy(), 'Omni', val)
            unit:EnableIntel('Omni')
        else
            unit:SetIntelRadius('Omni', val)
            unit:EnableIntel('Omni')
        end
    end,
    BuildRate = function(unit, instigator, vals, buffDef, afterRemove)
        local val = BuffCalculate(unit, nil, 'BuildRate', unit:GetBlueprint().Economy.BuildRate or 1)
        unit:SetBuildRate(val)
    end,
    EnergyProductionBuf = function(unit, instigator, vals, buffDef, afterRemove)
        if unit:GetBlueprint().Economy.ProductionPerSecondEnergy then
            local val = BuffCalculate(unit, nil, 'EnergyProductionBuf',
                unit:GetBlueprint().Economy.ProductionPerSecondEnergy
                or 0)
            unit.EnergyProdMod = val
            unit:UpdateProductionValues()
        end
    end,
    MassProductionBuf = function(unit, instigator, vals, buffDef, afterRemove)
        local val = BuffCalculate(unit, nil, 'MassProductionBuf',
            unit:GetBlueprint().Economy.ProductionPerSecondMass or 0)
        unit.MassProdMod = val
        unit:UpdateProductionValues()
    end,
    EnergyActive = function(unit, instigator, vals, buffDef, afterRemove)
        local val = BuffCalculate(unit, nil, 'EnergyActive', 1)
        unit.EnergyBuildAdjMod = val
        unit:UpdateConsumptionValues()
    end,
    MassActive = function(unit, instigator, vals, buffDef, afterRemove)
        local val = BuffCalculate(unit, nil, 'MassActive', 1)
        unit.MassBuildAdjMod = val
        unit:UpdateConsumptionValues()
    end,
    EnergyMaintenance = function(unit, instigator, vals, buffDef, afterRemove)
        local val = BuffCalculate(unit, nil, 'EnergyMaintenance', 1)
        unit.EnergyMaintAdjMod = val
        unit:UpdateConsumptionValues()
    end,
    MassMaintenance = function(unit, instigator, vals, buffDef, afterRemove)
        local val = BuffCalculate(unit, nil, 'MassMaintenance', 1)
        unit.MassMaintAdjMod = val
        unit:UpdateConsumptionValues()
    end,
    EnergyProduction = function(unit, instigator, vals, buffDef, afterRemove)
        local val = BuffCalculate(unit, nil, 'EnergyProduction', 1)
        unit.EnergyProdAdjMod = val
        unit:UpdateProductionValues()
    end,
    MassProduction = function(unit, instigator, vals, buffDef, afterRemove)
        local val = BuffCalculate(unit, nil, 'MassProduction', 1)
        unit.MassProdAdjMod = val
        unit:UpdateProductionValues()
    end,

    EnergyWeapon = function(unit, instigator, vals, buffDef, afterRemove)
        local val = BuffCalculate(unit, nil, 'EnergyWeapon', 1)
        for i = 1, unit:GetWeaponCount() do
            local wep = unit:GetWeapon(i)
            if wep:WeaponUsesEnergy() then
                wep.AdjEnergyMod = val
            end
        end
    end,
    RateOfFire = function(unit, instigator, vals, buffDef, afterRemove)
        for i = 1, unit:GetWeaponCount() do
            local wep = unit:GetWeapon(i)
            local wepbp = wep:GetBlueprint()
            local weprof = wepbp.RateOfFire
            local val = BuffCalculate(unit, nil, 'RateOfFire', 1)
            local delay = 1 / wepbp.RateOfFire
            wep.adjRoF = val
            wep:ChangeRateOfFire(wep.bufRoF / wep.adjRoF)
        end
    end,


}
BuffProcessors.Regen = BuffProcessors.RegenPercent

function BuffAffectUnit(unit, buffName, instigator, afterRemove)
    local buffDef = Buffs[buffName]
    local buffAffects = buffDef.Affects
    if buffDef.OnBuffAffect and not afterRemove then
        buffDef:OnBuffAffect(unit, instigator)
    end
    for atype, vals in buffAffects do
        local f = BuffProcessors[atype]
        if f then
            f(unit, instigator, vals, buffDef, afterRemove)
        elseif atype ~= 'Stun' then
            WARN("*WARNING: Tried to apply a buff with an unknown affect type of " ..
                atype .. " for buff " .. buffName)
        end
    end
end

function BuffWorkThread(unit, buffName, instigator)
    local buffTable = Buffs[buffName]
    local totPulses = buffTable.DurationPulse
    if not totPulses then
        WaitSeconds(buffTable.Duration)
    else
        local pulse = 0
        local pulseTime = buffTable.Duration / totPulses
        while pulse <= totPulses and not unit:IsDead() do
            WaitSeconds(pulseTime)
            BuffAffectUnit(unit, buffName, instigator, false)
            pulse = pulse + 1
        end
    end
    RemoveBuff(unit, buffName)
end

function PlayBuffEffect(unit, buffName, trsh)
    local def = Buffs[buffName]
    if not def.Effects then
        return
    end
    for k, fx in def.Effects do
        local bufffx = CreateAttachedEmitter(unit, 0, unit:GetArmy(), fx)
        if def.EffectsScale then
            bufffx:ScaleEmitter(def.EffectsScale)
        end
        trsh:Add(bufffx)
        unit.TrashOnKilled:Add(bufffx)
    end
end

local getsize = table.getsize
function ApplyBuff(unit, buffName, instigator)
    if unit:IsDead() then
        return
    end
    instigator = instigator or unit
    local def = Buffs[buffName]
    if not def then
        error("*ERROR: Tried to add a buff that doesn\'t exist! Name: " .. buffName, 2)
        return
    end
    if def.EntityCategory then
        local cat = ParseEntityCategory(def.EntityCategory)
        if not EntityCategoryContains(cat, unit) then
            return
        end
    end
    if def.BuffCheckFunction then
        if not def:BuffCheckFunction(unit) then
            return
        end
    end
    local ubt = unit.Buffs.BuffTable
    if def.MinLevel and def.MinLevel >= unit.VeteranLevel then
        return
    end
    if def.MaxLevel and def.MaxLevel + 1 < unit.VeteranLevel then
        return
    end
    if def.Stacks == 'REPLACE' and ubt[def.BuffType] then
        for key, bufftbl in unit.Buffs.BuffTable[def.BuffType] do
            RemoveBuff(unit, key, true)
        end
    end
    if not ubt[def.BuffType] then
        ubt[def.BuffType] = {}
    end
    if def.Stacks == 'IGNORE' and ubt[def.BuffType] and getsize(ubt[def.BuffType]) > 0 then
        return
    end
    local data = ubt[def.BuffType][buffName]
    if not data then
        data = {
            Count = 1,
            Trash = TrashBag(),
            BuffName = buffName,
        }
        ubt[def.BuffType][buffName] = data
    else
        data.Count = data.Count + 1
    end
    local uaffects = unit.Buffs.Affects
    if def.Affects then
        for k, v in def.Affects do
            if k ~= 'Health' and k ~= 'Energy' then
                if not uaffects[k] then uaffects[k] = {} end
                if not uaffects[k][buffName] then
                    local affectdata = { BuffName = buffName, Count = 1, }
                    for buffkey, buffval in v do
                        affectdata[buffkey] = buffval
                    end
                    uaffects[k][buffName] = affectdata
                else
                    uaffects[k][buffName].Count = uaffects[k][buffName].Count + 1
                end
            end
        end
    end
    if def.Duration and def.Duration > 0 then
        local thread = ForkThread(BuffWorkThread, unit, buffName, instigator)
        unit.Trash:Add(thread)
        data.Trash:Add(thread)
    end
    PlayBuffEffect(unit, buffName, data.Trash)
    ubt[def.BuffType][buffName] = data
    if def.OnApplyBuff then
        def:OnApplyBuff(unit, instigator)
    end
    BuffAffectUnit(unit, buffName, instigator, false)
end

local copy = table.copy
local removeByValue = table.removeByValue

function RemoveBuff(unit, buffName, removeAllCounts, instigator)
    local def = Buffs[buffName]
    local unitBuff = unit.Buffs.BuffTable[def.BuffType][buffName]
    for atype, _ in def.Affects do
        local list = unit.Buffs.Affects[atype]
        if list and list[buffName] then
            if removeAllCounts then
                list[buffName].Count = list[buffName].Count - unitBuff.Count
            else
                list[buffName].Count = list[buffName].Count - 1
            end
            if list[buffName].Count <= 0 then
                list[buffName] = nil
            end
        end
    end
    if not unitBuff.Count then
        local stg = "*WARNING: BUFF: unitBuff.Count is nil. Unit: " ..
            unit:GetUnitId() .. " Buff Name: " .. buffName .. " Unit BuffTable: ", repr(unitBuff)
        LOG('***ERROR.please.fix.me: ' .. GetGameTimeSeconds() .. 's ' .. stg)
        return
    end
    unitBuff.Count = unitBuff.Count - 1
    if removeAllCounts or unitBuff.Count <= 0 then
        unitBuff.Trash:Destroy()
        unit.Buffs.BuffTable[def.BuffType][buffName] = nil
    end
    if def.OnBuffRemove then
        def:OnBuffRemove(unit, instigator)
    end
    if def.Icon then
        local newTable = unit.Sync.Buffs
        removeByValue(newTable, buffName)
        unit.Sync.Buffs = copy(newTable)
    end
    BuffAffectUnit(unit, buffName, unit, true)
end

function HasBuff(unit, buffName)
    local def = Buffs[buffName]
    if not def then
        return false
    end
    local bonu = unit.Buffs.BuffTable[def.BuffType][buffName]
    if bonu then
        return true
    end
    return false
end
