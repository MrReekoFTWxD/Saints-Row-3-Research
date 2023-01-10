local PAUSE_LIST_BUTTON_HEIGHT	 	= 100
local PAUSE_LIST_HIGHLIGHT_HEIGHT 	= 30
Vdo_pause_mega_list_tween_done = true

local PAUSE_MEGA_LIST_ALIGN_LEFT = 0
local PAUSE_MEGA_LIST_ALIGN_CENTER = 1

local PAUSE_MEGA_LIST_DEFAULT_WIDTH = 700 * 3

function vdo_pause_mega_list_init()
	local anim_h = vint_object_find("mega_list_in_anim")
	vint_set_property(anim_h, "is_paused", true)
end

function vdo_pause_mega_list_cleanup()
end

function Vdo_pause_mega_list_scroll_done(tween_h, event_name)
	-- remove this callback
	remove_tween_end_callback( vint_object_find("toggle_group_anchor_tween") )
	Vdo_pause_mega_list_tween_done = true
end

-- Inherited from Vdo_base_object
Vdo_pause_mega_list = Vdo_base_object:new_base()


--------------------------------------------------------------------------------
-- Initializes Mega List7
--------------------------------------------------------------------------------
function Vdo_pause_mega_list:init()

	self.anim_in_func_cb  			= -1			--Animation callback func...
	self.anim_out_func_cb  			= -1			--Animation callback func...
	self.drawn_at_least_once		= false		--Determines if we've drawn at least once. The menu MUST animate everytime you see it at first.
	
	-- Hide the initial button
	vint_set_property(vint_object_find("base", self.handle), "visible", false)

	self.button_copy = Vdo_pause_button_toggle:new("base", self.handle)
	self.button_copy_x, self.button_copy_y = self.button_copy:get_property("anchor")

	self.highlight = Vdo_pause_button_highlight:new("highlight", self.handle)
	
	--Animation that slide that scales all the objects in.
	local mega_list_anim_in = Vdo_anim_object:new("mega_list_in_anim", self.handle)
	mega_list_anim_in:stop()
	
	Vdo_pause_mega_list_tween_done = true
end


--------------------------------------------------------------------------------
-- Deletes the internal data and destroys the button clones
--------------------------------------------------------------------------------
function Vdo_pause_mega_list:cleanup()
	if self.draw_called then
		for i, button in pairs(self.buttons) do
			button:object_destroy()
		end
		self.draw_called = false
	end
end

function Vdo_pause_mega_list:set_list_alignment(alignment)
	if alignment == "center" then
		alignment = PAUSE_MEGA_LIST_ALIGN_CENTER
	elseif alignment == "left" then
		alignment = PAUSE_MEGA_LIST_ALIGN_LEFT 
	else
		alignment = PAUSE_MEGA_LIST_ALIGN_LEFT 
	end
	self.alignment = alignment 
end

function Vdo_pause_mega_list:set_width(width)
	self.width = width
end

