--Document handle
Hud_qte_key_doc_h = 0

-- handles
Hud_qte_btn_1_grp_h = 0
Hud_qte_btn_1_h = 0
Hud_qte_btn_2_h = 0
Hud_qte_sticks_grp_h = 0
Hud_qte_stick_pad_h = 0
Hud_qte_stick_base_h = 0
Hud_qte_stick_arrow_h = 0
Hud_qte_stick_label_h = 0
Hud_qte_success_grp_h = 0
Hud_qte_kb_grp_h = 0
Hud_qte_mouse_grp_h = 0

--QTE Vdo Objects
Hud_qte_kb_key = 0


-- button_index values
HUD_QTE_BTN_HIDDEN 	= -1
HUD_QTE_BTN_A 			= 0
HUD_QTE_BTN_X 			= 1
HUD_QTE_BTN_Y 			= 2
HUD_QTE_BTN_LT 		= 3
HUD_QTE_BTN_RT 		= 4
HUD_QTE_STICK_UP		= 5
HUD_QTE_STICK_DOWN	= 6
HUD_QTE_STICK_RIGHT	= 7
HUD_QTE_STICK_LEFT	= 8

-- button_animation values
HUD_QTE_ANIM_NONE							= -1
HUD_QTE_ANIM_MASH_STANDARD				= 0
HUD_QTE_ANIM_MASH_FAST					= 1
HUD_QTE_ANIM_ALTERNATE_TRIGGERS		= 2

-- storage
Hud_qte_prev_btn = 0
Hud_qte_prev_anim = 0

--Mouse key inputs...
local MOUSE_KEY_INVALID 	= -1
local MOUSE_KEY_LEFT 		= 0
local MOUSE_KEY_MIDDLE 		= 1
local MOUSE_KEY_RIGHT 		= 2
local MOUSE_KEY_4 			= 3
local MOUSE_KEY_5 			= 4
local MOUSE_KEY_WHEEL_UP 	= 5
local MOUSE_KEY_WHEEL_DOWN	= 6
				
--mouse highlights...
local Hud_qte_mouse_highlights = {
	[MOUSE_KEY_LEFT] 			= "uhd_ui_qte_mouse_0",
	[MOUSE_KEY_MIDDLE] 		= "uhd_ui_qte_mouse_2",
	[MOUSE_KEY_RIGHT] 		= "uhd_ui_qte_mouse_1",
	[MOUSE_KEY_4] 				= "uhd_ui_qte_mouse_base_highlight",
	[MOUSE_KEY_5] 				= "uhd_ui_qte_mouse_base_highlight",
	[MOUSE_KEY_WHEEL_UP] 	= "uhd_ui_qte_mouse_scroll_up",
	[MOUSE_KEY_WHEEL_DOWN] 	= "uhd_ui_qte_mouse_scroll_down",
}

--mouse icons...
local Hud_qte_mouse_icons = {
	[MOUSE_KEY_LEFT] 			= "uhd_ui_qte_mouse_fluer",
	[MOUSE_KEY_MIDDLE] 		= "uhd_ui_qte_mouse_fluer",
	[MOUSE_KEY_RIGHT] 		= "uhd_ui_qte_mouse_fluer",
	[MOUSE_KEY_4] 				= "uhd_ui_qte_mouse_3",
	[MOUSE_KEY_5] 				= "uhd_ui_qte_mouse_4",
	[MOUSE_KEY_WHEEL_UP] 	= "uhd_ui_qte_mouse_fluer",
	[MOUSE_KEY_WHEEL_DOWN] 	= "uhd_ui_qte_mouse_fluer",
}
Hud_qte_mouse_success_bitmaps = {}
Hud_qte_mouse_success_anims = {}

