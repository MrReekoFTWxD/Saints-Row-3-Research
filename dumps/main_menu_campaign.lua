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
