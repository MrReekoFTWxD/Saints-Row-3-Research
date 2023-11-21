-- vint_meter_type
local HDM_NONE                = -1
local HDM_DISTANCE            = 0
local HDM_XY                  = 1
local HDM_COUNTER             = 2
local HDM_TIME                = 3
local HDM_PERCENT             = 4
local HDM_TEXT                = 5
local HDM_QTE                	= 6

-- diversion_status
local HDIS_IN_PROGRESS              = 0
local HDIS_CANCELLED                = 1
local HDIS_COMPLETE                 = 2
local HDIS_COMPLETE_DO_NOT_SHOW_HUD = 3

-- Message Type
local HDT_NONE	= -1

-- Challenge Diversion Type
local DT_CHALLENGE = 1

-- Invalid enums
local STATS_INVALID = -1
local DT_NONE = -1

local DIVERSION_ANCHOR_OFFSET = 60 * 3
local DIVERSION_MAX_STEPS = 3
local DIVERSION_METER_PCT_FUDGE = 0.02
local DIVERSION_MAX = 5
local DIVERSIONS_MAX_FIRE = 14

local CHAL_TITLE_X = 100 * 3
local CHAL_TITLE_NO_IMAGE_X = 11 * 3
local CHAL_TITLE_Y = -36 * 3
--local CHAL_METER_MAX = 204

local Hud_challenge_data = {}
local Hud_diversions = {}
local Div_slots = {}
local Num_divs = 0
local Meter_max = 0
local Meter_height = 0

Hud_diversion_doc = 0 

Hud_diversion_is_paused = false

function hud_diversion_init()
	Hud_diversion_doc = vint_document_find("hud_diversion")
	
	-- hide base group
	local div_base = Vdo_base_object:new("div_base")
	div_base:set_visible(false)
	
	local meter_fill = Vdo_base_object:new("meter_fill", div_base.handle)
	meter_fill:set_color(COLOR_RESPECT_METER.R, COLOR_RESPECT_METER.G, COLOR_RESPECT_METER.B)
	
	local chal_grp = Vdo_base_object:new("chal_grp")
	chal_grp:set_visible(false)
	chal_grp:set_alpha(0)
	
	local chal_meter_fill = Vdo_base_object:new("chal_meter_fill")
	Meter_max, Meter_height = chal_meter_fill:get_actual_size()
	
	-- subscriptions
	vint_dataitem_add_subscription("hud_challenge", "update", "hud_diversion_chal_data_item_update")
	vint_datagroup_add_subscription("hud_diversion", "update", "hud_diversion_data_item_update")
end

function hud_diversion_data_item_update(di_h)
	--[[
		Hud Diversions datagroup members:
		VINT_PROP_TYPE_INT            - Meter type
		VINT_PROP_TYPE_UINT           - Line one message crc or string to display in the meter (diversion name)
		VINT_PROP_TYPE_UINT           - Line two message crc to display in the meter (diversion name)
		VINT_PROP_TYPE_FLOAT          - Current value/time/distance
		VINT_PROP_TYPE_FLOAT          - Min value/time/distance
		VINT_PROP_TYPE_FLOAT          - Max value/time/distance
		VINT_PROP_TYPE_BOOL           - Whether the meter should be descending or not.
		VINT_PROP_TYPE_INT            - Diversion status
		VINT_PROP_TYPE_INT            - Respect
		VINT_PROP_TYPE_FLOAT          - Cash
		VINT_PROP_TYPE_INT            - Diversion Type
		VINT_PROP_TYPE_INT            - Respect Stat
		VINT_PROP_TYPE_INT            - Type of message, passed directly back to code on removal
	]]

	local meter_type, message_one, message_two, cur_value, min_value, max_value, descending, status, respect, cash, div_type, respect_stat, message_type = vint_dataitem_get(di_h)
	hud_diversion_update(di_h, meter_type, message_one, message_two, cur_value, min_value, max_value, descending, status, respect, cash, div_type, respect_stat, message_type)
