-------------
-- CREDITS --
-------------
-- Credits Constants
--Movement Constants
CREDITS_PIXELS_PER_SEC_MAX 	= 480 * 3
CREDITS_PIXELS_PER_SEC_MAX_PC = 480 * 3
CREDITS_PIXELS_PER_SEC_NORMAL = 50 * 3 
CREDITS_PIXELS_PER_SEC_MIN 	= 5 * 3

-- Enum types for credits
local CREDITS_TYPE_HEADER		=	0
local CREDITS_TYPE_HEADER_SUB	=	1
local CREDITS_TYPE_ROLE_NAME	=	2
local CREDITS_TYPE_MUSIC		=	3
local CREDITS_TYPE_IMAGE		=	4
local CREDITS_TYPE_CENTERED	=	5

local CREDITS_FINISHED_TOKEN	= 100

local Credits_finished = false
local Credit_skipped = false
local Input_tracker




--------------------------------------
--Defines spacing above each item...
--------------------------------------
local CREDIT_OBJECT_FORMATTING = {
	[CREDITS_TYPE_HEADER] = {
			base_grp = "credit_header_grp",			-- Base group in the vint doc...
			txt_objects = {"header_txt"},				-- Text object in the base group...
			stacked = false,								-- If the items are stacked or set side to side.
			[CREDITS_TYPE_HEADER] = 70 * 3,				-- Spacing to set from bottom of this item type...
			[CREDITS_TYPE_HEADER_SUB] = 70 * 3,
			[CREDITS_TYPE_ROLE_NAME] = 70 * 3,
			[CREDITS_TYPE_MUSIC] = 70 * 3,
			[CREDITS_TYPE_CENTERED] = 70 * 3,
			[CREDITS_TYPE_IMAGE] = 30 * 3,
		},
	[CREDITS_TYPE_HEADER_SUB] = {
			base_grp = "credit_header_sub_grp",
			txt_objects = {"header_sub_txt"},
			stacked = false,
			[CREDITS_TYPE_HEADER] = 30 * 3,
			[CREDITS_TYPE_HEADER_SUB] = 65 * 3,
			[CREDITS_TYPE_ROLE_NAME] = 70 * 3,
			[CREDITS_TYPE_MUSIC] = 70 * 3,
			[CREDITS_TYPE_CENTERED] = 70 * 3,
			[CREDITS_TYPE_IMAGE] = 30 * 3,
		},
	[CREDITS_TYPE_ROLE_NAME] = {
			base_grp = "credit_role_name_grp",
			txt_objects = {"role_txt", "name_txt"},
			stacked = false,
			[CREDITS_TYPE_HEADER] = 20 * 3,
			[CREDITS_TYPE_HEADER_SUB] = 25 * 3,
			[CREDITS_TYPE_ROLE_NAME] = 0,
			[CREDITS_TYPE_MUSIC] = 35 * 3,
			[CREDITS_TYPE_CENTERED] = 35 * 3,
			[CREDITS_TYPE_IMAGE] = 30 * 3,
		},
	[CREDITS_TYPE_MUSIC] = {
			base_grp = "credit_music_grp",
			txt_objects = {"song_name_txt", "description_txt"},
			stacked = true,
			[CREDITS_TYPE_HEADER] = 20 * 3,
			[CREDITS_TYPE_HEADER_SUB] = 25 * 3,
			[CREDITS_TYPE_ROLE_NAME] = 35 * 3,
			[CREDITS_TYPE_MUSIC] = 35 * 3,
			[CREDITS_TYPE_CENTERED] = 35 * 3,
			[CREDITS_TYPE_IMAGE] = 30 * 3,
		},
	[CREDITS_TYPE_IMAGE] = {
			base_grp = "credit_image_grp",
			img_object = "image_bmp",
			[CREDITS_TYPE_HEADER] = 20 * 3,
			[CREDITS_TYPE_HEADER_SUB] = 25 * 3,
			[CREDITS_TYPE_ROLE_NAME] = 35 * 3,
			[CREDITS_TYPE_MUSIC] = 35 * 3,
			[CREDITS_TYPE_CENTERED] = 35 * 3,
			[CREDITS_TYPE_IMAGE] = 30 * 3,
		},
	[CREDITS_TYPE_CENTERED] = {
			base_grp = "credit_centered_grp",
			txt_objects = {"centered_txt"},
			stacked = false,
			[CREDITS_TYPE_HEADER] = 20 * 3,
			[CREDITS_TYPE_HEADER_SUB] = 25 * 3,
			[CREDITS_TYPE_ROLE_NAME] = 35 * 3,
			[CREDITS_TYPE_MUSIC] = 35 * 3,
			[CREDITS_TYPE_CENTERED] = 0,
			[CREDITS_TYPE_IMAGE] = 30 * 3,
		},
}

