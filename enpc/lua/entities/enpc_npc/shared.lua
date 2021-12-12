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

    function enpc.MakeFrame(pnl,txt)
        pnl:SetTitle("")
        pnl.Paint = function(s,w,h)
            surface.SetDrawColor(enpc.bgdark)
            surface.DrawRect(0,0,w,h)
            draw.SimpleText(txt,"ENPCFontUISmall",10,7,enpc.white,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
        end
    end

    function enpc.MakeButton(pnl,txt,col)
        pnl:SetText("")
        local speed,barstatus = 4,0
        pnl.Paint = function(s,w,h)
            if pnl:IsHovered() then
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
    
    function enpc.MakeInput(pnl,txt)
        pnl:SetFont("ENPCFontUISmall")
        pnl.Paint = function(s,w,h)
            surface.SetDrawColor(enpc.bglight)
            surface.DrawRect(0,0,w,h)
            if pnl:GetText() == "" then
                draw.SimpleText(txt,"ENPCFontUISmall",5,h/2,enpc.grey,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
            end
            pnl:DrawTextEntryText(enpc.white,enpc.hghlight,enpc.white)
        end
    end
    
    function enpc.MakeCombo(pnl,txt)
        pnl:SetFont("ENPCFontUISmall")
        pnl:SetColor(enpc.white)
        pnl.Paint = function(s,w,h)
            surface.SetDrawColor(enpc.bglight)
            surface.DrawRect(0,0,w,h)
            if pnl:GetSelected() == nil and pnl:GetText() == "" then
                draw.SimpleText(txt,"ENPCFontUISmall",5,h/2,enpc.grey,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
            end
        end
    end
end
print("[ENPC] Loading file: shared.lua")