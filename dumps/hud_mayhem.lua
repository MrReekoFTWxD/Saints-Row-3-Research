
--Constants...	
local MAYHEM_DISPLAY_TYPE_CASH	 	= 0
local MAYHEM_DISPLAY_TYPE_POINTS 	= 1
local MAYHEM_DISPLAY_TYPE_SEC 		= 2
local MAYHEM_DISPLAY_TYPE_SEC_2 		= 3
local MAYHEM_DISPLAY_TYPE_CUSTOM 	= 4

Hud_mayhem_elements = {
	in_game_grp_h = -1,
	bonus_grp_h = -1,
	bonus_item_grp_h = -1,
	bonus_grp_start_x = -1,
	bonus_grp_start_y = -1,
}

Hud_mayhem_anims = {
	rise_anim_h = -1,
	bonus_item_grp_anim_h = -1
}

Hud_mayhem_world_cash_status = {
	depth = 0,
	text_intensity = 0,
	color_r = .89,
	color_g = .749,
	color_b = .05,
}
Hud_mayhem_world_cash = {}

Hud_mayhem_bonus_mod_status = {
	current_index = 0,
	cleared_index = 0,
	line_height = 25 * 3,
} 

Hud_mayhem_bonus_mods = {}


Hud_mayhem_world_cash_colors = {
	["WHITE"] 		= { ["r"] = .898,			 ["g"] = .894,				 ["b"] = .874}, 	--White
	["YELLOW"] 		= { ["r"] = 246/255, 	["g"] = 173/255,	 ["b"] = 40/255}, 	--Yellow
	["ORANGE"]		= { ["r"] = 235/255, 	["g"] = 98/255, 	["b"] = 5/255}, 	--Orange
	["RED"]			= { ["r"] = 220/255, 	["g"] = 47/255, 	["b"] = 9/255}, 	--Red
	["BLUE"]			= { ["r"] = .26,	["g"] = .501, 	["b"] = .835}, 
	["MID_BLUE"]	= { ["r"] = .145,	["g"] = .419, 	["b"] = .811}, 
	["DARK_BLUE"]	= { ["r"] = .027,	["g"] = .341, 	["b"] = .788},
}

--object handles...
local Hud_mayhem_combo_total_item_h = 0

-- Local player combo hud data
local HUD_COMBO_OFFESET_X = 100 * 3
local HUD_COMBO_OFFESET_Y = 0

local HUD_PLAYER_INVALID_ID	= 0

local HP_TEXT	= 0
local HP_VALUE	= 1

-- Player combo hud data
-- NOTE: It is not local because this hud has been opened to LUA and these defines are shared.
HPT_NONE				= 0
HPT_POINTS			= 1
HPT_DISTANCE		= 2
HPT_TIME				= 3
HPT_MONEY			= 4
HPT_DEGREES			= 5
HPT_MULTIPLIER		= 6
HPT_MESSAGE_ONLY	= 7
HPT_SECONDS			= 8

HPS_NONE				= 0
HPS_MINUS			= 1
HPS_PLUS				= 2
HPS_MULTIPLIER		= 3

-- Player combo hud skin types
HP_SKIN_DEFAULT 	= 0

-- Player combo hud skin data
local Hud_player_skins = {
	[HP_SKIN_DEFAULT]	= {
		[HP_TEXT]	= { 0.898, 0.894, 0.874 }, -- White
		[HP_VALUE]	= { 0.898, 0.894, 0.874 }, -- White
	},
}

function hud_mayhem_init()
	--Find and store elements
	local h = vint_object_find("mayhem_grp")
	
	--In world cash
	Hud_mayhem_elements.in_game_grp_h = vint_object_find("mayhem_cash_grp")		-- in world cash
	Hud_mayhem_anims.rise_anim_h = vint_object_find("mayhem_rise_anim")			-- in world cash
	Hud_mayhem_combo_total_item_h = vint_object_find("combo_total_item")		--combo totals
	
	-- hide base elements
	vint_set_property(Hud_mayhem_elements.in_game_grp_h, "visible", false)
	vint_set_property(Hud_mayhem_combo_total_item_h, "visible", false)
	
	--Subscribe to data items
	vint_dataitem_add_subscription("local_player_combohud", "update", "hud_mayhem_combo_total_update")
	
	autil_hud_mayhem_init( )
end