--General Constants
CREDITS_HALF_SCREEN_HEIGHT = 360 * 3
CREDITS_SCREEN_LEEWAY_TOP 				= 50 * 3
CREDITS_SCREEN_LEEWAY_BOTTOM 			= 250 * 3
CREDITS_IMAGE_SCREEN_LEEWAY_TOP		= 50 * 3
CREDITS_IMAGE_SCREEN_LEEWAY_BOTTOM 	= 250 * 3


Credits_images = {
	"ui_credits_001",
	"ui_credits_002",
	"ui_credits_003",
	"ui_credits_004",
	"ui_credits_005",
	"ui_credits_006",
	"ui_credits_007",
	"ui_credits_008",
	"ui_credits_009",
	"ui_credits_010",
	"ui_credits_011",
	"ui_credits_012",
	"ui_credits_013",
	"ui_credits_014",
	"ui_credits_015",
	"ui_credits_016",
	"ui_credits_017",
	"ui_credits_018",
	"ui_credits_019",
	"ui_credits_020",
	"ui_credits_021",
	"ui_credits_022",
	"ui_credits_023",
	"ui_credits_024",
	"ui_credits_025",
	"ui_credits_026",
	"ui_credits_027",
	"ui_credits_028",
	"ui_credits_029",
	"ui_credits_030",
	"ui_credits_031",
	"ui_credits_032",
	"ui_credits_033",
	"ui_credits_034",
	"ui_credits_035",
	"ui_credits_036",
	"ui_credits_037",
	"ui_credits_038",
	"ui_credits_039",
	"ui_credits_040",
	"ui_credits_041",
	"ui_credits_042",
	"ui_credits_043",
	"ui_credits_044",
	"ui_credits_045",
	"ui_credits_046",
	"ui_credits_047",
	"ui_credits_048",
	"ui_credits_049",
	"ui_credits_050",	
	"ui_credits_051",
	"ui_credits_052",
	"ui_credits_053",
	"ui_credits_054",
	"ui_credits_055",
	"ui_credits_056",
	"ui_credits_057",
	"ui_credits_058",
	"ui_credits_059",
	"ui_credits_060",	
	"ui_credits_061",
	"ui_credits_062",
	"ui_credits_063",
	"ui_credits_064",
	"ui_credits_065",
	"ui_credits_066",
	"ui_credits_067",
	"ui_credits_068",
	"ui_credits_069",
	"ui_credits_070",		
	"ui_credits_071",
	"ui_credits_072",
	"ui_credits_073",
	"ui_credits_074",
	"ui_credits_075",
	"ui_credits_076",
	"ui_credits_077",
	"ui_credits_078",
	"ui_credits_079",
	"ui_credits_080",	
	"ui_credits_081",
	"ui_credits_082",
	"ui_credits_083",
	"ui_credits_084",
}


--init text size globals
Credits_cur_idx = -1				--Current credit index...
Credits_oldest_idx = 0			
Credits_cur_slide_pos = 400 * 3	--Position of slide... 400 starts us off the bottom of the screen...
Credits_num_items = 0			--Num Items
Credits_scroll_speed = CREDITS_PIXELS_PER_SEC_NORMAL
Credits_skip_available  = true

Credits_objects = {}

Credits = {}
Credits_data = { }

--Credits Reel (aka images)
CREDITS_REEL_IMG_SPACING  = 20 --* 3			--Spacing between reel images...
CREDITS_REEL_IMG_HEIGHT  = 169 --* 3			--Height of reel image...
Credits_reel_cur_idx = -1					--Current credit index...
Credits_reel_oldest_idx = 0
Credits_reel_cur_slide_pos = 640 --* 3			--Position of slide... 600 starts us a bit below the log.
Credits_reel_num_items = 0	--Num Items
Credits_reel_data = {}

local Credits_reel_load_queue = {}		--Images that we are loading...
local Credits_reel_load_num = 0			--# Images that we plan to load
local Credits_reel_loaded_num = 0		--# Images that loaded...

