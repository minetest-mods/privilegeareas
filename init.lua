privilegeareas = {

	players = {},

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

		}
	},

	createPlayerTable = function(player)
		if not player or not player:get_player_name() then
			print("Player does not exist!")
			return;
		end

		local name = player:get_player_name()

		print("writing player table for "..name)
		
		if (name=="") then
			return;
		end
		
		privilegeareas.players[name] = {}
		privilegeareas.players[name].player = player

		if not privilegeareas.players[name].areas then
			privilegeareas.players[name].areas = {}
		end

		privilegeareas.calculate_current_areas(player)
	end,
	
	calculate_current_areas = function(player)
		local name = player:get_player_name()
		print("calculating current areas for "..name)

		if (name=="") then
			return;
		end

		if (not privilegeareas.players[name]) then
			createPlayerTable(player)
		end

		for i=1,# privilegeareas.areas do
			if privilegeareas.areas[i].type == "radius" then
				if distance(player:getpos(),privilegeareas.areas[i].location) < privilegeareas.areas[i].location.radius then
					print ("is in area "..i)
					if  (not privilegeareas.players[name].areas or not privilegeareas.players[name].areas[i] or privilegeareas.players[name].areas[i]==false) then
						print ("running function enter area")
						privilegeareas.enter_area(player,i)
					end
				else
					print ("is not in area "..i)
					if  (privilegeareas.players[name].areas[i]==true) then
						print ("running function leave area")
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
			print("player does not exist error!")
		end

		-- loop grants
		local tmp = false
		if privilegeareas.areas[i].actions.on_enter.grant then
			for a=1,# privilegeareas.areas[i].actions.on_enter.grant do
				if tmp == false then
					tmp = true
					minetest.chat_send_player(name, "You have been given the following privs:")
				end
	
				privs[privilegeareas.areas[i].actions.on_enter.grant[a]]=true;
				minetest.chat_send_player(name, "-- "..privilegeareas.areas[i].actions.on_enter.grant[a])
			end
		end

		-- Loop though takes
		tmp = false
		if privilegeareas.areas[i].actions.on_enter.take then
			
			for a=1,# privilegeareas.areas[i].actions.on_enter.take do
				if tmp == false then
					tmp = true
					minetest.chat_send_player(name, "You have lost the following privs:")
				end
	
				privs[privilegeareas.areas[i].actions.on_enter.take[a]]=false;
				minetest.chat_send_player(name, "-- "..privilegeareas.areas[i].actions.on_enter.take[a])
			end
		end

		-- Set privs
		minetest.set_player_privs(name, privs)
	end,

	leave_area = function(player,i)
		local name = player:get_player_name()
		privilegeareas.players[name].areas[i]=false
		minetest.chat_send_player(name, "You have left area "..i)
		
		-- Get privs
		local privs = minetest.get_player_privs(name)
		
		if not privs then
			print("player does not exist error!")
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
	end
}

function vector_is_in(hay,needle)
	if (needle.x > hay.x and needle.x < hay.x+hay.w) then
		if (needle.y > hay.y and needle.y < hay.y+hay.h) then
			if (needle.z > hay.z and needle.z < hay.z+hay.d) then
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
		print("Updating")

		for _, plr in pairs(privilegeareas.players) do
			print("player")
			privilegeareas.calculate_current_areas(plr.player)
		end

	end
end)

minetest.register_on_joinplayer(function(player)
	privilegeareas.createPlayerTable(player)
end)