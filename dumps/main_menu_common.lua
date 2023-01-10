Menu_hint_bar = -1
Main_menu_coop_is_xbox_live = -1			-- bool to determine whether main_menu_coop is xbox live or system link...
Main_menu_common_doc = -1

Header_obj = -1
List = -1
Screen_mask = -1
Screen_slide_out_anim = -1
Screen_slide_in_anim = -1
Screen_in_anim = -1
Screen_out_anim = -1
Screen_back_in_anim = -1
Screen_back_out_anim = -1

SAVE_OPERATION_SAVE_GAME = 0
SAVE_OPERATION_LOAD_GAME = 1
Save_system_operation = SAVE_OPERATION_LOAD_GAME

COOP_INVITE_LIST			= 0
COOP_ONLINE_JOIN_LIST  	= 1
COOP_SYSLINK_JOIN_LIST 	= 2
Coop_connect_operation = COOP_ONLINE_JOIN_LIST

Enter_dlc_menu = false
Load_for_coop = false
In_pause_menu = false
Exit_after_closing = false
Whored_mode_active = false
First_time = true
Save_message_displayed = false
Start_game_after_display = false
Show_continue = false
Press_start_called = false
Close_all_menu = false
Join_friend_after_display = -1

-- PC Menu has height adjusted
local PC_menu_adjusted = false

function main_menu_common_init()
	Main_menu_common_doc = vint_document_find("main_menu_common")

	-- Japanese Logo version...
	local logo_jp_h = vint_object_find("logo_jp")
	
	--Adjust logo if we are japanese...
	if game_get_language() == "JP" then
		vint_set_property(logo_jp_h, "visible", true)
	else
		vint_set_property(logo_jp_h, "visible", false)
	end
	
	List = Vdo_mega_list:new("list",0,Main_menu_common_doc)
	List:set_highlight_color(COLOR_STORE_REWARDS_PRIMARY, COLOR_STORE_REWARDS_SECONDARY)
	
	Header_obj = Vdo_pause_header:new("header",0,Main_menu_common_doc)
	
	List:set_visible(false)
	Header_obj:set_visible(false)
	
	Screen_mask = vint_object_find("screen_mask",0,Main_menu_common_doc)
	
	Screen_in_anim = Vdo_anim_object:new("screen_in_anim",0,Main_menu_common_doc)
	local twn = Vdo_tween_object:new("screen_in_twn", Screen_in_anim.handle)
	twn:set_end_event("menu_common_anim_in_cb")
	
	Screen_out_anim = Vdo_anim_object:new("screen_out_anim",0,Main_menu_common_doc)
	local twn2 = Vdo_tween_object:new("screen_out_twn", Screen_out_anim.handle)
	twn2:set_end_event("menu_common_anim_out_cb")
	
	Screen_slide_out_anim = Vdo_anim_object:new("screen_slide_out_anim",0,Main_menu_common_doc)
	local twn_out = Vdo_tween_object:new("screen_slide_out_twn1", Screen_slide_out_anim.handle)
	twn_out:set_end_event("menu_common_anim_out_cb")
	
	Screen_slide_in_anim = Vdo_anim_object:new("screen_slide_in_anim",0,Main_menu_common_doc)
	local twn_in = Vdo_tween_object:new("screen_slide_in_twn1", Screen_slide_in_anim.handle)
	twn_in:set_end_event("menu_common_anim_in_cb")
	
	Screen_back_in_anim = Vdo_anim_object:new("screen_back_in_anim",0,Main_menu_common_doc)
	local twn_back_in = Vdo_tween_object:new("back_in_twn1", Screen_back_in_anim.handle)
	twn_back_in:set_end_event("menu_common_anim_in_cb")
	
	Screen_back_out_anim = Vdo_anim_object:new("screen_back_out_anim",0,Main_menu_common_doc)
	local twn_back_out = Vdo_tween_object:new("back_out_twn1", Screen_back_out_anim.handle)
	twn_back_out:set_end_event("menu_common_anim_out_cb")
	
	bg_saints_show(false)
	
	bg_saints_set_type(BG_TYPE_CENTER,true)
	
	--Hide everything on init...
	main_menu_logo_hide()
	
	-- Move the title up on PC to make room for the extra options
	if game_get_platform() == "PC" and PC_menu_adjusted == false then
		local base_logo_h = vint_object_find("base_logo")
		local x, y = vint_get_property(base_logo_h, "anchor")
		if vint_is_std_res() then
			vint_set_property(base_logo_h, "anchor", x, y - 35*3)
		else
			vint_set_property(base_logo_h, "anchor", x, y - 25*3)
		end
		PC_menu_adjusted = true
	end
end

function main_menu_common_cleanup()
end

-------------------------------------------------------------------------------
-- Start the bg video...
-------------------------------------------------------------------------------
function main_menu_start_video(has_pressed_start)
	bg_saints_set_video("main_menu_bg.bik")
	if not has_pressed_start then
		bg_saints_press_start_setup()
	end
	bg_saints_play_video(true, "video_stopped")
	
	if has_pressed_start == true then 
		bg_saints_main_menu_setup()
	end