Credits_inverse_scale			= 1.0
Credits_reel_inverse_scale		= 1.0

--[[
	-- Comment Used as reference....
	Credits_data = {
		[0] = {type = CREDITS_TYPE_HEADER, 			data = {"Volition"}},
		[1] = {type = CREDITS_TYPE_HEADER_SUB, 	data = {"Leads"}},
		[2] = {type = CREDITS_TYPE_ROLE_NAME, 		data = {"Producer", "Gred Donovan"}},
		[3] = {type = CREDITS_TYPE_ROLE_NAME, 		data = {"Product Technical Director", "Nick Lee"}},
		[4] = {type = CREDITS_TYPE_ROLE_NAME, 		data = {"Programmer", "David Absug"}},
		[5] = {type = CREDITS_TYPE_ROLE_NAME,		data = {"Programmer", "Jim Brennan"}},
		[6] = {type = CREDITS_TYPE_ROLE_NAME, 		data = {"Programmer", "John Buckley"}},
		[7] = {type = CREDITS_TYPE_MUSIC,			data = {"This is how we do it", "Performed by Jesus Christ Superstar. This covers any SR2 specific technical details that need to be documented. Things pertaining to how parts of the"}},
		[8] = {type = CREDITS_TYPE_MUSIC, 			data = {"Dear Maria, Count Me In", "Performed by All Time Low. Concerts, album reviews, pop, jazz and classical music news from the Los Angeles Times."}},
		[9] = {type = CREDITS_TYPE_MUSIC, 			data = {"Sorry", "Peformed by Buck Cherry. Check out new bands and artists on MySpace Music: Watch music videos, check out concerts and tour dates, music, news and more."}},
	}
	Credits_num_items = 10
]]

Credits_thread = -1			--Thread for credits processing....
Credits_reel_thread = -1			--Thread for credits processing....
Credits_is_in_game = false


function credits_init()
	
	--Check to see if we are in game...
	if vint_document_find("main_menu_common") == 0 then
		Credits_is_in_game = true 
	else
		audio_object_post_event("Credits_main_menu", nil, nil, nil, false)
	end
	
	--Dumping pause map if in game...
	if Credits_is_in_game then
		pause_map_dump()
	end
	
	if vint_is_std_res() then
		--Must scale overides in the document
		Credits_inverse_scale		= 1/.55
		Credits_reel_inverse_scale	= 1/.48		
	end
	
	Credits_objects = {}
	
	--Build image table from out list (This just makes coding easier)
	for idx, img in pairs(Credits_images) do
		Credits_reel_data[Credits_reel_num_items] = { img = img }
		Credits_reel_num_items = Credits_reel_num_items + 1
	end
	--Wipe out original credits table...
	Credits_images = {}
	
	--Template Elements
	Credits_objects.credits_base_h = vint_object_find("credits_base_grp")
	Credits_objects.credits_slide_h = vint_object_find("credits_slide_grp")
	Credits_objects.credits_reel_slide_h = vint_object_find("credits_reel_slide_grp")
	
	--Hide all base objects
	for idx, val in pairs(CREDIT_OBJECT_FORMATTING) do
		local base_grp_h = vint_object_find(val.base_grp)
		vint_set_property(base_grp_h, "visible", false)
	end

	--Hide reel base object...
	local h = vint_object_find("reel_bmp", Credits_objects.credits_reel_slide_h)
	vint_set_property(h, "visible", false)
	
	--logo img placeholder
	Credits_objects.logo = vint_object_find("credit_logo")

	--populate first item with image...
	Credits_data[Credits_num_items] = { type = CREDITS_TYPE_IMAGE, data = {"uhd_ui_mainmenu_logo_shield"} }
	Credits_num_items = Credits_num_items + 1
	
	--Download 50 of the first credits...
	vint_dataresponder_request("credits_grab_credits", "credits_populate", 50)
	
	--Start thread for credits processing....
	Credits_thread = thread_new("credits_process")
	Credits_reel_thread = thread_new("credits_reel_process")
	
	--hide background layers...
	local background_base_bg_h = vint_object_find("background_base_bg")
	local credits_bg_grp_h = vint_object_find("credits_bg_grp")
	vint_set_property(background_base_bg_h, "alpha", 0)
	vint_set_property(credits_bg_grp_h, "alpha", 0)
	
	--Is the main menu loaded? if so do not delay background fade in.
	
	if Credits_is_in_game then
		--Fade in background.
		local anim_h = vint_object_find("credits_bg_game_fade_in")
		lua_play_anim(anim_h)	--delay background fade in by 2 seconds...
	else
		--We are in main menu, play different anim
		local anim_h = vint_object_find("credits_bg_main_menu_fade_in")
		lua_play_anim(anim_h)
	end
	
	local anim = vint_object_find("credit_bg_loop_anim")
	lua_play_anim(anim,0)
	
	--Subscribe to input...
	Input_tracker = Vdo_input_tracker:new()
	Input_tracker:add_input("select", "credits_button_b", 50)
	Input_tracker:add_input("back", "credits_button_b", 50)
	Input_tracker:add_input("map", "credits_button_b", 50)
	Input_tracker:add_input("inventory_y", "credits_input_stick", 50, true)
	
	if game_get_platform() == "PC" then
		Input_tracker:add_input("key_down", "credits_input_faster", 50)
		Input_tracker:add_input("key_up", "credits_input_slower", 50)
	end

	Input_tracker:subscribe(true)
