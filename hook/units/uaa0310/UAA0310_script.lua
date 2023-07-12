local oldUAA0310 = UAA0310
UAA0310 = Class(oldUAA0310) {
    CreateWreckage = function(self, overkillRatio)
        if overkillRatio and overkillRatio > 1.0 then
            return
        end
        self:CreateWreckageProp(overkillRatio)
    end,
}
TypeClass = UAA0310
