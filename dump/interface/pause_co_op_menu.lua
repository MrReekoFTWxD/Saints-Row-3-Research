-- Global
local FFO_NONE					= 2	-- From code

local ID_INVITE					= 1
local ID_KICK					= 2
local ID_PRIV					= 3
local ID_FF						= 4
local ID_VIEW_GAMERCARD			= 5

local Anims = {}
local Invite_button = { type = TYPE_BUTTON, label = "COOP_MENU_INVITE",	id = ID_INVITE	}
local Kick_button = { type = TYPE_BUTTON, label = "COOP_MENU_KICK", id = ID_KICK 	}
local Privacy_button = { type = TYPE_TOGGLE, label = "COOP_MENU_PRIVACY", 
								 options = {"COOP_MENU_OPEN", "COOP_MENU_FRIENDS_ONLY", "COOP_MENU_PRIVATE"},
								 current_value = game_get_coop_join_type() + 1, id = ID_PRIV }
local FF_button = { type = TYPE_TOGGLE, label = "COOP_MENU_FRIENDLY_FIRE",
						  options = {"COOP_MENU_FULL_DAMAGE", "COOP_MENU_LIGHT_DAMAGE", "MENU_NONE"},
						  current_value = game_get_coop_friendly_fire() + 1,	id = ID_FF,	}
local Show_gamercard_button = { type = TYPE_BUTTON, label = "PLT_MENU_VIEW_PARTNER_GAMERCARD", id = ID_VIEW_GAMERCARD }
local Data = {}
local Input_tracker
local Mouse_input_tracker

local Screen_width = 700 * 3

local Tween_done = true

local Co_op_monitor_thread_h = -1

function pause_is_session_joinable()
	local is_joinable = game_is_joinable()
	if game_get_platform() == "PS4" and game_user_have_ps_plus(false) == false then
		is_joinable = true
	end
	return is_joinable
end