end

function credits_cleanup()
	-- stop audio
	audio_object_post_event("Credits_stop", nil, nil, nil, false)
	
	---Cleanup any loaded pegs from our image reel...
	for idx, val in pairs(Credits_reel_load_queue) do
		if val ~= nil then
			game_peg_unload(val.image_name)
		end
	end

	-- If we are in game we need to restore the pause map...
	if Credits_is_in_game then
		local cte_news_doc = vint_document_find("cte_news")
		if cte_news_doc == 0 then
			--restore pause map...
			pause_map_restore()
		end
	end	

	if Credits_thread ~= -1 then
		thread_kill(Credits_thread)
	end
	
	if Credits_reel_thread ~= -1 then
		thread_kill(Credits_reel_thread)
	end
	
	Input_tracker:subscribe(false)
end

-------------------------------------------------------------------------------
-- Populates the credits...
--
function credits_populate(item_type, str1, str2)
	if item_type == CREDITS_FINISHED_TOKEN then
		Credits_finished = true
		return
	end

	--If string is empty skip this credit...
	if str1 == "" or  str1 == nil then
		Credit_skipped = true
		return
	end
	
	Credits_data[Credits_num_items] = { type = item_type, y = -1 }
	
	if str2 ~= nil then 
		if item_type == CREDITS_TYPE_ROLE_NAME then
			Credits_data[Credits_num_items].data = { str2, str1 }
		else
			Credits_data[Credits_num_items].data = { str1, str2 }
		end
	else
		Credits_data[Credits_num_items].data = { str1 }
	end
	Credits_num_items = Credits_num_items + 1
end

