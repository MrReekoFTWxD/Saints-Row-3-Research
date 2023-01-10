Bg_saints_doc_handle = 0	--Doc handle to bg saints...

BG_TYPE_DEFAULT 		= 0
BG_TYPE_STRONGHOLD 	= 1
BG_TYPE_COMPLETION 	= 2
BG_TYPE_CENTER			= 3
BG_TYPE_FULLSCREEN	= 4
 
local Bg_saints_scale = 1
local Bg_saints_type = BG_TYPE_DEFAULT

-- BG Video frame times
local PRESS_START_LOOP_START  = 239
local PRESS_START_LOOP_END    = 240
local PRESS_START_TRANS_START = 241
local MAIN_MENU_LOOP_START    = 272
local MAIN_MENU_LOOP_END      = 2608

local HD_Templates = {
	[BG_TYPE_COMPLETION] 	= {	anchor_x = 100*3, 
											size_x = 468*3,
											use_background = false},
							
	[BG_TYPE_STRONGHOLD] 	= {	anchor_x = 100*3, 
											size_x = 488*3,
											use_background = false},
	[BG_TYPE_DEFAULT] 		= {	anchor_x = -6*3, 
											size_x = 3850,
											use_background = true},
	[BG_TYPE_CENTER] 			= {	anchor_x = 1920, 
											size_x = 2400,
											use_background = false},
	[BG_TYPE_FULLSCREEN] 	= {	anchor_x = -6*3, 
											size_x = 3850,
											use_background = false},
}

local SD_Templates = {
	[BG_TYPE_COMPLETION] = {	anchor_x = 74*3,
										size_x = 468*3,
										use_background = false},
							
	[BG_TYPE_STRONGHOLD] 	= {	anchor_x = 54*3, 
											size_x = 478*3,
											use_background = false},
								
	[BG_TYPE_DEFAULT] 		= {	anchor_x = -6*3, 
											size_x = 640*3,
											use_background = true},
	[BG_TYPE_CENTER] 			= {	anchor_x = (320 * 1.5)*3, 
											size_x = 800*3,
											use_background = false},
	[BG_TYPE_FULLSCREEN] 	= {	anchor_x = -6*3, 
											size_x = (645 * 1.5)*3,
                           		use_background = false},
}
function bg_saints_init()
	Bg_saints_doc_handle = vint_document_find("bg_saints")
	
	--Hide dimmer background
	bg_saints_dimmer_show(false)
	
	--Set default type...
	bg_saints_set_type(BG_TYPE_DEFAULT, false)
	
	
	--Start background scroll
	local anim_h = vint_object_find("crib_bg_loop_anim")
	lua_play_anim(anim_h)

end

function bg_saints_cleanup()
	local bg_saints_video_h = vint_object_find( "bg_video", 0, Bg_saints_doc_handle )
	vint_set_property( bg_saints_video_h, "end_event", "" )
end

