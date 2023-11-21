local	HUD_COLLECTION_FLASHPOINT		= 0
local	HUD_COLLECTION_COLLECTIBLE_GENERIC      = 1
local	HUD_COLLECTION_COLLECTIBLE_PHOTO_OP	= 2
local	HUD_COLLECTION_HITMAN			= 3
local	HUD_COLLECTION_CHOP_SHOP		= 4
local	HUD_COLLECTION_STUNT_JUMP		= 5
local	HUD_COLLECTION_BARNSTORMING		= 6
local	HUD_COLLECTION_SURVIVAL			= 7
local	HUD_COLLECTION_SECRET			= 8
local	HUD_COLLECTION_STAG			= 9

local	STATS_INVALID = -1

local	DT_NONE				= -1
local	DT_CHOP_SHOP		= 2
local	DT_BARNSTORMING	= 4
local DT_EXPLORATION		= 5
local	DT_FLASHPOINT		= 6
local	DT_HITMAN			= 7
local	DT_SURVIVAL			= 12

local Hud_collection_types = {
	[HUD_COLLECTION_FLASHPOINT] =		{
		audio = "ui_hud_gang_flash_complete",
		d_type = DT_FLASHPOINT,
	},
	[HUD_COLLECTION_COLLECTIBLE_GENERIC] =	{
		audio = "ui_hud_generic_div_complete",
		d_type = DT_NONE,
	},
	[HUD_COLLECTION_COLLECTIBLE_PHOTO_OP] =	{
		audio = "ui_hud_photo_op_complete",
		d_type = DT_NONE,
	},
	[HUD_COLLECTION_HITMAN] =		{
		audio = "ui_hud_hitman_complete",
		d_type = DT_HITMAN,
	},
	[HUD_COLLECTION_CHOP_SHOP] =		{
		audio = "ui_hud_chop_shop_complete",
		d_type = DT_CHOP_SHOP,
	},
	[HUD_COLLECTION_STUNT_JUMP] =		{
		d_type = DT_NONE,
	},
	[HUD_COLLECTION_BARNSTORMING] =		{
		d_type = DT_BARNSTORMING,
	},
	[HUD_COLLECTION_SURVIVAL] =		{
		audio = "ui_hud_survival_complete",
		d_type = DT_SURVIVAL,
	},
	[HUD_COLLECTION_SECRET] =		{
		d_type = DT_EXPLORATION,
	},
	[HUD_COLLECTION_STAG] =		{
		audio = "ui_hud_generic_div_complete",
		d_type = DT_NONE,
	}
}

local Hud_collection_anims = {}
local Hud_collection_data = {}
local Hud_collection_initialized = false
local Hud_collection_is_active = false
local Current_collection_index = 0
local Num_collection_data = 0
local Queued_collection_data = { }

local Hud_collection_control_meter 				= 0		--Control meter object...
local Hud_collection_respect_meter 				= 0		--Respect meter object...
local Hud_collection_cash_h 					 	= 0		--Cash Display...

local HUD_COLLECTION_ICON_WIDTH 			= 64 * 3
local HUD_COLLECTION_CONTROL_WIDTH		= 84 * 3
local HUD_COLLECTION_RESPECT_WIDTH 		= 84 * 3
local HUD_COLLECTION_MAX_WIDTH 			= 818 * 3
local HUD_COLLECTION_HEADER_MAX_WIDTH 	= 495 * 3