--------------------------------------------------------------------------------
-- Credits process thread... used for formatting and moving the credits....
--------------------------------------------------------------------------------
function credits_process()
	
	local move_amount = 0
	
	local prev_item, new_item, credit_h, h, item_width, item_height, prev_height, prev_item_y, item_y
	local create_new_item = false
	local credits_play = true
	
	while credits_play do
		--move credits
		move_amount = Credits_scroll_speed * get_frame_time()
		
		--Slide Credits up
		Credits_cur_slide_pos = Credits_cur_slide_pos - move_amount
		vint_set_property(Credits_objects.credits_slide_h, "anchor", 0, Credits_cur_slide_pos)
	
		--Is the first top item off the screen?	
		if Credits_cur_idx < 0 then
			--Initialize always create first item...
			create_new_item = true
		else
			--Remove first item?
			local actual_slide_pos = Credits_cur_slide_pos + CREDITS_HALF_SCREEN_HEIGHT 
			
			if Credits_data[Credits_oldest_idx] ~= nil then	
				if actual_slide_pos <  (Credits_data[Credits_oldest_idx].y + (Credits_data[Credits_oldest_idx].height * Credits_inverse_scale) + CREDITS_SCREEN_LEEWAY_TOP) * -1 then
					--Lets kill it
					if Credits_data[Credits_oldest_idx].credit_h ~= nil then
						vint_object_destroy(Credits_data[Credits_oldest_idx].credit_h)
					end
					
					Credits_data[Credits_oldest_idx] = nil
					Credits_oldest_idx = Credits_oldest_idx + 1
					
					--Attempt to Get the next credit...
					if Credits_finished ~= true then
						Credit_skipped = true
						while Credit_skipped == true do
							Credit_skipped = false
							vint_dataresponder_request("credits_grab_credits", "credits_populate", 1)
						end
					end
					
					--Are credits complete?
					if Credits_num_items == Credits_oldest_idx then
						--Credits complete
						credits_complete()
						credits_play = false
					end
				end
			end	

			if Credits_data[Credits_cur_idx] ~= nil then		
				--Build next item
				local next_item_build_at = (Credits_data[Credits_cur_idx].y + Credits_data[Credits_cur_idx].height) * -1
				actual_slide_pos = Credits_cur_slide_pos - CREDITS_HALF_SCREEN_HEIGHT 
				if actual_slide_pos < next_item_build_at + CREDITS_SCREEN_LEEWAY_BOTTOM then
					create_new_item = true 
				end
			end
		end
		
		--Should I create an item on the bottom?
		if create_new_item == true then
			--What is the new item going to be?
			local next_index = Credits_cur_idx + 1
			new_item = Credits_data[next_index]
			
			if new_item ~= nil and next_index <= Credits_num_items then
				--store new index to global.
				Credits_cur_idx = next_index
	
				--get item type, data and formatting for that item...
				local item_type = new_item.type
				local item_data = new_item.data
				local credit_object_format = CREDIT_OBJECT_FORMATTING[item_type]
					
				--find our base object
				local base_grp = credit_object_format.base_grp
				local base_grp_h = vint_object_find(base_grp) 
					
				--Clone it...
				local base_grp_clone_h = vint_object_clone(base_grp_h)
				
				local height = 0
				
				if item_type == CREDITS_TYPE_IMAGE then
					--Image Type
					local image_h = vint_object_find("img_bmp", base_grp_clone_h)
					local image_name = item_data[1]
					
					vint_set_property(image_h, "image", image_name)
					local image_width, image_height = element_get_actual_size(image_h)
					height = image_height
				else
					--All other types...
					local txt_objects = credit_object_format.txt_objects
					local num_txt_objects = #txt_objects
					
					for i = 1, num_txt_objects do
						local txt_object = txt_objects[i]
						
						--Find our text object...
						local txt_object_h = vint_object_find(txt_object, base_grp_clone_h)
						
						local txt_data = item_data[i]
						
						--Set text tag...
						vint_set_property(txt_object_h, "text_tag", txt_data)
						
						--calculate height...
						if txt_data ~= "" then
							--only calculate height on credit items with strings in them...
							local text_width, text_height = element_get_actual_size(txt_object_h)
							
							--move name down on wrapped roles
							if item_type == CREDITS_TYPE_ROLE_NAME then
								if i == 1 then
									local next_txt_object_h = vint_object_find(txt_objects[i+1], base_grp_clone_h)
									local role_width, role_height = element_get_actual_size(txt_object_h)
									local name_width, name_height = element_get_actual_size(next_txt_object_h)
									if txt_object == "role_txt" and role_height > name_height then
										local x, y = vint_get_property(next_txt_object_h, "anchor")
										local name_move = y + (role_height - name_height)
										vint_set_property(next_txt_object_h, "anchor", x, name_move)
									end
								end
							end
							
							if credit_object_format.stacked == true then
								
								if i > 1 then
									--get original position
									local x, y = vint_get_property(txt_object_h, "anchor")
									
									--shift y down... +3 offset for each item.
									y = height + (3 * (i - 1))
									
									--set new position
									vint_set_property(txt_object_h, "anchor", x, y)
								end
								
								--stacked... add heights...
								height = height + text_height
							else
								--Not stacked... figure out largest height...
								height = max(height, text_height)
							end
						end
					end
					
				end
				
				
				--Reassign parent and set visible...
				vint_object_set_parent(base_grp_clone_h, Credits_objects.credits_slide_h)
				vint_set_property(base_grp_clone_h, "visible", true)
				
				--Calculate y from previous item data
				prev_item = Credits_data[Credits_cur_idx - 1]
				
				if prev_item == nil then
					--no item, so we always start at 0.
					item_y = 0
				else
					local prev_type = prev_item.type
					local vertical_spacing = credit_object_format[prev_type]		--get spacing from our previous object type...
					local prev_height = prev_item.height								--get height of previous item...					
					item_y = prev_item.y + prev_height + vertical_spacing			--add previous item y + height + spacing.
				end
				
				--Position object
				vint_set_property(base_grp_clone_h, "anchor", 0, item_y)
				
				--store off the new object for processing and cleanup...
				new_item.credit_h = base_grp_clone_h
				new_item.height = height 
				new_item.type = item_type 
				new_item.y = item_y 
			end
			
			--Do not create the next item automatically
			create_new_item = false
		end
		thread_yield()
	end
