--------------------------------------------------------------------------- 
-- Vdo_button_toggle
--
-- A button toggle that ise designed for use in the Vdo_pause_mega_list 
-- This item has 2 text strings label and a value.
---------------------------------------------------------------------------

function vdo_button_toggle_init()
end
function vdo_button_toggle_cleanup()
end

-- Inherited from Vdo_base_object
Vdo_button_toggle = Vdo_base_object:new_base()

-- "defines"
COLOR_PAUSE_BUTTON_TOGGLE_TEXT_UNSELECTED = {R = 218/255, G = 226/255; B = 230/255}
COLOR_PAUSE_BUTTON_TOGGLE_TEXT_SELECTED = {R = 0/255, G = 0/255; B = 0/255}
COLOR_ICON_LOCK = {R = 90/255, G = 90/255; B = 90/255}
COLOR_ICON_CHECK = {R = 220/255, G = 220/255; B = 220/255}
COLOR_ICON_SPECIAL = {R = 118/255, G = 0/255; B = 157/255}
COLOR_ICON_SPECIAL_DARK = {R = 58/255, G = 0/255; B = 78/255}
local BUTTON_TOGGLE_LOCK_OFFSET = 15 * 3

BUTTON_TOGGLE_ICON_TYPE_NONE			= 0	--No Icon
BUTTON_TOGGLE_ICON_TYPE_LOCK 			= 1	--Lock icon
BUTTON_TOGGLE_ICON_TYPE_BOX			= 2	--Checkbox
BUTTON_TOGGLE_ICON_TYPE_BOX_CHECKED	= 3	--ChecboxChecked
BUTTON_TOGGLE_ICON_TYPE_INDENT		= 4	--Indented (No Icon)
BUTTON_TOGGLE_ICON_TYPE_NEW			= 5	--New item (exclamation point)
BUTTON_TOGGLE_ICON_TYPE_DLC			= 6	--DLC item (fleur)
BUTTON_TOGGLE_ICON_TYPE_SPECIAL		= 7	--Background highlight


function Vdo_button_toggle:init()
	--Store references to icons...
	self.icon1 = Vdo_base_object:new("icon1", self.handle, self.doc_handle)
	self.icon2 = Vdo_base_object:new("icon2", self.handle, self.doc_handle)
	
	-- Hide optional icons
	self:set_icon(0,0)
	self.text_offset = 0
	self.special = false
end

-- Sets the label of the button object
function Vdo_button_toggle:set_label(new_label)
	local text = Vdo_base_object:new("toggle_text", self.handle, self.doc_handle)
	
	if text.handle ~= 0 then
		text:set_property("text_tag", new_label)
	end
end

-- Sets the label crc of the button object
function Vdo_button_toggle:set_label_crc(new_label_crc)
	local text = Vdo_base_object:new("toggle_text", self.handle, self.doc_handle)
	
	if text.handle ~= 0 then
		text:set_property("text_tag_crc", new_label_crc)
	end
end


-- Sets the width of the button toggle object
function Vdo_button_toggle:set_width(width)
	--this does nothing!?... should be removed?
end