function hud_qte_init()
	Hud_qte_key_doc_h = vint_document_find("hud_qte")
	
	-- assign handles
	Hud_qte_btn_1_grp_h = vint_object_find("btn_1_grp")
	Hud_qte_btn_1_h = vint_object_find("btn_1")		
	Hud_qte_btn_2_h = vint_object_find("btn_2")
	
	Hud_qte_sticks_grp_h 	= vint_object_find("qte_sticks_grp")
	Hud_qte_stick_pad_h 		= vint_object_find("stick_pad")
	Hud_qte_stick_base_h 	= vint_object_find("stick_base_bmp")
	Hud_qte_stick_arrow_h 	= vint_object_find("stick_arrow")
	Hud_qte_stick_label_h 	= vint_object_find("stick_label")
	Hud_qte_kb_grp_h 			= vint_object_find("qte_keyboard_grp")
	Hud_qte_kb_key 			= Vdo_qte_key:new("qte_key", 0, Hud_qte_key_doc_h)
	Hud_qte_mouse_grp_h 		= vint_object_find("qte_mouse_grp")
	
	
	Hud_qte_success_grp_h 	= vint_object_find("qte_success_grp")

	-- set animation loops for QTE's
	local btn_1_off_standard_twn_h = vint_object_find("btn_1_off_standard")
	local btn_1_off_fast_twn_h 	= vint_object_find("btn_1_off_fast")
	local stick_pressed_twn_h 		= vint_object_find("stick_pressed_twn")
	vint_set_property(btn_1_off_standard_twn_h, "end_event", "vint_anim_loop_callback")		
	vint_set_property(btn_1_off_fast_twn_h, "end_event", "vint_anim_loop_callback")		
	vint_set_property(stick_pressed_twn_h, "end_event", "vint_anim_loop_callback")		
	
	-- subscription
	vint_dataitem_add_subscription("hud_qte", "update", "hud_qte_update")
end