function hud_mayhem_world_cash_update(di_h)
	--[[
		VINT_PROP_TYPE_FLOAT          - World position (x)
		VINT_PROP_TYPE_FLOAT          - World position (y)
		VINT_PROP_TYPE_FLOAT          - World position (z)
		VINT_PROP_TYPE_VECTOR2F    	- Screen position
		VINT_PROP_TYPE_INT            - Cash value
		VINT_PROP_TYPE_FLOAT          - Text intensity
		VINT_PROP_TYPE_INT        	- Multiplier value
		VINT_PROP_TYPE_INT			- Type 0 = $$, 1 = Points, 2 = Seconds, 3 = Seconds added, 4 = Custom text
		VINT_PROP_TYPE_ING	  		- Line offset
		VINT_PROP_TYPE_FLOAT		- Text scale
		VINT_PROP_TYPE_STRING		- Custom text string
		
	]]
	local world_x, world_y, world_z, screen_pos_x, screen_pos_y, cash_value, text_intensity, multiplier, display_type, line_offset, scale, custom_text = vint_dataitem_get(di_h)
								
	--debug_print("vint", "hud_mayhem_world_cash_update: di_h " .. di_h .. "\n")
	--debug_print("vint", "hud_mayhem_world_cash_update: cash_value $" .. cash_value .. "\n")

	if display_type == nil then
		display_type = 0
	end

	--Don't do anything else if this is a dummy object.
	if cash_value == 0 then
		--reset text color
		hud_mayhem_text_color_change(text_intensity)
		return
	end

	--If this item has't been created, make a new one and set it up
	if Hud_mayhem_world_cash[di_h] == nil then
		--Reset text color
		hud_mayhem_text_color_change(text_intensity)
		
		--Clone New item
		local grp_h = vint_object_clone(Hud_mayhem_elements.in_game_grp_h)
		local sub_grp_h = vint_object_find("cash_sub_grp", grp_h)
		local cash_txt_h = vint_object_find("cash_txt", grp_h)
		local multiplier_txt_h = vint_object_find("multiplier_txt", grp_h)
		local anim_h = vint_object_clone(Hud_mayhem_anims.rise_anim_h)

		--show gombo cash...
		vint_set_property(grp_h, "visible", true)
		
		--Set the scale
		local base_scale_x, base_scale_y = vint_get_property(grp_h, "scale")
		vint_set_property(grp_h, "scale", base_scale_x * scale, base_scale_y * scale)

		--Rotate and set depth
		vint_set_property(grp_h, "rotation", rand_float(-0.249, 0.249))
		vint_set_property(grp_h, "depth", Hud_mayhem_world_cash_status.depth)
	
		--Hide the group for the first frame since it takes a frame for tweens to play.
		vint_set_property(sub_grp_h, "alpha", 0)
		
		--Retarget Tweens
		vint_set_property(anim_h, "target_handle", grp_h)
		
		--Randomize Tween Direction
		local twn_h = vint_object_find("txt_anchor_twn_1", anim_h)
		vint_set_property(twn_h, "end_value", rand_int(-20 * 3, 20 * 3), rand_int(-0,-30 * 3))
		
		--Callback tween to kill objects and stuff
		local callback_twn_h = vint_object_find("txt_anchor_twn_1", anim_h)
		vint_set_property(callback_twn_h, "end_event", "hud_mayhem_cash_destroy")
						
		--Tint Cash Text
		vint_set_property(cash_txt_h, "tint", Hud_mayhem_world_cash_status.color_r, Hud_mayhem_world_cash_status.color_g, Hud_mayhem_world_cash_status.color_b)
		
		-- +{0}sec   HUD_AMT_SECS
		-- +{0}points   HUD_AMT_POINTS
		
		--HUD_AMT_POINTS
		local insertion_text = { [0] = floor(cash_value) }
		local amt = ""

		if display_type == MAYHEM_DISPLAY_TYPE_CASH then
			--Cash
			amt =  "$" .. cash_value
		elseif display_type == MAYHEM_DISPLAY_TYPE_POINTS then
			--Points
			amt = vint_insert_values_in_string("HUD_AMT_POINTS", insertion_text)
		elseif display_type == MAYHEM_DISPLAY_TYPE_SEC then
			--Seconds
			amt = vint_insert_values_in_string("HUD_AMT_SECS", insertion_text)
		elseif display_type == MAYHEM_DISPLAY_TYPE_SEC_2 then
			--seconds + green
			amt = vint_insert_values_in_string("HUD_AMT_SECS", insertion_text)
			--Force green text
			vint_set_property(cash_txt_h, "tint", 0, 1, 0.25)
		elseif display_type == MAYHEM_DISPLAY_TYPE_CUSTOM then
			amt = custom_text

			--Override default tween end position and rotation
			vint_set_property(twn_h, "end_value", rand_int(-25 * 3, 25 * 3), rand_int(0,10 * 3))
			vint_set_property(grp_h, "rotation", 0)
		end
		
		vint_set_property(cash_txt_h, "text_tag", amt)	
		

		--Format Text with or without multiplier
		if multiplier ~= 0 then
			--Show Multiplier and Align text
			
			--Set MultiplierText Value
			vint_set_property(multiplier_txt_h, "text_tag", "X" .. multiplier)
			
			--Alignment
			local spacing = 5 * 3
			local c_w, c_h = vint_get_property(cash_txt_h, "screen_size")
			local c_x, c_y = vint_get_property(cash_txt_h, "anchor")
			local m_w, m_h = vint_get_property(multiplier_txt_h, "screen_size")
			local m_x, m_y = vint_get_property(multiplier_txt_h, "anchor")
			local half_w = (c_w + m_w + spacing) / 2
			local c_x = 0 - half_w 
			local m_x = c_x + c_w + spacing
			
			--Set Properties
			vint_set_property(cash_txt_h, "anchor", c_x, c_y)
			vint_set_property(multiplier_txt_h, "anchor", m_x, m_y)
		else
			--Hide multiplier and center text
			
			vint_set_property(multiplier_txt_h, "visible", false)
			
			--Alignment
			local c_w, c_h = vint_get_property(cash_txt_h, "screen_size")
			local c_x, c_y = vint_get_property(cash_txt_h, "anchor")
			local c_x = 0 - (c_w / 2)
			
			--Set Properties
			vint_set_property(cash_txt_h, "anchor", c_x, c_y)
		end

		--play tween in animation
		lua_play_anim(anim_h, 0)
		
		--Decrement depth
		Hud_mayhem_world_cash_status.depth = Hud_mayhem_world_cash_status.depth - 1
		
		--Store values and handles to process later
		Hud_mayhem_world_cash[di_h] = {
			di_h = di_h,
			grp_h = grp_h,
			sub_grp_h = sub_grp_h,
			anim_h = anim_h,
			twn_h = callback_twn_h
		}
		
	end

	--Calculate and set the position
	local size_x, size_y = vint_get_property(Hud_mayhem_world_cash[di_h].grp_h, "screen_size")
	screen_pos_y = screen_pos_y + (line_offset * (size_y - (10 * 3)))
	vint_set_property(Hud_mayhem_world_cash[di_h].grp_h, "anchor", screen_pos_x, screen_pos_y)

