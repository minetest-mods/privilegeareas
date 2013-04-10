privilegeareas = {

	players = nil,
	userdata = {},

	areas = {
	
		-- EXAMPLE HOTSPOT
		-- If player enters this area (is less than 10 metres away from {0,0,0}):
		-- 	>> "shout" is granted
		--	>> "fast" is taken away
		-- If player leaves this area (is more than 10 metres away from {0,0,0}):
		-- 	>> "fast" is granted
		--	>> "shout" is taken away
		{
			type="radius",
			location = {x=0,y=0,z=0,radius=10},
			actions = {
				on_enter = {
					grant = {"shout"},
					take = {"fast"}
				},
				
				on_leave = {
					grant = {"fast"},
					take = {"shout"}
				}
			},

		},

		-- EXAMPLE HOTSPOT 2
		-- If player enters this area ({-30000,100,-30000} to {30000,30000,30000}):
		-- 	>> "fly" is granted
		-- If player leaves this area ({-30000,100,-30000} to {30000,30000,30000}):
		--	>> "fly" is taken away
		-- note: all of location2's values must be bigger than location's values
		{
			type="box",
			location = {x=-30000,y=100,z=-30000},
			location2 = {x=30000,y=30000,z=30000},
			actions = {
				on_enter = {
					grant = {"fly"}
				},
				
				on_leave = {
					take = {"fly"}
				}
			},

		}
	},

	createPlayerTable = function(player)
		if not privilegeareas.players then
			load_data()
		end

		if not player or not player:get_player_name() then
			print("[PrivilegeAreas] Player does not exist!")
			return;
		end

		local name = player:get_player_name()

		print("[PrivilegeAreas] writing player table for "..name)

		if (name=="") then
			return;
		end
		
		privilegeareas.players[name] = {}
		privilegeareas.userdata[name] = player

		if not privilegeareas.players[name].areas then
			privilegeareas.players[name].areas = {}
		end
	end,
	
	calculate_current_areas = function(player)
		local name = player:get_player_name()
		print("[PrivilegeAreas] calculating current areas for "..name)

		if (name=="") then
			return;
		end

		if (not privilegeareas.players[name]) then
			createPlayerTable(player)
		end

		for i=1,# privilegeareas.areas do
			if privilegeareas.areas[i].type == "radius" then
				if distance(player:getpos(),privilegeareas.areas[i].location) < privilegeareas.areas[i].location.radius then
					if  (not privilegeareas.players[name].areas or not privilegeareas.players[name].areas[i] or privilegeareas.players[name].areas[i]==false) then
						privilegeareas.enter_area(player,i)
					end
				else
					if  (privilegeareas.players[name].areas[i]==true) then
						privilegeareas.leave_area(player,i)
					end
				end
			elseif privilegeareas.areas[i].type == "box" then
				if (vector_is_in(privilegeareas.areas[i].location,privilegeareas.areas[i].location2,player:getpos())) then
					print("is in box")
					if  (not privilegeareas.players[name].areas or not privilegeareas.players[name].areas[i] or privilegeareas.players[name].areas[i]==false) then
						privilegeareas.enter_area(player,i)
					end
				else
					print("is not in box")
					if  (privilegeareas.players[name].areas[i]==true) then
						privilegeareas.leave_area(player,i)
					end
				end
			end
		end
	end,

	enter_area = function(player,i)
		local name = player:get_player_name()
		privilegeareas.players[name].areas[i]=true
		minetest.chat_send_player(name, "You have entered area "..i)
		
		-- Get privs
		local privs = minetest.get_player_privs(name)
		
		if not privs then
			print("[PrivilegeAreas] player does not exist error!")
		end

		-- loop grants
		local tmpv = false
		if privilegeareas.areas[i].actions.on_enter.grant then
			for a=1,# privilegeareas.areas[i].actions.on_enter.grant do
				if tmpv == false then
					tmpv = true
					minetest.chat_send_player(name, "You have been given the following privs:")
				end
	
				privs[privilegeareas.areas[i].actions.on_enter.grant[a]]=true;
				minetest.chat_send_player(name, "-- "..privilegeareas.areas[i].actions.on_enter.grant[a])
			end
		end

		-- Loop though takes
		tmpv = false
		if privilegeareas.areas[i].actions.on_enter.take then
			
			for a=1,# privilegeareas.areas[i].actions.on_enter.take do
				if tmpv == false then
					tmpv = true
					minetest.chat_send_player(name, "You have lost the following privs:")
				end
	
				privs[privilegeareas.areas[i].actions.on_enter.take[a]]=false;
				minetest.chat_send_player(name, "-- "..privilegeareas.areas[i].actions.on_enter.take[a])
			end
		end

		-- Set privs
		minetest.set_player_privs(name, privs)
		
		-- save data
		save_data()
	end,

	leave_area = function(player,i)
		local name = player:get_player_name()
		privilegeareas.players[name].areas[i]=false
		minetest.chat_send_player(name, "You have left area "..i)
		
		-- Get privs
		local privs = minetest.get_player_privs(name)
		
		if not privs then
			print("[PrivilegeAreas] player does not exist error!")
		end

		-- loop grants
		local tmp = false
		if privilegeareas.areas[i].actions.on_leave.grant then
			for a=1,# privilegeareas.areas[i].actions.on_leave.grant do
				if tmp == false then
					tmp = true
					minetest.chat_send_player(name, "You have been given the following privs:")
				end
	
				privs[privilegeareas.areas[i].actions.on_leave.grant[a]]=true;
				minetest.chat_send_player(name, "-- "..privilegeareas.areas[i].actions.on_leave.grant[a])
			end
		end

		-- Loop though takes
		tmp = false
		if privilegeareas.areas[i].actions.on_leave.take then
			
			for a=1,# privilegeareas.areas[i].actions.on_leave.take do
				if tmp == false then
					tmp = true
					minetest.chat_send_player(name, "You have lost the following privs:")
				end
	
				privs[privilegeareas.areas[i].actions.on_leave.take[a]]=false;
				minetest.chat_send_player(name, "-- "..privilegeareas.areas[i].actions.on_leave.take[a])
			end
		end

		-- Set privs
		minetest.set_player_privs(name, privs)
		
		-- save data
		save_data()
	end
}

