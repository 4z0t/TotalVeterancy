local MathMin = math.min

local Buff = import('/lua/sim/buff.lua')
local mstbuff = Buffs.VeterancyStorageBuff.Affects.MassStorageBuf.Mult or 1 - 1
local estbuff = Buffs.VeterancyStorageBuff.Affects.EnergyStorageBuf.Mult or 1 - 1
local ScenarioInfo = ScenarioInfo

local XPGAINMult = tonumber(ScenarioInfo.Options.XPGainMult or '1.0') or 1
LOG("XP Gain mult " .. XPGAINMult)

local _VeterancyComponent = VeterancyComponent
VeterancyComponent = Class(_VeterancyComponent)
{
    ---@param self VeterancyComponent | Unit
    OnCreate = function(self)
        local blueprint = self.Blueprint

        -- these fields are always required
        self.VetDamageTaken = 0
        self.VetDamage = {}
        self.VetInstigators = setmetatable({}, { __mode = 'v' })

        -- optionally, these fields are defined too to inform UI of our veterancy status
        if blueprint.Economy.XPperLevel then
            self:GetStat('VetLevel', 0)
            self:GetStat('VetExperience', 0)
            self:GetStat('LevelProgress', 0)
            self:GetStat('XPnextLevel', 0)
            self.XPnextLevel = blueprint.Economy.XPperLevel
            self.VetExperience = 0
            self.VetLevel = 1
            self.LevelProgress = 1
            self:SetStat('XPnextLevel', self.XPnextLevel)
            self:SetStat('VetLevel', self.VetLevel)
            self:SetStat('VetExperience', self.VetExperience)
            self:SetStat('LevelProgress', self.LevelProgress)
        end
    end,

    ---@param self VeterancyComponent | Unit
    ---@param instigator Unit
    ---@param amount number
    ---@param vector Vector
    ---@param damageType DamageType
    DoTakeDamage = function(self, instigator, amount, vector, damageType)
        amount = MathMin(amount, self:GetMaxHealth())
        self.VetDamageTaken = self.VetDamageTaken + amount
        if instigator and instigator.IsUnit and not IsDestroyed(instigator) then
            local entityId = instigator.EntityId
            local vetInstigators = self.VetInstigators
            local vetDamage = self.VetDamage

            vetInstigators[entityId] = instigator
            vetDamage[entityId] = (vetDamage[entityId] or 0) + amount
        end
    end,

    --- Disperses the veterancy, expects to be only called once
    ---@param self VeterancyComponent | Unit
    VeterancyDispersal = function(self)
        local bp = self.Blueprint
        if not bp.Economy.xpValue then
            return
        end
        local vetWorth = self:GetFractionComplete() * self:GetTotalMassCost()
        local vetDamage = self.VetDamage
        local vetInstigators = self.VetInstigators
        local vetDamageTaken = self.VetDamageTaken

        local xp = bp.Economy.xpValue * self.VetLevel * 0.25 * self:GetFractionComplete()

        for id, unit in vetInstigators do
            if not IsDestroyed(unit) then
                local proportion = xp * (vetDamage[id] / vetDamageTaken)
                unit:AddVetExperience(proportion)
            end
        end
    end,

    -- Adds experience to a unit
    ---@param self Unit | VeterancyComponent
    ---@param experience number
    ---@param noLimit boolean?
    AddVetExperience = function(self, experience, noLimit)
        local blueprint = self.Blueprint
        if not self.XPnextLevel then
            return
        end
        if experience <= 0 then
            return
        end

        self.VetExperience = self.VetExperience + experience * XPGAINMult
        self:CheckVetLevel()
    end,


    ---@param self Unit | VeterancyComponent
    CheckVetLevel = function(self)
        if not self.XPnextLevel then
            return
        end
        local bpe = self.Blueprint.Economy
        while self.VetExperience >= self.XPnextLevel do
            self.VetExperience = self.VetExperience - self.XPnextLevel
            self.XPnextLevel = bpe.XPperLevel * (1 + 0.1 * self.VetLevel)
            self:SetVetLevel(self.VetLevel + 1)
        end
        self:SetStat('VetExperience', self.VetExperience)
        self:SetStat('XPnextLevel', self.XPnextLevel)
        self.LevelProgress = self.VetExperience / self.XPnextLevel + self.VetLevel
        self:SetStat('LevelProgress', self.LevelProgress)
    end,

    --- Adds a single level of veterancy
    ---@param self Unit | VeterancyComponent
    AddVetLevel = function(self)
        return self:AddLevels(1)
    end,

    ---@param self Unit | VeterancyComponent
    AddLevels = function(self, levels)
        if levels <= 0 then
            return
        end
        local bp = self:GetBlueprint()
        local curlevel = self.VetLevel
        local percent = self.LevelProgress - curlevel
        local xpAdd = 0
        if levels >= (1 - percent) then
            xpAdd = self.XPnextLevel * (1 - percent)
            levels = levels - (1 - percent)
        else
            xpAdd = self.XPnextLevel * levels
            levels = 0
        end
        while levels > 1 do
            levels = levels - 1
            curlevel = curlevel + 1
            xpAdd = xpAdd + bp.Economy.XPperLevel * (1 + 0.1 * curlevel)
        end
        xpAdd = xpAdd + bp.Economy.XPperLevel * (1 + 0.1 * (curlevel + 1)) * levels
        self:AddVetExperience(xpAdd)
    end,

    ---@param self Unit | VeterancyComponent
    ---@param level number
    SetVeterancy = function(self, level)
        self.VetExperience = 0
        self.VetLevel = 1
        self:SetVetLevel(level + 1)
    end,

    ---@param self Unit | VeterancyComponent
    ---@param massKilled number
    ---@param noLimit boolean
    CalculateVeterancyLevelAfterTransfer = function(self, massKilled, noLimit)
        self.VetExperience = 0
        self.VetLevel = 1
        self:AddVetExperience(massKilled, noLimit)
    end,

    ---@param self Unit | VeterancyComponent
    ---@param unitThatIsDying Unit
    OnKilledUnit = function(self, unitThatIsDying, experience)
        if not experience then
            return
        end

        if not IsDestroyed(unitThatIsDying) then
            local vetWorth = unitThatIsDying:GetFractionComplete() * unitThatIsDying:GetTotalMassCost()
            self:AddVetExperience(experience, false)
        end
    end,


    ---@param self Unit | VeterancyComponent
    ---@param massKilled number
    ---@param noLimit boolean
    CalculateVeterancyLevel = function(self, massKilled, noLimit)
        self.VetExperience = 0
        self.VetLevel = 1
        self:AddVetExperience(massKilled, noLimit)
    end,

    ---@param self Unit | VeterancyComponent
    ---@param level number
    SetVetLevel = function(self, level)
        local bapb = Buff.ApplyBuff
        local mod = math.mod
        self.VetLevel = level
        self:SetStat('VetLevel', self.VetLevel)
        bapb(self, 'VeterancyHealthRegen')
        bapb(self, 'VeterancyVision')
        local bp = self:GetBlueprint()
        local brain = GetArmyBrain(self:GetArmy())
        local gotweapon = false
        if bp.Weapon then
            for k, v in bp.Weapon do
                if v.Label ~= 'DeathWeapon' then
                    bapb(self, 'VeterancyDamageRoF')
                    bapb(self, 'VeterancyDamageArea')
                    bapb(self, 'VeterancyRange')
                    gotweapon = true
                    break
                end
            end
        end
        if EntityCategoryContains(categories.MOBILE, self) and not EntityCategoryContains(categories.AIR, self) then
            bapb(self, 'VeterancySpeed')
        end
        if self:GetBuildRate() and self:GetBuildRate() > 2 then
            bapb(self, 'VeterancyBuildRate')
        end
        if bp.Intel.RadarRadius and bp.Intel.RadarRadius > 0 then
            bapb(self, 'VeterancyRadar')
        end
        if bp.Intel.SonarRadius and bp.Intel.SonarRadius > 0 then
            bapb(self, 'VeterancySonar')
        end
        if bp.Intel.OmniRadius and bp.Intel.OmniRadius > 0 then
            bapb(self, 'VeterancyOmniRadius')
        end
        if (bp.Economy.ProductionPerSecondEnergy and bp.Economy.ProductionPerSecondEnergy > 0) or
            (bp.Economy.ProductionPerSecondMass and bp.Economy.ProductionPerSecondMass > 0) then
            bapb(self, 'VeterancyResourceProduction')
        end
        local gotShield = false
        if EntityCategoryContains(categories.COMMAND, self) or EntityCategoryContains(categories.SUBCOMMANDER, self) then
            bapb(self, 'VeterancyCommandProduction')
            bapb(self, 'VeterancySpeed2')
            if self.VetLevel == 101 then
                for i = 1, self:GetWeaponCount() do
                    local wep = self:GetWeapon(i)
                    local wepbp = wep:GetBlueprint()
                    if wep.Label ~= 'DeathWeapon' then
                        wep:SetFireTargetLayerCaps('Air|Land|Water|Seabed|Sub')
                        wepbp.FireTargetLayerCapsTable = {
                            Land = 'Air|Land|Water|Seabed|Sub',
                            Seabed = 'Air|Land|Water|Seabed|Sub',
                            Water = 'Air|Land|Water|Seabed|Sub',
                        }
                    end
                end
            end
            if not EntityCategoryContains(categories.CYBRAN, self) then
                gotShield = true
            end
        end
        if self:GetShield() or gotShield then
            bapb(self, 'VeterancyShield')
        end
        local bpb = self:GetBlueprint().Buffs
        if bpb then
            for bLevel, bData in bpb do
                if (bLevel == 'Any' or bLevel == 'Level' .. level) then
                    for bType, bValues in bData do
                        local buffName = self:CreateUnitBuff(bLevel, bType, bValues)
                        if buffName then
                            bapb(self, buffName)
                        end
                    end
                end
            end
        end
        if gotweapon then
            if level == 6 then
                self.pFx = ForkThread(self.PlayVeteranFx, self, 0.5)
            end
            self.Trash:Add(self.pFx)
            if mod(level, 10) == 1 then
                if self.pFx then
                    KillThread(self.pFx)
                end
                self.pFx = ForkThread(self.PlayVeteranFx, self, level * 0.1)
            end
            if mod(level, 25) == 1 then
                if EntityCategoryContains(categories.MOBILE - categories.AIR, self) then
                    if brain.BrainType == "Human" then
                        local revive = self.Revive or 0
                        local revadd = 1
                        if self.Revive > 2 and ScenarioInfo.ALLies == false then
                            revadd = 0
                        end
                        self.Revive = revive + revadd
                        self.Sync.Revive = self.Revive
                    end
                end
            end
        end
        if not brain.StorageEnergyTotal then
            brain.StorageEnergyTotal = 0
        end
        if not brain.StorageMassTotal then
            brain.StorageMassTotal = 0
        end
        if not brain.ME then
            brain.ME = "Mass"
        end
        if bp.Economy.StorageMass then
            brain.StorageMassTotal = brain.StorageMassTotal + (bp.Economy.StorageMass * mstbuff)
        end
        if bp.Economy.StorageEnergy then
            brain.StorageEnergyTotal = brain.StorageEnergyTotal + (bp.Economy.StorageEnergy * estbuff)
        end
        if brain.ME then
            if brain.ME == "Mass" then
                if brain.StorageMassTotal then
                    brain:GiveStorage("MASS", brain.StorageMassTotal)
                end
            elseif brain.ME == "Energy" then
                if brain.StorageEnergyTotal then
                    brain:GiveStorage("ENERGY", brain.StorageEnergyTotal)
                end
            else
                brain.ME = "Mass"
            end
            self:GetAIBrain():OnBrainUnitVeterancyLevel(self, level)
            self:DoUnitCallbacks('OnVeteran')
        end
    end,

    ---@deprecated
    ---@param self Unit | VeterancyComponent
    GetVeterancyValue = function(self)
        local fractionComplete = self:GetFractionComplete()
        local unitMass = self:GetTotalMassCost()
        local vetMult = self.Blueprint.VeteranImportanceMult or 1
        local cargoMass = self.cargoMass or 0
        -- Allow units to count for more or less than their real mass if needed
        return fractionComplete * unitMass * vetMult + cargoMass
    end,
}