-------------------------------------------------------------------------------
-- This is included with hud.vint_doc
-------------------------------------------------------------------------------
function hud_collection_init()
	vint_dataitem_add_subscription("collection_hud_element", "update", "hud_collection_update")
	vint_dataitem_add_subscription("game_paused_item", "update", "hud_collection_game_is_paused")	--to check if game is paused...
	
	local h = vint_object_find("collection_grp")
	vint_set_property(h, "visible", false)
	
	--Animations stored to globals
	Hud_collection_anims.in_anim_h 			= vint_object_find("collection_in_anim")
	Hud_collection_anims.district_anim_h		= vint_object_find("collection_district_anim")
	Hud_collection_anims.respect_anim_h 		= vint_object_find("collection_respect_anim")
	Hud_collection_anims.cash_anim_h 		= vint_object_find("collection_cash_anim")
	Hud_collection_anims.complete_anim_h		= vint_object_find("collection_complete_anim")
	
	-- Setup callbacks to tweens....
	local control_twn_h = vint_object_find("collection_control_twn")
	local respect_twn_h = vint_object_find("collection_respect_twn")
	local cash_twn_h = vint_object_find("collection_cash_twn")
	local collection_fade_out_twn_h = vint_object_find("collection_fade_out_twn")
	
	vint_set_property(control_twn_h, "end_event", "hud_collection_start_control")
	vint_set_property(respect_twn_h, "start_event", "hud_collection_show_respect")
	vint_set_property(respect_twn_h, "end_event", "hud_collection_start_respect")
	vint_set_property(cash_twn_h, "start_event", "hud_collection_start_cash")
	vint_set_property(collection_fade_out_twn_h, "start_event", "hud_collection_audio_out")		--audio play out...
	vint_set_property(collection_fade_out_twn_h, "end_event", "hud_collection_finished")

	--Initialize control meter.
	Hud_collection_control_meter = Vdo_city_control:new("collection_control_meter")
	
	--Initialize respect meter.
	Hud_collection_respect_meter = Vdo_city_control:new("collection_respect_meter")
	Hud_collection_respect_meter:change_to_respect()

	Hud_collection_cash_h = vint_object_find("collection_cash_txt")
	
	local collection_hud_bg_tile_h = vint_object_find("collection_hud_bg_tile")
	local collection_hud_bg_tile_twn = vint_object_find("collection_hud_bg_tile_twn")
	vint_set_property(collection_hud_bg_tile_twn, "duration", 30)
	vint_set_property(collection_hud_bg_tile_twn, "loop_mode", "cycle")
end

-------------------------------------------------------------
-- Fills in the data object for populating the screen...
-------------------------------------------------------------
--		VINT_PROP_TYPE_INT,           // Collection type
--		VINT_PROP_TYPE_UINT,          //    Title of the Collection message ("Gang Operation", "Hitman", "Chopshop") 
--		VINT_PROP_TYPE_UINT,          //    Subtitle (Destroyed, Completed, Found)
--		VINT_PROP_TYPE_INT,           //    How many items the player has left in district or game
--		VINT_PROP_TYPE_INT,           // Total items in district or game
--		
--		// if the following are nil then we omit their display...
--		VINT_PROP_TYPE_FLOAT,         //    Cash Reward
--		VINT_PROP_TYPE_INT,           // Respect Reward 
--		VINT_PROP_TYPE_FLOAT,  		 	//    District percentage before...
--		VINT_PROP_TYPE_FLOAT,   		// District percentage after...
--		VINT_PROP_TYPE_STRING,  		// DISTRICT name
--		VINT_PROP_TYPE_BOOL,				// Whether the rewards should be saved on mission failure/restart
--		VINT_PROP_TYPE_BOOL,				// whether to award cash / respect

function hud_collection_update(di_h)
	local collection_type, title, sub_title, items_left, items_total, cash_reward, respect_reward, district_pct_old, district_pct_new, district_name, save_in_mission, no_reward = vint_dataitem_get(di_h)
	
	if Hud_collection_initialized == false then
		--This gets called on subscription but we have nothing to process at boot... so we exit.
		Hud_collection_initialized = true
		return
	end

	--determine what kind of collection type we are and do some shit based on that...
	local collection_type = collection_type

	if title == 0 then
		--No data... Abort Collection screen.
		return
	end
	local gained_pct = district_pct_new - district_pct_old	
	
	--Queue up any data into memory...
	Queued_collection_data[Num_collection_data] = {
		collection_type = collection_type,
		title = title, 
		sub_title = sub_title, 
		items_left = items_left, 
		items_total = items_total, 
		cash_reward = cash_reward, 
		respect_reward = respect_reward, 
		district_pct_old = district_pct_old, 
		district_pct_new = district_pct_new, 
		district_name = district_name,
		save_in_mission = save_in_mission,
		no_reward = no_reward,
	}

	Num_collection_data = Num_collection_data + 1
	if Num_collection_data == 1 then
		hud_collection_start()
	end
