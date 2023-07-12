local oldShield = Shield
Shield = Class(oldShield) {
    InitBuffValues = function(self, spec)
        self.spec = spec
        spec.Owner.Sync.ShieldMaxHp = spec.ShieldMaxHealth
        spec.Owner.Sync.ShieldRegen = spec.ShieldRegenRate
    end,
    OnCreate = function(self, spec)
        self:InitBuffValues(spec)
        oldShield.OnCreate(self, spec)
        if EntityCategoryContains(categories.MOBILE * categories.SHIELD * categories.DEFENSE + categories.STRUCTURE -
            categories.UNSELECTABLE - categories.UNTARGETABLE - categories.INSIGNIFICANTUNIT, self.Owner) and
            self.Owner.XPnextLevel then
            self.XPonDamaged = ForkThread(self.XPonDamagedThread, self)
        end
    end,
    ChargingUp = function(self, curProgress, time)
        oldShield.ChargingUp(self, curProgress, time)
        if ScenarioInfo.ALLies then
            self:SetHealth(self, self:GetMaxHealth())
        end
    end,
    OnState = State {
        Main = function(self)
            if ScenarioInfo.Allies == false then
                if self.OffHealth >= 0 then
                    self.Owner:SetMaintenanceConsumptionActive()
                    self:ChargingUp(0, self.ShieldEnergyDrainRechargeTime)
                    if self:GetHealth() < self:GetMaxHealth() and self.RegenRate > 0 then
                        self.RegenThread = ForkThread(self.RegenStartThread, self)
                        self.Owner.Trash:Add(self.RegenThread)
                    end
                end
            end
            self.OffHealth = -1
            self:UpdateShieldRatio(-1)
            self.Owner:OnShieldEnabled()
            self:CreateShieldMesh()
            local aiBrain = self.Owner:GetAIBrain()
            WaitSeconds(1.0)
            local fraction = self.Owner:GetResourceConsumed()
            local on = true
            local test = false
            while on do
                WaitTicks(1)
                self:UpdateShieldRatio(-1)
                fraction = self.Owner:GetResourceConsumed()
                if fraction ~= 1 and aiBrain:GetEconomyStored('ENERGY') <= 0 then
                    if test then
                        on = false
                    else
                        test = true
                    end
                else
                    on = true
                    test = false
                end
            end
            ChangeState(self, self.EnergyDrainRechargeState)
        end,
        IsOn = function(self)
            return true
        end,
    },
    OffState = State {
        Main = function(self)
            if ScenarioInfo.Allies == false then
                if self.RegenThread then
                    KillThread(self.RegenThread)
                    self.RegenThread = nil
                end
            end
            self.OffHealth = -1
            if ScenarioInfo.ALLies == false then
                self.OffHealth = self:GetHealth()
            end
            self:UpdateShieldRatio(0)
            self:RemoveShield()
            self.Owner:OnShieldDisabled()
            WaitSeconds(1)
        end,
    },
    XPonDamagedThread = function(self)
        while self and self.Owner:IsDead() ~= true do
            if self:GetHealth() < self:GetMaxHealth() then
                self.Owner:AddXP(self.Owner.XPnextLevel * 0.1)
            end
            WaitTicks(40)
        end
    end,
}

