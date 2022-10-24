ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Car Lift"
ENT.Author = "Darky"
ENT.Category = "Other"

ENT.Spawnable = true
ENT.AdminSpawnable = false


GTA_TUNE = {}

GTA_TUNE.armorpricelist = {  -- Armor upgrade Pricelist
    2000, -- Level 1
    4000, -- Level 2
    6000, -- Level 3
    8000, -- Level 4
    10000, -- Level 5
}

GTA_TUNE.enginepricelist = {  -- Engine upgrade Pricelist
    3600, -- Level 1
    5000, -- Level 2
    7200, -- Level 3
    10000, -- Level 4
}

GTA_TUNE.brakepricelist = { -- Brake upgrade Pricelist
    2000, -- Level 1
    4000, -- Level 2
    6000, -- Level 3
    8000, -- Level 4
}

GTA_TUNE.tirepricelist = { -- Tire upgrade Pricelist
    2000, -- Level 1
    4000, -- Level 2
    6000, -- Level 3
    8000, -- Level 4
}

GTA_TUNE.colorpricelist = { -- Respray Pricelist
    500, -- White
    500, -- Light Gray
    500, -- Dark Gray
    500, -- Black
    1500, -- Pink
    1000, -- Red
    1000, -- Dark Red
    1000, -- Orange
    1500, -- Yellow
    1500, -- Purple
    1500, -- Cyan
    1000, -- Blue
    1000, -- Dark Blue
    1500, -- Lime
    1000, -- Green
}

GTA_TUNE.underglowpricelist = { -- Respray Pricelist
    0, -- no
    2000, -- White
    1900, -- Light Gray
    2500, -- Pink
    2500, -- Red
    2000, -- Dark Red
    2000, -- Orange
    2000, -- Yellow
    2500, -- Purple
    2500, -- Cyan
    2000, -- Blue
    2000, -- Dark Blue
    3000, -- Lime
    2000, -- Green
}

GTA_TUNE.colorlist = { -- Colors itself
    Color(255,255,255),
    Color(150,150,150),
    Color(51,51,51),
    Color(0,0,0),
    Color(255,0,140),
    Color(255,0,0),
    Color(124,0,0),
    Color(255,102,0),
    Color(255,255,0),
    Color(225,0,255),
    Color(0,255,255),
    Color(0,120,255),
    Color(0,0,255),
    Color(0,255,0),
    Color(0,160,0),
}

GTA_TUNE.underglowlist = { -- Underglow colors
    Color(0,0,0),
    Color(255,255,255),  
    Color(150,150,150),
    Color(255,0,140),
    Color(255,0,0),
    Color(124,0,0),
    Color(255,102,0),
    Color(255,255,0),
    Color(225,0,255),
    Color(0,255,255),
    Color(0,120,255),
    Color(0,0,255),
    Color(0,255,0),
    Color(0,160,0),
}

GTA_TUNE.upgradePerLevel = {
    100, -- +100 health per level 
    50, -- +50 peak torque per level
    15, -- +15 braking power per level
    8, -- +8 traction per level
}

GTA_TUNE.maxUpgrades = {
    4375*1.5, -- MaxSpeed
    75*1.5, -- MaxTraction
    450*1.5, -- MaxTorque
    100*1.5, -- MaxBraking
}