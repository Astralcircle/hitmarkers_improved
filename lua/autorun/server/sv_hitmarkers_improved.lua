resource.AddWorkshop( "3824846324" )

util.AddNetworkString( "hitmarkers_improved_hit" )

local npcHeadshot = false
local preHealth = 0
local tookEnt = nil
local hadArmor = false

local function IsSentient( ent )
    return ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()
end

hook.Add( "ScaleNPCDamage", "HitmarkersImprovedNPCDMG", function( _, hitgroup )
    npcHeadshot = hitgroup == HITGROUP_HEAD
end )

hook.Add( "EntityTakeDamage", "HitmarkersImproved", function( ent )
    if not IsSentient( ent ) then return end

    tookEnt = ent
    preHealth = ent:Health()
    hadArmor = ent:IsPlayer() and ent:Armor() > 0
end )

hook.Add( "PostEntityTakeDamage", "HitmarkersImproved", function( ent, dmginfo, took )
    if not took then return end
    if tookEnt ~= ent then return end
    if not IsSentient( ent ) then return end

    local currentHealth = math.max( ent:Health(), 0 )
    local dmgTook = preHealth - currentHealth
    if dmgTook <= 0 then return end

    local attacker = dmginfo:GetAttacker()
    if not IsValid( attacker ) then return end
    if attacker:IsVehicle() and IsValid( attacker:GetDriver() ) then attacker = attacker:GetDriver() end
    if not attacker:IsPlayer() then return end

    local inflictor = dmginfo:GetInflictor()
    if inflictor == ent or attacker == ent then return end

    local isHeadshot
    if ent:IsPlayer() then
        isHeadshot = ent:LastHitGroup() == HITGROUP_HEAD
    else
        isHeadshot = npcHeadshot
    end
    npcHeadshot = false

    net.Start( "hitmarkers_improved_hit", true )
    net.WriteUInt( math.min( math.ceil( dmgTook ), 65535 ), 16 )
    net.WriteBool( isHeadshot )
    net.WriteBool( currentHealth <= 0 )
    net.WriteBool( ent:IsPlayer() and hadArmor or false )
    net.WriteUInt( ent:EntIndex(), 16 )
    net.Send( attacker )
end )
