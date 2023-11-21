local PREDATOR_MODE_OFF 			= 0
local PREDATOR_MODE_OVERHEAD 		= 1
local PREDATOR_MODE_GUIDED 		= 2
local PREDATOR_MODE_RC 				= 3

local PREDATOR_MODE_RC_DESTRUCT	= 20

local HUD_PREDATOR_BASE_STATIC_LEVEL = .05
local HUD_PREDATOR_MAX_STATIC_LEVEL = .3
-------------------------------------------------------------------------------
-- Intialize Predator
-------------------------------------------------------------------------------
local Hud_predator_static_alpha = 0
local Hud_predator_doc = -1
local Predator_static_thread_on = false
local Predator_thread = -1 
local Hud_predator_static_tiles = {}
local Predator_cloned_objects
local Guided_cloned_objects
local Rc_cloned_objects
local Predator_mode = -1

local Predator_hint_bar
local Predator_hint_bar_x
local Predator_hint_bar_y

local Hud_predator_rc = {}
local Hud_predator_satellite = {}

Hud_predator_rc_signal_txt_h = 0

-- Guided missle stuff...
local Hud_predator_guided = {}
Hud_predator_guided.left_lines = {}
Hud_predator_guided.left_text = {}
Hud_predator_guided.right_lines = {}
Hud_predator_guided.right_text = {}
Hud_predator_guided.line_h = 0
Hud_predator_guided.alt_txt_h = 0
Hud_predator_guided.guided_right_grp_h = 0


local Predator_btn_hints = {
	[PREDATOR_MODE_OFF] = false,
	[PREDATOR_MODE_OVERHEAD] = {
		{CTRL_BUTTON_LT, "SATELLITE_GUIDED_MISSILE", game_get_key_name_for_action("CBA_SWC_FIRE_GUIDED")},
		{CTRL_BUTTON_RT, "SATELLITE_FIRE_MISSILE", game_get_key_name_for_action("CBA_SWC_FIRE_FREE")},
		{CTRL_MENU_BUTTON_B, "SATELLITE_MODE_EXIT", game_get_key_name_for_action("CBA_SWC_EXIT_SATELLITE_MODE")},
	},
	[PREDATOR_MODE_GUIDED] = {
		{CTRL_BUTTON_LT, "SATELLITE_SLOW_DOWN", game_get_key_name_for_action("CBA_SWC_MISSILE_DECELERATE")},
		{CTRL_BUTTON_RT, "SATLLITE_SPEED_UP", game_get_key_name_for_action("CBA_SWC_MISSILE_ACCELERATE")},
		{CTRL_MENU_BUTTON_B, "SATELLITE_EXIT_GUIDED_MODE", game_get_key_name_for_action("CBA_SWC_EXIT_SATELLITE_MODE")},
	},
	[PREDATOR_MODE_RC] = {
		{CTRL_MENU_BUTTON_B, "SATELLITE_EXIT_RC_MODE", game_get_key_name_for_action("CBA_VDC_RC_ABORT")},
	},
	[PREDATOR_MODE_RC_DESTRUCT] = {
		{CTRL_BUTTON_Y, "SATELLITE_RC_MODE_DESTRUCT", game_get_key_name_for_action("CBA_VDC_RC_SELF_DESTRUCT")},
		{CTRL_MENU_BUTTON_B, "SATELLITE_EXIT_RC_MODE", game_get_key_name_for_action("CBA_VDC_RC_ABORT")},
	},
}

--Hint bar coloring...
local PREDATOR_HINT_COLOR_OVERHEAD 	= 	{ R=183/255, G=211/255,B=141/255}
local PREDATOR_HINT_COLOR_NORMAL 	= 	{ R=158/255, G=211/255,B=78/255}

local Predator_btn_hints_colors = {
	[PREDATOR_MODE_OFF] 				= PREDATOR_HINT_COLOR_NORMAL,
	[PREDATOR_MODE_OVERHEAD]		= PREDATOR_HINT_COLOR_OVERHEAD,
	[PREDATOR_MODE_GUIDED] 			= PREDATOR_HINT_COLOR_OVERHEAD,
	[PREDATOR_MODE_RC] 				= PREDATOR_HINT_COLOR_NORMAL,
	[PREDATOR_MODE_RC_DESTRUCT] 	= PREDATOR_HINT_COLOR_NORMAL,
}

