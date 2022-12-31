include("enpc_config.lua")
include("shared.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("enpc_config.lua")

util.AddNetworkString("te_save")
util.AddNetworkString("te_edit")
util.AddNetworkString("te_remove")
util.AddNetworkString("te_sendlua")

function ENT:Initialize()

	self:SetModel(enpc.Config.DefaultModel)
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetSolid(SOLID_BBOX)
	self:CapabilitiesAdd(bit.bor(CAP_ANIMATEDFACE, CAP_TURN_HEAD))
	self:SetUseType(SIMPLE_USE)
	self:DropToFloor()
	self:SetMaxYawSpeed(90)
	self:DropToFloor()

	self:SetNPCType("Select Type")
	self:SetNPCData("")
	self:SetSavedTitle(enpc.Config.DefaultText)
	self:SetSavedModel(enpc.Config.DefaultModel)

end

function ENT:Use( activator )

	if ( activator:IsPlayer() ) then
		self:PerformInteract( activator )
	end

end

function ENT:PerformInteract( ply )

	if self:GetNPCType() == "" then return end
	local typ = self:GetNPCType()
	if typ == "Lua String" then
		net.Start("te_sendlua")
		net.WriteString(self:GetNPCData())
		net.Send(ply)
	elseif typ == "Console Command" then
		ply:ConCommand(self:GetNPCData())
	elseif typ == "Chat Command" then
		ply:Say(self:GetNPCData())
	end

end


net.Receive("te_edit",function(len,ply)
	local ent = net.ReadEntity()
	local tbl = util.JSONToTable(util.Decompress(net.ReadData(250)))
	if enpc.Config.AllowedRanks[ply:GetUserGroup()] and ent:GetClass() == "enpc_npc" then
		ent:SetNPCType(tbl.type)
		ent:SetNPCData(tbl.info)
		ent:SetSavedModel(tbl.model)
		ent:SetSavedTitle(tbl.title)
		ent:SetModel(tbl.model)
	end
end)

net.Receive("te_save",function(len,ply)
	if enpc.Config.AllowedRanks[ply:GetUserGroup()] then
		enpc:SaveEnts()
		enpc:RemoveEnts()
		enpc:LoadEnts()
	end
end)

net.Receive("te_remove",function(len,ply)
	local ent = net.ReadEntity()
	if enpc.Config.AllowedRanks[ply:GetUserGroup()] and IsValid(ent) and ent:GetClass() == "enpc_npc" then
		local saved = ent:GetSaved()
		ent:Remove()
		if saved == true then
			timer.Simple(1, function() enpc:SaveEnts() end)
		end
	end
end)

function enpc:SaveEnts()
	local data = {}
	for k ,v in pairs(ents.FindByClass("enpc_npc")) do
		table.insert(data, {pos = v:GetPos(), ang = v:GetAngles(), type = v:GetNPCType(), info = v:GetNPCData(), model = v:GetSavedModel(), title = v:GetSavedTitle()})
	end
	if not file.Exists("enpcs" , "DATA") then
		file.CreateDir("enpcs")
	end

	file.Write("enpcs/"..game.GetMap()..".json", util.TableToJSON(data))
end

function enpc:RemoveEnts()
	for k,v in ipairs(ents.FindByClass("enpc_npc")) do
		v:Remove()
	end
end

function enpc:LoadEnts()
	if file.Exists("enpcs/"..game.GetMap()..".json" , "DATA") then
		local data = file.Read("enpcs/"..game.GetMap()..".json", "DATA")
		data = util.JSONToTable(data)
		for k, v in pairs(data) do
			local slot = ents.Create("enpc_npc")
			slot:SetPos(v.pos)
			slot:SetAngles(v.ang)
			slot:Spawn()
			slot:SetModel(v.model)
			slot:SetNPCType(v.type)
			slot:SetNPCData(v.info)
			slot:SetSavedModel(v.model)
			slot:SetSavedTitle(v.title)
			slot:SetSaved( true )
		end
		print("[ENPC] Finished loading "..#data.." NPCs.")
	else
		print("[ENPC] No map data found for NPCs. Please place some and do enpc_save to create the data.")
	end
end

hook.Add("InitPostEntity", "spawn:enpcs", function()
	enpc:LoadEnts()
end)

hook.Add("PostCleanupMap","respawn:enpcs",function()
	enpc:LoadEnts()
end)

print("[ENPC] Loading file: init.lua")