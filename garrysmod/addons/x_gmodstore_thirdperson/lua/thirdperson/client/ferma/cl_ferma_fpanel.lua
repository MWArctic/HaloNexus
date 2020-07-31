FERMA = FERMA or {}
FPanel = {}

function FPanel:Style( style )

    /* Defaults */
    self.FT = FERMA.CORE.Fermafy( style, self:GetParent() )
    FERMA.CORE.FermaDefaults( self )
    /* */

end

function FPanel:Paint( w, h )

    /* Defaults */
    FERMA.CORE.PaintFermafy( w, h, self.FT )
    -- 76561222104720366
    /* */

end

derma.DefineControl( "FPanel", "Better DPanel", FPanel, "DPanel" )