function hud_qte_update(di_h, event)
	local button_index, button_animation, x, y, is_ps4, kbm_name, success, mouse_button_number = vint_dataitem_get(di_h)
	
	-- set button group position
	vint_set_property(Hud_qte_btn_1_grp_h, 	"anchor", x, y)		
	vint_set_property(Hud_qte_sticks_grp_h, 	"anchor", x, y)		
	vint_set_property(Hud_qte_success_grp_h, 	"anchor", x, y)		
	vint_set_property(Hud_qte_kb_grp_h, 		"anchor", x, y - (40 * 3))		--moving the key up so it does not interfere with subtitles...
	vint_set_property(Hud_qte_mouse_grp_h, 	"anchor", x, y)
	
	-- determine button visibility
	vint_set_property(Hud_qte_btn_1_h, "visible", false)
	vint_set_property(Hud_qte_btn_2_h, "visible", false)
	vint_set_property(Hud_qte_sticks_grp_h, "visible", false)
	vint_set_property(Hud_qte_success_grp_h, "visible", false)

	vint_set_property(Hud_qte_kb_grp_h, "visible", false)
	vint_set_property(Hud_qte_mouse_grp_h, "visible", false)
	
	if (button_index ~= HUD_QTE_BTN_HIDDEN) then 
		if game_is_active_input_gamepad() == false then
			--determine if mouse or key...
			if mouse_button_number == -1 then
				--Show the keyboard key...
				vint_set_property(Hud_qte_kb_grp_h, "visible", true)
				
				--Set text...
				Hud_qte_kb_key:set_text(kbm_name)
				
				--Trigger animation...
				Hud_qte_kb_key:mash(button_animation)
				
				--Center QTE
				local width = Hud_qte_kb_key:get_width()
				local x, y = vint_get_property(Hud_qte_kb_key.handle, "anchor")
				vint_set_property(Hud_qte_kb_key.handle, "anchor", -width * .5, y)
				
				--Play succes animation?
				Hud_qte_kb_key:success(success)
			else

				--Show mouse
				vint_set_property(Hud_qte_mouse_grp_h, "visible", true)
				
				--Update buttons
				local mouse_highlight_h = vint_object_find("mouse_highlight")
				local mouse_icon_h = vint_object_find("mouse_icon")
				
				local mouse_highlight = Hud_qte_mouse_highlights[mouse_button_number]
				local mouse_icon = Hud_qte_mouse_icons[mouse_button_number]
				vint_set_property(mouse_highlight_h, "image", mouse_highlight)
				vint_set_property(mouse_icon_h, "image", mouse_icon)

				if	(button_animation == HUD_QTE_ANIM_NONE) then 		
					hud_qte_pause_all()
					vint_set_property(mouse_highlight_h, "alpha", 0)
				elseif (button_animation == HUD_QTE_ANIM_MASH_STANDARD or button_animation == HUD_QTE_ANIM_MASH_FAST) then
					lua_play_anim(vint_object_find("mouse_mash_standard_anim"))
				end
				
				local mouse_success_anim_h = vint_object_find("mouse_success_anim")
				local mouse_success_h = vint_object_find("mouse_success")
				vint_set_property(mouse_success_h, "alpha", 0)
				
				if #Hud_qte_mouse_success_bitmaps ~= 0 then
					for i = 1, #Hud_qte_mouse_success_bitmaps do
						vint_object_destroy(Hud_qte_mouse_success_bitmaps[i])
						vint_object_destroy(Hud_qte_mouse_success_anims[i])
					end
					Hud_qte_mouse_success_bitmaps = {}
					Hud_qte_mouse_success_anims = {}
				end
				
				if success then
					--create mouse success items
					for i = 1, 4 do
						Hud_qte_mouse_success_bitmaps[i] = vint_object_clone(mouse_success_h)
						Hud_qte_mouse_success_anims[i] = vint_object_clone(mouse_success_anim_h)
						vint_set_property(Hud_qte_mouse_success_anims[i], "target_handle", Hud_qte_mouse_success_bitmaps[i])
						lua_play_anim(Hud_qte_mouse_success_anims[i], (i - 1) * .1)
					end
					vint_set_property(mouse_highlight_h, "visible", false)
				else
					vint_set_property(mouse_highlight_h, "visible", true)
				end
			end
		else
			--Show buttons if index is lower than the stick indexes...
			if button_index < HUD_QTE_STICK_UP then
				vint_set_property(Hud_qte_btn_1_h, "visible", true)
				-- if animation exists make second image visible
				if (button_animation ~= HUD_QTE_ANIM_NONE) then
					vint_set_property(Hud_qte_btn_2_h, "visible", true)
				end		
			end
			
			--Adjust stuff if button_index is a stick...
			if (button_index >= HUD_QTE_STICK_UP and button_index <= HUD_QTE_STICK_LEFT ) then
				--Uses stick index so show stick and adjust settings accordingly...
				vint_set_property(Hud_qte_sticks_grp_h, "visible", true)
				local stick_pressed_twn_h = vint_object_find("stick_pressed_twn")
				
				--Set Callback to playback anim...
				vint_set_property(stick_pressed_twn_h, "end_event", "vint_anim_loop_callback")		
				lua_play_anim(vint_object_find("stick_direction"))
				
				if (button_index == HUD_QTE_STICK_UP) then -- R2
					-- Rotate arrow pointing up...
					vint_set_property(Hud_qte_stick_arrow_h, "rotation", 0)
					
					--Modify Tweens to move stick up...
					vint_set_property(stick_pressed_twn_h, "start_value", 0, -15 * 3)
					vint_set_property(stick_pressed_twn_h, "end_value", 0, -15 * 3)
					
				elseif (button_index == HUD_QTE_STICK_DOWN) then
					--Rotate arrow pointing down..
					vint_set_property(Hud_qte_stick_arrow_h, "rotation", 3.147)
					
					--Modify Tweens to move stick down...
					vint_set_property(stick_pressed_twn_h, "start_value", 0, 15 * 3)
					vint_set_property(stick_pressed_twn_h, "end_value", 0, 15 * 3)
				elseif (button_index == HUD_QTE_STICK_RIGHT) then -- R2
					-- Rotate arrow pointing right...
					vint_set_property(Hud_qte_stick_arrow_h, "rotation", 90 * DEG_TO_RAD)
					
					--Modify Tweens to move stick right...
					vint_set_property(stick_pressed_twn_h, "start_value", 0, 0)
					vint_set_property(stick_pressed_twn_h, "end_value", 15 * 3, 0)
					
				elseif (button_index == HUD_QTE_STICK_LEFT) then
					--Rotate arrow pointing left..
					vint_set_property(Hud_qte_stick_arrow_h, "rotation", 270 * DEG_TO_RAD)
					
					--Modify Tweens to move stick left...
					vint_set_property(stick_pressed_twn_h, "start_value", 0, 0)
					vint_set_property(stick_pressed_twn_h, "end_value", -15 * 3, 0)				
				end
			end
			
			-- Set button images
			if (is_ps4 == true) then		
				if			(button_index == HUD_QTE_BTN_A) then -- CROSS
					vint_set_property(Hud_qte_btn_1_h, "image", "uhd_ui_qte_ps4_cross_up")
					vint_set_property(Hud_qte_btn_2_h, "image", "uhd_ui_qte_ps4_cross_down")													
				elseif	(button_index == HUD_QTE_BTN_X) then -- SQUARE
					vint_set_property(Hud_qte_btn_1_h, "image", "uhd_ui_qte_ps4_square_up")
					vint_set_property(Hud_qte_btn_2_h, "image", "uhd_ui_qte_ps4_square_down")
				elseif	(button_index == HUD_QTE_BTN_Y) then -- TRIANGLE
					vint_set_property(Hud_qte_btn_1_h, "image", "uhd_ui_qte_ps4_triangle_up")
					vint_set_property(Hud_qte_btn_2_h, "image", "uhd_ui_qte_ps4_triangle_down")
				elseif	(button_index == HUD_QTE_BTN_LT) then -- L2
					vint_set_property(Hud_qte_btn_1_h, "image", "uhd_ui_qte_ps4_l2")
					vint_set_property(Hud_qte_btn_2_h, "image", "uhd_ui_qte_ps4_l2_down")			
				elseif	(button_index == HUD_QTE_BTN_RT) then -- **CHANGING RT TO MAP TO R2 ON PS4 BECAUSE R2 IS USED FOR SHOOTING ON PS4**
					vint_set_property(Hud_qte_btn_1_h, "image", "uhd_ui_qte_ps4_r2")
					vint_set_property(Hud_qte_btn_2_h, "image", "uhd_ui_qte_ps4_r2_down")	
				elseif	(button_index >= HUD_QTE_STICK_UP and button_index <= HUD_QTE_STICK_LEFT ) then --Stick			
					vint_set_property(Hud_qte_stick_pad_h, "image", "uhd_ui_ps4_ctrl-stick_thumb")
					vint_set_property(Hud_qte_stick_base_h, "image", "uhd_ui_ps4_ctrl_base")
					vint_set_property(Hud_qte_stick_arrow_h, "image", "uhd_ui_qte_ps4_arrow")
					vint_set_property(Hud_qte_stick_label_h, "text_tag", "L")
				else
					--If btn value isn't accounted for throw up a garbage texture to let us know in game
					vint_set_property(Hud_qte_btn_1_h, "image", "uhd_ui_hud_not_police")
					vint_set_property(Hud_qte_btn_2_h, "image", "uhd_ui_hud_not_police")			
				end					
			else	
				if			(button_index == HUD_QTE_BTN_A) then 
					vint_set_property(Hud_qte_btn_1_h, "image", "uhd_ui_qte_xbox_a_up")
					vint_set_property(Hud_qte_btn_2_h, "image", "uhd_ui_qte_xbox_a_down")													
				elseif	(button_index == HUD_QTE_BTN_X) then 
					vint_set_property(Hud_qte_btn_1_h, "image", "uhd_ui_qte_xbox_x_up")
					vint_set_property(Hud_qte_btn_2_h, "image", "uhd_ui_qte_xbox_x_down")
				elseif	(button_index == HUD_QTE_BTN_Y) then 
					vint_set_property(Hud_qte_btn_1_h, "image", "uhd_ui_qte_xbox_y_up")
					vint_set_property(Hud_qte_btn_2_h, "image", "uhd_ui_qte_xbox_y_down")
				elseif	(button_index == HUD_QTE_BTN_LT) then 
					vint_set_property(Hud_qte_btn_1_h, "image", "uhd_ui_qte_xbox_lt_up")
					vint_set_property(Hud_qte_btn_2_h, "image", "uhd_ui_qte_xbox_lt_down")			
				elseif	(button_index == HUD_QTE_BTN_RT) then 
					vint_set_property(Hud_qte_btn_1_h, "image", "uhd_ui_qte_xbox_rt_up")
					vint_set_property(Hud_qte_btn_2_h, "image", "uhd_ui_qte_xbox_rt_down")			
				elseif	(button_index >= HUD_QTE_STICK_UP and button_index <= HUD_QTE_STICK_LEFT ) then --Stick
					vint_set_property(Hud_qte_stick_pad_h, "image", "uhd_ui_xbox_ctrl-stick_thunb")
					vint_set_property(Hud_qte_stick_base_h, "image", "uhd_ui_xbox_ctrl_base")
					vint_set_property(Hud_qte_stick_arrow_h, "image", "uhd_ui_qte_xbox_arrow")
					vint_set_property(Hud_qte_stick_label_h, "text_tag", "LS")
				else
					--If btn value isn't accounted for throw up a garbage texture to let us know in game
					vint_set_property(Hud_qte_btn_1_h, "image", "uhd_ui_hud_not_police")
					vint_set_property(Hud_qte_btn_2_h, "image", "uhd_ui_hud_not_police")			
				end			
			end
			
			--adjust success graphic anchor for buttons
			
			if (button_index >= HUD_QTE_BTN_A and button_index <= HUD_QTE_BTN_RT ) then
				local button_width, button_height = vint_get_property(Hud_qte_btn_1_h, "screen_size")--element_get_actual_size(Hud_qte_btn_1_h)
				local qte_x, qte_y = vint_get_property(Hud_qte_success_grp_h, "anchor")
				local new_y = qte_y - button_height * 0.5
				
				vint_set_property(Hud_qte_success_grp_h, "anchor", qte_x, new_y)			
			end

			-- Play mash anim...
			if			(button_animation == HUD_QTE_ANIM_NONE) then 		
				hud_qte_pause_all()
			elseif	(button_animation == HUD_QTE_ANIM_MASH_STANDARD) then 	
				lua_play_anim(vint_object_find("mash_standard"))
			elseif	(button_animation == HUD_QTE_ANIM_MASH_FAST) then 	
				lua_play_anim(vint_object_find("mash_fast"))			
			end
				
				-- if the qte is successful play the animation
			if success then
				vint_set_property(Hud_qte_success_grp_h, "visible", true)
				hud_qte_play_success_anim()
			end
		end	
	else
		--Hide and pause everything
		vint_set_property(Hud_qte_btn_1_h, "visible", false)
		vint_set_property(Hud_qte_btn_2_h, "visible", false)		
		vint_set_property(Hud_qte_sticks_grp_h, "visible", false)
		vint_set_property(Hud_qte_success_grp_h, "visible", false)

		vint_set_property(Hud_qte_kb_grp_h, "visible", false)
		vint_set_property(Hud_qte_mouse_grp_h, "visible", false)
		
		hud_qte_pause_all()
	end	
	
	-- store current btn and anim
	Hud_qte_prev_btn = button_index
	Hud_qte_prev_anim = button_animation
	
	debug_print("vint", "button_animation: " .. var_to_string(button_animation) .. "\n")
