local ID_NEW_SAVE_GAME 			= 99
local ID_NO_GAMES					= -1
local SAVE_LOAD_WIDTH			= 800 * 3

local Save_load_max_visible	= 8

local Save_load_doc 	= -1
local Save_load_list = -1

local Save_load_unload_img = -1
local Save_load_image_update_thread = -1
local Save_load_current_image = nil

local Save_load_stat_grp = -1

local Save_load_image = nil

local Save_load_data = {}
local Num_saves = 0

local Input_tracker = {}
local Mouse_input_tracker = 0
local Hint_bar_mouse_input_tracker = 0
local Save_id

local Device_selected = false
local Slide_out = true
local Is_Forced_Exit = true

Pause_Respect_meter = -1
Pause_District_meter = -1

local Pause_save_images = {
	"ui_save_1",
	"ui_save_2",
	"ui_save_3",
	"ui_save_4",
	"ui_save_5",
	"ui_save_6",
	"ui_save_7",
	"ui_save_8",
	"ui_save_9",
	"ui_save_10",
	"ui_save_11",
	"ui_save_12",
	"ui_save_13",
	"ui_save_14",
	"ui_save_15",
	"ui_save_16",
	"ui_save_17",
	"ui_save_18",
	"ui_save_19",
	"ui_save_20",
	"ui_save_21",
	"ui_save_22",
	"ui_save_23",
	"ui_save_24",
	"ui_save_mm",
	"ui_save_mm",
	"ui_save_mm",
	"ui_save_mm",
	"ui_save_mm",
	"ui_save_mm",
	"ui_save_mm",
	"ui_save_mm",
	"ui_save_mm",
	"ui_save_mm",
	"ui_save_mm",
	"ui_save_mm",
	"ui_save_mm",
	"ui_save_mm",
	"ui_save_mm",
	"ui_save_mm",
	"ui_save_mm",
	"ui_save_mm",
	"ui_save_mm",
	"ui_save_mm",
	"ui_save_mm",
	"ui_save_mm",
	"ui_save_mm",--"MISSION_NAME_SH01",
	"ui_save_mm",--"MISSION_NAME_SH02",
	"ui_save_mm",--"MISSION_NAME_SH03",
	"ui_save_mm",--"MISSION_NAME_SH04",
}

