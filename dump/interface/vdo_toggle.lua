function vdo_toggle_init()
end

function vdo_toggle_cleanup()
end

-- Inherited from Vdo_base_object
Vdo_toggle = Vdo_base_object:new_base()

COLOR_PAUSE_BUTTON_TOGGLE_TEXT_UNSELECTED = {R = 194/255, G = 201/255; B = 204/255}
COLOR_PAUSE_BUTTON_TOGGLE_TEXT_SELECTED = {R = 0/255, G = 0/255; B = 0/255}
local TOGGLE_TEXT_PAD = (3 * 3)

--Init Toggle
function Vdo_toggle:init()
	self.value_txt_h = vint_object_find("value", self.handle)
	
	--Default highlight color...
	self.highlight_color = COLOR_PAUSE_BUTTON_TOGGLE_TEXT_SELECTED
	
	--Defaults...
	self.is_disabled = false
	self.arrows_hidden = false
end

-------------------------------------------------------------------------------
-- Sets the value of the toggle object
-- @param	value		value you want to set...
-------------------------------------------------------------------------------
function Vdo_toggle:set_value(value)
	vint_set_property(self.value_txt_h, "text_tag", value)
end

-------------------------------------------------------------------------------
-- sets the width based on the values in the options.
-- @param	options	Table with the options. options = {"option_1", "option_2"}
-------------------------------------------------------------------------------
function Vdo_toggle:set_width_based_on_values(options)
	--Find largest text string and size component to it...
	local width = 0
	local max_width = 0
	for i = 1, #options do
		vint_set_property(self.value_txt_h, "text_tag", options[i])
		width = element_get_actual_size(self.value_txt_h)
		max_width = max(max_width, width)
	end
	
	self:set_width(max_width)
end

-------------------------------------------------------------------------------
-- Returns the width of the current value in the toggle.
-------------------------------------------------------------------------------
function Vdo_toggle:get_value_width()
	local width, height = element_get_actual_size(self.value_txt_h)
	return width
end

-------------------------------------------------------------------------------
-- Set width
-- @param	width		
-------------------------------------------------------------------------------
function Vdo_toggle:set_width(width)

	-- Reposition Right Arrow
	local a_right_h = vint_object_find("arrow_right", self.handle)
	local x, y = vint_get_property(a_right_h, "anchor")
	local arrow_width, arrow_height = element_get_actual_size(a_right_h)
	x = width + arrow_width + (3 * 3) 
	vint_set_property(a_right_h, "anchor", x, y)
	
	-- Center text in toggle.
	local value_x, value_y = vint_get_property(self.value_txt_h, "anchor")
	value_x = width/2 + (arrow_width)
	vint_set_property(self.value_txt_h, "anchor", value_x, value_y)
	
	self.width = x + arrow_width
end

-------------------------------------------------------------------------------
-- Returns the width the the vdo from left arrow to right arrow.
-------------------------------------------------------------------------------
function Vdo_toggle:get_width()
	return self.width
end

-------------------------------------------------------------------------------
-- Sets the highlighted state of the slider to on or off 
-- (will eventually have grayed out here too)
--
function Vdo_toggle:set_highlight(is_highlighted)

	local arrow_left_h = vint_object_find("arrow_left", self.handle, self.doc_handle)
	local arrow_right_h = vint_object_find("arrow_right", self.handle, self.doc_handle)

	if is_highlighted then
		--Set color
		vint_set_property(self.value_txt_h, "tint", 0, 0, 0)
		
		--Show Arrows only if we are not disabled. 
		vint_set_property(arrow_left_h, "visible", true)
		vint_set_property(arrow_right_h, "visible", true)
	else
		--Set Color
		vint_set_property(self.value_txt_h, "tint", COLOR_PAUSE_BUTTON_TOGGLE_TEXT_UNSELECTED.R, COLOR_PAUSE_BUTTON_TOGGLE_TEXT_UNSELECTED.G, COLOR_PAUSE_BUTTON_TOGGLE_TEXT_UNSELECTED.B)
		
		--Hide Arrows
		vint_set_property(arrow_left_h, "visible", false)
		vint_set_property(arrow_right_h, "visible", false)
	end
	
end

function Vdo_toggle:set_highlight_color(new_color)
	self.highlight_color = new_color
end



-------------------------------------------------------------------------------
-- Sets the scale for the text items...
-- (will eventually have grayed out here too)
--
function Vdo_toggle:set_text_scale(scale)
	vint_set_property(self.value_txt_h, "scale", scale, scale)
end

function Vdo_toggle:set_disabled(is_disabled)
	
	local arrow_left_h = vint_object_find("arrow_left", self.handle, self.doc_handle)
	local arrow_right_h = vint_object_find("arrow_right", self.handle, self.doc_handle)
	
	--Hide Arrows
	if is_disabled == true then
		vint_set_property(arrow_left_h, 		"alpha", 0)
		vint_set_property(arrow_right_h, 	"alpha", 0)
		vint_set_property(self.value_txt_h, "alpha", .5)
	else
		vint_set_property(arrow_left_h, 		"alpha", 1.0)
		vint_set_property(arrow_right_h, 	"alpha", 1.0)
		vint_set_property(self.value_txt_h, "alpha", 1.0)
	end
	self.is_disabled = is_disabled
endd_u'0