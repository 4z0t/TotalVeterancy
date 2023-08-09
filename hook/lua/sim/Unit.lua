local EntityCategoryContains = EntityCategoryContains

--AR : AutoRevive

local ScenarioInfo = ScenarioInfo
local AutoReviveRedir1 = function(self, other, firingWeapon)
    if EntityCategoryContains(categories.PROJECTILE, other) and IsEnemy(self:GetArmy(), other:GetArmy()) then
        if not other.red then
            self.Enemy = other:GetLauncher()
            self.Enemyproj = other
            if self.Enemy then
                local otposx, otposy, otposz = other:GetPositionXYZ()
                local protposx, protposy, protposz = self.Enemy:GetPositionXYZ()
                local function pm()
                    local pm = Random(-2, 1)
                    if pm == 0 then
                        pm = 2
                    end
                    return pm
                end

                local function rndg()
                    return (Random(3, 6) * Random() * pm())
                end

                other.red = (other.red or 0) + 1
                other.DamageData.CollideFriendly = true
                other.DamageData.DamageFriendly = true
                other.DamageData.DamageSelf = true
                other:TrackTarget(true)
                other:SetTurnRate(720)
                other:SetLifetime(2.2)
                other:SetMaxSpeed(0)
                other:SetPosition({ otposx, otposy + 5, otposz }, false)
                other:SetNewTargetGround({ protposx + rndg(), protposy - 1, protposz + rndg() })
                other:SetVelocity(60):SetAcceleration(30):SetMaxSpeed(100)
                return false
            end
        end
        return false
    end
    return false
end
local ard1 = AutoReviveRedir1
AutoReviveRedir3 = function(self, other, firingWeapon)
    if EntityCategoryContains(categories.PROJECTILE, other) and IsEnemy(self:GetArmy(), other:GetArmy()) then
        if not other.red then
            self.Enemy = other:GetLauncher()
            self.Enemyproj = other
            if self.Enemy then
                local otposx, otposy, otposz = other:GetPositionXYZ()
                other.red = (other.red or 0) + 1
                other.DamageData.CollideFriendly = true
                other.DamageData.DamageFriendly = true
                other.DamageData.DamageSelf = true
                if other.DamageData.DamageRadius < 2 then
                    other.DamageData.DamageRadius = 2
                end
                other:TrackTarget(true)
                other:SetTurnRate(720)
                other:SetLifetime(2.2)
                other:SetPosition({ otposx, otposy + 30, otposz }, true)
                other:SetNewTarget(self.Enemy)
                other:SetAcceleration(160)
                return false
            end
            return false
        end
    end
    return false
end
local ard3 = AutoReviveRedir3
local PostAutoreviveRedir1 = function(self, other, firingWeapon)
    if EntityCategoryContains(categories.PROJECTILE, other) and IsEnemy(self:GetArmy(), other:GetArmy()) then
        if not other.red then
            self.Enemy = other:GetLauncher()
            self.Enemyproj = other
            if self.Enemy and self.Owner then
                other.red = (other.red or 0) + 1
                local otposx, otposy, otposz = other:GetPositionXYZ()
                local quickfix = other:GetCurrentTargetPosition()
                if quickfix == nil then
                    return false
                end
                local protposx, protposy, protposz = unpack(quickfix)
                unpack(other:GetCurrentTargetPosition())
                quickfix = self.Owner:GetCollisionExtents().Max
                if quickfix == nil then
                    return false
                end
                local w, h, l = unpack(quickfix)
                local function pm()
                    local pm = Random(-2, 1)
                    if pm == 0 then
                        pm = 2
                    end
                    return pm
                end

                local function rndg()
                    return (Random(3, 6) * Random() * pm())
                end

                other:SetLifetime(2)
                other.DamageData.CollideFriendly = true
                other.DamageData.DamageFriendly = true
                other.DamageData.DamageSelf = true
                other.DamageData.DamageRadius = 0.01
                local r1, r2 = rndg(), rndg()
                w, h, l = w * r1, h * 5, l * r2
                other:SetMaxSpeed(65)
                other:TrackTarget(true)
                other:SetTurnRate(90)
                other:SetNewTargetGround({ protposx - w, h, protposz - l })
                other.delay = ForkThread(function() WaitTicks(4)
                    if other and not other:BeenDestroyed() then
                        other:SetTurnRate(360)
                        local vdx, vdy, vdz = other:GetPositionXYZ()
                        local vdix, vdiy, vdiz = unpack((
                            VDiff({ otposx, otposy, otposz }, other:GetPosition()) or { 0, 0, 0 }))
                        other:SetNewTargetGround({ 0 + vdx - vdix + w, -400 - h * 5 + vdy - vdiy, vdz - vdiz + l })
                        WaitTicks(2)
                        if other and not other:BeenDestroyed() then
                            other:TrackTarget(false)
                            other:SetTurnRate(0)
                        end
                    end
                end)
                other.Trash:Add(other.delay)
            end
            return false
        end
    end
    return false
