local NEW_GAME_INDEX			= 1
local LOAD_GAME_INDEX		= 2

local ID_NEW_GAME				= 1
local ID_LOAD_GAME			= 2

local New_game_button = {
	type = TYPE_BUTTON,
	label = "MAINMENU_NEW",
	id = ID_NEW_GAME,
}

local Load_game_button = {
	type = TYPE_BUTTON,
	label = "SAVELOAD_LOAD_GAME",
	id = ID_LOAD_GAME,
}

local Data
local Anims = {}

local Input_tracker
local Mouse_input_tracker

local Tween_done = true
local Online_check_thread = -1

--------------------------------------------------------------------------- 
-- Initialize Pause Options Menu.
---------------------------------------------------------------------------
function main_menu_campaign_init()
	-- Subscribe to the button presses we need
	 
	Input_tracker = Vdo_input_tracker:new()
	Input_tracker:add_input("select", "main_menu_campaign_button_a", 50)
	Input_tracker:add_input("back", "main_menu_campaign_button_b", 50)
	Input_tracker:add_input("nav_up", "main_menu_campaign_nav_up", 50)
	Input_tracker:add_input("nav_down", "main_menu_campaign_nav_down", 50)
	Input_tracker:add_input("nav_left", "main_menu_campaign_nav_left", 50)
	Input_tracker:add_input("nav_right", "main_menu_campaign_nav_right", 50)
	Input_tracker:subscribe(false)
	
	local screen_width = 495 * 3
	local header_str = "MAINMENU_CAMPAIGN"
	Data = { }
		
	Data[NEW_GAME_INDEX] = New_game_button
	Data[LOAD_GAME_INDEX] = Load_game_button	
	
	--Initialize Header
	Header_obj:set_text(header_str, screen_width)

	--Setup Button Hints 
	local hint_data = {
		{CTRL_MENU_BUTTON_B, "MENU_BACK"},
	}
	Menu_hint_bar:set_hints(hint_data)  
	
	--Get the selection option from when the menu was last loaded
	local last_option_selected = menu_common_stack_get_index()

	List:draw_items(Data, last_option_selected, screen_width)
	
	--Store some locals to the pause menu common for screen processing.
	menu_common_set_list_style(List, Header_obj, screen_width)
	menu_common_set_screen_data(List, Header_obj, Input_tracker, Screen_back_out_anim, Screen_out_anim)
	
	if First_time then
		Screen_in_anim:play(0)
		bg_saints_slide_in(495 * 3)
		First_time = false
	end
	
	-- Add mouse inputs for the PC
	if game_get_platform() == "PC" then
		Menu_hint_bar:set_highlight(0)
		
		Mouse_input_tracker = Vdo_input_tracker:new()
		List:add_mouse_inputs("main_menu_campaign", Mouse_input_tracker)
		Menu_hint_bar:add_mouse_inputs("main_menu_campaign", Mouse_input_tracker)
		Mouse_input_tracker:subscribe(true)
		
		--menu_common_set_mouse_tracker(Mouse_input_tracker)
	end
end

function main_menu_campaign_cleanup()
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

function main_menu_campaign_nav_up(event, acceleration)
	-- Move highlight up
	List:move_cursor(-1)
end

function main_menu_campaign_nav_down(event, acceleration)
	-- Move highlight down
	List:move_cursor(1)
end

function main_menu_campaign_nav_left(event, acceleration)
	-- Move highlight left
	List:move_slider(-1)
end

function main_menu_campaign_nav_right(event, acceleration)
	-- Move highlight right
	List:move_slider(1)
end

function main_menu_campaign_check_live()
	if game_get_platform() == "XBOX3" then
		main_menu_supress_profile_change(true)
		online_and_privilege_validator_begin(false, false, false, false, false, false)
		while Online_validator_result == ONLINE_VALIDATOR_IN_PROGRESS do
			thread_yield()
		end
		main_menu_supress_profile_change(false)
				
		List:highlight_show(true)
			
		if Online_validator_result ~= ONLINE_VALIDATOR_PASSED then
			Input_tracker:subscribe(true)
			return
		end
	end
			
	menu_common_transition_push("pause_save_game")			
	Online_check_thread = -1
end

function main_menu_campaign_button_a(event, acceleration)
	if Tween_done == true then
		--Set the screen data to the list data
		Data = List:return_data()
		local current_id = List:get_id()

		menu_common_stack_add(current_id)
	
		if current_id == ID_NEW_GAME then
			menu_common_transition_push("main_menu_new_game")
			return	
		elseif current_id == ID_LOAD_GAME then
			if game_is_still_loading() then
				return
			end
			Online_check_thread = thread_new("main_menu_campaign_check_live")
			return	
		end	
	end