end

function main_menu_stop_video()
	bg_saints_play_video(false, "video_stopped")
end

function video_stopped()
	main_menu_video_has_stopped()
end

function main_menu_common_reset()
	main_menu_restart_video()
	-- Move the title up on PC to make room for the extra options
	if game_get_platform() == "PC" then
		local base_logo_h = vint_object_find("base_logo")
		local x, y = vint_get_property(base_logo_h, "anchor")
		if vint_is_std_res() then
			vint_set_property(base_logo_h, "anchor", x, y - 35*3)
		else
			vint_set_property(base_logo_h, "anchor", x, y - 25*3)
		end
		PC_menu_adjusted = true
	end
end

-------------------------------------------------------------------------------
-- Show logo...
-------------------------------------------------------------------------------
function main_menu_logo_show()
	--show the main menu logo.
	local intro_logo_anim_h = vint_object_find("intro_logo_anim", 0, Main_menu_common_doc)
	lua_play_anim(intro_logo_anim_h, 0, Main_menu_common_doc)
	First_time = true
end

-------------------------------------------------------------------------------
-- Hide logo...
-------------------------------------------------------------------------------
function main_menu_logo_hide()
	--we probably don't need this...
	local intro_logo_anim_h = vint_object_find("intro_logo_anim", 0, Main_menu_common_doc)
	vint_set_property(intro_logo_anim_h, "is_paused", true)
	
	local logo_h = vint_object_find("logo", 0, Main_menu_common_doc)
	vint_set_property(logo_h, "alpha", 0)
	
end

-------------------------------------------------------------------------------
---LEGACY C++ stuff from the old main menu...
-- Lets clean this up.
-------------------------------------------------------------------------------
function main_menu_controller_selected(show_continue)
	Main_menu_controller_is_selected = true
	Show_continue = show_continue
	
	main_menu_top_press_start_hide()
	main_menu_top_menu_show()
	
	if Press_start_called == false then
		bg_saints_main_menu_setup()
		Press_start_called = true
	end
end

--FORCES the player to a specific menu...
function main_menu_force_to_menu()
	--Don't do anything because we shouldn't
--[[
	if Main_menu_controller_selected == false then
		Main_menu_first_menu = menu_name
	else
		main_menu_close_extra_screens(true)
		if menu_name == "top" then
			if Main_menu_controller_selected == true then
				menu_hide_active()
				vint_set_property(vint_object_find("safe_frame"), "visible", true)
				Main_menu_can_has_input = true
				menu_input_block(false)
				main_menu_screen_fade(0)
			end
			
			main_menu_grab_input()
			dialog_box_force_close_all()
		elseif menu_name == "coop_load" then
			credits_force_close()
			Pause_load_is_coop = true
			vint_set_property(vint_object_find("safe_frame"), "visible", true)
			main_menu_load_menu_select()
		elseif menu_name == "customize" then
			vint_set_property(vint_object_find("safe_frame"), "visible", true)
			main_menu_customize_menu_select()
		end
	end
]]
end

function main_menu_nav(target, event)
	-- We will try and use input tracker...
	--do nothing
end

function load_before_join()
	Load_for_coop = true
	push_screen("pause_save_game")
end

-- Make the megalist look main menuy
--
function main_menu_set_style(List, Header, Width, Num_pops)
	
	Header:set_visible(true)
	List:set_visible(true)
	
	--get the list width
	local list_w, list_h = vint_get_property(List.handle, "screen_size")
	list_w = Width or list_w

	local new_x
	if vint_is_std_res() == false then
		new_x = 640 * 3
	else
		new_x = (320 * 1.5) * 3
	end
	new_x = new_x - (list_w * 0.5)
	
	local list_tween_h
	local header_tween_h
	local hint_bar_tween_h
	
	local max_width = 650*3
	local back_out_twn1_h = vint_object_find("back_out_twn1", Screen_back_out_anim.handle)
	local back_out_twn2_h = vint_object_find("back_out_twn2", Screen_back_out_anim.handle)
	local back_out_twn3_h = vint_object_find("back_out_twn3", Screen_back_out_anim.handle)
	
	local slide_out_twn1_h = vint_object_find("screen_slide_out_twn1", Screen_slide_out_anim.handle)
	local slide_out_twn2_h = vint_object_find("screen_slide_out_twn2", Screen_slide_out_anim.handle)
	local slide_out_twn3_h = vint_object_find("screen_slide_out_twn3", Screen_slide_out_anim.handle)
	
	if list_w > max_width then
		vint_set_property(back_out_twn1_h, "end_value", -1 * max_width, 652*3)
		vint_set_property(back_out_twn2_h, "end_value", -1 * max_width, 230*3)
		vint_set_property(back_out_twn3_h, "end_value", -1 * max_width, 267*3)
		
		vint_set_property(slide_out_twn1_h, "end_value", 1100*3, 652*3)
		vint_set_property(slide_out_twn2_h, "end_value", 1100*3, 267*3)
		vint_set_property(slide_out_twn3_h, "end_value", 1150*3, 230*3)
	else
		vint_set_property(back_out_twn1_h, "end_value", -300*3, 652*3)
		vint_set_property(back_out_twn2_h, "end_value", -300*3, 230*3)
		vint_set_property(back_out_twn3_h, "end_value", -300*3, 267*3)
		
		vint_set_property(slide_out_twn1_h, "end_value", 900*3, 652*3)
		vint_set_property(slide_out_twn2_h, "end_value", 900*3, 267*3)
		vint_set_property(slide_out_twn3_h, "end_value", 950*3, 230*3)
	end
	
	if not First_time then
		bg_saints_set_type(BG_TYPE_CENTER, true, list_w)
		local mask_x,mask_y = vint_get_property(Screen_mask, "anchor")
		main_menu_mask_morph(BG_TYPE_CENTER, list_w, new_x)
			
		if Num_pops > 0 then
			main_menu_set_slide_in_values( new_x )
			vint_apply_start_values(Screen_slide_in_anim.handle)
			Screen_slide_in_anim:play(0)
		else
			main_menu_set_back_in_values( new_x )
			vint_apply_start_values(Screen_back_in_anim.handle)
			Screen_back_in_anim:play(0)
		end
	else
		main_menu_center_layout( new_x )
		--vint_set_property(Screen_mask,"screen_size", list_w, 800)
		main_menu_mask_morph(BG_TYPE_CENTER, list_w, new_x)
		bg_saints_set_type(BG_TYPE_CENTER, false, list_w)
	end
