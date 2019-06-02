local E, L = unpack(select(2, ...)) -- Engine, Locale

-- Global strings
-- We define them as "globals" here, since Lua would otherwise create and hash new strings over and over again.
-- This method should save a bit of memory and probably speed things up by a few nanoseconds
-- ... Yep, this is overkill, but idc
E.STR = {}

E.STR.EMPTY		= ""

E.STR.player	= "player"
E.STR.Boss		= "Boss"
E.STR.HELPFUL	= "HELPFUL"
E.STR.HARMFUL	= "HARMFUL"

E.STR.TOP			= "TOP"
E.STR.TOPLEFT		= "TOPLEFT"
E.STR.TOPRIGHT		= "TOPRIGHT"
E.STR.BOTTOM		= "BOTTOM"
E.STR.BOTTOMRIGHT	= "BOTTOMRIGHT"
E.STR.BOTTOMLEFT	= "BOTTOMLEFT"
E.STR.RIGHT			= "RIGHT"
E.STR.LEFT			= "LEFT"
E.STR.CENTER		= "CENTER"

E.TBL = {}
E.TBL.EMPTY		= {}