function pause_save_game_init()
	Save_load_doc = vint_document_find("pause_save_game")
	
	save_system_set_operation(Save_system_operation)

	Pause_Respect_meter = Vdo_respect_meter:new("respect_meter", 0, 0, "pause_save_game.lua", "Pause_Respect_meter")	
	Pause_District_meter = Vdo_city_control:new("control_meter", 0, 0, "pause_save_game.lua", "Pause_District_meter")
	
	Save_load_list = Vdo_mega_list:new("list",0,Save_load_doc)
	Save_load_list:set_highlight_color(COLOR_STORE_REWARDS_PRIMARY, COLOR_STORE_REWARDS_SECONDARY)
	
	Save_load_stat_grp = vint_object_find("save_stats_group",0,Save_load_doc)
	
	-- Subscribe to the button presses we need
	Input_tracker = Vdo_input_tracker:new()
		
	local header_str = ""
	if (Save_system_operation == SAVE_OPERATION_LOAD_GAME) then
		Input_tracker:add_input("select", "load_button_a", 50)
		header_str = "SAVELOAD_LOAD_GAME"
	else 
		Input_tracker:add_input("select", "save_button_a", 50)
		header_str = "SAVELOAD_SAVE_GAME"
	end
	
	Input_tracker:add_input("back", "save_load_button_b", 50)
	Input_tracker:add_input("alt_select", "save_load_button_x", 50)
	if game_get_platform() == "PC" then
		Input_tracker:add_input("scancode", "save_load_button_y", 50, false, 211) --'del' key
		Input_tracker:add_input("gamepad_y", "save_load_button_y", 50)
	else
		Input_tracker:add_input("exit", "save_load_button_y", 50)
	end

	if In_pause_menu then
		Input_tracker:add_input("pause", "save_load_button_start", 50)
	end	
	Input_tracker:add_input("nav_up", "save_load_nav_up", 50)
	Input_tracker:add_input("nav_down", "save_load_nav_down", 50)
	Input_tracker:subscribe(false)
	
	-- Add mouse inputs for the PC
	if game_get_platform() == "PC" then
		Mouse_input_tracker = Vdo_input_tracker:new()
		Hint_bar_mouse_input_tracker = Vdo_input_tracker:new()
		Menu_hint_bar:set_highlight(0)
		-- Hint bar and list inputs added elsewhere
	
		Hint_bar_mouse_input_tracker:subscribe(false)
		Mouse_input_tracker:subscribe(false)
	end

	--Initialize Header
	local ctrl_header_obj = Vdo_pause_header:new("header", 0, Save_load_doc)
	ctrl_header_obj:set_text(header_str)
	ctrl_header_obj:set_text_scale(1)

	SAVE_LOAD_WIDTH = 800 * 3
	--Store some locals to the pause menu common for screen processing.
	menu_common_set_list_style(List, Header_obj, SAVE_LOAD_WIDTH)
	
	Header_obj:set_visible(false)
	List:set_visible(false)
	
	save_load_refresh(false)
	
	local pause_screen_in_anim = Vdo_anim_object:new("save_back_in_anim", 0, Save_load_doc)
	--if in pause menu act normal
	if In_pause_menu then
		menu_common_set_screen_data(List, Header_obj, Input_tracker, Screen_back_out_anim, Screen_slide_out_anim)
		
		local mask_h = vint_object_find("screen_mask", 0, Save_load_doc)
		local mask_x,mask_y = vint_get_property(mask_h, "anchor")
		save_load_mask_morph(BG_TYPE_STRONGHOLD, SAVE_LOAD_WIDTH, mask_x)
	
		pause_screen_in_anim:play(0)
	else
		--slide in the screen from the left we are on the main menu
		if First_time then
			pause_screen_in_anim = Vdo_anim_object:new("save_slide_in_anim", 0, Save_load_doc)
			Screen_in_anim:play(0)
			bg_saints_slide_in(SAVE_LOAD_WIDTH)
			First_time = false
			menu_common_set_screen_data(List, Header_obj, Input_tracker, Screen_back_out_anim, Screen_out_anim)
		else
			Slide_out = false
			menu_common_set_screen_data(List, Header_obj, Input_tracker, Screen_back_out_anim, Screen_slide_out_anim)
		
			--get the list x and y
			local new_x
			local middle_x
			if vint_is_std_res() == false then
				middle_x = 640 * 3
			else
				middle_x = (320 * 1.5) * 3
			end
			new_x = middle_x - (SAVE_LOAD_WIDTH * 0.5)
			local mask_start_x = middle_x + (SAVE_LOAD_WIDTH * 0.5)
			
			local mask_anchor_twn = vint_object_find("ctrl_mask_anchor_twn", 0, Save_load_doc)
			local mask_x,mask_y = vint_get_property(mask_anchor_twn,"start_value")
			vint_set_property(mask_anchor_twn,"start_value", mask_start_x, mask_y)
			
			bg_saints_set_type(BG_TYPE_CENTER, true, SAVE_LOAD_WIDTH)
			save_load_set_slide_in_values( new_x )
			save_load_mask_morph(BG_TYPE_CENTER, SAVE_LOAD_WIDTH, new_x)
		end
		pause_screen_in_anim:play(0)
	end
	
	save_load_set_header()
end

function save_load_image_done()
	local save_image_h = vint_object_find("save_image", 0, Save_load_doc)
	vint_set_property(save_image_h,"image",Save_load_image)
	vint_set_property(save_image_h,"visible",true)
end

