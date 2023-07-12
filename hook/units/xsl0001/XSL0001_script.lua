local oldXSL0001 = XSL0001
XSL0001 = Class(oldXSL0001) {
    GetUnitsToBuff = function(self, bp)
        local unitCat = ParseEntityCategory(bp.UnitCategory or
            'BUILTBYTIER3FACTORY + BUILTBYQUANTUMGATE + NEEDMOBILEBUILD')
        local brain = self:GetAIBrain()

        local radiusMult = Buffs.VeterancyDamageArea.Affects.DamageRadius.Mult - 1
        local radiusMaxLevel = Buffs.VeterancyDamageArea.MaxLevel
        local radius = bp.Radius + (radiusMult * math.min(radiusMaxLevel, self.VeteranLevel - 1) * bp.Radius)

        local all = brain:GetUnitsAroundPoint(unitCat, self:GetPosition(), radius, 'Ally')
        local units = {}

        for _, u in all do
            if not u.Dead and not u:IsBeingBuilt() then
                table.insert(units, u)
            end
        end

        return units
    end,
}
TypeClass = XSL0001
