-- Inherited from Vdo_base_object
Vdo_weapon_radial = Vdo_base_object:new_base()

--Assign Audio IDs
local SOUND_RADIAL_OPEN 
local SOUND_RADIAL_SELECT 
local SOUND_RADIAL_EQUIP_WEAPON 
local SOUND_RADIAL_EQUIP_GRENADE

local STICK_TRAVEL_DISTANCE = 10*3

local ANCHOR_DPAD_MENU_STORE_X = 238*3
local ANCHOR_DPAD_MENU_STORE_Y = 0

local WEAPON_HIGHLIGHT_PREVIOUS_SELECTED 	= -1
local WEAPON_HIGHLIGHT_SELECT_NONE 			= -2

local Dpad_menu_enabled = true

function vdo_weapon_radial_init()
	SOUND_RADIAL_OPEN = game_audio_get_audio_id("SYS_WEP_MENU")
	SOUND_RADIAL_SELECT = game_audio_get_audio_id("SYS_WEP_SCROLL")
	SOUND_RADIAL_EQUIP_WEAPON = game_audio_get_audio_id("SYS_RADIAL_WEAPON_EQUIP")
	SOUND_RADIAL_EQUIP_GRENADE = game_audio_get_audio_id("SYS_RADIAL_DRUG_EQUIP")
end

function Vdo_weapon_radial:init()
	--Member Variables
	self.slots = {}
	self.selected_weapon_slot = -1
	self.selected_grenade_slot = -1
	self.equipped_weapon_slot = -1
	self.equipped_grenade_slot = -1
	self.purchase_grp = -1
	self.store_highlight = -1
	self.slot_grenade_highlight = -1
	self.btn_hint = -1
	self.store_mode_is_enabled = false
	self.last_selected_slot = -1
	
	--Initialize all slots
	local slot
	for i = 0, 11 do
		slot = "slot_" .. i
		self.slots[i] = Vdo_weapon_radial_slot:new(slot, self.handle, self.doc_handle)
	end
	
	--Change control stick depending on platform
	local control_stick_bmp = Vdo_base_object:new("stick_bmp", self.handle, self.doc_handle)
	control_stick_bmp:set_image(get_control_stick_thumb())
	
	--Change base depending on platform
	local stick_base_bmp = Vdo_base_object:new("base", self.handle, self.doc_handle)
	stick_base_bmp:set_image(get_control_stick_base())
	
	--Change d-pad depending on base
	local dpad_bmp = Vdo_base_object:new("dpad", self.handle, self.doc_handle)
	dpad_bmp:set_image(get_dpad_image())
	
		--Clear out text fields on init...
	local weapon_txt = Vdo_base_object:new("weapon_text", self.handle, self.doc_handle)
	weapon_txt:set_text("")
	weapon_txt = Vdo_base_object:new("grenade_text", self.handle, self.doc_handle)
	weapon_txt:set_text("")
	
	--callbacks for looping highlight animations...
	local weapon_radial_glow_twn = Vdo_tween_object:new("weapon_radial_glow_twn", self.handle, self.doc_handle)
	local grenade_radial_glow_twn = Vdo_tween_object:new("grenade_radial_glow_twn", self.handle, self.doc_handle)
	weapon_radial_glow_twn:set_property("end_event", "vint_anim_loop_callback")
	grenade_radial_glow_twn:set_property("end_event", "vint_anim_loop_callback")
	
	self.purchase_grp = Vdo_base_object:new("purchase_grp", self.handle, self.doc_handle)		
	self.store_highlight = Vdo_base_object:new("slot_highlight_store", self.handle, self.doc_handle)
	self.slot_highlight = Vdo_base_object:new("slot_highlight", self.handle, self.doc_handle)
	self.slot_grenade_highlight = Vdo_base_object:new("slot_grenade_highlight", self.handle, self.doc_handle)
	self.btn_hint = Vdo_hint_button:new("btn_hint", self.handle, self.doc_handle)
	self.arrow_bmp = Vdo_base_object:new("arrow", self.handle, self.doc_handle)
	
	self.purchase_grp:set_visible(false)
	self.store_highlight:set_visible(false)		
	self.slot_highlight:set_visible(false)		
	self.slot_grenade_highlight:set_visible(false)		
	self.btn_hint:set_visible(false)
	
	self.btn_hint:set_button(CTRL_MENU_BUTTON_A)
	
	self.stick_grp = Vdo_base_object:new("control_stick", self.handle, self.doc_handle)
	self.dpad_bmp = Vdo_base_object:new("dpad", self.handle, self.doc_handle)

	-- PC: Hide dpad and control stick
	local gamepad_in_use = game_is_active_input_gamepad()
	self.stick_grp:set_visible(gamepad_in_use)
	self.dpad_bmp:set_visible(gamepad_in_use)
	self.arrow_bmp:set_visible(gamepad_in_use)
