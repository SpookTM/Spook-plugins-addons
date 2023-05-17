if(SERVER) then
	util.AddNetworkString("sh_tfa_support")
end
local PLUGIN = PLUGIN


PLUGIN.GunData = {}
ix.util.Include("sh_tfa_weps.lua")

PLUGIN.AttachData = {}
ix.util.Include("sh_tfa_attach.lua")

PLUGIN.AmmoData = {}
ix.util.Include("sh_tfa_ammo.lua")

if CLIENT then
	function PLUGIN:PopulateItemTooltip( tooltip, item )
		if item.Attachments and not table.IsEmpty( item.Attachments ) then
			local text = "Modifications: "

			local mods = item:GetData( "mods", {} )
			local already = {}

			if not table.IsEmpty( mods ) then
				for k, v in next, mods do
					already[ v ] = true
					text = text .. "\n  +" .. ( ( ix.item.list[ v ] and ix.item.list[ v ].name ) or v )
				end
			end

			for k, v in next, item.Attachments do
				if not already[ k ] then
					local att = ix.item.list[ k ]
					if att then
						text = text .. "\n  -" .. att.name
					end
				end
			end

			local row = tooltip:AddRowAfter( "description", "modsList" )
			row:SetText( text )
			row:SetBackgroundColor( derma.GetColor( "Info", tooltip ) )
			row:SizeToContents()
		end
	end
end

