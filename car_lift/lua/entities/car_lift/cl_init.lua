include('shared.lua')

function ENT:Draw()
    self:DrawModel()
end


function ENT:Think()
    if CLIENT then
		local ply = LocalPlayer()
		
		if not IsValid(ply) then return end
		
		ply.simeditor_nextrequest = isnumber(ply.simeditor_nextrequest) and ply.simeditor_nextrequest or 0
		
		local ent = ply:GetVehicle().vehiclebase
		
		if not simfphys.IsCar(ent) then return end
		
		if ply.simeditor_nextrequest < CurTime() then
			net.Start("simfphys_plyrequestinfo")
				net.WriteEntity(ent)
			net.SendToServer()
			
			ply.simeditor_nextrequest = CurTime() + 0.6
		end
	end
end


--
local GrayColor = Color(10,10,10,250)
local White = Color(255,255,255)
local BlackColor = Color(10,10,10,255)
local GreenColor = Color(0,173,9)

local scrh2 = ScrH()/2
local lowres = false
local carcolor = Color(255,255,255)

if scrh2 < 400 then -- low res check
    lowres = true
end

function GTA_TUNE.OpenMenu()
    if IsValid(GTA_TUNE.Menu) then
        -- GTA_TUNE.Menu:Remove()
        return
    end
    
    local MenuHeight = 800
    local submenu = false

    if lowres then
        MenuHeight = scrh2*2
    else
        MenuHeight = 800
    end

    GTA_TUNE.Menu = vgui.Create("DFrame")

    GTA_TUNE.Menu:SetSize(400, MenuHeight)   
    GTA_TUNE.Menu:SetPos(70,scrh2-MenuHeight/2)
    GTA_TUNE.Menu:SetTitle("")
    GTA_TUNE.Menu:MakePopup()
    GTA_TUNE.Menu:SetDraggable(false)
    -- GTA_TUNE.Menu:ShowCloseButton(false)

    local car = LocalPlayer():GetSimfphys()


    
    local underColor = Color(102,102,102)
    local nocolor = Color(0,0,0,0)
    local hoverColor = Color(255,255,255,150)

    -- local Efficiency = car:GetEfficiency()
    local Speed, Traction, Torque, Braking
    local TractionBoost, TorqueBoost, BrakingBoost = 0, 0, 0

    function reloadspeeds()
        Speed = car:GetVehicleInfo().maxspeed
        Traction = car:GetMaxTraction()
        Torque = car:GetMaxTorque()
        Braking = car:GetBrakePower()
    end

    reloadspeeds()

    timer.Simple(0.2, reloadspeeds)

    local vname = car:GetSpawn_List()
    local VehicleList = list.Get("simfphys_vehicles")[vname]

    local MaxSpeed = GTA_TUNE.maxUpgrades[1]
    local MaxTraction = GTA_TUNE.maxUpgrades[2]
    local MaxTorque = GTA_TUNE.maxUpgrades[3]
    local MaxBraking = GTA_TUNE.maxUpgrades[4]
    
    local BaseTraction = VehicleList.Members.MaxGrip 
    local BaseTorque = VehicleList.Members.PeakTorque
    local BaseBraking = VehicleList.Members.BrakePower

    GTA_TUNE.Menu.Paint = function(me,w,h)
		surface.SetDrawColor(GrayColor)
		surface.DrawRect(0,0,w,MenuHeight-185)
		surface.SetDrawColor(BlackColor)
		surface.DrawRect(0,0,w,150)
		surface.DrawRect(0,MenuHeight-180,w,800)

        surface.SetDrawColor(underColor)
		surface.DrawRect(200,MenuHeight-160,180,12)
		surface.DrawRect(200,MenuHeight-120,180,12)
		surface.DrawRect(200,MenuHeight-80,180,12)
		surface.DrawRect(200,MenuHeight-40,180,12)

        surface.SetDrawColor(GreenColor)
		surface.DrawRect(200, MenuHeight-120, ((BaseTorque+GTA_TUNE.upgradePerLevel[2]*TorqueBoost)/MaxTorque)*180, 12)
		surface.DrawRect(200, MenuHeight-80, ((BaseBraking+GTA_TUNE.upgradePerLevel[3]*BrakingBoost)/MaxBraking)*180, 12)
		surface.DrawRect(200, MenuHeight-40, ((BaseTraction+GTA_TUNE.upgradePerLevel[4]*TractionBoost)/MaxTraction)*180, 12) 

        surface.SetDrawColor(White)
		surface.DrawRect(200, MenuHeight-160, (Speed/MaxSpeed)*180, 12)
		surface.DrawRect(200, MenuHeight-120, (Torque/MaxTorque)*180, 12)
		surface.DrawRect(200, MenuHeight-80, (Braking/MaxBraking)*180, 12)
		surface.DrawRect(200, MenuHeight-40, (Traction/MaxTraction)*180, 12)



        surface.SetDrawColor(BlackColor)
		surface.DrawRect(198+36, MenuHeight-160, 3, 200)
		surface.DrawRect(198+36*2, MenuHeight-160, 3, 200)
		surface.DrawRect(198+36*3, MenuHeight-160, 3, 200)
		surface.DrawRect(198+36*4, MenuHeight-160, 3, 200)
    end

    local label = GTA_TUNE.Menu:Add("DLabel")
    label:SetText("Dunwood Customs")
    label:SetSize(300, 32)
    label:SetTextColor(White)
    label:SetFont("DermaLarge")

    label:SetPos(200-label:GetTextSize()/2,50)
    

    local categ = GTA_TUNE.Menu:Add("DLabel")
    categ:SetText("CATEGORIES")
    categ:SetSize(300, 32)
    categ:SetPos(5,120)
    categ:SetTextColor(White)
    categ:SetFont("GModNotify")

    local colorlist = GTA_TUNE.colorlist
    local colorpricelist = GTA_TUNE.colorpricelist
    local underglowpricelist = GTA_TUNE.underglowpricelist
    local tirepricelist = GTA_TUNE.tirepricelist
    local brakepricelist = GTA_TUNE.brakepricelist
    local enginepricelist = GTA_TUNE.enginepricelist
    local armorpricelist = GTA_TUNE.armorpricelist


    local List = GTA_TUNE.Menu:Add("DListView")
    List:SetSize(400, MenuHeight-400)   
    List:SetPos(0,150)
    List:SetHideHeaders(true)
    List:SetSortable(false)
    List:SetDirty(false)
    List:SetPaintBackground(false)
    List:SetMultiSelect(false)
    List:AddColumn("Type")
    List:AddColumn("Price")



    local armorlist = {
        {"Armor Upgrade 20%", armorpricelist[1], function() installpart("armor", 1) end},
        {"Armor Upgrade 40%", armorpricelist[2], function() installpart("armor", 2) end},
        {"Armor Upgrade 60%", armorpricelist[3], function() installpart("armor", 3) end},
        {"Armor Upgrade 80%", armorpricelist[4], function() installpart("armor", 4) end},
        {"Armor Upgrade 100%", armorpricelist[5], function() installpart("armor", 5) end},
    }

    local enginelist = {
        {"EMS Upgrade, Level 1", enginepricelist[1], function() installpart("engine", 1) end, function() TorqueBoost = 1 end},
        {"EMS Upgrade, Level 2", enginepricelist[2], function() installpart("engine", 2) end, function() TorqueBoost = 2 end},
        {"EMS Upgrade, Level 3", enginepricelist[3], function() installpart("engine", 3) end, function() TorqueBoost = 3 end},
        {"EMS Upgrade, Level 4", enginepricelist[4], function() installpart("engine", 4) end, function() TorqueBoost = 4 end},
    }

    local brakelist = {
        {"Stock Brakes", brakepricelist[1], function() installpart("brakes", 1) end, function() BrakingBoost = 1 end},
        {"Street Brakes", brakepricelist[2], function() installpart("brakes", 2) end, function() BrakingBoost = 2 end},
        {"Sport Brakes", brakepricelist[3], function() installpart("brakes", 3) end, function() BrakingBoost = 3 end},
        {"Race Brakes", brakepricelist[4], function() installpart("brakes", 4) end, function() BrakingBoost = 4 end},
    }

    local tirelist = {
        {"Stock Tires", tirepricelist[1], function() installpart("tires", 1) end, function() TractionBoost = 1 end},
        {"Street Tires", tirepricelist[2], function() installpart("tires", 2) end, function() TractionBoost = 2 end},
        {"Sport Tires", tirepricelist[3], function() installpart("tires", 3) end, function() TractionBoost = 3 end},
        {"Race Tires", tirepricelist[4], function() installpart("tires", 4) end, function() TractionBoost = 4 end},
    }

    local respraylist = {
        {"White", colorpricelist[1], function() installpart("color", 1) end, function() car:SetColor(colorlist[1]) end},
        {"Light Gray", colorpricelist[2], function() installpart("color", 2) end, function() car:SetColor(colorlist[2]) end},
        {"Dark Gray", colorpricelist[3], function() installpart("color", 3) end, function() car:SetColor(colorlist[3]) end},
        {"Black", colorpricelist[4], function() installpart("color", 4) end, function() car:SetColor(colorlist[4]) end},
        {"Pink", colorpricelist[5], function() installpart("color", 5) end, function() car:SetColor(colorlist[5]) end},
        {"Red", colorpricelist[6], function() installpart("color", 6) end, function() car:SetColor(colorlist[6]) end},
        {"Dark Red", colorpricelist[7], function() installpart("color", 7) end, function() car:SetColor(colorlist[7]) end},
        {"Orange", colorpricelist[8], function() installpart("color", 8) end, function() car:SetColor(colorlist[8]) end},
        {"Yellow", colorpricelist[9], function() installpart("color", 9) end, function() car:SetColor(colorlist[9]) end},
        {"Purple", colorpricelist[10], function() installpart("color", 10) end, function() car:SetColor(colorlist[10]) end},
        {"Cyan", colorpricelist[11], function() installpart("color", 11) end, function() car:SetColor(colorlist[11]) end},
        {"Blue", colorpricelist[12], function() installpart("color", 12) end, function() car:SetColor(colorlist[12]) end},
        {"Dark Blue", colorpricelist[13], function() installpart("color", 13) end, function() car:SetColor(colorlist[13]) end},
        {"Lime", colorpricelist[14], function() installpart("color", 14) end, function() car:SetColor(colorlist[14])  end},
        {"Green", colorpricelist[15], function() installpart("color", 15) end, function() car:SetColor(colorlist[15]) end},
    }
    local underglowlist = {
        {"No underglow", underglowpricelist[1], function() installpart("underglow", 1) end},
        {"White", underglowpricelist[2], function() installpart("underglow", 2) end},
        {"Light Gray", underglowpricelist[3], function() installpart("underglow", 3) end},
        {"Pink", underglowpricelist[4], function() installpart("underglow", 4) end},
        {"Red", underglowpricelist[5], function() installpart("underglow", 5) end},
        {"Dark Red", underglowpricelist[6], function() installpart("underglow", 6) end},
        {"Orange", underglowpricelist[7], function() installpart("underglow", 7) end},
        {"Yellow", underglowpricelist[8], function() installpart("underglow", 8) end},
        {"Purple", underglowpricelist[9], function() installpart("underglow", 9) end},
        {"Cyan", underglowpricelist[10], function() installpart("underglow", 10) end},
        {"Blue", underglowpricelist[11], function() installpart("underglow", 11) end},
        {"Dark Blue", underglowpricelist[12], function() installpart("underglow", 12) end},
        {"Lime", underglowpricelist[13], function() installpart("underglow", 13) end},
        {"Green", underglowpricelist[14], function() installpart("underglow", 14) end},
    }
    local mainmenulist = {
        {"Armor", "", function() List:ParseTable(armorlist, car:GetNWInt("GTA_armor")) end},
        {"Engine", "", function() List:ParseTable(enginelist, car:GetNWInt("GTA_engine")) end},
        {"Brakes", "", function() List:ParseTable(brakelist, car:GetNWInt("GTA_brakes")) end},
        {"Tires", "", function() List:ParseTable(tirelist, car:GetNWInt("GTA_tires")) end},
        {"Underglow", "", function() List:ParseTable(underglowlist, car:GetNWInt("GTA_underlight")) end},
        {"Respray", "", function() List:ParseTable(respraylist, car:GetNWInt("GTA_color")) end},
    }
    List.DataLayout = function()
        local y = 0
        local h = 35
    
        for k, Line in ipairs(List.Sorted) do
            Line:SetPos(10, y)
            Line:SetSize(List:GetWide() - 20, h)
            Line:DataLayout(List)
            y = y + Line:GetTall()
        end
        return y
    end

    List.Paintit = function()
        for k, line in ipairs(List:GetLines()) do
            line:SetAltLine(false)
            line.Paint = function(me,w,h)
                if line:IsHovered() then
                    surface.SetDrawColor(hoverColor)
                    line.Columns[1]:SetTextColor(BlackColor)
                    line.Columns[2]:SetTextColor(BlackColor)
                    surface.DrawRect(0,0,w,h)
                    local ourfunc = line:GetValue(4)
                    if isfunction(ourfunc) then
                        ourfunc()
                    end
                else
                    surface.SetDrawColor(nocolor)
                    line.Columns[1]:SetTextColor(White)
                    line.Columns[2]:SetTextColor(White)
                    surface.DrawRect(0,0,w,h)
                end
            end
            line.Columns[1]:SetTextColor(White)
            line.Columns[2]:SetTextColor(White)
            line.Columns[1]:SetFont("GModNotify")
            line.Columns[2]:SetFont("GModNotify")
            line.Columns[2]:SetTextInset(110,0)
        end
    end
    List:Paintit()

    List.ParseTable = function(idk, tbl, installedpart)
        List:Clear()
        for k, v in pairs(tbl) do
            if installedpart then
                if k == installedpart then
                    List:AddLine("● "..v[1],DarkRP.formatMoney(v[2]), v[3], v[4])
                else
                    List:AddLine(v[1], DarkRP.formatMoney(v[2]), v[3], v[4])
                end
            else
                List:AddLine(v[1],v[2], v[3], v[4])
            end
        end
        List:Paintit()
    end

    List.ParseTable(false, mainmenulist)

    function ResetColor() 
        net.Start("gta_tune_get_color")
        net.SendToServer()
    end

    function installpart(str, level)
        net.Start("gta_tune_install_part")
        net.WriteString(str)
        net.WriteUInt(level, 6)
        net.SendToServer()

        -- List.ParseTable(false, mainmenulist)
        -- submenu = false
        -- ResetColor()
        -- 
    end


    local kill = GTA_TUNE.Menu:Add("DButton")
    kill:SetText("")
    kill:SetPos(200-380/2, MenuHeight-230)
    kill:SetSize(380, 40)
    kill.DoClick = function()
        if submenu then
            List.ParseTable(false, mainmenulist)
            submenu = false
            ResetColor() 
        else
            net.Start("simfphys_startengine")
            net.WriteEntity(car)
            net.SendToServer()            
        end
    end

    kill.Paint = function(me,w,h)
		surface.SetDrawColor(GrayColor)
		surface.DrawRect(0,0,w,h)
        if submenu then
            draw.DrawText("BACK", "GModNotify", 190, 10, White, TEXT_ALIGN_CENTER)
        else
            draw.DrawText("EXIT", "GModNotify", 190, 10, White, TEXT_ALIGN_CENTER)
        end
    end

    local stat1 = GTA_TUNE.Menu:Add("DLabel")
    stat1:SetText("Top Speed")
    stat1:SetSize(200, 32)
    stat1:SetPos(20,MenuHeight-170)
    stat1:SetTextColor(White)
    stat1:SetFont("GModNotify")

    local stat2 = GTA_TUNE.Menu:Add("DLabel")
    stat2:SetText("Peak Torque")
    stat2:SetSize(200, 32)
    stat2:SetPos(20,MenuHeight-130)
    stat2:SetTextColor(White)
    stat2:SetFont("GModNotify")

    local stat3 = GTA_TUNE.Menu:Add("DLabel")
    stat3:SetText("Braking")
    stat3:SetSize(200, 32)
    stat3:SetPos(20,MenuHeight-90)
    stat3:SetTextColor(White)
    stat3:SetFont("GModNotify")

    local stat4 = GTA_TUNE.Menu:Add("DLabel")
    stat4:SetText("Traction")
    stat4:SetSize(200, 32)
    stat4:SetPos(20,MenuHeight-50)
    stat4:SetTextColor(White)
    stat4:SetFont("GModNotify")

    -- ⦿ ● 

    List.OnRowSelected = function(lst, index, pnl)
        pnl:GetValue(3)()
        submenu = true
    end

    net.Receive( "gta_tune_install_part", function()
        if not car:IsValid() then return end
        if net.ReadBool() then
            if IsValid(GTA_TUNE.Menu) then
                GTA_TUNE.Menu:Remove()
                GTA_TUNE.OpenMenu()
            end
        end
    end)