end
local prd1 = PostAutoreviveRedir1
local nn = function()
    return false
end

local AutoRevive = function(self, instigator, type, overkillRatio)
    local brain = GetArmyBrain(self:GetArmy())

    if not (self.Revive > 0 and not brain:IsDefeated() and ScenarioInfo.Options.AutoRevive == "true") then
        return
    end

    local bp = self:GetBlueprint()
    local unitEnhancements = import('/lua/enhancementcommon.lua').GetEnhancements(self:GetEntityId())
    local where = self:GetPosition()
    local revivee = CreateUnitHPR(self:GetUnitId(), self:GetArmy(), where[1], where[2], where[3], 0, 0, 0)
    revivee:SetCanBeKilled(false)
    revivee:SetCanTakeDamage(false)
    revivee:SetFireState(1)
    if unitEnhancements then
        for k, v in unitEnhancements do
            if bp.Enhancements[v].Prerequisite ~= nil then
                local recin = {}
                local rec = v
                local int = 1
                while bp.Enhancements[rec].Prerequisite ~= nil do
                    recin[int] = bp.Enhancements[rec].Prerequisite
                    int = int + 1
                    rec = bp.Enhancements[rec].Prerequisite
                end
                local size = table.getsize(recin) or 1
                for i = size, 1, -1 do
                    revivee:CreateEnhancement(recin[i])
                end
            end
            revivee:CreateEnhancement(v)
        end
    end
    local lvl = math.floor(self.VetLevel) - 10
    if ScenarioInfo.ALLies == false then
        local cost = bp.Economy
        local massx, energyx = (-cost.BuildCostMass * lvl * 0.1), (-cost.BuildCostEnergy * lvl * .1)
        SetArmyEconomy(revivee:GetArmy(), massx, energyx)
    end
    revivee:AddLevels(lvl)
    revivee:SetHealth(nil, 1)
    local reviveelvl = revivee.VetLevel
    local br = revivee:GetBuildRate()
    local brRatio = reviveelvl / br
    revivee:SetBuildRate(0)
    revivee.Revive = self.Revive - 1
    revivee.Sync.Revive = revivee.Revive
    local id = revivee:GetEntityId()
    ForkThread(function()
        local army = revivee:GetArmy()
        local function cee(X)
            return CreateEmitterOnEntity(revivee, army, '/effects/emitters/' .. X .. '_emit.bp')
        end

        local function vfx(VFX, bag)
            for k, v in VFX do
                local f = cee(v)
                revivee.Trash:Add(f)
                table.insert(bag, f)
            end
        end

        local function clfx(bag)
            for k, v in bag do
                v:Destroy()
                v = nil
            end
        end

        local rbp = revivee:GetBlueprint()
        revivee.Vetredirector = import('/lua/defaultantiprojectile.lua').Flare {
            Owner =
            revivee,
            Radius = 5,
            Category = 'PROJECTILE',
        }
        revivee.Trash:Add(revivee.Vetredirector)
        local timer = self.VetLevel * 10
        local redc = ard1
        revivee.rf = {}
        local rfx = { 'fire' }
        vfx(rfx, revivee.rf)
        if timer > 1490 then
            redc = ard3
        end
        if ScenarioInfo.ALLies == false then
            redc = prd1
        end
        revivee.Vetredirector.OnCollisionCheck = redc
        if ScenarioInfo.ALLies == false then
            revivee.Vetredirector:SetCollisionShape('Box', 0, 0, 0, 12, 200, 12)
        end
        if timer > 600 then
            timer = 600
            if ScenarioInfo.ALLies == false then
                timer = 200
            end
        end
        local name = ''
        if brain.Nickname then
            name = brain.Nickname
        end
        PrintText(name ..
            "'s Elite " .. LOC(rbp.Description) .. " revived at Level " .. math.floor(revivee.VetLevel) .. ' !!'
            , 20, 'FFFF0000', 10, 'center')
        PrintText("It'll be Invincible for " .. math.floor(timer * 0.1) .. ' seconds !!', 10, 'FFFF0000', 5, 'center')
        for i = timer, 1, -1 do
            if not revivee:IsDead() then
                if math.mod(i, 10) == 0 then
                    FloatingEntityText(id, i * 0.1)
                end
                revivee:SetFireState(1)
                if math.mod(i, 100) == 0 then
                    vfx(rfx, revivee.rf)
                end
                WaitTicks(1)
            end
        end
        if revivee:IsDead() then
            return
        end
        revivee:SetCanBeKilled(true)
        revivee:SetCanTakeDamage(true)
        revivee:SetBuildRate(br)
        revivee:SetFireState(0)
        revivee.Vetredirector.OnCollisionCheck = prd1
        revivee.Vetredirector:SetCollisionShape('Box', 0, 0, 0, 12, 200, 12)
        local redir2 = 180
        clfx(revivee.rf)
        local rfx = { '_test_swirl_01' }
        vfx(rfx, revivee.rf)
        if ScenarioInfo.ALLies == false then
            redir2 = 2
        end
        for i = redir2, 1, -1 do
            if not revivee:IsDead() then
                FloatingEntityText(id, i)
                WaitTicks(10)
            end
        end
        if not revivee:IsDead() then
            clfx(revivee.rf)
            revivee.Vetredirector.OnCollisionCheck = nn
            revivee.Vetredirector:SetCollisionShape('None')
            revivee.Vetredirector:Destroy()
            revivee.Vetredirector = nil
        end
    end)
