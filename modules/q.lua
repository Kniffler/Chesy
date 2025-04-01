-- Function table to return
local fs = {}

function fs.execute(message, stats)
	if not hasAdmin(message) then return end
	message:delete()
	
	local args = splitArguments(message.content)
	local text = table.concat(args, " ", 2)
	if text == "" then return end
	log("Impersonating: "..message.author.username.." -> "..text)
	
	message.channel:send {
		content = text,
		reference = message.referencedMessage and { message = message.referencedMessage, mention = false } or nil,
	}
end

return fs
