
-- All of these defines exist also in data/lua_scripts/game_lib.lua
-- Object Indicator Assets
OI_ASSET_INVALID		= -1
OI_ASSET_KILL			= 0
OI_ASSET_DEFEND		= 1
OI_ASSET_USE			= 2
OI_ASSET_REVIVE		= 3
OI_ASSET_LOCATION		= 4
OI_ASSET_COOP			= 5
OI_ASSET_KILL_FULL	= 6
OI_ASSET_FINSHER		= 7 -- Not used in lua, just here so we stay in sync with C.
OI_ASSET_KILL_TIRES  = 8 -- Should not be used, but added so the assets after it stay in sync.
OI_ASSET_HITMAN		= 9
OI_ASSET_CHOPSHOP		= 10 
OI_ASSET_ALL			= 11 -- Not used in lua, just here so we stay in sync with C.
OI_ASSET_SYNDICATE	= 12
OI_ASSET_GRENADE 		= 13


-- This must match the flags defined in object_indicators.h
OI_FLAG_NONE					= 0x00
OI_FLAG_STICKY					= 0x01
OI_FLAG_DISPLAY_DISTANCE	= 0x02
OI_FLAG_PULSE					= 0x04
OI_FLAG_FADE					= 0x08
OI_FLAG_PARTIAL_HIDE			= 0x10

OI_OFFSET_Y = 90
Oi_offset_scale = 1.0

Oi_elements = {
	in_game_grp_h = -1,
	pulse_anim_h = -1,
	pulse_circle = -1,
}

object_indicator = {}

local Object_indicator_types = {
	[OI_ASSET_KILL]			= 	{ img = "uhd_ui_target_icon_kill", 		color = COLOR_TARGET_KILL},
	[OI_ASSET_DEFEND]			=  { img = "uhd_ui_target_icon_defend",		color = COLOR_TARGET_DEFEND},
	[OI_ASSET_USE]				=  { img = "uhd_ui_target_icon_use", 		color = COLOR_TARGET_USE},
	[OI_ASSET_REVIVE]			=  { img = "uhd_ui_target_icon_revive", 	color = COLOR_TARGET_REVIVE,  depth = -20},
	[OI_ASSET_LOCATION]		= 	{ img = "uhd_ui_target_icon_location", 	color = COLOR_TARGET_LOCATION},
	[OI_ASSET_COOP]			= 	{ img = "uhd_ui_target_icon_coop", 		color = COLOR_TARGET_COOP},
	[OI_ASSET_KILL_FULL]		= 	{ img = "uhd_ui_target_icon_kill", 		color = COLOR_TARGET_KILL},
	[OI_ASSET_FINSHER]		= 	{ img = "uhd_ui_target_icon_kill", 		color = COLOR_TARGET_REVIVE},		-- Not used in lua, just here so we stay in sync with C.
	[OI_ASSET_KILL_TIRES]	= 	{ img = "uhd_ui_target_icon_kill", 		color = COLOR_TARGET_KILL},
	[OI_ASSET_HITMAN]			= 	{ img = "uhd_ui_saintsbook_hitman", 		color = COLOR_TARGET_HITMAN},
	[OI_ASSET_CHOPSHOP]		=	{ img = "uhd_ui_saintsbook_vehicle", 	color = COLOR_TARGET_CHOPSHOP},	
	[OI_ASSET_ALL]				= 	{ img = "uhd_ui_target_icon_kill", 		color = COLOR_TARGET_REVIVE},		-- Not used in lua, just here so we stay in sync with C.
	[OI_ASSET_SYNDICATE]		= 	{ img = "uhd_ui_target_icon_syndicate",	color = COLOR_TARGET_SYNDICATE},
	[OI_ASSET_GRENADE]		= 	{ img = "uhd_ui_target_icon_grenade",	color = COLOR_TARGET_GRENADE},
}

--[[
To use Lua implementation, change the value below to true.  Also, in
object_indicator.cpp, uncomment the line #define OBJECT_INDICATOR_USE_LUA.  
If you tweak the Lua implementation, be sure to ask a programmer to make the 
corresponding tweak to the C implementation as well, and don't check the system
in using the Lua implementation.
--]]
Object_indicator_use_lua = false

