-- Function table to return
local fs = {}

function fs.execute(message, stats)
	log("\"\\matchup\" DETECTED : Proceeding with guard-clauses...")
	
	if not hasAdmin(message) then
		log("Insufficient caller authority : Abandoning")
		actualReply(message, "We apologize, however we do not condone peasants controlling the flow of the club.")
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
	log("Guard-clauses passed : Proceeding with shuffle")
	
	local participants = {}

	for p in message.mentionedUsers:iter() do
		table.insert(participants, p.mentionString)
	end

	local matchupPairs = {}
	local finalPairUps = "# ***Matchups***\nFor this session*\n\n"

	participants = shuffleTable(participants)

	for i=1, #participants, 2 do
		if participants[i+1] then
			table.insert(matchupPairs, {participants[i], participants[i+1]})
		else
			table.insert(matchupPairs, {participants[i]})
		end
	end
	log("Testing for display pair-up")

	if #participants%2 == 0 then
		for _, pair in pairs(matchupPairs) do
			local pairUpStr = pair[1].." **VS** "..pair[2].."\n"
			finalPairUps = finalPairUps..pairUpStr
		end
		log("Even number of participants : Displaying")
		actualReply(message, finalPairUps)
		log("<SUCCESSFULL EXECUTION> matchup")
		return
	end
	log("Calculating odd match-ups...")
	
	-- Shift all participants by 1 space and attach the old matchups, basically making the matchups even
	local firstPart = participants[1]
	for i=1, #participants-1 do
		participants[i] = participants[i+1]
	end
	participants[#participants] = firstPart
	
	table.insert(matchupPairs[#matchupPairs], participants[#participants])
	for i=#participants-1, 1, -2 do
		table.insert(matchupPairs, {participants[i], participants[i-1]})
	end

	for _, pair in ipairs(matchupPairs) do
		local pairUpStr = pair[1].." **VS** "..pair[2].."\n"
		finalPairUps = finalPairUps..pairUpStr
	end
	log("Displaying odd match-ups")
	actualReply(message, finalPairUps)
	log("<SUCCESSFULL EXECUTION> matchup")
end

return fs
