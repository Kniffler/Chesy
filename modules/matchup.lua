-- Function table to return
local fs = {}

function fs.execute(message, stats)
	log("\"\\matchup\" DETECTED : Proceeding with guard-clauses...")
	
	if not hasAdmin(message) then
		log("Insufficient caller authority : Abandoning")
		actualReply(message, "We apologize, however we do not condone peasants controlling the flow of the games.")
		return
	end
	if not message.mentionedUsers or #message.mentionedUsers < 1 then
		log("Insufficient/invalid number of participants : Abandoning")
		actualReply(message, "You need to ping all participants")
		return
	end
	for usr in message.mentionedUsers:iter() do
		if usr.bot then
			log("Found a bot amongst participants : Abandoning")
			actualReply(message, "I do not play games with you, human.")
			return
		end
	end
	log("Guard-clauses passed : Proceeding with participant initiation")

	local times = 1
	if splitArguments(message.content) ~= message.mentionedUsers:count() + 1 then
		times = tonumber(splitArguments(message.content)[2]) or 1
	end
	local participants = {}
	local participantNames = {}
	
	for p in message.mentionedUsers:iter() do
		--table.insert(participants, p.mentionString)
		table.insert(participants, p.id)
		participantNames[p.id] = p.mentionString
	end

	local matchupPairs = {} -- The current pairs
	local finalPairUps = "# **Matchups**\n***For this session* ***\n\n"
	local sets = {} -- Each set is an evenly matched and calculated set of match-ups
	local chanceLimit = (8*times)+10 -- The maximum amount of times a repeated matchup is to be reshuffled
	local chanceCurrent = 1
	local uniqueMatchups = {}
	
	for x=1, times, 1 do
		chanceCurrent = 1
		::loopRedo::
		if chanceCurrent >= chanceLimit then
			goto endOfLoop
		end
		if x~=1 then
			chanceCurrent = chanceCurrent+1
		end
		actualReply(message, ""..chanceCurrent)
		participants = shuffleTable(participants)
		for i=1, #participants, 2 do
			if participants[i+1] then
				local address = keyPairMake(participants[i], participants[i+1])
				if uniqueMatchups[address] then
					goto loopRedo
				else
					table.insert(matchupPairs, {participants[i], participants[i+1]})
					uniqueMatchups[address] = true
				end
			else
				table.insert(matchupPairs, {participants[i]})
			end
		end
		
		if #participants%2 == 0 then
			goto endOfLoop
		end

		-- Shift all participants by 1 space and attach the old matchups, basically making the matchups even
		participants = shiftTable(participants)
		table.insert(matchupPairs[#matchupPairs], participants[#participants])
		
		if uniqueMatchups[keyPairMake(matchupPairs[#matchupPairs][1], matchupPairs[#matchupPairs][2])] then
			matchupPairs[#matchupPairs] = nil
			goto loopRedo
		else
			uniqueMatchups[keyPairMake(matchupPairs[#matchupPairs][1], matchupPairs[#matchupPairs][2])] = true
		end
		
		for i=#participants-1, 1, -2 do
			local address = keyPairMake(participants[i], participants[i-1])
			if uniqueMatchups[address] then
				goto loopRedo
			else
				table.insert(matchupPairs, {participants[i], participants[i-1]})
				uniqueMatchups[address] = true
			end
		end
		
		::endOfLoop::
		chanceCurrent = 0
		table.insert(sets, matchupPairs)
		matchupPairs = nil or {}
	end
	
	log("Adding match-ups")
	for index, set in ipairs(sets) do
		finalPairUps = finalPairUps.."**Bracket "..index..":** \n"
		for _, pair in ipairs(set) do
			local pairUpStr = participantNames[pair[1]].." **VS** "..participantNames[pair[2]].."\n"
			finalPairUps = finalPairUps..pairUpStr
		end
	end
	log("Displaying match-ups")
	actualReply(message, finalPairUps)
	log("<SUCCESSFULL EXECUTION> matchup")
end

return fs
