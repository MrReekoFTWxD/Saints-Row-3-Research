-------------------------------------------------------------------------------
-- This deals with the notoriety icons around the minimap.
---------------------------------------------------------------------------------

--Notoriety States
local NOTO_STATE_INITIALIZE	= -1
local NOTO_STATE_HIDDEN 		= 0
local NOTO_STATE_VISIBLE 		= 1
local NOTO_STATE_ADD				= 2
local NOTO_STATE_REMOVE			= 3
local NOTO_STATE_DECAYING		= 4
local NOTO_STATE_INCREASING	= 5

-------------------------------------------------------------------------------
-- Hud notoriety data.
-- 
Hud_noto_data = {
	gangs = {
		cur_team = 0,
		cur_level = -1,
		teams = {
			["brotherhood"]	= 	{icon_image = "ui_hud_not_syndicate",	noto_level = -1},
			["ronin"]	= 			{icon_image = "ui_hud_not_syndicate",	noto_level = -1},
			["samedi"]	= 			{icon_image = "ui_hud_not_syndicate",	noto_level = -1},
		},
		icons = {
			[1] = {state = -1, state_prev = -1, tween_end = 0, anim_0 = 0, anim_1 = 0, anim_2 = 0, anim_3 = 0, bmp_clone_0 = 0, bmp_clone_1 = 0},
			[2] = {state = -1, state_prev = -1, tween_end = 0, anim_0 = 0, anim_1 = 0, anim_2 = 0, anim_3 = 0, bmp_clone_0 = 0, bmp_clone_1 = 0},
			[3] = {state = -1, state_prev = -1, tween_end = 0, anim_0 = 0, anim_1 = 0, anim_2 = 0, anim_3 = 0, bmp_clone_0 = 0, bmp_clone_1 = 0},
			[4] = {state = -1, state_prev = -1, tween_end = 0, anim_0 = 0, anim_1 = 0, anim_2 = 0, anim_3 = 0, bmp_clone_0 = 0, bmp_clone_1 = 0},
			[5] = {state = -1, state_prev = -1, tween_end = 0, anim_0 = 0, anim_1 = 0, anim_2 = 0, anim_3 = 0, bmp_clone_0 = 0, bmp_clone_1 = 0}
		},
	},

	police = {
		cur_team = 0,
		cur_level = -1,
		teams = {
			["police"]	= {icon_image = "ui_hud_not_police", noto_level = -1},
		},
		icons = {
			[1] = {state = -1, state_prev = -1, tween_end = 0, anim_0 = 0, anim_1 = 0, anim_2 = 0, anim_3 = 0, bmp_clone_0 = 0, bmp_clone_1 = 0},
			[2] = {state = -1, state_prev = -1, tween_end = 0, anim_0 = 0, anim_1 = 0, anim_2 = 0, anim_3 = 0, bmp_clone_0 = 0, bmp_clone_1 = 0},
			[3] = {state = -1, state_prev = -1, tween_end = 0, anim_0 = 0, anim_1 = 0, anim_2 = 0, anim_3 = 0, bmp_clone_0 = 0, bmp_clone_1 = 0},
			[4] = {state = -1, state_prev = -1, tween_end = 0, anim_0 = 0, anim_1 = 0, anim_2 = 0, anim_3 = 0, bmp_clone_0 = 0, bmp_clone_1 = 0},
			[5] = {state = -1, state_prev = -1, tween_end = 0, anim_0 = 0, anim_1 = 0, anim_2 = 0, anim_3 = 0, bmp_clone_0 = 0, bmp_clone_1 = 0}
		},
	},
}