--- A bubble shield attached to a single unit.
---@class PersonalBubble : Shield
PersonalBubble = ClassShield(Shield) {
    OnCreate = function(self, spec)
        Shield.OnCreate(self, spec)

        -- Store off useful values from the blueprint
        local OwnerBp = self.Owner.Blueprint or self.Owner:GetBlueprint()

        self.SizeX = OwnerBp.SizeX
        self.SizeY = OwnerBp.SizeY
        self.SizeZ = OwnerBp.SizeZ

        self.ShieldSize = spec.ShieldSize

        self.ShieldType = 'Personal'

        -- Manually disable the bubble shield's collision sphere after its creation so it acts like the new personal shields
        EntitySetCollisionShape(self, 'None')
    end,

    ApplyDamage = function(self, instigator, amount, vector, dmgType, doOverspill)
        -- We want all personal shields to pass overkill damage, including this one
        -- Was handled by self.PassOverkillDamage bp value, now defunct
        if self.Owner ~= instigator then
            local overkill = self:GetOverkill(instigator, amount, dmgType)
            if overkill > 0 and self.Owner and IsUnit(self.Owner)  then
                self.Owner:DoTakeDamage(instigator, overkill, vector, dmgType)
            end
        end

        Shield.ApplyDamage(self, instigator, amount, vector, dmgType, doOverspill)
    end,

    CreateShieldMesh = function(self)
        Shield.CreateShieldMesh(self)
        EntitySetCollisionShape(self, 'None')
    end,

    RemoveShield = function(self)
        Shield.RemoveShield(self)
        EntitySetCollisionShape(self, 'None')
    end,

    OnState = State(Shield.OnState) {
        Main = function(self)
            -- Set the collision profile of the unit to match the apparent shield sphere.
            -- Since the collision handler in Unit deals with personal shields, the damage will be
            -- passed to the shield.
            EntitySetCollisionShape(self.Owner, 'Sphere', 0, self.SizeY * 0.5, 0, self.ShieldSize * 0.5)
            Shield.OnState.Main(self)
        end
    },

    OffState = State(Shield.OffState) {
        Main = function(self)
            -- When the shield is down for some reason, reset the unit's collision profile so it can
            -- again be hit.
            UnitRevertCollisionShape(self.Owner)
            Shield.OffState.Main(self)
        end
    },

    RechargeState = State(Shield.RechargeState) {
        Main = function(self)
            UnitRevertCollisionShape(self.Owner)
            Shield.RechargeState.Main(self)
         end
    },
}

--- A personal bubble that can render a set of encompassed units invincible.
-- Useful for shielded transports (to work around the area-damage bug).
---@class TransportShield : Shield
TransportShield = ClassShield(Shield) {

    OnCreate = function(self, spec)
        Shield.OnCreate(self, spec)
        self.protectedUnits = {}
    end,

    -- toggle vulnerability of the transport and its content
    SetContentsVulnerable = function(self, canTakeDamage)
        for k, v in self.protectedUnits do
            k.CanTakeDamage = canTakeDamage
        end
    end,

    -- we try and forget this unit
    RemoveProtectedUnit = function(self, unit)
        self.protectedUnits[unit] = nil
        unit.CanTakeDamage = true
    end,

    -- we try and protect this unit
    AddProtectedUnit = function(self, unit)
        self.protectedUnits[unit] = true
    end,

    OnState = State(Shield.OnState) {
        Main = function(self)
            Shield.OnState.Main(self)

            -- prevent ourself and our content from taking damage
            self:SetContentsVulnerable(false)
            self.Owner.CanTakeDamage = false 
        end,

        AddProtectedUnit = function(self, unit)
            self.protectedUnits[unit] = true
            unit.CanTakeDamage = false
        end
    },

    OffState = State(Shield.OffState) {
        Main = function(self)
            Shield.OffState.Main(self)

            -- allow ourself and our content to take damage
            self:SetContentsVulnerable(true)
            self.Owner.CanTakeDamage = true 
        end,
    },

    DamageDrainedState = State(Shield.DamageDrainedState) {
        Main = function(self)
            Shield.DamageDrainedState.Main(self)

            -- allow ourself and our content to take damage
            self:SetContentsVulnerable(true)
            self.Owner.CanTakeDamage = true 
        end
    },

    EnergyDrainedState = State(Shield.EnergyDrainedState) {
        Main = function(self)
            Shield.EnergyDrainedState.Main(self)

            -- allow ourself and our content to take damage
            self:SetContentsVulnerable(true)
            self.Owner.CanTakeDamage = true 
        end
    },
}