-- Sets the highlighted state of the button to on or off (will eventually have grayed out here too)
function Vdo_button_toggle:set_highlight(is_highlighted)

	if is_highlighted then
		local text_obj = Vdo_base_object:new("toggle_text", self.handle, self.doc_handle)
		if self.special ~= true then
			self.icon1:set_color(0,0,0)
		else
			self.icon1:set_color(COLOR_ICON_SPECIAL)
		end
		
		if self.highlight_color ~= nil then
			text_obj:set_color(self.highlight_color.R, self.highlight_color.G, self.highlight_color.B)	
			if self.special ~= true then
				self.icon1:set_color(self.highlight_color.R, self.highlight_color.G, self.highlight_color.B)	
			end
			self.icon2:set_color(self.highlight_color.R, self.highlight_color.G, self.highlight_color.B)	
		else
			text_obj:set_color(COLOR_PAUSE_BUTTON_TOGGLE_TEXT_SELECTED.R, COLOR_PAUSE_BUTTON_TOGGLE_TEXT_SELECTED.G, COLOR_PAUSE_BUTTON_TOGGLE_TEXT_SELECTED.B)
			if self.special ~= true then
				self.icon1:set_color(COLOR_PAUSE_BUTTON_TOGGLE_TEXT_SELECTED.R, COLOR_PAUSE_BUTTON_TOGGLE_TEXT_SELECTED.G, COLOR_PAUSE_BUTTON_TOGGLE_TEXT_SELECTED.B)
			end
			self.icon2:set_color(COLOR_PAUSE_BUTTON_TOGGLE_TEXT_SELECTED.R, COLOR_PAUSE_BUTTON_TOGGLE_TEXT_SELECTED.G, COLOR_PAUSE_BUTTON_TOGGLE_TEXT_SELECTED.B)
		end
	else
		local text_obj = Vdo_base_object:new("toggle_text", self.handle, self.doc_handle)
		text_obj:set_color(self.icon_color.R, self.icon_color.G, self.icon_color.B)
		if self.special ~= true then
			self.icon1:set_color(self.icon_color.R, self.icon_color.G, self.icon_color.B)
		else
			self.icon1:set_color(COLOR_ICON_SPECIAL_DARK)
		end
		self.icon2:set_color(self.icon_color.R, self.icon_color.G, self.icon_color.B)
	end

end

-- Sets the enabled state of the button to on or off
function Vdo_button_toggle:set_enabled(enabled)

	local text = Vdo_base_object:new("toggle_text", self.handle, self.doc_handle)
	
	if enabled then
		text:set_alpha(1)
		--text:set_color(1,1,1)
	else
		text:set_alpha(0.35)
		--text:set_color(.2,.2,.2)	
	end

end

function Vdo_button_toggle:set_highlight_color(new_color)
	self.highlight_color = new_color
end

-------------------------------------------------------------
-- Sets an icon where the (A) button is
--
-- @param icon		Corresponds to one of the following icons
-- BUTTON_TOGGLE_ICON_TYPE_NONE			= 0	--No Icon
-- BUTTON_TOGGLE_ICON_TYPE_LOCK 			= 1	--Lock icon
-- BUTTON_TOGGLE_ICON_TYPE_BOX			= 2	--Checkbox
-- BUTTON_TOGGLE_ICON_TYPE_BOX_CHECKED	= 3	--ChecboxChecked
-- BUTTON_TOGGLE_ICON_TYPE_INDENT		= 4	--Indented (No Icon)
-- BUTTON_TOGGLE_ICON_TYPE_NEW			= 5	--New item (exclamation point)
-- BUTTON_TOGGLE_ICON_TYPE_DLC			= 6	--DLC item (fleur)
-- BUTTON_TOGGLE_ICON_TYPE_SPECIAL		= 7	--Background highlight