function save_game_populate(handle, is_loadable, is_autosave, is_cheat, description, percent, time_played, time_stamp, difficulty, missions_completed, districts_owned, cash, rank, current_respect_pct, total_respect, district_control_pct, last_mission_id)
	Num_saves = Num_saves + 1

	if handle == ID_NEW_SAVE_GAME or handle == ID_NO_GAMES then
		if handle == ID_NEW_SAVE_GAME then
			Save_load_data[Num_saves] = 
				{ type = TYPE_ROW, label_1 = "SAVELOAD_NEW_SAVE_GAME", save_id = ID_NEW_SAVE_GAME,
				  label_2 = "", label_3 = "", label_4 = "" }
		else	
			Save_load_data[Num_saves] = 
				{ type = TYPE_ROW, label_1 = "SAVELOAD_NOTHING_TO_LOAD", save_id = ID_NO_GAMES,
				  label_2 = "", label_3 = "", label_4 = "", show_button = false }
		end
		return
	end
	
	local played_hours = floor(time_played / 60)
	local played_mins = floor(time_played - (played_hours * 60))
	local game_time
	
	if played_mins > 9 then
		game_time = ""..played_hours..":"..played_mins
	else
		game_time = ""..played_hours..":0"..played_mins
	end
	
	Save_load_data[Num_saves] = {
		type = TYPE_ROW,
		--Info for displaying the Vdo_pause_row
		label_1 = description,
		label_2 = percent .. "%%",
		label_3 = game_time,
		label_4 = time_stamp,	
		
		--Data used by this script...
		has_data = true,
		save_id = handle,
		description = description,
		is_loadable = is_loadable,
		missions_completed = missions_completed, 
		districts_owned = districts_owned,
		is_cheat = is_cheat, 
		game_time = game_time, 
		difficulty = difficulty, 
		is_autosave = is_autosave, 
		percent = percent .. "%%",
		cash = "$" .. cash,
		rank = rank,
		current_respect_pct = current_respect_pct,
		total_respect = total_respect,
		district_control_pct = district_control_pct,
		last_mission_id = last_mission_id,
	}

end

function pause_save_game_cleanup()
	if Save_load_current_image ~= nil then
		game_peg_unload(Save_load_current_image)
	end		
	if Save_load_unload_img ~= nil then
		game_peg_unload(Save_load_unload_img)
	end
	if Save_load_image ~= nil then
		game_peg_unload(Save_load_image)
	end
	
	-- Nuke all button subscriptions
	Input_tracker:subscribe(false)
	if Mouse_input_tracker ~= 0 then
		Mouse_input_tracker:subscribe(false)
		Hint_bar_mouse_input_tracker:subscribe(false)
	end
			
	Header_obj:set_visible(true)
	List:set_visible(true)
		
	-- DAD - 6/16/11 - DO NOT REMOVE, this will break PS3 load game if you don't do this.
	save_game_wrap_up()
end

function device_selected()
	Device_selected = true
end

function save_load_lock_input(locked)
	Input_tracker:subscribe(not locked)
	
	if  Mouse_input_tracker ~= 0 then
		Mouse_input_tracker:subscribe(not locked)
		Hint_bar_mouse_input_tracker:subscribe(not locked)
	end
end

function save_load_nav_up(event, acceleration)
	-- Move highlight up
	Save_load_list:move_cursor(-1)
	save_load_set_header()
	save_load_set_hints_on_nav()
	if Mouse_input_tracker ~= 0 then
		Save_load_list:set_mouse_highlight(-1)
		Save_load_list:update_mouse_inputs("save_load", Mouse_input_tracker)
	end
end

function save_load_nav_down(event, acceleration)
	-- Move highlight down
	Save_load_list:move_cursor(1)
	save_load_set_header()
	save_load_set_hints_on_nav()
	if Mouse_input_tracker ~= 0 then
		Save_load_list:set_mouse_highlight(-1)
		Save_load_list:update_mouse_inputs("save_load", Mouse_input_tracker)
	end
end

function save_button_a(event, acceleration)
	if not Device_selected then
		return
	end
	
	local current_button = Save_load_list:get_selection()
	local data = Save_load_data[current_button]
	if not data then
		return
	end
	
	if data.save_id == ID_NO_GAMES then
		return
	end
	
	save_load_lock_input(true)
	save_system_save_game(data.save_id)
end

function load_confirm(result, action)
	if result == 0 then
		Input_tracker:subscribe(false)
		if Load_for_coop == true then
			if Main_menu_coop_is_xbox_live then
				game_coop_start_new_live()
			else 
				game_coop_start_new_syslink()
			end
		end	
		save_system_load_game(Save_id)
	else	
		Input_tracker:subscribe(true)
	end
end

function load_button_a(event, acceleration)
	if not Device_selected then
		return
	end
	
	local current_button = Save_load_list:get_selection()
	local data = Save_load_data[current_button]
	if not data then
		return
	end

	if data.save_id == ID_NO_GAMES then
		return
	end
	
	if In_pause_menu == false then
		game_UI_audio_play("UI_Main_Menu_Select")	
		Save_id = data.save_id
		load_confirm(0, 0)
	else 
		Save_id = data.save_id
		dialog_box_destructive_confirmation("SAVELOAD_LOAD_GAME", "SAVELOAD_LOAD_GAME_CONFIRM_EXPOSITION", "load_confirm")
		Input_tracker:subscribe(false)
	end
	
	Is_Forced_Exit = false
