do

end
local BPUtilities = {
    ---@param bp UnitBlueprint
    ---@param name string
    AddCategory = function(bp, name)
        if table.find(bp.Categories, name) then
            return
        end
        table.insert(bp.Categories, name)
        bp.CategoriesHash[name] = true
    end,

    ---@param bp UnitBlueprint
    ---@param name string
    ---@return boolean
    HasCatergory = function(bp, name)
        return bp.CategoriesHash[name]
    end
}



local function hwpe(id, bp)
    if bp.Categories and BPUtilities.HasCatergory(bp, 'ANTITELEPORT') and BPUtilities.HasCatergory(bp, 'COMMAND') and
        bp.Economy and bp.Economy.BuildCostMass and bp.Economy.BuildCostEnergy and bp.Economy.BuildTime then
        bp.Economy.xpValue = 200
    end
end

local oldModBP = ModBlueprints
function ModBlueprints(all_bps)
    oldModBP(all_bps)

    local scaling = 0.5
    local evenkills = 2
    local econScaling = 2
    local ACUbaseValue = 1600
    local SCUbaseValue = 6400
    for id, bp in all_bps.Unit do
        if bp.Weapon then
            for k, v in bp.Weapon do
                if type(v) ~= 'table' then
                    LOG('***ERROR.' .. id .. '.has.a.error.in.its.Weapon.table.' .. repr(k) .. repr(v))
                    continue
                end
                if v.Label ~= 'DeathWeapon' then
                    v.DamageFriendly = false
                    v.CollideFriendly = false
                end
            end
        end
        if bp.Economy.BuildRate > 4 then
            if not bp.Economy.MaxBuildDistance then
                bp.Economy.MaxBuildDistance = 10
            end
        end
        if bp.Defense.RegenRate == nil then
            bp.Defense.RegenRate = 0
        end
        local RegenMod = 0.9 * (50 - 1 / (0.00000060257 * bp.Defense.MaxHealth + 0.020016))
        bp.Defense.RegenRate = bp.Defense.RegenRate + RegenMod
        hwpe(id, bp)
        if bp.Economy and not bp.Economy.xpBaseValue and bp.Economy.BuildCostMass and bp.Economy.BuildCostEnergy and
            bp.Economy.BuildTime and BPUtilities.HasCatergory(bp, 'COMMAND') then
            bp.Economy.xpBaseValue = ACUbaseValue
        end
        if bp.Economy and not bp.Economy.xpBaseValue and bp.Economy.BuildCostMass and bp.Economy.BuildCostEnergy and
            bp.Economy.BuildTime and BPUtilities.HasCatergory(bp, 'SUBCOMMANDER') then
            bp.Economy.xpBaseValue = SCUbaseValue
        end
        if BPUtilities.HasCatergory(bp, 'SUBCOMMANDER') then
            bp.Economy.MaintenanceConsumptionPerSecondMass = nil
            bp.Economy.MaintenanceConsumptionPerSecondEnergy = nil
        end
        if bp.Economy and not bp.Economy.xpValue and bp.Economy.BuildCostMass and bp.Economy.BuildCostEnergy and
            bp.Economy.BuildTime and
            (
            not BPUtilities.HasCatergory(bp, 'UNTARGETABLE') or bp.Economy.xpBaseValue or
                BPUtilities.HasCatergory(bp, 'PROJECTILE')) then
            bp.Economy.xpValue = math.pow((
                bp.Economy.xpBaseValue or
                    (bp.Economy.BuildCostMass * 0.8 + bp.Economy.BuildCostEnergy * 0.2 + bp.Economy.BuildTime * 0.07)),
                scaling)
        end
        if bp.Economy and not bp.Economy.XPperLevel and bp.Economy.xpValue then
            bp.Economy.XPperLevel = bp.Economy.xpValue * evenkills
        end
        if id == 'uea0001' or id == 'uea0003' then
            table.insert(bp.Economy.BuildableCategory, 'BUILTBYTIER2COMMANDER UEF')
            table.insert(bp.Economy.BuildableCategory, 'BUILTBYTIER3COMMANDER UEF')
            BPUtilities.AddCategory(bp, 'SHOWQUEUE')
        end
        if BPUtilities.HasCatergory(bp, 'CONSTRUCTION') and BPUtilities.HasCatergory(bp, 'ENGINEER') and
            BPUtilities.HasCatergory(bp, 'REPAIR') and BPUtilities.HasCatergory(bp, 'RECLAIM') and
            BPUtilities.HasCatergory(bp, 'ASSIST') and not BPUtilities.HasCatergory(bp, 'SHOWQUEUE') then
            BPUtilities.AddCategory(bp, 'SHOWQUEUE')
        end
        if bp.Economy.ProductionPerSecondMass and not bp.Economy.StorageMass then
            bp.Economy.StorageMass = bp.Economy.ProductionPerSecondMass * 65
        end
        if bp.Economy.ProductionPerSecondEnergy and not bp.Economy.StorageEnergy then
            bp.Economy.StorageEnergy = bp.Economy.ProductionPerSecondEnergy * 10
        end
        if bp.Categories and BPUtilities.HasCatergory(bp, 'STRUCTURE') and
            (
            BPUtilities.HasCatergory(bp, 'MASSEXTRACTION') or BPUtilities.HasCatergory(bp, 'MASSFABRICATION') or
                BPUtilities.HasCatergory(bp, 'MASSPRODUCTION')) and not bp.Economy.xpTimeStep and
            not BPUtilities.HasCatergory(bp, 'UNTARGETABLE') then
            bp.Economy.xpTimeStep = math.random(99, 119)
            bp.Economy.xpValue = bp.Economy.xpValue * econScaling
        end
        if bp.Categories and BPUtilities.HasCatergory(bp, 'STRUCTURE') and
            BPUtilities.HasCatergory(bp, 'ENERGYPRODUCTION') and
            not bp.Economy.xpTimeStep and not BPUtilities.HasCatergory(bp, 'UNTARGETABLE') then
            bp.Economy.xpTimeStep = math.random(98, 118)
            bp.Economy.xpValue = bp.Economy.xpValue * econScaling
        end
        if bp.Categories and
            (
            BPUtilities.HasCatergory(bp, 'STRUCTURE') and BPUtilities.HasCatergory(bp, 'ENERGYSTORAGE') or
                BPUtilities.HasCatergory(bp, 'MASSSTORAGE')) and not bp.Economy.xpTimeStep and
            not BPUtilities.HasCatergory(bp, 'UNTARGETABLE') then
            bp.Economy.xpTimeStep = math.random(94, 114)
            bp.Economy.xpValue = bp.Economy.xpValue * econScaling
        end
        if bp.Categories and BPUtilities.HasCatergory(bp, 'INTELLIGENCE') and
            (BPUtilities.HasCatergory(bp, 'STRUCTURE') or BPUtilities.HasCatergory(bp, 'MOBILESONAR')) and
            not bp.Economy.xpTimeStep and not BPUtilities.HasCatergory(bp, 'UNTARGETABLE') then
            bp.Economy.xpTimeStep = math.random(101, 121)
            bp.Economy.xpValue = bp.Economy.xpValue * econScaling
        end
        if bp.Categories and BPUtilities.HasCatergory(bp, 'STRUCTURE') and BPUtilities.HasCatergory(bp, 'SHIELD') and
            not bp.Economy.xpTimeStep and not BPUtilities.HasCatergory(bp, 'UNTARGETABLE') then
            bp.Economy.xpTimeStep = math.random(100, 120)
            bp.Economy.xpValue = bp.Economy.xpValue * econScaling
        end
        if bp.Categories and bp.Economy and
            (
            BPUtilities.HasCatergory(bp, 'CONSTRUCTION') or BPUtilities.HasCatergory(bp, 'ENGINEER') or
                BPUtilities.HasCatergory(bp, 'FACTORY') or BPUtilities.HasCatergory(bp, 'SILO') or bp.General.UpgradesTo
            ) and
            not BPUtilities.HasCatergory(bp, 'UNTARGETABLE') then
            bp.Economy.BuildXPLevelpSecond = 1
        end
    end
end