-------------------------------------------------------------------------------
-- Initialize and subscribe to data.
-- 
function hud_noto_init()

	--find reference base icons
	for i = 1, 5 do
		local gang_icon_h = vint_object_find("gang_noto_icon_" .. i)
		local police_icon_h = vint_object_find("police_noto_icon_" .. i)
		Hud_noto_data.gangs.icons[i].icon_h = gang_icon_h
		Hud_noto_data.police.icons[i].icon_h = police_icon_h
	end

	--decay tweens must play at the same time. so we start the animation but disable the tweens and enable them as we go.
	local decaying_anim_h = vint_object_find("noto_decaying_anim")
	local noto_decaying_twn_h = vint_object_find("noto_decaying_twn", decaying_anim_h)
	vint_set_property(noto_decaying_twn_h, "state", VINT_TWEEN_STATE_DISABLED)
	lua_play_anim(decaying_anim_h)
	
	--Notoriety
	vint_datagroup_add_subscription("sr2_notoriety", "update", "hud_noto_change")
	vint_datagroup_add_subscription("sr2_notoriety", "insert", "hud_noto_change")
end

-------------------------------------------------------------------------------
-- Datagroup callback
-- 
function hud_noto_change(data_item_h, event_name)
	local team_name, noto_level, noto_icon = vint_dataitem_get(data_item_h)
	local noto_data, display_data, icon_data, meter_data, team_data

	-- find the interesting data for team
	for key, noto_type in pairs(Hud_noto_data) do
		if noto_type.teams[team_name] ~= nil then
			noto_data = noto_type
			display_data = noto_type.teams[team_name]
			icon_data = noto_type.icons
			break
		end
	end

	if noto_data == nil then
		-- not an interesting team so outta here
		return
	end

	-- update the notoriety table
	display_data.noto_level = noto_level

	-- find the team in this group with highest notoriety
	noto_level = -1
	team_name = nil
	for key, value in pairs(noto_data.teams) do
		if value.noto_level > noto_level then
			team_name = key
			noto_level = value.noto_level
			team_data = value
		end
	end

	-- better safe then sorry
	if team_name == nil then
		return
	end

	local base_new_noto = floor(noto_level)
	local base_old_noto = floor(noto_data.cur_level)
	local icon_h = 0

	-- new team, animate in all icons
	if team_name ~= noto_data.cur_team then
		--update current image
		for i = 1, 5 do
			--Set image of icon...
			vint_set_property(noto_data.icons[i], "image", team_data.icon_image)
		
			--set the proper state for the icon...
			if base_new_noto >= i then
				hud_noto_icon_set_state(noto_data.icons[i], NOTO_STATE_ADD)
			else
				hud_noto_icon_set_state(noto_data.icons[i], NOTO_STATE_REMOVE)
			end
		end

		noto_data.cur_team = team_name
		
		--Make sure we are visible...
		hud_player_notoriety_show()

	-- noto on the rise, animate in all new icons
	elseif base_new_noto > base_old_noto then
		for i = 1, 5 do
			icon_h = noto_data.icons[i].icon_h
			if base_new_noto >= i and base_old_noto < i then
				hud_noto_icon_set_state(noto_data.icons[i], NOTO_STATE_ADD)
			elseif base_new_noto < i then
				hud_noto_icon_set_state(noto_data.icons[i], NOTO_STATE_REMOVE)
			else
				hud_noto_icon_set_state(noto_data.icons[i], NOTO_STATE_VISIBLE)
			end
		end
		
		--Make sure we are visible...
		hud_player_notoriety_show()

	-- noto falling, animate the highest active icon
	elseif base_new_noto < base_old_noto then
		for i = 1, 5 do
			if base_new_noto == i then
				hud_noto_icon_set_state(noto_data.icons[i], NOTO_STATE_ADD)
			elseif base_new_noto < i then
				hud_noto_icon_set_state(noto_data.icons[i], NOTO_STATE_REMOVE)
			end
		end
	end

	-- update meter
	local part_new_noto = noto_level - base_new_noto
	

	--determine if we are still, decaying or increasing
	local noto_diff = noto_level - noto_data.cur_level
	if base_new_noto == base_old_noto then

		if noto_diff < -0.001 then
			--decaying...
			for i = 1, 5 do
				icon_h = noto_data.icons[i].icon_h
				if base_new_noto == i then
					hud_noto_icon_set_state(noto_data.icons[i], NOTO_STATE_DECAYING)
				end
			end
		elseif noto_diff > 0.001 then
			--Increase...
			for i = 1, 5 do
				icon_h = noto_data.icons[i].icon_h
				if base_new_noto == i then
					hud_noto_icon_set_state(noto_data.icons[i], NOTO_STATE_INCREASING)
				end
			end
		elseif abs(noto_level) > 0.0001 then
			--probably the same level again just make sure we are visible...
			for i = 1, 5 do
				icon_h = noto_data.icons[i].icon_h
				if base_new_noto == i then
					hud_noto_icon_set_state(noto_data.icons[i], NOTO_STATE_VISIBLE)
				end
			end
		end
	end

	--store the current level to the notoriety type(gang or police)
	noto_data.cur_level = noto_level
	
	--Process the states...
	hud_noto_icon_process_state(noto_data)
	
	-- find lowest notoriety value
	local lowest_noto_level = 0
	local x_data = Hud_noto_data
	for key, noto_type in pairs(Hud_noto_data) do
		if noto_type.cur_level ~= -1 then
			if noto_type.cur_level > lowest_noto_level then
				lowest_noto_level = noto_type.cur_level
			end		
		end
	end
	
	--hide notoriety if we are less than 1.
	if lowest_noto_level < 1 then
		hud_player_notoriety_hide()
	end