end


function hud_collection_start()
	Hud_collection_is_active = true
	Hud_collection_data = Queued_collection_data[Current_collection_index]
	Current_collection_index = Current_collection_index + 1
	
	--Determine what rewards to display...
	Hud_collection_data.has_district 	= true
	Hud_collection_data.has_respect	 	= true
	Hud_collection_data.has_cash			= true
	
	if Hud_collection_data.district_pct_old == Hud_collection_data.district_pct_new then
		--No district
		Hud_collection_data.has_district = false
	end
	
	if Hud_collection_data.respect_reward == 0 then
		--No cash reward...
		Hud_collection_data.has_respect = false
	end
	
	if Hud_collection_data.cash_reward == 0 then
		--No cash reward...
		Hud_collection_data.shas_cash = false
	end
	
	--All reward elements start out hidden...
	Hud_collection_control_meter:set_alpha(0)
	Hud_collection_respect_meter:set_alpha(0)
	vint_set_property(Hud_collection_cash_h, "alpha", 0)
	
	
	--Initialize Control meter...
	Hud_collection_control_meter:update(Hud_collection_data.district_pct_old, false)
	
	--Do update of text items...
	local header_txt_h = vint_object_find("collection_header_txt")
	local insert_values = { [0] = Hud_collection_data.title, [1] = Hud_collection_data.items_left, [2] = Hud_collection_data.items_total}
	
	local text_string
	if Hud_collection_data.collection_type == HUD_COLLECTION_STAG then
		text_string = Hud_collection_data.title
	else
		text_string = vint_insert_values_in_string("{0} {1}/{2}", insert_values)
	end
	
	vint_set_property(header_txt_h, "text_tag", text_string)
	
	local sub_txt_h = vint_object_find("collection_sub_txt")
	vint_set_property(sub_txt_h, "text_tag", Hud_collection_data.sub_title)

	--Set cash total...
	vint_set_property(Hud_collection_cash_h, "text_tag", "$" .. format_cash(Hud_collection_data.cash_reward))
	
	--calculate widths of headers and cash
	local header_width, header_height = element_get_actual_size(header_txt_h)
	local header_sub_width, header_sub_height = element_get_actual_size(sub_txt_h)
	
	--Need to scale but by how much?
	local new_header_width = max(header_width, header_sub_width)
	local scale = 1.0
	local max_width = HUD_COLLECTION_HEADER_MAX_WIDTH
	
	if header_width > header_sub_width then
		if header_width > max_width then
			scale = max_width / header_width
			new_header_width = header_width * scale
		end
	else
		if header_sub_width > max_width then
			scale =  max_width / header_sub_width
			new_header_width = header_sub_width * scale
		end
	end
	
	--Apply scale to whole text group...
	local collection_title_grp_h = vint_object_find("collection_title_grp")
	vint_set_property(collection_title_grp_h, "scale", scale, scale)
	
	local pos_y = 102 * 3							--Start position for reward elements...
	local start_time = 1.5					--start offset for first reward...
	local start_time_spacing = 1.2		--Time between rewards..
	local header_width_min = 0 			-- min size of element 		
	local HUD_COLLECTION_TEXT_SPACING = 15 * 3
	--positions
	local title_x, title_y = vint_get_property(collection_title_grp_h, "anchor")
	local x, y = Hud_collection_control_meter:get_anchor()
	x = title_x + new_header_width + HUD_COLLECTION_TEXT_SPACING 
	
	--Positions for elements...
	local control_x 	= 0					
	local respect_x 	= 0
	local cash_x 		= 0
	
	--Start times for elements...
	local control_start_time 	= 0
	local respect_start_time 	= 0
	local cash_start_time 		= 0 
	local complete_start_time 	= 0
	
	local HUD_COLLECTION_ITEM_SPACING = 10 * 3
	
	--Determine what we have and then calculate each item based on that...
	if Hud_collection_data.has_district then
		local half_width = (HUD_COLLECTION_CONTROL_WIDTH *.5)
		control_x = x + half_width
		x = x + HUD_COLLECTION_CONTROL_WIDTH + HUD_COLLECTION_ITEM_SPACING
		
		control_start_time = start_time
		start_time =  start_time + start_time_spacing
	end
	
	if Hud_collection_data.has_respect then
		local half_width = (HUD_COLLECTION_RESPECT_WIDTH *.5)
		respect_x = x + half_width
		x = x + HUD_COLLECTION_RESPECT_WIDTH + HUD_COLLECTION_ITEM_SPACING
	
		respect_start_time = start_time
		start_time =  start_time + start_time_spacing
	end
	
	if Hud_collection_data.has_cash then
		local cash_width, cash_height = element_get_actual_size(Hud_collection_cash_h)
		local half_width = (cash_width *.5)
		cash_x = x  + half_width
		x = x + cash_width + HUD_COLLECTION_ITEM_SPACING		
		
		cash_start_time = start_time
	end


	local total_width = x							--total width of the element is x....	
	complete_start_time = start_time + 3		--Delay close out animation by 3 seconds...

	--Set positions...
	Hud_collection_control_meter:set_anchor(control_x, y)
	Hud_collection_respect_meter:set_anchor(respect_x, y)
	vint_set_property(Hud_collection_cash_h, "anchor", cash_x, y)
	
	local collection_elements_grp_h = vint_object_find("collection_elements_grp")
	local collection_x, collection_y = vint_get_property(collection_elements_grp_h, "anchor")
	collection_x = (640 * 3) - (total_width * 0.5)
	vint_set_property(collection_elements_grp_h, "anchor", collection_x, collection_y)
	
	--Unhide
	local h = vint_object_find("collection_grp")
	vint_set_property(h, "visible", true)
	
	
	--Playback animations at different times...
	
	-- Play back main animation....
	lua_play_anim(Hud_collection_anims.in_anim_h, 0)
	
	ui_audio_post_event("ui_generic_band_anim_in")
			
	--Play back animations... but only if they are needed... this is to prevent bad callbacks...
	if Hud_collection_data.has_district then
		lua_play_anim(Hud_collection_anims.district_anim_h, control_start_time)
	end
	if Hud_collection_data.has_respect then
		lua_play_anim(Hud_collection_anims.respect_anim_h, respect_start_time)
	end
	if Hud_collection_data.has_cash then
		lua_play_anim(Hud_collection_anims.cash_anim_h, cash_start_time)
	end
	
	--This animation closes it out...
	lua_play_anim(Hud_collection_anims.complete_anim_h, complete_start_time)
		
	local collection_hud_bg_tile_h = vint_object_find("collection_hud_bg_tile")
	lua_play_anim(collection_hud_bg_tile_h)
	
	--Get audio string from collection type...
	local audio = Hud_collection_types[Hud_collection_data.collection_type].audio
	if audio ~= nil then
		--Play event...
		audio_object_post_event(audio, nil, nil, nil, false)
	end