--Target coloring...
local PREDATOR_TARGET_FRIENDLY	= 0 
local PREDATOR_TARGET_HOSTILE		= 1
local PREDATOR_TARGET_NORMAL 		= 2

local Predator_color_targets = {
	[PREDATOR_TARGET_NORMAL]			= 	{ R=197/255, G=197/255,	B=197/255},
	[PREDATOR_TARGET_HOSTILE]        = 	{ R=197/255, G=36/255,	B=0/255	},
	[PREDATOR_TARGET_FRIENDLY]       = 	{ R=136/255, G=211/255,	B=24/255	},
}

local Hud_predator_input_tracker 

function hud_predator_init()
	Hud_predator_doc = vint_document_find("hud_predator")
	
	-- subscribe to common inputs
	Hud_predator_input_tracker = Vdo_input_tracker:new()
	Hud_predator_input_tracker:add_input("map", "hud_predator_ignore_input", 50)
	Hud_predator_input_tracker:subscribe(false)
	
	--Button Hints...
	Predator_hint_bar = Vdo_hint_bar:new("btn_hints")
	Predator_hint_bar_x, Predator_hint_bar_y = vint_get_property(Predator_hint_bar.handle, "anchor")
	Predator_hint_bar:enable_text_shadow(true)
	Predator_hint_bar:set_hints(Predator_btn_hints[PREDATOR_MODE_GUIDED])
	
	Predator_cloned_objects = clone_table_create()
	Rc_cloned_objects 		= clone_table_create()
	Guided_cloned_objects 	= clone_table_create()

	--Setup guided interface...
	Hud_predator_guided.main_h = vint_object_find("guided")
	Hud_predator_guided.guided_lines_h = vint_object_find("guided_lines", Hud_predator_guided.main_h)
	Hud_predator_guided.line_h = vint_object_find("guided_line_bmp", Hud_predator_guided.guided_lines_h)
	Hud_predator_guided.alt_txt_h = vint_object_find("alt_txt", Hud_predator_guided.guided_lines_h)
	Hud_predator_guided.guided_right_grp_h = vint_object_find("guided_right_grp")
	vint_set_property(Hud_predator_guided.line_h, "visible", false)
	vint_set_property(Hud_predator_guided.alt_txt_h, "visible", false)
	
	--Reticule...
	Hud_predator_guided.reticule_h = vint_object_find("reticule_h", Hud_predator_guided.main_h)
	Hud_predator_guided.reticule_friend_h = vint_object_find("reticule_friend_h", Hud_predator_guided.main_h)
	
	--Setup meter...
	local rc_meter_bg_h = vint_object_find("rc_meter_bg")
	local rc_meter_fill_h = vint_object_find("rc_meter_fill")
	Hud_predator_rc.meter_bg_h = rc_meter_bg_h
	Hud_predator_rc.meter_fill_h = rc_meter_fill_h
	Hud_predator_rc.meter_max_scale_x, Hud_predator_rc.meter_max_scale_y = vint_get_property(rc_meter_bg_h, "scale")
	Hud_predator_rc.meter_max_width, Hud_predator_rc.meter_max_height = element_get_actual_size(rc_meter_bg_h)
	Hud_predator_rc.signal_txt_h = vint_object_find("signal_txt")	
	
	--Hide guided parts...	
	vint_set_property(Hud_predator_guided.main_h, "visible", false)
	
	--Hide satellite parts...
	Hud_predator_satellite.main_h = vint_object_find("satellite")
	Hud_predator_satellite.dumb_ammo_count_txt_h 	= vint_object_find("dumb_ammo_count_txt", Hud_predator_satellite.main_h)
		--Reticule...
	Hud_predator_satellite.reticule_h = vint_object_find("reticule_h", Hud_predator_satellite.main_h)
	Hud_predator_satellite.reticule_friend_h = vint_object_find("reticule_friend_h", Hud_predator_satellite.main_h)
	vint_set_property(Hud_predator_satellite.main_h, "visible", false)
	
	--Hide RC parts...
	Hud_predator_rc.main_h = vint_object_find("rc_car")
	vint_set_property(Hud_predator_rc.main_h, "visible", false)
	
	--All parts are setup.
	--Now subscribe to data and get the show on the road.
	vint_dataitem_add_subscription("sr2_local_player_satellite_weapon", "update", "hud_predator_update")
	vint_dataitem_add_subscription("game_paused_item", "update", "hud_predator_game_paused")	--to check if game is paused...