end

--------------------------------------------------------------------------------
-- Reel Slide
--------------------------------------------------------------------------------
function credits_reel_process()
	
	local move_amount = 0
	
	local prev_item, new_item, credit_h, h, item_width, item_height, prev_item_height, prev_item_y, item_y
	local next_item_build_at = 0
	local create_new_item = false
	local credits_play = true
	
	while credits_play do
		--move Reel...
		
		--Reel moves at half speed of normal credit speed...
		move_amount = Credits_scroll_speed * get_frame_time() *.5
		
		--Slide Credits up
		Credits_reel_cur_slide_pos = Credits_reel_cur_slide_pos - move_amount
		vint_set_property(Credits_objects.credits_reel_slide_h, "anchor", 0, Credits_reel_cur_slide_pos)
		
		--Is the first top item off the screen?	
		if Credits_reel_cur_idx < 0 then
			--Initialize always create first item...
			create_new_item = true
		else
			--Remove first item?
			local actual_slide_pos = Credits_reel_cur_slide_pos + CREDITS_HALF_SCREEN_HEIGHT 
			
			if Credits_reel_data[Credits_reel_oldest_idx] ~= nil then	
				if actual_slide_pos <  (Credits_reel_data[Credits_reel_oldest_idx].y + (CREDITS_REEL_IMG_HEIGHT * Credits_reel_inverse_scale) + CREDITS_IMAGE_SCREEN_LEEWAY_TOP) * -1 then
					--Lets kill it
					if Credits_reel_data[Credits_reel_oldest_idx].img_h ~= nil then
						local image_data = Credits_reel_data[Credits_reel_oldest_idx]
						vint_object_destroy(image_data.img_h)
						game_peg_unload(image_data.img)
						
						Credits_reel_load_queue[image_data.queue_num] = nil
					end
					
					Credits_reel_data[Credits_reel_oldest_idx] = nil
					Credits_reel_oldest_idx = Credits_reel_oldest_idx + 1
					
					--Are credits complete?
					if Credits_reel_num_items == Credits_reel_oldest_idx then
						--Credit reel complete...
						credits_play = false
					end
				end
			end	
			if Credits_reel_data[Credits_reel_cur_idx] ~= nil then		
				actual_slide_pos = Credits_reel_cur_slide_pos - CREDITS_HALF_SCREEN_HEIGHT 
				if actual_slide_pos < next_item_build_at + CREDITS_IMAGE_SCREEN_LEEWAY_BOTTOM then				
					create_new_item = true 
				end
			end
		end

		--Should I create an item on the bottom?
		if create_new_item == true then
			--What is the new item going to be?
			local next_idx = Credits_reel_cur_idx + 1
			new_item = Credits_reel_data[next_idx]
			
			if new_item ~= nil and next_idx <= Credits_reel_num_items then	
				--store current index to global...
				Credits_reel_cur_idx = next_idx
				
				local image_name = Credits_reel_data[Credits_reel_cur_idx].img
		
				--Position Image
				local base_image_h = vint_object_find("reel_bmp", Credits_objects.credits_reel_slide_h)
				
				--Clone image base
				local image_clone_h = vint_object_clone(base_image_h)
				vint_object_set_parent(image_clone_h, Credits_objects.credits_reel_slide_h)
				vint_set_property(image_clone_h, "visible", true)

				--Stream in the next image...
				local queue_num = Credits_reel_load_num
				game_peg_load_with_cb("credits_reel_peg_loaded", 1, image_name)
				Credits_reel_load_queue[queue_num] = { image_name = image_name, image_h = image_clone_h}
				Credits_reel_load_num = Credits_reel_load_num + 1
				
				--Position it.
				
				--Calculate y from previous item data
				prev_item = Credits_reel_data[Credits_reel_cur_idx - 1]
				if prev_item == nil then
					--no item, so we always start at 0.
					item_y = 0
				else
					item_y = prev_item.y + CREDITS_REEL_IMG_HEIGHT + CREDITS_REEL_IMG_SPACING --add previous item y + height + spacing.
				end
					
				--Position object
				vint_set_property(image_clone_h, "anchor", 0, item_y)
				
				--store off the new object for processing and cleanup...
				new_item.img_h = image_clone_h
				new_item.height = CREDITS_REEL_IMG_HEIGHT
				new_item.queue_num = queue_num		--Store queue number so we can remove it from the list on peg unload...
				
				--Build next item
				next_item_build_at = (item_y + CREDITS_REEL_IMG_HEIGHT) * -1
				new_item.y = item_y 
			end
			
			--Do not create the next item automatically
			create_new_item = false
		end
		thread_yield()
	end