end

function save_load_refresh(dont_unsubscribe_inputs)
	if dont_unsubscribe_inputs == false then
		Input_tracker:subscribe(false) --Nuke button subscription, will resubscribe after list redraws...
		if Mouse_input_tracker ~= 0 then
			Mouse_input_tracker:remove_all()
		end
	end

	-- Empty save game list to start until code flags an update
	Save_load_data = {}
	Save_load_data.row_alignment = {ALIGN_LEFT, ALIGN_RIGHT, ALIGN_RIGHT, ALIGN_RIGHT}
	Save_load_data.row_column_count = 4
	
	Save_load_list:set_visible(false)

	Num_saves = 0
	vint_dataresponder_request("save_system_populate", "save_game_populate", 0, Save_system_operation)
	Save_load_list:set_properties(nil, nil, Save_load_max_visible, .9, SAVE_LOAD_WIDTH, false, true)
	Save_load_list:draw_items(Save_load_data, 1)	
	Save_load_list:set_visible(true)
	save_load_set_hints_on_nav()

	local col_1_x, col_2_x, col_3_x, col_4_x = Save_load_list:row_get_column_positions()
	save_load_align_header_columns(col_1_x, col_2_x, col_3_x, col_4_x)
	save_load_set_header()
	
	Input_tracker:subscribe(true)
	if Mouse_input_tracker ~= 0 then
		save_load_reset_mouse_inputs(false)
	end
end

function save_load_button_x(event, acceleration)
end

function save_load_delete_cb(result, action)
	if result == 0 then
		save_system_delete_game(Save_id)
	else
		Input_tracker:subscribe(true)
	end
end

function save_load_button_y(event, acceleration)
	if not Device_selected then
		return
	end
	
	local current_button = Save_load_list:get_selection()
	local data = Save_load_data[current_button]
	if not data then
		return
	end

	if data.save_id == ID_NO_GAMES then
		return
	end
		
	if data.save_id == ID_NEW_SAVE_GAME then
		return
	end
	
	Save_id = data.save_id
	dialog_box_confirmation("MENU_TITLE_WARNING", "MENU_DELETE_SAVE", "save_load_delete_cb",nil,nil,1)
	Input_tracker:subscribe(false)
end

function save_load_button_b(event, acceleration)
	-- If the load was initiated from coop, then make sure we tell coop we're not loading.
	if Load_for_coop == true then
		save_system_cancel_coop_load()
		Input_tracker:subscribe(false)
		if Mouse_input_tracker ~= 0 then
			Mouse_input_tracker:subscribe(false)
			Hint_bar_mouse_input_tracker:subscribe(false)
		end
		Load_for_coop = false	-- reset the variable
	end
	
	if Exit_after_closing == true then
		pause_menu_quit_game_internal()
		Exit_after_closing = false
		Close_all_menu = false
	elseif Close_all_menu == true then
		Input_tracker:subscribe(false)
		menu_common_transition_pop(3)
		if Mouse_input_tracker ~= 0 then
			Mouse_input_tracker:subscribe(false)
			Hint_bar_mouse_input_tracker:subscribe(false)
		end
		Exit_after_closing = false		-- reset
		Close_all_menu = false			-- reset
		return
	else
		--Remove current menu from the stack
		Input_tracker:subscribe(false)
		menu_common_stack_remove()
		menu_common_transition_pop(1)
		if In_pause_menu then
			Save_load_list:set_visible(true)
		end
		
		if Mouse_input_tracker ~= 0 then
			Mouse_input_tracker:subscribe(false)
			Hint_bar_mouse_input_tracker:subscribe(false)
		end
	end
	
	if not In_pause_menu then
		if Slide_out then
			bg_saints_slide_out()
			local anim = Vdo_anim_object:new("save_slide_in_anim", 0, Save_load_doc)
			local twn_h = vint_object_find("save_screen_anchor", 0, Save_load_doc)
			local twn_start_x,twn_start_y = vint_get_property(twn_h,"start_value")
			local twn_end_x,twn_end_y = vint_get_property(twn_h,"end_value")
			vint_set_property(twn_h,"start_value",twn_end_x,twn_end_y)
			vint_set_property(twn_h,"end_value",-900 * 3,twn_start_y)
			anim:play(0)
		end 
	end
	
	Is_Forced_Exit = false