function pause_co_op_build_data()

	Data = {}

	if In_pause_menu == false then
	-- Main Menu coop menu
		Data[#Data + 1] = Privacy_button
		Data[#Data + 1] = FF_button
	elseif coop_is_active() then
	-- During Coop Game menu
		if game_get_is_host() then
		-- The host's version
			Data[#Data + 1] = Kick_button
			Data[#Data + 1] = Privacy_button
			Data[#Data].disabled = true --can't change privacy while coop
			Data[#Data + 1] = FF_button
		else 
		-- The client's version
			Data[#Data + 1] = FF_button
			Data[#Data].disabled = true	-- can't change as client
		end

		if not game_is_syslink() and not game_is_pc_epicstore() and not game_is_pc_gog() then
			Data[#Data + 1] = Show_gamercard_button
		end

	else
		-- In Game, coop not started
		Data[#Data + 1] = Invite_button
		if pause_is_session_joinable() == false then
			Data[#Data].disabled = true
			Data[#Data].toggle_disabled = true
		else
			Data[#Data].disabled = false
			Data[#Data].toggle_disabled = false
		end
		Data[#Data + 1] = Privacy_button
		Data[#Data + 1] = FF_button
	end
end

function pause_co_op_menu_init()
	-- Subscribe to the button presses we need
	
	Input_tracker = Vdo_input_tracker:new()
	Input_tracker:add_input("select", "pause_co_op_menu_button_a", 50)
	Input_tracker:add_input("pause", "pause_co_op_menu_button_start", 50)
	Input_tracker:add_input("back", "pause_co_op_menu_button_b", 50)
	Input_tracker:add_input("nav_up", "pause_co_op_menu_nav_up", 50)
	Input_tracker:add_input("nav_down", "pause_co_op_menu_nav_down", 50)
	Input_tracker:add_input("nav_left", "pause_co_op_menu_nav_left", 50)
	Input_tracker:add_input("nav_right", "pause_co_op_menu_nav_right", 50)
	Input_tracker:subscribe(false)

	--Initialize Header
	Header_obj:set_text("MAINMENU_COOP", Screen_width)

	--Setup Button Hints
	local hint_data = {
		{CTRL_MENU_BUTTON_B, "MENU_BACK"},
	}
	Menu_hint_bar:set_hints(hint_data)  
	
	--Get the selection option from when the menu was last loaded
	local last_option_selected = menu_common_stack_get_index()
	
	pause_co_op_build_data()
	
	-- draw it up
	List:draw_items(Data, last_option_selected, Screen_width)
	
	--Store some locals to the pause menu common for screen processing.
	menu_common_set_list_style(List, Header_obj, Screen_width)
	menu_common_set_screen_data(List, Header_obj, Input_tracker, Screen_back_out_anim, Screen_slide_out_anim)
	
	-- Add mouse input subscriptions for the PC
	if game_get_platform() == "PC" then
		Mouse_input_tracker = Vdo_input_tracker:new()
		Menu_hint_bar:add_mouse_inputs("pause_co_op_menu", Mouse_input_tracker)
		List:add_mouse_inputs("pause_co_op_menu", Mouse_input_tracker)
		
		Mouse_input_tracker:subscribe(true)
	end
	
	if In_pause_menu then
		Co_op_monitor_thread_h = thread_new("pause_co_op_monitor_co_op_active")
	end
end

function pause_co_op_menu_cleanup()
	-- Nuke all button subscriptions
	Input_tracker:subscribe(false)
	if Mouse_input_tracker ~= nil then
		Mouse_input_tracker:subscribe(false)
	end
	List:enable_toggle_input(false)
	
	if Co_op_monitor_thread_h ~= -1 then
		thread_kill(Co_op_monitor_thread_h)
		Co_op_monitor_thread_h = -1
	end
end

function pause_co_op_menu_nav_up(event, acceleration)
	-- Move highlight up
	List:move_cursor(-1)
end

function pause_co_op_menu_nav_down(event, acceleration)
	-- Move highlight down
	List:move_cursor(1)
end

function pause_co_op_menu_nav_left(event, acceleration)
	-- only host can change this guy
	if not game_get_is_host() and In_pause_menu == true then
		return
	end

	-- Move highlight left	
	List:move_slider(-1)
	
	update_option(List:get_id())
end

function pause_co_op_menu_nav_right(event, acceleration)
	-- only host can change this guy
	if not game_get_is_host() and In_pause_menu == true then
		return
	end

	-- Move highlight right
	List:move_slider(1)
	
	update_option(List:get_id())
end

function pause_co_op_menu_button_a(event, acceleration)
	if Tween_done == true then
	
		local current_id = List:get_id()
		if current_id == ID_VIEW_GAMERCARD then
			game_show_coop_partner_gamercard()
			return
		end
	
		if not game_get_is_host() and In_pause_menu == true then
			return
		end
		
		--set the screen data to the list data
		Data = List:return_data()
		
		local current_id = List:get_id()
		menu_common_stack_add(current_id)
		if current_id == ID_INVITE then
			-- See if we're connected to the network even...
			if game_is_connected_to_network() == false then
				dialog_box_message("MENU_TITLE_WARNING", "NO_NETWORK_CONNECTION")
				return
			end
			-- See if we're connected to PSN or XBL
			if game_is_connected_to_service() == false then
				if game_get_platform() == "PC" then
					if game_is_pc_epicstore() == true then
						dialog_box_message("MENU_TITLE_WARNING", "NOT_LOGGED_IN_EPIC")
					elseif game_is_pc_gog() == true then
						dialog_box_message("MENU_TITLE_WARNING", "NOT_LOGGED_IN_GOG")
					else
						dialog_box_message("MENU_TITLE_WARNING", "NOT_LOGGED_IN")
					end
				elseif game_get_platform() == "XBOX3" then
					dialog_box_message("MENU_TITLE_WARNING", "NOT_LOGGED_IN_XBOX")
				else 				
					dialog_box_message("MENU_TITLE_WARNING", "NOT_LOGGED_IN")
				end
				return
			end
			--see if we're on a profile
			if game_is_signed_in() == false then
				if game_get_platform() == "PC" then
					dialog_box_message("MENU_TITLE_WARNING", "MULTI_NOT_SIGNED_IN")
				elseif game_get_platform() == "XBOX3" then
					dialog_box_message("MENU_TITLE_WARNING", "MULTI_NOT_SIGNED_IN")
				end
				return
			end
			if game_get_platform() == "PS4" and game_user_have_ps_plus(true) == false then
				return
			end
			menu_common_transition_push("pause_invite_friends")
			return
		elseif current_id == ID_KICK then
			game_coop_kick_player("pause_co_op_kick_complete")
		else 
			--update_option(current_id)
			pause_co_op_menu_nav_right(event, acceleration)
		end
	end
end

function pause_co_op_kick_complete(kicked)
	if kicked then
		pause_co_op_build_data()
		-- draw it up
		local last_option_selected = menu_common_stack_get_index()
		List:draw_items(Data, last_option_selected, 700 * 3)
		
		if Mouse_input_tracker ~= nil then
			Mouse_input_tracker:remove_all()
			Menu_hint_bar:add_mouse_inputs("pause_co_op_menu", Mouse_input_tracker)
			List:add_mouse_inputs("pause_co_op_menu", Mouse_input_tracker)
			Mouse_input_tracker:subscribe(true)
		end
	end
end

function update_option(option_id)
	if option_id == ID_PRIV then
		-- we will save this on backout
		--game_set_coop_join_type(List:get_data_from_id(ID_PRIV).current_value - 1)
	else
		local value = List:get_data_from_id(ID_FF).current_value - 1
		
		if value == FFO_NONE and pause_menu_cat_mouse_active() then
			dialog_box_confirmation("MENU_TITLE_WARNING", "CAT_MOUSE_FRIENDLY_FIRE_WARNING", "pause_co_op_ff_conf")
		else
			game_set_coop_friendly_fire(List:get_data_from_id(ID_FF).current_value - 1)
		end
	end
end

function pause_co_op_ff_conf(result, action)
	if result == 0 then
		game_set_coop_friendly_fire(List:get_data_from_id(ID_FF).current_value - 1)
	else
		-- Reset the selection
		List:get_data_from_id(ID_FF).current_value = game_get_coop_friendly_fire() + 1
		List:move_slider(0)
	end
end

function pause_co_op_menu_button_b(event, acceleration)
	if Tween_done == true then
		--update privacy settings
		if In_pause_menu == false or game_get_is_host() then
			game_set_coop_join_type(List:get_data_from_id(ID_PRIV).current_value - 1)
		end
		--pass off the input to the list
		List:button_b()
		--Remove current menu from the stack
		menu_common_stack_remove()
		menu_common_transition_pop(1)
	end
end

function pause_co_op_menu_button_start(event, acceleration)
	if Tween_done == true then
		menu_common_set_screen_data(List, Header_obj, Input_tracker, Screen_back_out_anim, Screen_out_anim)	
		Input_tracker:subscribe(false)
		if In_pause_menu == true then
			menu_common_transition_pop(3)	-- save_load, pause_menu_top, menu_common
		else
			menu_common_transition_pop(2)	-- main_menu_coop_top, menu_common
		end
		bg_saints_slide_out()
	end
end

function pause_co_op_menu_mouse_click(event, target_handle)
	-- First check if the target_handle refers to the hint bar
	local hint_index = Menu_hint_bar:get_hint_index(target_handle)
	if hint_index == 1 then
		pause_co_op_menu_button_b()
	end

	local new_index = List:get_button_index(target_handle)
	if new_index ~= 0 then
		-- Enter an option if the target_handle is in the Mega_list
		List:set_selection(new_index)
		local data = List:return_selected_data()
		if data.type == TYPE_TOGGLE then
			pause_co_op_menu_nav_right()
		else
			pause_co_op_menu_button_a()
		end
	end
	if List:is_left_arrow(target_handle) then
		pause_co_op_menu_nav_left()
	end
end

function pause_co_op_menu_mouse_move(event, target_handle)
	-- Reset highlights
	Menu_hint_bar:set_highlight(0)
	
	-- Check if the target_handle is the hint bar
	local hint_index = Menu_hint_bar:get_hint_index(target_handle)
	if hint_index ~= 0 then
		Menu_hint_bar:set_highlight(hint_index)
	end
	
	local new_index = List:get_button_index(target_handle)
	if new_index ~= 0 then
		-- Get the button's index and set it as the selected button
		List:set_selection(new_index)
		List:move_cursor(0, true)
	end

end

function pause_co_op_monitor_co_op_active()

	local prev_game_is_joinable = false
	local prev_coop_is_active = false
	
	while true do
		local cur_game_is_joinable = pause_is_session_joinable()
		local cur_coop_is_active = coop_is_active()
		
		if prev_coop_is_active ~= cur_coop_is_active or prev_game_is_joinable ~= cur_game_is_joinable then
			pause_co_op_build_data()
			-- draw it up
			local last_option_selected = menu_common_stack_get_index()
			List:draw_items(Data, last_option_selected, 700 * 3)
			
			if Mouse_input_tracker ~= nil then
				Mouse_input_tracker:remove_all()
				Menu_hint_bar:add_mouse_inputs("pause_co_op_menu", Mouse_input_tracker)
				List:add_mouse_inputs("pause_co_op_menu", Mouse_input_tracker)
				Mouse_input_tracker:subscribe(true)
			end
		end
		
		prev_game_is_joinable = cur_game_is_joinable
		prev_coop_is_active = cur_coop_is_active
		delay(1.0)
	end
	Co_op_monitor_thread_h = -1
end
eration)

	-- if Num_friends == 0 then
	-- 	if Coop_connect_operation == COOP_INVITE_LIST then
	-- 		Data = { [1] = NO_FRIENDS_FOUND_OPTION }
	-- 	else
	-- 		Data = { [1] = NO_GAMES_FOUND_OPTION }
	-- 	end
	-- end
	
	--Get the selection option from when the menu was last loaded
	pause_invite_friends_update_list_width(#Data)
	local selection = List:get_selection()
	selection = min(selection, #Data)
	--REMOVED true FROM LIST DRAW CALL TO FIX ASSERT JAM 5/3/11
	List:draw_items(Data, selection, List_width, MIN_SCROLL_ITEMS, nil, false)--true)
	
	Hint_y_index = -1
	
	local hint_data
	if Coop_connect_operation == COOP_SYSLINK_JOIN_LIST then
		if game_get_platform() ~= "PC" then
			hint_data = {
				{CTRL_MENU_BUTTON_B, "MENU_BACK"},
				{CTRL_BUTTON_X, "MENU_REFRESH_SYSLINK"},
			}
			Hint_x_index = 2
		else
			hint_data = {
				{CTRL_MENU_BUTTON_B, "MENU_BACK"},
				{CTRL_BUTTON_Y, "MENU_REFRESH_SYSLINK"},
			}
			Hint_y_index = 2
		end
	elseif Num_friends == 0 or game_is_pc_epicstore() == true or game_is_pc_gog() then
		hint_data = {
			{CTRL_MENU_BUTTON_B, "MENU_BACK"},
			}
		Hint_x_index = -1
	else
		hint_data = {
			{CTRL_MENU_BUTTON_B, "MENU_BACK"},
			{CTRL_BUTTON_X, "PLT_MENU_VIEW_GAMERCARD"},
		}
		Hint_x_index = 2
	end
	
	if Party_show == true then
		hint_data[#hint_data + 1] = { CTRL_BUTTON_Y, "MENU_XBOX_PARTY_JOIN" }
		Hint_y_index = #hint_data 
	elseif Party_invite == true then
		hint_data[#hint_data + 1] = { CTRL_BUTTON_Y, "MENU_XBOX_PARTY_INVITE" }
		Hint_y_index = #hint_data
	end
	
	Menu_hint_bar:set_width_max(List_width - HINT_BAR_OFFSET)
	Menu_hint_bar:set_hints(hint_data) 
	
	--UNLOCK INPUT HERE JAM 5/3/11
	Input_tracker:subscribe(true)
	if Mouse_input_tracker ~= nil then
		Mouse_input_tracker:remove_all()
		List:add_mouse_inputs("pause_invite_friends", Mouse_input_tracker)
		Mouse_input_tracker:subscribe(true)
	end
	
	if Hint_bar_input_tracker ~= nil then
		Hint_bar_input_tracker:remove_all()
		Menu_hint_bar:add_mouse_inputs("pause_invite_friends", Hint_bar_input_tracker)
		Hint_bar_input_tracker:subscribe(true)
	end
end

function pause_invite_refresh_syslink(quick_refresh)
	game_start_find_syslink_servers()
	Started_syslink_search = true
	
	Data = { [1] = SEARCHING_OPTION }

	pause_invite_friends_update_list_width(#Data)
	List:draw_items(Data, 1, List_width, MIN_SCROLL_ITEMS)
	List:set_visible(true)

	local hint_data = {
		{CTRL_MENU_BUTTON_B, "MENU_BACK"},
	}
	
	Menu_hint_bar:set_width_max(List_width - HINT_BAR_OFFSET)
	Menu_hint_bar:set_hints(hint_data)  
	Hint_y_index = -1
	Hint_x_index = -1

	--REMOVED quick_refresh FROM LIST DRAW CALL TO FIX ASSERT JAM 5/3/11
	pause_invite_friends_update_list_width(#Data)
	List:draw_items(Data, 1, List_width, MIN_SCROLL_ITEMS, nil, false)--quick_refresh)
	
	Input_tracker:subscribe(true)
	if Mouse_input_tracker ~= nil then
		Mouse_input_tracker:remove_all()
		List:add_mouse_inputs("pause_invite_friends", Mouse_input_tracker)
		Mouse_input_tracker:subscribe(true)
	end
	
	if Hint_bar_input_tracker ~= nil then
		Hint_bar_input_tracker:remove_all()
		Menu_hint_bar:add_mouse_inputs("pause_invite_friends", Hint_bar_input_tracker)
		Hint_bar_input_tracker:subscribe(true)
	end

	delay(SYSLINK_UPDATE_DELAY)
	
	pause_invite_friends_do_responder()

	-- Does not live update.
	game_stop_find_syslink_servers()	
	Started_syslink_search = false
	
	Search_thread = -1
end

function pause_invite_friends_nav_up(event, acceleration)
	-- Move highlight up
	List:move_cursor(-1)
end

function pause_invite_friends_nav_down(event, acceleration)
	-- Move highlight down
	List:move_cursor(1)
end

function pause_invite_friends_nav_left(event, acceleration)
	-- Move highlight left
	List:move_slider(-1)
end

function pause_invite_friends_nav_right(event, acceleration)
	-- Move highlight right
	List:move_slider(1)
end

function pause_invite_friends_button_a(event, acceleration)
	if Tween_done == true then
		--set the screen data to the list data
		Data = List:return_data()
		local current_id = List:get_id()
				
		if current_id == -1 then
			return
		end
		
		if Coop_connect_operation == COOP_INVITE_LIST then
			if game_can_send_player_invite(List:get_selection() - 2) == false then
				return
			end
			
			local insert_values = { [0] = Data[List:get_selection()].invite_tag }
			if game_send_pause_menu_player_invite(List:get_selection() - 2) == true then -- offset index by 1
				local body = vint_insert_values_in_string("MP_INVITE_SENT_BODY", insert_values)
				dialog_box_message("MP_INVITE_SENT_TITLE", body)
			else
				local body = vint_insert_values_in_string("INVITE_FAILED_BODY", insert_values)
				dialog_box_message("INVITE_FAILED_TITLE", body)
			end
			
			if Exit_after_closing == true then
				menu_common_transition_pop(3)
			end
		elseif Coop_connect_operation == COOP_ONLINE_JOIN_LIST then
			local has_seen_cal_screen = pause_menu_has_seen_display_cal_screen()
			if has_seen_cal_screen then
				local join_started = game_main_menu_join_friend_in_progress(List:get_selection() - 2);
				if join_started then
				    pause_invite_friends_lock_input(true)
				end
			else
				Join_friend_after_display = List:get_selection() - 2
				menu_display_set_cal_id(options_display_get_brightness_id())
				push_screen("pause_options_display_cal")
			end
			
		elseif Coop_connect_operation == COOP_SYSLINK_JOIN_LIST then
			game_join_syslink_game(current_id)
		end
	
	end
end

function pause_invite_friends_button_b(event, acceleration)
	if Tween_done == true then
		--pass off the input to the list
		List:button_b()
	
		--set up the list out twns
		local list_slide_out = Vdo_tween_object:new("screen_slide_out_twn2", Screen_slide_out_anim.handle)
		local header_slide_out = Vdo_tween_object:new("screen_slide_out_twn3", Screen_slide_out_anim.handle)
		
		list_slide_out:set_property("start_value", 100 * 3, 120 * 3)
		header_slide_out:set_property("start_value", 130 * 3, 80 * 3)
		
		list_slide_out:set_property("end_value", 1000 * 3, 120 * 3)
		header_slide_out:set_property("end_value", 1000 * 3, 80 * 3)
		
		local list_slide_in = Vdo_tween_object:new("screen_slide_in_twn2", Screen_slide_in_anim.handle)
		local header_slide_in = Vdo_tween_object:new("screen_slide_in_twn3", Screen_slide_in_anim.handle)
		
		list_slide_in:set_property("start_value", -200 * 3, 267 * 3)
		header_slide_in:set_property("start_value", -200 * 3, 230 * 3)
	
		list_slide_in:set_property("end_value", 100 * 3, 267 * 3)
		header_slide_in:set_property("end_value", 130 * 3, 230 * 3)
	
		Input_tracker:subscribe(false)
		if Mouse_input_tracker ~= nil then
			Mouse_input_tracker:subscribe(false)
		end
		if Exit_after_closing == true then
			menu_common_transition_pop(3)
		else
			--Remove current menu from the stack
			menu_common_stack_remove()
			menu_common_transition_pop(1)
		end
	end
end

function pause_invite_friends_button_x(event, acceleration)
	if Tween_done == true and Hint_x_index ~= -1 then
		if game_get_platform() ~= "PC" and Coop_connect_operation == COOP_SYSLINK_JOIN_LIST then
			if Search_thread == -1 then
				Search_thread = thread_new("pause_invite_refresh_syslink", true)
			end
			return
		end
	
		local current_id = List:get_id()
		if current_id == -1 then
			return
		end
	
		game_show_coop_gamercard(List:get_selection() - 2)
	end
end

function pause_invite_friends_button_y(event, acceleration)
	if Party_invite then
		game_send_party_invites()
	elseif Party_show then
		if game_get_party_member_count() > 1 then
			game_show_community_sessions_ui()
		else
			game_show_party_ui()
		end
	elseif game_get_platform() == "PC" then
		if Search_thread == -1 then
			pause_invite_friends_get_data()
		end
	end
end

function pause_invite_friends_button_start(event, acceleration)
	if In_pause_menu == false then
		return
	end
	
	if Tween_done == true then
		menu_common_set_screen_data(List, Header_obj, nil, Screen_back_out_anim, Screen_out_anim)	
		Input_tracker:subscribe(false)
		-- stack is part of common, which is getting popped, so we don't update it.
		menu_common_transition_pop(4) -- invite_friends, pause_co_op_menu, pause_menu_top, menu_common
		bg_saints_slide_out()
	end
end

-- Update the list width (depending on if it will scroll or not)
function pause_invite_friends_update_list_width(list_items)
	if list_items > MIN_SCROLL_ITEMS then
		List_width = 685 * 3
	else
		List_width = 700 * 3
	end
end

-- Mouse inputs
function pause_invite_friends_mouse_click(event, target_handle)
	local hint_index = Menu_hint_bar:get_hint_index(target_handle)
	if hint_index == 1 then
		pause_invite_friends_button_b()
	elseif hint_index == Hint_y_index then
		pause_invite_friends_button_y()
	elseif hint_index == Hint_x_index then
		pause_invite_friends_button_x()
	end

	local new_index = List:get_button_index(target_handle)
	if new_index ~= 0 then
		List:set_selection(new_index)
		pause_invite_friends_button_a()
	end
end

function pause_invite_friends_mouse_move(event, blah1, blah2, blah3, blah4, target_handle)
	
	local hint_index = Menu_hint_bar:get_hint_index(target_handle)
	if hint_index ~= 0 then
		Menu_hint_bar:set_highlight(hint_index)
	else
		Menu_hint_bar:set_highlight(0)	
	end
	
	local new_index = List:get_button_index(target_handle)
	if new_index ~= 0 then
		List:set_selection(new_index)
		List:move_cursor(0, true)
	end
end

function pause_invite_friends_mouse_scroll(event, target_handle, mouse_x, mouse_y, scroll_lines)
	if scroll_lines ~= 0 then
		if List:get_scroll_region_handle() == target_handle then
			List:scroll_list(scroll_lines * -1)
			List:update_mouse_inputs("pause_invite_friends", Mouse_input_tracker)
			Mouse_input_tracker:subscribe(true)
		end
	end
end

function pause_invite_friends_mouse_drag(event, target_handle, mouse_x, mouse_y)
	if List.scrollbar.tab.handle == target_handle then
		local new_start_index = List.scrollbar:drag_scrolltab(mouse_y, List.num_buttons - (List.max_buttons - 1))
		List:scroll_list(0, new_start_index)
	end
end

-- Updates the mouse inputs for the list and snaps the scrolltab to the closest notch based on the visible index
--
function pause_invite_friends_mouse_drag_release(event, target_handle, mouse_x, mouse_y)
	if List.scrollbar.tab.handle == target_handle then
		local start_index = List:get_visible_indices()
		List.scrollbar:release_scrolltab(start_index, List.num_buttons - (List.max_buttons - 1))
		List:update_mouse_inputs("pause_invite_friends", Mouse_input_tracker)
		Mouse_input_tracker:subscribe(true)
	end
end

function pause_invite_friends_lock_input(lock)
	-- Nuke all button subscriptions
	Input_tracker:subscribe(not lock)
	if Mouse_input_tracker ~= nil then
		Mouse_input_tracker:subscribe(not lock)
	end
end
_anchor", 0, Save_load_doc)
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