end

function hud_diversion_update(index, meter_type, message_one, message_two, cur_value, min_value, max_value, descending, status, respect, cash, div_type, respect_stat, message_type)	
	
	--If this item has't been created, make a new one and set it up
	if Hud_diversions[index] == nil then	
				
		if Num_divs == DIVERSION_MAX then
			return
		end
		
		-- clone new object
		local div_base = Vdo_base_object:new("div_base")
		local div_anim_in = Vdo_anim_object:new("div_anim_in")
		local div_anim_complete = Vdo_anim_object:new("div_anim_complete")
		local div_anim_shift_up = Vdo_anim_object:new("div_anim_shift_up")
		local div_anim_multi = Vdo_anim_object:new("div_anim_multi")
		local div_anim_fire = Vdo_anim_object:new("div_anim_fire")
		local div_anim_fire_scale = Vdo_anim_object:new("div_anim_fire_scale")
		
		div_base:set_visible(false)
		
		local grp = Vdo_base_object:clone(div_base.handle)
		local anim_in = Vdo_anim_object:clone(div_anim_in.handle)
		local anim_complete = Vdo_anim_object:clone(div_anim_complete.handle)
		local anim_shift_up = Vdo_anim_object:clone(div_anim_shift_up.handle)
		local anim_multi = Vdo_anim_object:clone(div_anim_multi.handle)
		local anim_fire = Vdo_anim_object:clone(div_anim_fire.handle)
		local anim_fire_scale = Vdo_anim_object:clone(div_anim_fire_scale.handle)
		
		local div_respect = Vdo_base_object:new("div_respect", grp.handle)
		--local div_clip_resize_twn = Vdo_tween_object:new("div_clip_resize_twn", anim_complete.handle)
		
		grp:set_visible(true)
		anim_in:set_target_handle(grp.handle)		
		anim_complete:set_target_handle(grp.handle)		
		anim_shift_up:set_target_handle(grp.handle)
		anim_multi:set_target_handle(grp.handle)
		anim_fire:set_target_handle(grp.handle)
		anim_fire_scale:set_target_handle(grp.handle)
		
		local shift_up_grp = Vdo_base_object:new("div_shift_up_grp", grp.handle)
		local shift_up_x, shift_up_y = shift_up_grp:get_anchor()
		shift_up_grp:set_anchor(shift_up_x, DIVERSION_ANCHOR_OFFSET * Num_divs)		
		
		local div_in_twn = Vdo_tween_object:new("div_in_twn", anim_in.handle)
		local start_value_x, start_value_y = div_in_twn:get_start_value()
		local end_value_x, end_value_y = div_in_twn:get_end_value()
		--div_in_twn:set_property("start_value", start_value_x, start_value_y) 
		div_in_twn:set_property("end_value", end_value_x, start_value_y)
		
		local fire_scale_twn = Vdo_tween_object:new("fire_scale_twn", anim_fire_scale.handle)
		local fire_scale_x_start, fire_scale_y_start = fire_scale_twn:get_start_value()
		local fire_scale_x_end, fire_scale_y_end = fire_scale_twn:get_end_value()
		
		anim_in:play(0)		

		--div_clip_resize_twn:set_property("end_value",-180, 50)
		
		Hud_diversions[index] = {
			index              = index,
			grp                = grp,
			anim_in            = anim_in,
			anim_complete      = anim_complete,
			anim_shift_up      = anim_shift_up,
			anim_multi         = anim_multi,
			anim_fire          = anim_fire,
			anim_fire_scale    = anim_fire_scale,
			fire_scale_x_start = fire_scale_x_start,
			fire_scale_y_start = fire_scale_y_start,
			fire_scale_x_end   = fire_scale_x_end,
			fire_scale_y_end   = fire_scale_y_end,
			div_level          = 0,
			fire_count         = -1,
			cash               = 0,
			respect            = 0,
			div_type           = -1,
			respect_stat       = -1,
			message_type       = -1
		}
		
		hud_diversion_add_slot(index)
		
	end
	
	Hud_diversions[index].cash         = cash
	Hud_diversions[index].respect      = respect
	Hud_diversions[index].div_type     = div_type
	Hud_diversions[index].respect_stat = respect_stat
	Hud_diversions[index].message_type = message_type
	
	local grp = Hud_diversions[index].grp
	local div_title = Vdo_base_object:new("div_title", grp.handle)
	
	-- set title
	if type(message_one) == "string" then
		div_title:set_text(message_one, false)
	elseif type(message_one) == "number" then
		div_title:set_text(message_one, true)
	end
	
	-- Based on our status, check if we have an early out case.
	if status == HDIS_CANCELLED then
		hud_diversion_remove(index)
		return
	
	elseif status >= HDIS_COMPLETE then
		-- Handles HDIS_COMPLETE and HDIS_COMPLETE_DO_NOT_SHOW_HUD cases.
		hud_diversion_complete(index, status == HDIS_COMPLETE_DO_NOT_SHOW_HUD)
		return
	end
	
	local meter_fill = Vdo_base_object:new("meter_fill", grp.handle)
	local div_value = Vdo_base_object:new("div_value", grp.handle)	
	local div_fleur = Vdo_base_object:new("div_fleur", grp.handle)	
	local div_meter_bg = Vdo_base_object:new("meter_bg", grp.handle)
	local div_multi = Vdo_base_object:new("div_multi", grp.handle)
	
	-- Get the floored current value, used in several meters.
	local cur_value_floor = 0
	if cur_value ~= nil then
		cur_value_floor = floor(cur_value)
	end
	
	-- Set the current value for the meter.
	if meter_type == HDM_NONE then
		grp:set_visible(false)
		return
		
	elseif meter_type == HDM_DISTANCE then
		if type(message_two) == "number" and message_two ~= 0 then
			local insert = { [0] = message_two, [1] = format_distance(cur_value) }
			local body = vint_insert_values_in_string("DIVERSION_TEXT_PROGRESS", insert)

			div_value:set_text(body)
		else
			div_value:set_text(format_distance(cur_value))
		end
	elseif meter_type == HDM_XY then
		if type(message_two) == "number" and message_two ~= 0 then
			local insert = { [0] = message_two, [1] = cur_value_floor.."/"..max_value }
			local body = vint_insert_values_in_string("DIVERSION_TEXT_PROGRESS", insert)

			div_value:set_text(body)
		else
			div_value:set_text(cur_value_floor.."/"..max_value)
		end
	elseif meter_type == HDM_COUNTER then
		if type(message_two) == "number" and message_two ~= 0 then
			local insert = { [0] = message_two, [1] = cur_value_floor }
			local body = vint_insert_values_in_string("DIVERSION_TEXT_PROGRESS", insert)

			div_value:set_text(body)
		else
			div_value:set_text(cur_value_floor)
		end
	elseif meter_type == HDM_TIME then
		-- Time is in milliseconds
		-- format_clock accepts time in seconds
		if type(message_two) == "number" and message_two ~= 0 then
			local insert = { [0] = message_two, [1] = format_time(cur_value_floor / 1000, false, true) }
			local body = vint_insert_values_in_string("DIVERSION_TEXT_PROGRESS", insert)

			div_value:set_text(body)
		else
			div_value:set_text(format_time(cur_value_floor / 1000, false, true))
		end
		
	elseif meter_type == HDM_PERCENT then
		-- always 0 - 100
		if type(message_two) == "number" and message_two ~= 0 then
			local insert = { [0] = message_two, [1] = cur_value_floor.."%%" }
			local body = vint_insert_values_in_string("DIVERSION_TEXT_PROGRESS", insert)

			div_value:set_text(body)
		else
			div_value:set_text(cur_value_floor.."%%")
		end
		
	elseif meter_type == HDM_TEXT then
		-- This gets a string
		-- Hide everything except the fire and the fleur
		div_fleur:set_visible(true)
		meter_fill:set_visible(false)
		div_meter_bg:set_visible(false)		
		div_multi:set_visible(false)
		
		hud_diversion_start_fire(index)	
		
		div_value:set_property("force_case", "upper")
		
		if type(message_two) == "number" and message_two ~= 0 then
			div_value:set_text(message_two, true)
		else
			div_value:set_visible(false)
		end
		
		return
	elseif meter_type == HDM_QTE then
		-- always 0 - 100
		if type(message_two) == "number" and message_two ~= 0 then
			local insert = { [0] = message_two, [1] = cur_value_floor.."%%" }
			local body = vint_insert_values_in_string("DIVERSION_TEXT_PROGRESS", insert)

			div_value:set_text(body)
		else
			div_value:set_text(cur_value_floor.."%%")
		end		
	end	
	
	-- Because the descending types are filled in reverse, we must calculate our fill differently.
	local fill = 0
	if descending then
		local diff = min_value - max_value
		if cur_value < min_value and diff > 0 then
			fill = ((min_value - cur_value) * DIVERSION_MAX_STEPS) / diff
		elseif diff == 0 then
			fill = DIVERSION_MAX_STEPS
		end
	else
		local diff = max_value - min_value
		if  cur_value > min_value and diff > 0 then
			fill = ((cur_value - min_value) * DIVERSION_MAX_STEPS) / diff
		elseif diff == 0 then
			fill = DIVERSION_MAX_STEPS
		end
	end
	
	-- Overwrite diversion steps for HUD_QTE type
	if meter_type == HDM_QTE then
		local diff = max_value - min_value
		if  cur_value > min_value and diff > 0 then
			fill = (cur_value - min_value) / diff
		end
	end
	
	-- Set our current diversion level and meter fill percent, based on the overall fill level.
	local div_level = floor(fill)
	
	-- If we are at max, we need to hardcode the meter fill to full.
	local meter_fill_pct = 0
	if div_level >= DIVERSION_MAX_STEPS then
		meter_fill_pct = 6.30 -- = 2PI (6.28) + fudge to make sure the bar is full with no gaps.
	else
		-- Otherwise the fill percent is the decimal of the fill
		meter_fill_pct = (fill - div_level) * 6.28	
	end
	
	-- If the level changed, and we aren't at the default level, setup the fire/text
	local play_anim_multi = false
	if div_level ~= Hud_diversions[index].div_level then
		-- Start our fire playing if it isn't already.
		if hud_diversion_is_fire_playing(index) == false and div_level > 0 then
			hud_diversion_start_fire(index)		
		end
		
		-- If we get here, the div_level went down, remove the multiplier text and fire.
		if div_level == 0 then
			div_multi:set_text("")
			hud_diversion_stop_fire(index)
			
			local div_gradient_grp = Vdo_base_object:new("div_gradient_grp", grp.handle)
			div_gradient_grp:set_alpha(0)
		
		elseif div_level == 1 then
			div_multi:set_text("2X")
			play_anim_multi = true
			
			Hud_diversions[index].anim_fire_scale:stop()
			
		elseif div_level == 2 then
			div_multi:set_text("3X")
			play_anim_multi = true
			
			Hud_diversions[index].anim_fire_scale:play(0)
			
			local anim = Hud_diversions[index].anim_fire_scale
			local fire_scale_twn = Vdo_tween_object:new("fire_scale_twn", anim.handle)
			
			-- Force the scale to default, this handles cases where we went from 3 -> 2,
			-- or went from 3 -> 1 -> 2, by forcing the scale to be at initial values.
			fire_scale_twn:set_property("start_value", Hud_diversions[index].fire_scale_x_start, Hud_diversions[index].fire_scale_y_start)
			fire_scale_twn:set_property("end_value", Hud_diversions[index].fire_scale_x_end, Hud_diversions[index].fire_scale_y_end)
			
		elseif div_level == 3 then
			div_multi:set_text("MAX")
			play_anim_multi = true
			
			local anim = Hud_diversions[index].anim_fire_scale
			local fire_scale_twn = Vdo_tween_object:new("fire_scale_twn", anim.handle)
			
			local x, y = fire_scale_twn:get_property("end_value")
			
			fire_scale_twn:set_property("start_value", 1, 1)
			fire_scale_twn:set_property("end_value", 2.2, 2.2)
			
			anim:play(0)
			
			play_anim_multi = true
		end
	end
	
	-- Save our current diversion level
	Hud_diversions[index].div_level = div_level
	
	-- If we should play the animation multiplier, do so.
	if play_anim_multi == true then
		Hud_diversions[index].anim_multi:play(0)	
		play_anim_multi = false
	end

	-- Set our fill.
	meter_fill:set_property("end_angle", meter_fill_pct)