end

-------------------------------------------------------------------------------
-- Icon set state
--
function hud_noto_icon_set_state(icon, state)
	if state == NOTO_STATE_ADD then
		if icon.state == NOTO_STATE_VISIBLE then
			--Don't try to re-add an icon.
			icon.state = NOTO_STATE_VISIBLE
		else
			icon.state = NOTO_STATE_ADD
		end
	elseif state == NOTO_STATE_REMOVE then
		if icon.state == NOTO_STATE_HIDDEN then
			--Don't try to re-hide an icon
			icon.state = NOTO_STATE_HIDDEN
		else
			icon.state = NOTO_STATE_REMOVE
		end
	elseif state == NOTO_STATE_VISIBLE then
		if icon.state == NOTO_STATE_ADD then
			--If the state is already adding, we just keep it that way instead of trying to force visible.
			icon.state = NOTO_STATE_ADD
		else
			icon.state = NOTO_STATE_VISIBLE
		end
	elseif state == NOTO_STATE_INCREASING then
		if icon.state == NOTO_STATE_ADD then
			--can't change to increasing if we are currently adding.
			icon.state = NOTO_STATE_ADD
		else
			icon.state = NOTO_STATE_INCREASING
		end		
	else
		icon.state = state
	end
end

-------------------------------------------------------------------------------
-- Silenetly resets the state. This happens after our ADD, REMOVE and PULSE
-- callbacks. This way we don't reprocess a hidden state.
--
function hud_noto_icon_set_state_silent(icon, state)
	icon.state = state
	icon.state_prev = state
end

-------------------------------------------------------------------------------
-- Processes the state for the specific noto type.
-- noto_type			(gang or police) Hud_noto_data.gang or Hud_noto_data.police
-- process_icon_id 	if icon# is specified, we will only process that icon.
--
function hud_noto_icon_process_state(noto_type)
	-- Loop through our icons and change state...
	for icon_id = 1, 5 do
		local icon = noto_type.icons[icon_id]
		local icon_h = icon.icon_h
		if icon.state ~= icon.state_prev then
			-- We need to change states now...
			if icon.state == NOTO_STATE_ADD then
				hud_noto_icon_add(icon_h, icon)
			elseif icon.state == NOTO_STATE_DECAYING then
				hud_noto_icon_decay(icon_h, icon)
			elseif icon.state == NOTO_STATE_INCREASING then
				hud_noto_icon_pulse(icon_h, icon)
			elseif icon.state == NOTO_STATE_REMOVE then
				hud_noto_icon_remove(icon_h, icon)
			elseif icon.state == NOTO_STATE_VISIBLE then
				hud_noto_icon_visible(icon_h, icon)	
			elseif icon.state == NOTO_STATE_HIDDEN then
				hud_noto_icon_hide(icon_h, icon)
			end
			icon.state_prev = icon.state
		end
	end
end

