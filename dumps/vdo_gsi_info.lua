-------------------------------------------------------------------------------
-- GSI Info Component
-- This combonent is used to display in the format of the following.
-- STATUS: XXXX
-- 
-- It is used for things like mayhem to keep track of combos. i.e. COMBO: 1 
-------------------------------------------------------------------------------
-- Inherited from Vdo_base_object
Vdo_gsi_info = Vdo_base_object:new_base()

-- Standard Init Function
function vdo_gsi_info_init()
end

-- Standard Cleanup Function
function vdo_gsi_info_cleanup()
end

--Constants
local GSI_INFO_LABEL_PADDING = 9 * 3

function Vdo_gsi_info:init()
end

function Vdo_gsi_info:create(skin)
	--Initialize Standard Indicator Values
	self.visible = -1						--Is the indicator displaying? 
	self.is_dirty = true					--Is the indicator dirty? we set this to true if we want the GSI to re-align everything.
	self.skin = skin
	self.width = 100 * 3
	self.height = 10 * 3
	
	--Initialize Custom Values 
	self.info_value = "XXXX: IS AWESOME"
	self.label = 0
end

function Vdo_gsi_info:update(visible, skin, label_crc, info_crc, info_value)
	--Set visible
	self:set_visible(visible)
	
	--Check if everything is formatted during change?
	
	local info_txt_obj = Vdo_base_object:new("info_txt", self.handle)
	local label_txt_obj = Vdo_base_object:new("label_txt", self.handle)
	
	--Set label with crc
	if label_crc == 0 or label_crc == nil then
		--No crc or Invalid crc
		label_txt_obj:set_text("")
	else
		label_txt_obj:set_text_crc(label_crc)
	end
	
	--Set Info Part
	if info_crc == 0 and info_value == nil then
		--no string
		info_txt_obj:set_text("")
	elseif info_crc == 0 then
		--Use string
		
		--Skin processing
		if skin == "Cash" then
			--format the cash
			info_value = "$" .. format_cash(tonumber(info_value))
		elseif skin == "TrailBlazing" then
			--Trailblazing specific
			local insertion_text 	= { [0] = info_value }
			info_value = vint_insert_values_in_string("HUD_AMT_SECS_B", insertion_text)
			
			--Tint the bonus yellow
			info_txt_obj:set_color(GSI_SKIN["Default"].tint[1], GSI_SKIN["Default"].tint[2], GSI_SKIN["Default"].tint[3])
		end
		
		info_txt_obj:set_text(info_value)
	else
		--use crc
		info_txt_obj:set_text_crc(info_crc)
	end
	
	--Mayhem Activity Specific Coloring
	if skin == "Mayhem" then
		if info_value ~= "0" then
			info_txt_obj:set_color(Hud_mayhem_world_cash_status.color_r, Hud_mayhem_world_cash_status.color_g, Hud_mayhem_world_cash_status.color_b)
		else
			--reset color
			info_txt_obj:set_color(GSI_SKIN["Mayhem"].tint[1], GSI_SKIN["Mayhem"].tint[2], GSI_SKIN["Mayhem"].tint[3])
		end
	end

	label_txt_obj:set_scale(1,1)
	info_txt_obj:set_scale(1,1)
	
	--Repostion Elements and Calculate width/height
	local label_width, label_height = label_txt_obj:get_actual_size()
	local info_width, info_height = info_txt_obj:get_actual_size()
	
	--Resize if its too wide to fit within reason...
	local width_total = label_width + info_width
	local width_max = 536 * 3
	if width_total > width_max then
		local scale = width_max/width_total
		label_txt_obj:set_scale(scale, 1)
		info_txt_obj:set_scale(scale, 1)
		label_width = label_width * scale
		info_width = info_width * scale
	end
	
	local label_padding = GSI_INFO_LABEL_PADDING
	if label_width == 0 then
		--If the label doesn't exist then we don't need any padding
		label_padding = 0 
	end
	
	--Left Aligned Only?
	local info_x = label_padding + label_width
	local info_y = 0
	
	info_txt_obj:set_anchor(info_x, info_y)
	
	--Override width for mayhem only.
	if skin == "Mayhem" then
		info_width = 30 * 3
	end
	
	--Clean up GSI if the label changed...
	if label_crc ~= self.label_crc  then
		self.is_dirty = true	
	end
	
	--Add spacing to width
	local width = info_x + info_width + GSI_TEXT_SPACING
	local width_dif = abs(self.width - width)
	
	--Determine if we need to do more cleanup?
	if width_dif > 3 then
		self.is_dirty = true	
	end

	--Get Height of object...
	local height = info_height
	if label_height > info_height then
		height = label_height
	end
	
	--Store new width and height of indicator
	self.width = width
	self.height = height
	
	---Store Values
	self.label_crc = label_crc
	self.info_value = info_value
end

function Vdo_gsi_info:get_size()
	return self.width, self.height
end

--Standard Indicator Functions
function Vdo_gsi_info:set_visible(visible)
	--Hide the indicator if it is not visible
	if visible ~= self.visible then
		if visible == true then
			self:set_property("visible", true)
			self.visible = visible
		else
			self:set_property("visible", false)
			self.visible = visible
		end
		
		--Format of the indicators changed, so lets make sure we set the flag to dirty.
		--The vdo_gsi will take care of everything when we set this dirty flag to true...
		self.is_dirty = true
	end
end