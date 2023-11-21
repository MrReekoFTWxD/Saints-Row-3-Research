-- Inherited from Vdo_base_object
Vdo_qte_key = Vdo_base_object:new_base()


local HUD_QTE_ANIM_NONE = -1
local HUD_QTE_ANIM_MASH_STANDARD = 0
local HUD_QTE_ANIM_MASH_FAST = 1


HUD_QTE_KEY_ARROW_N	= 1
HUD_QTE_KEY_ARROW_E	= 4
HUD_QTE_KEY_ARROW_S	= 2
HUD_QTE_KEY_ARROW_W	= 3

local HUD_QTE_ARROW_DIRECTION_ROTATIONS = {
	[HUD_QTE_KEY_ARROW_N] = 0,
	[HUD_QTE_KEY_ARROW_E] = 90 * DEG_TO_RAD,
	[HUD_QTE_KEY_ARROW_S] = 180 * DEG_TO_RAD,
	[HUD_QTE_KEY_ARROW_W] = 270 * DEG_TO_RAD,
}

function Vdo_qte_key:init()
	self.key_off_handles = {}
	local key_off_grp_h = vint_object_find("key_off_grp", self.handle)
	local key_on_grp_h = vint_object_find("key_on_grp", self.handle)
	local key_glow_grp_h = vint_object_find("key_glow_grp", self.handle)
	
	self.key_off_grp_h 	= key_off_grp_h
	self.key_on_grp_h 	= key_on_grp_h
	self.key_glow_grp_h 	= key_glow_grp_h
	
	self.key_off_w_h = vint_object_find("key_w", key_off_grp_h)
	self.key_off_m_h = vint_object_find("key_m", key_off_grp_h)
	self.key_off_e_h = vint_object_find("key_e", key_off_grp_h)
	
	self.key_on_w_h = vint_object_find("key_w", key_on_grp_h)
	self.key_on_m_h = vint_object_find("key_m", key_on_grp_h)
	self.key_on_e_h = vint_object_find("key_e", key_on_grp_h)
	
	self.key_glow_w_h = vint_object_find("key_w", key_glow_grp_h)
	self.key_glow_m_h = vint_object_find("key_m", key_glow_grp_h)
	self.key_glow_e_h = vint_object_find("key_e", key_glow_grp_h)
	
	self.success_base_h 		= vint_object_find("success_base_grp", self.handle)
	self.success_base_w_h 	= vint_object_find("success_key_w", self.success_base_h)
	self.success_base_m_h 	= vint_object_find("success_key_m", self.success_base_h)
	self.success_base_e_h 	= vint_object_find("success_key_e", self.success_base_h)
	
	self.key_arrow_grp_h = vint_object_find("key_arrow_grp", self.handle)
	
	self.width = 0
	self.mash_fast_anim_h 		= vint_object_find("mash_fast_anim", self.handle)
	self.arrow_anim_h 			= vint_object_find("arrow_anim", self.handle)
	
	vint_set_property(self.mash_fast_anim_h, "target_handle", self.handle)
	vint_set_property(self.arrow_anim_h, "target_handle", self.handle)

	self.success_clones = {}
	self.success_anim_clones = {}
	
	self:mash(HUD_QTE_ANIM_NONE)
end

function Vdo_qte_key:cleanup()
end

function Vdo_qte_key:set_text(text_tag)
	local key_txt_h = vint_object_find("key_txt", self.handle)
	vint_set_property(key_txt_h, "text_tag", text_tag)
	vint_set_property(key_txt_h, "scale", 1.0, 1.0)
	
	local width, height = element_get_actual_size(key_txt_h)
	local width_max = 226 * 3
	local width_min = 20 * 3
	width = max(width, width_min)

	--keep a min width on everything...
	if width < 50 * 3	then
		width = 30 * 3
		vint_set_property(key_txt_h, "anchor", 40 * 3, -1 * 3)
	else
		vint_set_property(key_txt_h, "anchor", (width)*.5 + (25 * 3), -1 * 3)
	end
	
	if width > width_max then
		local scale = width_max/width
		vint_set_property(key_txt_h, "scale", scale, scale)
		width = width * scale
	end
	
	width = width + (35 * 3)
	self:resize(width)