end

function hud_predator_cleanup()
	Predator_static_thread_on = false
end


-----------------------------------------------------------------------------------------
-- Update from C++
-----------------------------------------------------------------------------------------
function hud_predator_update(di_h)
	local satellite_mode, param1, param2, param3, param4, param5, param6, param7, param8, param9 = vint_dataitem_get(di_h)

	if satellite_mode == PREDATOR_MODE_OFF then
		--Turn off anything...
		if Predator_mode ~= PREDATOR_MODE_OFF then
			hud_predator_satellite_hide()
			hud_predator_guided_hide()		--hide guided missile stuff
			hud_predator_rc_hide()
			
			hud_predator_static_stop()
			hud_predator_set_hints(satellite_mode)
			hud_predator_vignette_show(false)
			Predator_mode = PREDATOR_MODE_OFF
		end
		Hud_predator_input_tracker:subscribe(false)
	elseif satellite_mode == PREDATOR_MODE_OVERHEAD then
	
		if Predator_mode ~= PREDATOR_MODE_OVERHEAD then
			hud_predator_satellite_hide()	--clear out satellite elements
			hud_predator_guided_hide()		--hide guided missile stuff
			hud_predator_rc_hide()			--hide rc
			hud_predator_static_stop()		--stop static
			
		
			hud_predator_satellite_show()	--show satellite elements
			hud_predator_static_start()	--restart static...
			hud_predator_set_hints(satellite_mode)
			hud_predator_vignette_show(true)
			
			Hud_predator_input_tracker:subscribe(true)
			Predator_mode = PREDATOR_MODE_OVERHEAD
		end
		
		hud_predator_satelite_update(param1, param2, param3, param4, param5, param6, param7, param8, param9)
	elseif satellite_mode == PREDATOR_MODE_GUIDED then
		if Predator_mode ~= PREDATOR_MODE_GUIDED then
			hud_predator_satellite_hide()
			hud_predator_rc_hide()
			hud_predator_static_stop()
			hud_predator_set_hints(satellite_mode)
			hud_predator_vignette_show(true)
			
			hud_predator_guided_show()
			
			Hud_predator_input_tracker:subscribe(true)
			Predator_mode = PREDATOR_MODE_GUIDED
		end
		hud_predator_guided_update(param1, param2, param3, param4, param5, param6, param7, param8, param9)
	elseif satellite_mode == PREDATOR_MODE_RC then
	
		
		if Predator_mode ~= PREDATOR_MODE_RC then
			hud_predator_rc_show()
			hud_predator_static_start()
			
			--Determine if we are gonna show the health or not...
			local show_help = param5
			local show_self_destruct_hint = param6

			if show_help ~= 0 then
				if show_self_destruct_hint ~= 0 then
					hud_predator_set_hints(PREDATOR_MODE_RC_DESTRUCT)
				else
					--Set hints..
					hud_predator_set_hints(satellite_mode)
				end
			else 
				--Hide hints...
				hud_predator_set_hints(PREDATOR_MODE_OFF)
			end
			
			hud_predator_vignette_show(true)
			
			Hud_predator_input_tracker:subscribe(true)
			Predator_mode = PREDATOR_MODE_RC
		end
		--speed, Max Speed, Acceleration , Signal Strength %
		hud_predator_rc_update(param1, param2, param3, param4)
	end
	
	--Upda
	--[[
			VINT_PROP_TYPE_INT,				
			// Satellite mode 0..3
			// 0 - off
			// 1 - satellite overhead
			// 2 - satellite guided
			// 3 - rc gun

			VINT_PROP_TYPE_FLOAT,
			// Satellite Drone Overhead		- Static %
			// Satellite Drone Missile		- Static %
			// RC Gun						- Speed

			VINT_PROP_TYPE_FLOAT,
			// Satellite Drone Overhead		- Angle heading in radians
			// Satellite Drone Missile		- Bank angle
			// RC Gun						- Max Speed

			VINT_PROP_TYPE_FLOAT,
			// Satellite Drone Overhead		- Distance to ground along camera
			// Satellite Drone Missile		- Altitude
			// RC Gun						- Acceleration from 0 to 1

			VINT_PROP_TYPE_FLOAT,
			// Satellite Drone Overhead		- Time to reload % (0=ready)
			// Satellite Drone Missile		- Target info (0=nothing, 1=bogey, 2 = friendly)
			// RC Gun						- Signal Strength %

			VINT_PROP_TYPE_FLOAT,
			// Satellite Drone Overhead		- Target info (0=nothing, 1=bogey, 2 = friendly)
			// Satellite Drone Missile		- n/a
			// RC Gun						- 		Show exit Rc mode (bool)

			VINT_PROP_TYPE_FLOAT,
			// Satellite Drone Overhead		- Outer Circle X (from -1 to 1)
			// Satellite Drone Missile		- n/a
			// RC Gun						- is self destruct...(bool)

			VINT_PROP_TYPE_FLOAT,
			// Satellite Drone Overhead		- Outer Circle Y (from -1 to 1)
			// Satellite Drone Missile		- n/a
			// RC Gun						- n/a

			VINT_PROP_TYPE_INT,
			// Satellite Drone Overhead		- Dumbfire ammo	
			// Satellite Drone Missile		- n/a
			// RC Gun						- n/a

			VINT_PROP_TYPE_INT,
			// Satellite Drone Overhead		- Guided ammo
			// Satellite Drone Missile		- n/a
			// RC Gun						- n/a
		
	]]
