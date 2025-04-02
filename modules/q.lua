-- Function table to return
local fs = {}

function fs.execute(message)
	local channelLinks = require('channelLinks')
	local args = splitArguments(message.content)
	local specify = args[2]
	local guild = message.guild.id
	local channelID = message.channel.id

	if not channelID or not guild then
		log("No values for impersonating :(")
		return
	end
	if specify == "register" then
		if not #args == 3 then log("Inaccurate argument count for register : Abandoning")
		actualyReply(message, "Please provide the proper amount of arguments") return end

		local origin = args[3]
		local control = message.channel.id
		if not channelLinks[guild] then channelLinks[guild] = {} end

		channelLinks[guild][origin.."o"] = control
		channelLinks[guild][control.."c"] = origin
		
		saveChannels(channelLinks)
		actualReply(message, "Registered link. New messages will now appear here")
		
	elseif specify == "unregister" then
		if not #args == 2 then log("Inaccurate argument count for unregister : Abandoning")
		actualyReply(message, "Please provide the proper amount of arguments") return end

		if not channelLinks[guild][tostring(channelID).."c"] then
			log("Channel has no entry or is nil somehow")
			actualyReply(message, "You have no link to disengage, try running this command again in the control channel")
			return
		end
		channelLinks[guild][(channelLinks[guild][channelID.."c"]).."o"] = nil
		channelLinks[guild][channelID.."c"] = nil
		
		saveChannels(channelLinks)
		actualReply(message, "Unregistered link. New messages will NEVER appear here")
		
	elseif specify == "unregister-guild" then
		if not #args == 2 then log("Inaccurate argument count for unregister-guild : Abandoning")
		actualyReply(message, "Please provide the proper amount of arguments") return end

		channelLinks[message.guild.id] = nil

		saveChannels(channelLinks)
		actualReply(message, "Unregistered guild.")
		
	end
	return channelLinks
end

return fs