function object_indicator_init()
	if Object_indicator_use_lua then
		-- Lua implementation
	
		if vint_is_std_res() then
			Oi_offset_scale = Oi_offset_scale * .667
		else
			Oi_offset_scale = Oi_offset_scale * .667
		end
		
		--Find and store elements
		Oi_elements.in_game_grp_h = vint_object_find("oi_grp")
		Oi_elements.pulse_anim_h = vint_object_find("oi_pulse_anim")
		Oi_elements.pulse_circle = vint_object_find("pulse_circle")
		vint_set_property(Oi_elements.pulse_circle, "visible", false)
		
		--Whole title group...
		Oi_elements.title_grp_h = vint_object_find("title_grp")
		vint_set_property(Oi_elements.title_grp_h, "visible", false)
				
		--Subscribe to data items
		vint_datagroup_add_subscription("object_indicator", "insert", "object_indicator_update")
		vint_datagroup_add_subscription("object_indicator", "update", "object_indicator_update")
		vint_datagroup_add_subscription("object_indicator", "remove", "object_indicator_remove")
	else
		-- C implementation
		object_indicator_init_lua( )
	end
end

-- object_indicator_update: called from game via datagroup subscription
function object_indicator_update(di_h)
	--[[
		Object Indicator datagroup members:
		VINT_PROP_TYPE_VECTOR2F    	- Screen position
		VINT_PROP_TYPE_INT            - Asset
		VINT_PROP_TYPE_FLOAT          - Rotation
		VINT_PROP_TYPE_FLOAT          - Health
		VINT_PROP_TYPE_INT            - Distance (in meters)
		VINT_PROP_TYPE_FLOAT          - Viewing Distance (for scaling indicator)
		VINT_PROP_TYPE_INT            - Flags
	]]
	local screen_pos_x, screen_pos_y, asset_id, rotation, health, dist, view_dist, flags, alpha, partial_hide, title_crc, body_crc  = vint_dataitem_get(di_h)
								
	--title crc
	-- default is 0, when text is 0
	-- 0 after population it will fade out and cleanup.
	--

	
	--If this item has't been created, make a new one and set it up
	if object_indicator[di_h] == nil then
		--Reset text color
		--oi_text_color_change(text_intensity)
		
		--Clone New item
		local grp_h = vint_object_clone(Oi_elements.in_game_grp_h)
		local sub_grp_h = vint_object_find("oi_sub_grp", grp_h)
		local arrow_grp_h = vint_object_find("oi_arrow_grp", grp_h)
		local oi_icon = vint_object_find("oi_icon", grp_h)
		local oi_arrow = vint_object_find("oi_arrow", grp_h)
		local oi_arrow_shadow = vint_object_find("oi_arrow_shadow", grp_h)
		local oi_text = vint_object_find("oi_text", grp_h)
		local oi_health = vint_object_find("oi_health", grp_h)
		local oi_health_shadow = vint_object_find("oi_health_shadow", grp_h)
		local anim_h = 0

		vint_set_property(grp_h, "visible", true)
		vint_set_property(oi_arrow, "rotation", rotation)
		vint_set_property(oi_arrow_shadow, "rotation", rotation)

		if floor(flags / OI_FLAG_PULSE) % 2 == 1 then
			local pulse_circle_h = vint_object_find("pulse_circle", grp_h)
			vint_set_property(pulse_circle_h, "visible", true)
			anim_h = vint_object_clone(Oi_elements.pulse_anim_h)
			vint_set_property(anim_h, "target_handle", sub_grp_h)
			lua_play_anim(anim_h, 0)
		end

		if floor(flags / OI_FLAG_DISPLAY_DISTANCE) % 2 == 1 then
			vint_set_property(oi_text, "visible", true)
		else
			vint_set_property(oi_text, "visible", false)
		end

		--Special case hiding if a grenade is tossed....
		if asset_id == OI_ASSET_GRENADE then
			vint_set_property(Oi_elements.pulse_circle, "visible", false)
			vint_set_property(oi_health, "visible", false)
			vint_set_property(oi_health_shadow, "visible", false)
		end
		
		--vint_set_property(grp_h, "tint", rand_float(0.0, 1.0), rand_float(0.0, 1.0), rand_float(0.0, 1.0))
		--vint_set_property(oi_health, "end_angle", rand_float(0.0, 6.28))
		
		--Grab info from our indicator type table...
		local icon_img		=		Object_indicator_types[asset_id].img
		local color	 		=		Object_indicator_types[asset_id].color
		local depth 		= 		Object_indicator_types[asset_id].depth
		
		-- Set image and colors...
		vint_set_property(oi_icon , "image", icon_img)
		vint_set_property(arrow_grp_h, 	"tint", color.R, color.G, color.B)		
		vint_set_property(sub_grp_h, 		"tint", color.R, color.G, color.B)		
		vint_set_property(oi_text, 		"tint", color.R, color.G, color.B)		
		
		--Set depth if specified by indicator type...
		if depth ~= nil then
			vint_set_property(grp_h, "depth", -20) -- above all others
		end
			
		--Store values and handles to process later
		object_indicator[di_h] = {
			di_h = di_h,
			grp_h = grp_h,
			sub_grp_h = sub_grp_h,
			arrow_grp_h = arrow_grp_h,
			oi_arrow_shadow = oi_arrow_shadow,
			anim_h = anim_h,
			oi_text = oi_text,
			oi_health = oi_health,
			oi_health_shadow = oi_health_shadow,
			text_offset_y = 0,
			title_crc = title_crc,
			body_crc = body_crc,
		}
		
		if title_crc ~= 0 then
			local color = Object_indicator_types[asset_id].color
			object_indicator_title_create(di_h, title_crc, body_crc, color)
		end	
	end

	local oi_item = object_indicator[di_h]
	local grp_h = oi_item.grp_h
	local oi_arrow = vint_object_find("oi_arrow", grp_h)
	local oi_arrow_shadow = oi_item.oi_arrow_shadow
	local sub_grp_h = oi_item.sub_grp_h 
	local arrow_grp_h = oi_item.arrow_grp_h
	local oi_text = oi_item.oi_text
	local oi_health = oi_item.oi_health
	local oi_health_shadow = oi_item.oi_health_shadow

	--Calculate and set the position
	local scale = .9
	if sqrt(view_dist) > 3 then
		scale = 1.2 / sqrt(view_dist) + (scale - 0.4)
	end
	scale = scale * 0.72

	vint_set_property(sub_grp_h,   "scale", scale, scale)
	vint_set_property(arrow_grp_h, "scale", scale, scale)
	local size_x, size_y = element_get_actual_size(oi_arrow)
	local offset_x, offset_y = vint_get_property(oi_arrow, "offset")
	local offset_distance = (size_y - offset_y - OI_OFFSET_Y) * Oi_offset_scale
	
	screen_pos_x = screen_pos_x - (sin(rotation) * offset_distance)
	screen_pos_y = screen_pos_y + (cos(rotation) * offset_distance)
	
	vint_set_property(grp_h, "anchor", screen_pos_x, screen_pos_y)
	vint_set_property(grp_h, "alpha", alpha)

	--set arrow rotation
	vint_set_property(oi_arrow, "rotation", rotation)
	vint_set_property(oi_arrow_shadow, "rotation", rotation)


	if partial_hide == true then
		vint_set_property(oi_text,   "visible", false)
		vint_set_property(sub_grp_h, "visible", false)
	else
		vint_set_property(sub_grp_h, "visible", true)

		if floor(flags / OI_FLAG_DISPLAY_DISTANCE) % 2 == 1 then
			vint_set_property(oi_text, "visible", true)
			vint_set_property(oi_text, "text_tag", format_distance(dist))
			local c_w, c_h = element_get_actual_size(oi_text) 
			local text_width_half = c_w * .5
			local text_height_half = c_h * .5
			
			--40 is the base size including padding of the oi circle.
			local text_offset_x = -sin(rotation) * ((40 * scale) + text_width_half)
			local text_offset_y =  cos(rotation) * ((40 * scale) + text_height_half)
			vint_set_property(object_indicator[di_h].oi_text, "anchor", text_offset_x, text_offset_y)
			object_indicator[di_h].text_offset_x = text_offset_x 
			object_indicator[di_h].text_offset_y = text_offset_y - text_height_half
		end

		if health == 1 then
			vint_set_property(oi_health, "end_angle", 6.283)
			vint_set_property(oi_health_shadow, "end_angle", 0 )
		else
			vint_set_property(oi_health, "end_angle", health * 6.28)
			vint_set_property(oi_health_shadow, "end_angle", 6.28 - (health * 6.28) )
			
		end
	end
	
	
	if title_crc ~= oi_item.title_crc or title_crc ~= 0 then
		object_indicator_title_update(di_h,screen_pos_x, screen_pos_y, scale)
		oi_item.title_crc = title_crc

		-- begin fading out when the crc is back to 0
		if title_crc == 0 then
			local title_obj = Object_indicator_titles[di_h]
			lua_play_anim(title_obj.fade_out_anim_h)
		end
	end