end

function Vdo_qte_key:resize(width)
	--self.key_off_handles.key_w
	
	--Expand the center using source_se.x, source_se.y
	---self.key_off_w_h 
	--self.key_off_m_h 
	--self.key_off_e_h 
	local source_se_x, source_se_y = vint_get_property(self.key_off_m_h, "source_se")
	vint_set_property(self.key_off_m_h, "source_se", width, source_se_y)
	vint_set_property(self.key_on_m_h, "source_se", width, source_se_y)

	--Move Right Side
	local x, y = vint_get_property(self.key_off_e_h, "anchor")
	vint_set_property(self.key_off_e_h, "anchor", width - (40 * 3), y)
	vint_set_property(self.key_on_e_h, "anchor", width - (40 * 3), y)
	
	--Build Glow...
	local glow_m_width, glow_m_height = element_get_actual_size(self.key_glow_m_h)
	element_set_actual_size(self.key_glow_m_h, width - 19 * 3, glow_m_height)
	local x, y = vint_get_property(self.key_glow_e_h, "anchor")
	vint_set_property(self.key_glow_e_h, "anchor", width, y)

	--This stuff works...
	local inverse_start_scale = 1.669
	local center_width = (width * inverse_start_scale) - (50 * 3)
	local center_offset = 10 * 3

	vint_set_property(self.success_base_m_h, "scale", 1.0, 1.0)
	local success_m_width, success_m_height = element_get_actual_size(self.success_base_m_h)
	element_set_actual_size(self.success_base_m_h, center_width, success_m_height)
	
	local x, y = vint_get_property(self.success_base_w_h, "anchor")
	vint_set_property(self.success_base_w_h, "anchor", -center_width * 0.5 , y)
	
	local x, y = vint_get_property(self.success_base_e_h, "anchor")
	vint_set_property(self.success_base_e_h, "anchor", center_width * 0.5 , y)
	
	local success_center_grp_h = vint_object_find("success_center_grp", self.success_base_h)
	local x, y = vint_get_property(success_center_grp_h, "anchor")
	local x = ((width ) * 0.5)  + center_offset
	vint_set_property(success_center_grp_h, "anchor", x, y)
	vint_set_property(success_center_grp_h, "scale", 0.65, 0.65)
	vint_set_property(success_center_grp_h, "alpha", 0)
	
	--Store width with extra padding and it centers nicely.
	self.width = width + (18 * 3)
end

function Vdo_qte_key:get_width()
	return self.width 
end
	
function Vdo_qte_key:mash(mash_type)

	--Always stop any mashing...
	vint_set_property(self.key_off_grp_h, 	"alpha", 1)
	vint_set_property(self.key_on_grp_h, 	"alpha", 0)
	vint_set_property(self.key_glow_grp_h, "alpha", 0)
	self.mash_type = mash_type
	
	if mash_type == HUD_QTE_ANIM_NONE then
		vint_set_property(self.mash_fast_anim_h,"is_paused", true)
		vint_set_property(self.arrow_anim_h, "is_paused", true)
		vint_set_property(self.key_arrow_grp_h, "visible", false)
		return
	elseif mash_type == HUD_QTE_ANIM_MASH_STANDARD or  mash_type == HUD_QTE_ANIM_MASH_FAST then	
		lua_play_anim(self.mash_fast_anim_h)
		lua_play_anim(self.arrow_anim_h)
		vint_set_property(self.key_arrow_grp_h, "visible", self.arrows_are_visible)
	end
end

function Vdo_qte_key:show_arrows(is_visible)
	if self.mash_type == HUD_QTE_ANIM_NONE then
		vint_set_property(self.key_arrow_grp_h, "visible", false)
	else
		vint_set_property(self.key_arrow_grp_h, "visible", is_visible)
	end
	self.arrows_are_visible = is_visible
end