end

function hud_diversion_complete(index, hide_completion_anim)
	
	local div_respect	= Vdo_base_object:new("div_respect", Hud_diversions[index].grp.handle)

	-- Trigger reward and cash
	if Hud_diversions[index].respect > 0 then
		game_award_respect(Hud_diversions[index].respect, Hud_diversions[index].respect_stat, Hud_diversions[index].div_type)
		
		local insert = { [0] = floor(Hud_diversions[index].respect) }
		local body = vint_insert_values_in_string("DIVERSIONS_RESPECT", insert)
		
		div_respect:set_text(body)
	elseif Hud_diversions[index].cash > 0 then
		local insert = { [0] = "$" .. format_cash(floor(Hud_diversions[index].cash)) }
		local body = vint_insert_values_in_string("DIVERSIONS_CASH", insert)	
	
		game_award_cash(Hud_diversions[index].cash, Hud_diversions[index].div_type)			
		div_respect:set_text(body)
	else
		hud_diversion_remove(index)
		return
	end	
	
	local anim_complete = Hud_diversions[index].anim_complete
	local div_end_event = Vdo_tween_object:new("div_end_event", anim_complete.handle)

	-- Since you can't pass parameters through end events have
	-- end event find handle to remove
	div_end_event:set_end_event("hud_diversion_remove_complete")
	
	--set animation start time...
	if Hud_diversion_is_paused or hide_completion_anim then
		-- We are paused so skip the animation. The code will do the callback and completed itself...
		anim_complete:play(-10)
	else
		anim_complete:play(0)
	end