end
local drawhint = false

net.Receive( "gta_tune_get_color", function()
    local car = LocalPlayer():GetSimfphys()
    if not car:IsValid() then return end
    car:SetColor(net.ReadColor())
end)



net.Receive("gta_tune_open", function()   
    GTA_TUNE.OpenMenu()
    drawhint = false
end)

net.Receive("gta_tune_close", function()   
    if IsValid(GTA_TUNE.Menu) then
        GTA_TUNE.Menu:Remove()
    end
end)

local lift
local hint_alpha = 0

net.Receive("gta_tune_hudhint", function(len, ply)   
    if not IsValid(GTA_TUNE.Menu) and not drawhint then
        lift = net.ReadEntity()
        drawhint = true
        hint_alpha = 1
    end
end)


local key_bg = Material("key_bg_start.png", "noclamp smooth")
local key_bg2 = Material("key_bg_md.png", "noclamp smooth")
local key_bg3 = Material("key_bg_end.png", "noclamp smooth")
local key = string.upper(language.GetPhrase(input.GetKeyName(GetConVar("cl_simfphys_keyengine"):GetInt()))) -- жж
local width

local offset = 0

surface.SetFont("Trebuchet24")
local getrealwidth = select(1, surface.GetTextSize(key))
if getrealwidth < 24 then
    width = 24
    offset = 11-getrealwidth/2
