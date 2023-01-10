--------------------------------------------------------------------------- 
-- Vdo_button_remap
--
-- A PC-specific button for remapping shortcut keys
---------------------------------------------------------------------------

function vdo_button_remap_init()
end
function vdo_button_remap_cleanup()
end

-- Inherited from Vdo_base_object
Vdo_button_remap = Vdo_base_object:new_base()

local DEFAULT_VALUE1_OFFSET = 150 * 3
local DEFAULT_VALUE2_OFFSET = 100 * 9

local SCALE_UNSELECTED = 0.8
local SCALE_SELECTED = 0.8

function Vdo_button_remap:init()
	self.value_bg = {}
	self.value_text = {}
	self.value_button = {}
	
	-- Get references to the subelements
	self.label_text =  Vdo_base_object:new("label_text", self.handle, self.doc_handle)
	self.value_bg[1] =  Vdo_base_object:new("value1_bg1", self.handle, self.doc_handle)
	self.value_text[1] =  Vdo_base_object:new("value1_text", self.handle, self.doc_handle)
	self.value_button[1] =  Vdo_hint_button:new("value1_button", self.handle, self.doc_handle)
	self.value_bg[2] =  Vdo_base_object:new("value2_bg", self.handle, self.doc_handle)
	self.value_text[2] =  Vdo_base_object:new("value2_text", self.handle, self.doc_handle)
	self.value_button[2] =  Vdo_hint_button:new("value2_button", self.handle, self.doc_handle)
	
	self.value_bg[1]:set_visible(false)
	self.value_bg[2]:set_visible(false)
	
	-- Set blank defaults
	self:set_shortcut(1, nil)
	self:set_shortcut(2, nil)
	self:set_label("EMPTY")
	
	-- Nothing highlighted by default
	self:set_highlight_column(0)
	
	self:set_highlight(false)
end

-- Moves the value elements to their proper location
function Vdo_button_remap:set_value_offset(offset)
	self.value_bg[1]:set_anchor(DEFAULT_VALUE1_OFFSET + offset, 0)
	self.value_text[1]:set_anchor(DEFAULT_VALUE1_OFFSET + offset, 0)
	self.value_button[1]:set_anchor(DEFAULT_VALUE1_OFFSET + offset, 0)
	self.value_bg[2]:set_anchor(DEFAULT_VALUE2_OFFSET + offset, 0)
	self.value_text[2]:set_anchor(DEFAULT_VALUE2_OFFSET + offset, 0)
	self.value_button[2]:set_anchor(DEFAULT_VALUE2_OFFSET + offset, 0)
end

-- Sets the shortcut (nil to clear)
function Vdo_button_remap:set_shortcut(column, shortcut)
	if shortcut == nil then
		self.value_text[column]:set_text("--")
		self.value_text[column]:set_visible(true)
		self.value_button[column]:set_visible(false)
	else
		self.value_text[column]:set_visible(false)
		self.value_button[column]:set_visible(true)
		self.value_button[column]:set_button(nil, shortcut)
	end
end

-- Wait for the player to press a button (show a "?")
function Vdo_button_remap:wait_for_key(index, column)
	self.value_text[column]:set_text("?")
	self.value_text[column]:set_visible(true)
	self.value_button[column]:set_visible(false)
	-- Remap_category_index is in pause_options_remap
	vint_options_remap_set_key_binding(Remap_category_index, index - 1, column == 2) -- Subtract 1 because category is index 1, remapping starts at 2
end

-- Sets the label of the button object
function Vdo_button_remap:set_label(new_label)
	self.label_text:set_property("text_tag", new_label)
end

-- Sets the width of the button toggle object
function Vdo_button_remap:set_width(width)
	--this does nothing!?... should be removed?
end

-- Sets highlighting on/off for the megalist
function Vdo_button_remap:set_highlight(highlight)	
	if highlight == false then
		self.label_text:set_color(COLOR_PAUSE_BUTTON_TOGGLE_TEXT_UNSELECTED)	
		self.current_column = 0
	else
		self.label_text:set_color(COLOR_PAUSE_BUTTON_TOGGLE_TEXT_SELECTED)
		
		if self.current_column == 0 then
			self.current_column = 1
		end
	end
	
	self:update_column_highlight()
end

-- Sets which column is highlighted, or 0 for none (the whole thing is not highlighted)
function Vdo_button_remap:set_highlight_column(highlight_column)	
	self.current_column = highlight_column
	
	self:update_column_highlight()
end

function Vdo_button_remap:update_column_highlight()
	self.value_text[1]:set_color(COLOR_PAUSE_BUTTON_TOGGLE_TEXT_UNSELECTED)	
	self.value_text[2]:set_color(COLOR_PAUSE_BUTTON_TOGGLE_TEXT_UNSELECTED)	
	self.value_button[1]:set_scale(SCALE_UNSELECTED, SCALE_UNSELECTED)
	self.value_button[2]:set_scale(SCALE_UNSELECTED, SCALE_UNSELECTED)
	self.value_button[1]:set_color(COLOR_PAUSE_BUTTON_TOGGLE_TEXT_UNSELECTED)	
	self.value_button[2]:set_color(COLOR_PAUSE_BUTTON_TOGGLE_TEXT_UNSELECTED)
	self.value_button[1]:set_scale(SCALE_UNSELECTED, SCALE_UNSELECTED)
	self.value_button[2]:set_scale(SCALE_UNSELECTED, SCALE_UNSELECTED)
	
	if self.current_column > 0 then
		self.value_text[self.current_column]:set_color(COLOR_PAUSE_BUTTON_TOGGLE_TEXT_SELECTED)	
		self.value_button[self.current_column]:set_color(COLOR_PAUSE_BUTTON_TOGGLE_TEXT_SELECTED)	
		self.value_text[self.current_column]:set_scale(SCALE_SELECTED, SCALE_SELECTED)
		self.value_button[self.current_column]:set_scale(SCALE_SELECTED, SCALE_SELECTED)
	end
end

function Vdo_button_remap:get_target_column(handle)
	if handle == self.value_bg[1].handle then
		return 1
	elseif handle == self.value_bg[2].handle then
		return 2
	else
		return 0
	end
end

-- Sets the enabled state of the button to on or off
function Vdo_button_remap:set_enabled(enabled)	
	if enabled then
		self.label_text:set_alpha(1)
	else
		self.label_text:set_alpha(0.35)
	end
end

function Vdo_button_remap:set_highlight_color(new_color)
	self.highlight_color = new_color
end

-- Get the size of the label's text
function Vdo_button_remap:get_text_width()
	local width, height = self.label_text:get_actual_size()

	return width
end