end

function hud_mayhem_text_color_change(text_intensity)
	--Combo Color update
	--Prepare color morphing based on intensity
	local color1, color2, morph_value
	if text_intensity < 0.5 then
		if MP_enabled == true then
			color1 = Hud_mayhem_world_cash_colors["BLUE"]
			color2 = Hud_mayhem_world_cash_colors["MID_BLUE"]
		else
			color1 = Hud_mayhem_world_cash_colors["YELLOW"]
			color2 = Hud_mayhem_world_cash_colors["ORANGE"]
		end
		morph_value = text_intensity / 0.5
	else
		if text_intensity > 1 then 
			morph_value = (text_intensity -1) -- 1..2
			color1 = Hud_mayhem_world_cash_colors["MID_BLUE"]
			color2 = Hud_mayhem_world_cash_colors["DARK_BLUE"]
		elseif MP_enabled == true then
			color1 = Hud_mayhem_world_cash_colors["MID_BLUE"]
			color2 = Hud_mayhem_world_cash_colors["DARK_BLUE"]
		else
			color1 = Hud_mayhem_world_cash_colors["ORANGE"]
			color2 = Hud_mayhem_world_cash_colors["RED"]
		end
		morph_value = (text_intensity - 0.5) / 0.5
	end
	
	Hud_mayhem_world_cash_status.color_r = color1.r - ((color1.r - color2.r) * morph_value)
	Hud_mayhem_world_cash_status.color_g = color1.g - ((color1.g - color2.g) * morph_value)
	Hud_mayhem_world_cash_status.color_b = color1.b - ((color1.b - color2.b) * morph_value)
	Hud_mayhem_world_cash_status.text_intensity = text_intensity