end

function save_load_button_start(event, acceleration)
	if Exit_after_closing == true then
		pause_menu_quit_game_internal()
	else
		local screen_grp_h = vint_object_find("screen_grp", 0, Save_load_doc)
	
		local screen_out_anim_h = vint_object_find("screen_out_anim", 0, Save_load_doc)
		lua_play_anim(screen_out_anim_h, 0, Save_load_doc)
		
		menu_common_set_screen_data(List, Header_obj, Input_tracker, Screen_back_out_anim, Screen_out_anim, pause_menu_top_anim_in_done)

		bg_saints_slide_out()
		
		menu_common_transition_pop(3)	-- save_load, pause_menu_top, menu_common
	end
end

function save_load_set_button_hints(show_delete)
	--Set Button hints
	local hint_data
	if game_get_platform() == "PS4" or game_get_platform() == "XBOX3" then
		hint_data = {
			{CTRL_MENU_BUTTON_B, "MENU_BACK"},
		}
		
		if show_delete then 
			hint_data[2] = {CTRL_BUTTON_Y, "MENU_OPTIONS_DELETE", game_get_key_name(211)} --"del"
		end
	elseif game_get_platform() == "PC" then
		hint_data = {
			{CTRL_MENU_BUTTON_B, "MENU_BACK"},
		}
		
		if show_delete then 
			hint_data[2] = {CTRL_BUTTON_Y, "MENU_OPTIONS_DELETE", game_get_key_name(211)} --"del"
			if Save_system_operation == SAVE_OPERATION_LOAD_GAME then
				hint_data[3] = {CTRL_MENU_BUTTON_A, "COOP_LOAD_OLD_TEXT", game_get_key_name(28)}
			else
				hint_data[3] = {CTRL_MENU_BUTTON_A, "TRIGGER_SAVE", game_get_key_name(28)}
			end
		else
			if Save_system_operation == SAVE_OPERATION_LOAD_GAME then
				hint_data[2] = {CTRL_MENU_BUTTON_A, "COOP_LOAD_OLD_TEXT", game_get_key_name(28)}
			else
				hint_data[2] = {CTRL_MENU_BUTTON_A, "TRIGGER_SAVE", game_get_key_name(28)}
			end
		end
	end
	Menu_hint_bar:set_hints(hint_data) 
	Menu_hint_bar:set_visible(true)
	Menu_hint_bar:set_alpha(1.0)	
end