end

function object_indicator_remove(di_h)
	--Destroy objects, animation and values
	if object_indicator[di_h] ~= nil then
		--Destroy animation
		vint_object_destroy(object_indicator[di_h].anim_h)
		--Destroy group object
		vint_object_destroy(object_indicator[di_h].grp_h)
		--Destroy stored values
		object_indicator[di_h] = nil	
		
		--Attempt to Destroy the indicator title if exists...
		object_indicator_title_destroy(di_h)
	end
end


Object_indicator_titles = {}

-------------------------------------------------------------------------------
-- Creates table, clone and reference objects
--
function object_indicator_title_create(di_h, title_crc, body_crc, color)
	--create table, clone and reference objects
	local title_obj = {}
	local title_grp_h 		= vint_object_clone(Oi_elements.title_grp_h)
	vint_set_property(title_grp_h, "visible", true)
	
	title_obj.title_grp_h 	= title_grp_h
	title_obj.title_h 		= vint_object_find("title_txt", 	title_grp_h)
	title_obj.body_h 			= vint_object_find("body_txt", 	title_grp_h)
	
	--get base scale for standard def stuff.
	local base_scale_grp_h 	= vint_object_find("title_scale_grp", title_grp_h)
	title_obj.base_scale		= vint_get_property(base_scale_grp_h, "scale")
	
	
	--Animation
	title_obj.fade_out_anim_h 	= vint_object_clone(vint_object_find("title_fade_out_anim"))
	title_obj.fade_out_twn_h 	= vint_object_find("title_twn", title_obj.fade_out_anim_h)
	vint_set_property(title_obj.fade_out_anim_h, "target_handle", title_grp_h)
	vint_set_property(title_obj.fade_out_twn_h, "end_event", "object_indicator_title_fade_cb")
	
	--Set titles of object
	vint_set_property(title_obj.title_h, 	"text_tag_crc", title_crc)
	vint_set_property(title_obj.body_h, 	"text_tag_crc", body_crc)
	
	--Set color of title
	vint_set_property(title_obj.title_h, 	"tint", color.R, color.G, color.B)
	
	--Set parent to the object...
	vint_object_set_parent(title_grp_h, object_indicator[di_h].grp_h)

	--Vertically align elements so they are spaced properly.
	local elements = {
				{	h = title_obj.title_h, type = VINT_OBJECT_TEXT, space = 0},
				{	h = title_obj.body_h, type = VINT_OBJECT_TEXT, space = 2},
			}
	local width, height = vint_align_elements(elements)
	title_obj.width 	= width
	title_obj.height 	= height
	
	--TODO: create these objects in script only.
	Object_indicator_titles[di_h] = title_obj
