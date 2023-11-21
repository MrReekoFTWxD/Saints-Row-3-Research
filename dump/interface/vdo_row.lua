function vdo_row_init()
end

function vdo_row_cleanup()
end

-- Inherited from Vdo_base_object
Vdo_row = Vdo_base_object:new_base()

COLOR_PAUSE_BUTTON_TOGGLE_TEXT_UNSELECTED = {R = 194/255, G = 201/255; B = 204/255}
COLOR_PAUSE_BUTTON_TOGGLE_TEXT_SELECTED = {R = 0/255, G = 0/255; B = 0/255}

local SELECTED_SCALE = 1.0
local UNSELECTED_SCALE = 1.0
PAUSE_ROW_ITEM_MIN_SPACING = 10 --* 3 		--Spacing between columns

function Vdo_row:init()
	self.columns = {
		{h = vint_object_find("row_item_1", self.handle), x = 0, width = 0, enabled = true, alignment = ALIGN_LEFT},
		{h = vint_object_find("row_item_2", self.handle), x = 0, width = 0, enabled = true, alignment = ALIGN_LEFT},
		{h = vint_object_find("row_item_3", self.handle), x = 0, width = 0, enabled = true, alignment = ALIGN_LEFT},
		{h = vint_object_find("row_item_4", self.handle), x = 0, width = 0, enabled = true, alignment = ALIGN_LEFT},
	}
	--default column count...
	self.column_count = 4
end

--------------------------------------------------------------------------------
-- Set font scale of entire row.
--
function Vdo_row:set_font_scale(font_scale)
	for idx, val in pairs(self.columns) do
		vint_set_property(val.h, "text_scale", font_scale, font_scale)
	end
end
	

--------------------------------------------------------------------------------
-- Sets the text value of each column
-- only supports 4 arguments for 4 columsn
function Vdo_row:set_value(...)
	for idx = 1, #self.columns do
		local label = arg[idx]
		local h = self.columns[idx].h
		local col = self.columns[idx]
		if label ~= nil and label ~= "" and idx <= self.column_count then
			vint_set_property(h, "text_tag", label)
			vint_set_property(h, "visible", true)
			col.width = floor(element_get_actual_size(h))
		else
			debug_print("vint", "idx: " .. idx .. "\n")
			vint_set_property(h, "visible", false)
			col.width = 0
		end
	end
end

-------------------------------------------------------------------------------
-- Sets the position of col_2, col_3, and col_4
--	@param col_1	largest width of column 1
--	@param col_2	largest width of column 2
--	@param col_3	largest width of column 3
--	@param col_4	largest width of column 4
-------------------------------------------------------------------------------
function Vdo_row:format_columns(...)
	local x = 0
	local total_width = 0
	local count = 0
	
	for idx = 1, self.column_count do
		local col_width = arg[idx]
		--this could be different depending on what come up with below, alignment means different width...
		total_width = total_width + col_width
		if idx > 1 then
			total_width = total_width + PAUSE_ROW_ITEM_MIN_SPACING
		end
	end

	--Hardcoding size of indent from left side... and an extra 5 for padding...
	total_width  = total_width + 45 * 3

	if total_width < self.max_width then
		local extra_width = self.max_width - total_width
		local extra_width_per_item = extra_width / (self.column_count)
		for idx = 1, self.column_count do
			local col = arg[idx]
			arg[idx] = floor(col + extra_width_per_item)
		end
	end

	for idx = 1, self.column_count do
		local label = arg[idx]
		local h = self.columns[idx].h
		local alignment = self.columns[idx].alignment 
		local new_width = 0
		local prev_width = 0

		local original_x, original_y = vint_get_property(h, "anchor")
		
		if idx == 1 then
			--first item is always left aligned...
			x = 0
		else
			if self.columns[idx - 1].alignment == ALIGN_LEFT then
				if alignment == ALIGN_LEFT then
					prev_width = arg[idx - 1]
					x = x + prev_width
				else
					prev_width = arg[idx - 1]
					new_width = arg[idx]
					x = x + prev_width + new_width
				end
			else
				--previous item is align right
				
				if alignment == ALIGN_LEFT then
					prev_width = arg[idx - 1]
					x = x
				else
					--this item is align right...
					new_width = arg[idx]
					x = x + new_width
				end
			end
			--Add spacing...
			x = x + PAUSE_ROW_ITEM_MIN_SPACING
		end

		 self.columns[idx].x = x
		vint_set_property(h, "anchor", x, original_y)
	end
	
	--make sure we include the indenting in our final width...
	self.width = x + 45 * 3
end

-------------------------------------------------------------------------------
-- Returns column widths of pause row
-- @return	width of col_1
-- @return	width of col_2
-- @return	width of col_3
-- @return	width of col_4
-------------------------------------------------------------------------------
function Vdo_row:get_column_widths()
	return self.columns[1].width, self.columns[2].width, self.columns[3].width, self.columns[4].width
end


-------------------------------------------------------------------------------
-- Returns the column positions of each element...
--
function Vdo_row:get_column_positions()
	return self.columns[1].x, self.columns[2].x, self.columns[3].x, self.columns[4].x
end

-------------------------------------------------------------------------------
-- Returns the width stored from when we formated the row.
--
function Vdo_row:get_width()
	return self.width
end


-------------------------------------------------------------------------------
-- Sets the max width that the row could be, so we can stretch really wide
-- if the list requests it.
--
function Vdo_row:set_max_width(max_width)
	self.max_width = max_width
end

-- Sets the highlighted state of the slider to on or off (will eventually have grayed out here too)
function Vdo_row:set_highlight(is_highlighted)
	if is_highlighted then
		for idx, val in pairs(self.columns) do
			vint_set_property(val.h, "tint", COLOR_PAUSE_BUTTON_TOGGLE_TEXT_SELECTED.R, COLOR_PAUSE_BUTTON_TOGGLE_TEXT_SELECTED.G, COLOR_PAUSE_BUTTON_TOGGLE_TEXT_SELECTED.B)
			vint_set_property(val.h, "scale", SELECTED_SCALE, SELECTED_SCALE)
		end
	else
		for idx, val in pairs(self.columns) do
			vint_set_property(val.h, "tint", COLOR_PAUSE_BUTTON_TOGGLE_TEXT_UNSELECTED.R, COLOR_PAUSE_BUTTON_TOGGLE_TEXT_UNSELECTED.G, COLOR_PAUSE_BUTTON_TOGGLE_TEXT_UNSELECTED.B)
			vint_set_property(val.h, "scale", UNSELECTED_SCALE, UNSELECTED_SCALE)
		end
	end
end

-- Sets the alignment for the columns
-- arg1 = column 1, ALIGN_LEFT or ALIGN_RIGHT
function Vdo_row:set_alignment(...)
	for idx, val in pairs(self.columns) do
		local alignment = arg[idx]
		
		local auto_offset = "w"
		if alignment == ALIGN_RIGHT then
			auto_offset = "e"
		end
		
		vint_set_property(val.h, "auto_offset", auto_offset)
		val.alignment = alignment
	end
end

-------------------------------------------------------------------------------
-- Sets the number of columns used in the mewnu...
-- @param	#of columns
--
function Vdo_row:set_column_count(column_count)
	self.column_count = column_count
end'0