-------------------------------------------------------------------------------
-- Sets type of background
-- @param	screen_type		Screen type: 	BG_TYPE_DEFAULT, BG_TYPE_STRONGHOLD, BG_TYPE_COMPLETION, BG_TYPE_CENTER
-- @param	morph				Bool:	do morph animation or not
-- @param	width				width override for background
-- @param	anchor			anchor override for background
--
function bg_saints_set_type( screen_type, morph, width, anchor )

	local bg_saints_mask_h = vint_object_find("bg_saints_mask", 0, Bg_saints_doc_handle)
	local radial_glow_h = vint_object_find("radial_glow", 0, Bg_saints_doc_handle)
	local left_shadow_h = vint_object_find("left_shadow", 0, Bg_saints_doc_handle)
	local right_shadow_h = vint_object_find("right_shadow", 0, Bg_saints_doc_handle)
	local crib_bg_shadow_h = vint_object_find("crib_bg_shadow", 0, Bg_saints_doc_handle)
	local screen_group_h = vint_object_find("screen_grp", 0, Bg_saints_doc_handle)
	
	local templates = HD_Templates
	if vint_is_std_res() then
		templates = SD_Templates
	end
	
	Bg_saints_scale = vint_get_property(screen_group_h,"scale")
	
	Bg_saints_type = screen_type
	
	local template = templates[screen_type]
	
	--Check to see if our template is valid...
	if template == nil then
		template = templates[BG_TYPE_DEFAULT]
	end
	
	--Get Template values.
	--if anchor is nil then we will use template.anchor_x
	local anchor_x = anchor or template.anchor_x
	local anchor_y = -6
	
	--if width is nil then we will use template.size_x
	local size_x = width or template.size_x
	local size_y = 730*3
	local use_background = template.use_background
	
	bg_saints_set_background(use_background)

	--do we need drop shadows?
	if screen_type == BG_TYPE_DEFAULT then	
		--no, hide them
		vint_set_property( left_shadow_h, "visible", false )
		vint_set_property( right_shadow_h, "visible", false )
		vint_set_property( crib_bg_shadow_h, "visible", false )
	else
		--yes, show them
		vint_set_property( left_shadow_h, "visible", true )
		vint_set_property( right_shadow_h, "visible", true )
		vint_set_property( crib_bg_shadow_h, "visible", true )
	end
	
	--If Center aligned, create the center anchor point from the width of the mask
	if screen_type == BG_TYPE_CENTER then
		anchor_x = (anchor_x) - (size_x * 0.5)
	end

	if morph then
		--do the morph stuff
		bg_saints_morph( screen_type, size_x, anchor_x )
	else
		--Set template values, Position, Size, and if its a background layer...
		vint_set_property(bg_saints_mask_h,"anchor", anchor_x, anchor_y)
		vint_set_property(radial_glow_h,"anchor", anchor_x, anchor_y)
		element_set_actual_size(bg_saints_mask_h, size_x, size_y)
		vint_set_property( left_shadow_h, "anchor", anchor_x, 40*3 )
		vint_set_property( right_shadow_h, "anchor", anchor_x + size_x, 660*3 )
	end
end

-------------------------------------------------------------------------------
-- Morphs background from previous size/position to the next...
-- @param	screen_type		Screen type: 	BG_TYPE_DEFAULT, BG_TYPE_STRONGHOLD, BG_TYPE_COMPLETION, BG_TYPE_CENTER
-- @param	size_end_x		width that the animation will end on
-- @param	anchor_end_x	x position that the animation will end on
--
function bg_saints_morph( screen_type, size_end_x, anchor_end_x )
	--get handles for everyone
	local bg_saints_mask_h = vint_object_find("bg_saints_mask", 0, Bg_saints_doc_handle)
	local morph_anim_h = vint_object_find("mask_morph_anim", 0, Bg_saints_doc_handle)
	local morph_scale_twn_h = vint_object_find("mask_morph_scale_twn", 0, Bg_saints_doc_handle)
	local morph_anchor_twn_h = vint_object_find("mask_morph_anchor_twn", 0, Bg_saints_doc_handle) 
	local left_shadow_anchor_twn_h = vint_object_find("left_shadow_anchor_twn", 0, Bg_saints_doc_handle) 
	local right_shadow_anchor_twn_h = vint_object_find("right_shadow_anchor_twn", 0, Bg_saints_doc_handle) 
	local right_shadow_h = vint_object_find( "right_shadow",0,Bg_saints_doc_handle)
	local left_shadow_h = vint_object_find( "left_shadow",0,Bg_saints_doc_handle)
	local shadow_h = vint_object_find( "shadow_group", 0, Bg_saints_doc_handle )
	
	--set up the left shadow start and end values
	--get the starting x position
	local anchor_start_x,anchor_start_y = vint_get_property( left_shadow_h, "anchor" )

	vint_set_property( left_shadow_anchor_twn_h, "start_value", anchor_start_x, anchor_start_y )
	vint_set_property( left_shadow_anchor_twn_h, "end_value", anchor_end_x, anchor_start_y )
	
	--set up the right shadow start and end values
	anchor_start_x,anchor_start_y = vint_get_property( right_shadow_h, "anchor" )
	local adjusted_anchor_end_x = anchor_end_x + size_end_x
	vint_set_property( right_shadow_anchor_twn_h, "start_value", anchor_start_x, anchor_start_y )
	vint_set_property( right_shadow_anchor_twn_h, "end_value", adjusted_anchor_end_x, anchor_start_y )
	
	--setup the anchor for the mask
	--get the starting x position
	local mask_anchor_start_x,mask_anchor_start_y = vint_get_property( bg_saints_mask_h, "anchor" )
	vint_set_property(morph_anchor_twn_h, "start_value", mask_anchor_start_x, mask_anchor_start_y )
	vint_set_property(morph_anchor_twn_h, "end_value", anchor_end_x, mask_anchor_start_y )
	
	--setup the scale of the mask
	--get the starting scale
	local size_start_x,size_start_y = vint_get_property(bg_saints_mask_h,"scale")
	--get the correct size, this fixes SD scale issues
	local adjusted_size_end_x,crap = element_get_scale_from_size(bg_saints_mask_h, size_end_x, 16)
	vint_set_property(morph_scale_twn_h, "start_value", size_start_x , size_start_y)
	vint_set_property(morph_scale_twn_h, "end_value", adjusted_size_end_x , size_start_y)
	
	--play the animation
	lua_play_anim(morph_anim_h, 0, Bg_saints_doc_handle)	
	
