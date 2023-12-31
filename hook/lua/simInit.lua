--TODO: BAD PRACTICE!
local function testforbrute()
    for m, f in __active_mods do
        if f.uid == "184478EA-63CA-11DE-A3CE-C95E55D89593" and f.enabled == true and f.ui_only == false and
            f.author == "Brute51" and f.selectable == true then
            return false
        end
    end
end

local function CheckAlliances()
    local humans = {}
    local i = 0
    if testforbrute() == false then
        LOG('***Tech over Time mod active! MP Balance Set!')
        return false
    end
    for k, v in ArmyBrains do
        if v.BrainType == 'Human' then
            i = i + 1
            humans[i] = v
        end
    end
    if not table.empty(humans) then
        local maxhumans = table.getn(humans)
        for hum = 1, maxhumans do
            for ans = 1, maxhumans do
                if not IsAlly(humans[hum]:GetArmyIndex(), humans[ans]:GetArmyIndex()) then
                    LOG('***MP Balance Set!')
                    return false
                end
            end
        end
    end
    LOG('***SP/Coop Balance Set!')
    return true
end

local _SetupSession = SetupSession
function SetupSession()
    _SetupSession()
    do
        local function IsEnabled(name)
            return ScenarioInfo.Options[name] ~= "false"
        end

        local function _GetBuffMult(buff, name)
            return (ScenarioInfo.Options[buff .. name] or 0) / 100
        end

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
        for _, buff in VetBuffs do
            if not IsEnabled(buff) then
                Buffs[buff].Affects = {}
                LOG("Veterancy buff " .. buff .. " Disabled")
            else
                LOG("Veterancy buff " .. buff .. " Enabled")
                for name, affect in pairs(Buffs[buff].Affects) do
                    if affect.Mult then
                        affect.Mult = 1 + _GetBuffMult(buff, name)
                        LOG(('Buff %s:%s = %f'):format(buff, name, affect.Mult))
                    end
                end
            end
        end
    end
end

local oldBeginSession = BeginSession
function BeginSession()
    local s = ScenarioInfo
    local restrictedUnits = import('/lua/ui/lobby/restrictedUnitsData.lua').restrictedUnits
    restrictedUnits['NUKE']['categories'] = nil
    restrictedUnits['GAMEENDERS']['categories'] = nil
    restrictedUnits['NUKE']['categories'] = { 'NUKE' }
    restrictedUnits['GAMEENDERS']['categories'] = { 'ORBITALSYSTEM' }
    if not s.Options.RestrictedCategories then
        s.Options.RestrictedCategories = {}
    end
    oldBeginSession()
    local buildRestrictions = nil
    if s.Options.RestrictedCategories then
        local restrictedUnits = import('/lua/ui/lobby/restrictedUnitsData.lua').restrictedUnits
        restrictedUnits['GAMEENDERS']['categories'] = EntityCategoryGetUnitList(
            categories.SILO * categories.EXPERIMENTAL + categories.NUKE * categories.EXPERIMENTAL +
            categories.ECONOMIC * categories.EXPERIMENTAL +
            categories.ARTILLERY * categories.TECH3 +
            categories.ARTILLERY * categories.EXPERIMENTAL +
            categories.ORBITALSYSTEM + categories.EXPERIMENTAL * categories.STRATEGIC -
            categories.EXPERIMENTAL * categories.FACTORY * categories.MOBILE -
            categories.TECH3 * categories.ARTILLERY * categories.MOBILE)
        restrictedUnits['NUKE']['categories'] = EntityCategoryGetUnitList(
            categories.SILO * categories.EXPERIMENTAL +
            categories.SILO * categories.TECH3 -
            categories.SUBCOMMANDER)
        for index, restriction in s.Options.RestrictedCategories do
            local restrictedCategories = nil
            for index, cat in restrictedUnits[restriction].categories do
                if restrictedCategories == nil then
                    restrictedCategories = categories[cat]
                else
                    restrictedCategories = restrictedCategories + categories[cat]
                end
            end
            if buildRestrictions == nil then
                buildRestrictions = restrictedCategories
            else
                buildRestrictions = buildRestrictions + restrictedCategories
            end
        end
    end
    if buildRestrictions then
        local tblArmies = ListArmies()
        for index, name in tblArmies do
            AddBuildRestriction(index, buildRestrictions)
        end
    end
    s.ALLies = CheckAlliances()
    Sync.UnitData.ALLies = s.ALLies
end
