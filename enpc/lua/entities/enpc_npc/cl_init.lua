include("shared.lua")
include("enpc_config.lua")

surface.CreateFont("ENPCFont",{font = "Roboto",size = 255, antialias = true})
surface.CreateFont("ENPCFontUI",{font = "Roboto",size = 20, antialias = true})
surface.CreateFont("ENPCFontUISmall",{font = "Roboto",size = 15, antialias = true})
shownpcs = false


function ENT:Draw()

	self:DrawModel()

	local plypos, plyang = LocalPlayer():GetPos(), LocalPlayer():GetAngles()
	local text = self:GetNWString("enpc:titletext",enpc.Config.DefaultText)
	local mins, maxs = self:GetModelBounds()
	local pos = self:GetPos() + Vector( 0, 0, maxs.z + 7 )
	local ang = Angle( 0, plyang.yaw-90, 90 )
	local dist = pos:Distance(plypos)
	local alpha = math.Clamp(enpc.Config.RenderDistance - dist * 2.7, 0, 255)

	if (alpha <= 0) then return end

	cam.Start3D2D( pos, ang, 0.025 )
		draw.WordBox(48,0,0,text,"ENPCFont",enpc.blackhud,enpc.white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	cam.End3D2D()

end

function enpc:OpenEditMenu()
	local targetent = LocalPlayer():GetEyeTrace().Entity
	local scrw,scrh = ScrW(),ScrH()
	
	local frame = vgui.Create("DFrame")
	frame:SetSize(scrw*.15,scrh*.24)
	frame:Center()
	frame:MakePopup()
	frame:SetVisible(true)
	frame:DockPadding(10,30,10,10)
	enpc.MakeFrame(frame,"ENPC Edit Menu")

	local typebox = vgui.Create("DComboBox",frame)
	typebox:Dock(TOP)
	typebox:DockMargin(0,5,0,5)
	typebox:SetHeight(30)
	typebox:AddChoice("Lua String")
	typebox:AddChoice("Chat Command")
	typebox:AddChoice("Console Command")
	typebox:SetValue(targetent:GetNWString("enpc:type","Select Type"))
	enpc.MakeCombo(typebox,"Select Type")

	local luaentry = vgui.Create("DTextEntry",frame)
	luaentry:Dock(TOP)
	luaentry:DockMargin(0,5,0,5)
	luaentry:SetHeight(30)
	luaentry:SetText(targetent:GetNWString("enpc:rundata",""))
	enpc.MakeInput(luaentry,Either(typebox:GetValue() == "Select Type","Please select a Type","Enter "..typebox:GetValue()))
	typebox.OnSelect = function()
		enpc.MakeInput(luaentry,Either(typebox:GetValue() == "Select Type","Please select a Type","Enter "..typebox:GetValue()))
	end

	local modelentry = vgui.Create("DTextEntry",frame)
	modelentry:Dock(TOP)
	modelentry:DockMargin(0,5,0,5)
	modelentry:SetHeight(30)
	modelentry:SetText(targetent:GetNWString("enpc:modelname",""))
	enpc.MakeInput(modelentry,"Enter Model Name")

	local titleentry = vgui.Create("DTextEntry",frame)
	titleentry:Dock(TOP)
	titleentry:DockMargin(0,5,0,5)
	titleentry:SetHeight(30)
	titleentry:SetText(targetent:GetNWString("enpc:titletext",""))
	enpc.MakeInput(titleentry,"Enter Title")

	local removebutton = vgui.Create("DButton",frame)
	removebutton:Dock(TOP)
	removebutton:DockMargin(0,5,0,5)
	removebutton:SetHeight(40)
	enpc.MakeButton(removebutton,"Remove",enpc.red)
	removebutton.DoClick = function()
		if IsValid(targetent) and targetent:GetClass() == "enpc_npc" then
			chat.AddText(enpc.green,"["..enpc.Config.ChatPrefix.."]",enpc.white," removed NPC.")
			net.Start("te_remove")
			net.WriteEntity(targetent)
			net.SendToServer()
			frame:Close()
		end
	end

	local editbutton = vgui.Create("DButton",frame)
	editbutton:Dock(TOP)
	editbutton:DockMargin(0,5,0,5)
	editbutton:SetHeight(40)
	enpc.MakeButton(editbutton,"Edit Entity",enpc.blue)
	editbutton.DoClick = function()
		if IsValid(targetent) and targetent:GetClass() == "enpc_npc" then
			if typebox:GetText() == "Select Type" then chat.AddText(enpc.green,"["..enpc.Config.ChatPrefix.."]",enpc.white," please select a type.") return end
			chat.AddText(enpc.green,"["..enpc.Config.ChatPrefix.."]",enpc.white," edited NPC.")
			local tbl = util.Compress(util.TableToJSON({info = luaentry:GetText(), model = modelentry:GetText(), title = titleentry:GetText(), type = typebox:GetText()}))
			net.Start("te_edit")
			net.WriteEntity(LocalPlayer():GetEyeTrace().Entity)
			net.WriteData(tbl)
			net.SendToServer()
		end
	end

	local savebutton = vgui.Create("DButton",frame)
	savebutton:Dock(TOP)
	savebutton:DockMargin(0,5,0,5)
	savebutton:SetHeight(40)
	enpc.MakeButton(savebutton,"Save All Entities",enpc.green)
	savebutton.DoClick = function()
		if IsValid(targetent) and targetent:GetClass() == "enpc_npc" then
			chat.AddText(enpc.green,"["..enpc.Config.ChatPrefix.."]",enpc.white," Saved: "..#ents.FindByClass("enpc_npc").." entites to "..game.GetMap())
			net.Start("te_save")
			net.SendToServer()
			frame:Close()
		end
	end
end

concommand.Add("enpc_edit",function(ply,cmd,args)
	local ent = LocalPlayer():GetEyeTrace().Entity
	if IsValid(ent) and ent:GetClass() == "enpc_npc" and enpc.Config.AllowedRanks[ply:GetUserGroup()] then
		enpc:OpenEditMenu()
	end
end)

concommand.Add("enpc_save",function(ply,cmd,args)
	if enpc.Config.AllowedRanks[ply:GetUserGroup()] then
		net.Start("te_save")
		net.WriteEntity(targetent)
		net.SendToServer()
	end
end)

concommand.Add("enpc_show",function(ply,cmd,args)
	if enpc.Config.AllowedRanks[ply:GetUserGroup()] then
		if shownpcs == false then
			shownpcs = true
			hook.Add("PostDrawOpaqueRenderables","ShowEnpcs",function()
				for k,v in ipairs(ents.FindByClass("enpc_npc")) do
					local min,max = v:GetModelBounds()
					render.SetColorMaterial()
					render.DrawWireframeBox(v:GetPos(),v:GetAngles(),min,max,enpc.wfgreen)
					render.DrawBox( v:GetPos(),v:GetAngles(),min,max,enpc.rfgreen)
				end
			end)
		else
			hook.Remove("PostDrawOpaqueRenderables","ShowEnpcs")
			shownpcs = false
		end
	end
end)
net.Receive("te_sendlua",function()
	RunString(net.ReadString())
end)
print("[ENPC] Loading file: cl_init.lua")