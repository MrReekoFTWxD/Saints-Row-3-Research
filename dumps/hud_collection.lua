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
end