-------------------------------------------------------------------------------
-- Hides icons with animation...
-- 
function hud_noto_icon_remove(icon_h, icon)
	vint_object_destroy(icon.bmp_clone_0)
	vint_object_destroy(icon.bmp_clone_1)
	vint_object_destroy(icon.anim_0)
	vint_object_destroy(icon.anim_1)
	vint_object_destroy(icon.anim_2)
	vint_object_destroy(icon.anim_3)

	--ANIMATE: Fade Icon Away
	local anim_3 = vint_object_find("noto_fade_out_anim")
	local anim_clone_3 = vint_object_clone(anim_3)

	--Targets
	local anim_3_alpha_tween = vint_object_find("noto_alpha_3", anim_clone_3)
	vint_set_property(anim_3_alpha_tween, "target_handle",	icon_h)

	--Reset Tween value
	local alpha_val = vint_get_property(icon_h, "alpha")
	vint_set_property_typed("float", anim_3_alpha_tween, "start_value", alpha_val)

	--Callback
	vint_set_property(anim_3_alpha_tween, "end_event",		"hud_noto_icon_hide_end")

	lua_play_anim(anim_clone_3, 0);

	icon.bmp_clone_0 = 0
	icon.bmp_clone_1 = 0
	icon.anim_0 = 0
	icon.anim_1 = 0
	icon.anim_2 = 0
	icon.anim_3 = anim_clone_3
	icon.tween_end = anim_3_alpha_tween
end

function hud_noto_icon_hide_end(tween_h, event_name)
	-- search for indicated tween and clean up
	for k, noto_data in pairs(Hud_noto_data) do
		for key, icon in pairs(noto_data.icons) do
			if icon.tween_alpha_out == tween_h then
				vint_object_destroy(icon.bmp_clone_0)
				vint_object_destroy(icon.bmp_clone_1)
				vint_object_destroy(icon.anim_0)
				vint_object_destroy(icon.anim_1)
				vint_object_destroy(icon.anim_2)
				vint_object_destroy(icon.anim_3)
				icon.bmp_clone_0 = 0
				icon.bmp_clone_1 = 0
				icon.anim_0 = 0
				icon.anim_1 = 0
				icon.anim_2 = 0
				icon.anim_3 = 0
				icon.tween_show = 0
				
				hud_noto_icon_set_state_silent(icon, NOTO_STATE_HIDDEN)
				return
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Shows icons with animation...
-- 
function hud_noto_icon_add(icon_h, icon)
	vint_set_property(icon_h, "visible", true)

	--Destroy all objects if there are any currently being animated
	vint_object_destroy(icon.bmp_clone_0)
	vint_object_destroy(icon.bmp_clone_1)
	vint_object_destroy(icon.anim_0)
	vint_object_destroy(icon.anim_1)
	vint_object_destroy(icon.anim_2)
	vint_object_destroy(icon.anim_3)

	--Create bitmap clones for animation
	local bmp_clone_0 = vint_object_clone(icon_h)
	local bmp_clone_1 = vint_object_clone(icon_h)
	vint_set_property(bmp_clone_0, "depth",	-1)
	vint_set_property(bmp_clone_1, "depth",	-2)

	--Clone the notoriety anim and adjust the childs targets

	--ANIMATION: Large to small
	local anim_0 = vint_object_find("noto_add_down_anim")
	local anim_clone_0 = vint_object_clone(anim_0)

	--Target Tweens
	local anim_0_alpha_tween = vint_object_find("noto_alpha_0", anim_clone_0)
	local anim_0_scale_tween = vint_object_find("noto_scale_0", anim_clone_0)
	vint_set_property(anim_0_alpha_tween, "target_handle",	bmp_clone_0)
	vint_set_property(anim_0_scale_tween, "target_handle",	bmp_clone_0)
	
	--ANIMATION: Small To Large
	local anim_1 = vint_object_find("noto_add_up_anim");
	local anim_clone_1 = vint_object_clone(anim_1)

	--Target Tweens
	local anim_1_alpha_tween = vint_object_find("noto_alpha_1", anim_clone_1)
	local anim_1_scale_tween = vint_object_find("noto_scale_1", anim_clone_1)
	vint_set_property(anim_1_alpha_tween, "target_handle",	bmp_clone_1)
	vint_set_property(anim_1_scale_tween, "target_handle",	bmp_clone_1)
	
	--ANIMATION: BASIC FADE IN
	local anim_2 = vint_object_find("noto_fade_in_anim")
	local anim_clone_2 = vint_object_clone(anim_2)
	
	--Target Tweens
	local anim_2_alpha_tween = vint_object_find("noto_alpha_2", anim_clone_2)
	vint_set_property(anim_2_alpha_tween, "target_handle",	icon_h)
	
	--Reset Properties to current value
	local alpha_val = vint_get_property(icon_h, "alpha")
	vint_set_property_typed("float", anim_2_alpha_tween, "start_value", alpha_val)

	--Setup callback
	vint_set_property(anim_0_scale_tween, "end_event",		"hud_noto_icon_add_end")
	
	--play anims
	lua_play_anim(anim_clone_0, 0);
	lua_play_anim(anim_clone_1, 0);
	lua_play_anim(anim_clone_2, 0);

	icon.bmp_clone_0 = bmp_clone_0
	icon.bmp_clone_1 = bmp_clone_1
	icon.anim_0 = anim_clone_0
	icon.anim_1 = anim_clone_1
	icon.anim_2 = anim_clone_2
	icon.anim_3 = 0
	icon.tween_end = anim_0_scale_tween