--------------------------------------------------------------------------------
-- Draws the megalist for the first time. Usually called immediatly after the 
-- initialization of the object.
--	
-- @param data					Data 
-- @param current_options	Which option is set to highlight in the list
-- @param width				Size in pixels the width of the list
-- @param max_buttons		How many buttosn can appear in the list
-- @param alignment			aligns text to left or center... ("left", "center")
-- @param refresh				set to true if you do not want to animate
--------------------------------------------------------------------------------
function Vdo_pause_mega_list:draw_items(data, current_option, width, max_buttons, alignment, refresh)

	--Defaults
	max_buttons = max_buttons or 999

	-- Error Check
	for idx, val in pairs(data) do
		if type(val) ~= "table" then
			debug_print("vint", "Vdo_pause_mega_list:draw_items was called with impropperly formatted parameters!\n")
			return
		end
	end
	
	-- Nuke the shit out of whatever was previously here
	self:cleanup()

	-- Set up handle for base button
	local button_copy = self.button_copy
	if button_copy.handle == 0 then
		debug_print("vint", "Unable to find object \"base\"")
		return
	end
	
	--TODO: Put these at the top of the file...
	-- Set up tables to manage handles and data for this object
	self.draw_called = true
	self.buttons = {}
	self.data = data
	self.open = false
	self.old_slider_value = nil
	self.max_buttons = 0
	
	-- Set initial cursor position
	if current_option == nil then
		current_option = 1
	end
	
	
	
	if width ~= nil then
		self.width = width + (10 * 3)
	elseif self.width == nil or self.width == 0 then
		self.width = PAUSE_MEGA_LIST_DEFAULT_WIDTH
	end
	self.slider_anchor_y = 0
	self.toggle_anchor_y = 0
	
	-- Reassign our objects
	self.group 			= Vdo_base_object:new("megalist_group", self.handle)	
	
	self.anims = {}
	self.anims.mega_list_in = Vdo_anim_object:new("mega_list_in_anim", self.handle)
	
	--Set alignment...
	if self.alignment == nil and alignment == nil then
		self.alignment = PAUSE_MEGA_LIST_ALIGN_LEFT
	elseif alignment ~= nil then
		self:set_list_alignment(alignment)
	end

	-- Save the number of buttons
	self.num_buttons = #data
	
	for i = 1, self.num_buttons do
		-- Assign the button copy to the table that manages data for this object
		self.buttons[i] = Vdo_pause_button_toggle:clone(button_copy.handle)
		local button = self.buttons[i]
		
		local val = data[i]
		
		--Set shadows if we have it...
		if self.button_shadows ~= nil then
			button:set_shadow(self.button_shadows)
		end
		
		-- Set the button toggle text
		button:set_label(val.label)
	
		local button_width = button:get_text_width()
		
		-- Move the button copy into the correct position
		local new_y = self.button_copy_y + (PAUSE_LIST_BUTTON_HEIGHT  * (i - 1))
		
		local x
		if self.alignment == PAUSE_MEGA_LIST_ALIGN_CENTER then
			--Center alignment...
			x = self.button_copy_x - button_width/2 - 44
		else
			--Default left alignment...
			x = self.button_copy_x
		end
		button:set_property("anchor", x, new_y)
		
		-- Make the button visible
		button:set_property("visible", true)
		
		--Set color if we have it...
		if self.button_unselected_color ~= nil and self.button_unselected_color ~= nil then
			button:set_color(self.button_selected_color, self.button_unselected_color)
		end
				                  	
		--Used for fading out the object...
		local extra_obj_handle = -1
		local x = 0
		local y = 0
		
		--store the button toggle options
		if val.type == TYPE_BUTTON then
			-- Set the button toggle value
			button:set_value("")
			if val.disabled == true then
				button:set_alpha(.5)
			end
		end
		
		if current_option == i then
			button:set_highlight(true)
		else
			button:set_highlight(false)
		end
		
	end
	
	--find largest button and then we will figure out the positions for everything...
	local largest_button_width = 0
	local current_button_width, current_button_height
	for i = 1, self.num_buttons do
		local button = self.buttons[i]
		local button_x, button_y = button:get_anchor()
		current_button_width = button_x + button:get_text_width() + (30 * 3)
		if current_button_width > largest_button_width then
			largest_button_width = current_button_width
		end
	end

	--Tween the animations...
	local anchor_tween = Vdo_tween_object:new("mg_anchor_twn", self.handle)			
	for i = 1, self.num_buttons do
		local button = self.buttons[i]
		
		-- clone tween and retarget animation
		local time_offset = i * (3/30)
		local anchor_tween_clone = Vdo_tween_object:clone(anchor_tween.handle)
		anchor_tween_clone:set_property("target_handle", button.handle)
	
		if self.alignment == PAUSE_MEGA_LIST_ALIGN_CENTER then
			--overload anchor tween clone with basic fade values..
			anchor_tween_clone:set_property("start_time", time_offset)
			anchor_tween_clone:set_property("target_property", "alpha")
			anchor_tween_clone:set_property("start_value", 0)
			anchor_tween_clone:set_property("end_value", 1)
		else
			--Calculate positions...
			local start_x, start_y = anchor_tween_clone:get_property("start_value")
			local end_x, end_y = anchor_tween_clone:get_property("end_value")
			local temp_x, temp_y = button:get_anchor()
			end_x = temp_x
			end_y = temp_y 
			anchor_tween_clone:set_property("start_time", time_offset)
			anchor_tween_clone:set_property("start_value", start_x, end_y)
			anchor_tween_clone:set_property("end_value",  end_x, end_y)
		end
		
		--Final tween... so we can do some special stuff based on this...
		if i == self.num_buttons then
			--Set callback if we have one...
			if self.anim_in_func_cb ~= -1 then
				anchor_tween_clone:set_end_event(self.anim_in_func_cb)
			end
		end
	end
	
	--Animate list
	if refresh == false or self.drawn_at_least_once == false then
		self.anims.mega_list_in:play(0)
		self.drawn_at_least_once = true
	else
		self.anims.mega_list_in:play(-20)
	end
	
	if current_option > self.num_buttons then
		current_option = self.num_buttons
	end
	--set the cuurent button to the passed in variable for the current option
	self.current_idx = current_option
			
	--set the size of the list
	--self:set_size(width, max_buttons)
	
	--reset the y of the list group
	local list_x, list_y =  self.group:get_property("anchor")
	self.group:set_property("anchor",list_x,0)

	-- Draw the cursor
	self:move_cursor(0)
