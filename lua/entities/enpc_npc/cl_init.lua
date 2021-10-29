include("shared.lua")

surface.CreateFont("ENPCFont",{font = "Roboto",size = 255, antialias = true})
surface.CreateFont("ENPCFontUI",{font = "Roboto",size = 20, antialias = true})
surface.CreateFont("ENPCFontUISmall",{font = "Roboto",size = 15, antialias = true})

shownpcs = false


function ENT:Draw()

	self:DrawModel()

	local plypos, plyang = LocalPlayer():GetPos(), LocalPlayer():GetAngles()
	local text = self:GetNWString("titletext","ENPC")
	local mins, maxs = self:GetModelBounds()
	local pos = self:GetPos() + Vector( 0, 0, maxs.z + 7 )
	local ang = Angle( 0, plyang.yaw-90, 90 )
	local dist = pos:Distance(plypos)
	local alpha = math.Clamp(2000 - dist * 2.7, 0, 255)

	if (alpha <= 0) then return end

	cam.Start3D2D( pos, ang, 0.025 )
		draw.WordBox(48,0,0,text,"ENPCFont",Color( 20, 20, 20, 253),Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	cam.End3D2D()

end

function enpc:OpenEditMenu()
	local targetent = LocalPlayer():GetEyeTrace().Entity
	
	local frame = vgui.Create("DFrame")
	frame:SetSize(0,0)
	frame:Center()
	frame:MakePopup()
	frame:SetVisible(true)
	enpc.MakeFrame(frame,300,250,"ENPC Edit Menu")

	local luaentry = vgui.Create("DTextEntry",frame)
	luaentry:SetPos(10,30)
	luaentry:SetSize(280,30)
	luaentry:SetText(targetent:GetNWString("runlua",""))
	enpc.MakeInput(luaentry,"Enter Lua String")

	local modelentry = vgui.Create("DTextEntry",frame)
	modelentry:SetPos(10,70)
	modelentry:SetSize(280,30)
	modelentry:SetText(targetent:GetNWString("modelname",""))
	enpc.MakeInput(modelentry,"Enter Model Name")

	local titleentry = vgui.Create("DTextEntry",frame)
	titleentry:SetPos(10,110)
	titleentry:SetSize(280,30)
	titleentry:SetText(targetent:GetNWString("titletext",""))
	enpc.MakeInput(titleentry,"Enter Title")

	local removebutton = vgui.Create("DButton",frame)
	removebutton:SetPos(195,150)
	removebutton:SetSize(95,40)
	removebutton:SetText("")
	enpc.MakeButton(removebutton,"Remove",Color(204,117,117))
	removebutton.DoClick = function()
		if IsValid(targetent) and targetent:GetClass() == "enpc_npc" then
			chat.AddText(Color(94,214,94),"[ENPC]",Color(255,255,255)," removed NPC.")
			net.Start("te_remove")
			net.WriteEntity(targetent)
			net.SendToServer()
			frame:Close()
		end
	end

	local editbutton = vgui.Create("DButton",frame)
	editbutton:SetPos(10,150)
	editbutton:SetSize(180,40)
	editbutton:SetText("")
	enpc.MakeButton(editbutton,"Edit Entity",Color(110,117,212))
	editbutton.DoClick = function()
		if IsValid(targetent) and targetent:GetClass() == "enpc_npc" then
			chat.AddText(Color(94,214,94),"[ENPC]",Color(255,255,255)," edited NPC.")
			local tbl = {lua = luaentry:GetText(), model = modelentry:GetText(), title = titleentry:GetText()}
			net.Start("te_edit")
			net.WriteEntity(LocalPlayer():GetEyeTrace().Entity)
			net.WriteTable(tbl)
			net.SendToServer()
		end
	end

	local savebutton = vgui.Create("DButton",frame)
	savebutton:SetPos(10,200)
	savebutton:SetSize(280,40)
	savebutton:SetText("")
	enpc.MakeButton(savebutton,"Save All Entities",Color(94,214,94))
	savebutton.DoClick = function()
		if IsValid(targetent) and targetent:GetClass() == "enpc_npc" then
			chat.AddText(Color(94,214,94),"[ENPC]",Color(255,255,255)," Saved: "..#ents.FindByClass("enpc_npc").." entites to "..game.GetMap())
			net.Start("te_save")
			net.SendToServer()
			frame:Close()
		end
	end
end

function enpc:OpenTestMenu()
	local frame = vgui.Create("DFrame")
	frame:SetSize(0,0)
	frame:Center()
	frame:MakePopup()
	frame:SetVisible(true)
	enpc.MakeFrame(frame,200,150,"Test Menu")

	local close = vgui.Create("DButton",frame)
	close:SetPos(10,60)
	close:SetSize(180,40)
	close:SetText("")
	enpc.MakeButton(close,"Close",Color(204,117,117))
	close.DoClick = function()
		frame:Close()
	end
end

concommand.Add("enpc_edit",function(ply,cmd,args)
	local ent = LocalPlayer():GetEyeTrace().Entity
	if IsValid(ent) and ent:GetClass() == "enpc_npc" and ply:IsSuperAdmin() then
		enpc:OpenEditMenu()
	end
end)

concommand.Add("enpc_save",function(ply,cmd,args)
	if ply:IsSuperAdmin() then
		net.Start("te_save")
		net.WriteEntity(targetent)
		net.SendToServer()
	else
		print("Error: Incorrect Usergroup!")
	end
end)

concommand.Add("enpc_show",function(ply,cmd,args)
	if ply:IsSuperAdmin() then
		if shownpcs == false then
			shownpcs = true
			hook.Add("PostDrawOpaqueRenderables","ShowEnpcs",function()
				for k,v in ipairs(ents.FindByClass("enpc_npc")) do
					local min,max = v:GetModelBounds()
					render.DrawBox(v:GetPos(),v:GetAngles(),min,max,Color(94,214,94,31))
					render.DrawWireframeBox(v:GetPos(),v:GetAngles(),min,max,Color(58,131,58))
				end
			end)
		else
			hook.Remove("PostDrawOpaqueRenderables","ShowEnpcs")
			shownpcs = false
		end
	else
		print("Error: Incorrect Usergroup!")
	end
end)