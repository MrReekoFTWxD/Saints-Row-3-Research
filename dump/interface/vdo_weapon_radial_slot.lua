-- Inherited from Vdo_base_object
Vdo_weapon_radial_slot = Vdo_base_object:new_base()


WEAPON_SLOT_STATE_DISABLED 	= 0
WEAPON_SLOT_STATE_ENABLED 		= 1
WEAPON_SLOT_STATE_HIGHLIGHTED = 2

local Weapon_store_images = {
	[1] = "uhd_ui_hud_inv_gen_melee",
	[2] = "uhd_ui_hud_inv_gen_pistol",
	[3] = "uhd_ui_hud_inv_gen_smg",
	[4] = "uhd_ui_hud_inv_gen_shotgun",
	[5] = "uhd_ui_hud_inv_gen_rifle",
	[6] = "uhd_ui_hud_inv_gen_explosive",
	[7] = "uhd_ui_hud_inv_gen_spc",
	[8] = "uhd_ui_hud_inv_gen_grenade",
	[9] = "uhd_ui_hud_inv_gen_molotov",
	[10] = "uhd_ui_hud_inv_gen_flash",
	[11] = "uhd_ui_hud_inv_gen_electric",
	[12] = "uhd_ui_hud_inv_gen_melee",
}

--Local Constants
local AMMO_ANGLE_FULL 	= PI2 * -1
local AMMO_ANGLE_EMPTY 	= -4.7

local Vdo_weapon_radial_slot_dual_1_x = 	0
local Vdo_weapon_radial_slot_dual_1_y = 	0
local Vdo_weapon_radial_slot_dual_2_x =	0 
local Vdo_weapon_radial_slot_dual_2_y = 	0



function vdo_weapon_radial_slot_init()
	local dual_1_h = vint_object_find("dual_inv_1_bmp")
	local dual_2_h = vint_object_find("dual_inv_2_bmp")
	Vdo_weapon_radial_slot_dual_1_x, Vdo_weapon_radial_slot_dual_1_y = vint_get_property(dual_1_h, "anchor")
	Vdo_weapon_radial_slot_dual_2_x, Vdo_weapon_radial_slot_dual_2_y = vint_get_property(dual_2_h, "anchor")
end

function Vdo_weapon_radial_slot:init()

	--Member Variables
	self.slot_num = -1         --not used, just for debugging
	self.weapon_name_crc = - 1	--crc for name of item
	self.weapon_bmp = -1 		--Weapon Bitmap, if set to nil the no weapon
	self.ammo_cur = -1			--Current ammount of ammo for clip
	self.ammo_max = -1			--Maximum ammount of ammo for clip
	self.ammo_infinite = -1 	--Do we have infinite ammo?
	self.dual_wield = -1 		--Is weapon Dual wield?
	self.weapon_bmp_name = -1	--Bitmap name for weapon
	self.level = -1				--What is the current weapon level
	self.availability = -1		--Is the weapon available
	self.ammo_type = -1			--Bitmap for ammo type
	self.is_outline = false		--Is icon a placeholder outline?

end
function Vdo_weapon_radial_slot:cleanup()
end