end

-------------------------------------------------------------------------------
-- Animates background into view...
--
function bg_saints_animate()
	local bg_h = vint_object_find( "bg", 0, Bg_saints_doc_handle )
	local shadow_h = vint_object_find( "shadow_group", 0, Bg_saints_doc_handle )
	vint_set_property(bg_h, "alpha", 1.0)
	vint_set_property(shadow_h, "alpha", 0.5)
	
	local bg_saints_mask_h = vint_object_find( "bg_saints_mask", 0, Bg_saints_doc_handle )
	local mask_x,mask_y = vint_get_property( bg_saints_mask_h, "anchor" )
	local mask_tween_h = vint_object_find( "mask_drop_twn", 0, Bg_saints_doc_handle )
	vint_set_property(mask_tween_h,"start_value", -1000*3, mask_y)
	vint_set_property(mask_tween_h,"end_value", mask_x, mask_y)
	local anim = Vdo_anim_object:new("mask_drop_anim", 0, Bg_saints_doc_handle)
	anim:play()
	vint_apply_start_values(anim.handle)
	bg_saints_show(true)
end

-------------------------------------------------------------------------------
-- Slides background into view...
--
function bg_saints_slide_in(width, anchor)
	local bg_h = vint_object_find( "bg", 0, Bg_saints_doc_handle )
	local shadow_h = vint_object_find( "shadow_group", 0, Bg_saints_doc_handle )
	local right_shadow_h = vint_object_find( "right_shadow", 0, Bg_saints_doc_handle )
	local left_shadow_h = vint_object_find( "left_shadow", 0, Bg_saints_doc_handle )
	vint_set_property(bg_h, "alpha", 1.0)
	vint_set_property(shadow_h, "alpha", 0.5)
	local bg_saints_mask_h = vint_object_find( "bg_saints_mask", 0, Bg_saints_doc_handle )
	
	--get the resolution specific end position and width
	local templates = HD_Templates
	if vint_is_std_res() then
		templates = SD_Templates
	end
	local template = templates[Bg_saints_type]
	local anchor_x = anchor or template.anchor_x
	local width = width or template.size_x
	local left_anchor_x = anchor_x
	if Bg_saints_type == BG_TYPE_CENTER then
		left_anchor_x = (anchor_x) - (width * 0.5)
		local right_anchor_x = (anchor_x) + (width * 0.5)
		local crap_x,left_anchor_y = vint_get_property(left_shadow_h, "anchor")
		vint_set_property(left_shadow_h, "anchor", left_anchor_x, left_anchor_y)
		local crap_x,right_anchor_y = vint_get_property(right_shadow_h, "anchor")
		vint_set_property(right_shadow_h, "anchor", right_anchor_x, right_anchor_y)
	end
	
	--set the correct x and y for the mask
	local start_x = -1000*3
	local mask_x,mask_y = vint_get_property( bg_saints_mask_h, "anchor" )
	local mask_tween_h = vint_object_find( "mask_drop_twn_1", 0, Bg_saints_doc_handle )
	vint_set_property(mask_tween_h, "start_value", start_x, mask_y)
	vint_set_property(mask_tween_h, "end_value", left_anchor_x, mask_y)
	
	--be sure to offest the start positions so that the anims match up
	local shadow_tween_h = vint_object_find("shadow_drop_twn_1", 0, Bg_saints_doc_handle)
	local shadow_x,shadow_y = vint_get_property(shadow_tween_h, "start_value")
	vint_set_property(shadow_tween_h, "start_value", start_x - left_anchor_x, shadow_y)
	
	local anim = Vdo_anim_object:new("mask_slide_in_anim", 0, Bg_saints_doc_handle)
	anim:play()
	vint_apply_start_values(anim.handle)
	bg_saints_show(true)