function Vdo_qte_key:set_arrow_direction(direction)

	if self.width == 0 then
		return
	end
	
	local x, y
	if direction == HUD_QTE_KEY_ARROW_N then
		x = self.width * .5
		y = -37.0 * 3
	elseif direction == HUD_QTE_KEY_ARROW_E then
		x = self.width + 5 * 3
		y = 0
	elseif direction == HUD_QTE_KEY_ARROW_S then 
		x = self.width * .5
		y = 37.0 * 3
	elseif direction == HUD_QTE_KEY_ARROW_W  then 
		x =  - 5 * 3
		y = 0
	end
	
	vint_set_property(self.key_arrow_grp_h, "anchor", x, y)
	local angle = HUD_QTE_ARROW_DIRECTION_ROTATIONS[direction] 
	vint_set_property(self.key_arrow_grp_h, "rotation", angle)
end

function Vdo_qte_key:success(is_success)
	if #self.success_clones ~= 0 then
		for i = 1, #self.success_clones do
			vint_object_destroy(self.success_clones[i])
			vint_object_destroy(self.success_anim_clones[i])
		end
		self.success_clones = {}
		self.success_anim_clones = {}
	end

	if is_success then
		--create mouse success items
		for i = 1, 4 do
			self.success_clones[i] = vint_object_clone(self.success_base_h)
			self.success_anim_clones[i] = vint_object_clone(vint_object_find("success_anim"))
			vint_set_property(self.success_anim_clones[i], "target_handle", self.success_clones[i])
			lua_play_anim(self.success_anim_clones[i], (i - 1) * .1)
		end
		vint_set_property(self.key_on_grp_h, "visible", false)
	else
		vint_set_property(self.key_on_grp_h, "visible", true)
	end
end = chal_bg:get_actual_size()
	local chal_title_width, chal_title_height = chal_title:get_actual_size()
	local new_bg_height = (CHAL_TITLE_Y - chal_title_height) * -1
	chal_bg:set_actual_size(chal_bg_width, new_bg_height)
	
	end_event:set_end_event("hud_diversion_chal_complete")
	chal_anim:play(0)	
	chal_grp:set_visible(true)
	
	-- Handle meter fill
	local fill = (Hud_challenge_data.cur_val / Hud_challenge_data.max_val) * Meter_max
	chal_meter_fill:set_actual_size(fill, Meter_height)
end

function hud_diversion_chal_complete()

	-- Reward the player with cash/respect
	if Hud_challenge_data.respect_reward > 0 then
		game_award_respect(Hud_challenge_data.respect_reward, STATS_INVALID, DT_CHALLENGE)
	end
	if Hud_challenge_data.cash_reward > 0 then
		game_award_cash(Hud_challenge_data.cash_reward, DT_CHALLENGE)
	end
	
	hud_diversion_remove_callback(Hud_challenge_data.message_type)
	if Hud_challenge_data.is_achievement == true then
		game_peg_unload(Hud_challenge_data.image)
	end
end

-------------------------------------------------------------------------------
-- Causes the diversion hud to go into a paused state...
-------------------------------------------------------------------------------
function hud_diversion_pause(is_paused)
	Hud_diversion_is_paused = is_paused
end

------------------------------------------------------------------------
--Forces diversions to hide with transition...
-------------------------------------------------------------------------------
function hud_diversion_hide()
	local anim_h = vint_object_find("div_fade_all_out_anim", 0, Hud_diversion_doc)
	lua_play_anim(anim_h)
	hud_diversion_pause(true)
end

-------------------------------------------------------------------------------
--Forces diversions to show with transition... 
-------------------------------------------------------------------------------
function hud_diversion_show()
	local anim_h = vint_object_find("div_fade_all_in_anim", 0, Hud_diversion_doc)
	lua_play_anim(anim_h)
	hud_diversion_pause(false)
end

-------------------------------------------------------------------------------
--	Meter Testing code
-------------------------------------------------------------------------------

Diversion_test_thread = -1 
Diversion_test_data = {}
Diversion_test_data_count = 0