end

function hud_collection_audio_out()
	ui_audio_post_event("ui_generic_band_anim_out")
end

function hud_collection_finished()

	--pause looping bg animation..
	local collection_hud_bg_tile_h = vint_object_find("collection_hud_bg_tile")
	vint_set_property(collection_hud_bg_tile_h, "is_paused", true)
	
	--award the stuff for real...
	if Hud_collection_data.has_respect and Hud_collection_data.no_reward ~= true then
		game_award_respect(Hud_collection_data.respect_reward, STATS_INVALID, Hud_collection_types[Hud_collection_data.collection_type].d_type, Hud_collection_data.save_in_mission)		
	end
	if Hud_collection_data.has_cash and Hud_collection_data.no_reward ~= true then
		game_award_cash(Hud_collection_data.cash_reward, Hud_collection_types[Hud_collection_data.collection_type].d_type, Hud_collection_data.save_in_mission)			
	end

	if Current_collection_index == Num_collection_data then
		Num_collection_data = 0
		Current_collection_index = 0
		Queued_collection_data = { }
		Hud_collection_is_active = false
		
		--only save after last collection is done...
		game_autosave()
	else 
		hud_collection_start()
	end
end

-------------------------------------------------------------
-- Starts control meter fill/update (done via callback)
-------------------------------------------------------------
function hud_collection_start_control()
	Hud_collection_control_meter:update(Hud_collection_data.district_pct_new, true)
