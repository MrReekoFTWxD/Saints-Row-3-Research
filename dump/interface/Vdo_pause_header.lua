--------------------------------------------------------------------------- 
-- Vdo_pause_header
--
-- The header for each screen in the pause menu. This object gets included
-- manually in those documents that need a header.
---------------------------------------------------------------------------

-- Inherited from Vdo_base_object
Vdo_pause_header = Vdo_base_object:new_base()

--Colors - 
COLOR_PAUSE_HEADER = {R = 218/255, G = 226/255; B = 230/255}

--Standard Init
function Vdo_pause_header_init()
	--Hide the object from displaying crap on the first frame
	local text = vint_object_find("text")
	vint_set_property(text, "text_tag", "")
end

--Standard Cleanup
function Vdo_pause_header_cleanup()
end

--------------------------------------------------------------------------- 
-- Initializes VDO Object
---------------------------------------------------------------------------
function Vdo_pause_header:init()
	--Reset color to script value
	local text_obj = Vdo_base_object:new("text", self.handle)
	--text_obj:set_color(COLOR_PAUSE_HEADER.R, COLOR_PAUSE_HEADER.G, COLOR_PAUSE_HEADER.B)
end

--------------------------------------------------------------------------- 
-- Sets the text of the header and causes
--
-- @param new_text_string	Text string for header
---------------------------------------------------------------------------
function Vdo_pause_header:set_text(new_text_string, max_width)
	local text_obj = Vdo_base_object:new("text", self.handle)
	text_obj:set_text(new_text_string)
	text_obj:set_scale(1.0,1.0)
	local text_width,text_height = self:get_size() 
	
	--leave room for padding
	if max_width ~= nil then
		max_width = max_width - 40*3
	end
	
	if max_width ~= nil and text_width > max_width then
		local text_scale = max_width/text_width
		self:set_scale(text_scale,text_scale)
	else
		self:set_scale(1.0,1.0)
	end
	
	text_obj:set_alpha(1.0)
	text_obj:set_anchor(0,0)
	
	local crumb_obj = Vdo_base_object:new("text_crumb", self.handle)
	crumb_obj:set_visible(false)
	
end

function Vdo_pause_header:set_crumb(new_text_string)
	local crumb_obj = Vdo_base_object:new("text_crumb", self.handle)
	if new_text_string ~= nil or new_text_string ~= "" then
		crumb_obj:set_visible(true)
		crumb_obj:set_text(new_text_string)
	else
		crumb_obj:set_visible(false)
		crumb_obj:set_text("")
	end

end


function Vdo_pause_header:set_alignment(alignment)
	local text_obj_h = vint_object_find("text", self.handle)
	vint_set_property(text_obj_h, "auto_offset", alignment)
end

function Vdo_pause_header:set_text_scale(scale)
	local text_obj_h = vint_object_find("text", self.handle)
	vint_set_property(text_obj_h, "text_scale", scale, scale)
end

function Vdo_pause_header:get_size()
	local text_obj_h = vint_object_find("text", self.handle)
	return element_get_actual_size(text_obj_h)
end




'0