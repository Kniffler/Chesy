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

	for p in message.mentionedUsers:iter() do
		table.insert(participants, p.mentionString)
	end

	local matchupPairs = {}
	local finalPairUps = "# ***Matchups***\n***For this session****\n\n"
	
	log("Participant initiation complete : Shuffling")

	participants = shuffleTable(participants)
	-- TODO:
	-- Make this work
	for i=1, times, 1 do
		log("Testing for display pair-up : i="..i)
		for k=1, #participants, 2 do
			if participants[k+1] then
				table.insert(matchupPairs, {participants[k], participants[k+1]})
			else
				table.insert(matchupPairs, {participants[k]})
			end
		end

		if #participants%2 == 0 then
			goto endOfLoop
		end
		
		-- Shift all participants by 1 space and attach the old matchups, basically making the matchups even
		local firstPart = participants[1]
		for k=1, #participants-1 do
			participants[k] = participants[k+1]
		end
		participants[#participants] = firstPart
		
		table.insert(matchupPairs[#matchupPairs], participants[#participants])
		for k=#participants-1, 1, -2 do
			table.insert(matchupPairs, {participants[k], participants[k-1]})
		end
		
		::endOfLoop::
	end
	log("Adding match-ups")
	for _, pair in ipairs(matchupPairs) do
		local pairUpStr = pair[1].." **VS** "..pair[2].."\n"
		finalPairUps = finalPairUps..pairUpStr
	end
	log("Displaying match-ups")
	actualReply(message, finalPairUps)
	log("<SUCCESSFULL EXECUTION> matchup")
end

return fs