-- Table Save Load Functions
function save_data()
	if privilegeareas.players == nil then
		return
	end

	local file = io.open(minetest.get_worldpath().."/privareas.txt", "w")
	if file then
		file:write(minetest.serialize(privilegeareas.players))
		file:close()
	end
end

function load_data()
	if privilegeareas.players == nil then
		print("[PrivilegeAreas] Loading data")
	
		local file = io.open(minetest.get_worldpath().."/privareas.txt", "r")
		if file then
			local table = minetest.deserialize(file:read("*all"))
			if type(table) == "table" then
				privilegeareas.players = table
				return
			end
		end
	end
	privilegeareas.players = {}
end

load_data()

minetest.register_on_shutdown(function()
	-- save data
	save_data()
end)

function vector_is_in(hay,box,needle)
	if (needle.x > hay.x and needle.x < box.x) then
		if (needle.y > hay.y and needle.y < box.y) then
			if (needle.z > hay.z and needle.z <box.z) then
				return true
			end
		end
	end
	return false
end

function distance(v, w)
	return math.sqrt(
		math.pow(v.x - w.x, 2) +
		math.pow(v.y - w.y, 2) +
		math.pow(v.z - w.z, 2)
	)
end

local timer = 0

minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 1 then
		timer=0
		print("[PrivilegeAreas] Updating")

		for _, plr in pairs(privilegeareas.userdata) do
			privilegeareas.calculate_current_areas(plr)
		end

	end
end)

minetest.register_on_joinplayer(function(player)
	privilegeareas.createPlayerTable(player)
end)

minetest.register_on_leaveplayer(function(player)
	privilegeareas.userdata[player:get_player_name()]=nil
end)