end

local HUD_PREDATOR_OVERHEAD_RING_RADIUS = 100 * 3

local HUD_PREADTOR_GUIDED_LINE_SPACING 	= 20 * 3		--spacing between lines...
local HUD_PREADTOR_GUIDED_RANGE			 	= 16		--Range of numbers
local HUD_PREADTOR_GUIDED_MAX_ALT		 	= 180		--Maximum altitude

function hud_predator_guided_show()
	--show guided hud...
	vint_set_property(Hud_predator_guided.main_h, "visible", true)
	
	local inner_ring_h = vint_object_create("inner_ring", "group", Hud_predator_guided.main_h)
	local inner_ring_bmp = vint_object_find("inner_ring_bmp", Hud_predator_guided.main_h)
	vint_set_property(inner_ring_bmp, "visible", false)

	local item_count = 8
	local rotation_spacing = PI2/item_count
	for i = 0, item_count - 1 do 
		local ring_h = vint_object_clone(inner_ring_bmp)
		vint_object_set_parent(ring_h, inner_ring_h)
		vint_set_property(ring_h, "rotation", rotation_spacing * i )
		vint_set_property(ring_h, "visible", true)
		clone_table_add(Guided_cloned_objects, ring_h)
	end

	Hud_predator_guided.inner_ring_h = inner_ring_h
	
	--Add our created group to clone table for cleanup.
	clone_table_add(Guided_cloned_objects, inner_ring_h)
end

function hud_predator_guided_hide()

	--hide items...
		vint_set_property(Hud_predator_guided.main_h, "visible", false)

	--delete everything out of range
	for i = -HUD_PREADTOR_GUIDED_RANGE, HUD_PREADTOR_GUIDED_MAX_ALT do
		if Hud_predator_guided.left_lines[i] ~= nil then
			vint_object_destroy(Hud_predator_guided.left_lines[i])
			Hud_predator_guided.left_lines[i] = nil
			
			vint_object_destroy(Hud_predator_guided.right_lines[i])
			Hud_predator_guided.right_lines[i] = nil
		end
		if Hud_predator_guided.left_text[i] ~= nil then
			vint_object_destroy(Hud_predator_guided.left_text[i])
			Hud_predator_guided.left_text[i] = nil
			
			vint_object_destroy(Hud_predator_guided.right_text[i])
			Hud_predator_guided.right_text[i] = nil
		end
	end

	clone_table_clear(Guided_cloned_objects)
end

