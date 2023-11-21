Menu_hint_bar = -1

SAVE_OPERATION_SAVE_GAME = 0
SAVE_OPERATION_LOAD_GAME = 1
Save_system_operation = SAVE_OPERATION_LOAD_GAME

COOP_INVITE_LIST			= 0
COOP_ONLINE_JOIN_LIST  	= 1
COOP_SYSLINK_JOIN_LIST 	= 2
Coop_connect_operation = COOP_INVITE_LIST

In_pause_menu = true
Load_for_coop = false
Exit_after_closing = false
Save_message_displayed = false
Close_all_menu = false

Pause_menu_common_doc_h = -1

Header_obj = -1
List = -1
Screen_mask = -1
Screen_slide_out_anim = -1
Screen_slide_in_anim = -1
Screen_in_anim = -1
Screen_out_anim = -1
Screen_back_in_anim = -1
Screen_back_out_anim = -1

First_time = true
Start_game_after_display = false
Join_friend_after_display = -1

function pause_menu_common_init()
	
	Pause_menu_common_doc_h = vint_document_find("pause_menu_common")

	--Apply purple lut!
	pause_menu_lut_effect("lut_completion_screen")
	
	-- Play sound effect for pause menu starting up
	--play_ui_sound( "INT_PAUSE" )
	
	--Initialize Hint Bar store it to global Menu_hint_bar
	Menu_hint_bar = Vdo_hint_bar:new("hint_bar")
	
	Screen_mask = vint_object_find("screen_mask",0,Pause_menu_common_doc_h)
	
	Screen_in_anim = Vdo_anim_object:new("screen_in_anim",0,Pause_menu_common_doc_h)
	local twn = Vdo_tween_object:new("screen_in_twn", Screen_in_anim.handle)
	twn:set_end_event("menu_common_anim_in_cb")
	
	Screen_out_anim = Vdo_anim_object:new("screen_out_anim",0,Pause_menu_common_doc_h)
	local twn2 = Vdo_tween_object:new("screen_out_twn", Screen_out_anim.handle)
	twn2:set_end_event("menu_common_anim_out_cb")
	
	Screen_slide_out_anim = Vdo_anim_object:new("screen_slide_out_anim",0,Pause_menu_common_doc_h)
	local twn_out = Vdo_tween_object:new("screen_slide_out_twn1", Screen_slide_out_anim.handle)
	twn_out:set_end_event("menu_common_anim_out_cb")
	
	Screen_slide_in_anim = Vdo_anim_object:new("screen_slide_in_anim",0,Pause_menu_common_doc_h)
	local twn_in = Vdo_tween_object:new("screen_slide_in_twn1", Screen_slide_in_anim.handle)
	twn_in:set_end_event("menu_common_anim_in_cb")
	
	Screen_back_in_anim = Vdo_anim_object:new("screen_back_in_anim",0,Pause_menu_common_doc_h)
	local twn_back_in = Vdo_tween_object:new("back_in_twn1", Screen_back_in_anim.handle)
	twn_back_in:set_end_event("menu_common_anim_in_cb")
	
	Screen_back_out_anim = Vdo_anim_object:new("screen_back_out_anim",0,Pause_menu_common_doc_h)
	local twn_back_out = Vdo_tween_object:new("back_out_twn1", Screen_back_out_anim.handle)
	twn_back_out:set_end_event("menu_common_anim_out_cb")
	
	List = Vdo_mega_list:new("list",0,Pause_menu_common_doc_h)
	List:set_highlight_color(COLOR_STORE_REWARDS_PRIMARY, COLOR_STORE_REWARDS_SECONDARY)
	
	Header_obj = Vdo_pause_header:new("header",0,Pause_menu_common_doc_h)

	bg_saints_show(false)

	vint_apply_start_values(Screen_in_anim.handle)
end

function pause_menu_common_cleanup()
	-- Possibly, free up controller memory when document is unloaded...
	-- This also happens in pause_options_controls_config() but is done here in case the user presses
	-- The back button...
	pause_menu_control_scheme_init(false)

	--Remove purple lut...
	pause_menu_lut_effect("none")
end

function pause_menu_common_server_drop()
	Save_system_operation = SAVE_OPERATION_SAVE_GAME
	Exit_after_closing = true
	push_screen("pause_save_game")
end

function pause_menu_common_open_invite()
	Exit_after_closing = true
	push_screen("pause_invite_friends")
end

function pause_menu_common_open_cheat_save()
	Save_system_operation = SAVE_OPERATION_SAVE_GAME
	Close_all_menu = true
	push_screen("pause_save_game")
end