end

function hud_diversion_remove_complete(tween_handle)
	
	local anim = vint_object_parent(tween_handle)
				
	for idx, val in pairs(Hud_diversions) do
		if anim == val.anim_complete.handle then				
			hud_diversion_remove(idx)				
			break
		end
	end
end

function hud_diversion_find_fire_handle(tween_handle)
	local anim = vint_object_parent(tween_handle)
		
	for idx, val in pairs(Hud_diversions) do
		if anim == val.anim_fire.handle then
			return idx
		end
	end	
end

function hud_diversion_remove(index)
	--Destroy objects, animation and values
	if Hud_diversions[index] ~= nil then
		--Destroy group object
		Hud_diversions[index].grp:object_destroy()
		
		--Destory anim objects	
		Hud_diversions[index].anim_in:object_destroy()
		Hud_diversions[index].anim_complete:object_destroy()
		Hud_diversions[index].anim_shift_up:object_destroy()
		Hud_diversions[index].anim_multi:object_destroy()
		Hud_diversions[index].anim_fire:object_destroy()
		Hud_diversions[index].anim_fire_scale:object_destroy()
		
		-- Callback we are done
		hud_diversion_remove_callback(Hud_diversions[index].message_type)
		
		--Destroy stored values
		hud_diversion_remove_slot(index)	
		Hud_diversions[index] = nil	
	end
