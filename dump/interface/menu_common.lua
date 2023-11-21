--------------------------------------------------------------------------- 
-- Stack tracking for the pause menu. Keeps track of the current index for
-- a particular menu system. Each screen must manage the retreiving, adding 
-- and removal of the stack.
---------------------------------------------------------------------------
Menu_common_stack = {}
Menu_common_stack.current_stack = 0

Current_menu_anim_in_cb = 0

--------------------------------------------------------------------------- 
-- Adds an element to the stack. Use when making a selection on the menu.
-- @param index	Index of the current selected option
---------------------------------------------------------------------------
function menu_common_stack_add(index)
	Menu_common_stack[Menu_common_stack.current_stack] = index
	Menu_common_stack.current_stack = Menu_common_stack.current_stack + 1
end

--------------------------------------------------------------------------- 
-- Removes an element from the stack. Use when going back a menu.
---------------------------------------------------------------------------
function menu_common_stack_remove()
	--Nothing in menu stack return default selection
	if Menu_common_stack.current_stack == 0 then
		return
	end

	--Remove value of current stack
	Menu_common_stack[Menu_common_stack.current_stack] = nil
	Menu_common_stack.current_stack = Menu_common_stack.current_stack - 1
end

--------------------------------------------------------------------------- 
-- Returns the current index for a particular menu.
---------------------------------------------------------------------------
function menu_common_stack_get_index(data)
	--Nothing stored in the current stack then return default index
	local stack_id = Menu_common_stack[Menu_common_stack.current_stack]
	if stack_id == nil then
		--No stack created, select first item in list...
		return 1
	end

	local option_selected = stack_id
	
	--if data is defined then loop through and find the currently selected option from id.
	if data ~= nil then	
		for i = 1, #data do
			if data[i].id == stack_id then
				option_selected = i
				break
			end
		end
	end
	
	--Remove value of current stack
	return option_selected
end

--------------------------------------------------------------------------- 
-- + Input blocking for each menu during transitions...
-- + Push/Pop queueing for after transitions...
---------------------------------------------------------------------------
local Current_menu_input_tracker		= 0		--Local to store the current input tracker 
local Current_mouse_input_tracker	= 0		--Local to store the current mouse input tracker 
local Current_menu_list					= 0		--Local to store the current list
local Current_menu_header				= 0		--Local to store the current header 
local Menu_common_push_screen 		= ""		--Local to store the current screen to push 
local Menu_common_num_pops				= 0		--Local to store the current times to pop 
local Current_menu_anim_pop			= 0		--Local to store the current pop animation
local Current_menu_anim_push			= 0		--Local to store the current push animation

--Stores local screen data and sets callbacks for screen subscriptions...
function menu_common_set_screen_data(list, header, input_tracker, push_anim, pop_anim, anim_in_cb)
	
	Current_menu_list = list
	Current_menu_header = header
	Current_menu_input_tracker = input_tracker
	Current_menu_anim_pop = pop_anim
	Current_menu_anim_push = push_anim
	
	if anim_in_cb ~= nil then
		Current_menu_anim_in_cb = anim_in_cb
	else
		Current_menu_anim_in_cb = 0
	end
	
	--reset transition out variables...
	Menu_common_push_screen = ""
	Menu_common_num_pops = 0
	
	-- Use this later for transitioning megalist... JMH(4/27/2011)
	--list:set_anim_in_cb("menu_common_anim_in_cb")
	--list:set_anim_out_cb("menu_common_anim_out_cb")
	--menu_common_anim_in_cb()
end

--Callback for when the menus are done transitioning...
function menu_common_anim_in_cb()
	if Current_menu_input_tracker ~= nil and Current_menu_input_tracker ~= 0 then
		Current_menu_input_tracker:subscribe(true)
	end
	
	if Current_mouse_input_tracker ~= nil and Current_mouse_input_tracker ~= 0 then
		Current_mouse_input_tracker:subscribe(true)
	end
	
	if Current_menu_anim_in_cb ~= 0 then
		Current_menu_anim_in_cb()
	end
end

--Callback for when the menus are done transitioning...
function menu_common_anim_out_cb()

	--Pop or push screen?
	if Menu_common_num_pops == 0 and Menu_common_push_screen ~= "" then
		--Push screen
		push_screen(Menu_common_push_screen)
	else
		--Pop Screen
		for i = 1, Menu_common_num_pops do
			pop_screen()
		end
	end
end


-- Transition into another screen...
-- @param	target_screen		string of target screen... i.e. "pause_options_menu"
function menu_common_transition_push(target_screen)
	if Current_menu_input_tracker ~= nil and Current_menu_input_tracker ~= 0 then
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
endio'0