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

enpc = enpc or {}

if CLIENT then

    function enpc.MakeFrame(pnl,width,height,txt)
        pnl:SetTitle("")
        pnl.IsMoving = true
        pnl:SizeTo(width,height,1,0,.1,function()
            pnl.IsMoving = false
        end)
        pnl.Paint = function(s,w,h)
            if pnl.IsMoving == true then
                pnl:Center()
            end
            surface.SetDrawColor(Color(47,54,64))
            surface.DrawRect(0,0,w,h)
            draw.SimpleText(txt,"ENPCFontUISmall",10,7,Color(255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
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
            surface.SetDrawColor(Color(68,76,92))
            surface.DrawRect(0,0,w,h)
            surface.SetDrawColor(col)
            surface.DrawRect(0,h * .9,w * barstatus,h * .1)
            draw.SimpleText(txt,"ENPCFontUI",w/2,h/2,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end
    end
    
    function enpc.MakeInput(pnl,txt)
        pnl:SetFont("ENPCFontUISmall")
        pnl.Paint = function(s,w,h)
            surface.SetDrawColor(Color(68,76,92))
            surface.DrawRect(0,0,w,h)
            if pnl:GetText() == "" then
                draw.SimpleText(txt,"ENPCFontUISmall",5,h/2,Color(150,150,150),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
            end
            pnl:DrawTextEntryText(Color(255,255,255),Color(141,141,190),Color(255,255,255))
        end
    end

    function enpc.MakeList(pnl)
        pnl.Paint = function(s,w,h)
            surface.SetDrawColor(Color(68,76,92))
            surface.DrawRect(0,0,w,h)
        end
    end

    function enpc.MakeCombo(pnl,txt)
        pnl:SetFont("ENPCFontUISmall")
        pnl:SetColor(Color(255,255,255))
        pnl.Paint = function(s,w,h)
            surface.SetDrawColor(Color(68,76,92))
            surface.DrawRect(0,0,w,h)
            if pnl:GetSelected() == nil then
                draw.SimpleText(txt,"ENPCFontUISmall",5,h/2,Color(150,150,150),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
            end
        end
    end

    function enpc.MakeWang(pnl)
        pnl:SetFont("ENPCFontUISmall")
        pnl.Paint = function(s,w,h)
            surface.SetDrawColor(Color(68,76,92))
            surface.DrawRect(0,0,w,h)
            pnl:DrawTextEntryText(Color(255,255,255),Color(141,141,190),Color(255,255,255))
            if pnl:GetValue() > pnl:GetMax() then
                pnl:SetValue(pnl:GetMax())
            elseif pnl:GetValue() < pnl:GetMin() then
                pnl:SetValue(pnl:GetMin())
            end
            pnl:DrawTextEntryText(Color(255,255,255),Color(141,141,190),Color(255,255,255))
        end
    end
end