end

function main_menu_campaign_button_b(event, acceleration)
	if Tween_done == true then
		--pass off the input to the list
		List:button_b()
		--Remove current menu from the stack
		menu_common_stack_remove()
		
		--Pop Screen off the list
		menu_common_transition_pop(1)
		
		bg_saints_slide_out()
	end
end

function main_menu_campaign_mouse_click(event, target_handle)
	local hint_index = Menu_hint_bar:get_hint_index(target_handle)
	if hint_index == 1 then
		main_menu_campaign_button_b()
	end

	local new_index = List:get_button_index(target_handle)
	if new_index ~= 0 then
		List:set_selection(new_index)
		main_menu_campaign_button_a()
	end
end

function main_menu_campaign_mouse_move(event, target_handle)
	Menu_hint_bar:set_highlight(0)
	
	local hint_index = Menu_hint_bar:get_hint_index(target_handle)
	if hint_index ~= 0 then
		Menu_hint_bar:set_highlight(hint_index)
	end
	
	local new_index = List:get_button_index(target_handle)
	if new_index ~= 0 then
		List:set_selection(new_index)
		List:move_cursor(0, true)
	end
end
	end
		end
		PC_menu_adjusted = true
	end
end

function main_menu_top_lost_focus()
	local main_menu_list_h = vint_object_find("main_menu_list")
	vint_set_property(main_menu_list_h, "visible", false)
	
	List:set_visible(true)
	Header_obj:set_visible(true)
	
	main_menu_logo_hide()
	
	Main_menu_input_tracker:subscribe(false)
	if Main_menu_mouse_input_tracker ~= -1 then
		Main_menu_mouse_input_tracker:subscribe(false)
	end
end

function main_menu_top_input_lock(locked)
	Main_menu_input_tracker:subscribe(not locked)
	if Main_menu_mouse_input_tracker ~= -1 then
		Main_menu_mouse_input_tracker:subscribe(not locked)
	end
end

function main_menu_top_gained_focus()
	local main_menu_list_h = vint_object_find("main_menu_list")

	List:set_visible(false)
	Header_obj:set_visible(false)
	
	-- Hide hint bar hints
	Menu_hint_bar:set_hints()  

	bg_saints_show(false)
	main_menu_logo_show()

	if Main_menu_returned_to_start == true then
		vint_set_property(main_menu_list_h, "visible", false)
		if not game_is_demo() and not game_is_remastered() then
			Menu_newsticker:set_visible(false)
		end
		return
	else 
		vint_set_property(main_menu_list_h, "visible", true)
	end
	
	Main_menu_input_tracker:subscribe(true)
	if Main_menu_mouse_input_tracker ~= -1 then
		Main_menu_mouse_input_tracker:subscribe(true)
	end
	
	if Enter_dlc_menu == true then
		main_menu_top_dlc()
		Enter_dlc_menu = false
	end
end

function main_menu_top_cleanup()
	if Main_menu_press_start_peg ~= -1 then
		game_peg_unload(Main_menu_press_start_peg)
	end
	
	if Online_check_thread ~= -1 then
		thread_kill(Online_check_thread)
	end
end

-------------------------------------------------------------------------------
-- Initialize press start screen...
-- Setup controls, and show proper press start bitmap...
-------------------------------------------------------------------------------
function main_menu_top_press_start_init()
	--Start init...
end

function main_menu_top_press_start_show()
	
	if Menu_hint_bar ~= -1 then
		Menu_hint_bar:set_visible(false)
	end
	
	if Main_menu_list ~= -1 then
	
		--Clear any submenu stacks...
		menu_common_stack_clear()
		
		Main_menu_returned_to_start = true
		vint_set_property(Main_menu_list.handle, "visible", false)
	end
			
	if Main_menu_input_tracker ~= -1 then
		Main_menu_input_tracker:subscribe(false)
	end
	
	if Main_menu_mouse_input_tracker ~= -1 then
		Main_menu_mouse_input_tracker:subscribe(false)
	end
		
	local press_start_pulse_h = vint_object_find("press_start_pulse", 0, Main_menu_top_doc)
	lua_play_anim(press_start_pulse_h, 0, Main_menu_top_doc)
	
	--Show start group stuff...
	local h = vint_object_find("press_start_grp", 0, Main_menu_top_doc)
	vint_set_property(h, "visible", true)
	vint_set_property(h, "alpha", 0)
	
	local anim_h = vint_object_find("intro_press_start_anim", 0, Main_menu_top_doc)
	lua_play_anim(anim_h, 0, Main_menu_top_doc)

	local screen_grp_h = vint_object_find("screen_grp", 0, Main_menu_common_doc)
	vint_set_property(screen_grp_h, "anchor", -1000, 0)
	
