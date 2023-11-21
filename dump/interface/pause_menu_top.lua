-- Globals
-- These are from mission_info.h
local MT_MISSION_NONE 		= -1
local MT_MISSION 				= 0
local MT_ACTIVITY				= 1
local MT_SILENT				= 2
local MT_STRONGHOLD			= 3
local	MT_DIVERSION_ACTIVE	= 4

local HORDE_RETRY_INDEX	= 2
local HORDE_NEW_INDEX	= 3

local ID_SAVE_GAME		= 1
local ID_LOAD_GAME		= 2
local ID_OPTIONS			= 3
local ID_CO_OP				= 4
local ID_QUIT_GAME		= 5
local ID_HORDE_RETRY		= 6
local ID_HORDE_NEW		= 7
local ID_CANCEL_MISSION	= 8
local ID_RECORD_MODE		= 9
local ID_CASUAL_RECORD_MODE = 10
local ID_PLAYBACK_MODE	= 11

local Quit_message_normal = "QUIT_GAME_TEXT_FULL"
local Quit_message_horde = "HORDE_MODE_QUIT_TEXT"

local Quit_message

local Data
local Save_button = {
	type = TYPE_BUTTON,
	label = "SAVELOAD_SAVE_GAME",
	id = ID_SAVE_GAME,
}

local Load_button = {
	type = TYPE_BUTTON,
	label = "SAVELOAD_LOAD_GAME",
	id = ID_LOAD_GAME,
}

local Options_button = {
	type = TYPE_BUTTON,
	label = "PAUSE_MENU_OPTIONS",
	id = ID_OPTIONS,
}

local Coop_button = {
	type = TYPE_BUTTON,
	label = "PAUSE_MENU_COOP",
	id = ID_CO_OP,
}

local Record_button = {
	type = TYPE_BUTTON,
	label = "PAUSE_MENU_RECORD_MODE",
	id = ID_RECORD_MODE,
}

local Casual_record_button = {
	type = TYPE_BUTTON,
	label = "MENU_VIDEO_RECORD_MODE",
	id = ID_CASUAL_RECORD_MODE,
}

local Playback_button = {
	type = TYPE_BUTTON,
	label = "PAUSE_MENU_PLAYBACK_MODE",
	id = ID_PLAYBACK_MODE,
}

local Quit_button = {
	type = TYPE_BUTTON,
	label = "HORDE_MODE_MENU_EXIT",
	id = ID_QUIT_GAME,
}

local Horde_retry_button = {
	type = TYPE_BUTTON,
	id = ID_HORDE_RETRY,
	label = "HORDE_MODE_MENU_RETRY"
}

local Horde_new_button = {
	type = TYPE_BUTTON,
	id = ID_HORDE_NEW,
	label = "HORDE_MODE_MENU_NEW_GAME"
}

local Cancel_button = {
	type = TYPE_BUTTON,
	id = ID_CANCEL_MISSION,
	label = "HUD_CANCEL_MISSION",
}

local Anims = {}

local Input_tracker
local Mouse_input_tracker
local Online_check_thread = -1

local Screen_width = 495*3
local Tween_done = true

local Checking_dlc = false