function hud_predator_guided_update(static_pct, bank_angle, altitude, target_info)

	--adjust angles of our elements...
	vint_set_property(Hud_predator_guided.main_h, "rotation", -bank_angle)
	vint_set_property(Hud_predator_guided.inner_ring_h, "rotation", -bank_angle)
	
	--Arrange elements on screen...
	altitude = (altitude * .1)
	local altitude_rounded = floor(altitude + .5)
	local half_range = floor(HUD_PREADTOR_GUIDED_RANGE *.5)
	local lines_lower_limit = altitude_rounded - half_range
	local lines_upper_limit = altitude_rounded + half_range
	
	local total_lines_on_screen = 0
	for i = -HUD_PREADTOR_GUIDED_RANGE, HUD_PREADTOR_GUIDED_MAX_ALT do
		if i >= lines_lower_limit and i <= lines_upper_limit then
			if Hud_predator_guided.left_lines[i] == nil then
				local left_line_h = vint_object_clone(Hud_predator_guided.line_h)
				local x, y = vint_get_property(Hud_predator_guided.line_h, "anchor")
				
				local right_line_h = vint_object_clone(Hud_predator_guided.line_h)
				vint_object_set_parent(right_line_h, Hud_predator_guided.guided_right_grp_h)
				
				y = HUD_PREADTOR_GUIDED_LINE_SPACING  * i
				
				if i % 5 == 0 then
					element_set_actual_size(left_line_h, 35 * 3, 2 * 3)
					element_set_actual_size(right_line_h, 35 * 3, 2 * 3)
					local text_h = vint_object_clone(Hud_predator_guided.alt_txt_h)
					local altitude_text = i * (10 * 3)
					vint_set_property(text_h, "visible", true)
					vint_set_property(text_h, "text_tag", altitude_text)
					vint_set_property(text_h, "anchor", x - (7 * 3), y + (1 * 3))
					Hud_predator_guided.left_text[i] = text_h
					
					local text_h = vint_object_clone(Hud_predator_guided.alt_txt_h)
					vint_object_set_parent(text_h, Hud_predator_guided.guided_right_grp_h) 
					vint_set_property(text_h, "visible", true)
					vint_set_property(text_h, "text_tag", altitude_text)
					vint_set_property(text_h, "auto_offset", "w")
					vint_set_property(text_h, "anchor", x + (7 * 3), y)
					Hud_predator_guided.right_text[i] = text_h
				end
				
				vint_set_property(left_line_h, "anchor", x, y)
				vint_set_property(left_line_h, "visible", true)
				Hud_predator_guided.left_lines[i] = left_line_h
				
				vint_set_property(right_line_h, "visible", true)
				vint_set_property(right_line_h, "anchor", x, y)
				vint_set_property(right_line_h, "auto_offset", "e")
	
				Hud_predator_guided.right_lines[i] = right_line_h
			end
			total_lines_on_screen = total_lines_on_screen + 1
		else
			--delete everything out of range...
			if Hud_predator_guided.left_lines[i] ~= nil then
				vint_object_destroy(Hud_predator_guided.left_lines[i])
				Hud_predator_guided.left_lines[i] = nil
				
				vint_object_destroy(Hud_predator_guided.right_lines[i])
				Hud_predator_guided.right_lines[i] = nil
			end
			if Hud_predator_guided.left_text[i] ~= nil then
				vint_object_destroy(Hud_predator_guided.left_text[i])
				Hud_predator_guided.left_text[i] = nil
				
				vint_object_destroy(Hud_predator_guided.right_text[i])
				Hud_predator_guided.right_text[i] = nil
			end
		end
	end
	
	--set global group of guided missle lines ...
	local y =  -(altitude * HUD_PREADTOR_GUIDED_LINE_SPACING) + ((HUD_PREADTOR_GUIDED_RANGE * HUD_PREADTOR_GUIDED_LINE_SPACING)*.5)
	vint_set_property(Hud_predator_guided.guided_lines_h, "anchor", 0, y)
	
	if target_info ~= Hud_predator_guided.target_info then
		hud_predator_set_color(Hud_predator_guided.main_h, target_info)
		Hud_predator_guided.target_info = target_info
	end
	
	--set static percent...
	hud_predator_static_set(static_pct)
