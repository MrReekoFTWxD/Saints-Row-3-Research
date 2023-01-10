----------------------
-- System Functions --
----------------------

_UGGlobals = { }
_DynamicGlobals = { }
_ActiveTable = ""

-- SDR / HDR
Current_menu_display_cal_id = 0
MENU_HDR							= 19
MENU_BRIGHTNESS						= 20

------------------------
-- Internal functions --
------------------------

function menu_display_set_cal_id(input_id)
	Current_menu_display_cal_id = input_id
end

function menu_display_get_cal_id()
	return Current_menu_display_cal_id
end
function menu_common_set_mouse_tracker(input_tracker)
	Current_mouse_input_tracker = input_tracker
end
function options_display_get_brightness_id()
	return MENU_BRIGHTNESS
end
function options_display_get_HDR_id()
	return MENU_HDR
end
function is_hdr_screen()
	return (Current_menu_display_cal_id == MENU_HDR)
end


-- Assign a value to global variable. Any nil-assignment raises an error.
--
function _CatchNilAssignment(t, k, v)
	if (v == nil) then
		error("attempted to initialize global variable '"..k.."' with nil value")
	elseif (_ActiveTable ~= "") then
		rawset( _DynamicGlobals[ _ActiveTable ], k, v )
	else
		rawset(t, k, v)
	end
end

-- Catch an attempt to write to an undefined global variable
--
function _CatchUndefinedGlobalWrite(t, k, v)
	if (v == nil) then
		error("attempted to initialize global variable '"..k.."' with nil value")
		return
	end

	for i, table in pairs( _DynamicGlobals ) do

		local val = rawget( table, k )
		if (val ~= nil) then
			rawset( table, k, v )
			return
		end

	end

	error("attempted to write to undefined global variable '"..k.."'")
end

-- Find a value in the Dynamic table since it's not in UGGlobals
--
function _GetDynamicGlobal( t, k )
	for i, table in pairs( _DynamicGlobals ) do

		local v = rawget( table, k )
		if (v ~= nil) then
			return v
		end

	end

	error("attempted to read undefined global variable '"..k.."'")
end

-- Find a value in any global space, return nil if not found
--
function _GetAnyGlobalSilent( k )
	local v
	
	v = rawget( _UGGlobals, k )
	
	if v ~= nil then
		return v
	end
	
	for i, table in pairs( _DynamicGlobals ) do
		v = rawget( table, k )
		if v ~= nil then
			return v
		end

	end

	return nil
end

-- Prepare to load a lua script into the dynamic table
--
function _PrepareForDynamicGlobals( filename )
	_DynamicGlobals[ filename ] = { }
	_ActiveTable = filename

	setmetatable( _UGGlobals, {__index = _GetDynamicGlobal, __newindex = _CatchNilAssignment} )
end

-- Callback for loading of dynamic table complete
--
function _DynamicGlobalsLoadComplete( )
	_ActiveTable = ""

	setmetatable( _UGGlobals, {__index = _GetDynamicGlobal, __newindex = _CatchUndefinedGlobalWrite} )
end

-- Unload a table of Dynamic globals
--
function _UnloadDynamicGlobals( filename )
	rawset( _DynamicGlobals, filename, nil ) -- erase the entry from the table
end

-- Delay execution for a certain amount of time
--
-- duration:	duration of delay, in seconds (if time_seconds <= 0, execution will delay for exactly one frame)
--
function delay(duration)
	if duration == nil then
		duration = 0
	end

	local elapsed_time = 0.0

	repeat
		thread_yield()
		elapsed_time = elapsed_time + get_frame_time()
	until (elapsed_time >= duration)
end