end

-------------------------------------------------------------------------------
-- Destroys title object
--
function object_indicator_title_destroy(di_h)
	if Object_indicator_titles[di_h] then
		vint_object_destroy(Object_indicator_titles[di_h].title_h)
		vint_object_destroy(Object_indicator_titles[di_h].body_h)
		vint_object_destroy(Object_indicator_titles[di_h].fade_out_anim_h)
		Object_indicator_titles[di_h] = nil
	end
end

-------------------------------------------------------------------------------
-- Updates title object
--
function object_indicator_title_update(di_h, x, y, scale)
	--get references to objects, store them as locals
	local title_obj = Object_indicator_titles[di_h]
	if title_obj == nil then
		return
	end
	
	local title_grp_h = title_obj.title_grp_h 	
	local title_h 		= title_obj.title_h 		
	local body_h 		= title_obj.body_h 			
	
	--Adjust scale value to apply to text.
	scale = scale * 1.8
	if scale < 0.85 then
		scale = 0.85
	end
	
	--Get our alignement values.
	local text_height = title_obj.height + 10
	local text_width = title_obj.width * Oi_offset_scale * scale
	local text_offset_y	= object_indicator[di_h].text_offset_y
	
	--Make sure we don't drop below the indicator.
	if text_offset_y > -15 then
		text_offset_y = -15
	end
	
	--Right or left aligned
	local is_right_aligned = false

	local right_side_of_text_box = x + text_width
	if right_side_of_text_box > Safe_frame_e then
		--need to right align
		is_right_aligned = true
	end
	
	local x = -30
	if is_right_aligned then
		--Align right
		vint_set_property(title_h, "auto_offset", "ne")
		vint_set_property(body_h, 	"auto_offset", "ne")
		vint_set_property(title_h, "horz_align", "right")
		vint_set_property(body_h, 	"horz_align", "right")
		x = 30
	else
		--Align left
		vint_set_property(title_h, "auto_offset", "nw")
		vint_set_property(body_h, 	"auto_offset", "nw")
		vint_set_property(title_h, "horz_align", "left")
		vint_set_property(body_h, 	"horz_align", "left")
	end
	
	--Set position and scale on screen
	local y = text_offset_y - ((text_height * scale) * title_obj.base_scale)
	
	--scale positioning based on our base scale
	x = x * title_obj.base_scale
	
	vint_set_property(title_grp_h, "anchor", x, y)
	vint_set_property(title_grp_h, "scale", scale, scale)
end

-------------------------------------------------------------------------------
-- Cleanup object when we are done with it... this is called by tween event
-- 
function object_indicator_title_fade_cb(twn_h)
	--find di_h based on tween handle...
	local di_h = 0
	for idx, val in pairs(Object_indicator_titles) do
		if twn_h == val.fade_out_twn_h then
			di_h = idx
		end
	end
	
	--Exit if we didn't find it...
	if di_h == 0 then
		return
	end
	
	--Destroy the object...
	object_indicator_title_destroy(di_h)
endto_string(button_animation) .. "\n")
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
endrc'0