end

	
function hud_predator_satelite_update(static_pct, angle_heading_radians, distance_to_ground, time_to_reload_pct, target_info, outer_circle_x, outer_circle_y, dumbfire_ammo, guided_ammo)
	--Static

	--Hud_predator_static_alpha = static_pct + .2
	--Directional Indicator

	--Apply rotation...
	vint_set_property(Hud_predator_satellite.inner_ring_h, "rotation", angle_heading_radians)
	
	local inner_ring_direction_bmp_h = vint_object_find("inner_ring_direction_bmp")
	vint_set_property(Hud_predator_satellite.inner_ring_h, "rotation", angle_heading_radians)
	vint_set_property(Hud_predator_satellite.outer_ring_h, "rotation", -angle_heading_radians)
	vint_set_property(inner_ring_direction_bmp_h, "rotation", angle_heading_radians)
	
	local satelite_degrees_txt_h = vint_object_find("satelite_degrees_txt")
	local ssatelite_degrees_grp_h = vint_object_find("satelite_degrees_grp")
	vint_set_property(satelite_degrees_txt_h, "rotation", -angle_heading_radians)
	vint_set_property(ssatelite_degrees_grp_h, "rotation", angle_heading_radians)
	local degrees = floor( (angle_heading_radians / DEG_TO_RAD) )
	vint_set_property(satelite_degrees_txt_h, "text_tag", degrees )
	
	--Outer Ring Indicator...
	local x = HUD_PREDATOR_OVERHEAD_RING_RADIUS * outer_circle_x
	local y = HUD_PREDATOR_OVERHEAD_RING_RADIUS * outer_circle_y
	vint_set_property(Hud_predator_satellite.outer_ring_h, "anchor", x, y)
	
	--Set color based on target info...	
	if target_info ~= Hud_predator_satellite.target_info then
		hud_predator_set_color(Hud_predator_satellite.main_h, target_info)
		Hud_predator_satellite.target_info = target_info
	end
	
	--ammo is the sum of dumbfire and guided
	local ammo = dumbfire_ammo + guided_ammo
	
	if ammo ~= Hud_predator_satellite.ammo then
		if ammo < 0 then
			vint_set_property(Hud_predator_satellite.dumb_ammo_count_txt_h, "text_tag", "[image:uhd_ui_text_infinity]")
		else
			vint_set_property(Hud_predator_satellite.dumb_ammo_count_txt_h, "text_tag", ammo)
		end
		Hud_predator_satellite.ammo = ammo
	end
	
	hud_predator_static_set(static_pct)
end

-----------------------------------------------------------------------------------------
-- Builds satellite elements
--
function hud_predator_satellite_show()
	local satellite_h = vint_object_find("satellite")
	
	local inner_ring_h = vint_object_create("inner_ring", "group", satellite_h)
	local outer_ring_h = vint_object_create("outer_ring", "group", satellite_h)
	
	local inner_ring_bmp = vint_object_find("inner_ring_bmp", satellite_h)
	local outer_ring_bmp = vint_object_find("outer_ring_bmp", satellite_h)
	
	vint_set_property(inner_ring_bmp, "visible", false)
	vint_set_property(outer_ring_bmp, "visible", false)
	
	local item_count = 9
	local rotation_spacing = PI2/item_count
	for i = 0, item_count - 1 do 
		local ring_h = vint_object_clone(outer_ring_bmp)
		vint_object_set_parent(ring_h, outer_ring_h)
		vint_set_property(ring_h, "rotation", rotation_spacing * i )
		vint_set_property(ring_h, "visible", true)
		clone_table_add(Predator_cloned_objects, ring_h)
	end
	
	local item_count = 8
	local rotation_spacing = PI2/item_count
	for i = 0, item_count - 1 do 
		local ring_h = vint_object_clone(inner_ring_bmp)
		vint_object_set_parent(ring_h, inner_ring_h)
		vint_set_property(ring_h, "rotation", rotation_spacing * i )
		vint_set_property(ring_h, "visible", true)
		clone_table_add(Predator_cloned_objects, ring_h)
	end
	
	--Add our created groups to clone table for cleanup.
	clone_table_add(Guided_cloned_objects, inner_ring_h)
	clone_table_add(Guided_cloned_objects, outer_ring_h)
	
	--Store satellite stuff...
	Hud_predator_satellite.inner_ring_h = inner_ring_h
	Hud_predator_satellite.outer_ring_h = outer_ring_h

	--Show Hud...
	local satellite_h = vint_object_find("satellite")
	vint_set_property(satellite_h, "visible", true)
end

-----------------------------------------------------------------------------------------
-- Destroys Satelite elements and hides any remaining elements.
--
function hud_predator_satellite_hide()
	clone_table_clear(Predator_cloned_objects)
	
	--hide hud...
	local satellite_h = vint_object_find("satellite")
	vint_set_property(satellite_h, "visible", false)
end

-----------------------------------------------------------------------------------------
-- Builds RC Elements
--
function hud_predator_rc_show()
	local corner_ne_h = vint_object_find("corner_ne")
	local item_count = 3
	local rotation_spacing = PI/2
	for i = 1, item_count do 
		local corner_h = vint_object_clone(corner_ne_h)
		vint_set_property(corner_h, "rotation", rotation_spacing * i )
		vint_set_property(corner_h, "visible", true)
		clone_table_add(Rc_cloned_objects, corner_h)
	end
	
	--Show the base element...
	vint_set_property(Hud_predator_rc.main_h, "visible", true)