function hud_diversion_test_thread()
	--Just test one meter at a time...
	local doing_thread = true
	local di
	while doing_thread do
		--Process specific data 
		for idx, val in pairs(Diversion_test_data) do
			di = val.data_item
			local current_time = vint_get_time_index() 
			local interp = (current_time - val.start_time )/ val.duration
			local cur_value = floor(test_interp_linear(interp, val.start_value, val.end_value -  val.start_value))
			
			--Finished interpolation...
			local status = di.status
			
			if cur_value >= val.end_value then
				cur_value = val.end_value
				--Transition Complete!
				status = HDIS_COMPLETE
			end
			
			di.cur_value = cur_value
			if Diversion_test_data[idx] == nil then
				--No Update
			else
				hud_diversion_update(idx, di.meter_type, di.message_one, di.message_two, cur_value, di.min_value, di.max_value, di.descending, status, di.respect, di.cash, di.div_type, di.respect_stat, di.message_type)	
			end
			
			if status == HDIS_COMPLETE then
				--Wipe out diverion from test data...
				Diversion_test_data[idx] = nil
			end
		end
		
		--Hold Frame...
		thread_yield()
	end
end

function hud_challenge_test_add(unit_type)

	--Initialize values...
	local title					= 0
	local cur_val				= 0
	local max_val				= 0
	local val_units			= 0
	local cash_reward			= 0
	local respect_reward		= 0
	local is_achievement		= false
	local message_type		= HDT_NONE

	-- Display the type of hud they want
	if unit_type == nil or unit_type == "" then
		title				= get_localized_crc_for_tag("DIVERSION_CHALLENGES_DESTROY_MORNINGSTAR_VEHICLES")
		cur_val			= 20000
		max_val			= 20000
		val_units		= 0
		cash_reward		= 1500
		respect_reward	= 750
		
	elseif unit_type == "meters" then
		title				= get_localized_crc_for_tag("DIVERSION_CHALLENGES_BAILOUT_DISTANCE")
		cur_val			= 500
		max_val			= 500
		val_units		= get_localized_crc_for_tag("HUD_METERS_ABR")
		cash_reward		= 1500
		respect_reward	= 750
		
	elseif unit_type == "feet" then
		title				= get_localized_crc_for_tag("DIVERSION_CHALLENGES_BAILOUT_DISTANCE")
		cur_val			= 500 * FEET_PER_METER
		max_val			= 500 * FEET_PER_METER
		val_units		= get_localized_crc_for_tag("HUD_FEET_ABR")
		cash_reward		= 1500
		respect_reward	= 750
		
	elseif unit_type == "miles" then
		title				= get_localized_crc_for_tag("DIVERSION_CHALLENGES_ONCOMING_LANE")
		cur_val			= 10
		max_val			= 10
		val_units		= get_localized_crc_for_tag("HUD_MILES_ABR")
		cash_reward		= 1600
		respect_reward	= 800
	
	elseif unit_type == "seconds" then
		title				= get_localized_crc_for_tag("DIVERSION_CHALLENGES_POWERSLIDE_TIME")
		cur_val			= 600
		max_val			= 600
		val_units		= get_localized_crc_for_tag("HUD_SECONDS_ABR")
		cash_reward		= 1500
		respect_reward	= 750
		
	elseif unit_type == "minutes" then
		title				= get_localized_crc_for_tag("DIVERSION_CHALLENGES_POWERSLIDE_TIME")
		cur_val			= 10
		max_val			= 10
		val_units		= get_localized_crc_for_tag("HUD_MINUTES_ABR")
		cash_reward		= 1500
		respect_reward	= 750
		
	elseif unit_type == "hours" then
		title				= get_localized_crc_for_tag("DIVERSION_CHALLENGES_POWERSLIDE_TIME")
		cur_val			= 1
		max_val			= 1
		val_units		= get_localized_crc_for_tag("HUD_HOURS_ABR")
		cash_reward		= 1500
		respect_reward	= 750
		
	else
		title				= get_localized_crc_for_tag("DIVERSION_CHALLENGES_VEHICLE_MODDING")
		cur_val			= 20000
		max_val			= 20000
		val_units		= 0
		cash_reward		= 1500
		respect_reward	= 750
	end
	
	-- Display the hud
	hud_diversion_chal_update(title, cur_val, max_val, val_units, cash_reward, respect_reward, false, is_achievement, nil, message_type)
