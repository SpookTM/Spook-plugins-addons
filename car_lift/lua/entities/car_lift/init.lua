AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua") 
 
include("shared.lua")

util.AddNetworkString("gta_tune_open")
util.AddNetworkString("gta_tune_close")
util.AddNetworkString("gta_tune_hudhint")
util.AddNetworkString("gta_tune_get_color")
util.AddNetworkString("gta_tune_install_part")
util.AddNetworkString("simfphys_startengine")


function ENT:Initialize()

	self:SetModel("models/darky_m/car_lift.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
 
    local phys = self:GetPhysicsObject()

	if phys:IsValid() then
		phys:Wake()
	end
end
 
function ENT:Use(activator, caller)
    return
end
 
function ENT:Think()
    local selfpos = self:LocalToWorld(self:OBBCenter())+Vector(0,0,-30)
    local Ents = ents.FindInSphere(selfpos, 30)

    for i = 1, #Ents do
		if simfphys.IsCar(Ents[i]) then
            local Car = Ents[i]
            local CarPos = Car:LocalToWorld(Car:OBBCenter())
            local selfposZcar = Vector(selfpos.x, selfpos.y, CarPos.z)
            if CarPos:DistToSqr(selfposZcar) < 3000 and CarPos:DistToSqr(selfposZcar) > 200 and not Car:EngineActive() then
                -- debugoverlay.Line(selfposZcar, Car:GetPos()+Vector(0,0,Car:OBBCenter().z), 0.2, Color(0, 255, 13), true)
                construct.SetPhysProp(self, self, 0, self:GetPhysicsObject(), {Material = "ice"})
                local curang = Car:GetAngles()
                local curpos = Car:GetPos()
                local curanglocal = curang-self:GetAngles()
                
                local idealang = Angle(math.Round(curanglocal.p/90)*90, math.Round(curanglocal.y/90)*90, math.Round(curanglocal.r/90)*90)+self:GetAngles()

                local phys = Car:GetPhysicsObject()
                local mass = phys:GetMass()
                phys:ApplyForceCenter((selfposZcar-curpos)*Vector(3*mass,3*mass,0))
                phys:SetAngles(LerpAngle(0.2, curang, idealang))

            elseif CarPos:DistToSqr(selfposZcar) < 500 and not Car:EngineActive() then
                if Car:GetDriver():IsPlayer() then
                    self.User = Car:GetDriver()
                    net.Start("gta_tune_open")
                    net.Send(Car:GetDriver())

                    net.Receive("gta_tune_install_part", function(len, ply)
                        local car = ply:GetSimfphys()

                        if not car:IsValid() then return end
                        if not ply == self.User then return end

                        local part = net.ReadString()
                        local level = net.ReadUInt(6)

                        if part != "" and level > 0 then
                            -- All good, installing
                            -- print(part, level)

                            local vname = car:GetSpawn_List()
                            local VehicleList = list.Get("simfphys_vehicles")[vname]

                            if part == "color" then
                                if car:GetNWInt("GTA_color") != level then --we don't want to painting in same color
                                    if ply:getDarkRPVar("money") < GTA_TUNE.colorpricelist[level] then 
                                        DarkRP.notify(ply, 0, 3, "You don't have enough funds")
                                        return
                                    end

                                    ply:addMoney(-GTA_TUNE.colorpricelist[level])
                                    car:SetColor(GTA_TUNE.colorlist[level])
                                    -- print("Colored for $"..GTA_TUNE.colorpricelist[level])
                                    DarkRP.notify(ply, 0, 3, "Your car was painted for "..DarkRP.formatMoney(GTA_TUNE.colorpricelist[level]))
                                    
                                    net.Start("gta_tune_install_part")
                                    net.WriteBool(true)
                                    net.Send(ply)
                                    car:SetNWInt("GTA_color", level)
                                    
                                    car:EmitSound("player/sprayer.wav")
                                end

                            elseif part == "engine" then
                                if car:GetNWInt("GTA_engine") != level then -- we don't want same upgrade 
                                    local basetorq = VehicleList.Members.PeakTorque

                                    if ply:getDarkRPVar("money") < GTA_TUNE.enginepricelist[level] then 
                                        DarkRP.notify(ply, 0, 3, "You don't have enough funds")
                                        return
                                    end

                                    car:SetMaxTorque(math.min((basetorq + GTA_TUNE.upgradePerLevel[2] * level), GTA_TUNE.maxUpgrades[3]))
                                    ply:addMoney(-GTA_TUNE.enginepricelist[level])
                                    -- print("Engine upgraded for $"..GTA_TUNE.enginepricelist[level])
                                    DarkRP.notify(ply, 0, 3, "Engine on your car was upgraded for "..DarkRP.formatMoney(GTA_TUNE.enginepricelist[level]))
                                    
                                    net.Start("gta_tune_install_part")
                                    net.WriteBool(true)
                                    net.Send(ply)
                                    car:SetNWInt("GTA_engine", level)
                                    car:EmitSound("car_lift_install.mp3")
                                end
                            elseif part == "brakes" then
                                if car:GetNWInt("GTA_brakes") != level then -- we don't want same upgrade 
                                    local basebrake = VehicleList.Members.BrakePower

                                    if ply:getDarkRPVar("money") < GTA_TUNE.brakepricelist[level] then 
                                        DarkRP.notify(ply, 0, 3, "You don't have enough funds")
                                        return
                                    end

                                    car:SetBrakePower(math.min((basebrake + GTA_TUNE.upgradePerLevel[3] * level), GTA_TUNE.maxUpgrades[4]))
                                    ply:addMoney(-GTA_TUNE.brakepricelist[level])
                                    -- print("Brakes upgraded for $"..GTA_TUNE.brakepricelist[level])
                                    DarkRP.notify(ply, 0, 3, "Brakes on your car was upgraded for "..DarkRP.formatMoney(GTA_TUNE.brakepricelist[level]))
                                    net.Start("gta_tune_install_part")
                                    net.WriteBool(true)
                                    net.Send(ply)
                                    car:SetNWInt("GTA_brakes", level)
                                    car:EmitSound("car_lift_install.mp3")
                                end
                            elseif part == "tires" then
                                if car:GetNWInt("GTA_tires") != level then -- we don't want same upgrade 
                                    local basetraction = VehicleList.Members.MaxGrip 

                                    if ply:getDarkRPVar("money") < GTA_TUNE.tirepricelist[level] then 
                                        DarkRP.notify(ply, 0, 3, "You don't have enough funds")
                                        return
                                    end

                                    car:SetMaxTraction(math.min((basetraction + GTA_TUNE.upgradePerLevel[4] * level), GTA_TUNE.maxUpgrades[2]))
                                    ply:addMoney(-GTA_TUNE.tirepricelist[level])
                                    -- print("Tires upgraded for $"..GTA_TUNE.tirepricelist[level])
                                    DarkRP.notify(ply, 0, 3, "Tires on your car was upgraded for "..DarkRP.formatMoney(GTA_TUNE.tirepricelist[level]))
                                    net.Start("gta_tune_install_part")
                                    net.WriteBool(true)
                                    net.Send(ply)
                                    car:SetNWInt("GTA_tires", level)
                                    car:EmitSound("car_lift_install.mp3")
                                end
                            elseif part == "armor" then
                                if car:GetNWInt("GTA_armor") != level then -- we don't want same upgrade 
                                    if ply:getDarkRPVar("money") < GTA_TUNE.armorpricelist[level] then 
                                        DarkRP.notify(ply, 0, 3, "You don't have enough funds")
                                        return
                                    end

                                    local basehp = math.floor(car.MaxHealth and car.MaxHealth or (1000 + car:GetPhysicsObject():GetMass() / 3))

                                    car:SetMaxHealth(basehp + GTA_TUNE.upgradePerLevel[1] * level)
                                    car:SetCurHealth(basehp + GTA_TUNE.upgradePerLevel[1] * level)
                                    ply:addMoney(-GTA_TUNE.armorpricelist[level])
                                    -- print("Armor upgraded for $"..GTA_TUNE.armorpricelist[level])
                                    DarkRP.notify(ply, 0, 3, "Armor on your car was upgraded for "..DarkRP.formatMoney(GTA_TUNE.armorpricelist[level]))
                                    
                                    net.Start("gta_tune_install_part")
                                    net.WriteBool(true)
                                    net.Send(ply)
                                    car:SetNWInt("GTA_armor", level)
                                    car:EmitSound("car_lift_install.mp3")
                                end
                            elseif part == "underglow" then
                                if car:GetNWInt("GTA_underlight") != level then -- we don't want same upgrade 
                                    if ply:getDarkRPVar("money") < GTA_TUNE.underglowpricelist[level] then 
                                        DarkRP.notify(ply, 0, 3, "You don't have enough funds")
                                        return
                                    end

                                    ply:addMoney(-GTA_TUNE.underglowpricelist[level])
                                    -- print("Underglow upgraded for $"..GTA_TUNE.underglowpricelist[level])
                                    net.Start("gta_tune_install_part")
                                    net.WriteBool(true)
                                    net.Send(ply)
                                    if level == 1 then
                                        level = 0
                                        DarkRP.notify(ply, 0, 3, "Underglow has been removed from your car")
                                    else
                                        car:EmitSound("car_lift_install.mp3")
                                        DarkRP.notify(ply, 0, 3, "Underglow was installed on your car for "..DarkRP.formatMoney(GTA_TUNE.underglowpricelist[level]))
                                    end
                                    car:SetNWInt("GTA_underlight", level)
                                end
                            end

                        end
                    end)

                elseif self.User and self.User:IsPlayer() then
                    net.Start("gta_tune_close")
                    net.Send(self.User)   
                    self.User = nil      
                end           
            else
                construct.SetPhysProp(self, self, 0, self:GetPhysicsObject(), {Material = "metal"})
                if self.User and self.User:IsPlayer() then
                    net.Start("gta_tune_close")
                    net.Send(self.User)   
                    -- self.User = nil      
                else
                    net.Start("gta_tune_hudhint")
                    net.WriteEntity(self)
                    net.Send(Car:GetDriver())
                end
                -- debugoverlay.Line(selfposZcar, CarPos, 0.2, Color(255, 0, 0), true)
            end 
        end  
	end


    net.Receive("simfphys_startengine", function(len, ply)
        -- print("trying!!!!!!!!")
        -- print(self.User, ply:GetVehicle())
        if self.User and self.User == ply and ply:GetVehicle().vehiclebase:IsValid() then
            ply:GetVehicle().vehiclebase:StartEngine(true)
        end
    end)
end

net.Receive("gta_tune_get_color", function(len, ply)
    local car = ply:GetSimfphys()
    if not car:IsValid() then return end
    net.Start("gta_tune_get_color")
    net.WriteColor(car:GetColor())
    net.Send(ply)
end)