end

-----------------------------------------------------------------------------------------
-- STATIC!
-----------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------
-- Builds RC Elements
-----------------------------------------------------------------------------------------
function hud_predator_rc_hide()
	--Hide all parts
	vint_set_property(Hud_predator_rc.main_h, "visible", false)
	
	clone_table_clear(Rc_cloned_objects)
end

--Updats RC...
function hud_predator_rc_update(speed, speed_max, accelleration, signal_strength_pct)
	local pct = signal_strength_pct 
	pct = limit(pct, 0, 1)
	local pct_invert = 1.0 - pct
	local x_scale = Hud_predator_rc.meter_max_scale_x * (pct)
	vint_set_property(Hud_predator_rc.meter_fill_h, "scale", x_scale, Hud_predator_rc.meter_max_scale_y)
	
	local signal_strength_pct_txt = floor(pct * 100)
	
	local first_digit = "0."
	local second_digit = signal_strength_pct_txt
	
	if signal_strength_pct_txt < 10 then
		second_digit = "0" .. signal_strength_pct_txt
	end

	local values = { [0] = first_digit .. second_digit }
	local signal_strength_pct_txt = vint_insert_values_in_string("SATELLITE_RC_SIGNAL_STRENGTH", values)	
	vint_set_property(Hud_predator_rc.signal_txt_h, "text_tag", signal_strength_pct_txt)
	
	local static_pct = HUD_PREDATOR_BASE_STATIC_LEVEL + (pct_invert * (HUD_PREDATOR_MAX_STATIC_LEVEL - HUD_PREDATOR_BASE_STATIC_LEVEL))
	hud_predator_static_set(static_pct)
end


-----------------------------------------------------------------------------------------
-- STATIC!
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
--Starts up static...
--
function hud_predator_static_start()
	--Start Static...
	if Predator_static_thread_on == false then
		Predator_static_thread_on = true
		Predator_thread = thread_new("hud_predator_static_thread")
	end
end

-----------------------------------------------------------------------------------------
-- Stops static...
--
function hud_predator_static_stop()
	Predator_static_thread_on = false
	thread_kill(Predator_thread)
	
	--Destroy all tiles
	for idx, val in pairs(Hud_predator_static_tiles) do
		vint_object_destroy(val)
	end
end

--Static thread for predator drone...
function hud_predator_static_thread()
	while Predator_static_thread_on do
		hud_predator_static_fill_frame()
		thread_yield()
	end
end

function hud_predator_static_set(pct)
	Hud_predator_static_alpha = pct
end

function hud_predator_static_fill_frame()
	--grid size
	local tiles_width = 9
	local tiles_height = 7
	local tile_size = 190 *3
	local tile_size_varient = 30 *3
	local tile_uv_varient = 30 *3
	
	for idx, val in pairs(Hud_predator_static_tiles) do
		vint_object_destroy(val)
	end
	
	Hud_predator_static_tiles = {}
	local safe_frame_h = vint_object_find("safe_frame")
	local static_h = vint_object_create("static_grp", "group", safe_frame_h)
	vint_set_property(static_h, "anchor", rand_int(-25, -10), rand_int(-25, -10))
	vint_set_property(static_h, "alpha", Hud_predator_static_alpha) --vint_object_create("static_grp", "group", safe_frame_h)

	Hud_predator_static_tiles.static_h = static_h
	local tile_count = 0
	local cur_y = 0
	local tile_size_base = tile_size
	for tile_y = 0, tiles_height - 1 do
		tile_size = tile_size_base - rand_int(0, tile_size_varient)
		for tile_x = 0, tiles_width - 1 do 
			local bitmap_h = vint_object_create("static_image", "bitmap", static_h)
			vint_set_property(bitmap_h, "image", "ui_static")
			
			--Change UV Mapping
			local uv_x_varient = rand_int(0, tile_uv_varient)
			local uv_y_varient = rand_int(0, tile_uv_varient)
			vint_set_property(bitmap_h, "source_nw", uv_x_varient, uv_y_varient)
			vint_set_property(bitmap_h, "source_se", tile_size , tile_size)
			
			--position...
			local x = tile_x * tile_size
			local y = cur_y 
			
			--Flip UV
			local flip_x = rand_int(0,1)
			local flip_y = rand_int(0,1)
			if flip_x == 0 then
				flip_x = -1
				x = x + tile_size
			end
			if flip_y == 0 then
				flip_y = -1
				y = y + tile_size
			end
			
			
			vint_set_property(bitmap_h, "anchor", x, y)
			vint_set_property(bitmap_h, "scale", flip_x, flip_y)
			Hud_predator_static_tiles[tile_count] = bitmap_h
			tile_count = tile_count + 1
		end
		--Increment y positon...
		cur_y = cur_y + tile_size 
	end