end

function hud_diversion_test_add()

	--Initialize values...
	local status 				= HDIS_IN_PROGRESS
	local meter_type 			= HDM_TIME
	local message_one	 		= "POWER SLIDE"
	local message_two			= 0

	local start_value 		= 0									--Start value for the meter to start
	local end_value			= 80000--rand_int(5000,10000)			--End value for the meter...
	
	local min_value         = 0
	local max_value			= 80000							--Maximum that the meter can reach...
	local descending        = false
	local duration				= 8 -- rand_int(4,8)				--Time in seconds
	
	--Reward
	local respect				= 120				--respect
	local cash 					= 0				--cash
	
	--Diversion info
	local div_type          = -1				--What is the type of the diversion
	local respect_stat      = -1				--What is the stat that should be incremented for awarding respect
	local message_type      = HDT_NONE      --What is the type of message
	
	--Build test data table...
	-- status, meter_type, cur_value, max_value, message_crc, message_wide, respect, cash, new_record)	
	Diversion_test_data[Diversion_test_data_count] = {
		data_item = {
			meter_type = meter_type,
			message_one = message_one,
			message_two = message_two,
			cur_value = start_value,
			min_value = min_value,
			max_value = max_value,
			descending = descending,
			status = status,
			respect = respect,
			cash = cash,
			div_type = div_type,
			respect_stat = respect_stat,
			message_type = message_type,
		},
		start_value = start_value,
		end_value = end_value,
		start_time = vint_get_time_index(),
		duration = duration
	}
	
	Diversion_test_data_count = Diversion_test_data_count + 1 
	
	if Diversion_test_thread == -1 then
		Diversion_test_thread = thread_new("hud_diversion_test_thread")
	end
end

--Randomly cancels one of the diversions...
function hud_diversion_test_cancel()
	--removes the first diversion this thing can find...
	for idx, val in pairs(Diversion_test_data) do
		local di = val.data_item
		hud_diversion_update(idx, di.meter_type, di.message_one. di.message_two, di.cur_value, di.min_value, di.max_value, di.descending, HDIS_CANCELLED, di.respect, di.cash, di.div_type, di.respect_stat, di.message_type)
		Diversion_test_data[idx] = nil
		if true then
			return
		end
	end
end

--Randomly cancels one of the diversions...
function hud_diversion_test_complete()
	--removes the first diversion this thing can find...
	for idx, val in pairs(Diversion_test_data) do
		local di = val.data_item
		hud_diversion_update(idx, di.meter_type, di.message_one. di.message_two, di.cur_value, di.min_value, di.max_value, di.descending, HDIS_COMPLETE, di.respect, di.cash, di.div_type, di.respect_stat, di.message_type)
		Diversion_test_data[idx] = nil
		if true then
			return
		end
	end
end
ta()
	if not self.draw_called then
		debug_print("vint", "Vdo_pause_mega_list:return_selected_data called with invalid document handle\n")
		return
	end
	
	return self.data[self.current_idx]
end

function Vdo_pause_mega_list:return_state()
	
	if not self.draw_called then
		debug_print("vint", "Vdo_pause_mega_list:return_state called with invalid document handle\n")
		return
	end
	
	return self.open
end

function Vdo_pause_mega_list:enable(state)
	if not self.draw_called then
		debug_print("vint", "Vdo_pause_mega_list:enable called with invalid document handle\n")
		return
	end
	
	local current_idx = self.current_idx
	
	for idx, button in pairs(self.buttons) do
		button:set_enabled(state)
	end
	
	local current_button = self.buttons[current_idx]
	
	-- Highlight/unhighlight current button
	current_button:set_highlight(state)
	current_button:set_enabled(state)		
end

function Vdo_pause_mega_list:show_bar(is_on)
	self.highlight:show_bar(is_on)
end