end

--------------------------------------------------------------------------------
-- Sets the size of the mega list
-- @param width			Size in pixels the width of the list
-- @param max_buttons	How many buttosn can appear in the list
--------------------------------------------------------------------------------
function Vdo_pause_mega_list:set_size(width, max_buttons)
	if not self.draw_called then
		debug_print("vint", "Vdo_pause_mega_list:set_size called with invalid document handle\n")
		return
	end
end



function Vdo_pause_mega_list:move_cursor(direction, is_index_set)
	if not self.draw_called then
		debug_print("vint", "Vdo_pause_mega_list:move_cursor called with invalid document handle\n")
		return
	end
	
	is_index_set = is_index_set or false
	
	-- Play sound for cursor movement...
	if direction ~= 0 then
		if direction == 1 then
			game_UI_audio_play("Ui_main_menu_nav_up")
		else
			game_UI_audio_play("Ui_main_menu_nav_down")
		end
	elseif is_index_set then
		game_UI_audio_play("Ui_main_menu_nav_up")
	end
	
	local highlight = self.highlight
	--check to see if the toggle is open
	if not self.open then
		--check if we can process input
		if Vdo_pause_mega_list_tween_done then
			-- Clear out old highlight
			for idx, button in pairs(self.buttons) do
				button:set_highlight(false)
			end

			--toggle is closed so navigate the list normally
			--Increment the direction
			self.current_idx = wrap_index(self.current_idx, direction, self.num_buttons)
			
			local total_buttons = #self.data
			local total_height = ( total_buttons * PAUSE_LIST_BUTTON_HEIGHT  ) + ( PAUSE_LIST_HIGHLIGHT_HEIGHT )

			local new_y = total_height + 0
			local list_x, list_y =  self.group:get_property("anchor")
			local scrolling = false
			local visual_center = ( self.max_buttons * 0.5 )
			--get the value for the visual bottom
			local visual_center_bottom = total_buttons - visual_center
			--do we need to scroll?
			if (-1 * total_height) <= 0 then
				scrolling = true
				--move the list
				local end_y = 5 * 3
				if direction == -1 then
					--is the current button half way from the visible top
					if self.current_idx > visual_center then
						--the current button is greater than or equal to the visual middle
						--is the current button half way from the visible bottom
						if self.current_idx < visual_center_bottom then
							--the current button is less than or equal to the visual bottom center
							--MOVE THE Y UP
							new_y = list_y + PAUSE_LIST_BUTTON_HEIGHT
						else
							new_y = end_y
						end
					end
				else
					--is the current button half way from the visible top
					if self.current_idx > visual_center then
						--the current button is greater than or equal to the visual middle
						--is the current button half way from the visible bottom
						if self.current_idx < visual_center_bottom then
							--the current button is less than or equal to the visual bottom center
							--MOVE THE Y DOWN
							new_y = list_y - PAUSE_LIST_BUTTON_HEIGHT
						else
							new_y = end_y
						end
					end
				end
		
				Vdo_pause_mega_list_tween_done = true
			end
		
			-- Get current button
			local current_idx = self.current_idx
			local current_button = self.buttons[current_idx]
			
			local current_button_data = self.data[current_idx]
			
			-- Highlight current button
			current_button:set_highlight(true)
			current_button:set_property("depth", -10)
			current_button:set_property("blur", 0)
		
			highlight:set_property( "depth",  -1)
			--get the current highlighted button x and y
			local button_x, button_y = current_button:get_property("anchor")
			highlight:set_property( "anchor", button_x, button_y )
			highlight:set_width(current_button:get_text_width())
			
			--if there is only one button don't animate highlight
			if self.num_buttons > 1 then
				highlight:set_highlight()
			end
			
			
			-- Highlighting a button...
			if self.data[current_idx].type == TYPE_BUTTON then
				--Default controls...
				--Show A Button
				highlight:show_button(CTRL_MENU_BUTTON_A)
			end
			
			if current_button_data.disabled == true then
				--hide icon and button
				current_button:set_property("alpha", 0.5)
				highlight:show_button("")
			else
				current_button:set_property("alpha", 1.0)
			end
		end
	elseif self.data[self.current_idx].type == TYPE_TOGGLE then
		--toggle is open so send the navigation off to the toggle list
		self.toggle:move_cursor(direction)
	end