else
    width = getrealwidth
end

hook.Add( "HUDPaint", "gta_tune_engine_hint", function()
    local ply = LocalPlayer()
    if not IsValid( ply ) or not ply:Alive() then return end
    local vehiclebase = ply:GetSimfphys()
    if not vehiclebase:IsValid() then drawhint = false hint_alpha = 0 return end
    ply.lift_nextcheck = isnumber(ply.lift_nextcheck) and ply.lift_nextcheck or 0

    if ply.lift_nextcheck < CurTime() then
        if lift and lift:IsValid() then
            if lift:GetPos():DistToSqr(vehiclebase:GetPos()) > 7000 then drawhint = false end
            ply.lift_nextcheck = CurTime() + 0.6
        end
    end
    if hint_alpha < 240 and drawhint then
        hint_alpha = hint_alpha + 10
    elseif not drawhint and hint_alpha > 10 then
        hint_alpha = hint_alpha - 10
    end
    
    if not IsValid(vehiclebase) then return end

    surface.SetFont("Trebuchet24")
    surface.SetAlphaMultiplier(hint_alpha/255)
    draw.RoundedBox(15, 70, scrh2-30, 186+width, 61, GrayColor)
    surface.SetDrawColor(255,255,255,255)
    surface.SetMaterial(key_bg)
    surface.DrawTexturedRect(80, scrh2-24, 13, 48)

	surface.SetTextColor(255, 255, 255)
	surface.SetTextPos(93+offset, scrh2-17) 
	surface.DrawText(key)
    
    surface.SetTextPos(120+width, scrh2-13) 
	surface.DrawText("Stop Engine")

    surface.SetMaterial(key_bg2)
    surface.DrawTexturedRect(93, scrh2-24, width, 48)
    surface.SetMaterial(key_bg3)
    surface.DrawTexturedRect(93+width, scrh2-24, 13, 48)


    surface.SetAlphaMultiplier(1) --just for safe
end)


hook.Add("RenderScreenspaceEffects", "GTA_Neonlights", function()
    for k, ent in pairs(ents:GetAll()) do
        if IsValid(ent) then
            if ent:GetClass() == "gmod_sent_vehicle_fphysics_base" then
                ent.RenderOverride = function()
                    ent:DrawModel()
                    local level = ent:GetNWInt("GTA_underlight")
                    if level > 0 then
                        if LocalPlayer():GetPos():DistToSqr(ent:GetPos())<900000 then
                            local dlight = DynamicLight(ent:EntIndex())
                            if dlight then
                                dlight.pos = ent:GetPos()
                                dlight.r = GTA_TUNE.underglowlist[level].r
                                dlight.g = GTA_TUNE.underglowlist[level].g
                                dlight.b = GTA_TUNE.underglowlist[level].b
                                dlight.brightness = 8
                                dlight.nomodel = true
                                dlight.Decay = 1
                                dlight.Size = 100
                                dlight.DieTime = CurTime() + 0.1
                            end
                        end
                    end
                end
            end
        end
    end
end)