end

function Vdo_weapon_radial:cleanup()
	-- Temp: bitmap doesn't line up with triangle edges
end

function Vdo_weapon_radial:show(is_visible)

	if is_visible == nil then
		is_visible = false
	end
	
	local weapon_radial_glow = Vdo_anim_object:new("weapon_radial_glow", self.handle, self.doc_handle)
	local grenade_slot_glow = Vdo_anim_object:new("grenade_radial_glow", self.handle, self.doc_handle)
	
	self:stick_arrow_reset()
	
	self:set_visible(is_visible)

	-- Show only the available grenade slots.  Slot 8 is always on, so check 9 through 11.
	for i = 9, 11 do
		local weapon_level_obj = Vdo_base_object:new("slot_" .. i, self.handle, self.doc_handle)
		if self.slots[i].level >= 1 then
			--show slot
			weapon_level_obj:set_visible(true)
		else
			--hide slot
			weapon_level_obj:set_visible(false)
		end
	end
	
	-- Using a different highlight that doesn't animate for store mode	
	if self.store_mode_is_enabled ~= true then
		if is_visible == true then
			--animate pulse
			weapon_radial_glow:play()
			grenade_slot_glow:play()
		else
			--stop animating pulse
			weapon_radial_glow:stop()
			grenade_slot_glow:stop()
		end
	else
		-- JAM: Don't move the grenades up in 4:3, we don't have enough room
		if not vint_is_std_res() then
			local dpad_menu = Vdo_base_object:new("dpad_menu", self.handle, self.doc_handle)
			dpad_menu:set_anchor(ANCHOR_DPAD_MENU_STORE_X,ANCHOR_DPAD_MENU_STORE_Y)
		end
		-- SEH: we want to stay on the last slot selected when purchasing/upgrading, so don't reset here in stores.
		--intialize to first slot
		--self:weapon_highlight(1, true)
	end	
end

--Updates position of stick on the radial menu
--stick_x:	-1 to 1 horizontal position of the stick on analog
--stick_y:	-1 to 1 vertical position of the stick on analog
function Vdo_weapon_radial:stick_update_position(stick_x, stick_y)
	local x = stick_x * STICK_TRAVEL_DISTANCE
	local y = -stick_y * STICK_TRAVEL_DISTANCE
	local stick_grp = Vdo_base_object:new("stick_grp", self.handle, self.doc_handle)
	stick_grp:set_anchor(x, y)
end

--Updates the tag of the analog stick with the proper text (RS, LS, R, L)
function Vdo_weapon_radial:stick_update_tag()
	local stick_txt = Vdo_base_object:new("stick_text", self.handle, self.doc_handle)
	stick_txt:set_text(get_control_stick_text())
end

function Vdo_weapon_radial:stick_update_arrow(rotation_radians)
	local new_radians = rotation_radians + (PI / 2)
	self.arrow_bmp:set_rotation(-new_radians)
