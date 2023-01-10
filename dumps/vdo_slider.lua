function vdo_slider_init()
end

function vdo_slider_cleanup()
end

-- Inherited from Vdo_base_object
Vdo_slider = Vdo_base_object:new_base()

PAUSE_COLOR_SLIDER_FILL_SELECTED = {R = 58/255, G = 20/255, B = 41/255}
PAUSE_COLOR_SLIDER_FILL_UNSELECTED = {R = 59/255, G = 54/255, B = 58/255}

local VDO_SLIDER_WIDTH		=	231*3
local VDO_SLIDER_INTERNAL_WIDTH	=	201*3 	--size of slider without arrows...
local VDO_SLIDER_HEIGHT		=	24*3

-- Sets the value of the slider object
function Vdo_slider:set_value(new_value,min_value,max_value,display,mapping)
	
	--Find Slider objects
	local slider_bg = Vdo_base_object:new("slider_bg", self.handle, self.doc_handle)
	local meter_left = Vdo_base_object:new("slider_bg_left", self.handle, self.doc_handle)
	local meter_right = Vdo_base_object:new("slider_bg_right", self.handle, self.doc_handle)
	local slider_value = Vdo_base_object:new("slider_value", self.handle, self.doc_handle)

	--	local x, y = meter:get_anchor()
	--	local meter_max, bogus_height = meter:get_property("screen_size")
	
		--local bg = Vdo_base_object:new("slider_meter_bg_2", self.handle, self.doc_handle)
	--	local value_grp = Vdo_base_object:new("slider_value_group", self.handle, self.doc_handle)
	--	local value = Vdo_base_object:new("slider_value", self.handle, self.doc_handle)
		
	min_value = min_value or 0
	max_value = max_value or 100
	
	local new_value_pct = (new_value - min_value) / (max_value - min_value)
	
	-- special case adjustment for 0-1.0 % sliders (show whole numbers)
	if min_value < 1 and max_value <= 1 then
		new_value = floor((new_value * 100) + .5)
	end
	
	--Position Text
	-- Min is position of text for 0 on left side of bar
	-- Max is position of text for 100 on right side of bar
	local x_min = 35*3
	local x_max = 194*3
	local pos_x = (x_max - x_min) * new_value_pct + x_min
	slider_value:set_anchor(pos_x,0)

	--Resize and position bars
	
	--Left Bar
	local width_min 	= 0.01
	local width_max	= 156*3
	local size_x = (width_max - width_min) * new_value_pct + width_min 
	local t_x, t_y = meter_left:get_actual_size()
	meter_left:set_actual_size(size_x, t_y)
	
	--Right Bar
	local width_min	= 156*3
	local width_max 	= 0.01
	local size_x = (width_max - width_min) * new_value_pct + width_min 
	meter_right:set_actual_size(size_x, t_y)

	if mapping ~= nil then
		if mapping[new_value] ~= nil then
			new_value = mapping[new_value]
		end
	end
	
	slider_value:set_property("text_tag", new_value)
end

-- Sets the highlighted state of the slider to on or off (will eventually have grayed out here too)
function Vdo_slider:set_highlight(is_highlighted)
	local meter_left = Vdo_base_object:new("slider_bg_left", self.handle, self.doc_handle)
	local meter_right = Vdo_base_object:new("slider_bg_right", self.handle, self.doc_handle)
	local arrow_left = Vdo_base_object:new("arrow_left", self.handle, self.doc_handle)
	local arrow_right = Vdo_base_object:new("arrow_right", self.handle, self.doc_handle)
	local slider_bg = Vdo_base_object:new("slider_bg", self.handle, self.doc_handle)

	if is_highlighted then
		meter_left:set_color(self.highlight_color.R, self.highlight_color.G, self.highlight_color.B)
		meter_right:set_color(self.highlight_color.R, self.highlight_color.G, self.highlight_color.B)
		arrow_left:set_visible(true)
		arrow_right:set_visible(true)
		slider_bg:set_visible(true)
	else
		meter_left:set_color(self.highlight_color.R, self.highlight_color.G, self.highlight_color.B)
		meter_right:set_color(self.highlight_color.R, self.highlight_color.G, self.highlight_color.B)	
		--meter_left:set_color(PAUSE_COLOR_SLIDER_FILL_UNSELECTED.R, PAUSE_COLOR_SLIDER_FILL_UNSELECTED.G, PAUSE_COLOR_SLIDER_FILL_UNSELECTED.B)
		--meter_right:set_color(PAUSE_COLOR_SLIDER_FILL_UNSELECTED.R, PAUSE_COLOR_SLIDER_FILL_UNSELECTED.G, PAUSE_COLOR_SLIDER_FILL_UNSELECTED.B)
		arrow_left:set_visible(false)
		arrow_right:set_visible(false)
		slider_bg:set_visible(false)
	end
end

-- Sets the enabled state of the slider to on or off
function Vdo_slider:set_enabled(enabled)
end

-- Sets the width of the slider object
function Vdo_slider:set_width(width)
end

-- This is a hacky function to display the button icon next to the text without highlighting.  It mainly
-- exists for early test screens where we needed to have a back button image with text for descriptive
-- purposes only.
function Vdo_slider:show_button(button_icon)
end

function Vdo_slider:set_highlight_color(new_color)
	self.highlight_color = new_color
end

function Vdo_slider:get_size()
	return VDO_SLIDER_WIDTH, VDO_SLIDER_HEIGHT
end
function Vdo_slider:get_internal_width()
	return VDO_SLIDER_INTERNAL_WIDTH
end

function Vdo_slider:set_disabled(is_disabled)
		
	--Hide Arrows
	if is_disabled == true then
		vint_set_property(self.handle, 		"alpha", 0.5)
	else
		vint_set_property(self.handle, 		"alpha", 1.0)
	end
end