end

function hud_noto_icon_add_end(tween_h, event_name)
	-- search for indicated tween and clean up
	for k, noto_data in pairs(Hud_noto_data) do
		for key, icon in pairs(noto_data.icons) do
			if icon.tween_end == tween_h then

				vint_object_destroy(icon.bmp_clone_0)
				vint_object_destroy(icon.bmp_clone_1)
				vint_object_destroy(icon.anim_0)
				vint_object_destroy(icon.anim_1)
				vint_object_destroy(icon.anim_2)

				icon.bmp_clone_0 = 0
				icon.bmp_clone_1 = 0
				icon.anim_0 = 0
				icon.anim_1 = 0
				icon.anim_2 = 0
				icon.tween_show = 0
				
				hud_noto_icon_set_state_silent(icon, NOTO_STATE_VISIBLE)
				return
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Starts decaying looping animation on specific icon.
--
function hud_noto_icon_decay(icon_h, icon)

	--make sure we aren't already playing an animation...
	vint_object_destroy(icon.bmp_clone_0)
	vint_object_destroy(icon.bmp_clone_1)
	vint_object_destroy(icon.anim_0)
	vint_object_destroy(icon.anim_1)
	vint_object_destroy(icon.anim_2)
	vint_object_destroy(icon.anim_3)

	vint_set_property(icon_h, "visible", true)

	--This one is a little bit different because we want the tweens to stay in sync... so we just clone the tween.
	--Animation is already playing, cloning the tweens will keep them in sync.
	local decaying_anim_h = vint_object_find("noto_decaying_anim")
	local decay_twn_h = vint_object_find("noto_decaying_twn", decaying_anim_h)
	local decay_clone_twn_h = vint_object_clone(decay_twn_h)
	vint_set_property(decay_clone_twn_h, "state", VINT_TWEEN_STATE_RUNNING)
	vint_set_property(decay_clone_twn_h, "target_handle",	icon_h)
	
	--Store options to globals...
	icon.bmp_clone_0 = 0
	icon.bmp_clone_1 = 0
	icon.anim_0 = decay_clone_twn_h
	icon.anim_1 = 0
	icon.anim_2 = 0
	icon.anim_3 = 0
	icon.tween_end = 0
end