end


local mstbuff = Buffs.VeterancyStorageBuff.Affects.MassStorageBuf.Mult or 1 - 1
local estbuff = Buffs.VeterancyStorageBuff.Affects.EnergyStorageBuf.Mult or 1 - 1
local s = ScenarioInfo
local StorageBuffs = function(self, instigator, type, overkillRatio)
    local bp = self:GetBlueprint()
    local brain = GetArmyBrain(self:GetArmy())
    if bp.Economy.StorageEnergy and self.VetLevel > 1 then
        brain.StorageEnergyTotal = brain.StorageEnergyTotal -
            bp.Economy.StorageEnergy * estbuff * (self.VetLevel - 1)
        brain:GiveStorage("ENERGY", brain.StorageEnergyTotal)
    end
    if bp.Economy.StorageMass and self.VetLevel > 1 then
        brain.StorageMassTotal = brain.StorageMassTotal - bp.Economy.StorageMass * mstbuff * (self.VetLevel - 1)
        brain:GiveStorage("MASS", brain.StorageMassTotal)
    end
end
local GetEnemies = function(self, instigator)
    local eAm = {}
    local ps = self:GetPosition()
    local rn = (VDist3(ps, instigator:GetPosition())) * 1.4
    local units = GetUnitsInRect(ps[1] - rn, ps[3] - rn, ps[1] + rn, ps[3] + rn)
    local selA = self:GetArmy()
    for k, y in units do
        if IsAlly(selA, y:GetArmy()) then
            continue
        end
        table.insert(eAm, y)
    end
    return eAm
end

local Buff = import('/lua/sim/buff.lua')
local ScenarioInfo = ScenarioInfo
local XPGAINMult = tonumber(ScenarioInfo.Options.XPGainMult or '1.0') or 1