end

--Reset arrow to currently highlighted weapon...
function Vdo_weapon_radial:stick_arrow_reset()
	local new_radians = 0
	local offset = PI 
	new_radians = (self.selected_weapon_slot/8) * PI2  + offset	
	self.arrow_bmp:set_rotation(new_radians)
end

--Highlights a slot on the weapon radial
function Vdo_weapon_radial:weapon_highlight(slot_num, skip_audio, force_update)
	
	local selector_grp
	local weapon_txt
	local selected_slot_old
	local slot_old_obj 
	local slot_new_obj 
	local dpad_menu
	local dpad_menu_x = 0
	local dpad_menu_y = 0
	local weapon_name_tag = ""

	
	-- slot_num == -1 can be passed in to just update previous slot
	if slot_num == -1 then
		slot_num = self.selected_weapon_slot
	end
	
	--Change text for the weapon radial
	local slot_ammo = Vdo_base_object:new("slot_ammo", self.handle, self.doc_handle)
	local img_ammo = Vdo_base_object:new("img_ammo", self.handle, self.doc_handle)	
	
	--Check if we are updating the radial or grenade if not in the store
	
	--and self.store_mode_is_enabled == false 
	
	if slot_num < 8 then	
	
		weapon_txt = Vdo_base_object:new("weapon_text", self.handle, self.doc_handle)
		selector_grp = Vdo_base_object:new("slot_weapon_select", self.handle, self.doc_handle)
				
		slot_old_obj = self.slots[self.selected_weapon_slot]
		slot_new_obj = self.slots[slot_num]
		
		--Store slot variables
		selected_slot_old = self.selected_weapon_slot
		self.selected_weapon_slot = slot_num
		
		--Update name and weapon level
		local level = slot_new_obj.level + 1
		if self.store_mode_is_enabled == true or level <= 1 then
			if slot_new_obj.weapon_name_crc ~= 0 then
				--no level appended...
				local base_weapon_string = "{0:text_tag_crc}"
				local values = {[0] = slot_new_obj.weapon_name_crc}
				weapon_name_tag = vint_insert_values_in_string(base_weapon_string, values)
			else
				--weapon has no name (fist)
				weapon_name_tag = ""
			end
		else
			--no level appended...
			local values = {[0] = slot_new_obj.weapon_name_crc, [1] = level }
			weapon_name_tag = vint_insert_values_in_string("MENU_WEAPON_LEVEL", values)
		end

		self:stick_arrow_reset()
	else
		--Grenades
		weapon_txt = Vdo_base_object:new("grenade_text", self.handle, self.doc_handle)
		selector_grp = Vdo_base_object:new("slot_grenade_select", self.handle, self.doc_handle)
		dpad_menu = Vdo_base_object:new("dpad_menu", self.handle, self.doc_handle)
		dpad_menu_x, dpad_menu_y = dpad_menu:get_anchor()		
			
		if self.slots[slot_num].level == 0 then
			--grenade slot is not unlocked yet.  Return early
			return
		end

		slot_old_obj = self.slots[self.selected_grenade_slot]
		slot_new_obj = self.slots[slot_num]
		
		--Update name... (no level for grenades)
		if slot_new_obj.weapon_name_crc ~= 0 then
			local base_weapon_string = "{0:text_tag_crc}"
			local values = {[0] = slot_new_obj.weapon_name_crc}
			weapon_name_tag = vint_insert_values_in_string(base_weapon_string, values)
		else
			--weapon has no name (empty)
			weapon_name_tag = ""
		end
		
		--Store slot variables
		selected_slot_old = self.selected_grenade_slot
		self.selected_grenade_slot = slot_num
	end

	--Stores handle their selected slots differently, only one item 
	--can be selected at a time...
	if self.store_mode_is_enabled then
		slot_old_obj = self.slots[self.last_selected_slot]
		slot_new_obj = self.slots[slot_num]
		selected_slot_old = self.last_selected_slot
		self.last_selected_slot = slot_num
	end
	
	--Now do the menu update...
	
	local skip_highlight = false
	
	-- If in store use different highlight scheme
	if self.store_mode_is_enabled then			
	
	
		--Hide standard weapon select highlights
		self.slot_highlight:set_visible(false)
		self.slot_grenade_highlight:set_visible(false)
		weapon_txt:set_visible(false)
	
		--Reset parent of highlight handle and show the highlight
		vint_object_set_parent(self.store_highlight.handle, selector_grp.handle)
		self.store_highlight:set_visible(true)
		
		--Show button hint in store
		self.btn_hint:set_visible(game_is_active_input_gamepad())
		
		--If in store and not selected slot then dim out	
		for i=0, #self.slots do		
			if i == slot_num and self.slots[slot_num].state ~= WEAPON_SLOT_STATE_DISABLED then
				-- This slot is highlighted
				self.slots[i]:set_state(WEAPON_SLOT_STATE_HIGHLIGHTED)
			elseif self.slots[i].state == WEAPON_SLOT_STATE_DISABLED then
				self.slots[i]:set_state(WEAPON_SLOT_STATE_DISABLED)
				if i == slot_num then 
					skip_highlight = true
				end
			else
				self.slots[i]:set_state(WEAPON_SLOT_STATE_ENABLED)
			end		
		end
	else
		self:set_highlight_color(COLOR_SAINTS_PURPLE)
		self.slot_highlight:set_visible(true)		
		self.slot_grenade_highlight:set_visible(true)	
	end
	
	--Check if we are trying to select the same weapon and exit early if so...
	if slot_num == selected_slot_old and force_update ~= true then		
		return
	end
	
	--Reset previous slot 
	if selected_slot_old ~= -1 then
		slot_old_obj:set_scale(1,1)
	end
	
	if skip_highlight == false then
		--Scale up slot object
		slot_new_obj:set_scale(1.25,1.25)		
		 
		--Move the selector to the new slot
		--Offset A button so it doesn't cover ammo meter
		local BUTTON_HINT_OFFSET_X = -15 * 3
		local BUTTON_HINT_OFFSET_Y = 29	*3
		local selector_x, selector_y = slot_new_obj:get_anchor()
		
		selector_grp:set_anchor(selector_x, selector_y) 	
		self.btn_hint:set_anchor(selector_x + BUTTON_HINT_OFFSET_X + dpad_menu_x, selector_y + BUTTON_HINT_OFFSET_Y + dpad_menu_y)
				
		weapon_txt:set_text(weapon_name_tag)
		
		--Hide text if weapon doesn't have ammo
		if slot_new_obj.ammo_cur == -1 then
			slot_ammo:set_visible(false)
			img_ammo:set_visible(false)
		else
			if self.store_mode_is_enabled then
				slot_ammo:set_text(slot_new_obj.ammo_cur.."/"..slot_new_obj.ammo_max)	
				img_ammo:set_image(slot_new_obj.ammo_type)
				slot_ammo:set_visible(true)
				img_ammo:set_visible(true)
			end
		end
		
		--Center ammo text
		local slot_ammo_width, slot_ammo_height = element_get_actual_size(slot_ammo.handle)
		local weapon_txt_x, weapon_txt_y = weapon_txt:get_anchor()
		local AMMO_IMAGE_OFFSET = 12 * 3
		self.purchase_grp:set_anchor(weapon_txt_x + AMMO_IMAGE_OFFSET, weapon_txt_y + 20 * 3)
		img_ammo:set_anchor(slot_ammo_width * -0.5 - AMMO_IMAGE_OFFSET, 0) 
	end

	
	--Play audio
	if skip_audio == false or skip_audio == nil then
		game_UI_audio_play("UI_HUD_Select_Weapon")
	end		
	
	-- PC: Hide dpad and control stick
	local gamepad_in_use = game_is_active_input_gamepad()
	self.stick_grp:set_visible(gamepad_in_use)
	self.dpad_bmp:set_visible(gamepad_in_use)
	self.arrow_bmp:set_visible(gamepad_in_use)
