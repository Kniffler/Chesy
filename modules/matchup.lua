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
	if times > #participants-1 then
		log("Invalid participation times : Abandoning")
		actualReply(message, "I cannot repeat this many times for such a limited set of people")
		return
	end
	if #participants%2~=0 and times%2~=0 then
		log("Uneven distributent count : Abandoning")
		actualReply(message, "Letting an uneven amount of people play, with an uneven amount of times each, is not mathematically feasible in chess.")
		return
	end
	
	log("Guard-clauses passed : Proceeding with participant initiation")

	local finalPairUps = "# **Matchups**\n***For this session* ***\n\n"

 	log("Generating possible matches for this line-up")
 	participants = shuffleTable(participants)
	local allMatches = {}
	local participantMapper = {}
	
	for i=1, #participants, 1 do
		if not participants[i+1] then
			break
		end
		
		for k=i+1, #participants, 1 do
			local key = makeKey(participants[i], participants[k])
			allMatches[key] = {participants[i], participants[k]}
			
			participantMapper[participants[i]] = participantMapper[participants[i]] or {}
			participantMapper[participants[k]] = participantMapper[participants[k]] or {}
			
			table.insert(participantMapper[participants[i]], participants[k])
			table.insert(participantMapper[participants[k]], participants[i])
		end
	end

	log("Filtering using chain-method")
	local finalMatches = {}
	local lightMapper = trueCopy(participantMapper)
	local hardMapper = trueCopy(participantMapper)
	
	for i=1, times, 1 do 
	--[[
		It took me a bit to understand, but the basics is that when running just once,
		the algorithm gives 2 games per person - this cannot be changed without changing the algorithm.
		Another downside of this is that people can only play in multiples of 2, so 2, 4 or 6 games per person
		with no option of going between, like at 9 players, where having 1 game per person would make 9 games,
		but this algorithm would give 2 games per player, so 18 games. Inefficient but works for now.
		
	]]
		lightMapper = trueCopy(hardMapper)
		local firstIterant = participants[math.random(#participants)]
		local currentIterant = firstIterant
		log("First iterant: "..firstIterant)
		log("Current iterant: "..currentIterant)
		log("Moving into body for-loop")
		for k=1, #participants, 1 do 
			if k%2==0 then
				goto loopEnd
			end
			log("Current iterant: "..currentIterant)
			local nextIterantIndex = math.random(#lightMapper[currentIterant])
			log("Next iterant index: "..nextIterantIndex)
			local nextIterant = lightMapper[currentIterant][nextIterantIndex] or firstIterant
			log("Next iterant: "..(nextIterant or "NIL"))
			
			local adderKey = makeKey(currentIterant, nextIterant)
			log("Changing hardMapper")
			hardMapper[currentIterant] = removeArrayValue(hardMapper[currentIterant], nextIterant)
			hardMapper[nextIterant] = removeArrayValue(hardMapper[nextIterant], currentIterant)
			
			log("Changing lightMapper")
			lightMapper = removeValueFromDictArrays(lightMapper, currentIterant)

			finalMatches[adderKey] = allMatches[adderKey]
			currentIterant = nextIterant
			::loopEnd::
		end
	end
	--[[ A past idea (and likely bad) on how to make the matchups able to give 1 game per person
	for i=1, #finalMatches, 2 do
		finalMatches[i] = nil
	end
	]]
 	log("Calculating display string")

	-- I don't like the word index so this guy is called dex from now on
	for dex, pair in pairs(finalMatches) do
		local pairUpStr = participantNames[pair[1]].." **VS** "..participantNames[pair[2]].."\n"
		finalPairUps = finalPairUps..pairUpStr
	end
	
	log("Displaying match-ups")
	actualReply(message, finalPairUps)
	log("<SUCCESSFULL EXECUTION> matchup")

end

return fs