--- A shield that sticks to the surface of the unit. Doesn't have its own collision physics, just
-- grants extra health.
---@class PersonalShield : Shield
PersonalShield = ClassShield(Shield){

    RemainEnabledWhenAttached = true,

    OnCreate = function(self, spec)
        Shield.OnCreate(self, spec)

        -- store information from spec
        self.CollisionSizeX = spec.CollisionSizeX or 1
        self.CollisionSizeY = spec.CollisionSizeY or 1
        self.CollisionSizeZ = spec.CollisionSizeZ or 1
        self.CollisionCenterX = spec.CollisionCenterX or 0
        self.CollisionCenterY = spec.CollisionCenterY or 0
        self.CollisionCenterZ = spec.CollisionCenterZ or 0
        self.OwnerShieldMesh = spec.OwnerShieldMesh or ''

        -- set our shield type
        self.ShieldType = 'Personal'

        -- cache our shield effect entity
        self.ShieldEffectEntity = Entity( self.ImpactEntitySpecs )
    end,

    ApplyDamage = function(self, instigator, amount, vector, dmgType, doOverspill)
        -- We want all personal shields to pass overkill damage
        -- Was handled by self.PassOverkillDamage bp value, now defunct
        if self.Owner ~= instigator then
            local overkill = self:GetOverkill(instigator, amount, dmgType)
            if overkill > 0 and self.Owner and IsUnit(self.Owner) then
                self.Owner:DoTakeDamage(instigator, overkill, vector, dmgType)
            end
        end

        Shield.ApplyDamage(self, instigator, amount, vector, dmgType, doOverspill)
    end,

    CreateImpactEffect = function(self, vector)

        if IsDestroyed(self) then
            return
        end

        -- keep track of this entity
        self.LiveImpactEntities = self.LiveImpactEntities + 1

        -- cache values
        local effect
        local army = self.Army
        local vc = VectorCached

        -- compute length of vector that points at the point of impact
        local x = vector[1]
        local y = vector[2]
        local z = vector[3]
        local d = MathSqrt(x * x + y * y + z * z)

        -- re-use previous entity as we have no mesh
        local entity = self.ShieldEffectEntity

        -- warp the entity
        vc[1], vc[2], vc[3] = EntityGetPositionXYZ(self)
        Warp(entity, vc)
        
        -- orientate it to orientate the effect
        vc[1], vc[2], vc[3] = -x, -y, -z
        EntitySetOrientation(entity, OrientFromDir(vc), true)

        -- create the effect
        for k, v in self.ImpactEffects do
            effect = CreateEmitterAtBone(entity, -1, army, v)
            IEffectOffsetEmitter(effect, 0, 0, d)
        end

        -- hold a bit to lower the number of allowed effects
        CoroutineYield(20)

        self.LiveImpactEntities = self.LiveImpactEntities - 1
    end,

    CreateShieldMesh = function(self)
        -- Personal shields (unit shields) don't handle collisions anymore.
        -- This is done in the Unit's OnDamage function instead.
        EntitySetCollisionShape(self, 'None')
        EntitySetMesh(self.Owner, self.OwnerShieldMesh, true)
    end,

    RemoveShield = function(self)
        EntitySetCollisionShape(self, 'None')
        EntitySetMesh(self.Owner, self.Owner.Blueprint.Display.MeshBlueprint, true)
    end,

    OnDestroy = function(self)
        if not self.Owner.MyShield or self.Owner.MyShield.EntityId == self.EntityId then
            EntitySetMesh(self.Owner, self.Owner.Blueprint.Display.MeshBlueprint, true)
        end
        self:UpdateShieldRatio(0)
        ChangeState(self, self.DeadState)
    end,

    ChargingUp = function(self, curProgress, time)
        Shield.ChargingUp(self, curProgress, time)
        if ScenarioInfo.ALLies then
            self:SetHealth(self, self:GetMaxHealth())
        end
    end,
}