end


function Vdo_weapon_radial:store_highlight(slot_num, skip_audio, force_update)

end

---Equips currently selected slots in the radial menu for both weapons and grenades
function Vdo_weapon_radial:game_equip_selected_slots()
	--Equip the Weapon First
	
	--have we actually selected something
	if self.selected_weapon_slot ~= -1 then
		--is it available?
		if self.slots[self.selected_weapon_slot].availability == true then
			--is the selected slot not the same as the equipped slot?
			if self.selected_weapon_slot ~= self.equipped_weapon_slot then
				local success = game_use_radial_menu_item(self.selected_weapon_slot)
				if success then
					self.equipped_weapon_slot = self.selected_weapon_slot 
				end
			end
		end
	end
	
	--Equip Grenade Now
	if self.selected_grenade_slot ~= -1 then
		--is it available?
		if self.slots[self.selected_grenade_slot].availability == true then
			-- is this slot unlocked?
			if self.slots[self.selected_grenade_slot].level >= 1 then
				--is the selected slot not the same as the equipped slot?
				if self.selected_grenade_slot ~= self.equipped_grenade_slot then
					local success = game_set_equipped_grenade(self.selected_grenade_slot)
					if success then
						self.equipped_grenade_slot = self.selected_grenade_slot 
					end
				end
			end
		end
	end
