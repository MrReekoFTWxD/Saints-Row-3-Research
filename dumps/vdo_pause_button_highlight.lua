--------------------------------------------------------------------------- 
-- Vdo_pause_button_highlight
--
-- The highlight behind a botton toggle for use in a megalist.
---------------------------------------------------------------------------

-- Standard Init Function
function vdo_pause_button_highlight_init()
	vint_set_property(vint_object_find("highlight_blur_anim"),"state",TWEEN_STATE_DISABLED)
end

-- Standard Cleanup Function
function vdo_pause_button_highlight_cleanup()
end

-- Inherited from Vdo_base_object
Vdo_pause_button_highlight = Vdo_base_object:new_base()

--------------------------------------------------------------------------- 
-- Initializes VDO Object
---------------------------------------------------------------------------
function Vdo_pause_button_highlight:init()
end

--------------------------------------------------------------------------- 
-- Sets the button image on the VDO Object.
-- @param button_icon	Button Icon, please use the globals set in 
--								vdo_hint_button.lua. If no button is provided the
--								button is hidden.
---------------------------------------------------------------------------
function Vdo_pause_button_highlight:show_button(button_icon)
	local button = Vdo_hint_button:new("icon", self.handle)
		
	if game_is_active_input_gamepad() then
		if button.handle ~= 0 then
			if button_icon == "" or button_icon == false then
				button:set_property("visible", false)
			else
				button:set_button( button_icon )
				button:set_property("visible", true)
			end
		end
	else
		button:set_property("visible", false)
	end
end


--------------------------------------------------------------------------- 
-- Sets width of the button highlight
-- @param width    Width of the highlight in pixels
---------------------------------------------------------------------------
function Vdo_pause_button_highlight:set_width(width)
end

function Vdo_pause_button_highlight:set_highlight()
end
function Vdo_pause_button_highlight:set_color(color)
	local bar_obj = Vdo_base_object:new("bar", self.handle)
	bar_obj:set_color(color.R, color.G, color.B)
end

function Vdo_pause_button_highlight:show_bar(is_on)
	local bar_h = vint_object_find("bar", self.handle)
	vint_set_property(bar_h, "visible", is_on)
end
