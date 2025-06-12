-- Function table to return
local fs = {}

function fs.execute(message, stats)
	log("\"\\matchup\" DETECTED : Proceeding with guard-clauses...")
	
	if not hasAdmin(message) then
		log("Insufficient caller authority : Abandoning")
		actualReply(message, "We apologize, however we do not condone peasants controlling the flow of the games.")
		return
	end
	if not message.mentionedUsers or #message.mentionedUsers < 3 then --Doing a smart here, as my fancy formula fails with 2 people. And luckily 2 people is an obvious case
		log("Insufficient/invalid number of participants : Abandoning")
		actualReply(message, "Excuse me, how the heck do you expect me to match up "..(#message.mentionedUsers or "0").." people??")
		return
	end
	for usr in message.mentionedUsers:iter() do
		if usr.bot then
			log("Found a bot amongst participants : Abandoning")
			actualReply(message, "I do not play games with you, human.")
			return
		end
	end

	log("First clauses passed : Moving onto participant initiation and GPP prediction")
	-- GPP = Games Per Person
	
	local participants = {}
	local participantNames = {}
	
	for p in message.mentionedUsers:iter() do --	Simply iterate over all mentioned users and get their IDs
		table.insert(participants, p.id)
		participantNames[p.id] = p.mentionString --	Store user mentionStrings in dict. because I have no way of getting them another way later in the code
	end

	local finalPairUps = "# **Matchups:**\n"
	local times = math.min(#participants-1, 3)
	log("Automatic prediction: "..math.min(#participants-1, 3))
	
	if #splitArguments(message.content) ~= message.mentionedUsers:count() + 1 then
		times = tonumber(splitArguments(message.content)[2]) or math.min(#participants-1, 3)
	end
	if #participants%2~=0 and times%2~=0 then
		log("Uneven distributent count : Correcting")
		if times+1 <= #participants-1 then
			times = times+1
		elseif times-1 > 1 then
			times = times-1
		else
			log("Fancy adjustment failed : Abandoning")
			actualReply(message, "By total prediction and expectation, my fancy internal mathematics failed.\nPlease specify the amount of games-per-person manually")
			return
		end
	end
	if times > #participants-1 then
		log("Invalid participation times : Abandoning")
		actualReply(message, "I cannot repeat this many times for such a limited set of people")
		return
	end
	
	log("Guard-clauses passed : Generating possible matches for this line-up")

 	participants = shuffleTable(participants)
	local allMatches = {}
	local allOrder = {}
	
	for i=1, #participants, 1 do
		if not participants[i+1] then break end

		for k=i+1, #participants, 1 do
			local key = makeKey(participants[i], participants[k])
			allMatches[key] = {participants[i], participants[k]}
			table.insert(allOrder, key)
		end
	end

	local matchOrder = {}
	--[[
		An array of keys to keep track of the order
		in sortedMatches to systematically remove excess matches 
	]]--
	local perMap = {}
	--[[
		An array of numbers that counts if every participant
		plays the correct amount of times
	]]--
	
	local repetition = 1
	local foundIncorrect = false
	
	repeat
		foundIncorrect = false
		matchOrder = {}
		perMap = {}
		log("Filtering using remove count : Attempt - "..repetition)

		
		allOrder = shuffleTable(allOrder)
		if #participants-1 == times then
			log("Amount of match-ups is given : Using efficiency skip")
			matchOrder=allOrder
			break
		end
		for i=1, #allOrder, 1 do 
			perMap[allMatches[allOrder[i]][1]] = perMap[allMatches[allOrder[i]][1]] or 0
			perMap[allMatches[allOrder[i]][2]] = perMap[allMatches[allOrder[i]][2]] or 0

			local condition1 = (perMap[allMatches[allOrder[i]][1]] and perMap[allMatches[allOrder[i]][1]]) or false
			local condition2 = (perMap[allMatches[allOrder[i]][2]] and perMap[allMatches[allOrder[i]][2]]) or false
			if condition1 and perMap[allMatches[allOrder[i]][1]]+1 <= times and condition2 and perMap[allMatches[allOrder[i]][2]]+1 <= times then
				local key = allOrder[i]
				perMap[allMatches[allOrder[i]][1]] = perMap[allMatches[allOrder[i]][1]]+1
				perMap[allMatches[allOrder[i]][2]] = perMap[allMatches[allOrder[i]][2]]+1
				table.insert(matchOrder, key)
			end
		end
		for _, person in pairs(perMap) do
			if person~=times then
				repetition = repetition+1
				foundIncorrect = true
				break
			end
		end
	until not foundIncorrect
	
 	log("Calculating display string")
	

	-- I don't like the word index so this guy is called dex from now on
	for dex, key in ipairs(matchOrder) do
		local pair = allMatches[key]
		local pairUpStr = ((pair and participantNames[pair[1]]) or "NIL").." **VS** "..((pair and participantNames[pair[2]]) or "NIL").."\n"
		finalPairUps = finalPairUps..pairUpStr
	end
	
	if repetition==1 then -- Shut up, grammar is important
		finalPairUps = finalPairUps.."||*Calculated within 1 attempt*||"
	else 
		finalPairUps = finalPairUps.."||*Calculated within "..repetition.." attempts*||"
	end
	
	log("Displaying match-ups")
	actualReply(message, finalPairUps)
	log("<SUCCESSFULL EXECUTION> matchup")

end

return fs
