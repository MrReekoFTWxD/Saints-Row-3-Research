-------------------------------------------------------------------------------
--GSI XY Component
-------------------------------------------------------------------------------
-- Inherited from Vdo_base_object
Vdo_gsi_xy = Vdo_base_object:new_base()

-- Standard Init Function
function vdo_gsi_xy_init()
end

-- Standard Cleanup Function
function vdo_gsi_meter_cleanup()
end

--Constants
local	GSI_XY_LABEL_PADDING = 9 * 3
local	GSI_XY_SLASH_PADDING = 2 * 3

function Vdo_gsi_xy:init()

	--Store references to objects
	self.label_txt_h 	= vint_object_find("label_txt", self.handle)
	self.slash_txt_h 	= vint_object_find("slash_txt", self.handle)
	self.x_txt_h 		= vint_object_find("x_txt", self.handle)
	self.y_txt_h  		= vint_object_find("y_txt", self.handle)
	self.gsi_x_anim_h = vint_object_find("gsi_x_anim", self.handle)
	
	--Retarget_animation...
	vint_set_property(self.gsi_x_anim_h, "target_handle", self.x_txt_h)
end

function Vdo_gsi_xy:create(skin)
	--Initialize Standard Indicator Values
	self.visible = -1						--Is the indicator displaying? 
	self.is_dirty = true					--Is the indicator dirty? we set this to true if we want the GSI to re-align everything.
	self.skin = skin
	self.width = -1
	self.height = -1
	
	--Initialize Custom Values 
	self.x_value = 200 * 3
	self.y_value = 200 * 3
	self.label = 0
end

function Vdo_gsi_xy:update(visible, skin, label_crc, x_value, y_value, is_cash)
	--Set visible
	self:set_visible(visible)
	
	local label_txt_h = self.label_txt_h
	local slash_txt_h = self.slash_txt_h
	local x_txt_h = self.x_txt_h
	local y_txt_h = self.y_txt_h

	
	--Set label with crc
	if label_crc == 0 or label_crc == nil then
		--No crc or Invalid crc
		vint_set_property(label_txt_h, "text_tag", "")
	else
		vint_set_property(label_txt_h, "text_tag_crc", label_crc)
	end
	
	--Animate it...
	if x_value ~= self.x_value then
		lua_play_anim(self.gsi_x_anim_h)
	end
	
	--If skin is left blank then 
	if skin == "" then
		if is_cash == true then
			skin = "cash"
		else 
			skin = "default"
		end
	end
		
	--Apply any special formatting to the text
	local x_value_text, y_value_text
	
	if skin == "Cash" or skin == "Cash_Flash_Disabled" then
		x_value_text = "$" .. format_cash(x_value)
		y_value_text = "$" .. format_cash(y_value)
	else
		x_value_text = x_value
		y_value_text = y_value
	end
	
	--Set Text Fields
	vint_set_property(x_txt_h, "text_tag", x_value_text)
	
	--test size in the y slot because the x slot could be scaling because of animation...
	vint_set_property(y_txt_h, "text_tag", x_value_text)
	local x_width, x_height = element_get_actual_size(y_txt_h)
	
	vint_set_property(y_txt_h, "text_tag", y_value_text)
	
	
	--Get Sizes first
	local label_x, label_y = vint_get_property(label_txt_h, "anchor")
	local label_width, label_height = element_get_actual_size(label_txt_h)

	local slash_width, slash_height = element_get_actual_size(slash_txt_h)
	local y_width, y_height = element_get_actual_size(y_txt_h)

	local x_anchor_x = x_width/2
	if label_width ~= 0 then
		x_anchor_x = label_x + label_width + GSI_XY_LABEL_PADDING + x_anchor_x
	end
	
	--Set Positions
	local slash_anchor_x = x_anchor_x + x_width/2 + GSI_XY_SLASH_PADDING
	local y_anchor_x = slash_anchor_x + slash_width + GSI_XY_SLASH_PADDING
	
	vint_set_property(x_txt_h, "anchor", x_anchor_x, label_y)
	vint_set_property(y_txt_h, "anchor", y_anchor_x, label_y)
	vint_set_property(slash_txt_h, "anchor", slash_anchor_x, label_y)
	
	--Calculate Width
	local width = y_anchor_x + y_width + (GSI_TEXT_SPACING * 1.5)
	local width_dif = abs(self.width - width)
	
	if width_dif > 3 then
		self.is_dirty = true
	end
	
	--Store size values
	self.width = width
	self.height = x_height
	
	--Store Object values
	self.label_crc = label_crc
	self.x_value = x_value
	self.y_value = y_value
end

function Vdo_gsi_xy:get_size()
	return self.width, self.height
end

--Standard Indicator Functions
function Vdo_gsi_xy:set_visible(visible)
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