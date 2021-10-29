AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("te_save")
util.AddNetworkString("te_edit")
util.AddNetworkString("te_remove")

function ENT:Initialize()

	self:SetModel("models/barney.mdl")
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetSolid(SOLID_BBOX)
	self:CapabilitiesAdd(bit.bor(CAP_ANIMATEDFACE, CAP_TURN_HEAD))
	self:SetUseType(SIMPLE_USE)
	self:DropToFloor()
	self:SetMaxYawSpeed(90)
	self:DropToFloor()

end

function ENT:Use( activator )

	if ( activator:IsPlayer() ) then 
		activator:SendLua(self:GetNWString("runlua","enpc:OpenTestMenu()"))
	end

end

net.Receive("te_edit",function(len,ply)
	local ent = net.ReadEntity()
	local tbl = net.ReadTable()
	if ply:IsSuperAdmin() and ent:GetClass() == "enpc_npc" then
		ent:SetNWString("runlua",tbl.lua)
		ent:SetNWString("modelname",tbl.model)
		ent:SetNWString("titletext",tbl.title)
		ent:SetModel(tbl.model)
	end
end)

net.Receive("te_save",function(len,ply)
	if ply:IsSuperAdmin() then
		enpc:SaveEnts()
		enpc:RemoveEnts()
		enpc:LoadEnts()
	end
end)

net.Receive("te_remove",function(len,ply)
	local ent = net.ReadEntity()
	if ply:IsSuperAdmin() and IsValid(ent) and ent:GetClass() == "enpc_npc" then
		local saved = ent:GetNWBool("issaved",false)
		ent:Remove()
		if saved == true then
			enpc:SaveEnts()
		end
	end
end)

function enpc:SaveEnts()
	local data = {}
	for k ,v in pairs(ents.FindByClass("enpc_npc")) do
		table.insert(data, {pos = v:GetPos(), ang = v:GetAngles(), lua = v:GetNWString("runlua","enpc:OpenTestMenu()"), model = v:GetNWString("modelname","models/barney.mdl"), title = v:GetNWString("titletext","ENPC")})
	end
	if not file.Exists("enpcs" , "DATA") then
		file.CreateDir("enpcs")
	end

	file.Write("enpcs/"..game.GetMap()..".txt", util.TableToJSON(data))
end

function enpc:RemoveEnts()
	for k,v in ipairs(ents.FindByClass("enpc_npc")) do
		v:Remove()
	end
end

function enpc:LoadEnts()
	if file.Exists("enpcs/"..game.GetMap()..".txt" , "DATA") then
		local data = file.Read("enpcs/"..game.GetMap()..".txt", "DATA")
		data = util.JSONToTable(data)
		for k, v in pairs(data) do
			local slot = ents.Create("enpc_npc")
			slot:SetPos(v.pos)
			slot:SetAngles(v.ang)
			slot:Spawn()
			slot:SetModel(v.model)
            slot:SetNWString("runlua",v.lua)
			slot:SetNWString("modelname",v.model)
			slot:SetNWString("titletext",v.title)
			slot:SetNWBool("issaved",true )
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