function PLUGIN:InitializedPlugins()
	for k, v in next, weapons.GetList() do
		local class = v.ClassName
		local dat = self.GunData[ class ]
		
		
		if dat then
			if dat.BlackList then
				continue
			end
		else
			if self.DoAutoCreation and class:find( "tfa_" ) and not class:find( "base" ) then
				dat = {}
			else
				continue
			end
		end

		--v.MainBullet.Ricochet = function() return true end
		v.HandleDoor = function() return end
		v.Primary.DefaultClip = 0

		local orig_wep = weapons.GetStored( class )

		if dat.Prim and not table.IsEmpty( dat.Prim ) then
			for k2, v2 in next, dat.Prim do
				if v.Primary[ k2 ] then
					v.Primary[ k2 ] = v2
				end
			end
		end

		if dat.Sec and not table.IsEmpty( dat.Sec ) then
			for k2, v2 in next, dat.Sec do
				if v.Secondary[ k2 ] then
					v.Secondary[ k2 ] = v2
				end
			end
		end

		local ITEM = ix.item.Register( class, "base_weapons", nil, nil, true )

		ITEM.name = dat.Name or orig_wep.PrintName
		ITEM.price = dat.Price or 4000
		ITEM.exRender = dat.exRender or false
		ITEM.class = class
		ITEM.IsTFA = true
		ITEM.DoEquipSnd = true
		
		if dat.iconCam then
			ITEM.iconCam = dat.iconCam
		end

		local atts = {}
		if v.Attachments then
			for k, v in next, v.Attachments do
				if v.atts then
					for k2, v2 in next, v.atts do
						table.Merge( atts, { [ v2 ] = true } )
					end
				end
			end
		end
		ITEM.Attachments = atts

		if dat.Weight then
			ITEM.Weight = dat.Weight
		end

		if dat.DurCh then
			ITEM.DurCh = dat.DurCh
		end

		ITEM:Hook( "drop", function( item )
			item.player:EmitSound( "physics/metal/metal_box_footstep1.wav" ) 
		end )

		ITEM.model = dat.Model or v.WorldModel
		ITEM.ammotype = v.Primary.Ammo

		ITEM.width = dat.Width or 1
		ITEM.height = dat.Height or 1
		ITEM.weaponCategory = "primary" .. k
		if(v.Primary.Ammo) then
			local k = v.Primary.Ammo
			local ammotype = v.Primary.Ammo
			ix.ammo.Register( k )

			local ITEM = ix.item.Register( "mag_" .. k,nil , nil , nil , true )
			ITEM.name = v.Name or k .. " Mag"
			ITEM.ammo = k
			ITEM.ammoAmount = v.Primary.ClipSize or 30
			ITEM.price = v.Price or 200
			ITEM.category = "Mags"
			ITEM.isgoodammo  =true
			ITEM.model = "models/viper/mw/attachments/attachment_vm_pi_golf21_mag_xmags2.mdl"
			if v.iconCam then
				ITEM.iconCam = v.iconCam
			end
			ITEM.width = v.Width or 1
			ITEM.height = v.Height or 1

			function ITEM:GetDescription()
				return "" .. self:GetData("ammo" , self.ammoAmount) .. "/" .. self.ammoAmount
			end
			function ITEM:PaintOver(item, w, h)
				local x, y = w - 30, h - 14
				surface.SetDrawColor( 255, 255, 255, 100 )
				surface.SetTextPos( x, y ) 
				surface.DrawText(item:GetData("ammo" , item.ammoAmount) .. "/" .. item.ammoAmount )

			end
			ITEM:Hook( "drop", function(item)
				item.player:EmitSound( "physics/metal/metal_box_footstep1.wav" ) 
			end )
			ITEM.functions.combine = {
				OnRun = function(firstItem, data)
					local targets = {}
					local second = ix.item.instances[data[1]]
					if second.isgoodgoodammo and firstItem.ammo and firstItem.ammo == second.ammo then
						local client = firstItem.player
						if(firstItem:GetData("ammo" , firstItem.ammoAmount) + second:GetData("ammo" , second.ammoAmount) > firstItem.ammoAmount) then
							firstItem:SetData("ammo" , firstItem.ammoAmount)  
							second:SetData("ammo" , second:GetData("ammo" ,second.ammoAmount ) - firstItem.ammoAmount)
							if(second:GetData("ammo" ,second.ammoAmount ) < 0 ) then
								second:Remove()
							end
						else
							firstItem:SetData("ammo" ,firstItem:GetData("ammo" , 0) +  second:GetData("ammo" ,second.ammoAmount ))  
							second:Remove()
						end
						return false
					end
					return false
	
				end,
				OnCanRun = function(firstItem, data)
					return true
				end
			}	

			ITEM.functions.use = {
				name = "Equip",
				tip = "useTip",
				icon = "icon16/wrench.png",
				isMulti = true,
				multiOptions = function( item, client )
					local targets = {}
	
					for k, v in next, client:GetCharacter():GetInventory():GetItems() do
						if v.isWeapon and v.IsTFA and v.ammotype and v.ammotype == ammotype  then
							table.insert( targets, {
								name = v.name,
								data = { v.id },
							} )
						end
					end
	
					return targets
				end,
				OnCanRun = function( item )
					local client = item.player
					return !IsValid(item.entity) and IsValid(client) and item.invID == client:GetCharacter():GetInventory():GetID()
				end,
				OnRun = function( item, data )
					if data and data[1] then
						local wep_itm = item.player:GetCharacter():GetInventory():GetItemByID( data[1], true )
						if not wep_itm then return false end
						if(wep_itm:GetData("magstatus" , false) == true) then item.player:Notify('Already has mag') return false end
						wep_itm:SetData("magstatus" , true)
						wep_itm:SetData("mag" , item:GetData("ammo" , item.ammoAmount))
						if(wep_itm:GetData("equip" ) and wep_itm.class) then
							local wep = item.player:GetWeapon( wep_itm.class )
							wep:SetClip1(item:GetData("ammo" , item.ammoAmount))
						end
						return true
					end
	
					return false
				end,			
			}

		end

		if(v.Primary.Ammo) then
			local k = v.Primary.Ammo
			local ammotype = v.Primary.Ammo
			ix.ammo.Register( k )

			local ITEM = ix.item.Register( "ammo_" .. k,nil , nil , nil , true )
			ITEM.name = v.Name or k .. " ammo"
			ITEM.ammo = k
			ITEM.ammoAmount = 30
			ITEM.price = v.Price or 200
			ITEM.category = "Ammo"
			ITEM.isgoodgoodammo  =true
			ITEM.isgoodammo = false
			ITEM.model = "models/Items/BoxSRounds.mdl"
			if v.iconCam then
				ITEM.iconCam = v.iconCam
			end
			ITEM.width = v.Width or 1
			ITEM.height = v.Height or 1

			function ITEM:GetDescription()
				return "" .. self:GetData("ammo" , self.ammoAmount) .. "/" .. self.ammoAmount
			end
			function ITEM:PaintOver(item, w, h)
				local x, y = w - 30, h - 14
				surface.SetDrawColor( 255, 255, 255, 100 )
				surface.SetTextPos( x, y ) 
				surface.DrawText(item:GetData("ammo" , item.ammoAmount) .. "/" .. item.ammoAmount )

			end
			ITEM:Hook( "drop", function(item)
				item.player:EmitSound( "physics/metal/metal_box_footstep1.wav" ) 
			end )
		end
		function ITEM:OnEquipWeapon( ply, wep )
			local data = self:GetData( "mods", {} )
			if(wep.allowedmods == nil) then
				wep.allowedmods = {}
			end
			net.Start('sh_tfa_support')
			net.WriteEntity(wep)
			net.WriteTable(wep.allowedmods)
			net.Send(self.player)
			local z = wep.ixItem:GetData("mag" , 0) or 0
			wep:SetClip1(z)
			if not table.IsEmpty( data ) then
				timer.Simple( 0.2, function()
					if IsValid( wep ) then
						for k, v in next, data do
							if self.Attachments[ v ] then
								--wep:Attach( v )

								wep.allowedmods[v] = true
								net.Start('sh_tfa_support')
								net.WriteEntity(wep)
								net.WriteTable(wep.allowedmods)
								net.Send(self.player)
							end
						end
					end
				end )
			end
		end
		function ITEM:OnUnequipWeapon(client, weapon)
			self:SetData("mag" , weapon:Clip1() or 0) 
		end

		function ITEM:PaintOver(item, w, h)
			local x, y = w - 14, h - 14

			if item:GetData( "equip" ) then
				surface.SetDrawColor( 110, 255, 110, 100 )
				surface.DrawRect( x, y, 8, 8 )

				x = x - 8 * 1.6
			end

			if not table.IsEmpty( item:GetData( "mods", {} ) ) then
				surface.SetDrawColor( 255, 255, 110, 100 )
				surface.DrawRect( x, y, 8, 8 )

				x = x - 8 * 1.6
			end

			if  item:GetData( "magstatus", false) == true   then
				surface.SetDrawColor( 255, 150, 110, 100 )
				surface.DrawRect( x, y, 8, 8 )

				x = x - 8 * 1.6
			end
		end

		function ITEM:GetDescription()
			local text = ""

			if v.Primary.Ammo and v.Primary.ClipSize then
				local ammo_itm = ix.item.list[ "ammo_" .. v.Primary.Ammo ]
				text = text .. "Using ammo: " .. ( ( ammo_itm and ammo_itm.name ) or v.Primary.Ammo ) .. ".\nMagazine : " .. self:GetData("mag",0) .. "/" .. v.Primary.ClipSize .. ".\n" 
			end

			return text
		end

		function ITEM:OnInstanced()
			if self:GetData( "mods" ) == nil then
				self:SetData( "mods", {} )
			end
			
		end
		ITEM.functions.combine = {
			OnRun = function(firstItem, data)
				local targets = {}
				local second = ix.item.instances[data[1]]
				local client = firstItem.player
				client:EmitSound( "weapons/crossbow/reload1.wav" )
				if second.isgoodammo and firstItem.ammotype and firstItem.ammotype == second.ammo and firstItem:GetData("magstatus" , false) == false then
					local wep_itm = firstItem
					local item = second

					if not wep_itm then return false end
					if(wep_itm:GetData("magstatus" , false) == true) then client:Notify('Already has mag') return false end
					wep_itm:SetData("magstatus" , true)
					wep_itm:SetData("mag" , item:GetData("ammo" , item.ammoAmount))
					if(wep_itm:GetData("equip" ) and wep_itm.class) then
						local wep = client:GetWeapon( wep_itm.class )
						wep:SetClip1(item:GetData("ammo" , item.ammoAmount))
					end
					second:Remove()

					return false
				end
				return false


			end,
			OnCanRun = function(firstItem, data)
				return true
			end
		}	
		ITEM.functions.unload = {
			name = "Unload",
			tip = "unload",
			icon = "icon16/delete.png",
			OnCanRun = function( item )			
                return item:GetData( "magstatus", false ) 
			end,
			OnRun = function( item, data )
				local client = item.player
				local x, y, id = client:GetCharacter():GetInventory():Add( "mag_" .. item.ammotype )
				if not id then
					client:NotifyLocalized( "noFit" )
					return false
				end
				local wep = client:GetWeapon( item.class )
				if IsValid( wep ) then
					item:SetData("mag" , wep:Clip1())
					wep:SetClip1(0)
				end
				client:GetCharacter():GetInventory():GetItemAt(x,y):SetData("ammo",item:GetData("mag",0))
				item:SetData("magstatus" , false)
				item:SetData("mag" , 0)




				
				client:EmitSound( "weapons/crossbow/reload1.wav" )

				return false
			end,
		}
		ITEM.functions.detach = {
			name = "Dequip",
			tip = "useTip",
			icon = "icon16/wrench.png",
            isMulti = true,
            multiOptions = function( item, client )
                local targets = {}

                for k, v in next, item:GetData( "mods", {} ) do
                    table.insert( targets, {
                        name = ( ix.item.list[ v ] and ix.item.list[ v ].name ) or v,
                        data = { k, v },
                    } )
                end

                return targets
            end,
			OnCanRun = function( item )			
                return not IsValid( item.entity ) and IsValid( item.player ) and item.invID == item.player:GetCharacter():GetInventory():GetID() and not table.IsEmpty( item:GetData( "mods", {} ) )
			end,
			OnRun = function( item, data )
				if data and data[1] and data[2] then
					local mods = item:GetData( "mods", {} )
					if not mods[ data[1] ] then return false end

					local x, y, id = item.player:GetCharacter():GetInventory():Add( data[2] )
					if not id then
						item.player:NotifyLocalized( "noFit" )
						return false
					end

					mods[ data[1] ] = nil
					item:SetData( "mods", mods )

					item.player:EmitSound( "weapons/crossbow/reload1.wav" )

					local wep = item.player:GetWeapon( item.class )
					if IsValid( wep ) then
						--wep:Detach( data[2] )
						if(wep.allowedmods == nil) then
							wep.allowedmods = {}
						end
						wep.allowedmods[data[2]] = false
						net.Start('sh_tfa_support')
						net.WriteEntity(wep)
						net.WriteTable(wep.allowedmods)
						net.Send(item.player)
					end
				end

				return false
			end,
		}

	end


	for k, v in next, TFA.Attachments.Atts do
		local ITEM = ix.item.Register( k, nil, nil, nil, true )
		ITEM.name = v.Name
		ITEM.price = v.Price or 300
		ITEM.model = v.Model or "models/Items/BoxSRounds.mdl"
		if v.iconCam then
			ITEM.iconCam = v.iconCam
		end
		ITEM.width = v.Width or 1
		ITEM.height = v.Height or 1
		ITEM.isAttachment = true
		ITEM.category = "Attachments"
        ITEM.slot = v.ShortName

        function ITEM:GetDescription()
			return v.Desc
		end

		ITEM.functions.use = {
			name = "Equip",
			tip = "useTip",
			icon = "icon16/wrench.png",
			isMulti = true,
			multiOptions = function( item, client )
				local targets = {}

				for k, v in next, client:GetCharacter():GetInventory():GetItems() do
					if v.isWeapon and v.IsTFA and v.Attachments and v.Attachments[ item.uniqueID ] then
						table.insert( targets, {
							name = v.name,
							data = { v.id },
						} )
					end
				end

				return targets
			end,
			OnCanRun = function( item )
				local client = item.player
				return !IsValid(item.entity) and IsValid(client) and item.invID == client:GetCharacter():GetInventory():GetID()
			end,
			OnRun = function( item, data )
				if data and data[1] then
					local wep_itm = item.player:GetCharacter():GetInventory():GetItemByID( data[1], true )
					if not wep_itm then return false end

					if not wep_itm.Attachments or not wep_itm.Attachments[ item.uniqueID ] then return false end

					local mods = wep_itm:GetData( "mods", {} )
					if mods[ item.slot ] then
						item.player:Notify( "This type of item is already mounted on the weapon!" )
						return false
					else
						mods[ item.slot ] = item.uniqueID
						wep_itm:SetData( "mods", mods )

						item.player:EmitSound( "weapons/crossbow/reload1.wav" )

						local wep = item.player:GetWeapon( wep_itm.class )
						if IsValid( wep ) then

							--wep:Attach( item.uniqueID )
							if(wep.allowedmods == nil) then
								wep.allowedmods = {}
							end
							wep.allowedmods[item.uniqueID] = true
							net.Start('sh_tfa_support')
							net.WriteEntity(wep)
							net.WriteTable(wep.allowedmods)
							net.Send(item.player)
						end

						return true
					end
				end

				return false
			end,
		}
	end
end
net.Receive('sh_tfa_support', function()
	if(SERVER) then return end
	local wep = net.ReadEntity()
	local tbl = net.ReadTable()
	wep.allowedmods = tbl
end)
hook.Add("TFA_PreCanAttach"  , "tfacheckattach", function(wep,att)
	if(wep.allowedmods == nil) then return true end
	if(wep.allowedmods[att] != true ) then return false end


end)
