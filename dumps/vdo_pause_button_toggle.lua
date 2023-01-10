--------------------------------------------------------------------------- 
-- Vdo_pm_header
--
-- The header for each screen in the pause menu. This object gets included
-- manually in those documents that need a header.
---------------------------------------------------------------------------
function vdo_pause_button_toggle_init()
end
function vdo_pause_button_toggle_cleanup()
end

-- Inherited from Vdo_base_object
Vdo_pause_button_toggle = Vdo_base_object:new_base()

COLOR_PAUSE_BUTTON_TOGGLE_TEXT_UNSELECTED = {R = 194/255, G = 201/255; B = 204/255}
COLOR_PAUSE_BUTTON_TOGGLE_TEXT_SELECTED = {R = 0/255, G = 0/255; B = 0/255}

--COLOR_MAINMENU_TOGGLE_TEXT_UNSELECTED 	= {R = 160/255, G = 160/255; B = 160/255}
COLOR_MAINMENU_TOGGLE_TEXT_UNSELECTED 	= {R = 235/255, G = 235/255; B = 235/255}
COLOR_MAINMENU_TOGGLE_TEXT_SELECTED 	= {R = 160/255, G = 0/255; B = 224/255}

local SELECTED_SCALE = 1
local UNSELECTED_SCALE = 1

function Vdo_pause_button_toggle:init()
	self:set_color(COLOR_PAUSE_BUTTON_TOGGLE_TEXT_SELECTED, COLOR_PAUSE_BUTTON_TOGGLE_TEXT_UNSELECTED)
end


-- Sets the label of the button object
function Vdo_pause_button_toggle:set_label(new_label)
	local text = Vdo_base_object:new("toggle_text", self.handle)
	
	if text.handle ~= 0 then
		text:set_property("text_tag", new_label)
	end
end

-- Sets the value of the button toggle object
function Vdo_pause_button_toggle:set_value(new_value)
	local value = Vdo_base_object:new("toggle_value", self.handle)
	
	if value.handle ~= 0 then
		value:set_property("text_tag", new_value)
	end
end

-- Sets the width of the button toggle object
function Vdo_pause_button_toggle:set_width(width)
--[[
	local techno_text = Vdo_base_object:new("toggle_techno_text", self.handle)
	
	local rand_texts = {
		"ui_hud_small_text1",
		"ui_hud_small_text2",
	}
	
	local rand_idx = rand_int(1, #rand_texts)
	techno_text:set_property("image", rand_texts[rand_idx])

	local value = Vdo_base_object:new("toggle_value", self.handle)
	--get the old value anchor
	local bogus_x, value_y = value:get_property("anchor")
	local value_x = width * 0.75
	value:set_property("anchor", value_x, value_y)
	
	]]
end

--------------------------------------------------------------------------- 
-- Sets the highlighted state of the button to on or off
-- @param is_highlighted	Boolean determining if the button is in the 
--									highlight state or not.
---------------------------------------------------------------------------
function Vdo_pause_button_toggle:set_highlight(is_highlighted)
	--Get Object References
	local value_obj = Vdo_base_object:new("toggle_value", self.handle)
	local text_obj = Vdo_base_object:new("toggle_text", self.handle)
		
	if is_highlighted then
		--Set color
		value_obj:set_color(self.selected_color.R, self.selected_color.G, self.selected_color.B)
		text_obj:set_color(self.selected_color.R, self.selected_color.G, self.selected_color.B)
		
		--Set Scale
		value_obj:set_scale(SELECTED_SCALE, SELECTED_SCALE)
		text_obj:set_scale(SELECTED_SCALE, SELECTED_SCALE)
	else
		--Set Color
		value_obj:set_color(self.unselected_color.R, self.unselected_color.G, self.unselected_color.B)
		text_obj:set_color(self.unselected_color.R, self.unselected_color.G, self.unselected_color.B)
		
		--Set Scale
		value_obj:set_scale(UNSELECTED_SCALE, UNSELECTED_SCALE)
		text_obj:set_scale(UNSELECTED_SCALE, UNSELECTED_SCALE)
	end
end

-- Sets the enabled state of the button to on or off
function Vdo_pause_button_toggle:set_enabled(enabled)
end

function Vdo_pause_button_toggle:get_text_width()
	local text_obj = Vdo_base_object:new("toggle_text", self.handle)
	local width, height = text_obj:get_actual_size()
	
	local text_obj_scale = text_obj:get_scale()
	
	--Always return the max size of the text string
	if text_obj_scale == SELECTED_SCALE then
		return width
	else
		return width * SELECTED_SCALE
	end
end

-- Sets the color of the pause button...
function Vdo_pause_button_toggle:set_color(selected_color, unselected_color)
	self.selected_color 		= selected_color
	self.unselected_color 	= unselected_color
end

function Vdo_pause_button_toggle:set_shadow(has_shadow)

	--This does more than set shadow but gets us what we want on the main menu for sr3...
	local text_h = vint_object_find("toggle_text", self.handle)
	
	vint_set_property(text_h, "font", "header_n")
	vint_set_property(text_h, "text_scale", .6, .6)
	
	
	if has_shadow then
		vint_set_property(text_h, "shadow_enabled", true)
		vint_set_property(text_h, "shadow_offset", .5,.5)
		vint_set_property(text_h, "shadow_alpha", 0.8)
		
		--vint_set_property(text_h, "line_frame_w", "ui_fnt_body_s_w")
		--vint_set_property(text_h, "line_frame_m", "ui_fnt_body_s_m")
		--vint_set_property(text_h, "line_frame_e", "ui_fnt_body_s_e")
		--vint_set_property(text_h, "line_frame_enable", true)
	
	else
		vint_set_property(text_h, "shadow_enabled", false)
	end
end