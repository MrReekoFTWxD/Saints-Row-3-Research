Vdo_mega_list_tween_done = true

local Game_platform
local Toggle_mouse_input_tracker

function vdo_mega_list_init()
end

function vdo_mega_list_cleanup()
end

function vdo_mega_list_scroll_done(tween_h, event_name)
	-- remove this callback
	--remove_tween_end_callback( vint_object_find("toggle_group_anchor_tween") )
	Vdo_mega_list_tween_done = true
end

-- Inherited from Vdo_base_object
Vdo_mega_list = Vdo_base_object:new_base()

local MEGA_LIST_DEFAULT_WIDTH = 465 * 3						--Default width of megalist...
local BUTTON_ANCHOR_OFFSET = 0.5
local ANCHOR_SLIDER_LABEL = -30 * 3
local SLIDER_PADDING_RIGHT =  5 * 3								--padding from right side for toggles and sliders...
local MEGA_LIST_BUTTON_SPACING = -10						--vertical button spacing between options, this is -3 because the highlight actually overlaps between the options.
local MEGA_LIST_BUTTON_PADDING = 15						--Padding for the right side of button
local MEGALIST_HIGHLIGHT_WIDTH_OFFSET = -7			-- offset width for the highlight bar...
local MEGALIST_SCROLLBAR_PADDING = 5 * 3			-- offset width for the highlight bar...
local WIDE_HITBOX_OFFSET = -36 * 3

function Vdo_mega_list:init()

	-- Store common objects to self...
	self.group_h = vint_object_find("toggle_group", self.handle, self.doc_handle)	
	self.button_highlight =	Vdo_button_highlight:new("toggle_highlight", self.handle, self.doc_handle)
	self.toggle_base = Vdo_button_toggle:new("toggle_base", self.handle, self.doc_handle)
	self.toggle = Vdo_toggle:new("toggle_toggle", self.handle, self.doc_handle)
	self.slider = Vdo_slider:new("toggle_slider", self.handle, self.doc_handle)
	self.row = Vdo_row:new("toggle_row", self.handle, self.doc_handle)
	self.toggle_color = Vdo_toggle_color:new("toggle_color", self.handle, self.doc_handle)
	self.remap = Vdo_button_remap:new("toggle_remap", self.handle, self.doc_handle)
	self.scrollbar = Vdo_scrollbar:new("mega_list_scrollbar", self.handle, self.doc_handle)
	
	self.clip_h = vint_object_find("list_clip", self.handle)
	
	-- Hide our base objects...
	vint_set_property(self.toggle_base.handle, "visible", false)
	
	vint_set_property(self.toggle.handle, "visible", false)
	vint_set_property(self.toggle.handle, "alpha", 1)
	
	vint_set_property(self.slider.handle, "visible", false)
	vint_set_property(self.slider.handle, "alpha", 1)

	vint_set_property(self.row.handle, "visible", false)
	vint_set_property(self.row.handle, "alpha", 1)
	
	vint_set_property(self.toggle_color.handle, "visible", false)
	vint_set_property(self.toggle_color.handle, "alpha", 1)
	
	vint_set_property(self.remap.handle, "visible", false)
	vint_set_property(self.remap.handle, "alpha", 1)
		
	vint_set_property(self.scrollbar.handle, "visible", false)
	vint_set_property(self.scrollbar.handle, "alpha", 1)

	self.pulse_anim = Vdo_anim_object:new("toggle_pulse_anim", self.handle)
	self.pulse_twn = Vdo_tween_object:new("pulse_twn", self.pulse_anim.handle)		
	
	--default megalist tween to true... 
	Vdo_mega_list_tween_done = true
	
	-- Hide Marquee Mask TODO: MAKE THIS GLOBAL...
	local marq_mask_h = vint_object_find("mega_marquee_mask", self.handle)
	vint_set_property(marq_mask_h, "visible", false)
	vint_set_property(marq_mask_h, "mask", false)

	--Enable clip for megalist...
	vint_set_property(self.clip_h, "clip_enabled", true)
	
	Game_platform = game_get_platform()
	self.visible_start_idx = 1
	self.highlight_on = true		-- highlight is on by default...
	if Game_platform == "PC" then
		Toggle_mouse_input_tracker = Vdo_input_tracker:new()
	end
end

-- Deletes the internal data and destroys the button clones
function Vdo_mega_list:cleanup()
	if self.draw_called then
		for i, button in pairs(self.buttons) do
			self:cleanup_single_item(button)
			self.buttons[i] = nil
		end
		
		if Toggle_mouse_input_tracker ~= nil then
			Toggle_mouse_input_tracker:remove_all()
		end
		
		self.draw_called = false
	end	
end

function Vdo_mega_list:cleanup_single_item(button)
	button:object_destroy()
	if button.slider ~= nil then
		button.slider:object_destroy()
	elseif button.toggle ~= nil then
		button.toggle:object_destroy()
	elseif button.row ~= nil then
		button.row:object_destroy()
	elseif button.toggle_color ~= nil then
		button.toggle_color:object_destroy()
	elseif button.remap ~= nil then
		button.remap:object_destroy()
	end
	
	--Cleanup new tween if exists.
	if button.new_tween ~= nil then
		button.new_tween:object_destroy()
	end
	button = nil
end