end

function main_menu_top_press_start_hide()
	--Show start group stuff...
	local h = vint_object_find("press_start_grp")
	vint_set_property(h, "visible", false)
end

-- Turns off press start...
function main_menu_top_press_start_skip()
	--Show start group stuff...
	local h = vint_object_find("press_start_grp")
	vint_set_property(h, "visible", false)
end

function main_menu_create_top_menu()
	Main_menu_top = { }
	
	if Show_continue then
		Main_menu_top[#Main_menu_top + 1] = Continue_button
	end
	
	Main_menu_top[#Main_menu_top + 1] = Campaign_button
	
	if game_is_drm_free() == false then
		Main_menu_top[#Main_menu_top + 1] = Coop_button
	end

	if game_is_german_build() == false then
		Main_menu_top[#Main_menu_top + 1] = Whored_button
	end

	--Main_menu_top[#Main_menu_top + 1] = DLC_button
    --Main_menu_top[#Main_menu_top + 1] = Community_button	

	Main_menu_top[#Main_menu_top + 1] = Options_button
	
	--Main_menu_top[#Main_menu_top + 1] = Extras_button 
    Main_menu_top[#Main_menu_top + 1] = Credits_button 
	
	if game_get_platform() == "PC" then
		-- Main_menu_top[#Main_menu_top + 1] = Machinima_button
		Main_menu_top[#Main_menu_top + 1] = Mm_quit_game
	end

	if game_get_platform() == "XBOX3" then
		Main_menu_top[#Main_menu_top + 1] = { label = game_get_player_name(),			type = TYPE_BUTTON, on_select = main_menu_change_user}
	end
	
	-- Create megalist...
	if Main_menu_list == -1 then
		Main_menu_list = Vdo_pause_mega_list:new("main_menu_list")
		Main_menu_list:set_button_color(COLOR_MAINMENU_TOGGLE_TEXT_SELECTED, COLOR_MAINMENU_TOGGLE_TEXT_UNSELECTED)
		Main_menu_list:set_shadows(true)
		Main_menu_list:draw_items(Main_menu_top, 1, MAIN_MENU_MEGA_LIST_SIZE, 10, "center")
		Main_menu_list:show_bar(false)
	else
		Main_menu_list:draw_items(Main_menu_top, 1, MAIN_MENU_MEGA_LIST_SIZE, 10, "center")
	end


	if game_get_platform() == "PC" then
		Main_menu_mouse_input_tracker:remove_all()
		Main_menu_list:add_mouse_inputs("main_menu", Main_menu_mouse_input_tracker)
	end
end

--Show menu...
function main_menu_top_menu_show(show_continue)
	if show_continue then 
		Show_continue = true
	end
	
	Menu_hint_bar:set_hints()
	Menu_hint_bar:set_visible(true)
	
	Main_menu_returned_to_start = false
	
	-- Check for money shot unlocks after Press Start.
	main_menu_money_shot_check()
	
	main_menu_create_top_menu()
	vint_set_property(Main_menu_list.handle, "visible", true)

	--Disabling Newsticker for demo and remastered version.
	if not game_is_demo() and not game_is_remastered() then
		if Menu_newsticker == -1 then
			Menu_newsticker = Vdo_newsticker:new("newsticker", 0, 0, "main_menu_top.lua", "Menu_newsticker")
		end
		
		Menu_newsticker:set_visible(true)
		
		-- Move the ticker down, and everything else up on PC
		if game_get_platform() == "PC" and PC_menu_adjusted == false then
			local main_menu_list_h = vint_object_find("main_menu_list")
			vint_set_property(main_menu_list_h, "scale", 0.9, 0.9)
			
			local base_grp_h = vint_object_find("base_grp")
			local x, y = vint_get_property(base_grp_h, "anchor")
			if vint_is_std_res() then
				vint_set_property(base_grp_h, "anchor", x, y)
			else
				vint_set_property(base_grp_h, "anchor", x, y)
			end
			
			x, y = Menu_newsticker:get_anchor()
			if vint_is_std_res() then
				Menu_newsticker:set_anchor(x, y)
			else
				Menu_newsticker:set_anchor(x, y)
			end
			PC_menu_adjusted = true
		end
	end
			
	-- Subscribe to inputs
	Main_menu_input_tracker:subscribe(true)
		-- Add mouse inputs for the PC
	if game_get_platform() == "PC" then
		Main_menu_mouse_input_tracker:subscribe(true)
	end

	bg_saints_set_type(BG_TYPE_CENTER,true)
end


-- show main menu
function main_menu_start()

-- legacy shit...
--	pause_save_get_global_info(false)	-- this can block across frames
--	pause_save_get_global_info(get_device)

	-- Show main menu on screen...
	
end

function main_menu_do_nothing()

end

-------------------------------------------------------------------------------
-- Navigation Functions...
-------------------------------------------------------------------------------
function main_menu_nav_up()
	-- Move highlight up
	Main_menu_list:move_cursor(-1)
end

function main_menu_nav_down()
	-- Move highlight down
	Main_menu_list:move_cursor(1)
end

function main_menu_button_b()
	if game_get_platform() == "PC" then
		main_menu_initiate_quit_game()
	end
	--Nav the screen back...
end

function main_menu_button_a()
	--Nav the screen forward...

	--Set the screen data to the list data
	local data = Main_menu_list:return_data()
	local current_selection = Main_menu_list:get_selection()
	if current_selection == -1 then
		return
	end
	
	--Clear any sub menu stacks...
	menu_common_stack_clear()
	
	--pass off the input to the list
	Main_menu_list:button_a()
	
end

function main_menu_mouse_click(event, target_handle)
	local new_index = Main_menu_list:get_button_index(target_handle)
	if new_index ~= 0 then
		Main_menu_list:set_selection(new_index)
		--Main_menu_list:move_cursor(0, true)
		main_menu_button_a()
	end
end

function main_menu_mouse_move(event, target_handle)
	local new_index = Main_menu_list:get_button_index(target_handle)
	if new_index ~= 0 then
		Main_menu_list:set_selection(new_index)
		Main_menu_list:move_cursor(0, true)
	end
end

-- Continue button
function main_menu_top_continue()
	if game_is_still_loading() then
		return
	end

	main_menu_continue()
end

-- Campaign menu
function main_menu_top_campaign()
	--Do Campaign Game
	push_screen("main_menu_campaign")
end

function mm_top_redeem_check()
	main_menu_supress_profile_change(true)
	online_and_privilege_validator_begin(true, true, true, false, false)
	while Online_validator_result == ONLINE_VALIDATOR_IN_PROGRESS do
		thread_yield()
	end
	main_menu_supress_profile_change(false)
	
	main_menu_top_input_lock(false)
	if Online_validator_result ~= ONLINE_VALIDATOR_PASSED then
		return
	end
	
	main_menu_redeem_code()
	Online_check_thread = -1
end

function mm_top_coop_dlg_cb(result, action)
	if game_get_platform() == "PC" then
		if result == 0 then
			main_menu_top_dlc()
		end
	else
		if result == 0 then
			Online_check_thread = thread_new("mm_top_redeem_check")
		elseif result == 1 then
			main_menu_top_dlc()
		end
	end
end

function main_menu_top_coop_dlc_checked(has_coop, cancelled)
	if has_coop then
		--Do coop Coop
		push_screen("main_menu_coop_top")
	elseif not cancelled then
		local options
		local back_option = 1
		if game_get_platform() == "PC" then
			options = { [0] = "GO_DLC_STORE", [1] = "CONTROL_CANCEL" }
		else
			options = { [0] = "REDEEM_CODE", [1] = "GO_DLC_STORE", [2] = "CONTROL_CANCEL" }
			back_option = 2
		end
		dialog_box_open("DIALOG_COOP_DLC_TITLE", "DLC_COOP_DLC_MAIN_BODY", options, "mm_top_coop_dlg_cb", 
								0, DIALOG_PRIORITY_ACTION, false, nil, false, false, false, back_option)
		
	end
end

function main_menu_top_check_coop()
	main_menu_supress_profile_change(true)
	online_and_privilege_validator_begin(true, true, false, false, false)
	while Online_validator_result == ONLINE_VALIDATOR_IN_PROGRESS do
		thread_yield()
	end
	main_menu_supress_profile_change(false)
	
	main_menu_top_input_lock(false)
	if Online_validator_result ~= ONLINE_VALIDATOR_PASSED then
		return
	end
	
	game_check_coop_dlc("main_menu_top_coop_dlc_checked")
	Online_check_thread = -1
end

function main_menu_top_coop()
	if game_is_still_loading() then
		return
	end

	if game_get_platform() == "PS4" and main_menu_check_needs_patch() then 
		return 
	end

	Whored_mode_active = false
	
	main_menu_top_input_lock(true)
	
	Online_check_thread = thread_new("main_menu_top_check_coop")
end

function main_menu_top_whored()
	if game_is_still_loading() then
		return
	end

	Whored_mode_active = true
	
	if game_is_drm_free() then
		main_menu_horde_start()
	else
		--Do coop Coop
		push_screen("main_menu_coop_top")
	end
end

function mm_check_dlc()
	-- If there's a previous check, let it finish
	while Online_validator_result == ONLINE_VALIDATOR_IN_PROGRESS do
		thread_yield()
	end
	
	online_and_privilege_validator_begin(true, false, false, false, false)
	while Online_validator_result == ONLINE_VALIDATOR_IN_PROGRESS do
		thread_yield()
	end
	
	main_menu_top_input_lock(false)
	if Online_validator_result == ONLINE_VALIDATOR_PASSED then
		push_screen("store_dlc")
	end
	
	Online_check_thread = -1
end

function main_menu_top_dlc()
	if game_get_platform() == "PC" then
		game_steam_open_dlc_page_overlay()
		return
	end

	main_menu_top_input_lock(true)
	Online_check_thread = thread_new("mm_check_dlc")
end

function main_menu_top_options()
	--Top Options
	push_screen("pause_options_menu")
end

function main_menu_change_user()
	game_show_account_picker()
end

--function main_menu_top_extras()
--	--Top Extras
--	push_screen("main_menu_extras")
--end

function main_menu_top_credits()
	--Top Credits
	push_screen("credits")
end

function main_menu_top_machinima()
	-- This should bring up cinema_clip_manager, or show a dialog box saying that there are no clips to edit
	push_screen("pause_options_clip_select")
end

function main_menu_initiate_quit_game()
	dialog_box_destructive_confirmation("PLT_QUIT_GAME", "PLT_QUIT_GAME_WARNING", "main_menu_top_confirm_quit")
end

function main_menu_top_confirm_quit(return_value)
	if return_value == 0 then -- YES
		game_request_game_terminate()
	end
end

-------------------------------------------------------------------------------
-- Main Menu BMS Loaded
-------------------------------------------------------------------------------
function main_menu_top_bmp_loaded()
	--This is for the press start image...
	--It is a null function callback...
end


-------------------------------------------------------------------------------
-- Temp function to remove the demo disabling..stuff...
-- use the console to access... "vint_lua main_menu_top mm_coop"
-------------------------------------------------------------------------------
function mm_coop()
	for i, v in pairs(Main_menu_top) do
		v.disabled = nil
	end
	-- Create megalist...
	Main_menu_list:draw_items(Main_menu_top, 1, MAIN_MENU_MEGA_LIST_SIZE, "center")
--	Main_menu_list:set_highlight_color(COLOR_STORE_REWARDS_PRIMARY)
end

Continue_button	    = { label = "MAINMENU_CONTINUE",		type = TYPE_BUTTON, on_select = main_menu_top_continue  }
Campaign_button 	= { label = "MAINMENU_CAMPAIGN",		type = TYPE_BUTTON, on_select = main_menu_top_campaign  }
Coop_button 		= { label = "MAINMENU_COOP_OPTION", 	type = TYPE_BUTTON, on_select = main_menu_top_coop      }
Whored_button 		= { label = "MAINMENU_WHORED",			type = TYPE_BUTTON, on_select = main_menu_top_whored 	}
DLC_button			= { label = "MAINMENU_DLC",				type = TYPE_BUTTON, on_select = main_menu_top_dlc		}
Options_button		= { label = "MAINMENU_OPTIONS",			type = TYPE_BUTTON, on_select = main_menu_top_options	}
--Extras_button		= { label = "MAINMENU_EXTRAS", 			type = TYPE_BUTTON, on_select = main_menu_top_extras	}
Credits_button		= { label = "MAINMENU_CREDITS", 		type = TYPE_BUTTON, on_select = main_menu_top_credits	}
Machinima_button	= { label = "MAINMENU_MACHINIMA_MODE",  type = TYPE_BUTTON, on_select = main_menu_top_machinima }
Mm_quit_game 		= { label = "PLT_QUIT_GAME",			type = TYPE_BUTTON, on_select = main_menu_initiate_quit_game}'0