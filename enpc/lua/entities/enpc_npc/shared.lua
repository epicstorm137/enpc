ENT.Type = "anim"
ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.PrintName = "ENPC"
ENT.Author = "Epicstorm"
ENT.Category = "ENPC"
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:SetAutomaticFrameAdvance(bUsingAnim)
	self.AutomaticFrameAdvance = bUsingAnim
end

function ENT:SetupDataTables()
 
	self:NetworkVar( "String", 0, "NPCType" )
    self:NetworkVar( "String", 1, "NPCData" )
    self:NetworkVar( "String", 2, "SavedModel" )
    self:NetworkVar( "String", 3, "SavedTitle" )
    self:NetworkVar( "Bool", 0, "Saved" )

    local _SetNPCType = self.SetNPCType
    function self:SetNPCType( value )
        if CLIENT then return end
        _SetNPCType(self,value)
    end

    local _SetNPCData = self.SetNPCData
    function self:SetNPCData( value )
        if CLIENT then return end
        _SetNPCData(self,value)
    end

    local _SetSavedModel = self.SetSavedModel
    function self:SetSavedModel( value )
        if CLIENT then return end
        _SetSavedModel(self,value)
    end

    local _SetSavedTitle = self.SetSavedTitle
    function self:SetSavedTitle( value )
        if CLIENT then return end
        _SetSavedTitle(self,value)
    end

    local _SetSaved = self.SetSaved
    function self:SetSaved( value )
        if CLIENT then return end
        _SetSaved(self,value)
    end

end

if CLIENT then
    enpc.bgdark     = Color(47,54,64)
    enpc.bglight    = Color(68,76,92)
    enpc.grey       = Color(150,150,150)
    enpc.hghlight   = Color(141,141,190)
    enpc.white      = Color(255,255,255)
    enpc.blackhud   = Color(20,20,20,253)
    enpc.green      = Color(94,214,94)
    enpc.red        = Color(204,117,117)
    enpc.blue       = Color(110,117,212)
    enpc.wfgreen    = Color(0,255,0)
    enpc.rfgreen    = Color(0,255,0,50)

    function enpc.MakeFrame(self,width,height,txt)
        self:SetTitle("")
        self.IsMoving = true
        self:SizeTo(width,height,1,0,.1,function()
            self.IsMoving = false
        end)
        self.Paint = function(s,w,h)
            if self.IsMoving == true then
                self:Center()
            end
            surface.SetDrawColor(enpc.bgdark)
            surface.DrawRect(0,0,w,h)
            draw.SimpleText(txt,"ENPCFontUISmall",10,7,enpc.white,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
        end
    end

    function enpc.MakeButton(self,txt,col)
        self:SetText("")
        local speed,barstatus = 4,0
        self.Paint = function(s,w,h)
            if self:IsHovered() then
                barstatus = math.Clamp(barstatus + speed * FrameTime(), 0, 1)
            else
                barstatus = math.Clamp(barstatus - speed * FrameTime(), 0, 1)
            end
            surface.SetDrawColor(enpc.bglight)
            surface.DrawRect(0,0,w,h)
            surface.SetDrawColor(col)
            surface.DrawRect(0,h * .9,w * barstatus,h * .1)
            draw.SimpleText(txt,"ENPCFontUI",w/2,h/2,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end
    end
    
    function enpc.MakeInput(self,txt)
        self:SetFont("ENPCFontUISmall")
        self.Paint = function(s,w,h)
            surface.SetDrawColor(enpc.bglight)
            surface.DrawRect(0,0,w,h)
            if self:GetText() == "" then
                draw.SimpleText(txt,"ENPCFontUISmall",5,h/2,enpc.grey,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
            end
            self:DrawTextEntryText(enpc.white,enpc.hghlight,enpc.white)
        end
    end
    
    function enpc.MakeCombo(self,txt)
        self:SetFont("ENPCFontUISmall")
        self:SetColor(enpc.white)
        self.Paint = function(s,w,h)
            surface.SetDrawColor(enpc.bglight)
            surface.DrawRect(0,0,w,h)
            if self:GetSelected() == nil and self:GetValue() == "" then
                draw.SimpleText(txt,"ENPCFontUISmall",5,h/2,enpc.grey,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
            end
        end
    end
end
print("[ENPC] Loading file: shared.lua")