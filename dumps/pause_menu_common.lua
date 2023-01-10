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
end