end

function hud_mayhem_world_cash_remove(di_h)
	--Destroy objects, animation and values
	if Hud_mayhem_world_cash[di_h] ~= nil then
		--Destroy animation
		vint_object_destroy(Hud_mayhem_world_cash[di_h].anim_h)
		--Destroy group object
		vint_object_destroy(Hud_mayhem_world_cash[di_h].grp_h)
		--Destroy stored values
		Hud_mayhem_world_cash[di_h] = nil	
	end
end

--Destroys world cash text
function hud_mayhem_cash_destroy(twn_h, event)
	for idx, val in pairs(Hud_mayhem_world_cash) do
		if val.twn_h == twn_h then
		
			--Destroy animation, text object and Data item
			vint_object_destroy(val.anim_h)
			vint_object_destroy(val.grp_h)
			if val.di_h ~= -1 then
				vint_datagroup_remove_item("mayhem_local_player_world_cash", val.di_h)
			end
			
			--Destroy stored values
			Hud_mayhem_world_cash[idx] = nil	
		end
	end
	
	--reset values if this is the last cash item
	local cash_item_count = 0
	local is_last_item = true
	for idx, val in pairs(Hud_mayhem_world_cash) do
		cash_item_count = cash_item_count + 1
		is_last_item = false
		break
	end
end

local Combo_totals = {}
local Combo_totals_cleanup_data = {}
local Combo_total_last_update_id = -2