end

function Vdo_pause_mega_list:get_selection()
	if not self.draw_called then
		debug_print("vint", "Vdo_pause_mega_list:get_selection called with invalid document handle\n")
		return
	end
	
	if self.data[self.current_idx].disabled == true then
		return -1
	end

	return self.current_idx
end


-- Gets an optional ID value if one is saved
function Vdo_pause_mega_list:get_id()
	if not self.draw_called then
		debug_print("vint", "Vdo_pause_mega_list:get_toggle_selection called with invalid document handle\n")
		return
	end
	
	if self.data[self.current_idx].disabled == true then
		return -1
	end
	
	return self.data[self.current_idx].id
end

function Vdo_pause_mega_list:button_a()
	if not self.draw_called then
		debug_print("vint", "Vdo_pause_mega_list:button_a called with invalid document handle\n")
		return
	end
	

	
	local current_idx = self.current_idx
	local button_data = self.data[current_idx]
	local button =  self.buttons[current_idx]
	
	if button_data.type == TYPE_BUTTON then
		--Play sound...
		game_UI_audio_play("UI_main_menu_select")
	end

	--Callback for selecting the object...
	if button_data.on_select then
		button_data.on_select(button_data)
	end
	
	--check if we can process input
	if not Vdo_pause_mega_list_tween_done then
		return
	end
	
	local current_button = self.buttons[current_idx]
end

function Vdo_pause_mega_list:button_b()
	if not self.draw_called then
		debug_print("vint", "Vdo_pause_mega_list:button_b called with invalid document handle\n")
		return
	end
	
	--play sound...
	game_UI_audio_play("UI_main_menu_nav_back")
	
	local current_idx = self.current_idx
	local current_button = self.buttons[current_idx]
end


function Vdo_pause_mega_list:return_data()
	if not self.draw_called then
		debug_print("vint", "Vdo_pause_mega_list:return_data called with invalid document handle\n")
		return
	end
	
	return self.data
end

function Vdo_pause_mega_list:return_selected_data()
	if not self.draw_called then
		debug_print("vint", "Vdo_pause_mega_list:return_selected_data called with invalid document handle\n")
		return
	end
	
	return self.data[self.current_idx]
end

function Vdo_pause_mega_list:return_state()
	
	if not self.draw_called then
		debug_print("vint", "Vdo_pause_mega_list:return_state called with invalid document handle\n")
		return
	end
	
	return self.open
end

function Vdo_pause_mega_list:enable(state)
	if not self.draw_called then
		debug_print("vint", "Vdo_pause_mega_list:enable called with invalid document handle\n")
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

function Vdo_pause_mega_list:show_bar(is_on)
	self.highlight:show_bar(is_on)
end