end

-------------------------------------------------------------
-- Makes respect meter visible....(done via callback)
-------------------------------------------------------------
function hud_collection_show_respect()
	--Query respect meter for current values...
	local respect_total, respect_pct, respect_level = Hud_respect:get_data()

	--Initialize meter...
	Hud_collection_respect_meter:update_respect(Hud_collection_data.respect_reward, respect_pct, respect_level, false)
end

-------------------------------------------------------------
-- Starts respect meter fill/update (done via callback)
-------------------------------------------------------------
function hud_collection_start_respect()

	-- Query for the new values...
	local respect_total_new, respect_pct_new, respect_level_new  = Hud_respect:get_data()

	--Start animationg the meter...
	Hud_collection_respect_meter:update_respect(Hud_collection_data.respect_reward, respect_pct_new, respect_level_new, true)
end

-------------------------------------------------------------
-- Starts cash count/update (done via callback)
-------------------------------------------------------------
function hud_collection_start_cash()
	hud_collection_animate_cash()		
end

-----------------------------------------
--Cash count...
-----------------------------------------
function hud_collection_animate_cash()
   thread_new("hud_collection_anim_cash_thread")
end

function hud_collection_anim_cash_thread()
	--init stuff
	local start_cash = 0
	local cash_this_frame = -1
	local is_complete = false

	--get the variables from the global
	local cash = Hud_collection_data.cash_reward

	local amt_min = 100
	local amt_max = 5000
	
	local time_min = 300
	local time_max = 2999
	local init_time = floor(vint_get_time_index() * 1000)
	local cur_time = init_time
	local time_to_count = floor(time_min + ((time_max - time_min) * (cash / amt_max)))
	
	if time_to_count > time_max then
		time_to_count = time_max
	end
	
	--init sound IDs
	local activity_cash_count = 0
	local activity_cash_hit = 0

	while is_complete == false do
		cur_time = floor(vint_get_time_index() * 1000) - init_time
		
		--set my values
		cash_this_frame = cash * (cur_time / time_to_count)
		vint_set_property(Hud_collection_cash_h, "text_tag", "$" .. format_cash(cash_this_frame))
		
		if cur_time >= time_to_count then
			--game_audio_stop(activity_cash_count)
			--activity_cash_hit = game_audio_play(Completion_audio.cash_hit)
			vint_set_property(Hud_collection_cash_h, "text_tag", "$" .. format_cash(cash))
			is_complete = true
		end
		thread_yield()
	end		
end

-------------------------------------------------------------------------------
-- Pausing support for hud collection...
--
function hud_collection_game_is_paused(di_h)
	local is_paused = vint_dataitem_get(di_h)
	if Hud_collection_is_active then
		if is_paused == true then
			--Stop anims
			vint_set_property(Hud_collection_anims.complete_anim_h, "is_paused", true)
		else
			--Play all anims
			vint_set_property(Hud_collection_anims.complete_anim_h, "is_paused", false)
		end
	end
end-------------------------------------------------------------------------------
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