-------------------------------------------------------------------------------
-- Pleys pulse up animation on icon
--
function hud_noto_icon_pulse(icon_h, icon)

	--make sure we aren't already playing an animation, nuke it...
	vint_object_destroy(icon.bmp_clone_0)
	vint_object_destroy(icon.bmp_clone_1)
	vint_object_destroy(icon.anim_0)
	vint_object_destroy(icon.anim_1)
	vint_object_destroy(icon.anim_2)
	vint_object_destroy(icon.anim_3)
	
	--make sure our notoriety icon is visible.
	vint_set_property(icon_h, "visible", true)
	vint_set_property(icon_h, "alpha", 1)

	--Create bitmap clones for animation
	local bmp_clone_0 = vint_object_clone(icon_h)
	vint_set_property(bmp_clone_0, "depth",	-1)

	--Clone the notoriety anim and adjust the childs targets

	--ANIMATION: Small To Large
	local anim_0 = vint_object_find("noto_add_up_anim");
	local anim_clone_0 = vint_object_clone(anim_0)

	--Target Tweens
	local anim_0_alpha_tween = vint_object_find("noto_alpha_1", anim_clone_0)
	local anim_0_scale_tween = vint_object_find("noto_scale_1", anim_clone_0)
	vint_set_property(anim_0_alpha_tween, "target_handle",	bmp_clone_0)
	vint_set_property(anim_0_scale_tween, "target_handle",	bmp_clone_0)

	--Setup callback
	vint_set_property(anim_0_scale_tween, "end_event",		"hud_noto_icon_pulse_end")
	
	--play anims
	lua_play_anim(anim_clone_0, 0);

	icon.bmp_clone_0 = bmp_clone_0
	icon.anim_0 = anim_clone_0
	icon.tween_end = anim_0_scale_tween
end

function hud_noto_icon_pulse_end(tween_h, event)
	-- search for indicated tween and clean up
	for k, noto_data in pairs(Hud_noto_data) do
		for key, icon in pairs(noto_data.icons) do
			if icon.tween_end == tween_h then
				vint_object_destroy(icon.bmp_clone_0)
				vint_object_destroy(icon.bmp_clone_1)
				vint_object_destroy(icon.anim_0)
				vint_object_destroy(icon.anim_1)
				vint_object_destroy(icon.anim_2)

				icon.bmp_clone_0 = 0
				icon.bmp_clone_1 = 0
				icon.anim_0 = 0
				icon.anim_1 = 0
				icon.anim_2 = 0
				icon.tween_show = 0
				
				hud_noto_icon_set_state_silent(icon, NOTO_STATE_VISIBLE)
				return
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Force show icon...
--
function hud_noto_icon_visible(icon_h, icon)
	--make sure we aren't already playing an animation...
	vint_object_destroy(icon.bmp_clone_0)
	vint_object_destroy(icon.bmp_clone_1)
	vint_object_destroy(icon.anim_0)
	vint_object_destroy(icon.anim_1)
	vint_object_destroy(icon.anim_2)
	vint_object_destroy(icon.anim_3)

	vint_set_property(icon_h, "visible", true)
	vint_set_property(icon_h, "alpha", 1)
end

-------------------------------------------------------------------------------
-- Force hide icon.
--
function hud_noto_icon_hide(icon_h, icon)
	--make sure we aren't already playing an animation...
	vint_object_destroy(icon.bmp_clone_0)
	vint_object_destroy(icon.bmp_clone_1)
	vint_object_destroy(icon.anim_0)
	vint_object_destroy(icon.anim_1)
	vint_object_destroy(icon.anim_2)
	vint_object_destroy(icon.anim_3)

	vint_set_property(icon_h, "visible", false)
	vint_set_property(icon_h, "alpha", 0)
end



-------------------------------------------------------------------------------
-- Expand notoriety bars...
-- 
function hud_player_notoriety_show()
	if Hud_notoriety.is_expanded ~= true then
		vint_set_property(vint_object_find("map_noteriety_contract"), "is_paused", true)
		lua_play_anim(vint_object_find("map_noteriety_expand"))
		Hud_notoriety.is_expanded = true
	end
end


-------------------------------------------------------------------------------
-- Retract notoriety bars...
-- 
function hud_player_notoriety_hide()
	if Hud_notoriety.is_expanded ~= false then
		vint_set_property(vint_object_find("map_noteriety_expand"), "is_paused", true)
		lua_play_anim(vint_object_find("map_noteriety_contract"))
		Hud_notoriety.is_expanded = false
	end
end