function hud_mayhem_combo_total_update(di_h)
	--[[
		VINT_PROP_TYPE_UINT  - Message ID
		VINT_PROP_TYPE_FLOAT - World position (x)
		VINT_PROP_TYPE_FLOAT - World position (y)
		VINT_PROP_TYPE_UINT  - Message crc (can be nil/invalid crc)
		VINT_PROP_TYPE_FLOAT - Message display value (can be nil)
		VINT_PROP_TYPE_FLOAT - Message meter value (can be nil)
		VINT_PROP_TYPE_FLOAT - Text intensity.  -1.0 is off.  Otherwise a 0.0 - 1.0 scale
		VINT_PROP_TYPE_INT   - The message type id
		VINT_PROP_TYPE_INT   - The symbol id
		VINT_PROP_TYPE_INT   - The skin id
		VINT_PROP_TYPE_BOOL  - Play animations
		VINT_PROP_TYPE_BOOL  - Show the meter
		VINT_PROP_TYPE_BOOL  - If the meter is flashing
	]]
	local id, x, y, desc_crc, display_value, meter_value, text_intensity, value_type, value_symbol, skin, do_animation, show_meter, meter_flashing = vint_dataitem_get(di_h)
	
	-- When the data item is first initialized, nil values are passed.  Catch this and exit.
	if id == nil then
		return
	end
	
	if Combo_totals[id] == nil then
		--New ID
		
		--Fade out anim... and set to cleanup...
		local old_combo_total = Combo_totals[Combo_total_last_update_id]
		if old_combo_total ~= nil then
			--Play anim out, the callback will handle the rest of cleanup...
			lua_play_anim(old_combo_total.anim_out_h)
			Combo_total_last_update_id = HUD_PLAYER_INVALID_ID
		end
		
		if id == HUD_PLAYER_INVALID_ID then
			--just needed to destroy the old one
			return
		end
		
		local item_h = vint_object_clone(Hud_mayhem_combo_total_item_h)
		
		vint_set_property(item_h, "visible", true)
		
		--Play animation in, only if we need to...
		local anim_in_h = vint_object_find("combo_total_in_anim")
		
		if do_animation ~= true then
			--smooth fade in...
			anim_in_h = vint_object_find("combo_total_smooth_in_anim")
		end
		
		--Clone animation and target item...
		anim_in_h = vint_object_clone(anim_in_h)
		vint_set_property(anim_in_h, "target_handle", item_h)

		--Clone out animation and target item...
		local anim_out_h = vint_object_find("combo_total_out_anim")
		anim_out_h = vint_object_clone(anim_out_h)
		vint_set_property(anim_out_h, "target_handle", item_h)
		
		--Set callback and data for animation to hide item and clean up the data...
		local twn_h = vint_object_find("combot_total_out_twn", anim_out_h)
		vint_set_property(twn_h, "end_event", "hud_mayhem_combo_total_cleanup")
		Combo_totals_cleanup_data[twn_h] = id
		
		-- Set the skin and colors for the message
		if skin == nil or skin < 0 then
			skin = HP_SKIN_DEFAULT
		end
		
		local title_color = Hud_player_skins[skin][HP_TEXT]
		local val_color = Hud_player_skins[skin][HP_VALUE]
			
		local title_txt_h = vint_object_find("combo_title_txt", item_h)
		local value_txt_h = vint_object_find("combo_value_txt", item_h)
		vint_set_property(title_txt_h, "tint", title_color[1], title_color[2], title_color[3])
		vint_set_property(value_txt_h, "tint", val_color[1], val_color[2], val_color[3])

		--Configure meter if needed
		local meter = Vdo_gsi_meter:new("combo_total_meter", item_h)
		local combo_total_meter_value_h = vint_object_find("combo_total_meter_value", item_h)
		local meter_val_in_anim_h = vint_object_find("combo_total_meter_val_in_anim")
		meter_val_in_anim_h = vint_object_clone(meter_val_in_anim_h)
		
		if show_meter == true then
			--Show combo meter/hide value text...
			meter:set_visible(true)
			vint_set_property(value_txt_h, "visible", false)
			vint_set_property(combo_total_meter_value_h, "visible", true)
			
			--Creates the meter(initializing values..
			meter:create()
			
			--target animation to combo meter value...
			vint_set_property(meter_val_in_anim_h, "target_handle", combo_total_meter_value_h)
			
			-- Set the default color
			vint_set_property(combo_total_meter_value_h, "tint", val_color[1], val_color[2], val_color[3])
		else
			meter:set_visible(false)
			vint_set_property(value_txt_h, "visible", true)
			vint_set_property(combo_total_meter_value_h, "visible", false)
		end
		
		--Fade in...
		lua_play_anim(anim_in_h)

		--Store off for later...
		Combo_totals[id] = {
			item_h = item_h, 
			meter = meter,
			meter_display_value = display_value - 2, -- Why do it this way?  -1 might be a valid value, but this will always work
			text_intensity = -1, -- Default, means no text intensity is used
			anim_in_h = anim_in_h,
			anim_out_h = anim_out_h,
			meter_val_in_anim_h = meter_val_in_anim_h,
		}
	end
	
	--update!
	local combo_total = Combo_totals[id]
	
	vint_set_property(combo_total.item_h, "anchor", x + HUD_COMBO_OFFESET_X, y + HUD_COMBO_OFFESET_Y)
	local title_txt_h = vint_object_find("combo_title_txt", combo_total.item_h)
	local value_txt_h = vint_object_find("combo_value_txt", combo_total.item_h)
	
	--Set title description...
	if desc_crc ~= nil and desc_crc ~= 0 then
		vint_set_property(title_txt_h, "text_tag_crc", desc_crc)
	end
	
	--Set symbol
	local symbol = ""
	if value_symbol == HPS_MINUS then
		symbol = "-"
	elseif value_symbol == HPS_PLUS then
		symbol = "+"
	elseif value_symbol == HPS_MULTIPLIER then
		symbol = "X"
	end
	
	--Handle the display value being nil
	if display_value == nil then
		display_value = 0
	end
	
	--Set amount...
	local insertion_text = { [0] = symbol .. floor(display_value) }
	local amt = ""
	
	if value_type == HPT_NONE then
		-- Standard integer
		amt = symbol .. floor(display_value)
	elseif value_type == HPT_POINTS then
		-- Points
		amt = vint_insert_values_in_string("HUD_AMT_POINTS", insertion_text)
	elseif value_type == HPT_DISTANCE then
		-- Distance
		amt = symbol .. format_distance(display_value)
	elseif value_type == HPT_TIME then
		-- Seconds . Milliseconds
		amt = symbol .. format_time(display_value, true, true)
	elseif value_type == HPT_SECONDS then
		-- Seconds without milliseconds
		amt = symbol .. format_time(display_value, false, true)
	elseif value_type == HPT_MONEY then
		-- Cash
		amt = symbol .. "$" .. format_cash(floor(display_value))
	elseif value_type == HPT_DEGREES then
		-- Degrees
		amt = vint_insert_values_in_string("HUD_AMT_DEGREES", insertion_text)
	elseif value_type == HPT_MULTIPLIER then
		-- Multiplier, A digit formatted as such: 1.5X
		
		-- Make it show one significant digit
		display_value = display_value * 10
		floor(display_value)
		display_value = display_value / 10
		
		amt = symbol .. display_value .. "X"
	elseif value_type == HPT_MESSAGE_ONLY then
		-- No display value at all
		vint_set_property(value_txt_h, "visible", false)
		vint_set_property(combo_total_meter_value_h, "visible", false)
	end
	
	-- Set the value to the correct place depending on if the meter should show.
	if show_meter == true then
		local combo_total_meter_value_h = vint_object_find("combo_total_meter_value", combo_total.item_h)
		local meter = combo_total.meter
		
		-- First we need to set the color based on if a text_intensity exists and has been changed
		if combo_total.text_intensity ~= text_intensity then
			if text_intensity < 0 then
				local val_color = Hud_player_skins[skin][HP_VALUE]
				vint_set_property(combo_total_meter_value_h, "tint", val_color[1], val_color[2], val_color[3])
			else
				hud_mayhem_text_color_change(text_intensity)
				vint_set_property(combo_total_meter_value_h, "tint", Hud_mayhem_world_cash_status.color_r, Hud_mayhem_world_cash_status.color_g, Hud_mayhem_world_cash_status.color_b)
			end
			
			combo_total.text_intensity = text_intensity
		end
		
		-- Next update the display value if it has changed
		if combo_total.meter_display_value ~= display_value then
			--Set value of bonus label...
			vint_set_property(combo_total_meter_value_h, "text_tag", amt)
			
			--realign text to size of it so it stays centered for animation but left aligned to the title...
			local width, height = element_get_actual_size(combo_total_meter_value_h)
			local x, y = vint_get_property(combo_total_meter_value_h, "anchor")
			x = width/2
			vint_set_property(combo_total_meter_value_h, "anchor", x, y)

			x, y = vint_get_property(meter.handle, "anchor")
			x = width + (8 * 3) -- half the width of our combo value and 5 for padding...
			vint_set_property(meter.handle, "anchor", x, y)
			
			lua_play_anim(combo_total.meter_val_in_anim_h)
			
			combo_total.meter_display_value = display_value
		end
		
		--Make sure the meter range is valid
		if meter_value < 0 then
			meter_value = 0
		elseif meter_value > 1 then
			meter_value = 1
		end

		--Always update the meter...
		meter:update(true, "Mayhem", 0, meter_value, meter_flashing)
		
	-- No meter, just set it to the regular value text tag.
	else
		-- First we need to set the color based on if a text_intensity exists and has been changed
		if combo_total.text_intensity ~= text_intensity then
			if text_intensity < 0 then
				local val_color = Hud_player_skins[skin][HP_VALUE]
				vint_set_property(value_txt_h, "tint", val_color[1], val_color[2], val_color[3])
			else
				hud_mayhem_text_color_change(text_intensity)
				vint_set_property(value_txt_h, "tint", Hud_mayhem_world_cash_status.color_r, Hud_mayhem_world_cash_status.color_g, Hud_mayhem_world_cash_status.color_b)
			end
			
			combo_total.text_intensity = text_intensity
		end
		
		vint_set_property(value_txt_h, "text_tag", amt)
	end
	
	if x == 0 and y == 0 then
		vint_set_property(combo_total.item_h, "visible", false)
	else
		vint_set_property(combo_total.item_h, "visible", true)
	end
	
	--Store off update id...
	Combo_total_last_update_id = id
end


-------------------------------------------------------------------------------
-- Cleans up the combo total after the out animation has played...
-------------------------------------------------------------------------------
function hud_mayhem_combo_total_cleanup(twn_h)
	local combo_destroy_data = Combo_totals_cleanup_data[twn_h] 
	if combo_destroy_data ~= nil then
	
		local combo_data = Combo_totals[combo_destroy_data]
	
		--Destroy Objects...
		vint_object_destroy(combo_data.item_h)
		vint_object_destroy(combo_data.anim_in_h)
		vint_object_destroy(combo_data.anim_out_h)
		vint_object_destroy(combo_data.meter_val_in_anim_h)
		
		--Destroy Data in cleanup table...
		Combo_totals_cleanup_data[twn_h] = nil
		
		--Destroy data in  combo totals table...
		Combo_totals[combo_destroy_data] = nil
	end
end
