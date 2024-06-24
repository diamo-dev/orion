script.Disabled = true

local Client = script:WaitForChild("Client"):Clone()

game:GetService("Debris"):AddItem(script, 0)

local Remote = Instance.new("RemoteEvent")
Remote.Name = "Orion"
Remote.Parent = game:GetService("ReplicatedStorage")

local Value = Instance.new("ObjectValue")
Value.Name = "Remote"
Value.Value = Remote
Value.Parent = Client

local DataStore = game:GetService("DataStoreService"):GetDataStore("Orion")

local MessagingService = game:GetService("MessagingService")

local User = {}

local Conversation = {}

local Players = game:GetService("Players")

local HttpService = game:GetService("HttpService")

local MaxTries = 10
local Delay = 0.5
local unpack = table.unpack or unpack

local function Try(Callback, ...)
	local Tries, Success, Values = 0, false, {}
	repeat
		Success, Values = pcall(function(...)
			return {Callback(...)}
		end, ...)
		if not Success then
			Values = {Values}
			Tries += 1
			if Tries < MaxTries then
				wait(Delay)
			end
		end
	until Success or Tries >= MaxTries
	return Success, unpack(Values)
end

local Callbacks = {}

local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId

local function Fire(ID, From, Key, Data)
	local Player = Players:GetPlayerByUserId(ID)
	if Player then
		local Callbacks = Callbacks[Key]
		local Otherwise = Callbacks[2]
		local InConversation = User:Get(ID).Active == From
		if not Otherwise or InConversation then
			Callbacks[1](Player, Data, From, ID, InConversation)
		elseif Otherwise then
			Otherwise(Player, Data, From, ID)
		end
	else
		local Success, _, Error, UserPlaceId = pcall(function()
			return TeleportService:GetPlayerPlaceInstanceAsync(ID)
		end)
		if not Success or Error or UserPlaceId ~= PlaceId then
			local Data = HttpService:JSONEncode({ID = ID, From = From, Data = Data})
			Try(function()
				MessagingService:PublishAsync(Key, Data)
			end)
		end
	end
end

local function Subscribe(Key, Callback, Otherwise)
	Callbacks[Key] = {Callback, Otherwise}
	local function Function(Message)
		local Data = HttpService:JSONDecode(Message.Data)
		local ID = Data.ID
		local Player = Players:GetPlayerByUserId(ID)
		local From = Data.From
		if Player then
			local InConversation = User:Get(ID).Active == From
			if not Otherwise or InConversation then
				Callback(Player, Data.Data, From, ID, InConversation)
			elseif Otherwise then
				Otherwise(Player, Data.Data, From, ID)
			end
		end
	end
	Try(function()
		MessagingService:SubscribeAsync(Key, Function)
	end)
end

local function GetBytes(Combinations, Safe)
	local Possible = 127
	if Safe then
		Possible = 95
	end
	return math.max(math.ceil(math.log(Combinations, Possible)), 1)
end
local function NumberEN(Number, Safe)
	Number = math.abs(Number)
	local Possible, Exclusion = 127, 1
	if Safe then
		Possible, Exclusion = 95, 33
	end
	local Bytes = GetBytes(Number, Safe)
	local Chars = {}
	for Index_ = 1, Bytes do
		local Index = Bytes - Index_
		local Power = Possible ^ Index
		local Byte = math.floor(Number / Power)
		Number -= Byte * Power
		Chars[Index_] = string.char(Byte + Exclusion)
	end
	return table.concat(Chars, "")
end
local function NumberDE(String, Safe)
	local Possible, Exclusion = 127, 1
	if Safe then
		Possible, Exclusion = 95, 33
	end
	local Bytes = string.len(String)
	local Number = 0
	for Index = 1, Bytes do
		Number += (string.byte(string.sub(String, Index, Index)) - Exclusion) * Possible ^ (Bytes - Index)
	end
	return Number
end
local NUL = "\0"

local function tick()
	return DateTime.now().UnixTimestamp
end

