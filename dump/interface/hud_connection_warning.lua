local Hud_connection_warning_handle = -1
local Ping_thread_handle = 0;

--Init
function hud_connection_warning_init()
	Hud_connection_warning_handle = vint_document_find("hud_connection_warning")

	local status_text_handle = vint_object_find("connection_status")
	vint_set_property(status_text_handle, "text_tag", "LOW_CONNECTION_WARNING")
	vint_set_property(status_text_handle,"visible", false)

	Ping_thread_handle = thread_new("hud_connection_warning_ping_thread")
end

--Cleanup
function hud_connection_warning_cleanup()
	thread_kill(Ping_thread_handle)
	Ping_thread_handle = 0
end

-------------------------------------------------------------------------------
-- Get ping every 2 seconds until game is finished
--
function hud_connection_warning_ping_thread()
	local status_text_handle = vint_object_find("connection_status")
	local previous_status = false

	while true do
		local cell_foreground_doc = vint_document_find("cell_foreground")
		local current_status = coop_is_active()

		if current_status == true then
			local ping = game_get_coop_ping()
			
			if cell_foreground_doc ~= 0 then
				hud_connection_warning_set_ping(ping, cell_foreground_doc)
			end
			
			vint_set_property(status_text_handle, "visible", ping > PING_RATE_GREEN_ZONE)
			debug_print("vint", "hud_connection_warning_ping("..ping.." ms)\n")
		end
		
		if previous_status ~= current_status then
			if cell_foreground_doc ~= 0 then
				local top_icons_h = vint_object_find("top_icons", 0, cell_foreground_doc)
				vint_set_property(top_icons_h, "visible", not current_status)
				
				local ping_grp_h = vint_object_find("ping_grp", 0, cell_foreground_doc)
				vint_set_property(ping_grp_h, "visible", current_status)
			end
			
			previous_status = current_status
			-- Force hide warning message
			vint_set_property(status_text_handle, "visible", false)
		end
		
		delay(PING_TIME_CHECK_DELAY)
	end
end

-------------------------------------------------------------------------------
-- Sets connection strength for co-op in cell phone
--
function hud_connection_warning_set_ping(ping, cell_foreground_doc)
	local ping_grp_h = vint_object_find("ping_grp", 0 , cell_foreground_doc)
	local ping_txt_h = vint_object_find("ping_txt", 0, cell_foreground_doc)
	local bars = {}
	local num_bars = 0
	local color = COLOR_PING_GREY

	vint_set_property(ping_txt_h, "text_tag", ping.." ms ")
		
	-- turn all bars "off"
	for i = 1, 5 do
		local h = vint_object_find("bar_img_"..i, ping_grp_h, cell_foreground_doc)
		vint_set_property(h, "alpha", .33)				
		bars[i] = h
	end
	
	-- determing how many bars and what color to show
	if ping <= PING_RATE_GREEN_ZONE then
		if ping < 50 then
			num_bars = 5
		else
			num_bars = 4
		end		
		
		color = COLOR_PING_GREEN		
	elseif ping > PING_RATE_GREEN_ZONE and ping < PING_RATE_RED_ZONE then
		num_bars = 3		
	
		color = COLOR_PING_YELLOW		
	else
		if ping < 400 then
			num_bars = 2
		else
			num_bars = 1
		end
		
		color = COLOR_PING_RED
		
		if ping > 999 then
			vint_set_property(ping_txt_h, "text_tag", "999 ms ")
		end
	end
	
	-- turn bars "on"
	for i = 1, num_bars do
		vint_set_property(bars[i], "alpha", 1)	
	end
	
	--set color and show grp
	vint_set_property(ping_grp_h,"tint", color.R, color.G, color.B)
	vint_set_property(ping_grp_h,"visible", true)
end