---@class AntiArtilleryShield : Shield
AntiArtilleryShield = ClassShield(Shield) {
    OnCreate = function(self, spec)
        Shield.OnCreate(self, spec)
        self.ShieldType = 'AntiArtillery'
    end,

    OnCollisionCheckWeapon = function(self, firingWeapon)
        local bp = firingWeapon:GetBlueprint()
        if bp.CollideFriendly == false then
            if self.Army == firingWeapon.unit.Army then
                return false
            end
        end
        -- Check DNC list
        if bp.DoNotCollideList then
            for k, v in pairs(bp.DoNotCollideList) do
                if EntityCategoryContains(ParseEntityCategory(v), self) then
                    return false
                end
            end
        end
        if bp.ArtilleryShieldBlocks then
            return true
        end
        return false
    end,

    -- Return true to process this collision, false to ignore it.
    OnCollisionCheck = function(self, other)
        if other.Army == -1 then
            return false
        end

        if other:GetBlueprint().Physics.CollideFriendlyShield and other.DamageData.ArtilleryShieldBlocks then
            return true
        end

        if other.DamageData.ArtilleryShieldBlocks and IsEnemy(self.Army, other.Army) then
            return true
        end

        return false
    end,
}

-- Pretty much the same as personal shield (no collisions), but has its own mesh and special effects.
---@class CzarShield : PersonalShield
CzarShield = ClassShield(PersonalShield) {
    OnCreate = function(self, spec)
        PersonalShield.OnCreate(self, spec)

        self.ImpactMeshBp = spec.ImpactMesh
        self.ImpactMeshBigBp = spec.ImpactMeshBig
    end,


    CreateImpactEffect = function(self, vector)

        if IsDestroyed(self) then
            return
        end

        self.LiveImpactEntities = self.LiveImpactEntities + 1

        local army = self:GetArmy()
        local OffsetLength = Util.GetVectorLength(vector)
        local ImpactMesh = Entity ( self.ImpactEntitySpecs )
        local pos = self:GetPosition()

        -- Shield has non-standard form (ellipsoid) and no collision, so we need some magic to make impacts look good
        -- All impacts from above and below (>1 & <1) cause big pulses in the center of shield
        -- Projectiles that come from same elevation (ASF etc.) cause small pulses on the edge of shield using
        -- standard effect from static shields
        if vector.y > 1 then
            Warp(ImpactMesh, {pos[1], pos[2] + 9.5, pos[3]})

            ImpactMesh:SetMesh(self.ImpactMeshBigBp)
            ImpactMesh:SetDrawScale(self.Size)
            ImpactMesh:SetOrientation(OrientFromDir(Vector(0, -30, 0)), true)
        elseif vector.y < -1 then
            Warp(ImpactMesh, {pos[1], pos[2] - 9.5, pos[3]})

            ImpactMesh:SetMesh(self.ImpactMeshBigBp)
            ImpactMesh:SetDrawScale(self.Size)
            ImpactMesh:SetOrientation(OrientFromDir(Vector(0, 30, 0)), true)
        else
            Warp(ImpactMesh, {pos[1], pos[2], pos[3]})

            ImpactMesh:SetMesh(self.ImpactMeshBp)
            ImpactMesh:SetDrawScale(self.Size)
            ImpactMesh:SetOrientation(OrientFromDir(Vector(-vector.x, -vector.y, -vector.z)), true)
        end

        for _, v in self.ImpactEffects do
            CreateEmitterAtBone(ImpactMesh, -1, army, v):OffsetEmitter(0, 0, OffsetLength)
        end

        WaitSeconds(5)
        ImpactMesh:Destroy()
        self.LiveImpactEntities = self.LiveImpactEntities - 1
    end,

    CreateShieldMesh = function(self)
        -- Personal shields (unit shields) don't handle collisions anymore.
        -- This is done in the Unit's OnDamage function instead.
        self:SetCollisionShape('None')

        self:SetMesh(self.MeshBp)
        self:SetParentOffset(Vector(0, self.ShieldVerticalOffset, 0))
        self:SetDrawScale(self.Size)
    end,

    OnDestroy = function(self)
        Shield.OnDestroy(self)
    end,

    RemoveShield = function(self)
        Shield.RemoveShield(self)
        self:SetCollisionShape('None')
    end,
}

-- kept for mod backwards compatibility
UnitShield = PersonalShield


--- copypasted due to childrens using class that is already made