local oldUnit = Unit
Unit = Class(oldUnit) {
    OnCreate = function(self)
        oldUnit.OnCreate(self)
        local bp = self:GetBlueprint()
        local brain = GetArmyBrain(self:GetArmy())

        if EntityCategoryContains(categories.COMMAND, self) then
            local ecoThread = ForkThread(function()
                WaitSeconds(1.8)
                SetArmyEconomy(self:GetArmy(), 0, 5000)
            end)
            self.Trash:Add(ecoThread)
        end
        if ScenarioInfo.AItoggle and self.BuildXPLevelpSecond and brain.BrainType ~= "Human" then
            self.vetToggle = 4
        end

    end,
    OnStartBeingBuilt = function(self, builder, layer)
        if builder.LevelProgress and builder.LevelProgress > 5 and builder.vetToggle and builder.vetToggle > 0 and
            not self:GetBlueprint().Economy.vetBuild then
            local bp = self:GetBlueprint().Economy
            bp.vetBuild = (builder.LevelProgress - 1) * builder.vetToggle
            self.Sync.vetBuild = bp.vetBuild
        end
        oldUnit.OnStartBeingBuilt(self, builder, layer)
    end,
    OnStopBeingBuilt = function(self, builder, layer)
        if self:GetBlueprint().Economy.xpTimeStep and
            EntityCategoryContains(categories.ENERGYPRODUCTION + categories.MASSSTORAGE + categories.ENERGYSTORAGE, self) then
            self:ForkThread(self.XPOverTime)
        end
        oldUnit.OnStopBeingBuilt(self, builder, layer)
        if not self.XPosbb then
            self.XPosbb = ForkThread(self.OnStopBeingBuiltXP, self)
            self.Trash:Add(self.XPosbb)
        end
    end,
    OnStopBeingBuiltXP = function(self)
        local bp = self:GetBlueprint().Economy
        if bp.vetBuild and bp.vetBuild > 1 then
            self:AddLevels(bp.vetBuild * 0.05)
            bp.vetBuild = nil
            self.Sync.vetBuild = 0
        end
        local brain = GetArmyBrain(self:GetArmy())
        WaitTicks(9)
        self.XPosbb:Destroy()
        self.XPosbb = nil
    end,
    OnStopBuild = function(self, unitBeingBuilt)
        local sbp = self:GetBlueprint()
        if unitBeingBuilt and
            not unitBeingBuilt:IsDead() and
            sbp.Economy.xpValue and
            sbp.Economy.xpValue > 0 and
            sbp.Economy.BuildXPLevelpSecond and
            sbp.Economy.BuildXPLevelpSecond > 0 and
            unitBeingBuilt.XPosbb
        then
            local bp = unitBeingBuilt:GetBlueprint().Economy
            if bp.xpValue and bp.xpValue > 0 then
                local vetmult = 1
                if unitBeingBuilt.LevelProgress > 1 then
                    vetmult = vetmult + (unitBeingBuilt.LevelProgress - 1) * 0.2
                end
                self:AddXP(bp.xpValue * 0.25 * vetmult)
            end
        end
        oldUnit.OnStopBuild(self, unitBeingBuilt)
    end,
    WorkingState = State {
        OnWorkEnd = function(self, work)
            local enhBp = self:GetBlueprint().Enhancements[work]
            local enhxp = math.pow(enhBp.BuildCostMass + enhBp.BuildCostEnergy * 0.1 + enhBp.BuildTime * 0.04, 0.5)
            local mult = self.LevelProgress - 0.9999
            if ScenarioInfo.ALLies == false then
                mult = 0

                self.enhcnt = (self.enhcnt or 0) + 1

                if self.enhcnt > 25 then
                    oldUnit.WorkingState.OnWorkEnd(self, work)
                    return
                end
                if self.LevelProgress > 26 then
                    mult = math.max(-0.2 * self.VetLevel, -24)
                end
            end
            enhxp = enhxp * (100 + (4 * (mult))) * .01
            self:AddXP(enhxp)
            oldUnit.WorkingState.OnWorkEnd(self, work)
        end,
    },
    SetMaintenanceConsumptionActive = function(self)
        if self.XPOverTimeThread then
            KillThread(self.XPOverTimeThread)
        end
        self.XPOverTimeThread = ForkThread(self.XPOverTime, self)
        self.Trash:Add(self.XPOverTimeThread)
        oldUnit.SetMaintenanceConsumptionActive(self)
    end,
    XPOverTime = function(self)
        if not self:GetBlueprint().Economy.xpTimeStep then
            return
        end
        if self:GetBlueprint().Economy.xpTimeStep <= 0 then
            return
        end

        local waittime = self:GetBlueprint().Economy.xpTimeStep * 0.5
        local step = 0.75

        if ScenarioInfo.ALLies == false then
            step = 0.34
        end

        WaitSeconds(waittime)

        while not self:IsDead() and (self.MaintenanceConsumption or
            EntityCategoryContains(categories.ENERGYPRODUCTION + categories.MASSSTORAGE + categories.ENERGYSTORAGE,
                self)) do
            self:AddXP(self.XPnextLevel * step)
            WaitSeconds(waittime)
        end
    end,
    StartBuildXPThread = function(self)
        local levelPerSecond = self:GetBlueprint().Economy.BuildXPLevelpSecond
        if not levelPerSecond then
            return
        end
        if levelPerSecond <= 0 then
            return
        end

        WaitTicks(2)

        if not self:IsDead() and self.ActiveConsumption then
            self:AddXP(self.XPnextLevel * levelPerSecond * 0.017)
        else
            return
        end

        WaitTicks(10)

        if not self:IsDead() and self.ActiveConsumption then
            self:AddXP(self.XPnextLevel * levelPerSecond * 0.017)
        else
            return
        end

        WaitTicks(10)

        while not self:IsDead() and self.ActiveConsumption do
            self:AddXP(self.XPnextLevel * levelPerSecond * 0.05)
            WaitTicks(30)
        end
    end,

    SetActiveConsumptionActive = function(self)
        if ScenarioInfo.ALLies ~= false then
            if self.BuildXPThread then
                KillThread(self.BuildXPThread)
            end
            self.BuildXPThread = ForkThread(self.StartBuildXPThread, self)
            self.Trash:Add(self.BuildXPThread)
        end
        oldUnit.SetActiveConsumptionActive(self)
    end,

    StartSiloXPThread = function(self)
        local levelPerSecond = self:GetBlueprint().Economy.BuildXPLevelpSecond
        if not levelPerSecond then
            return
        end
        if levelPerSecond <= 0 then
            return
        end
        WaitTicks(2)
        if not self:IsDead() and self:IsUnitState("SiloBuildingAmmo") then
            self:AddXP(self.XPnextLevel * levelPerSecond * 0.016)
        else
            return
        end
        WaitTicks(10)
        if not self:IsDead() and self:IsUnitState("SiloBuildingAmmo") then
            self:AddXP(self.XPnextLevel * levelPerSecond * 0.016)
        else
            return
        end
        WaitTicks(10)
        if not self:IsDead() and self:IsUnitState("SiloBuildingAmmo") then
            self:AddXP(self.XPnextLevel * levelPerSecond * 0.016)
        else
            return
        end
        WaitTicks(10)
        while not self:IsDead() and self:IsUnitState("SiloBuildingAmmo") do
            self:AddXP(self.XPnextLevel * levelPerSecond * 0.05)
            WaitTicks(60)
        end
    end,

    OnSiloBuildStart = function(self, weapon)
        if self.SiloXPThread then
            KillThread(self.SiloXPThread)
        end
        self.SiloXPThread = ForkThread(self.StartSiloXPThread, self)
        self.Trash:Add(self.SiloXPThread)
        oldUnit.OnSiloBuildStart(self, weapon)
    end,

    ---@param self Unit
    ---@param time any
    PlayVeteranFx = function(self, time)
        if self.disableSFX == true then
            return
        end
        time = time or 1
        CreateAttachedEmitter(self, 0, self.Army, '/effects/emitters/destruction_explosion_concussion_ring_01_emit.bp')
            :ScaleEmitter(time)
    end,

    CreateUnitBuff = function(self, levelName, buffType, buffValues)
        local buffName = self:GetUnitId() .. levelName .. buffType
        local buffMinLevel = nil
        local buffMaxLevel = nil
        if buffValues.MinLevel then
            buffMinLevel = buffValues.MinLevel
        end
        if buffValues.MaxLevel then
            buffMaxLevel = buffValues.MaxLevel
        end
        if not Buffs[buffName] then
            BuffBlueprint {
                MinLevel = buffMinLevel,
                MaxLevel = buffMaxLevel,
                Name = buffName,
                DisplayName = buffName,
                BuffType = buffType,
                Stacks = buffValues.Stacks,
                Duration = buffValues.Duration,
                Affects = buffValues.Affects,
            }
        end
        return buffName
    end,

    UpdateProductionValues = function(self)
        local bpEcon = self:GetBlueprint().Economy
        if not bpEcon then
            return
        end
        self:SetProductionPerSecondEnergy((self.EnergyProdMod or bpEcon.ProductionPerSecondEnergy or 0) *
            (self.EnergyProdAdjMod or 1))
        self:SetProductionPerSecondMass((self.MassProdMod or bpEcon.ProductionPerSecondMass or 0) *
            (self.MassProdAdjMod or 1))
    end,

    AddXP = function(self, amount)
        self:AddVetExperience(amount)
    end,

    ---@param self Unit
    ---@param instigator Unit
    ---@param type any
    ---@param overkillRatio any
    OnKilled = function(self, instigator, type, overkillRatio)
        StorageBuffs(self, instigator, type, overkillRatio)
        AutoRevive(self, instigator, type, overkillRatio)
        oldUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    CreateShield = function(self, shieldSpec)
        oldUnit.CreateShield(self, shieldSpec)
        Buff.BuffAffectUnit(self, 'VeterancyShield', self, true)
    end,

    CreatePersonalShield = function(self, shieldSpec)
        oldUnit.CreatePersonalShield(self, shieldSpec)
        Buff.BuffAffectUnit(self, 'VeterancyShield', self, true)
    end,

    ---@param self Unit
    ---@param teleporter any
    ---@param location any
    ---@param orientation any
    InitiateTeleportThread = function(self, teleporter, location, orientation)
        self.UnitBeingTeleported = self
        self:SetImmobile(true)
        self:PlayUnitSound('TeleportStart')
        self:PlayUnitAmbientSound('TeleportLoop')


        local bp = self.Blueprint
        local teleDelay = bp.General.TeleportDelay

        local bpEco = bp.Economy
        if not bpEco then
            return
        end

        local energyCost, time

        local mass = bpEco.BuildCostMass * (bpEco.TeleportMassMod or 0.01)
        local energy = bpEco.BuildCostEnergy * (bpEco.TeleportEnergyMod or 0.01)
        energyCost = mass + energy
        time = energyCost * (bpEco.TeleportTimeMod or 0.01)

        if teleDelay then
            energyCostMod = (time + teleDelay) / time
            time = time + teleDelay
            energyCost = energyCost * energyCostMod

            self.TeleportDestChargeBag = nil
            self.TeleportCybranSphere = nil -- this fixes some "...Game object has been destroyed" bugs in EffectUtilities.lua:TeleportChargingProgress
        end

        if not ScenarioInfo.Allies then
            if EntityCategoryContains(categories.COMMAND, self) then
                time = math.max(time - self.VetLevel * 0.2, 6)
            elseif EntityCategoryContains(categories.SUBCOMMANDER, self) then
                time = math.max(time - self.VetLevel * 0.4, 10)
            else
                time = math.max(time - self.VetLevel, 15)
            end
        else
            if EntityCategoryContains(categories.COMMAND, self) then
                time = math.max(time - self.VetLevel * 0.5, 0.1)
            elseif EntityCategoryContains(categories.SUBCOMMANDER, self) then
                time = math.max(time - self.VetLevel, 0.2)
            else
                time = math.max(time - self.VetLevel, 1)
            end
        end


        self.TeleportDrain = CreateEconomyEvent(self, energyCost or 100, 0, time or 5, self.UpdateTeleportProgress)
        -- Create teleport charge effect
        self:PlayTeleportChargeEffects(location, orientation)
        WaitFor(self.TeleportDrain)

        if self.TeleportDrain then
            RemoveEconomyEvent(self, self.TeleportDrain)
            self.TeleportDrain = nil
        end

        self:PlayTeleportOutEffects()
        self:CleanupTeleportChargeEffects()
        WaitSeconds(0.1)

        -- prevent cheats (teleporting after transport, teleporting without having the enhancement)
        if self:IsUnitState('Teleporting') and self:TestCommandCaps('RULEUCC_Teleport') then
            Warp(self, location, orientation)
            self:PlayTeleportInEffects()
        else
            IssueClearCommands { self }
        end

        self:SetWorkProgress(0.0)
        self:CleanupRemainingTeleportChargeEffects()

        -- Perform cooldown Teleportation FX here
        WaitSeconds(0.1)

        -- Landing Sound
        self:StopUnitAmbientSound('TeleportLoop')
        self:PlayUnitSound('TeleportEnd')
        self:SetImmobile(false)
        self.UnitBeingTeleported = nil
        self.TeleportThread = nil

    end,

    GetShield = function(self)
        return self.MyShield or nil
    end,

    EnableUnitIntel = function(self, disabler, intel)
        if intel and intel == 'Cloak' then
            if not self.dnt then
                self:SetDoNotTarget(true)
                self.dnt = ForkThread(function()
                    WaitTicks(1)
                    self:SetDoNotTarget(false)
                    self.dnt:Destroy()
                    self.dnt = nil
                end)
                self.Trash:Add(self.dnt)
            end
        end
        oldUnit.EnableUnitIntel(self, disabler, intel)
    end,

    GetHealthPercent = function(self)
        local health = self:GetHealth()
        local maxHealth = self:GetMaxHealth()
        return health / maxHealth
    end,
}