function pause_menu_intro_done()

	-- Jeff: This needs to be setup properly
	--pause_menu_top_anim_in()

end

-- Make the pause menu megalist look pause menu
--
function pause_menu_set_style(List, Header, Width, Num_pops)
	--get the list width
	local list_w, list_h = vint_get_property(List.handle, "screen_size")
	list_w = Width or list_w
	
	Header:set_visible(true)
	List:set_visible(true)
	
	local max_width = 1950
	local back_out_twn1_h = vint_object_find("back_out_twn1", Screen_back_out_anim.handle)
	local back_out_twn2_h = vint_object_find("back_out_twn2", Screen_back_out_anim.handle)
	local back_out_twn3_h = vint_object_find("back_out_twn3", Screen_back_out_anim.handle)
	
	if list_w > max_width then
		vint_set_property(back_out_twn1_h, "end_value", -1 * max_width, 1956)
		vint_set_property(back_out_twn2_h, "end_value", -1 * max_width, 690)
		vint_set_property(back_out_twn3_h, "end_value", -1 * max_width, 801)
	else
		vint_set_property(back_out_twn1_h, "end_value", -900, 1956)
		vint_set_property(back_out_twn2_h, "end_value", -900, 690)
		vint_set_property(back_out_twn3_h, "end_value", -900, 801)
	end
	
	local bg_anchor = 300
	if vint_is_std_res() then
		bg_anchor = 222
	end
	
	if not First_time then
		bg_saints_set_type(BG_TYPE_STRONGHOLD, true, list_w, bg_anchor)
		local mask_x,mask_y = vint_get_property(Screen_mask,"anchor")
		pause_menu_mask_morph(BG_TYPE_STRONGHOLD, list_w, mask_x)
			
		if Num_pops > 0 then
			vint_apply_start_values(Screen_slide_in_anim.handle)
			Screen_slide_in_anim:play(0)
		else
			vint_apply_start_values(Screen_back_in_anim.handle)
			Screen_back_in_anim:play(0)
		end
	else
		vint_set_property(Screen_mask,"screen_size",list_w,2400)
		bg_saints_set_type(BG_TYPE_STRONGHOLD, false, list_w, bg_anchor)
	end
end

function pause_menu_mask_morph( screen_type, size_end_x, anchor_end_x )
	--get handles for everyone
	local morph_anim_h = vint_object_find("screen_mask_anim", 0, Pause_menu_common_doc_h)
	local morph_scale_twn_h = vint_object_find("screen_mask_scale_twn", 0, Pause_menu_common_doc_h)
	local morph_anchor_twn_h = vint_object_find("screen_mask_anchor_twn", 0, Pause_menu_common_doc_h) 
	
	--set up the left shadow start and end values
	--get the starting x position
	--create the center anchor point from the width of the mask, only if we are center aligned
	if screen_type == BG_TYPE_CENTER then
		anchor_end_x = (anchor_end_x) - (size_end_x * 0.5)
	end
	
	--setup the anchor for the mask
	--get the starting x position
	local mask_anchor_start_x,mask_anchor_start_y = vint_get_property( Screen_mask, "anchor" )
	vint_set_property(morph_anchor_twn_h, "start_value", mask_anchor_start_x, mask_anchor_start_y )
	vint_set_property(morph_anchor_twn_h, "end_value", anchor_end_x, mask_anchor_start_y )
	
	--setup the scale of the mask
	--get the starting scale
	local size_start_x,size_start_y = vint_get_property(Screen_mask,"scale")
	--get the correct size, this fixes SD scale issues
	local adjusted_size_end_x,crap = element_get_scale_from_size(Screen_mask, size_end_x, 16*3)
	vint_set_property(morph_scale_twn_h, "start_value", size_start_x , size_start_y)
	vint_set_property(morph_scale_twn_h, "end_value", adjusted_size_end_x , size_start_y)
	
	--play the animation
	lua_play_anim(morph_anim_h, 0, Pause_menu_common_doc_h)	
end



--Wrapper for c++ lut swap function...
function pause_menu_lut_effect(lut_table_string)

	if lut_table_string ~= "none" then
		--local platform = game_get_platform()
		local lut_platform_string = ""
		
		--if platform == "PS4" then
		--	lut_platform_string = "_ps4"
		--elseif platform == "XBOX3" then
		--	lut_platform_string = "_xb1"
		--elseif platform == "PC" then
			lut_platform_string = "_pc"
		--end
		completion_load_lut(lut_table_string .. lut_platform_string)
	else
		completion_load_lut(lut_table_string)
	end
end--------------------------------------------------------------------------- 
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
end