function Vdo_pause_mega_list:toggle_highlight(is_on)
	if not self.draw_called then
		debug_print("vint", "Vdo_pause_mega_list:toggle_highlight called with invalid document handle\n")
		return
	end
	
	local highlight = self.highlight
	highlight:set_property("visible", is_on)
	
	local current_idx = self.current_idx
	
	for idx, button in pairs(self.buttons) do
		button:set_highlight(false)
	end
	
	self.buttons[current_idx]:set_highlight(is_on)
end

-- Method to set callback for when the transition animation is complete...
function  Vdo_pause_mega_list:set_anim_in_cb(callback_func)
	self.anim_in_func_cb = callback_func
end

-- Method to set callback for when the out animation is complete...
function  Vdo_pause_mega_list:set_anim_out_cb(callback_func)
	self.anim_out_func_cb = callback_func
end

function Vdo_pause_mega_list:transition_out()
	local anim_out = Vdo_anim_object:new("mega_list_out_anim", self.handle)
	local twn_out = Vdo_tween_object:new("megalist_out_twn", anim_out.handle)
	twn_out:set_end_event(self.anim_out_func_cb)
	anim_out:play()
end

function Vdo_pause_mega_list:refresh_values(data)
	if not self.draw_called then
		debug_print("vint", "Vdo_pause_mega_list:refresh_values called with invalid document handle\n")
		return
	end
	
	for idx, val in pairs(data) do
		--store the button toggle options
		if data[idx].type == TYPE_BUTTON then
			-- Set the button toggle value
			self.buttons[idx]:set_value("")
		end
	end
end

function Vdo_pause_mega_list:return_size()
	local total_height
	for idx, val in pairs(self.data) do
		total_height = idx * LIST_BUTTON_HEIGHT
	end
	return self.width,total_height
end

function Vdo_pause_mega_list:set_highlight_color(color)
	self.highlight:set_color(color)
end

function Vdo_pause_mega_list:set_button_color(selected_color, unselected_color)
	self.button_selected_color 	= selected_color
	self.button_unselected_color 	= unselected_color
end

function Vdo_pause_mega_list:set_shadows(has_shadows)
	self.button_shadows = has_shadows
end

-- Sets the new current index
--
function Vdo_pause_mega_list:set_selection(new_index)
	if self.data[self.current_idx].disabled == true then
		return
	end

	self.current_idx = new_index
end

-- =====================================
--       Mouse Specific Functions
-- =====================================

-- Returns the button's index in the list based on the target handle. Returns 0 if nothing was found
--
function Vdo_pause_mega_list:get_button_index(target_handle)
	if self.buttons == nil then
		return
	end
		
	for idx, button in pairs(self.buttons) do
		if self.alignment == PAUSE_MEGA_LIST_ALIGN_CENTER then
			if vint_object_find("toggle_text", button.handle) == target_handle then
				return idx
			end
		else
			if button.handle == target_handle then
				return idx
			end
		end
	end

	-- If no matching target handle was found, return an invalid index
	return 0
end

-- Adds mouse input subscriptions to the input tracker
--
-- @param	func_prefix			Name of the screen that is currently using the hint bar
-- @param	input_tracker		The input tracker to hold the mouse inputs events
-- @param	priority				The priority of the input event
function Vdo_pause_mega_list:add_mouse_inputs(func_prefix, input_tracker, priority)
	if (self.buttons == nil) or (func_prefix == nil) then
		return
	end
	
	-- Default priority value to 50
	priority = priority or 50
	
	local mouse_click_function = func_prefix.."_mouse_click"
	local mouse_move_function = func_prefix.."_mouse_move"
	
	for idx, button in pairs(self.buttons) do
		if self.alignment == PAUSE_MEGA_LIST_ALIGN_CENTER then
			input_tracker:add_mouse_input("mouse_click", mouse_click_function, priority, vint_object_find("toggle_text", self.buttons[idx].handle))
			input_tracker:add_mouse_input("mouse_move", mouse_move_function, priority, vint_object_find("toggle_text", self.buttons[idx].handle))
			
		else
			input_tracker:add_mouse_input("mouse_click", mouse_click_function, priority, self.buttons[idx].handle)
			input_tracker:add_mouse_input("mouse_move", mouse_move_function, priority, self.buttons[idx].handle)
		end
	end
end