end

-- Pause all animations
function hud_qte_pause_all()
	vint_set_property(vint_object_find("mash_standard"),"is_paused", true)	
	vint_set_property(vint_object_find("mash_fast"),"is_paused", true)	
	vint_set_property(vint_object_find("stick_direction"),"is_paused", true)	
	vint_set_property(vint_object_find("success"),"is_paused", true)
	
	vint_set_property(vint_object_find("mouse_mash_standard_anim"),"is_paused", true)
	vint_set_property(vint_object_find("mouse_mash_fast_anima"),"is_paused", true)
	Hud_qte_kb_key:mash(HUD_QTE_ANIM_NONE)
end


--Play "success" Animation
function hud_qte_play_success_anim()
	lua_play_anim(vint_object_find("success"))
end



-------------------------------------------------------------------------------
-- TEST FUNCTIONS
--
function hud_qte_update_key_test()
--[[
	local Hud_qte_key_doc_h = vint_document_find("`hud_qte")
	Pc_qte_key = Vdo_qte_key:new("qte_pc_key", 0, Hud_qte_key_doc_h, "hud_qte.lua", "Pc_qte_key")
	local qte_key = Pc_qte_key
	qte_key:set_text("W")
	--qte_key:fast_mash()

	local delay_time = 2

	delay(delay_time)

	qte_key:set_text("I'M A BAD ASS")
	delay(delay_time)

	qte_key:set_text("I'M A BAD ASSSSSSSSSSSSSSSSFFFFFFSSSSSS")
	delay(delay_time)

	qte_key:set_text("SAACK")
	delay(delay_time)

	qte_key:set_text("DICKFACE")
	
	delay(delay_time)
	qte_key:set_text("TABULATION")
	
	delay(delay_time)


	qte_key:set_text("W")
]]
end