end

function hud_diversion_cleanup()

end

function hud_diversion_add_slot(index)
	
	for i = 0, Num_divs do
	
		if Div_slots[i] == nil then
			Div_slots[i] = index
		end
	
	end	
	
	Num_divs = Num_divs + 1		

end

function hud_diversion_remove_slot(index)
	
	for i = 0, Num_divs do
	
		if Div_slots[i] == index then
			Div_slots[i] = nil
		end
	
	end	
	
	-- step through slot array and shift everything up
	-- check if any anchor twns are running first	
	local shift_up = false
	for i = 0, Num_divs  do
	
		if Div_slots[i] == nil and Div_slots[i+1] ~= nil then			
			shift_up = true
		end	
		
		if shift_up == true then
			Div_slots[i] = Div_slots[i+1]
		end
		
		if Div_slots[i] ~= nil then
			hud_diversion_shift_up(i)
		end
	
	end	
	
	Num_divs = Num_divs - 1	
	
end

function hud_diversion_shift_up(slot)

	local index = Div_slots[slot]
	local grp = Hud_diversions[index].grp
	local shift_up_grp  = Vdo_base_object:new("div_shift_up_grp",grp.handle)
	local anim_shift_up = Hud_diversions[index].anim_shift_up
	
	local div_shift_up_twn = Vdo_tween_object:new("div_shift_up_twn", anim_shift_up.handle)

	--local start_value_x, start_value_y = div_shift_up_twn:get_start_value()
	local shift_up_grp_x, shift_up_grp_y = shift_up_grp:get_anchor()
	div_shift_up_twn:set_property("start_value", shift_up_grp_x, shift_up_grp_y)
	div_shift_up_twn:set_property("end_value", shift_up_grp_x, slot * DIVERSION_ANCHOR_OFFSET)	
	
	anim_shift_up:play(0)
	