end

-- Changes position of retecules in screen space
-- (x, y) screen space values(pre-translated for screen resolution)
-- Update call from hud.lua
function hud_predator_change_position(x, y)
	vint_set_property(Hud_predator_guided.main_h, "anchor", x, y)
	vint_set_property(Hud_predator_satellite.main_h, "anchor", x, y)
	vint_set_property(Hud_predator_rc.main_h, "anchor", x, y)
end

function hud_predator_set_hints(mode)
	Predator_hint_bar:set_hints(Predator_btn_hints[mode])
	--Predator_hint_bar:set_color(Predator_btn_hints_colors[mode])		--DO not color hints, just looks bad...(JMH 7/11/2011)
	local width, height = Predator_hint_bar:get_size()
	local x = Predator_hint_bar_x - (width/2)
	vint_set_property(Predator_hint_bar.handle, "anchor", x, Predator_hint_bar_y)
	
	Predator_hint_bar:enable_text_shadow(true)
end

-------------------------------------------------------------------------------
-- Sets the color of an element based on target info.
--
function hud_predator_set_color(item_h, target_info)
	local color_r = Predator_color_targets[target_info].R
	local color_g = Predator_color_targets[target_info].G
	local color_b = Predator_color_targets[target_info].B
	vint_set_property(item_h, "tint", color_r, color_g, color_b)
	
	if target_info == PREDATOR_TARGET_HOSTILE or target_info == PREDATOR_TARGET_NORMAL then
		vint_set_property(Hud_predator_guided.reticule_h, 			"visible", true)
		vint_set_property(Hud_predator_guided.reticule_friend_h, "visible", false)
		
		vint_set_property(Hud_predator_satellite.reticule_h, 			"visible", true)
		vint_set_property(Hud_predator_satellite.reticule_friend_h, "visible", false)
	else
		vint_set_property(Hud_predator_guided.reticule_h, 			"visible", false)
		vint_set_property(Hud_predator_guided.reticule_friend_h, "visible", true)	
		
		vint_set_property(Hud_predator_satellite.reticule_h, 			"visible", false)
		vint_set_property(Hud_predator_satellite.reticule_friend_h, "visible", true)
	end
end

function hud_predator_vignette_show(is_visible)
	local h = vint_object_find("vignette")
	vint_set_property(h, "visible", is_visible)
end


-------------------------------------------------------------------------------
-- When the game is paused we will hide certain elements of the screen...
--
function hud_predator_game_paused(di_h)
	local is_paused = vint_dataitem_get(di_h)
	local alpha = 1
	if is_paused == true then
		alpha = 0
	end
	--Using alpha here so we don't overlap with anything that the hud is normally doing...
	if Predator_mode == PREDATOR_MODE_RC then		
		vint_set_property(Hud_predator_rc.main_h, "alpha", alpha)
	elseif Predator_mode == PREDATOR_MODE_GUIDED then		
		vint_set_property(Hud_predator_guided.main_h, "alpha", alpha)
	elseif Predator_mode == PREDATOR_MODE_OVERHEAD then
		vint_set_property(Hud_predator_satellite.main_h, "alpha", alpha)
	end
	if Predator_mode ~= PREDATOR_MODE_OFF then
		Predator_hint_bar:set_alpha(alpha)
	end
end




-------------------------------------------------------------------------------
-- Ignore any unwanted input...
-------------------------------------------------------------------------------
function hud_predator_ignore_input(event)
end

function clone_table_create()
	local clone_table = {}
	clone_table.item_count = 0
	return clone_table
end

function clone_table_add(clone_table, handle_h)
	clone_table[clone_table.item_count] = handle_h
	clone_table.item_count = clone_table.item_count + 1
end

function clone_table_clear(clone_table)
	for i = 0, clone_table.item_count - 1 do
		vint_object_destroy(clone_table[i])
	end
	clone_table.item_count = 0
end