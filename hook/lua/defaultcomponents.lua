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
        if blueprint.VetEnabled then
            self:SetStat('VetLevel', self:GetStat('VetLevel', 0).Value)
            self:SetStat('VetExperience', self:GetStat('VetExperience', 0).Value)
            self.VetExperience = 0
            self.VetLevel = 0
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
        local vetWorth = self:GetFractionComplete() * self:GetTotalMassCost()
        local vetDamage = self.VetDamage
        local vetInstigators = self.VetInstigators
        local vetDamageTaken = self.VetDamageTaken
        for id, unit in vetInstigators do
            if unit.Blueprint.VetEnabled and (not IsDestroyed(unit)) then
                local proportion = vetWorth * (vetDamage[id] / vetDamageTaken)
                unit:AddVetExperience(proportion)
            end
        end
    end,

    -- Adds experience to a unit
    ---@param self Unit | VeterancyComponent
    ---@param experience number
    ---@param noLimit boolean
    AddVetExperience = function(self, experience, noLimit)
        local blueprint = self.Blueprint
        if not blueprint.VetEnabled then
            return
        end

        local currExperience = self.VetExperience
        local currLevel = self.VetLevel

        -- case where we're at max vet: just add the experience and be done

        if currLevel > 4 then
            currExperience = currExperience + experience
            self.VetExperience = currExperience
            self:SetStat('VetExperience', currExperience)
            return
        end

        ---@type UnitBlueprint
        local vetThresholds = blueprint.VetThresholds
        local lowerThreshold = vetThresholds[currLevel] or 0
        local upperThreshold = vetThresholds[currLevel + 1]
        local diffThreshold = upperThreshold - lowerThreshold

        -- case where we have no limit (after gifting / spawning)
        if noLimit then

            currExperience = currExperience + experience
            self.VetExperience = currExperience
            self:SetStat('VetExperience', currExperience)

            while currLevel < 5 and upperThreshold and upperThreshold <= experience do
                self:AddVetLevel()
                currLevel = currLevel + 1
                upperThreshold = vetThresholds[currLevel + 1]
            end

            -- case where we do have a limit (usual gameplay approach)
        else
            if experience > diffThreshold then
                experience = diffThreshold
            end

            currExperience = currExperience + experience
            self.VetExperience = currExperience
            self:SetStat('VetExperience', currExperience)

            if upperThreshold <= currExperience then
                self:AddVetLevel()
            end
        end
    end,

    --- Adds a single level of veterancy
    ---@param self Unit | VeterancyComponent
    AddVetLevel = function(self)
        local blueprint = self.Blueprint
        if not blueprint.VetEnabled then
            return
        end

        local nextLevel = self.VetLevel + 1
        self.VetLevel = nextLevel
        self:SetStat('VetLevel', nextLevel)

        -- shared across all units
        Buff.ApplyBuff(self, 'VeterancyMaxHealth' .. nextLevel)

        -- unique to all units... but not quite
        local regenBuffName = self.UnitId .. 'VeterancyRegen' .. nextLevel
        if not Buffs[regenBuffName] then
            local techLevel = VeterancyToTech[blueprint.TechCategory] or 1
            if techLevel < 4 and EntityCategoryContains(categories.NAVAL, self) then
                techLevel = techLevel + 1
            end

            BuffBlueprint {
                Name = regenBuffName,
                DisplayName = regenBuffName,
                BuffType = 'VeterancyRegen',
                Stacks = 'REPLACE',
                Duration = -1,
                Affects = {
                    Regen = {
                        Add = VeterancyRegenBuffs[techLevel][nextLevel],
                    },
                },
            }
        end

        Buff.ApplyBuff(self, regenBuffName)

        -- one time health injection

        local maxHealth = blueprint.Defense.MaxHealth
        local mult = blueprint.VeteranHealingMult[nextLevel] or 0.1
        self:AdjustHealth(self, maxHealth * mult)

        -- callbacks

        self:DoUnitCallbacks('OnVeteran')
        self.Brain:OnBrainUnitVeterancyLevel(self, nextLevel)
    end,

    ---@param self Unit | VeterancyComponent
    ---@param level number
    SetVeterancy = function(self, level)
        self.VetExperience = 0
        self.VetLevel = 0
        self:AddVetExperience(self.Blueprint.VetThresholds[MathMin(level or 0, 5)] or 0, true)
    end,

    ---@param self Unit | VeterancyComponent
    ---@param massKilled number
    ---@param noLimit boolean
    CalculateVeterancyLevelAfterTransfer = function(self, massKilled, noLimit)
        self.VetExperience = 0
        self.VetLevel = 0
        self:AddVetExperience(massKilled, noLimit)
    end,

    ---@param self Unit | VeterancyComponent
    ---@param instigator Unit
    OnKilledUnit = function(self, unitThatIsDying, experience)
        if not experience then
            return
        end

        if not IsDestroyed(unitThatIsDying) then
            local vetWorth = unitThatIsDying:GetFractionComplete() * unitThatIsDying:GetTotalMassCost()
            self:AddVetExperience(vetWorth, false)
        end
    end,

    -- kept for backwards compatibility with mods, but should really not be used anymore

    ---@deprecated
    ---@param self Unit | VeterancyComponent
    ---@param massKilled number
    ---@param noLimit boolean
    CalculateVeterancyLevel = function(self, massKilled, noLimit)
        self.VetExperience = 0
        self.VetLevel = 0
        self:AddVetExperience(massKilled, noLimit)
    end,

    ---@see AddVetLevel
    ---@deprecated
    ---@param self Unit | VeterancyComponent
    ---@param level number
    SetVeteranLevel = function(self, level)
        self.VetExperience = 0
        self.VetLevel = 0
        self:AddVetExperience(self.Blueprint.VetThresholds[MathMin(level, 5)] or 0, true)
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