function save_load_set_header()
	local current_button = Save_load_list:get_selection()
	local data = Save_load_data[current_button]
	
	local save_image_h = vint_object_find("save_image", 0, Save_load_doc)
	vint_set_property(save_image_h, "visible", false)
	
	if not data or data.has_data ~= true then
		if Save_load_image == nil then
			local new_image = Pause_save_images[#Pause_save_images]
			if Save_load_current_image ~= nil then
				game_peg_unload(Save_load_current_image)
			end
			if new_image ~= nil then
				-- must set save_load_loading_img before calling game_peg_load_with_cb(), which could fire the callback right away
				Save_load_image = new_image                             
				game_peg_load_with_cb("save_load_show_image", 1, new_image)
			end
		end
		vint_set_property(Save_load_stat_grp,"visible",false)
		return
	end
	
	--sets the new save file image
	--Save_load_image = data.image
	--game_peg_load_with_cb("save_load_image_done", 1, Save_load_image)
		
	local time_h = vint_object_find("time_value",0,Save_load_doc)
	local completion_h = vint_object_find("completion_value",0,Save_load_doc)
	local difficulty_h = vint_object_find("difficulty_value",0,Save_load_doc)
	local missions_h = vint_object_find("missions_value",0,Save_load_doc)
	local cash_h = vint_object_find("cash_value",0,Save_load_doc)
	local save_cheat_text_h = vint_object_find("save_cheat_text",0,Save_load_doc)
	
	vint_set_property(time_h,"text_tag",data.game_time)
	vint_set_property(completion_h,"text_tag",data.percent)
	vint_set_property(difficulty_h,"text_tag",data.difficulty)
	vint_set_property(missions_h,"text_tag",data.missions_completed)
	vint_set_property(cash_h,"text_tag",data.cash)
	
	vint_set_property(save_cheat_text_h, "visible", data.is_cheat)

	Pause_Respect_meter:reset_first_update()
	Pause_Respect_meter:update_respect(data.total_respect, data.current_respect_pct, data.rank, false)

	Pause_District_meter:update(data.district_control_pct)
	
	vint_set_property(Save_load_stat_grp,"visible",true)
	
	
	
	if Save_load_image == nil then
		local mission = data.last_mission_id
		if mission < 0 or mission == nil or mission > #Pause_save_images then
			mission = #Pause_save_images
		else	
			mission = data.last_mission_id + 1
		end
		local new_image = Pause_save_images[mission]
		if Save_load_current_image ~= nil then
			game_peg_unload(Save_load_current_image)
		end
		if new_image ~= nil then
			-- must set save_load_loading_img before calling game_peg_load_with_cb(), which could fire the callback right away
			Save_load_image = new_image                             
			game_peg_load_with_cb("save_load_show_image", 1, new_image)
		end
	end
end

-- Callback for when an image is done loading.
-- SEH: It might make sense to roll this into vdo_bitmap_viewer...
--
function save_load_show_image()
	local current_button = Save_load_list:get_selection()
	local data = Save_load_data[current_button]
	
	local new_image
	local mission = data.last_mission_id
	if mission == nil then
		new_image = "ui_save_0"
	elseif mission < 0 or mission > #Pause_save_images then
		new_image = Pause_save_images[#Pause_save_images]
	else	
		mission = data.last_mission_id + 1
		new_image = Pause_save_images[mission]
	end
	
	local save_image_h = vint_object_find("save_image", 0, Save_load_doc)
	 
	if Save_load_image == new_image then
		vint_set_property(save_image_h, "visible", true)
		vint_set_property(save_image_h, "image", new_image)
		Save_load_image = nil
		Save_load_current_image = new_image
	else
		-- a new image was picked while we were loading - load this now, and unload the one we just loaded
		if new_image ~= nil then
			Save_load_unload_img = Save_load_image
			Save_load_image = new_image
			Save_load_image_update_thread = thread_new("save_load_image_update")          
		else
			game_peg_unload(Save_load_image)
			Save_load_image = nil
		end
	end
end

function save_load_image_update()
	 delay(0.2)
	 game_peg_unload(Save_load_unload_img) 
	 game_peg_load_with_cb("save_load_show_image", 1, Save_load_image)
	 Save_load_image_update_thread = -1
end

function save_load_set_hints_on_nav()
	local current_button = Save_load_list:get_selection()
	local data = Save_load_data[current_button]
	if not data then
		save_load_set_button_hints(false)
		return
	end
	
	if not data or data.save_id == ID_NEW_SAVE_GAME or data.save_id == ID_NO_GAMES then
		save_load_set_button_hints(false)
	else
		save_load_set_button_hints(true)
	end
	save_load_reset_mouse_inputs(true)
end

-- Mouse inputs
function save_load_mouse_click(event, target_handle, mouse_x, mouse_y)
	
	local hint_index = Menu_hint_bar:get_hint_index(target_handle)
	if hint_index == 1 then
		save_load_button_b()
	end
	if hint_index == 2 then
		if Save_system_operation == SAVE_OPERATION_SAVE_GAME then
			local current_button = Save_load_list:get_selection()
			if current_button == 1 then
				save_button_a()
			else
				save_load_button_y()
			end
		else
			save_load_button_y()
		end
	end
	if hint_index == 3 then
		if Save_system_operation == SAVE_OPERATION_SAVE_GAME then
			save_button_a()
		else
			load_button_a()
		end
	end

	local new_index = Save_load_list:get_button_index(target_handle)
	if new_index ~= 0 then
		Save_load_list:set_selection(new_index)
		Save_load_list:move_cursor(0, true)
		save_load_set_header()
		save_load_set_hints_on_nav()
		--[[if (Save_system_operation == SAVE_OPERATION_LOAD_GAME) then
			load_button_a()
		else
			save_button_a()
		end]]
	end
end

function save_load_mouse_move(event, target_handle)
	Menu_hint_bar:set_highlight(0)
	
	local hint_index = Menu_hint_bar:get_hint_index(target_handle)
	if hint_index ~= 0 then
		Menu_hint_bar:set_highlight(hint_index)
	end
	
	local new_index = Save_load_list:get_button_index(target_handle)
	Save_load_list:set_mouse_highlight(new_index)
end

function save_load_mouse_scroll(event, target_handle, mouse_x, mouse_y, scroll_lines)
	if scroll_lines ~= 0 then
		if Save_load_list:get_scroll_region_handle() == target_handle then
			Save_load_list:scroll_list(scroll_lines * -1)
			save_load_reset_mouse_inputs(false)
		end
	end
end

function save_load_mouse_drag(event, target_handle, mouse_x, mouse_y)
	if Save_load_list.scrollbar.tab.handle == target_handle then
		local new_start_index = Save_load_list.scrollbar:drag_scrolltab(mouse_y, Save_load_list.num_buttons - (Save_load_list.max_buttons - 1))
		Save_load_list:scroll_list(0, new_start_index)
	end
end

-- Updates the mouse inputs for the list and snaps the scrolltab to the closest notch based on the visible index
--
function save_load_mouse_drag_release(event, target_handle, mouse_x, mouse_y)
	if Save_load_list.scrollbar.tab.handle == target_handle then
		local start_index = Save_load_list:get_visible_indices()
		Save_load_list.scrollbar:release_scrolltab(start_index, Save_load_list.num_buttons - (Save_load_list.max_buttons - 1))
		save_load_reset_mouse_inputs(false)
	end
end

function save_load_reset_mouse_inputs(hint_only)
	if Mouse_input_tracker ~= 0 then
		if hint_only == false then
			Mouse_input_tracker:remove_all()
			Save_load_list:add_mouse_inputs("save_load", Mouse_input_tracker)
			Mouse_input_tracker:subscribe(true)
		end
		Hint_bar_mouse_input_tracker:remove_all()
		Menu_hint_bar:add_mouse_inputs("save_load", Hint_bar_mouse_input_tracker)
		Hint_bar_mouse_input_tracker:subscribe(true)
	end
end

function save_load_mask_morph( screen_type, size_end_x, anchor_end_x )
	--get handles for everyone
	local mask_h = vint_object_find("screen_mask", 0, Save_load_doc)
	local morph_anim_h = vint_object_find("save_mask_anim", 0, Save_load_doc)
	local morph_scale_twn_h = vint_object_find("save_mask_scale_twn", 0, Save_load_doc)
	local morph_anchor_twn_h = vint_object_find("save_mask_anchor_twn", 0, Save_load_doc) 
	
	--setup the anchor for the mask
	--get the starting x position
	local mask_anchor_start_x,mask_anchor_start_y = vint_get_property( mask_h, "anchor" )
	vint_set_property(morph_anchor_twn_h, "start_value", mask_anchor_start_x, mask_anchor_start_y )
	vint_set_property(morph_anchor_twn_h, "end_value", anchor_end_x, mask_anchor_start_y )
	
	--setup the scale of the mask
	--get the starting scale
	local size_start_x,size_start_y = vint_get_property(mask_h,"scale")
	--get the correct size, this fixes SD scale issues
	if vint_is_std_res() == true then
		size_end_x = size_end_x + (28 * 3)
	end
	local adjusted_size_end_x,crap = element_get_scale_from_size(mask_h, size_end_x, 16 * 3)
	vint_set_property(morph_scale_twn_h, "start_value", size_start_x , size_start_y)
	vint_set_property(morph_scale_twn_h, "end_value", adjusted_size_end_x, size_start_y)
	
	--play the animation
	lua_play_anim(morph_anim_h, 0, Save_load_doc)	
end

function save_load_set_slide_in_values( new_x )

	local header_anchor_twn_h = vint_object_find("save_header_back_anchor", 0, Save_load_doc) 
	local list_anchor_twn_h = vint_object_find("save_list_back_anchor", 0, Save_load_doc) 
	local row_anchor_twn_h = vint_object_find("save_row_back_anchor", 0, Save_load_doc)
	local image_anchor_twn_h = vint_object_find("save_image_back_anchor", 0, Save_load_doc) 
	local stats_anchor_twn_h = vint_object_find("save_stats_back_anchor", 0, Save_load_doc) 
	
	local header_x,header_y = vint_get_property(header_anchor_twn_h, "end_value")
	local list_x,list_y = vint_get_property(list_anchor_twn_h, "end_value")
	local row_x,row_y = vint_get_property(row_anchor_twn_h, "end_value")
	local image_x,image_y = vint_get_property(image_anchor_twn_h, "end_value")
	local stats_x,stats_y = vint_get_property(stats_anchor_twn_h, "end_value")
	
	local ctrl_offset = 46 * 3
	local header_offset = 30 * 3
	local list_offset = 0
	local row_offset = 6*3
	local image_offset = 0
	local stats_offset = 372 * 3
	if vint_is_std_res() == true then
		ctrl_offset = 75 * 3
		header_offset = 60 * 3
		list_offset = 28 * 3
		row_offset = -28 * 3
		image_offset = 28 * 3
		stats_offset = 400 * 3
	end
	
	vint_set_property(header_anchor_twn_h, "end_value", new_x + header_offset, header_y)
	vint_set_property(list_anchor_twn_h, "end_value", new_x + list_offset, list_y)
	vint_set_property(row_anchor_twn_h, "end_value", new_x - row_offset, row_y)
	vint_set_property(image_anchor_twn_h, "end_value", new_x + image_offset, image_y)
	vint_set_property(stats_anchor_twn_h, "end_value", new_x + stats_offset, stats_y)
end


function save_load_align_header_columns(col_1, col_2, col_3, col_4)
	local mission_name_label_h = vint_object_find("mission_name_label", 	0, Save_load_doc)
	local date_label_h 			= vint_object_find("date_label", 			0, Save_load_doc)
	local completion_label_h 	= vint_object_find("completion_label", 	0, Save_load_doc)
	local time_label_h 			= vint_object_find("time_label", 			0, Save_load_doc)
	
	local shift_x = 8*3
	local x, y = vint_get_property(mission_name_label_h, "anchor")
	vint_set_property(mission_name_label_h, "anchor", col_1 + shift_x, y)
	
	x, y = vint_get_property(completion_label_h, "anchor")
	vint_set_property(completion_label_h, "anchor", col_2 + shift_x, y)
	
	x, y = vint_get_property(time_label_h, "anchor")
	vint_set_property(time_label_h, "anchor", col_3 + shift_x, y)
	
	x, y = vint_get_property(date_label_h, "anchor")
	vint_set_property(date_label_h, "anchor", col_4 + shift_x, y)
end

function save_load_ps3_complete(success, should_exit_menu)
	if Load_for_coop == true then
		if success == true then
			if Main_menu_coop_is_xbox_live then
				game_coop_start_new_live()
			else 
				game_coop_start_new_syslink()
			end
		else 
			save_system_cancel_coop_load()
		end
	end

	if should_exit_menu == false then
		return
	end
	
	if Exit_after_closing == true then
		pause_menu_quit_game_internal()
	elseif Close_all_menu == true then
		menu_common_stack_remove()
		menu_common_transition_pop(3)
		Save_load_list:set_visible(true)
		
		if Mouse_input_tracker ~= 0 then
			Mouse_input_tracker:subscribe(false)
			Hint_bar_mouse_input_tracker:subscribe(false)
		end
	else
		--Remove current menu from the stack
		menu_common_stack_remove()
		menu_common_transition_pop(1)
		Save_load_list:set_visible(true)
		
		if Mouse_input_tracker ~= 0 then
			Mouse_input_tracker:subscribe(false)
			Hint_bar_mouse_input_tracker:subscribe(false)
		end
	end
	if not In_pause_menu then
		if Slide_out then
			bg_saints_slide_out()
			local anim = Vdo_anim_object:new("save_slide_in_anim", 0, Save_load_doc)
			local twn_h = vint_object_find("save_screen_anchor", 0, Save_load_doc)
			local twn_start_x,twn_start_y = vint_get_property(twn_h,"start_value")
			local twn_end_x,twn_end_y = vint_get_property(twn_h,"end_value")
			vint_set_property(twn_h,"start_value",twn_end_x,twn_end_y)
			vint_set_property(twn_h,"end_value",-900 * 3,twn_start_y)
			anim:play(0)
		end
	end
end

function pause_save_game_exited()
	if Is_Forced_Exit == true then
		menu_common_transition_pop(0)
	end

	Is_Forced_Exit = true
endts_'0