end


function credits_complete()
	--Unsubscribe from controls
	Input_tracker:subscribe(false)
	
	--Tell game that credits are done rolling
	--TODO: Darryl needs to hook this in...
	--credits_are_finished()
	pop_screen()
end

----------------------------------
--Input Functions
----------------------------------
function credits_input_stick(event, value)
	if event == "inventory_y" then
		--Adjust credit speed
		if value > 0 then
			Credits_scroll_speed = CREDITS_PIXELS_PER_SEC_NORMAL + (CREDITS_PIXELS_PER_SEC_MIN - CREDITS_PIXELS_PER_SEC_NORMAL ) * value 
			
		elseif value < 0 then
		
			Credits_scroll_speed = 	CREDITS_PIXELS_PER_SEC_NORMAL + (CREDITS_PIXELS_PER_SEC_MAX - CREDITS_PIXELS_PER_SEC_NORMAL) * value * -1 
		else
			Credits_scroll_speed = CREDITS_PIXELS_PER_SEC_NORMAL 
		end
	end
end


function credits_input_faster(event)
	local slow_speed = CREDITS_PIXELS_PER_SEC_NORMAL + (CREDITS_PIXELS_PER_SEC_MIN - CREDITS_PIXELS_PER_SEC_NORMAL) 
	local fast_speed = CREDITS_PIXELS_PER_SEC_NORMAL + (CREDITS_PIXELS_PER_SEC_MAX_PC - CREDITS_PIXELS_PER_SEC_NORMAL) 
	if Credits_scroll_speed == slow_speed then
		Credits_scroll_speed = CREDITS_PIXELS_PER_SEC_NORMAL
	elseif Credits_scroll_speed == CREDITS_PIXELS_PER_SEC_NORMAL then
		Credits_scroll_speed = fast_speed
	else
		--Credits_scroll_speed = slow_speed
	end
end

function credits_input_slower(event)

	local slow_speed = CREDITS_PIXELS_PER_SEC_NORMAL + (CREDITS_PIXELS_PER_SEC_MIN - CREDITS_PIXELS_PER_SEC_NORMAL) 
	local fast_speed = CREDITS_PIXELS_PER_SEC_NORMAL + (CREDITS_PIXELS_PER_SEC_MAX_PC - CREDITS_PIXELS_PER_SEC_NORMAL) 
	if Credits_scroll_speed == fast_speed then
		Credits_scroll_speed = CREDITS_PIXELS_PER_SEC_NORMAL
	elseif Credits_scroll_speed == CREDITS_PIXELS_PER_SEC_NORMAL then
		Credits_scroll_speed = slow_speed
	else
		--Credits_scroll_speed = fast_speed
	end
end

function credits_button_b(event, acceleration)
	--exit credits
	credits_complete()
end


function credits_reel_peg_loaded()
	--after images load then we have to set the image on the bitmap handle...
	local image_info = Credits_reel_load_queue[Credits_reel_loaded_num]
	if image_info == nil then
		return
	end
	
	local image_name = image_info.image_name
	local image_h = image_info.image_h
	vint_set_property(image_h, "image", image_name)

	Credits_reel_loaded_num = Credits_reel_loaded_num + 1