-------------------------------------------------------------
function Vdo_button_toggle:set_icon(icon1, icon2)
	local text_obj = Vdo_base_object:new("toggle_text", self.handle, self.doc_handle)
	local text_obj_x, text_obj_y = text_obj:get_anchor()
	local icon2_x, icon2_y = self.icon2:get_anchor()
	local indent_count = 0
	
	self.icon_color = COLOR_PAUSE_BUTTON_TOGGLE_TEXT_UNSELECTED
	
	if icon1 == BUTTON_TOGGLE_ICON_TYPE_LOCK then
		self.icon1:set_image("uhd_ui_store_icon_lock_sm")
		self.icon1:set_visible(true)
	
		self.icon_color = COLOR_ICON_LOCK
	elseif icon1 == BUTTON_TOGGLE_ICON_TYPE_BOX then
		self.icon1:set_image("uhd_ui_store_icon_box")
		self.icon1:set_visible(true)
		
		self.icon_color = COLOR_ICON_CHECK

	elseif icon1 == BUTTON_TOGGLE_ICON_TYPE_BOX_CHECKED then
		self.icon1:set_image("uhd_ui_store_icon_checkbox")
		self.icon1:set_visible(true)
		
		self.icon_color = COLOR_ICON_CHECK
	elseif icon1 == BUTTON_TOGGLE_ICON_TYPE_NEW then
		self.icon1:set_image("uhd_ui_menu_tmp_arrow_e")
		self.icon1:set_visible(true)
		
		--self.icon_color = self.highlight_color
	elseif icon1 == BUTTON_TOGGLE_ICON_TYPE_DLC then
		self.icon1:set_image("uhd_ui_store_icon_dlc")
		self.icon1:set_visible(true)
		
		--self.icon_color = self.highlight_color
	elseif icon1 == BUTTON_TOGGLE_ICON_TYPE_SPECIAL then
		self.icon1:set_image("ui_blank")
		self.icon1:set_property("auto_offset", "w")
		self.icon1:set_scale(60, 1.6) -- Hacky, but works
		self.icon1:set_visible(true)
		
		local x, y = self.icon1:get_anchor()
		self.icon1:set_anchor(x - (100 * 3), y) -- Hacky, but works
		
		self.icon1:set_color(COLOR_ICON_SPECIAL_DARK)
		self.special = true
	else
		self.icon1:set_visible(false)
	end
	
	-- If we set icon2 move the button text over as well
	if icon2 == BUTTON_TOGGLE_ICON_TYPE_INDENT then
		-- Indent the text to align with other text w/ checkboxes
		text_obj:set_anchor(icon2_x + BUTTON_TOGGLE_LOCK_OFFSET, text_obj_y)
		indent_count = indent_count + 1
	elseif icon2 == BUTTON_TOGGLE_ICON_TYPE_LOCK then
		text_obj:set_anchor(icon2_x + BUTTON_TOGGLE_LOCK_OFFSET, text_obj_y)
		self.icon2:set_image("uhd_ui_store_icon_lock_sm")
		self.icon2:set_visible(true)
		
		self.icon_color = COLOR_ICON_LOCK
		indent_count = indent_count + 1
	elseif icon2 == BUTTON_TOGGLE_ICON_TYPE_BOX then
		text_obj:set_anchor(icon2_x + BUTTON_TOGGLE_LOCK_OFFSET, text_obj_y)
		self.icon2:set_image("uhd_ui_store_icon_box")
		self.icon2:set_visible(true)
		
		self.icon_color = COLOR_ICON_CHECK
		indent_count = indent_count + 1
	elseif icon2 == BUTTON_TOGGLE_ICON_TYPE_BOX_CHECKED then
		text_obj:set_anchor(icon2_x + BUTTON_TOGGLE_LOCK_OFFSET, text_obj_y)
		self.icon2:set_image("uhd_ui_store_icon_checkbox")
		self.icon2:set_visible(true)
		
		self.icon_color = COLOR_ICON_CHECK
		indent_count = indent_count + 1
	else
		self.icon2:set_visible(false)
	end	
	
	--Count how many times we were indented and add it to our text offset...
	self.text_offset = indent_count * (BUTTON_TOGGLE_LOCK_OFFSET + icon2_x)
end

-------------------------------------------------------------------------------
-- returns the size of the first text element...
-------------------------------------------------------------------------------
function Vdo_button_toggle:get_text_width()
	local text_obj = Vdo_base_object:new("toggle_text", self.handle, self.doc_handle)
	local width, height = text_obj:get_actual_size()
	--Size is the width of the text field plus the offset from the icon...
	return width + self.text_offset
end

function Vdo_button_toggle:set_label_anchor(new_x)
	local text_obj = Vdo_base_object:new("toggle_text", self.handle, self.doc_handle)
	local toggle_text_x, toggle_text_y = text_obj:get_anchor()
	
	text_obj:set_anchor(new_x, toggle_text_y)
end

function Vdo_button_toggle:get_label_anchor()
	local text_obj = Vdo_base_object:new("toggle_text", self.handle, self.doc_handle)
	
	return text_obj:get_anchor()
end

function Vdo_button_toggle:set_text_scale(scale)
	local text_h = vint_object_find("toggle_text", self.handle, self.doc_handle)
	vint_set_property(text_h, "text_scale", scale, scale)
end
'0