function Vdo_pause_mega_list:toggle_highlight(is_on)
	if not self.draw_called then
		debug_print("vint", "Vdo_pause_mega_list:toggle_highlight called with invalid document handle\n")
		return
	end
	
	local highlight = self.highlight
	highlight:set_property("visible", is_on)
	
	local current_idx = self.current_idx
	
	for idx, button in pairs(self.buttons) do
		button:set_highlight(false)
	end
	
	self.buttons[current_idx]:set_highlight(is_on)
end

-- Method to set callback for when the transition animation is complete...
function  Vdo_pause_mega_list:set_anim_in_cb(callback_func)
	self.anim_in_func_cb = callback_func
end

-- Method to set callback for when the out animation is complete...
function  Vdo_pause_mega_list:set_anim_out_cb(callback_func)
	self.anim_out_func_cb = callback_func
end

function Vdo_pause_mega_list:transition_out()
	local anim_out = Vdo_anim_object:new("mega_list_out_anim", self.handle)
	local twn_out = Vdo_tween_object:new("megalist_out_twn", anim_out.handle)
	twn_out:set_end_event(self.anim_out_func_cb)
	anim_out:play()
end

function Vdo_pause_mega_list:refresh_values(data)
	if not self.draw_called then
		debug_print("vint", "Vdo_pause_mega_list:refresh_values called with invalid document handle\n")
		return
	end
	
	for idx, val in pairs(data) do
		--store the button toggle options
		if data[idx].type == TYPE_BUTTON then
			-- Set the button toggle value
			self.buttons[idx]:set_value("")
		end
	end
end

function Vdo_pause_mega_list:return_size()
	local total_height
	for idx, val in pairs(self.data) do
		total_height = idx * LIST_BUTTON_HEIGHT
	end
	return self.width,total_height
end

function Vdo_pause_mega_list:set_highlight_color(color)
	self.highlight:set_color(color)
end

function Vdo_pause_mega_list:set_button_color(selected_color, unselected_color)
	self.button_selected_color 	= selected_color
	self.button_unselected_color 	= unselected_color
end

function Vdo_pause_mega_list:set_shadows(has_shadows)
	self.button_shadows = has_shadows
end

-- Sets the new current index
--
function Vdo_pause_mega_list:set_selection(new_index)
	if self.data[self.current_idx].disabled == true then
		return
	end

	self.current_idx = new_index
end

-- =====================================
--       Mouse Specific Functions
-- =====================================

-- Returns the button's index in the list based on the target handle. Returns 0 if nothing was found
--
function Vdo_pause_mega_list:get_button_index(target_handle)
	if self.buttons == nil then
		return
	end
		
	for idx, button in pairs(self.buttons) do
		if self.alignment == PAUSE_MEGA_LIST_ALIGN_CENTER then
			if vint_object_find("toggle_text", button.handle) == target_handle then
				return idx
			end
		else
			if button.handle == target_handle then
				return idx
			end
		end
	end

	-- If no matching target handle was found, return an invalid index
	return 0
end

-- Adds mouse input subscriptions to the input tracker
--
-- @param	func_prefix			Name of the screen that is currently using the hint bar
-- @param	input_tracker		The input tracker to hold the mouse inputs events
-- @param	priority				The priority of the input event
function Vdo_pause_mega_list:add_mouse_inputs(func_prefix, input_tracker, priority)
	if (self.buttons == nil) or (func_prefix == nil) then
		return
	end
	
	-- Default priority value to 50
	priority = priority or 50
	
	local mouse_click_function = func_prefix.."_mouse_click"
	local mouse_move_function = func_prefix.."_mouse_move"
	
	for idx, button in pairs(self.buttons) do
		if self.alignment == PAUSE_MEGA_LIST_ALIGN_CENTER then
			input_tracker:add_mouse_input("mouse_click", mouse_click_function, priority, vint_object_find("toggle_text", self.buttons[idx].handle))
			input_tracker:add_mouse_input("mouse_move", mouse_move_function, priority, vint_object_find("toggle_text", self.buttons[idx].handle))
			
		else
			input_tracker:add_mouse_input("mouse_click", mouse_click_function, priority, self.buttons[idx].handle)
			input_tracker:add_mouse_input("mouse_move", mouse_move_function, priority, self.buttons[idx].handle)
		end
	end
ende'0