end
--[[
OLD FUNCTIONALITY???
function credits_input_btn(event, accelleration)
	
	if Credits_skip_available == true then
		if event == "exit" then
			credits_were_skipped()
		elseif credits_in_cutscene() == false then
			credits_complete()
		end
	end
end
]]
on, self.num_buttons)
			
			local total_buttons = #self.data
			local total_height = ( total_buttons * PAUSE_LIST_BUTTON_HEIGHT  ) + ( PAUSE_LIST_HIGHLIGHT_HEIGHT )

			local new_y = total_height + 0
			local list_x, list_y =  self.group:get_property("anchor")
			local scrolling = false
			local visual_center = ( self.max_buttons * 0.5 )
			--get the value for the visual bottom
			local visual_center_bottom = total_buttons - visual_center
			--do we need to scroll?
			if (-1 * total_height) <= 0 then
				scrolling = true
				--move the list
				local end_y = 5 * 3
				if direction == -1 then
					--is the current button half way from the visible top
					if self.current_idx > visual_center then
						--the current button is greater than or equal to the visual middle
						--is the current button half way from the visible bottom
						if self.current_idx < visual_center_bottom then
							--the current button is less than or equal to the visual bottom center
							--MOVE THE Y UP
							new_y = list_y + PAUSE_LIST_BUTTON_HEIGHT
						else
							new_y = end_y
						end
					end
				else
					--is the current button half way from the visible top
					if self.current_idx > visual_center then
						--the current button is greater than or equal to the visual middle
						--is the current button half way from the visible bottom
						if self.current_idx < visual_center_bottom then
							--the current button is less than or equal to the visual bottom center
							--MOVE THE Y DOWN
							new_y = list_y - PAUSE_LIST_BUTTON_HEIGHT
						else
							new_y = end_y
						end
					end
				end
		
				Vdo_pause_mega_list_tween_done = true
			end
		
			-- Get current button
			local current_idx = self.current_idx
			local current_button = self.buttons[current_idx]
			
			local current_button_data = self.data[current_idx]
			
			-- Highlight current button
			current_button:set_highlight(true)
			current_button:set_property("depth", -10)
			current_button:set_property("blur", 0)
		
			highlight:set_property( "depth",  -1)
			--get the current highlighted button x and y
			local button_x, button_y = current_button:get_property("anchor")
			highlight:set_property( "anchor", button_x, button_y )
			highlight:set_width(current_button:get_text_width())
			
			--if there is only one button don't animate highlight
			if self.num_buttons > 1 then
				highlight:set_highlight()
			end
			
			
			-- Highlighting a button...
			if self.data[current_idx].type == TYPE_BUTTON then
				--Default controls...
				--Show A Button
				highlight:show_button(CTRL_MENU_BUTTON_A)
			end
			
			if current_button_data.disabled == true then
				--hide icon and button
				current_button:set_property("alpha", 0.5)
				highlight:show_button("")
			else
				current_button:set_property("alpha", 1.0)
			end
		end
	elseif self.data[self.current_idx].type == TYPE_TOGGLE then
		--toggle is open so send the navigation off to the toggle list
		self.toggle:move_cursor(direction)
	end
end

function Vdo_pause_mega_list:get_selection()
	if not self.draw_called then
		debug_print("vint", "Vdo_pause_mega_list:get_selection called with invalid document handle\n")
		return
	end
	
	if self.data[self.current_idx].disabled == true then
		return -1
	end

	return self.current_idx
end


-- Gets an optional ID value if one is saved
function Vdo_pause_mega_list:get_id()
	if not self.draw_called then
		debug_print("vint", "Vdo_pause_mega_list:get_toggle_selection called with invalid document handle\n")
		return
	end
	
	if self.data[self.current_idx].disabled == true then
		return -1
	end
	
	return self.data[self.current_idx].id
end

function Vdo_pause_mega_list:button_a()
	if not self.draw_called then
		debug_print("vint", "Vdo_pause_mega_list:button_a called with invalid document handle\n")
		return
	end
	

	
	local current_idx = self.current_idx
	local button_data = self.data[current_idx]
	local button =  self.buttons[current_idx]
	
	if button_data.type == TYPE_BUTTON then
		--Play sound...
		game_UI_audio_play("UI_main_menu_select")
	end

	--Callback for selecting the object...
	if button_data.on_select then
		button_data.on_select(button_data)
	end
	
	--check if we can process input
	if not Vdo_pause_mega_list_tween_done then
		return
	end
	
	local current_button = self.buttons[current_idx]
end

function Vdo_pause_mega_list:button_b()
	if not self.draw_called then
		debug_print("vint", "Vdo_pause_mega_list:button_b called with invalid document handle\n")
		return
	end
	
	--play sound...
	game_UI_audio_play("UI_main_menu_nav_back")
	
	local current_idx = self.current_idx
	local current_button = self.buttons[current_idx]
end


function Vdo_pause_mega_list:return_data()
	if not self.draw_called then
		debug_print("vint", "Vdo_pause_mega_list:return_data called with invalid document handle\n")
		return
	end
	
	return self.data
end

function Vdo_pause_mega_list:return_selected_data()
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