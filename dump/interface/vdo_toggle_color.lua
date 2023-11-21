--------------------------------------------------------------------------- 
-- Vdo_button_toggle
--
-- A button toggle that ise designed for use in the Vdo_pause_mega_list 
-- This item has 2 text strings label and a value.
---------------------------------------------------------------------------

function vdo_toggle_color_init()
end
function vdo_toggle_color_cleanup()
end

-- Inherited from Vdo_base_object
Vdo_toggle_color = Vdo_base_object:new_base()

function Vdo_toggle_color:init()
	self.color_value_h = vint_object_find("toggle_color_value", self.handle, self.doc_handle)
end

-------------------------------------------------------------------------------
-- Sets on the color part of the VDO
-- @param	color		Table example  { red = 0, green = 1, blue = 0}
-------------------------------------------------------------------------------
function Vdo_toggle_color:set_color_value(color)
	vint_set_property(self.color_value_h, "tint", color.red, color.green, color.blue)
end

-- Sets the width of the button toggle object
function Vdo_toggle_color:set_width(width)
	--this does nothing!?... should be removed?
end

-- Sets the highlighted state of the button to on or off (will eventually have grayed out here too)
function Vdo_toggle_color:set_highlight(is_highlighted)
end

-- Sets the enabled state of the button to on or off
function Vdo_toggle_color:set_enabled(enabled)
end

-------------------------------------------------------------------------------
-- Returns size of color toggle...
-------------------------------------------------------------------------------
function Vdo_toggle_color:get_width()
	return 130 * 3
end +'0