end

-------------------------------------------------------------------------------
-- Slides background out of view...
--
function bg_saints_slide_out(new_end_x)
	local bg_h = vint_object_find( "bg", 0, Bg_saints_doc_handle )
	local shadow_h = vint_object_find( "shadow_group", 0, Bg_saints_doc_handle )
	local left_shadow_h = vint_object_find( "left_shadow", 0, Bg_saints_doc_handle )
	vint_set_property(bg_h, "alpha", 1.0)
	vint_set_property(shadow_h, "alpha", 0.5)
	
	local end_x = new_end_x or -1000*3
	local bg_saints_mask_h = vint_object_find( "bg_saints_mask", 0, Bg_saints_doc_handle )
	local mask_x,mask_y = vint_get_property( bg_saints_mask_h, "anchor" )
	local mask_tween_h = vint_object_find( "mask_drop_twn_1_1", 0, Bg_saints_doc_handle )
	vint_set_property(mask_tween_h, "start_value", mask_x, mask_y)
	vint_set_property(mask_tween_h, "end_value", end_x, mask_y)
	
	--be sure to offest the end positions so that the anims match up
	local shadow_tween_h = vint_object_find("shadow_drop_twn_1_1", 0, Bg_saints_doc_handle)
	local crap_x,shadow_y = vint_get_property(shadow_tween_h, "start_value")
	local shadow_start_x,left_anchor_y = vint_get_property(left_shadow_h, "anchor")
	--vint_set_property(shadow_tween_h, "start_value", 0, shadow_y)
	vint_set_property(shadow_tween_h, "end_value", end_x - shadow_start_x, shadow_y)
	
	local anim = Vdo_anim_object:new("mask_slide_out_anim", 0, Bg_saints_doc_handle)
	anim:play()
end

-------------------------------------------------------------------------------
-- Shows background
-- @param	is_visible
--
function bg_saints_show( is_visible )
	local bg_saints_bg_h = vint_object_find( "bg", 0, Bg_saints_doc_handle )
	local bg_saints_shadow_h = vint_object_find( "shadow_group", 0, Bg_saints_doc_handle )
	vint_set_property( bg_saints_bg_h, "visible", is_visible )
	vint_set_property( bg_saints_shadow_h, "visible", is_visible )
end

-------------------------------------------------------------------------------
-- Toggles the interface in background mode or not...
-- @param	is_visible
--
function bg_saints_set_background(use_background)
	local crib_bg_grp_h = vint_object_find("crib_bg_grp", 0, Bg_saints_doc_handle)
	vint_set_property(crib_bg_grp_h, "background", use_background)