end

function hud_diversion_start_fire(index)

	local anim = Hud_diversions[index].anim_fire
	local end_event_twn = Vdo_tween_object:new("div_fire_end_event", anim.handle)
	end_event_twn:set_property("per_frame_event", "hud_diversion_loop_fire")
	anim:play(0)
	
end

function hud_diversion_loop_fire(tween_handle)

	local index = hud_diversion_find_fire_handle(tween_handle)
	local grp = Hud_diversions[index].grp
	
	local fire = Vdo_base_object:new("fire", grp.handle)
	local fire_count = Hud_diversions[index].fire_count
	
	fire:set_visible(true)
	
	-- change fire image when end event is triggered
	fire_count = fire_count + 1
	
	if fire_count > DIVERSIONS_MAX_FIRE then 
		fire_count = 0
	end
		
	fire:set_image("ui_hud_diversion_fire"..fire_count)
	
	Hud_diversions[index].fire_count = fire_count
	
end

function hud_diversion_is_fire_playing(index)

	return (Hud_diversions[index].anim_fire:get_property("is_paused") == false)
	
end

function hud_diversion_stop_fire(index)

	local grp = Hud_diversions[index].grp
	local fire = Vdo_base_object:new("fire", grp.handle)
	
	fire:set_visible(false)
	
	Hud_diversions[index].anim_fire_scale:stop()
	Hud_diversions[index].anim_fire:stop()
	
end


-------------------------------------------------------------------------------
-- Challenges fucntions
-------------------------------------------------------------------------------

