enpc = enpc or {}
enpc.Config = enpc.Config or {}

-- These are ranks that are allowed to edit, save and delete NPCs.
enpc.Config.AllowedRanks = {
    ["superadmin"] = true,
    ["admin"] = true,
}

-- This is how far the text above the NPC will render, 2000 is default.
enpc.Config.RenderDistance = 2000

-- This is the prefix of the text that comes up in chat when you edit, remove or save an NPC.
enpc.Config.ChatPrefix = "ENPC"

-- This is the default model that will be used when you spawn an ENPC in.
enpc.Config.DefaultModel = "models/barney.mdl"

-- This is the default text that will show when you have not set a text for above the NPC.
enpc.Config.DefaultText = "ENPC"