do
	local Conversations = {}

	local function BoolEN(Bool)
		if Bool then
			return "t"
		end
		return "f"
	end
	local function BoolDE(String)
		if String == "t" then
			return true
		end
		return false
	end

	local function ShallowClone(Table)
		local Clone = {}
		for Key, Value in pairs(Table) do
			Clone[Key] = Value
		end
		return Clone
	end

	local function GetKey(IDs)
		IDs = ShallowClone(IDs)
		table.sort(IDs, function(A, B)
			return A < B
		end)
		for Index, ID in ipairs(IDs) do
			IDs[Index] = tostring(ID)
		end
		return table.concat(IDs, "/")
	end

	local function MessageEN(Message)
		return NumberEN(Message.Author)..NUL..NumberEN(Message.Timestamp)..NUL..BoolEN(Message.Notified)..NUL..BoolEN(Message.Read)..NUL..string.gsub(Message.Contents, NUL, "")
	end
	local function MessageDE(String)
		local Items = string.split(String, NUL)
		local Message = {Author = NumberDE(Items[1]), Timestamp = NumberDE(Items[2]), Notified = BoolDE(Items[3]), Read = BoolDE(Items[4])}
		for _ = 1, 4 do
			table.remove(Items, 1)
		end
		Message.Contents = table.concat(Items, NUL)
		return Message
	end

	Subscribe("Message", function(Player, Message, From, ID)
		local Data = MessageDE(Message)
		Remote:FireClient(Player, "Message", Data)
		Conversation:Get({From, ID}):Insert(Data)
		Fire(From, ID, "Read")
	end, function(Player, Message, From, ID)
		if Conversations[GetKey({From, ID})] then
			Conversation:Get({From, ID}):Insert(MessageDE(Message))
		end
		if not User:Get(ID):Find(From) then
			Remote:FireClient(Player, "Add", From, User:Get(From).Name, "New Message")
		end
		Remote:FireClient(Player, "Unread", From)
		Fire(From, ID, "Notified")
	end)
	Subscribe("Read", function(Player, Message, From, ID, InConversation)
		Remote:FireClient(Player, "Read", From)
		if InConversation then
			User:Get(ID):Read(Conversation:Get({From, ID}))
		end
	end)
	Subscribe("Notified", function(Player, Message, From, ID, InConversation)
		Remote:FireClient(Player, "Notified", From)
		if InConversation then
			User:Get(ID):Notified(Conversation:Get({From, ID}))
		end
	end)

	local Seperator = NUL..NUL..NUL
	local function ConversationEN(Messages, Timestamp)
		local String = ""
		for Index, Message in ipairs(Messages) do
			local Part = MessageEN(Message)
			if Index > 1 then
				String = String..NUL..NUL..Part
			else
				String = Part
			end
		end
		if Timestamp then
			String = NumberEN(Timestamp)..Seperator..String
		end
		return String
	end
	local function ConversationDE(String)
		local Messages, Timestamp = {}, nil
		if String then
			if string.match(String, Seperator) then
				Timestamp, String = unpack(string.split(String, Seperator))
				Timestamp = NumberDE(Timestamp)
			end
			for _, String in ipairs(string.split(String, NUL..NUL)) do
				pcall(function()
					table.insert(Messages, MessageDE(String))
				end)
			end
		end
		return Messages, Timestamp
	end

	function Conversation:Encode(Data: table, Timestamp: number?)
		return ConversationEN(Data, Timestamp)
	end
	function Conversation:Decode(String: string)
		return ConversationDE(String)
	end 

	function Conversation:Get(IDs: table)
		local Key = GetKey(IDs)

		local Existing = Conversations[Key]
		if Existing then
			return Existing
		end

		local API = {}

		Conversations[Key] = API

		local Data, Timestamp

		Try(function()
			Data = DataStore:GetAsync(Key)
		end)

		Data, Timestamp = ConversationDE(Data or "")

		function API:Update(Callback)
			local function Function(Old)
				local New = Callback(Old)
				Data, Timestamp = ConversationDE(New)
				return New
			end
			Try(function()
				DataStore:UpdateAsync(Key, Function)
			end)
		end

		function API:New(Author: number, Contents: string)
			if not table.find(IDs, Author) then
				return error("Author is not in conversation!")
			end
			if tostring(string.gsub(tostring(string.gsub(Contents, NUL, "")), "%s", "")) == "" then
				return error("Not big enough!")
			end
			Timestamp = tick()
			local Data = {Author = Author, Timestamp = Timestamp, Read = false, Notified = false, Contents = Contents}
			local Encoded = MessageEN(Data)
			for _, ID in ipairs(IDs) do
				if ID ~= Author then
					Fire(ID, Author, "Message", Encoded)
				end
			end
			self:Update(function(Old)
				local Conversation = ConversationDE(Old or "")
				table.insert(Conversation, Data)
				return ConversationEN(Conversation, Timestamp)
			end)
		end

		function API:Get(Self: number)
			local Clone = {}
			local Timestamp = Timestamp
			if not Timestamp then
				local Last = Data[#Data]
				if Last and Last.Author == Self and not Last.Notified and not Last.Read then
					Timestamp = Last.Timestamp
				end
			end
			for _, AMessage in ipairs(Data) do
				local Message = ShallowClone(AMessage)
				if Message.Author ~= Self then
					if not Message.Read then
						Timestamp = Message.Timestamp
					end
					Message.Notified = nil
				end
				table.insert(Clone, Message)
			end
			return Clone, Timestamp
		end

		function API:Data()
			return Data
		end

		function API:Insert(Message: table)
			if not table.find(IDs, Message.Author) then
				return error("Author is not in conversation!")
			end
			table.insert(Data, Message)
		end

		return API
	end
end

do
	local Users = {}

	local function FormatName(Name)
		local LegalCharacters = tostring(string.gsub(Name, "[^%a']+", ""))
		return tostring(string.gsub(string.sub(LegalCharacters, 1, math.min(#LegalCharacters, 50)), "%a+", function(Match)
			local Length = #Match
			if Length < 2 then
				return string.upper(Match)
			else
				return string.upper(string.sub(Match, 1, 1))..string.lower(string.sub(Match, 2, Length))
			end
		end))
	end

	local function PeopleEN(People)
		local Strings = {}
		for _, ID in ipairs(People) do
			table.insert(Strings, NumberEN(ID))
		end
		return table.concat(Strings, NUL)
	end
	local function PeopleDE(String)
		local People = {}
		for _, String in ipairs(string.split(String, NUL)) do
			table.insert(People, NumberDE(String))
		end
		return People
	end

	local function UserEN(Data)
		local String = Data.Name
		local People = PeopleEN(Data.People)
		if People ~= "" then
			String = String..NUL..People
		end
		return String
	end
	local function UserDE(String)
		local Strings = string.split(String, NUL)
		local Data = {Name = table.remove(Strings, 1)}
		if #Strings > 0 then
			Data.People = PeopleDE(table.concat(Strings, NUL))
		else
			Data.People = {}
		end
		return Data
	end

	function User:Create(ID: number, Name: string)
		Name = FormatName(Name)
		if #Name < 1 then
			return error("Invalid name!")
		end
		local Encoded = UserEN({Name = Name, People = {}})
		local Key = tostring(ID)
		local Success = Try(function()
			DataStore:SetAsync(Key, Encoded)
		end)
		if Success then
			return User:Get(ID)
		end
	end

	function User:Get(ID: number)
		local Key = tostring(ID)

		local Success, Data = Try(function()
			return DataStore:GetAsync(Key)
		end)
		if not Success then
			return error(Data)
		elseif not Data then
			return error("Orion user not found!")
		end

		local Existing = Users[ID]
		if Existing then
			return Existing
		end

		local API = {}

		Users[ID] = API

		local Decoded = UserDE(Data)

		local Name = Decoded.Name

		API.Name = Name

		local People = Decoded.People
		local Current = PeopleEN(People)

		local function UpdatePeople()
			pcall(function()
				People = UserDE(DataStore:GetAsync(Key)).People
			end)
		end

		function API:Person(User: number)
			if User == ID then
				return error("Cannot add self to people list!")
			end
			UpdatePeople()
			local Index = table.find(People, User)
			if Index then
				table.remove(People, Index)
			end
			table.insert(People, 1, User)
			local Encoded = PeopleEN(People)
			if Current ~= Encoded then
				local Encoded = UserEN({Name = Name, People = People})
				Try(function()
					DataStore:SetAsync(Key, Encoded)
				end)
			end
		end
		function API:Find(User: number)
			if User == ID then
				return error("Self cannot be in people list!")
			end
			UpdatePeople()
			if table.find(People, User) then
				return true
			else
				return false
			end
		end

		function API:Notified(Conversation_: table, Data: table)
			Conversation_:Update(function(Old)
				local Data_, Timestamp = Conversation:Decode(Old)
				local Last = Data_[#Data_]
				if Last then
					if Last.Author == ID then
						if Last.Read then
							Data.Status = "Read"
						elseif Last.Notified then
							Data.Status = "Notified"
						else
							Data.Status = "Sent"
						end
					else
						if Last.Read then
							Data.Status = "Recieved"
						elseif not Last.Notified then
							Timestamp = tick()
						end
					end
					for _, Message in ipairs(Data_) do
						if Message.Author ~= ID and not Message.Read then
							if Data then
								Data.Status = "New Message"
							end
							Message.Notified = true
						end
					end
				end
				return Conversation:Encode(Data_, Timestamp)
			end)
		end

		local function GetData(ID_)
			local Data = {ID = ID_, Name = User:Get(ID_).Name, Status = "Conversation Empty"}
			local Conversation = Conversation:Get({ID, ID_})
			local _, Timestamp = Conversation:Get(ID)
			Data.Timestamp = Timestamp
			API:Notified(Conversation, Data)
			Fire(ID_, ID, "Notified")
			return Data
		end
		function API:Status(ID_)
			if ID_ == ID then
				return error("Conversation with self cannot exist!")
			end
			return GetData(ID_).Status
		end

		function API:Others()
			local List = {}
			for _, ID_ in ipairs(People) do
				if ID_ ~= ID then
					table.insert(List, GetData(ID_))
				end
			end
			return List
		end

		function API:Read(Conversation_: table)
			Conversation_:Update(function(Old)
				local Data, Timestamp = Conversation:Decode(Old or "")
				for _, Message in ipairs(Data) do
					if Message.Author ~= ID then
						if not Message.Read then
							Timestamp = tick()
						end
						Message.Read = true
					end
				end
				return Conversation:Encode(Data, Timestamp)
			end)
		end

		function API:Get(Key: number)
			if Key == ID then
				return error("Cannot get messages to self!")
			end
			local Success, Error = pcall(function()
				return User:Get(Key)
			end)
			if not Success then
				return error(Error)
			end
			self.Active = Key
			local Conversation_ = Conversation:Get({ID, Key})
			local Data, Timestamp = Conversation_:Get(ID)
			self:Read(Conversation_)
			Fire(Key, ID, "Read")
			return Data, Timestamp
		end

		function API:Send(Message: string, To: number)
			if To == ID then
				return error("Cannot send message to self!")
			end
			local Success, Recipiant = pcall(function()
				return User:Get(To)
			end)
			if not Success then
				return error(Recipiant)
			end
			Conversation:Get({ID, To}):New(ID, Message)
			self:Person(To)
			Recipiant:Person(ID)
		end

		function API:Add(Person: number)
			if table.find(People, Person) then
				return error("User already added!")
			end
			local Success, Error = pcall(function()
				return User:Get(Person)
			end)
			if not Success then
				return error(Error)
			end
			self:Person(Person)
		end

		function API:Exit()
			self.Active = nil
		end

		return API
	end
end

Remote.OnServerEvent:Connect(function(Player, Key, ID, Message)
	local UserId = Player.UserId
	if Key == "Created" then
		local Success, User = pcall(function()
			return User:Get(UserId)
		end)
		local Name = Success and User.Name
		Remote:FireClient(Player, "Created", Success, Name)
	else
		local Success = pcall(function()
			local User_ = User
			local User = User:Get(UserId)
			if Key == "Get People" then
				Remote:FireClient(Player, "People", User:Others())
			elseif Key == "Add" then
				local ID = Players:GetUserIdFromNameAsync(ID)
				User:Add(ID)
				Remote:FireClient(Player, "Add", ID, User_:Get(ID).Name, User:Status(ID))
			elseif Key == "Get" then
				local Data, Timestamp = User:Get(ID)
				Remote:FireClient(Player, ID, Data, Timestamp)
			elseif Key == "Send" then
				User:Send(Message, ID)
			elseif Key == "Exit" then
				User:Exit()
			end
		end)
		pcall(function()
			if not Success and Key == "Create" then
				User:Create(UserId, ID)
			end
		end)
	end
end)

local function Load(Player)
	local Client = Client:Clone()
	Client.Parent = Player:WaitForChild("PlayerGui")
	Client.Disabled = false
end

for _, APlayer in ipairs(Players:GetPlayers()) do
	Load(APlayer)
end

Players.PlayerAdded:Connect(Load)