function Vdo_weapon_radial_slot:update(slot_num, availability, weapon_name_crc, weapon_bmp_name, ammo_cur, ammo_max, dual_wield, ammo_infinite, level, ammo_type, store_mode_is_enabled)

	--Find bitmap references to update
	local ammo_bar_fill_bmp = Vdo_base_object:new("ammo_circle", self.handle, self.doc_handle)
	local ammo_bar_bg_bmp = Vdo_base_object:new("ammo_bg", self.handle, self.doc_handle)
	local infinity_bmp = Vdo_base_object:new("infinity_bmp", self.handle, self.doc_handle)
			
	--Ammo Update
	if ammo_cur ~= self.ammo_cur or ammo_max ~= self.ammo_max or ammo_infinite ~= self.ammo_infinite then

		if ammo_max == 0 then
			--No ammo clip, hide ammo bar and infinity symbol
			ammo_bar_fill_bmp:set_visible(false)
			ammo_bar_bg_bmp:set_visible(false)
			infinity_bmp:set_visible(false)

			self.ammo_infinite = -1
		else

			--Ammo Bar Fill
			local ammo_percent = ammo_cur/ammo_max
			local angle = AMMO_ANGLE_EMPTY + (AMMO_ANGLE_FULL - AMMO_ANGLE_EMPTY) * ammo_percent
			ammo_bar_fill_bmp:set_property("start_angle", angle)
			
			--Do we show Infinity Symbol or Ammo bar?
			if ammo_infinite ~= self.ammo_infinite then
				if ammo_infinite == true then
					ammo_bar_fill_bmp:set_visible(false)
					ammo_bar_bg_bmp:set_visible(false)
					infinity_bmp:set_visible(true)
				else	
					ammo_bar_fill_bmp:set_visible(true)
					ammo_bar_bg_bmp:set_visible(true)
					infinity_bmp:set_visible(false)
				end	
				
				self.ammo_infinite = ammo_infinite
			end
			
			self.ammo_cur = ammo_cur
			self.ammo_max = ammo_max

		end	
	end

	--Modify weapon Bitmaps
	
	--Find objects to change weapon bitmaps
	local dual_inv_1_bmp = Vdo_base_object:new("dual_inv_1_bmp", self.handle, self.doc_handle)
	local dual_inv_2_bmp = Vdo_base_object:new("dual_inv_2_bmp", self.handle, self.doc_handle)
	
	if store_mode_is_enabled == false then
		local has_ammo = true
		if ammo_max >= 1 and ammo_cur < 1 then
			has_ammo = false
		end
		if availability and has_ammo then
			self:set_state(WEAPON_SLOT_STATE_HIGHLIGHTED)
		else
			self:set_state(WEAPON_SLOT_STATE_DISABLED)
		end
	end
	
	if weapon_name_crc ~= self.weapon_name_crc or dual_wield ~= self.dual_wield then
	
		if weapon_bmp_name == nil then
			--No weapon, so hide other elements
			local ammo_bar_fill_bmp = Vdo_base_object:new("ammo_circle", self.handle, self.doc_handle)
			local ammo_bar_bg_bmp = Vdo_base_object:new("ammo_bg", self.handle, self.doc_handle)
			local infinity_bmp = Vdo_base_object:new("infinity_bmp", self.handle, self.doc_handle)
			ammo_bar_fill_bmp:set_visible(false)
			ammo_bar_bg_bmp:set_visible(false)
			infinity_bmp:set_visible(false)
			if slot_num < 8 then
				dual_inv_1_bmp:set_visible(false)
				dual_inv_2_bmp:set_visible(false)
			end
			
			-- Show placeholder weapon icon
			if store_mode_is_enabled then
				dual_inv_1_bmp:set_anchor(0, 0)
				dual_inv_1_bmp:set_image(Weapon_store_images[slot_num])
				dual_inv_1_bmp:set_visible(true)
				
				self.is_outline = true
			end
			
		else
			--Change Weapon bitmap
			dual_inv_1_bmp:set_image(weapon_bmp_name)
			dual_inv_2_bmp:set_image(weapon_bmp_name)

			--Check if Dual wielding for formating differences
			if dual_wield == true then	
				--Dual Wield Weapon
				dual_inv_1_bmp:set_visible(true)
				dual_inv_2_bmp:set_visible(true)
				
				--Reposition to stored values in init()
				dual_inv_1_bmp:set_anchor(Vdo_weapon_radial_slot_dual_1_x, Vdo_weapon_radial_slot_dual_1_y)
				dual_inv_2_bmp:set_anchor(Vdo_weapon_radial_slot_dual_2_x, Vdo_weapon_radial_slot_dual_2_y)
			else
				--Single Wield Weapon
				dual_inv_1_bmp:set_anchor(0, 0)
				dual_inv_1_bmp:set_visible(true)
				dual_inv_2_bmp:set_visible(false)
			end
				
			--Exception for layer depth for the following weapon bitmaps.
			--We want these bitmaps to draw in front of the ammo bar.
			if weapon_bmp_name == "uhd_ui_hud_inv_w_ar50grenade" or weapon_bmp_name == "uhd_ui_hud_inv_w_minigun" or weapon_bmp_name == "uhd_ui_hud_inv_w_flamethrower" then
				dual_inv_1_bmp:set_depth(-400)
				dual_inv_2_bmp:set_depth(-300)
			else
				dual_inv_1_bmp:get_depth(-200)
				dual_inv_2_bmp:get_depth(-100)
			end
		end
		
		self.dual_wield = dual_wield
		self.weapon_bmp_name = weapon_bmp_name
		self.weapon_name_crc = weapon_name_crc 
	end

	self.availability = availability
	self.level = level
	self.slot_num = slot_num
	self.ammo_type = ammo_type
	
end

------------------------------------------------------------
-- Vdo_weapon_radial_slot:set_state()
--
-- State Enums
--
-- Disabled				= 0
-- Enabled				= 1
-- Highlighted			= 2
------------------------------------------------------------
function Vdo_weapon_radial_slot:set_state(state)
	--Find objects to change weapon bitmaps
	local dual_inv_1_bmp = Vdo_base_object:new("dual_inv_1_bmp", self.handle)
	local dual_inv_2_bmp = Vdo_base_object:new("dual_inv_2_bmp", self.handle)
	local main = Vdo_base_object:new("safe_frame", self.handle)
	
	main:set_color(1,1,1)
	--dual_inv_1_bmp:set_visible(true)
	
	--Set tint based on weapon availability
	if state == WEAPON_SLOT_STATE_DISABLED then
		main:set_color(.15,.15,.15)
		if self.is_outline then
			dual_inv_1_bmp:set_visible(false)
		end
	elseif state == WEAPON_SLOT_STATE_ENABLED then
		dual_inv_1_bmp:set_color(.5, .5, .5)
		dual_inv_2_bmp:set_color(.5, .5, .5)		
	else
		-- set to highlighted
		dual_inv_1_bmp:set_color(1, 1, 1)
		dual_inv_2_bmp:set_color(1, 1, 1)
	end
end

function Vdo_weapon_radial_slot:set_store_weapon_icon(slot)

	

end