end

function main_menu_mask_morph( screen_type, size_end_x, anchor_end_x )
	--get handles for everyone
	local morph_anim_h = vint_object_find("screen_mask_anim", 0, Main_menu_common_doc)
	local morph_scale_twn_h = vint_object_find("screen_mask_scale_twn", 0, Main_menu_common_doc)
	local morph_anchor_twn_h = vint_object_find("screen_mask_anchor_twn", 0, Main_menu_common_doc) 
	
	--create the center anchor point from the width of the mask
	--anchor_end_x = (anchor_end_x) - (size_end_x * 0.5)

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
	lua_play_anim(morph_anim_h, 0, Main_menu_common_doc)	
end

function main_menu_set_slide_in_values( new_x )
	local hint_anchor_twn_h = vint_object_find("screen_slide_in_twn1", 0, Main_menu_common_doc)
	local header_anchor_twn_h = vint_object_find("screen_slide_in_twn3", 0, Main_menu_common_doc) 
	local list_anchor_twn_h = vint_object_find("screen_slide_in_twn2", 0, Main_menu_common_doc) 
	
	local hint_x,hint_y = vint_get_property(hint_anchor_twn_h, "end_value")
	local header_x,header_y = vint_get_property(header_anchor_twn_h, "end_value")
	local list_x,list_y = vint_get_property(list_anchor_twn_h, "end_value")
	
	vint_set_property(hint_anchor_twn_h, "end_value", new_x + 17*3, hint_y)
	vint_set_property(header_anchor_twn_h, "end_value", new_x + 30*3, header_y)
	vint_set_property(list_anchor_twn_h, "end_value", new_x, list_y)
end

function main_menu_set_back_in_values( new_x )
	local hint_anchor_twn_h = vint_object_find("back_in_twn1", 0, Main_menu_common_doc)
	local header_anchor_twn_h = vint_object_find("back_in_twn3", 0, Main_menu_common_doc) 
	local list_anchor_twn_h = vint_object_find("back_in_twn2", 0, Main_menu_common_doc) 
	
	local hint_x,hint_y = vint_get_property(hint_anchor_twn_h, "end_value")
	local header_x,header_y = vint_get_property(header_anchor_twn_h, "end_value")
	local list_x,list_y = vint_get_property(list_anchor_twn_h, "end_value")
	
	vint_set_property(hint_anchor_twn_h, "end_value", new_x + 17*3, hint_y)
	vint_set_property(header_anchor_twn_h, "end_value", new_x + 30*3, header_y)
	vint_set_property(list_anchor_twn_h, "end_value", new_x, list_y)
end

function main_menu_center_layout( new_x )
	--get the list x and y
	local list_x, list_y = vint_get_property(List.handle, "anchor")
	local header_x, header_y = vint_get_property(Header_obj.handle, "anchor")
	local hint_anchor_twn_h = vint_object_find("back_in_twn1", 0, Main_menu_common_doc)
	local hint_x,hint_y = vint_get_property(hint_anchor_twn_h, "end_value")
	
	vint_set_property(List.handle, "anchor", new_x, list_y)
	vint_set_property(Header_obj.handle, "anchor", new_x + 30*3, header_y)
	vint_set_property(Menu_hint_bar.handle, "anchor", new_x + 17*3, hint_y)
	vint_set_property(Screen_mask, "anchor", new_x, -58*3)
end