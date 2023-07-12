oldXEL0209 = XEL0209
XEL0209 = Class(oldXEL0209) {
    OnStopBuild = function(self, unitBeingBuilt)
        self:SetWeaponEnabledByLabel('Riotgun01', true)
        TConstructionUnit.OnStopBuild(self, unitBeingBuilt)
    end,
}
TypeClass = XEL0209