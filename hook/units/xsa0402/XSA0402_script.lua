local oldXSA0402 = XSA0402
XSA0402 = Class(oldXSA0402) {
    CreateWreckage = function(self, overkillRatio)
        if overkillRatio and overkillRatio > 1.0 then
            return
        end
        return self:CreateWreckageProp(overkillRatio)
    end,
}
TypeClass = XSA0402