--------------------------------------------------------------------------- 
-- Initialize Pause Menu Top (First Level of Pause Menu)
---------------------------------------------------------------------------
function pause_menu_top_init()
	-- Subscribe to the button presses we need
	
	Input_tracker = Vdo_input_tracker:new()
	Input_tracker:add_input("select", "pause_menu_top_button_a", 50)
	Input_tracker:add_input("pause", "pause_menu_top_button_b", 50)
	Input_tracker:add_input("back", "pause_menu_top_button_b", 50)
	Input_tracker:add_input("nav_up", "pause_menu_top_nav_up", 50)
	Input_tracker:add_input("nav_down", "pause_menu_top_nav_down", 50)
	Input_tracker:add_input("nav_left", "pause_menu_top_nav_left", 50)
	Input_tracker:add_input("nav_right", "pause_menu_top_nav_right", 50)
	Input_tracker:subscribe(false)

	--Initialize Header
	Header_obj:set_text("SYSTEM_PAUSED", Screen_width) --("MENU_GAME_PAUSED")

	-- Clear pause menu and build a new one
	Data = {}
	
	if horde_mode_is_active() == false then
		local save_is_enabled = game_machinima_is_recording() == false
		if game_get_platform() == "XBOX3" and game_is_signed_in() == false then
			save_is_enabled = false
		end
		if save_is_enabled then
			Data[#Data+1] = Save_button
			Data[#Data+1] = Load_button
		end
		
		local gameplay_type = game_get_in_progress_type()
		local cancel_button_tag = nil
		if gameplay_type == MT_MISSION then
			cancel_button_tag = "HUD_CANCEL_MISSION"
		elseif gameplay_type == MT_ACTIVITY then
			cancel_button_tag = "HUD_CANCEL_ACTIVITY"
		elseif gameplay_type == MT_STRONGHOLD then
			cancel_button_tag = "HUD_CANCEL_STRONGHOLD"
		elseif gameplay_type == MT_DIVERSION_ACTIVE then
			cancel_button_tag = "HUD_CANCEL_DIVERSION"
		end

		if cancel_button_tag then
			Data[#Data+1] = Cancel_button
			Cancel_button.label = cancel_button_tag
			if pause_menu_cant_retry_because_host_in_creation() then
				Cancel_button.disabled = true
			end
		end
		
		Data[#Data+1] = Options_button

		if game_get_is_host() == false and cancel_button_tag ~= nil then
			Load_button.disabled = true
		end
		
		if game_machinima_is_recording() == false and game_is_drm_free() == false then
			Data[#Data+1] = Coop_button
		end

		if game_record_mode_is_supported() then
			Data[#Data+1] = Casual_record_button
			--[[if game_machinima_is_recording() == true then
				Data[#Data+1] = Playback_button;
			else
				Data[#Data+1] = Record_button;
			end]]
		end

		Data[#Data+1] = Quit_button
		
		Quit_message = Quit_message_normal
	else 
		Data[#Data+1] = Options_button
		
		if game_get_is_host() then
			Data[#Data+1] = Horde_retry_button
			Data[#Data+1] = Horde_new_button
		end
		
		if game_record_mode_is_supported() then
			Data[#Data+1] = Casual_record_button
		end
		
		Data[#Data+1] = Quit_button
		
		if coop_is_active() then
			Quit_message = Quit_message_horde
		else
			Quit_message = Quit_message_normal
		end
	end
	
	--Setup button hints
	local hint_data = {
		{CTRL_MENU_BUTTON_B, "MENU_BACK"},
	}
	Menu_hint_bar:set_hints(hint_data)
	
	--Get the selection option from when the menu was last loaded
	local last_option_selected = menu_common_stack_get_index(Data)
	
	--this HACK stinks, we should get the longest string width back and adjust for that
	if game_get_language() == "DE" then
		Screen_width = 680*3
	end
	
	-- Initialize and draw list object
	List:draw_items(Data, last_option_selected, Screen_width)	
	
	--Store some locals to the pause menu common for screen processing.
	menu_common_set_list_style(List, Header_obj, Screen_width)
	menu_common_set_screen_data(List, Header_obj, Input_tracker, Screen_back_out_anim, Screen_out_anim, pause_menu_top_anim_in_done)
	
	
	-- Add mouse input subscriptions for the PC
	if game_get_platform() == "PC" then
		Menu_hint_bar:set_highlight(0)
	
		Mouse_input_tracker = Vdo_input_tracker:new()
		List:add_mouse_inputs("pause_menu_top", Mouse_input_tracker)
		Menu_hint_bar:add_mouse_inputs("pause_menu_top", Mouse_input_tracker)
		Mouse_input_tracker:subscribe(true)
	end
	
	if First_time then
		local bg_anchor = 300
		if vint_is_std_res() then
			bg_anchor = 222
		end
		Screen_in_anim:play(0)
		bg_saints_slide_in(Screen_width, bg_anchor)
		bg_saints_dimmer_show(true)	--Dim out the game...
		First_time = false
	end

end

function pause_menu_top_gained_focus()
	--Initialize Header
	Header_obj:set_text("SYSTEM_PAUSED") --("MENU_GAME_PAUSED")

		--Setup button hints
	local hint_data = {
		{CTRL_MENU_BUTTON_B, "MENU_BACK"},
	}
	Menu_hint_bar:set_hints(hint_data)

	--Get the selection option from when the menu was last loaded
	local last_option_selected = menu_common_stack_get_index(Data)
	
	-- Remove subscriptions
	if Mouse_input_tracker ~= nil then
		Mouse_input_tracker:remove_all()
	end
	
	-- Initialize and draw list object
	List:draw_items(Data, last_option_selected, Screen_width)	
	
	-- Re-add subscriptions
	if Mouse_input_tracker ~= nil then
		List:add_mouse_inputs("pause_menu_top", Mouse_input_tracker)
		Menu_hint_bar:add_mouse_inputs("pause_menu_top", Mouse_input_tracker)
		Mouse_input_tracker:subscribe(true)
	end
	
	--Store some locals to the pause menu common for screen processing.
	menu_common_set_list_style(List, Header_obj, Screen_width)
	menu_common_set_screen_data(List, Header_obj, Input_tracker, Screen_back_out_anim, Screen_out_anim, pause_menu_top_anim_in_done)

end

function pause_menu_top_lost_focus()
	-- Nuke all button subscriptions
	Input_tracker:subscribe(false)
	
	if Mouse_input_tracker ~= nil then
		Mouse_input_tracker:subscribe(false)
	end
	List:enable_toggle_input(false)
end

function pause_menu_top_cleanup()
	if Online_check_thread ~= -1 then
		thread_kill(Online_check_thread)
	end
	
	-- Nuke all button subscriptions
	Input_tracker:subscribe(false)
	
	if Mouse_input_tracker ~= nil then
		Mouse_input_tracker:subscribe(false)
	end
	List:enable_toggle_input(false)
end

function pause_menu_top_anim_in_done()
	if Exit_after_closing == true then
		Input_tracker:subscribe(false)
		
		if Mouse_input_tracker ~= nil then
			Mouse_input_tracker:subscribe(false)
		end
	else
		Input_tracker:subscribe(true)
	
		if Mouse_input_tracker ~= nil then
			Mouse_input_tracker:subscribe(true)
		end
	end
	
	pause_menu_common_top_finished_loading()
end

function pause_menu_top_nav_up(event, acceleration)
	-- Move highlight up
	List:move_cursor(-1)
end

function pause_menu_top_nav_down(event, acceleration)
	-- Move highlight down
	List:move_cursor(1)
end

function pause_menu_top_nav_left(event, acceleration)
	-- Move highlight left
	List:move_slider(-1)
end

function pause_menu_top_nav_right(event, acceleration)
	-- Move highlight right
	List:move_slider(1)
end

function pause_menu_save_callback(result, action)
	menu_common_transition_push("pause_save_game")
end

function pause_menu_proceed_to_coop()
	Input_tracker:subscribe(true)
	menu_common_transition_push("pause_co_op_menu")
	List:button_a()
end

function pause_check_online_status()
	online_and_privilege_validator_begin(true, true, false, true, false)
	while Online_validator_result == ONLINE_VALIDATOR_IN_PROGRESS do
		thread_yield()
	end
	
	Input_tracker:subscribe(false)
	if Online_validator_result ~= ONLINE_VALIDATOR_PASSED then
		Input_tracker:subscribe(true)
		return
	end

	pause_menu_proceed_to_coop()
	Online_check_thread = -1
end

function pause_menu_top_button_a(event, acceleration)
	if Tween_done == true then
		--Set the screen data to the list data
		Data = List:return_data()
		local current_id = List:get_id()
		
		--Add current selection to the stack to store the selected position on the menu
		menu_common_stack_add(current_id)
		
		--pass off the input to the list 
		
		if current_id == ID_SAVE_GAME then
			-- check if the game is autosaving
			if game_is_autosaving() then
				dialog_box_message("MENU_TITLE_NOTICE", "SAVELOAD_CANT_ENTER_AUTOSAVE")
			else
				Save_system_operation = SAVE_OPERATION_SAVE_GAME
				List:button_a()
				local progress_type = game_get_in_progress_type()
				if Save_message_displayed == false and (progress_type == MT_MISSION or progress_type == MT_SILENT or progress_type == MT_STRONGHOLD) then
					dialog_box_message("MENU_TITLE_WARNING", "SAVELOAD_MISSION_WARNING", nil, nil, "pause_menu_save_callback")
				elseif Save_message_displayed == false and (progress_type == MT_ACTIVITY or progress_type == MT_DIVERSION_ACTIVE) then
					dialog_box_message("MENU_TITLE_WARNING", "SAVELOAD_ACTIVITY_WARNING", nil, nil, "pause_menu_save_callback")
				else
					menu_common_transition_push("pause_save_game")
				end
				Save_message_displayed = true			
			end
			return
		elseif current_id == ID_LOAD_GAME then
			if game_is_still_loading() then
				return
			end
			-- check if the game is autosaving
			if game_is_autosaving() then
				dialog_box_message("MENU_TITLE_NOTICE", "SAVELOAD_CANT_ENTER_AUTOSAVE")
			elseif game_is_waiting_for_partner() then
				dialog_box_message("MENU_TITLE_NOTICE", "SAVELOAD_CANT_ENTER_JOINING")
			else
				Save_system_operation = SAVE_OPERATION_LOAD_GAME
				menu_common_transition_push("pause_save_game")
				List:button_a()
			end
			return	
		elseif current_id == ID_OPTIONS then
			menu_common_transition_push("pause_options_menu")
			List:button_a()
		
			return	
		elseif current_id == ID_CO_OP then
			if game_get_platform() == "PS4" and main_menu_check_needs_patch() then 
				return 
			end
			if game_is_still_loading() == false then
				Online_check_thread = thread_new("pause_check_online_status")
			end
			return	
		elseif current_id == ID_CANCEL_MISSION then
			game_cancel_mission()
			return
		elseif current_id == ID_QUIT_GAME then
			dialog_box_destructive_confirmation("PAUSE_MENU_QUIT_TITLE", Quit_message,"pause_menu_top_confirm_quit")
			if Mouse_input_tracker ~= nil then
				Mouse_input_tracker:subscribe(false)
			end
			return	
		elseif current_id == ID_HORDE_RETRY then
			dialog_box_destructive_confirmation("HORDE_MODE_MENU_RETRY", "HORDE_MODE_RETRY_TEXT", "horde_retry_confirm")
		elseif current_id == ID_HORDE_NEW then
			dialog_box_destructive_confirmation("HORDE_MODE_MENU_NEW_GAME", "HORDE_MODE_NEW_TEXT", "horde_new_confirm")
		elseif current_id == ID_RECORD_MODE then
			--dialog_box_destructive_confirmation("RECORD_MODE_WARNING", "RECORD_MODE_WARNING_TEXT", "record_mode_confirm")			
		elseif current_id == ID_CASUAL_RECORD_MODE then
			menu_common_transition_push("pause_options_record_mode")
		elseif current_id == ID_PLAYBACK_MODE then
			dialog_box_destructive_confirmation("PLAYBACK_MODE_WARNING", "PLAYBACK_MODE_WARNING_TEXT", "playback_mode_confirm")
		end
	end
end

function pause_menu_top_confirm_quit(result, action)
--	if action == 1 then
--		return
--	end
	
	if result == 0 then
		-- Dialog box result YES
		if horde_mode_is_active() then
			audio_object_post_event("ui_whr_quit_gameplay")
		end
		Input_tracker:subscribe(false)
		pause_menu_quit_game_internal()
--		menu_common_transition_pop(2)
--		bg_saints_slide_out()
	elseif result == 1 then
		-- Dialog box result NO
		-- Restore inputs to the pause menu
		if Mouse_input_tracker ~= nil then
			Mouse_input_tracker:subscribe(true)
		end
	end
end

function horde_retry_confirm(result, action)
	if result == 0 then
		-- Dialog box result YES
		pause_menu_horde_mode_retry()
		menu_common_transition_pop(2)
	elseif result == 1 then
		-- Dialog box result NO
		-- Restore inputs to the pause menu
		if Mouse_input_tracker ~= nil then
			Mouse_input_tracker:subscribe(true)
		end
	end
end

function horde_new_confirm(result, action)
	if result == 0 then
		-- Dialog box result YES
		pause_menu_horde_mode_new()
		menu_common_transition_pop(2)
	elseif result == 1 then
		-- Dialog box result NO
		-- Restore inputs to the pause menu
		if Mouse_input_tracker ~= nil then
			Mouse_input_tracker:subscribe(true)
		end
	end
end

function record_mode_confirm(result, action)
	if result == 0 then
		-- Dialog box result YES
		game_machinima_record()
		menu_common_transition_pop(2)
	elseif result == 1 then
		-- Dialog box result NO
		-- Restore inputs to the pause menu
		if Mouse_input_tracker ~= nil then
			Mouse_input_tracker:subscribe(true)
		end
	end
end

function playback_mode_confirm(result, action)
	if result == 0 then
		-- Dialog box result YES
		game_machinima_playback_enter("machinima")
		menu_common_transition_pop(2)
	elseif result == 1 then
		-- Dialog box result NO
		-- Restore inputs to the pause menu
		if Mouse_input_tracker ~= nil then
			Mouse_input_tracker:subscribe(true)
		end
	end
end

function pause_menu_top_button_b(event, acceleration)
	if Tween_done == true then
		Input_tracker:subscribe(false)
		if Mouse_input_tracker ~= nil then
			Mouse_input_tracker:subscribe(true)
		end
		List:button_b()
		menu_common_transition_pop(2)
		bg_saints_slide_out()
	end
end

function pause_menu_top_mouse_click(event, target_handle)
	-- First check if the target_handle is in the hint bar
	local hint_index = Menu_hint_bar:get_hint_index(target_handle)
	if hint_index == 1 then
		pause_menu_top_button_b()
	end

	local new_index = List:get_button_index(target_handle)
	if new_index ~= 0 then
		-- Enter an option if the target_handle is in the List
		List:set_selection(new_index)
		pause_menu_top_button_a()
	end
end

function pause_menu_top_mouse_move(event, target_handle)
	-- Reset highlights
	Menu_hint_bar:set_highlight(0)
	
	local hint_index = Menu_hint_bar:get_hint_index(target_handle)
	if hint_index ~= 0 then
		Menu_hint_bar:set_highlight(hint_index)
	end
	
	local new_index = List:get_button_index(target_handle)
	if new_index ~= 0 then
		-- Set the button as the new selected highlight
		List:set_selection(new_index)
		List:move_cursor(0, true)
	end
endr ~= nil and Current_menu_input_tracker ~= 0 then
		Current_menu_input_tracker:subscribe(false)
	end
	
	if Current_mouse_input_tracker ~= nil and Current_mouse_input_tracker ~= 0 then
		Current_mouse_input_tracker:subscribe(false)
	end
	
	Menu_common_push_screen = target_screen

	-- Use this later for transitioning megalist... JMH(4/27/2011)
	--	Current_menu_list:transition_out()
	Current_menu_anim_push:play()
	
	Menu_hint_bar:set_hints(false)
	
	if Current_menu_header then
		--Current_menu_header:anim_out()
	end
	
	--menu_common_anim_out_cb()
	
	--play the SELECT button sound
	game_UI_audio_play("UI_Main_Menu_Select")
	
end

-- Transition back into previous screens.
-- @param num_pops	how many times we want to pop after transition...
function menu_common_transition_pop(num_pops)
	if Current_menu_input_tracker ~= nil and Current_menu_input_tracker ~= 0 then
		Current_menu_input_tracker:subscribe(false)
	end
	
	if Current_mouse_input_tracker ~= nil and Current_mouse_input_tracker ~= 0 then
		Current_mouse_input_tracker:subscribe(false)
	end
	
	if num_pops == nil then
		num_pos = 1
	end
	Menu_common_num_pops = num_pops
	
	-- Use this later for transitioning megalist... JMH(4/27/2011)
	--Current_menu_list:transition_out()
	Current_menu_anim_pop:play()
	
	if Current_menu_header then
		--Current_menu_header:anim_out()
	end
	Menu_hint_bar:set_hints(false)
	
	--menu_common_anim_out_cb()
	
	--play the BACK button sound
	game_UI_audio_play("UI_Main_Menu_Nav_Back")
	
end

function menu_common_set_list_style(List, Header, Width)
	if In_pause_menu then
		pause_menu_set_style(List, Header, Width, Menu_common_num_pops)
	else
		main_menu_set_style(List, Header, Width, Menu_common_num_pops)
	end
end

function menu_common_stack_clear()
	Menu_common_stack = {}
	Menu_common_stack.current_stack = 0
end