function hud_diversion_chal_data_item_update(di_h)
	--[[
		Hud Challenge dataitem members:
		VINT_PROP_TYPE_UINT           - Message crc to display in the meter (title)
		VINT_PROP_TYPE_FLOAT          - Current progress for the challenge
		VINT_PROP_TYPE_FLOAT          - Goal for the challenge
		VINT_PROP_TYPE_UINT           - crc value for the units, if any
		VINT_PROP_TYPE_FLOAT          - The cash to reward the player with, if any
		VINT_PROP_TYPE_INT            - The respect to reward the player with, if any
		VINT_PROP_TYPE_BOOL           - If the respect/cash should be saved for mission restarts, passed back to code on reward.
		VINT_PROP_TYPE_BOOL           - If this is an achievement updated
		VINT_PROP_TYPE_BITMAP         - The image, if one exists.
		VINT_PROP_TYPE_INT            - The message type, passed back to code as a callback so it knows the hud is clear
	]]

	local title, cur_val, max_val, val_units, cash_reward, respect_reward, save_in_mission, is_achievement, image, message_type = vint_dataitem_get(di_h)
	hud_diversion_chal_update(title, cur_val, max_val, val_units, cash_reward, respect_reward, save_in_mission, is_achievement, image, message_type)
end

function hud_diversion_chal_update(title, cur_val, max_val, val_units, cash_reward, respect_reward, save_in_mission, is_achievement, image, message_type)
	--No data... Abort Challenge screen.
	if title == 0 or title == nil then
		return
	end
	
	--Queue up any data into memory...
	Hud_challenge_data = {
		title = title,
		cur_val = cur_val, 
		max_val = max_val, 
		val_units = val_units, 
		cash_reward = cash_reward, 
		respect_reward = respect_reward,
		is_achievement = is_achievement, 
		image = image, 
		message_type = message_type,
		save_in_mission = save_in_mission,
	}

	if is_achievement == true then
		game_peg_load_with_cb("hud_diversion_chal_show", 1, image)
	else
		hud_diversion_chal_show()
	end
end

function hud_diversion_chal_show() 
	local chal_grp = Vdo_base_object:new("chal_grp")
	local chal_bg = Vdo_base_object:new("chal_bg")
	local chal_title = Vdo_base_object:new("chal_title")
	local chal_xy = Vdo_base_object:new("chal_xy")
	local chal_image = Vdo_base_object:new("chal_image")
	local chal_meter_fill = Vdo_base_object:new("chal_meter_fill")
	local chal_anim = Vdo_anim_object:new("chal_anim_in")
	local end_event = Vdo_tween_object:new("chal_end_event_twn", chal_anim.handle)
	
	chal_title:set_text(Hud_challenge_data.title, true)	
	
	-- Handle units
	if Hud_challenge_data.cur_val < 0 then
		chal_xy:set_visible(false)
	else
		chal_xy:set_visible(true)
		if Hud_challenge_data.val_units ~= 0 then
			local insert = { 	[0] = format_cash(floor(Hud_challenge_data.cur_val)),
									[1] = format_cash(floor(Hud_challenge_data.max_val)), [2] = Hud_challenge_data.val_units }
			local body = vint_insert_values_in_string("DIVERSION_CHALLENGES_UNITS", insert)

			chal_xy:set_text(body)
		else
			chal_xy:set_text(floor(Hud_challenge_data.cur_val).."/"..floor(Hud_challenge_data.max_val))
		end	
	end
		
	if Hud_challenge_data.is_achievement == true then
		chal_image:set_image(Hud_challenge_data.image) 		
		chal_image:set_visible(true)
		--chal_title:set_anchor(CHAL_TITLE_X, CHAL_TITLE_Y)
		--chal_title:set_property("wrap_width", 265)
	else
		-- Hide image and move text over to compensate
		chal_image:set_visible(false)
		--chal_title:set_anchor(CHAL_TITLE_NO_IMAGE_X, CHAL_TITLE_Y)		
	end
	
	chal_title:set_property("wrap_width", 390 * 3)
	chal_title:set_property("word_wrap", true)

	local chal_bg_width, chal_bg_height = chal_bg:get_actual_size()
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