--This should only be called internally by Vdo_mega_list:draw_items()
function Vdo_mega_list:set_size(width)
	
	-- Handle clip size
	
	--TODO: FIX THIS FAKE PADDING... +2???
	--First Button height + max buttons in list + spacing between buttons)
	local clip_height = LIST_BUTTON_HEIGHT + ((self.max_buttons - 1) * (LIST_BUTTON_HEIGHT + MEGA_LIST_BUTTON_SPACING )) 
	
	local clip_height = clip_height
	vint_set_property(self.clip_h, "clip_size", width, clip_height)
	
	--set width of highlight
	self.button_highlight:set_width(width)
	
	-- Handle scrolling
	if(#self.data > self.max_buttons) then
		--show the scroll bar
		self.scrollbar:set_property("visible", true)
		
		local scrollbar_height = clip_height
		if Game_platform == "PC" then
			local move_height = LIST_BUTTON_HEIGHT + MEGA_LIST_BUTTON_SPACING
			local total_height = self.num_buttons * move_height
			self.scrollbar:set_size(SCROLLBAR_WIDTH, scrollbar_height, total_height)
		else
			--set the size of the scrollbar
			self.scrollbar:set_size(SCROLLBAR_WIDTH, scrollbar_height)
		end
		
		--set position of scrollbar
		local scrollbar_x = width + MEGALIST_SCROLLBAR_PADDING
		self.scrollbar:set_property("anchor", scrollbar_x, 0) 
		
	else
		--show the scroll bar
		self.scrollbar:set_property("visible", false)
	end	

	self.width = width
end


-------------------------------------------------------------------------------
-- Refreshes and Draws the mega list with new data
--	@param	data					table representing the list to display
-- @param	current_option		option you want highlighted
-- @param	width					min width for the menu(the selector will draw up to here)
-- @param	max_buttons			how many buttons in the list
-- @param	font_scale			scale of fonts in the list
-- @param	force_width			force the width of list. Buttons will marquee in this mode.
--										(Be sure to setup the lua_document, and Object reference, when	
--										setting this to true or it will explode.)
-------------------------------------------------------------------------------
function Vdo_mega_list:draw_items(data, current_option, width, max_buttons, font_scale, force_width)
	-- Error Check - use 1 to #, since we can have callbacks that aren't tables
	for i = 1, #data do
		if type(data[i]) ~= "table" then
			debug_print("vint", "Vdo_mega_list:draw_items was called with impropperly formatted parameters!\n")
			return
		end
	end
	
	-- Nuke the shit out of whatever was previously here
	self:cleanup()

	-- Set up handle for base button
	local button_copy = self.toggle_base
	if button_copy.handle == 0 then
		debug_print("vint", "Unable to find object \"toggle_base\"")
		return
	end

	--get the x and y of the button
	button_copy.x, button_copy.y = button_copy:get_property("anchor")

	--check to make sure we havn't initialized these values if we are passing in nil...
	if max_buttons == nil and self.max_buttons ~= nil then
		max_buttons = self.max_buttons
	else 
		self.max_buttons = max_buttons
	end
	
	if font_scale == nil and self.font_scale ~= nil then
		font_scale = self.font_scale
	else	
		self.font_scale = font_scale
	end
	
	if width == nil then
		if self.width ~= nil then
			width = self.width
		else
			width = MEGA_LIST_DEFAULT_WIDTH
		end
	end
	if force_width == nil and self.force_width ~= nil then
		force_width = self.force_width
	end
	local include_scrollbar_in_width = nil
	if self.include_scrollbar_in_width ~= nil then
		include_scrollbar_in_width = self.include_scrollbar_in_width
	end
	
	--Set the properties...
	self:set_properties(nil, nil, max_buttons, font_scale, width, force_width, include_scrollbar_in_width)
	
	-- Set up tables to manage handles and data for this object
	self.draw_called = true
	self.buttons = {}

	-- Try to only copy the data we need, instead of all of it
	self.data = data

	self.old_slider_value = nil
	self.old_toggle_value = nil
	self.slider_anchor_y = 0
	self.toggle_anchor_y = 0
	self.button_x = button_copy.x			--Store x position of button...
	self.label_x = 0
	
	self.item_range_min = 0
	self.item_range_max = 0
	
	--calculate new width based on scrollbar data...
	if self.include_scrollbar_in_width == true and #self.data > self.max_buttons then
		width = width - SCROLLBAR_WIDTH - (MEGALIST_SCROLLBAR_PADDING * 2)
	end

	self.anims = {}
	
	--Stop the animation that handles scrolling...
	local toggle_group_anim = Vdo_anim_object:new("toggle_group_anim", self.handle, self.doc_handle)
	toggle_group_anim:stop()
	Vdo_mega_list_tween_done = true
	
	-- Save the number of buttons
	self.num_buttons = #data

	-- Find and store size of sliders
	self.slider_width, self.toggle_slider_height = self.slider:get_size()
	
	self.toggle_width = 0
	
	-- Find and store size of toggle colors
	self.toggle_color_width = self.toggle_color:get_width()
	
	-- Count how many sliders and toggles are in list
	local num_toggles = 0
	local num_sliders = 0
	local num_rows = 0
	local num_toggle_colors = 0
	local num_remaps = 0
	
	--widths of the components to calculate layout.
	self.max_label_width 			= 0
	self.toggle_max_value_width 	= 0
	self.row_largest_col_1 			= 10
	self.row_largest_col_2 			= 10
	self.row_largest_col_3 			= 10
	self.row_largest_col_4 			= 0

	if font_scale ~= nil then
		self.font_scale = font_scale
	else
		self.font_scale = 1
	end

	--Loop through the items, draw them, but delete them afterwards. We will draw the right items we need afterwards.
	--Count how many objects we have of each type.
	for i = 1, self.num_buttons do
		--Draw all the items and delete them when finished.
		--This will run through all the calculations we need to calculate the positions and widths for items when we are completed.
		self:draw_single_item(i, true)
		
		local item = data[i]
		if item.type == TYPE_TOGGLE then
			num_toggles = num_toggles + 1
		elseif item.type == TYPE_SLIDER then
			num_sliders = num_sliders + 1
		elseif item.type == TYPE_ROW then
			num_rows = num_rows + 1
		elseif item.type == TYPE_TOGGLE_COLOR then
			num_toggle_colors = num_toggle_colors + 1
		elseif item.type == TYPE_REMAP then
			num_remaps = num_remaps + 1
		end			
	end
	
	--If we have no sliders then we do not use slider width in calculating the width...
	if num_sliders == 0 then
		self.slider_width = 0
	end
	
	if num_toggle_colors == 0 then
		self.toggle_color_width = 0
	end
	
	self.row_width = 0
	if num_rows == 0 then
		self.row_width = 0
	else
		--I couldn't figure out a better way to calculate the row width other than building one temporarily and deleting it...(JMH 8/5/2011)
		local temp_row = Vdo_row:clone(self.row.handle)
		temp_row:set_value("label_1", "label_2", "label_3", "label_4")	
		temp_row:set_max_width(width)
		temp_row:format_columns(self.row_largest_col_1, self.row_largest_col_2, self.row_largest_col_3, self.row_largest_col_4)
		self.row_width = temp_row:get_width()
		temp_row:object_destroy()
	end
	
	if num_toggles ~= 0 then
		--I couldn't figure out a better way to calculate the row width other than building one temporarily and deleting it...(JMH 8/5/2011)
		local temp_toggle = Vdo_toggle:clone(self.toggle.handle)
		temp_toggle:set_text_scale(self.font_scale)
		temp_toggle:set_value("toggle")
		temp_toggle:set_width(self.toggle_max_value_width)
		self.toggle_width = temp_toggle:get_width()
		temp_toggle:object_destroy()
	end
	
	local remap_width = 0
	if num_remaps == 0 then
		remap_width = 0
	else
		-- TODO: Update this to actually come from somewhere
		remap_width = 200*3
	end
	
	-- If the string and slider are greater than the width passed into draw items 
	-- then expand the width to accomodate
		
	--Accomodate for button offset in the max_label_width...
	self.button_offset = (self.button_x)
	if self.num_buttons == num_sliders or self.num_buttons == num_toggles then
		self.button_offset = self.button_x + ANCHOR_SLIDER_LABEL		
	end
	self.max_label_width = self.max_label_width + self.button_offset
	
	--Calculate the new width
	local new_width = width	
	local width_of_slider_item = self.max_label_width + self.slider_width 
	local width_of_toggle_item = self.max_label_width + self.toggle_max_value_width
	new_width = max(self.max_label_width, new_width)	--Compare against normal width of an item...
	new_width = max(width_of_slider_item, new_width)	--Compare against slider...
	new_width = max(width_of_toggle_item, new_width)	--Compare against toggles...
	new_width = max(self.row_width, new_width)		--Compare against row width...
	new_width = max(remap_width, new_width)	--Compare against remap width
	self.new_width = new_width

	--Toggle X
	self.slider_x 			= 0
	self.toggle_x 			= 0
	self.toggle_color_x 	= 0

	--Store positions for everything...
	--These are all sliders, so they need to be repositioned...
	if self.num_buttons == num_sliders then
		self.label_x = ANCHOR_SLIDER_LABEL
		self.slider_x = new_width - self.slider_width
	else		
		self.slider_x = new_width - self.slider_width
	end
	
	--Align toggles
	if self.num_buttons == num_toggles then
		self.label_x = ANCHOR_SLIDER_LABEL
	end
	
	--Make sure this value is at least as big as our sliders
	if self.slider_width ~= 0 then
		--comparing against internal width (self.slider:get_internal_width()), the size without the arrows,
		--we are comparing this with the internal of the toggle width so we can set the width of the toggle...
		self.toggle_max_value_width = max(self.slider:get_internal_width(), self.toggle_max_value_width)
	end
	
	--Find largest toggle and slider
	local max_item_width = 0
	max_item_width 		= max(max_item_width, self.toggle_width)	--TODO: There is a width for this somewhere...
	max_item_width 		= max(max_item_width, self.slider_width)
	max_item_width 		= max(max_item_width, self.toggle_color_width)
	self.max_item_width = max_item_width
	
	-- Set initial cursor position
	if current_option == nil then
		current_option = 1
	elseif current_option > self.num_buttons then
		current_option = self.num_buttons
	end
	
	--set the cuurent button to the passed in variable for the current option
	self.current_idx = current_option
	
	self.visible_start_idx = 1
	
	
	-- if we force width we should still draw at a certain width...
	if force_width == true then
		--calculate height of our list
		local total_items = #self.data
		local start_y = LIST_BUTTON_HEIGHT * BUTTON_ANCHOR_OFFSET	--height of button * .5 because button is aligned to middle...
		local offset_y = (LIST_BUTTON_HEIGHT + MEGA_LIST_BUTTON_SPACING) * (total_items - 1) 	-- height of button + button spacing * the button index. (-1 because our index starts at 1 and the first item doesn't need offset...)
		local mask_height = start_y + offset_y + (LIST_BUTTON_HEIGHT + MEGA_LIST_BUTTON_SPACING)

		
		if self.marquee_anim == nil then
			--only set up callbacks if we havn't done it already...
			self.marquee_anim = Vdo_anim_object:new("marquee_anim", self.handle, self.doc_handle)
			local marquee_end_twn_h = vint_object_find("marquee_end_twn", self.marquee_anim.handle)
			local twn_cb = self:package_tween_callback("marquee_loop_cb")
			vint_set_property(marquee_end_twn_h, "end_event", twn_cb)
		end
		
		-- Show Marquee Mask
		local marq_mask_h = vint_object_find("mega_marquee_mask", self.handle)
		vint_set_property(marq_mask_h, "visible", true)
		vint_set_property(marq_mask_h, "mask", true)
		element_set_actual_size(marq_mask_h, width, mask_height)
		new_width = width
		self.force_width = true
	else
		local marq_mask_h = vint_object_find("mega_marquee_mask", self.handle)
		vint_set_property(marq_mask_h, "visible", false)
		vint_set_property(marq_mask_h, "mask", false)
		self.force_width = false
	end
	
	self:set_size(new_width)
	
	--Draw the items now just as if the script hasn't changed yet...
	self:draw_item_range(self.current_idx) 

	
	
	--reset the y of the list group
	local list_x, list_y = vint_get_property(self.group_h, "anchor")
	vint_set_property(self.group_h, "anchor", list_x, 0)
	
	-- Draw the cursor
	self:move_cursor(0)
	if self.highlight_on ~= nil then
		self:toggle_highlight(self.highlight_on)
	end
end


-------------------------------------------------------------------------------
-- Sets the properties of the megalist...
-- megalist_properties = {
--		max_buttons
--		font_scale
--		width,
--		force_width
--		include_scrollbar_in_width
--		highlight_color
--		non_highlight_color
--		set_highlight_color
-- }


function Vdo_mega_list:set_properties(highlight_color, non_highlight_color, max_buttons, font_scale, width, force_width, include_scrollbar_in_width)
		
	--Set highlight color
	if highlight_color ~= nil and non_highlight_color ~= nil then
		self:set_highlight_color(highlight_color, non_highlight_color)
	end
	
	self.max_buttons = max_buttons or 999	--Default max buttons
	self.font_scale = font_scale or 1.0*.9		--Default scale.
	self.width = width or (465 * 3)					--Default width
	self.force_width = force_width or false		--force width is off by default..
	if include_scrollbar_in_width == nil then
		--force width is off by default..
		self.include_scrollbar_in_width = false
	else
		self.include_scrollbar_in_width = include_scrollbar_in_width
	end
end

--

function Vdo_mega_list:draw_item_range(current_option)

	if game_get_platform() == "PC" then
		for i = 1, #self.data do 
			self.buttons[i] = self:draw_single_item(i, false)		
		end
		return
	end

	--This could be streamlined...
	local item_min = current_option - self.max_buttons
	local item_max = current_option + self.max_buttons
	
	if item_min < 1 then
		item_min = 1
	end
	local total_items = #self.data
	if item_max > total_items then
		item_max = total_items
	end

	if item_max < item_min then
		--fail
		return
	end
	
	--check if its equals...
	
	
	for i, button in pairs(self.buttons) do
		local destroy_button = false
		
		--remove the items below...		
		if i < item_min then
			destroy_button = true
		elseif i > item_max then
			destroy_button = true
		end
		
		if destroy_button then
			self:cleanup_single_item(button)
			self.buttons[i] = nil
		end
	end
	
	--redraw all the items in range if we are redrawing the list...
	local draw_all_items_in_range = false
	if self.item_range_min == 0 and self.item_range_max == 0 then
		draw_all_items_in_range =  true
	end
	
	
	for i = item_min, item_max do  -- item_min + item_max
		local create_button = false
		if i <= self.item_range_min then
			create_button = true
		elseif i >= self.item_range_max then
			create_button = true
		end

		if create_button or draw_all_items_in_range then
			if self.buttons[i] == nil then
				self.buttons[i] = self:draw_single_item(i, false)
			end
		end
	end
	
	self.item_range_min = item_min
	self.item_range_max = item_max
end

function Vdo_mega_list:draw_single_item(item_index, check_size)
		-- Assign the button copy to the table that manages data for this object
		local button_copy = self.toggle_base
		button_copy.x, button_copy.y = button_copy:get_property("anchor")
		
		local button = Vdo_button_toggle:clone(button_copy.handle)
		local item = self.data[item_index]
								
		--Reset Icon....
		button:set_icon(BUTTON_TOGGLE_ICON_TYPE_NONE, BUTTON_TOGGLE_ICON_TYPE_NONE)				
							
		if item.label ~= nil then
			button:set_label(item.label)
		else
			button:set_label_crc(item.label_crc)
		end
		

		--create new tween flash if its new and we are actually building the list...
		if item.is_new == true and check_size == false then
			
			-- set icon to new icon (exclamation point)
			button:set_icon(BUTTON_TOGGLE_ICON_TYPE_NEW, BUTTON_TOGGLE_ICON_TYPE_NONE)
			button:set_color(self.highlight_color)
			
			-- clone and play pulse twn	
			button.new_tween = Vdo_tween_object:clone(self.pulse_twn.handle)
			button.new_tween:set_target_handle(button.handle)
			
			self.pulse_anim:play(0)			
		end
		
		if item.is_dlc == true then			
			-- set icon to new icon (exclamation point)
			button:set_icon(BUTTON_TOGGLE_ICON_TYPE_DLC, BUTTON_TOGGLE_ICON_TYPE_NONE)
		end		
		
		if item.is_locked then
			button:set_icon(BUTTON_TOGGLE_ICON_TYPE_LOCK, BUTTON_TOGGLE_ICON_TYPE_NONE)
		else
			if item.equipped ~= nil then
				if item.equipped then
					-- Display Checked Checkbox...
					button:set_icon(BUTTON_TOGGLE_ICON_TYPE_NONE, BUTTON_TOGGLE_ICON_TYPE_BOX_CHECKED)
				elseif item.equipped == false and item.owned == true then
					-- Display Empty Checkbox...
					button:set_icon(BUTTON_TOGGLE_ICON_TYPE_NONE, BUTTON_TOGGLE_ICON_TYPE_BOX)
				else
					--Still indent icon...
					button:set_icon(BUTTON_TOGGLE_ICON_TYPE_NONE, BUTTON_TOGGLE_ICON_TYPE_INDENT)
				end
				button.is_indented = true
			elseif item.is_purchased then
				-- Display Checkbox...
				button:set_icon(BUTTON_TOGGLE_ICON_TYPE_BOX_CHECKED, BUTTON_TOGGLE_ICON_TYPE_NONE)
			end
		end
		
		if item.disabled == true then
			button:set_enabled(false)
		else
			button:set_enabled(true)
		end
		
		if item.is_special == true then
			button:set_icon(BUTTON_TOGGLE_ICON_TYPE_SPECIAL, BUTTON_TOGGLE_ICON_TYPE_NONE)
		end
		
		-- Move the button copy into the correct position
		local new_y = 0
		
		--Set text scale on the button...
		button:set_text_scale(self.font_scale, self.font_scale)
		
		local start_y = LIST_BUTTON_HEIGHT * BUTTON_ANCHOR_OFFSET	--height of button * .5 because button is aligned to middle...
		local offset_y = (LIST_BUTTON_HEIGHT + MEGA_LIST_BUTTON_SPACING) * (item_index - 1) 	-- height of button + button spacing * the button index. (-1 because our index starts at 1 and the first item doesn't need offset...)
		new_y = start_y + offset_y
		button:set_property("anchor", button_copy.x, new_y)
	
		
		-- Make the button visible
		button:set_property("visible", true)
		
		-- Find largest text string and store it to self...
		local text_width = button:get_text_width() + MEGA_LIST_BUTTON_PADDING
		self.max_label_width = max(text_width, self.max_label_width)
	
		-- If the item is more than a button then we will attach something special to it...
		if item.type == TYPE_TOGGLE then
			-- Clone toggle
			local toggle = Vdo_toggle:clone(self.toggle.handle)
			
			--Show toggle
			toggle:set_visible(true)
			
			--Set the scale of the toggle element...
			toggle:set_text_scale(self.font_scale)
			
			--Re-set Highlight colors on objects before they are cloned...
			toggle:set_highlight_color(self.highlight_color)	
			
			if item.disabled == true then
				toggle:set_disabled(true)
			end

			if check_size == true then
				--Test width all the options in the toggle, store off the data to self, then destroy the object.
				local max_value_width = 0 
		
				local options = item.options
				local num_options = #options
				for option_idx = 1, num_options do
					toggle:set_value(options[option_idx])
					local toggle_value_width = toggle:get_value_width()
					max_value_width = max(toggle_value_width, max_value_width)
				end
				self.toggle_max_value_width = max(self.toggle_max_value_width, max_value_width)
				
				--Destroy Toggle
				toggle:object_destroy()
			else
				--Populate the toggle with current data, align toggle, then store off toggle to button.
				local options = item.options
				local option_idx = item.current_value
				local cur_value = options[option_idx]
				toggle:set_value(cur_value)	
				toggle:set_width(self.toggle_max_value_width)
				
				--Align toggle in the list
				local toggle_x, toggle_y = button:get_anchor()	
				local toggle_x = self.new_width - (self.max_item_width * .5) - (toggle:get_width() * .5) - SLIDER_PADDING_RIGHT
				toggle:set_property("anchor", toggle_x , toggle_y)
			
				--Change button anchor...
				button:set_label_anchor(self.label_x)
			
				-- Store Toggle
				button.toggle = toggle
			end
		elseif item.type == TYPE_SLIDER then
			local slider = Vdo_slider:clone(self.slider.handle)
			
			--Show Slider
			slider:set_visible(true)
			
			slider:set_highlight_color(self.highlight_color)	
			
			if item.disabled == true then
				slider:set_disabled(true)
			end			
			
			if check_size then
				--Destroy Slider
				slider:object_destroy()
			else
				-- Set value
				slider:set_value(item.current_value, item.min, item.max, nil, item.mapping)
			
				--Align slider in list...
				local slider_x, slider_y = button:get_anchor()		
				slider_x = self.new_width - (self.max_item_width * .5) - (self.slider_width *.5) - SLIDER_PADDING_RIGHT
				slider:set_property("anchor", slider_x, slider_y)
			
				--Change button anchor...
				button:set_label_anchor(self.label_x)
			
				-- Store Slider
				button.slider = slider
			end
		elseif item.type == TYPE_ROW then

			button:set_label("")
			button:set_property("visible", false)
			--Clone Toggle and update values...
			local row = Vdo_row:clone(self.row.handle)
			
			row:set_font_scale(self.font_scale)
			
			local row_alignment = self.data.row_alignment
			if row_alignment ~= nil then
				row:set_alignment(row_alignment[1], row_alignment[2], row_alignment[3], row_alignment[4])
			end
			
			local row_column_count = self.data.row_column_count
			if row_column_count ~= nil then
				row:set_column_count(row_column_count)
			end
		
			-- Set the button toggle value
			row:set_value(item.label_1, item.label_2, item.label_3, item.label_4)	
			row:set_property("anchor", button_copy.x, new_y)
			row:set_property("alpha", 1)
				
			row:set_visible(true)
			
			if check_size then
				--Check the sizes and store them to global...
				local row_col_1, row_col_2, row_col_3, row_col_4 = row:get_column_widths()
				self.row_largest_col_1 = max(row_col_1, self.row_largest_col_1)
				self.row_largest_col_2 = max(row_col_2, self.row_largest_col_2)
				self.row_largest_col_3 = max(row_col_3, self.row_largest_col_3)
				self.row_largest_col_4 = max(row_col_4, self.row_largest_col_4)
			
				--Destroy Row
				row:object_destroy()
			else
				row:set_max_width(self.width)
				row:format_columns(self.row_largest_col_1, self.row_largest_col_2, self.row_largest_col_3, self.row_largest_col_4)
				-- Store Row
				button.row = row
			end
		elseif item.type == TYPE_TOGGLE_COLOR then
			--Clone Color Toggle and update values...
			local toggle_color = Vdo_toggle_color:clone(self.toggle_color.handle)
			
			toggle_color:set_color_value(item.color)
			toggle_color:set_property("anchor", button_copy.x, new_y)
			
			toggle_color:set_property("alpha", 1)
			toggle_color:set_visible(true)
			
			if check_size then
				--Destroy Color
				toggle_color:object_destroy()
			else
				local toggle_color_x, toggle_color_y = button:get_anchor()		
				toggle_color_x = self.new_width - (self.max_item_width * .5) - (self.toggle_color_width *.5) - SLIDER_PADDING_RIGHT
				toggle_color:set_property("anchor", toggle_color_x, toggle_color_y)
			
				--Change button anchor...
				button:set_label_anchor(self.label_x)
			
				-- Store Color
				button.toggle_color = toggle_color
			end	
		elseif item.type == TYPE_REMAP then
			--Set all properties here...
			button:set_label("")
			button:set_property("visible", false)
			
			--Clone and update values...
			local remap = Vdo_button_remap:clone(self.remap.handle)
			
			-- TODO: Make this init correctly
			remap:set_label(item.label)	
			remap:set_shortcut(1, item.value1)	
			remap:set_shortcut(2, item.value2)	
			remap:set_property("anchor", button_copy.x, new_y)
			remap:set_property("alpha", 1)
			remap:set_visible(true)
			remap:set_value_offset(self.width - (450 * 3))
			
			--Change button anchor...
			button:set_label_anchor(self.label_x)
			
			-- Resize the click region to cover the label.
			local second_button_x = remap.value_bg[2]:get_property("anchor")
			local second_button_w = remap.value_bg[2]:get_actual_size()
			local new_width = (second_button_x - self.label_x - second_button_w / 2) / 2;
			local old_scale_x, old_scale_y = remap.value_bg[1]:get_property("scale")
			remap.value_bg[1]:set_property("anchor", self.label_x + new_width)
			remap.value_bg[1]:set_property("scale", new_width / (remap.value_bg[1]:get_actual_size() / 2) * old_scale_x, old_scale_y)
			
			
			if check_size then
				--Destroy Remap
				remap:object_destroy()
			else
				-- Store Remap
				button.remap = remap
			end
			
			--Set the remap column (used for non-mouse navigation)
			self.remap_column = 1
		end			
		
		if check_size == true then
			button:object_destroy()
			return
		else
			return button
		end
end


-- Updates the mega list.  Possibly changes the currently highlighted choice.
--
-- direction: 0 means to redraw the megalist, but don't move the cursor.  1 means move down, -1 means move up.
-- is_index_set: if the selected index was manually set (by the mouse), then is_index_set will be true
--
function Vdo_mega_list:move_cursor(direction, is_index_set)
	if not self.draw_called then
		debug_print("vint", "Vdo_mega_list:move_cursor called with invalid document handle\n")
		return
	end
	
	-- Default is_index_set to false
	is_index_set = is_index_set or false
	
	local highlight = self.button_highlight

	-- Check if we can process input.  If we can't, we still need to redraw the list, or the state can get out of sync.
	-- But we need to change direction to 0 because we can't start scrolling while we are already scrolling.
	if Vdo_mega_list_tween_done == false then
		direction = 0
	end

	
	--toggle is closed so navigate the list normally
	local current_idx = self.current_idx
	self.current_idx = wrap_index(self.current_idx, direction, self.num_buttons)
	
	if self.data[self.current_idx].disabled == true then
		--Increment the direction
		if direction == 0 then 
			direction = 1
		end

		--check to make sure we are not disabled and keep cycling until we find one that isn't...
		repeat 
			self.current_idx = wrap_index(self.current_idx, direction, self.num_buttons)
		until self.data[self.current_idx].disabled ~= true or current_idx == self.current_idx
	end
	
	local total_buttons = #self.data
	local move_height = LIST_BUTTON_HEIGHT + MEGA_LIST_BUTTON_SPACING

	local new_y = 0
	
	local list_x, list_y = vint_get_property(self.group_h, "anchor")
	
	-- use max_buttons + 1 since the starting index is 1
	local visual_center = ( (self.max_buttons + 1) * 0.5 )
	local button_x, button_y = 0,0

	local scrolling = true		
	
	local extended_row = 0
	
	if self.data[self.current_idx].max_level ~= nil then
		-- Make room for extended highlight
		visual_center = (self.max_buttons * 0.5)
		extended_row = 1
	end	

	--do we need to scroll?
	if direction == 1 then	-- moving down the list
		if Game_platform == "PC" then
			local visible_end_idx = self.visible_start_idx + (self.max_buttons - 1)
			if self.current_idx > visible_end_idx then
				-- move the list to show the highlight if it isn't visible
				local diff = self.current_idx - visible_end_idx
				self.visible_start_idx = self.visible_start_idx + diff
				new_y = list_y - (move_height * diff)
				
			elseif self.current_idx < self.visible_start_idx then
				-- move the list to show the highlight if it isn't visible
				local diff = self.visible_start_idx - self.current_idx
				self.visible_start_idx = self.current_idx
				new_y = list_y + (move_height * diff)
				
			elseif self.current_idx == 1 then 
				--if we wrapped then the list should be at zero
				self.visible_start_idx = 1
				new_y = 0
			else
				new_y = list_y
				scrolling = false
			end
			
		else
			if self.current_idx + extended_row > visual_center and self.current_idx + visual_center - 1 + extended_row <= self.num_buttons then
				--move the list
				new_y = list_y - move_height
			elseif self.current_idx == 1 then --if we wrapped then the list should be at zero
				new_y = 0
			else
				new_y = list_y
				scrolling = false
			end
		end
		
	elseif direction == -1 then	-- moving up the list
		if Game_platform == "PC" then
			local visible_end_idx = self.visible_start_idx + (self.max_buttons - 1)
			if self.current_idx < self.visible_start_idx then
				local diff = self.visible_start_idx - self.current_idx
				self.visible_start_idx = self.current_idx
				new_y = list_y + (move_height * diff)
				
			elseif self.current_idx > visible_end_idx then
				local diff = self.current_idx - visible_end_idx
				self.visible_start_idx = self.visible_start_idx + diff
				new_y = list_y - (move_height * diff)
			
			elseif self.current_idx == total_buttons then --if we wrapped then the list should be at the end
				if self.num_buttons > self.max_buttons - extended_row then
					self.visible_start_idx = self.num_buttons - (self.max_buttons - 1)
					new_y = move_height * (self.max_buttons - extended_row - self.num_buttons)
				--else
				--	new_y = 0
				end
			else
				new_y = list_y
				scrolling = false
			end
			
		else
			if self.current_idx >= floor(visual_center) and self.current_idx + visual_center <= self.num_buttons then
				--move the list
				new_y = list_y + move_height				
			elseif self.current_idx == total_buttons then -- we're at the end
				if self.num_buttons > self.max_buttons - extended_row then
					new_y = move_height * (self.max_buttons - extended_row - self.num_buttons)
				else
					new_y = 0
				end
			else
				new_y = list_y
				scrolling = false
			end
		end
		
	elseif direction == 0 then
		if Game_platform == "PC" then
			if not is_index_set and self.num_buttons > self.max_buttons then
				-- handles the case where we are entering the menu from another menu, but our current
				-- selection requires us to position the megalist so we can see it.
				local visible_end_idx = self.visible_start_idx + (self.max_buttons - 1)
				if self.current_idx < self.visible_start_idx then
					self.visible_start_idx = self.current_idx
				elseif self.current_idx > visible_end_idx then
					local diff = self.current_idx - visible_end_idx
					self.visible_start_idx = self.visible_start_idx + diff
				end
				
				new_y = -1 * move_height * (self.visible_start_idx - 1)
				new_y = limit(new_y, move_height * (self.max_buttons - self.num_buttons), 0)
				scrolling = false
			end
			
		else
			if self.current_idx > floor(visual_center) and self.num_buttons > self.max_buttons then
				-- handles the case where we are entering the menu from another menu, but our current
				-- selection requires us to position the megalist so we can see it.
				new_y = -1 * move_height * (self.current_idx - floor(visual_center))
				new_y = limit(new_y, move_height * (self.max_buttons - self.num_buttons), 0)
				scrolling = false
			end
		end
	else
		new_y = list_y
		scrolling = false
	end
	
	-- Adjust for font scale
	new_y = new_y 
	
	-- Always start a scroll animation, unless we were not told to move.  We do this to make the timing between cursor moves
	-- that cause a scroll and those that don't to be the same.
	if direction ~= 0 then
		--animate the list for now

		local toggle_group_anim = Vdo_anim_object:new("toggle_group_anim", self.handle, self.doc_handle)
		toggle_group_anim:set_target_handle(self.handle)
		local anchor_tween = Vdo_tween_object:new("toggle_group_anchor_tween", self.handle, self.doc_handle)
				
		anchor_tween:set_property("start_value", list_x, list_y )
		anchor_tween:set_property("end_value", list_x, new_y )
		anchor_tween:set_property("end_event", "vdo_mega_list_scroll_done")
		toggle_group_anim:play(0)
		
		Vdo_mega_list_tween_done = false		
	elseif not is_index_set then
		-- We are entering the menu from another menu... don't animate the position of the menu, just set it.
		vint_set_property(self.group_h, "anchor",  list_x, new_y)
	end

	local current_idx = self.current_idx
	if game_get_platform() ~= "PC" then
		-- Get current button
		self:draw_item_range(current_idx) 
	end
	
	local current_button = self.buttons[current_idx]
			
	-- does the button have levels
	if self.data[current_idx].max_level ~= nil then
		self.button_highlight:show_extended(true)
						
		-- set color BEFORE calling set level
		self.button_highlight:set_highlight_color(self.highlight_color)
		
		-- set level info
		self.button_highlight:set_level(self.data[current_idx].max_level, self.data[current_idx].level, self.data[current_idx].is_purchased, self.data[current_idx].show_next_level)		

		local shift_down = 0
		-- reposition buttons for new higlight
		for i = 1, self.num_buttons do
			local new_y = 0						
			local button_x, button_y = vint_get_property(self.toggle_base.handle, "anchor")

			if i == 1 then
				--TODO FIX THIS... Y Position is probably incorrect...
				--buttons are aligned to the middle, so offset the y to fthe first iem...
				new_y = LIST_BUTTON_HEIGHT * BUTTON_ANCHOR_OFFSET
			else
				--shifting down allows us to accomodate for additional spacing taken by the 
				--larger button...
				new_y = LIST_BUTTON_HEIGHT * (i + shift_down - BUTTON_ANCHOR_OFFSET)
			end

			self.buttons[i]:set_property("anchor", button_x, new_y)
			
			-- if we're highlighted shift the next buttons down
			if i == current_idx then
				shift_down = 1
			end
		end
	else
		self.button_highlight:show_extended(false)
	end
	
	if self.data[self.current_idx].disabled == true then
		current_button:set_highlight(false)
		current_button:set_property("alpha", 1.0)
		self.highlight_on = false
		self:highlight_show(false)
	else
		self.highlight_on = true
		-- Hide new flag
		if self.data[self.current_idx].is_new == true then
			
			-- hide new icon
			current_button:set_icon(BUTTON_TOGGLE_ICON_TYPE_NONE, BUTTON_TOGGLE_ICON_TYPE_NONE)
			
			-- change start and end values to make the tween not pulse when highlighted
			current_button.new_tween:set_start_value(1)
			current_button.new_tween:set_end_value(1)
		end
		
		-- Hide dlc flag
		if self.data[self.current_idx].is_dlc == true then
			-- hide dlc icon
			current_button:set_icon(BUTTON_TOGGLE_ICON_TYPE_NONE, BUTTON_TOGGLE_ICON_TYPE_NONE)
		end
		
		
		highlight:set_visible(true)
		
		-- Highlight current button
		current_button:set_highlight(true)
		current_button:set_property("depth", -10)
		current_button:set_property("alpha", 1.0)
		self.button_highlight:set_property( "depth",  -1)
		
		-- Highlight different button types...
		if current_button.slider then
			current_button.slider:set_highlight(true)
		elseif current_button.toggle then
			current_button.toggle:set_highlight(true)
		elseif current_button.row then
			current_button.row:set_highlight(true)
		elseif current_button.remap then
			current_button.remap:set_highlight_column(self.remap_column)
			current_button.remap:set_highlight(true)
			highlight:show_button("")
		end
	end	

	--get the current highlighted button x and y
	button_x, button_y = current_button:get_property("anchor")
	button_x = self.button_x -- always make sure x is our original position set in draw items...
	self.button_highlight:set_property( "anchor", button_x, button_y )

	self.button_highlight:set_width(self.width)
				
	if self.data[current_idx].type == TYPE_BUTTON or self.data[current_idx].type == nil then
		-- is the button locked?
		if self.data[current_idx].is_locked or self.data[current_idx].is_purchased or self.data[current_idx].show_button == false then
			highlight:show_button("")
		else
			highlight:show_button(CTRL_MENU_BUTTON_A)
		end
		
		--Marquee only supported in forced width modes...
		if self.force_width then
			--Find tweens...
			local marquee_anchor_twn_h = vint_object_find("marquee_anchor_twn", self.marquee_anim.handle, self.doc_handle)
			local marquee_end_twn_h = vint_object_find("marquee_end_twn", self.marquee_anim.handle, self.doc_handle)
			
			-- calculate text width + starting position for the button...
			local text_width = current_button:get_text_width() + button_x
			local new_x = button_x
			
			--Only marquee if we forced the width of the box and if the highlight is turned on...
			if text_width > self.width and self.highlight_on then
				local new_x = self.width - text_width + button_x - MEGA_LIST_BUTTON_PADDING

				--Retarget to current button
				vint_set_property(marquee_anchor_twn_h, "target_handle", current_button.handle)
				vint_set_property(marquee_end_twn_h, "target_handle",  current_button.handle)
				
				--Now set start and end values...
				vint_set_property(marquee_anchor_twn_h, "start_value", button_x, button_y)
				vint_set_property(marquee_anchor_twn_h, "end_value", new_x, button_y)
				
				local duration = abs(new_x - button_x)/60
				vint_set_property(marquee_anchor_twn_h, "duration", duration)
				vint_set_property(marquee_end_twn_h, "start_time", duration + .75)

				
				--play animation
				lua_play_anim(self.marquee_anim.handle)
				self.marquee_is_on = true
			else
				vint_set_property(self.marquee_anim.handle, "is_paused", true)
				self.marquee_is_on = false
			end
		end
		
		if self.input_tracker then
			self.input_tracker:highspeed_left_right(false)
		end
	elseif self.data[current_idx].type == TYPE_SLIDER then
		highlight:show_button("")
		
		if Game_platform == "PC" then
			self:update_toggle_mouse_inputs()
		end
		
		if self.input_tracker then
			self.input_tracker:highspeed_left_right(true)
		end	
	elseif self.data[current_idx].type == TYPE_TOGGLE then
		highlight:show_button("")
		
		
		if Game_platform == "PC" then
			self:update_toggle_mouse_inputs()
		end
		
		if self.input_tracker then
			self.input_tracker:highspeed_left_right(false)
		end
	elseif self.data[current_idx].type == TYPE_ROW then
		if self.data[current_idx].show_button == false then
			highlight:show_button("")
		else
			highlight:show_button(CTRL_MENU_BUTTON_A)
		end
		
		if self.input_tracker then
			self.input_tracker:highspeed_left_right(false)
		end
	end
	
	-- Clear out the old highlighted colors on buttons...
	for idx, button in pairs(self.buttons) do
		if idx ~= self.current_idx then
			button:set_highlight(false)
			button:set_property("depth", 0)
			button:set_property("alpha", 1)
			local button_x, button_y = button:get_anchor()
			
			--reset x position of button...
			button:set_anchor(self.button_x, button_y)
			
			--Unhighlight different button types...
			if button.slider then
				button.slider:set_highlight(false)
			elseif button.toggle then
				button.toggle:set_highlight(false)
			elseif button.row then
				button.row:set_highlight(false)
			elseif button.remap then
				button.remap:set_highlight(false)
			end

		
			-- reneable new tween
			if self.data[idx].is_new == true then
				
				-- set new icon back
				button:set_icon(BUTTON_TOGGLE_ICON_TYPE_NEW, BUTTON_TOGGLE_ICON_TYPE_NONE)
				
				-- change start and end values to make the tween pulse when highlighted
				button.new_tween:set_start_value(0.6)
				button.new_tween:set_end_value(1)
			end

			-- renedable dlc
			if self.data[idx].is_dlc == true then
				-- set new icon back
				button:set_icon(BUTTON_TOGGLE_ICON_TYPE_DLC, BUTTON_TOGGLE_ICON_TYPE_NONE)
			end
		end
	end
	
	
	
	--handle the scrollbar tab position
	if Game_platform == "PC" then
		self.scrollbar:set_value( self.num_buttons - (self.max_buttons - 1), self.visible_start_idx, scrolling == false )
	else
		self.scrollbar:set_value( total_buttons, current_idx, scrolling == false )
	end
	
	--check if we should play scrolling audio
	if direction ~= 0 or is_index_set then
		if self.num_buttons > 1 then
			game_UI_audio_play("UI_Reward_Store_Menu_Navigation")
		end
	end
end

function Vdo_mega_list:move_slider(direction, mouse_x, kill_audio)
	if not self.draw_called then
		debug_print("vint", "Vdo_pause_mega_list:move_slider called with invalid document handle\n")
		return
	end

	--get the button handle
	local current_idx = self.current_idx
	--check to see if we have a slider

	-- don't allow move if it's disabled
	if self.data[current_idx].disabled == true then
		return
	end
	
	if self.data[current_idx].type == TYPE_SLIDER then
		--Get the button handle
		local current_idx = self.current_idx
		local current_value = self.data[current_idx].current_value
		local current_max = self.data[current_idx].max
		local current_min = self.data[current_idx].min
		local current_step = self.data[current_idx].step
		local current_display = self.data[current_idx].display
		local current_mapping = self.data[current_idx].mapping
		local old_value = current_value

		if mouse_x ~= nil then
			if self.slider_hitboxes == nil then
				return
			end
			
			-- Get the hitbox of the slider that we care about
			local slider_hitbox
			for idx, hitbox in pairs(self.slider_hitboxes) do
				if hitbox.idx == current_idx then
					slider_hitbox = hitbox
				end
			end
			
			local slider_x, slider_y = vint_get_global_anchor(slider_hitbox.handle, self.doc_handle)
			local slider_width = element_get_actual_size(slider_hitbox.handle)
			
			-- Adjust the mouse position into the proper space.
			local screen_w, screen_h = vint_get_screen_size()
			if vint_is_std_res() then
				local doc_width = screen_h * 4 / 3
				local offset = (doc_width - screen_w) / 2
				mouse_x = ((mouse_x + offset) * (640*3) / doc_width)
				slider_width = slider_width * (0.666667)
			else 
				local doc_width = screen_h * 16 / 9
				local offset = (doc_width - screen_w) / 2
				mouse_x = ((mouse_x + offset) * (1280*3) / doc_width)
			end
			
			-- The actual area of the slider that we care about is smaller than the bounding box
			local SIDE_OFFSET = 15 * 3
			local min_x = slider_x + SIDE_OFFSET
			local max_x = slider_x + slider_width - SIDE_OFFSET
			
			current_value = ((mouse_x - min_x) / (max_x - min_x)) * (current_max - current_min) + current_min
			
			-- For sliders with a max of 1 (or less), these are mapped to 100 times their value internally, so rounding is trickier
			if current_min < 1 and current_max <= 1 then
				current_value = floor((current_value * 100) + 0.5) -- 0.5 is for better rounding
				current_value = current_value * 0.01
			else		
				-- Round it off
				current_value = floor(current_value + 0.5) -- 0.5 is for better rounding
			end
		else
			-- Increment the value
			current_value = current_value + ( current_step * direction )
		end
		
		-- Clamp the slider if necessary
		if current_value > current_max then
			current_value = current_max
		elseif current_value < current_min then
			current_value = current_min
		elseif kill_audio ~= true then
			if direction == 1 then
				game_UI_audio_play("UI_Main_Menu_Nav_Right")
			else
				game_UI_audio_play("UI_Main_Menu_Nav_Left")
			end
		end
		
		--Set the slider value
		self.buttons[current_idx].slider:set_value(current_value, current_min, current_max, nil, current_mapping )

		--Store the current value in the table
		self.data[current_idx].current_value = current_value
		
		-- Add back in when fixed in wise
		--game_UI_audio_play("UI_Customization_Slider")
		
		-- Return true if it changed
		local changed = (old_value ~= current_value)
		old_value = current_value
		return changed
	elseif self.data[current_idx].type == TYPE_TOGGLE then
		local toggle = self.buttons[current_idx].toggle
		local current_value = self.data[current_idx].current_value
		local options = self.data[current_idx].options
		
		local new_value = current_value + direction
		local num_options = #options
		
		if new_value > num_options then
			new_value = 1
		elseif new_value < 1 then
			new_value = num_options
		end
		
		if num_options > 1 then
			game_UI_audio_play("UI_Reward_Store_Menu_Navigation")
		end

		--Set label...
		local val_label = options[new_value]
		toggle:set_value(val_label)
		
		self.data[current_idx].current_value = new_value
	elseif self.data[current_idx].type == TYPE_REMAP then
		--Toggle between the two columns
		if self.remap_column == 1 then
			self.remap_column = 2
		else
			self.remap_column = 1
		end
		self.buttons[current_idx].remap:set_highlight_column(self.remap_column)
	end
end

function Vdo_mega_list:get_selection()
	if not self.draw_called then
		debug_print("vint", "Vdo_mega_list:get_selection called with invalid document handle\n")
		return
	end

	return self.current_idx
end

-------------------------------------------------------------------------------
-- Returns the value of a toggle...
--
function Vdo_mega_list:get_toggle_selection()
	if not self.draw_called then
		debug_print("vint", "Vdo_mega_list:get_toggle_selection called with invalid document handle\n")
		return
	end
	
	local selected_option = self.data[self.current_idx]
	if selected_option.type == TYPE_TOGGLE then
		return selected_option.current_value 
	end
	
	-- Spit back out the current highlight position
	return 0
end

-- Gets an optional ID value if one is saved
function Vdo_mega_list:get_id()
	if not self.draw_called then
		debug_print("vint", "Vdo_mega_list:get_toggle_selection called with invalid document handle\n")
		return
	end
	
	return self.data[self.current_idx].id
end

function Vdo_mega_list:get_data_from_id(id)
	for i, entry in pairs (self.data) do
		if entry.id == id then
			return entry
		end
	end
end

-------------------------------------------------------------------------------
-- Returns index from id
--
function Vdo_mega_list:get_index_from_id(id)
	if self.data == nil then
		return
	end
	for index, entry in pairs (self.data) do
		-- Skip the non-scalar field.
		if type(index) == "number" then
			if entry.id == id then
				return index
			end
		end
	end
	return -1
end

function Vdo_mega_list:button_a()
	if not self.draw_called then
		debug_print("vint", "Vdo_mega_list:button_a called with invalid document handle\n")
		return
	end
	
	local current_idx = self.current_idx
	if self.data[current_idx].type == TYPE_BUTTON or self.data[current_idx].type == nil then
		debug_print("vint", "BUTTON SELECTED GO TO A SCREEN OR SOMETHING\n")
	end

	if self.data[current_idx].type == TYPE_TOGGLE then
		local num_options = #(self.data[current_idx].options)
		if num_options <= 1 then
			debug_print("vint", "Vdo_mega_list:We have one or no options, no need to open toggle")
			return
		end
	end
	
	--check if we can process input
	if not Vdo_mega_list_tween_done then
		return
	end
	
	-- SEH - we don't want to handle A button with sliders
	if self.data[current_idx].type == TYPE_SLIDER or self.data[current_idx].type == TYPE_TOGGLE  then		
		return
	end
	
	local current_button = self.buttons[current_idx]
	
	if self.data[current_idx].type == TYPE_REMAP then
		-- Show popup message for remapping buttons
		-- Make current selection flash a "?"
		current_button.remap:wait_for_key(current_idx, self.remap_column)
		return
	end

	-- Unhighlight current button	
	self:highlight_show(false)
end

function Vdo_mega_list:button_b()
	if not self.draw_called then
		debug_print("vint", "Vdo_mega_list:button_b called with invalid document handle\n")
		return
	end
end


function Vdo_mega_list:return_data()
	if not self.draw_called then
		debug_print("vint", "Vdo_mega_list:return_data called with invalid document handle\n")
		return
	end
	
	return self.data
end

function Vdo_mega_list:return_selected_data()
	if not self.draw_called then
		debug_print("vint", "Vdo_mega_list:return_selected_data called with invalid document handle\n")
		return
	end
	
	return self.data[self.current_idx]
end

function Vdo_mega_list:enable(state)
	if not self.draw_called then
		debug_print("vint", "Vdo_mega_list:enable called with invalid document handle\n")
		return
	end
	
	local current_idx = self.current_idx
	
	for idx, button in pairs(self.buttons) do
		button:set_enabled(state)
	end
	
	local current_button = self.buttons[current_idx]
	
	-- Highlight/unhighlight current button
	current_button:set_highlight(state)
	current_button:set_enabled(state)		
end

function Vdo_mega_list:toggle_highlight(is_on)
	if not self.draw_called then
		debug_print("vint", "Vdo_mega_list:toggle_highlight called with invalid document handle\n")
		return
	end

	self.button_highlight:set_property("visible", is_on)
	
	if is_on == false then
		if self.marquee_anim == nil then
			self.marquee_anim = Vdo_anim_object:new("marquee_anim", self.handle, self.doc_handle)
		end
		--pause marquee if there is no highlight...
		vint_set_property(self.marquee_anim.handle, "is_paused", true)
		
		--reset button position and alpha.
		local current_button = self.buttons[self.current_idx]
		local button_x, button_y = current_button:get_anchor()
		current_button:set_anchor(self.button_x, button_y)
		current_button:set_alpha(1)
	else 
		--only turn the marquee on if we had one playing before...
		if self.marquee_is_on then
			lua_play_anim(self.marquee_anim.handle)
		end
	end
	
	local current_idx = self.current_idx
	
	for idx, button in pairs(self.buttons) do
		button:set_highlight(false)
	end
	
	self.buttons[current_idx]:set_highlight(is_on)
	self.highlight_on = is_on
end

function Vdo_mega_list:set_highlight_color(color, non_highlight_color)
	
	self.button_highlight:set_highlight_color(color)
	self.scrollbar:set_highlight_color(color)
	
	self.highlight_color = color
	self.non_highlight_color = non_highlight_color
end

--Shows the current highlight,
--used to toggle the options on or off...
function Vdo_mega_list:highlight_show(visible)
	local current_idx = self.current_idx
	local current_button = self.buttons[current_idx]
	current_button:set_highlight(visible)
	self.button_highlight:set_visible(visible)
	
	-- Highlight different button types...
	if current_button.slider then
		current_button.slider:set_highlight(visible)
	elseif current_button.toggle then
		current_button.toggle:set_highlight(visible)
	elseif current_button.remap then
		current_button.remap:set_highlight_column(self.remap_column)
		current_button.remap:set_highlight(visible)
		highlight:show_button("")
	end	
end

function Vdo_mega_list:highlight_set_button(button_img, override_show)
	self.button_highlight:show_button(button_img, override_show)
end

function Vdo_mega_list:refresh_values(data)
	if not self.draw_called then
		debug_print("vint", "Vdo_mega_list:refresh_values called with invalid document handle\n")
		return
	end
	
	for idx = 1,#data do
		--store the button toggle options
		if data[idx].type == TYPE_BUTTON or data[idx].type == nil then
			-- Set the button toggle value
			self.buttons[idx]:set_value("")
		elseif data[idx].type == TYPE_TOGGLE then
			--Store the value
			local option_idx = data[idx].current_value
			-- Set the button toggle value
			self.buttons[idx]:set_value(data[idx].options[option_idx])
		elseif data[idx].type == TYPE_SLIDER then
			-- Set the button toggle value
			--self.buttons[idx]:set_value(data[idx].current_value)
			self.buttons[idx]:set_value("")
		end
	end
end

function Vdo_mega_list:is_tween_done()
	return Vdo_mega_list_tween_done
end

function Vdo_mega_list:return_size()

	--TODO: THIS IS COMPLETELY INCORRECT... it will return the size of the entire list unculled...
	local total_height = #data * (LIST_BUTTON_HEIGHT  +MEGA_LIST_BUTTON_SPACING)
	return self.width, total_height
end

--Returns width and height of megalist... corner to corner. includes scrollbar...
--TODO: update this... to return proper width...
function Vdo_mega_list:get_size()
	if self.width == 0 then
		return
	end
	
	--Scrollbar is always part of the width
	local width = self.width + SCROLLBAR_WIDTH + MEGALIST_SCROLLBAR_PADDING
	
	--Height
	local height = self.max_buttons * (LIST_BUTTON_HEIGHT + MEGA_LIST_BUTTON_SPACING )
	return width, height
end

function Vdo_mega_list:set_selection(new_index)
	if self.data[self.current_idx].disabled == true then
		return
	end
	
	self.current_idx = new_index
end

-- loops the marquee animation via callback
function Vdo_mega_list:marquee_loop_cb()
	lua_play_anim(self.marquee_anim.handle)
end

function Vdo_mega_list:remove_new_flag(idx)
	if not self.draw_called then
		return
	end
	if self.data == nil then
		return
	end
	if self.data[idx] == nil then
		return
	end
	--remove new flag
	if self.data[idx].is_new then
		self.data[idx].is_new = false
		self:cleanup_single_item(self.buttons[idx])
		self.buttons[idx] = self:draw_single_item(idx, false)
	end
end

function Vdo_mega_list:refresh_single_item(idx)
	if not self.draw_called then
		return
	end
	if self.data == nil then
		return
	end
	if self.data[idx] == nil then
		return
	end
	
	--updates a specific item...
	self:cleanup_single_item(self.buttons[idx])
	self.buttons[idx] = self:draw_single_item(idx, false)
	self:move_cursor(0)
end


-- =====================================
--       Mouse Specific Functions
-- =====================================

function Vdo_mega_list:get_visible_indices()
	local visible_end_idx
	if self.num_buttons > self.max_buttons then
		visible_end_idx = self.visible_start_idx + (self.max_buttons - 1)
	else
		visible_end_idx = self.num_buttons
	end
	
	return self.visible_start_idx, visible_end_idx
end

-- Returns the button's index on the list based on the target handle.
-- Returns 0 (invalid index) if no button was found
--
function Vdo_mega_list:get_button_index(target_handle)
	if self.buttons == nil then
		return 0
	end
	
	for idx, button in pairs(self.buttons) do
		if self.data[idx].disabled ~= true and button.wide_handle ~= nil then
			if button.wide_handle == target_handle then
				return idx
			end
		end
	end

	-- Check the slider hitboxes
	if self.slider_hitboxes == nil then
		return 0
	end
	
	for idx, slider_hitbox in pairs(self.slider_hitboxes) do
		if slider_hitbox.handle == target_handle then
			return slider_hitbox.idx
		end
	end

	-- If no matching target handle was found, return an invalid index
	return 0
end

function Vdo_mega_list:get_remap_index(target_handle)
	local column = 0
	for i = 1, self.num_buttons do
		if self.buttons[i].remap ~= nil then
			column = self.buttons[i].remap:get_target_column(target_handle)
			if column > 0 then
				self.remap_column = column
				return i, self.buttons[i].remap, column
			end
		end
	end
	
	return 0, nil, 0
end

function Vdo_mega_list:get_scroll_region_handle()
	return self.clip_h
end

-- This is needed for the store UI screens, since each store should handle the
-- mouse_move events itself, not through the store_common script
--
function Vdo_mega_list:set_store(store_name)
	if store_name ~= nil then
		self.store_name = store_name
	end
end

-- callback_nav and callback_action are optional overrides (func_prefix is ignored if they are used)
function Vdo_mega_list:add_mouse_inputs(func_prefix, input_tracker, priority, callback_nav, callback_action, mouse_depth, right_click_enabled)
	if (self.buttons == nil) or (func_prefix == nil) or (input_tracker == nil) then
		return
	end
	
	mouse_depth = mouse_depth or 5000
	
	-- Default priority value to 50
	self.priority = priority or 50
	
	if self.store_name == nil then
		self.mouse_move_function			= callback_nav or func_prefix.."_mouse_move"
	else
		self.mouse_move_function			= self.store_name.."_mouse_move"
	end
	self.mouse_click_function				= callback_action or func_prefix.."_mouse_click"
	self.mouse_right_click_function		= callback_action or func_prefix.."_mouse_right_click"
	local mouse_drag_function				= func_prefix.."_mouse_drag"
	local mouse_drag_release_function	= func_prefix.."_mouse_drag_release"
	
	local visible_end_idx = self.num_buttons
	if self.num_buttons > self.max_buttons then
		visible_end_idx = self.visible_start_idx + (self.max_buttons - 1)
	end
	
	-- Clear out the old slider hitboxes
	if self.slider_hitboxes ~= nil then
		for idx, slider_hitbox in pairs(self.slider_hitboxes) do
			vint_object_destroy(slider_hitbox.handle)
		end
	end
	self.slider_hitboxes = {}
	
	-- Clear out old wide hitboxes
	if self.wide_hitboxes ~= nil then
		for idx, wide_hitbox in pairs(self.wide_hitboxes) do
			vint_object_destroy(wide_hitbox.handle)
		end
	end
	self.wide_hitboxes = {}
	
	
	-- Add mouse_click and mouse_move events for each button in the list
	for idx = self.visible_start_idx, visible_end_idx do
		-- Create a hitbox based on the button
		local move_height = LIST_BUTTON_HEIGHT + MEGA_LIST_BUTTON_SPACING	
		local list_y = -1 * move_height * (self.visible_start_idx - 1)
		local button_x, button_y = vint_get_property(self.buttons[idx].handle, "anchor")
		
		if self.buttons[idx].handle ~= 0 then
			local wide_index = #self.wide_hitboxes + 1
			local wide_name = "wide_hitbox"..wide_index
			local wide_handle = vint_object_create(wide_name, "bitmap", self.handle)
			
			self.wide_hitboxes[wide_index] = {}
			self.wide_hitboxes[wide_index].handle = wide_handle
			self.wide_hitboxes[wide_index].idx = idx
			vint_set_property(wide_handle, "auto_offset", "w")
			vint_set_property(wide_handle, "visible", false)
			vint_set_property(wide_handle, "depth", 100)
			
			element_set_actual_size(wide_handle, self.width, LIST_BUTTON_HEIGHT - (2 * 3))
			
			vint_set_property(wide_handle, "anchor", button_x + WIDE_HITBOX_OFFSET, button_y + list_y)
			vint_set_property(wide_handle, "mouse_depth", mouse_depth)
			self.buttons[idx].wide_handle = wide_handle
		
			-- Everything highlights based on the wide hitbox, while each type has different click functionality (or not)
			input_tracker:add_mouse_input("mouse_move", self.mouse_move_function, self.priority, wide_handle)
			
			if self.data[idx].type == TYPE_BUTTON or self.data[idx].type == TYPE_ROW or self.data[idx].type == TYPE_TOGGLE_COLOR or self.data[idx].type == nil then
				input_tracker:add_mouse_input("mouse_click", self.mouse_click_function, self.priority, wide_handle)
				if right_click_enabled then
					input_tracker:add_mouse_input("mouse_right_click", self.mouse_right_click_function, self.priority, wide_handle)
				end
				
			elseif self.data[idx].type == TYPE_TOGGLE then
				-- Add hitbox for the whole button, plus the left arrow
				input_tracker:add_mouse_input("mouse_click", self.mouse_click_function, self.priority, wide_handle)
				
			elseif self.data[idx].type == TYPE_SLIDER then	
				-- If the button is a slider, then create a hitbox for the slider from scratch
				local move_height = LIST_BUTTON_HEIGHT + MEGA_LIST_BUTTON_SPACING	
				local list_y = -1 * move_height * (self.visible_start_idx - 1)
				local slider_bg_handle = vint_object_find("slider_bg", self.buttons[idx].slider.handle)
				local slider_bg_w, slider_bg_h = element_get_actual_size(slider_bg_handle) --vint_get_property(slider_bg_handle, "screen_size")
				local slider_bg_x, slider_bg_y = vint_get_property(slider_bg_handle, "anchor")
				local slider_x, slider_y = vint_get_property(self.buttons[idx].slider.handle, "anchor")
				
				local hitbox_index = #self.slider_hitboxes + 1
				local hitbox_name = "slider_hitbox"..hitbox_index
				local hitbox_handle = vint_object_create(hitbox_name, "bitmap", self.handle)
				
				self.slider_hitboxes[hitbox_index] = {}
				self.slider_hitboxes[hitbox_index].handle = hitbox_handle
				self.slider_hitboxes[hitbox_index].idx = idx
				vint_set_property(hitbox_handle, "visible", false)
				vint_set_property(hitbox_handle, "depth", -20)
				element_set_actual_size(hitbox_handle, slider_bg_w, slider_bg_h - (7 * 3))
			
				vint_set_property(hitbox_handle, "anchor", slider_x + slider_bg_x, slider_y - (12 * 3) + list_y)
				
				-- Finally add in the mouse input tracking for the sliders
				input_tracker:add_mouse_input("mouse_click", self.mouse_click_function, self.priority, hitbox_handle)
				input_tracker:add_mouse_input("mouse_move", self.mouse_move_function, self.priority, hitbox_handle)
				input_tracker:add_mouse_input("mouse_drag", mouse_drag_function, self.priority, hitbox_handle)
				input_tracker:add_mouse_input("mouse_drag_release", mouse_drag_release_function, self.priority, hitbox_handle)
				vint_set_property(hitbox_handle, "mouse_depth", mouse_depth)
				
			elseif self.data[idx].type == TYPE_REMAP then
				-- Two addition mouse moves/clicks for remapping buttons
				input_tracker:add_mouse_input("mouse_move", self.mouse_move_function, self.priority, self.buttons[idx].remap.value_bg[1].handle)
				input_tracker:add_mouse_input("mouse_move", self.mouse_move_function, self.priority, self.buttons[idx].remap.value_bg[2].handle)
				input_tracker:add_mouse_input("mouse_click", self.mouse_click_function, self.priority, self.buttons[idx].remap.value_bg[1].handle)
				input_tracker:add_mouse_input("mouse_click", self.mouse_click_function, self.priority, self.buttons[idx].remap.value_bg[2].handle)
				vint_set_property(self.buttons[idx].remap.value_bg[1].handle, "mouse_depth", mouse_depth)
				vint_set_property(self.buttons[idx].remap.value_bg[2].handle, "mouse_depth", mouse_depth)
			end
		end
	end
	
	self:update_toggle_mouse_inputs()
	
	-- Add mouse inputs for the scroll region and scrolltab if needed
	if self.num_buttons > self.max_buttons then
		input_tracker:add_mouse_input("mouse_scroll", func_prefix.."_mouse_scroll", self.priority, self.clip_h)
		self.scrollbar:add_mouse_inputs(func_prefix, input_tracker, self.priority)
	end
end

-- Rebuilds the mouse input subscriptions, usually done when the list was rebuilt with draw_items()
--
function Vdo_mega_list:update_mouse_inputs(func_prefix, input_tracker, priority)
	-- If the list doesn't scroll, there's no need to update the mouse inputs
	if self.num_buttons <= self.max_buttons then
		return
	end
	
	input_tracker:remove_all()
	self:add_mouse_inputs(func_prefix, input_tracker, priority)
	input_tracker:subscribe(true)
end

function Vdo_mega_list:enable_toggle_input(enable)
	if Game_platform ~= "PC" or Toggle_mouse_input_tracker == nil then
		return
	end
	
	Toggle_mouse_input_tracker:subscribe(enable)
end

-- INTERNAL FUNCTION
-- Updates the mouse input tracking for the toggle/slider arrows, since they only capture input for the currently selected button
--
function Vdo_mega_list:update_toggle_mouse_inputs()
	if Game_platform ~= "PC" or Toggle_mouse_input_tracker == nil then
		return
	end

	Toggle_mouse_input_tracker:remove_all()

	if self.mouse_click_function == nil or self.mouse_move_function == nil or self.priority == nil then
		return
	end
	
	local start_idx, end_idx = self:get_visible_indices()
	if self.current_idx >= start_idx and self.current_idx <= end_idx then
		if self.data[self.current_idx].type == TYPE_SLIDER then
			local arrow_left_handle = vint_object_find("arrow_left", self.buttons[self.current_idx].slider.handle)
			local arrow_right_handle = vint_object_find("arrow_right", self.buttons[self.current_idx].slider.handle)
			vint_set_property(arrow_left_handle, "depth", -201)
			vint_set_property(arrow_right_handle, "depth", -201)
			
			Toggle_mouse_input_tracker:add_mouse_input("mouse_click", self.mouse_click_function, self.priority, arrow_left_handle)
			Toggle_mouse_input_tracker:add_mouse_input("mouse_move", self.mouse_move_function, self.priority, arrow_left_handle)
			Toggle_mouse_input_tracker:add_mouse_input("mouse_click", self.mouse_click_function, self.priority, arrow_right_handle)
			Toggle_mouse_input_tracker:add_mouse_input("mouse_move", self.mouse_move_function, self.priority, arrow_right_handle)
		elseif self.data[self.current_idx].type == TYPE_TOGGLE then
			local arrow_left_handle = vint_object_find("arrow_left", self.buttons[self.current_idx].toggle.handle)
			vint_set_property(arrow_left_handle, "depth", -201)
			
			Toggle_mouse_input_tracker:add_mouse_input("mouse_click", self.mouse_click_function, self.priority, arrow_left_handle)
			Toggle_mouse_input_tracker:add_mouse_input("mouse_move", self.mouse_move_function, self.priority, arrow_left_handle)
		end
	end
	
	Toggle_mouse_input_tracker:subscribe(true)
end

function Vdo_mega_list:is_left_arrow(target_handle)
	if self.buttons[self.current_idx].slider ~= nil then
		return ( target_handle == vint_object_find("arrow_left", self.buttons[self.current_idx].slider.handle) )
	elseif self.data[self.current_idx].type == TYPE_TOGGLE then
		return ( target_handle == vint_object_find("arrow_left", self.buttons[self.current_idx].toggle.handle) )
	else
		return false
	end
end

function Vdo_mega_list:is_right_arrow(target_handle)
	if self.buttons[self.current_idx].slider == nil then
		return false
	end
	
	return ( target_handle == vint_object_find("arrow_right", self.buttons[self.current_idx].slider.handle) )
end

function Vdo_mega_list:highlight_left_arrow(highlight)
	if self.buttons[self.current_idx].slider == nil then
		return false
	end
	
	if highlight then
		vint_set_property(vint_object_find("arrow_left", self.buttons[self.current_idx].slider.handle), "tint", 255,255,255 )
	else
		vint_set_property(vint_object_find("arrow_left", self.buttons[self.current_idx].slider.handle), "tint", 0,0,0 )
	end
end

function Vdo_mega_list:highlight_right_arrow(highlight)
	if self.buttons[self.current_idx].slider == nil then
		return false
	end
	
	if highlight then
		vint_set_property(vint_object_find("arrow_right", self.buttons[self.current_idx].slider.handle), "tint", 255,255,255 )
	else
		vint_set_property(vint_object_find("arrow_right", self.buttons[self.current_idx].slider.handle), "tint", 0,0,0 )
	end
end

function Vdo_mega_list:is_slider(target_handle)
	if self.buttons[self.current_idx].slider == nil or self.slider_hitboxes == nil then
		return false
	end
	
	for idx, slider_hitbox in pairs(self.slider_hitboxes) do
		if slider_hitbox.handle == target_handle then
			return true
		end
	end
	
	-- No matching slider hitbox was found
	return false
end

function Vdo_mega_list:scroll_list(scroll_lines, new_start_index)
	local new_y = 0

	local move_height = LIST_BUTTON_HEIGHT + MEGA_LIST_BUTTON_SPACING
	local list_x, list_y =  vint_get_property(self.group_h, "anchor")

	-- Set the start index based on mouse wheel's scroll lines or the new start index calculated
	-- by the scroll tab's position
	if new_start_index ~= nil then
		self.visible_start_idx = new_start_index
		
	else
		self.visible_start_idx = self.visible_start_idx + scroll_lines
		local visible_end_idx = self.visible_start_idx + (self.max_buttons - 1)
		if self.visible_start_idx < 1 then
			self.visible_start_idx = 1
		elseif visible_end_idx > self.num_buttons then
			self.visible_start_idx = self.num_buttons - (self.max_buttons - 1)
		end
	end
	local visible_end_idx = self.visible_start_idx + (self.max_buttons - 1)
	
	-- Calculate the list's new position based on the starting visible index
	new_y = -1 * move_height * (self.visible_start_idx - 1)
	new_y = limit(new_y, move_height * (self.max_buttons - self.num_buttons), 0)

	-- if scrolling with the mouse wheel, animate the list and the scrolltab
	if scroll_lines ~= 0 then
		-- Start a scroll animation, unless we were not told to move.  We do this to make the timing between cursor moves
		-- that cause a scroll and those that don't to be the same.

		local toggle_group_anim = Vdo_anim_object:new("toggle_group_anim", self.handle, self.doc_handle)
		toggle_group_anim:set_target_handle(self.handle)
		local anchor_tween = Vdo_tween_object:new("toggle_group_anchor_tween", self.handle, self.doc_handle)
				
		anchor_tween:set_property("start_value", list_x, list_y )
		anchor_tween:set_property("end_value", list_x, new_y )
		anchor_tween:set_property("end_event", "vdo_mega_list_scroll_done")
		toggle_group_anim:play(0)
		
		Vdo_mega_list_tween_done = false
		
		self.scrollbar:set_value( self.num_buttons - (self.max_buttons - 1), self.visible_start_idx, false )
	else
		-- only set the position of the list based on the new starting index
		vint_set_property(self.group_h, "anchor", list_x, new_y)
	end
end

function Vdo_mega_list:set_list_alignment()
	--TODO add support
end

function Vdo_mega_list:set_width()
	--TODO add support
end

-------------------------------------------------------------------------------
-- Returns the column positions from the first row in the list...
-------------------------------------------------------------------------------
function Vdo_mega_list:row_get_column_positions()
	for i = 1, self.num_buttons do
		local row = self.buttons[i].row
		if row then
			local col_1_x, col_2_x, col_3_x, col_4_x = row:get_column_positions()
			col_1_x = col_1_x + self.button_x
			col_2_x = col_2_x + self.button_x
			col_3_x = col_3_x + self.button_x
			col_4_x = col_4_x + self.button_x
			return col_1_x, col_2_x, col_3_x, col_4_x
		end
	end
end

function Vdo_mega_list:set_input_tracker(input_tracker)
	self.input_tracker = input_tracker
end

function Vdo_mega_list:set_mouse_highlight(new_index)
	
	-- Clear out the old highlighted colors on buttons...
	for idx, button in pairs(self.buttons) do
		if idx ~= new_index then
			button:set_alpha(1.0)
			--Unhighlight different button types...
			if button.slider then
				button.slider:set_mouse_highlight(false)
			elseif button.toggle then
				button.toggle:set_mouse_highlight(false)
			elseif button.row then
				--button.row:set_mouse_highlight(false)
				button.row:set_color(COLOR_CELL_MENU_HIGHLIGHT_TEXT)
			end
		end
	end

	--if we have a valid index then set the highlight
	if new_index > 0 then
		local current_button = self.buttons[new_index]
		-- Highlight different button types...
		if current_button.slider then
			current_button.slider:set_mouse_highlight(true)
		elseif current_button.toggle then
			current_button.toggle:set_mouse_highlight(true)
		elseif current_button.row then
			--current_button.row:set_mouse_highlight(true)
			current_button.row:set_color(COLOR_SAINTS_PURPLE)
		end
	end
end