end



--Updates the weapon radial from the dataitem subscription
--[[
		Data Item Breakdown:
		slot_num:			Slot number of item
		availability:		Is the item available and can it be equipped?
		weapon_name_crc:	crc for the item name (if nil then the item is empty
		bmp_name:			bitmap representing the item
		ammo_cur:			current ammo for the item (Weapons Only)
		ammo_max:			max ammo for the item (Weapons Only)
		dual_wield:			bool (Weapons Only)
		is_current_wpn		Bool(	Is Current Weapon ) 
		ammo_infinite:		bool (Weapons Only)
		level:				upgrade level of the weapon (0 is the base)
	]]
function Vdo_weapon_radial:slots_update(di_h)
	
	--Retreive Data from Dataitem
	local slot_num, availability, weapon_name_crc, bmp_name, ammo_cur, ammo_max, dual_wield, ammo_infinite, is_current_wpn, level, ammo_type  = vint_dataitem_get(di_h) 
	
	--Get slot
	local slot = self.slots[slot_num]
	
	--Force the fist icon if slot num is 0 and no bitmap name is provided
	if slot_num == 0 and bmp_name == nil then
		bmp_name = "uhd_ui_hud_inv_fist"
	end
	
	--Update slot
	slot:update(slot_num, availability, weapon_name_crc, bmp_name, ammo_cur, ammo_max, dual_wield, ammo_infinite, level, ammo_type, self.store_mode_is_enabled)
	
	--Set weapon currently equipped if it is the case
	if slot_num < 8 then
		if is_current_wpn == true then
			self.equipped_weapon_slot = slot_num
		end
	else 
		if is_current_wpn == true then
			self.equipped_grenade_slot = slot_num
		end
	end
end

function Vdo_weapon_radial:loop_anim_cb(tween_h, event)
	local anim_h = vint_object_parent(tween_h)
	lua_play_anim(anim_h)
end

function Vdo_weapon_radial:store_mode_enable(enable)
	self.store_mode_is_enabled = enable
	
	--Hide highlighted weapon text
	local grenade_text = vint_object_find("grenade_text", self.handle, self.doc_handle)
	local purchase_grp = vint_object_find("grenade_text", self.handle, self.doc_handle)
	local weapon_level_grp = vint_object_find("grenade_text", self.handle, self.doc_handle)
	local weapon_text = vint_object_find("grenade_text", self.handle, self.doc_handle)
	
	vint_set_property(grenade_text, "visible", false)
	vint_set_property(purchase_grp, "visible", false)
	vint_set_property(weapon_level_grp, "visible", false)
	vint_set_property(weapon_text, "visible", false)	
end

function Vdo_weapon_radial:show_dpad_menu(is_visible)
	local dpad_menu = Vdo_base_object:new("dpad_menu", self.handle, self.doc_handle)
	dpad_menu:set_visible(is_visible)
	
	Dpad_menu_enabled = is_visible
end

--SEH this needs to eventually determine if we last selected weapons or grenades, and return the right one
--
function Vdo_weapon_radial:get_selected_slot()
	return self.last_selected_slot
end

function Vdo_weapon_radial:set_highlight_color(color)
	self.arrow_bmp:set_property("tint", color.R, color.G, color.B)
	self.store_highlight:set_property("tint", color.R, color.G, color.B)	
	self.slot_highlight:set_property("tint", color.R, color.G, color.B)
	self.slot_grenade_highlight:set_property("tint", color.R, color.G, color.B)
end

function Vdo_weapon_radial:slot_disable(slot_num)
	if self.store_mode_is_enabled then
		self.slots[slot_num].state = WEAPON_SLOT_STATE_DISABLED
	end
end

function Vdo_weapon_radial:slot_enable(slot_num)
	if self.store_mode_is_enabled then
		self.slots[slot_num].state = WEAPON_SLOT_STATE_ENABLED
	end
end

function Vdo_weapon_radial:slot_is_disabled(slot_num)
	if self.store_mode_is_enabled then
		if self.slots[slot_num].state  == WEAPON_SLOT_STATE_DISABLED then
			return true
		else
			return false
		end
	else
		return false
	end
end

-- Adds mouse input subscriptions to the input tracker
--
-- @param	func_prefix			Name of the screen that is currently using the hint bar
-- @param	input_tracker		The input tracker to hold the mouse inputs events
-- @param	priority				THe priority of the input event
function Vdo_weapon_radial:add_mouse_inputs(func_prefix, input_tracker, priority)
	if func_prefix == nil then
		return
	end
	
	priority = priority or 50
	
	local mouse_click_function = func_prefix.."_mouse_click"
	local mouse_move_function = func_prefix.."_mouse_move"

	for i = 1, #self.slots do
		self.slots[i].slot_bmp_h = -1
		-- Is this slot enabled
		if self.slots[i].state == nil or self.slots[i].state == WEAPON_SLOT_STATE_ENABLED then
			-- Is it visible
			if Dpad_menu_enabled or i < 8 then
				-- Is it not disabled (for certain grendes) - This check probably not necessary
				if i < 9 or self.slots[i].level >= 1 then
					self.slots[i].slot_bmp_h = vint_object_find("base_bmp", self.slots[i].handle, self.doc_handle)
					input_tracker:add_mouse_input("mouse_click", mouse_click_function, priority, self.slots[i].slot_bmp_h)
					input_tracker:add_mouse_input("mouse_move", mouse_move_function, priority, self.slots[i].slot_bmp_h)
				end
			end
		end
	end
end

-- Mouse function: Return the slot matching the target_handle
function Vdo_weapon_radial:get_slot_index(target_handle)
	for i = 1, #self.slots do
		if target_handle == self.slots[i].slot_bmp_h then
			return i
		end
	end
	return 0
end

--SEH this needs to eventually determine if we last selected weapons or grenades, and return the right info.
-- This function finds the currently selected weapon, and return values related to ammo:
-- - current ammo count
-- - maximum ammo count
--
-- function Vdo_weapon_radial:get_selected_ammo_info()
	-- --Get slot
	-- local slot = self.slots[self.selected_weapon_slot]
	-- return slot.ammo_cur, slot.ammo_max
-- end