end

-------------------------------------------------------------------------------
-- Dims out everything behind bg saints...
-- @param	is_visible
--
function bg_saints_dimmer_show( is_visible )
	local background_bmp_h = vint_object_find("background_bmp", 0, Bg_saints_doc_handle)
	vint_set_property(background_bmp_h, "visible", is_visible)
end

-------------------------------------------------------------------------------
-- Sets video 
-- @param	video_name
--
function bg_saints_set_video( video_name )
	local bg_saints_video_h = vint_object_find( "bg_video", 0, Bg_saints_doc_handle)
	vint_set_property( bg_saints_video_h, "vid_name", video_name )
end

-------------------------------------------------------------------------------
-- Plays video
-- @param	is_playing
--
function bg_saints_play_video( is_playing, stop_callback )
	local bg_saints_video_h = vint_object_find( "bg_video", 0, Bg_saints_doc_handle )
	vint_set_property( bg_saints_video_h, "visible", is_playing )
	vint_set_property( bg_saints_video_h, "end_event", stop_callback )	

	if is_playing == false then
		-- needed so we can unload it and steal its memories
		vint_set_property( bg_saints_video_h, "is_stopped", true )
	else 
		vint_set_property( bg_saints_video_h, "is_paused", (not is_playing) )
	end
end


-------------------------------------------------------------------------------
-- INTERFACE SPECIFIC FUNCTIONS
-------------------------------------------------------------------------------
function bg_saints_stronghold_drop_out()
	local anim_h = vint_object_find("mask_stronghold_out_anim", 0, Bg_saints_doc_handle)
	lua_play_anim(anim_h, 0, Bg_saints_doc_handle)
end


-------------------------------------------------------------------------------
-- MAIN MENU VIDEO CALLBACKS
-------------------------------------------------------------------------------

-- Press Start
function bg_saints_press_start_setup()
	local bg_saints_video_h = vint_object_find( "bg_video", 0, Bg_saints_doc_handle )
	vint_set_property( bg_saints_video_h, "frame_event", "bg_saints_press_start_cb" )
	vint_set_property( bg_saints_video_h, "frame_event_num", PRESS_START_LOOP_END )	
end
	
function bg_saints_press_start_cb()
	thread_new("bg_saints_press_start_loop")
end

function bg_saints_press_start_loop()
	delay(0.005)
	
	local bg_saints_video_h = vint_object_find( "bg_video", 0, Bg_saints_doc_handle )
	vint_set_property( bg_saints_video_h, "frame", PRESS_START_LOOP_START )	
end


-- Main Menu
function bg_saints_main_menu_setup()
	local bg_saints_video_h = vint_object_find( "bg_video", 0, Bg_saints_doc_handle )
	
	--bg_saints_delay_trans()
	vint_set_property( bg_saints_video_h, "frame", PRESS_START_TRANS_START)
	
	vint_set_property( bg_saints_video_h, "frame_event", "bg_saints_main_menu_cb" )
	vint_set_property( bg_saints_video_h, "frame_event_num", MAIN_MENU_LOOP_END )		
end

-- function bg_saints_delay_trans()
	-- thread_new("bg_saints_press_start_trans")
-- end

-- function bg_saints_press_start_trans()
	-- delay(0.1)
	
	-- local bg_saints_video_h = vint_object_find( "bg_video", 0, Bg_saints_doc_handle )
	
	-- vint_set_property( bg_saints_video_h, "frame", PRESS_START_TRANS_START )			
-- end

function bg_saints_main_menu_cb()
	thread_new("bg_saints_main_menu_loop")
end

function bg_saints_main_menu_loop()
	delay(0.005)
	
	local bg_saints_video_h = vint_object_find( "bg_video", 0, Bg_saints_doc_handle )
	vint_set_property( bg_saints_video_h, "frame", MAIN_MENU_LOOP_START )
end


