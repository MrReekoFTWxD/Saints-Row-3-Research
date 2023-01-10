--------------------------------------------------------------------------- 
-- Newsticker!
---------------------------------------------------------------------------
Current_ticker = -1
local Screen_width = 3840

local NEWSTICKER_SEPERATOR_PADDING	= 10
local NEWSTICKER_TEXT_PADDING			= 20*3
local PIXELS_PER_SECOND					= 60*3

local Ticker_data_thread = -1
local Text_clones = { }

local NTS_OFFLINE_STRINGS				= 0
local NTS_ONLINE_STRINGS				= 1

function vdo_newsticker_init()
end

function vdo_newsticker_cleanup()
end

-- Inherited from Vdo_base_object
Vdo_newsticker = Vdo_base_object:new_base()

function Vdo_newsticker:init()
	self.lines = { }	
	self.num_lines = 0
	
	self.clones = {}
	self.clone_count = 0
	
	--Animation that slide that scales all the objects in.
	
	self.anim_h = vint_object_find("scroll_text_anim", self.handle)
	self.twn_h = vint_object_find("scroll_text_twn", self.handle)
	vint_set_property(self.twn_h, "end_event", "vint_anim_loop_callback")

	self.current_line = 0
	Current_ticker = self
	
	Ticker_data_thread = thread_new("newsticker_data_request_thread")
end

function Vdo_newsticker:on_destroy()
	if Current_ticker == self then
		Current_ticker = -1
	end
	
	if Ticker_data_thread ~= -1 then
		thread_kill(Ticker_data_thread)
		Ticker_data_thread = -1
	end
end

function Vdo_newsticker:populate_strings(text_line, online_string)
	self.lines[self.num_lines] = text_line
	self.num_lines = self.num_lines + 1
end

function Vdo_newsticker:build()
	--remove all clones from before...
	self:clones_destroy()

	local text_h = vint_object_find("text", self.handle)
	local seperator_h = vint_object_find("seperator", self.handle)
	local text_clone_h, seperator_clone_h
	local text_x, text_y = vint_get_property(text_h, "anchor")
	local seperator_x, seperator_y = vint_get_property(seperator_h, "anchor")

	local text_width, text_height 	--leave undefined... need to check string length...
	local seperator_width, seperator_height = element_get_actual_size(seperator_h)
	
	local next_x = 0
	
	for i = 0, self.num_lines -1 do
		local is_clone = false
		if i == 0 then
			text_clone_h		= text_h
			seperator_clone_h = seperator_h
		else
			text_clone_h = vint_object_clone(text_h)
			seperator_clone_h = vint_object_clone(seperator_h)
			is_clone = false
			self:clone_store(text_clone_h)
			self:clone_store(seperator_clone_h)
		end
		
		--Set text tag...
		vint_set_property(text_clone_h, "text_tag", self.lines[i])
		
		--Set positions...
		seperator_x = next_x 
		text_x = seperator_x + seperator_width + NEWSTICKER_SEPERATOR_PADDING
		vint_set_property(seperator_clone_h, "anchor", seperator_x , seperator_y) 
		vint_set_property(text_clone_h, "anchor", text_x, text_y)
				
		--Get width and height... to calculate for next ticker message...
		text_width, text_height = element_get_actual_size(text_clone_h)
		next_x = text_x + text_width + NEWSTICKER_TEXT_PADDING
	end
	
	local twn_h = vint_object_find("scroll_text_twn", self.handle)
	vint_set_property(twn_h, "duration", (Screen_width+next_x)/PIXELS_PER_SECOND)
	vint_set_property(twn_h, "start_value", Screen_width, 0)
	vint_set_property(twn_h, "end_value", -next_x, 0)
	
	lua_play_anim(self.anim_h)
	
	--width...
	self.width = next_x
end

function Vdo_newsticker:clone_store(clone_h)
	self.clones[self.clone_count] = clone_h
	self.clone_count = self.clone_count + 1
end

function Vdo_newsticker:clones_destroy()
	for i = 0, self.clone_count - 1 do 
		vint_object_destroy(self.clones[i])
	end
	self.clone_count = 0
	self.clones = {}
end

-------------------------------------------------------------------------------
-- news ticker utility functions...
-------------------------------------------------------------------------------

function newsticker_data_request_thread()
	vint_dataresponder_request("newsticker_populate", "newsticker_populate", 0, NTS_OFFLINE_STRINGS)
	Current_ticker:build()
	
	Current_ticker.num_lines = 0
	
	Ticker_data_thread = -1
end

function newsticker_populate(text_line, online)
	if Current_ticker == -1 then
		return
	end
		
	Current_ticker:populate_strings(text_line, online)
end