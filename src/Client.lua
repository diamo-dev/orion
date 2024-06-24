script.Disabled = true

local Remote = script:WaitForChild("Remote").Value

local Debris = game:GetService("Debris")
local function Destroy(Instance)
	pcall(function()
		Debris:AddItem(Instance, 0)
	end)
end

Destroy(script)

game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local function HideOthers(APlayer)
	if APlayer ~= Player then
		Destroy(APlayer)
	end
end
Players.PlayerAdded:Connect(HideOthers)
for _, APlayer in ipairs(Players:GetPlayers()) do
	HideOthers(APlayer)
end

local UserId = Player.UserId

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Orion"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local Created, Name
local Connection
Connection = Remote.OnClientEvent:Connect(function(Key, Created_, Name_)
	if Key == "Created" then
		Created, Name = Created_, Name_
		Connection:Disconnect()
	end
end)
Remote:FireServer("Created")
repeat
	wait()
until Created ~= nil

local Setup

local function Prompt(InstanceName, Text, Description, Placeholder, ButtonText)
	local Frame = Instance.new("Frame")
	Frame.Name = InstanceName
	Frame.BorderSizePixel = 0
	Frame.Size = UDim2.new(1, 0, 1, 0)
	Frame.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
	local List = Instance.new("UIListLayout")
	List.Name = "Layout"
	List.SortOrder = Enum.SortOrder.LayoutOrder
	List.HorizontalAlignment = Enum.HorizontalAlignment.Center
	List.VerticalAlignment = Enum.VerticalAlignment.Center
	List.Parent = Frame

	local Label = Instance.new("TextLabel")
	Label.Name = "Label"
	Label.LayoutOrder = 1
	Label.BackgroundTransparency = 1
	Label.Size = UDim2.new(1, -20, 0, 50)
	Label.TextColor3 = Color3.new(1, 1, 1)
	Label.Font = Enum.Font.GothamBold
	Label.TextSize = 50
	Label.TextWrapped = true
	Label.Text = Text
	Label.AutomaticSize = Enum.AutomaticSize.Y

	local Instructions = Label:Clone()
	Instructions.Name = "Instructions"
	Instructions.LayoutOrder = 2
	Instructions.Size = UDim2.new(1, -20, 0, 60)
	Instructions.Font = Enum.Font.Gotham
	Instructions.TextSize = 20
	local Constraint = Instance.new("UISizeConstraint")
	Constraint.Name = "Constaint"
	Constraint.MaxSize = Vector2.new(500, math.huge)
	Constraint.Parent = Instructions
	Instructions.Text = Description
	Instructions.AutomaticSize = Enum.AutomaticSize.Y

	Label.Parent = Frame
	Instructions.Parent = Frame

	local Entry = Instance.new("TextBox")
	Entry.Name = "Label"
	Entry.LayoutOrder = 3
	Entry.BackgroundTransparency = 1
	Entry.Size = UDim2.new(1, 0, 0, 70)
	Entry.TextColor3 = Color3.new(1, 1, 1)
	Entry.Font = Enum.Font.GothamBold
	Entry.TextSize = 50
	Entry.Text = ""
	Entry.PlaceholderColor3 = Color3.new(0.7, 0.7, 0.7)
	Entry.PlaceholderText = Placeholder
	Entry.ClearTextOnFocus = false
	Entry.Parent = Frame

	local Button = Instance.new("TextButton")
	Button.Name = ButtonText
	Button.LayoutOrder = 4
	Button.BorderSizePixel = 0
	Button.Size = UDim2.new(0, 200, 0, 50)
	Button.TextSize = 20
	Button.TextColor3 = Color3.new(1, 1, 1)
	Button.Font = Enum.Font.GothamBold
	Button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
	Button.Text = ButtonText

	local Corners = Instance.new("UICorner")
	Corners.Name = "Corners"
	Corners.CornerRadius = UDim.new(0, 5)
	Corners.Parent = Button

	Button.Parent = Frame
	
	return Frame, Entry, Button
end

if not Created then
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
	
	local Entry, Button
	
	Setup, Entry, Button = Prompt("Setup", "What is your name?", "Please use your real first name only. Please refrain from using emojis and custom fonts. You will not be able to change this later.", "Name", "Submit")
	Setup.ZIndex = 5
	
	Entry.FocusLost:Connect(function()
		Entry.Text = FormatName(Entry.Text)
	end)
	
	Button.Activated:Connect(function()
		local Input = FormatName(Entry.Text)
		if Input ~= "" then
			Name = Input
			Remote:FireServer("Create", Input)
			Created = true
		end
	end)
	
	Setup.Parent = ScreenGui
	
	repeat
		wait()
	until Name
end

local Loading = Instance.new("TextLabel")
Loading.Name = "Loading"
Loading.BorderSizePixel = 0
Loading.ZIndex = 4
Loading.Size = UDim2.new(1, 0, 1, 0)
Loading.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
Loading.TextColor3 = Color3.new(1, 1, 1)
Loading.Font = Enum.Font.Gotham
Loading.TextSize = 50
Loading.RichText = true
Loading.TextWrapped = true
Loading.Text = "Welcome to Orion,\n<b>"..Name.."</b>"
Loading.Parent = ScreenGui
Destroy(Setup)
local Frame = Instance.new("ScrollingFrame")
Frame.Name = "Orion"
Frame.BorderSizePixel = 0
Frame.Size = UDim2.new(1, 0, 1, 0)
Frame.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
Frame.ScrollingDirection = Enum.ScrollingDirection.Y
Frame.ScrollBarThickness = 0
Frame.ScrollBarImageTransparency = 1
local List = Instance.new("UIListLayout")
List.Name = "List"
List.SortOrder = Enum.SortOrder.LayoutOrder
List.Parent = Frame
local RenderStepped = game:GetService("RunService").RenderStepped
RenderStepped:Connect(function()
	Frame.CanvasSize = UDim2.new(1, 0, 0, List.AbsoluteContentSize.Y)
end)

local Chat = Instance.new("Frame")
Chat.Name = "Chat"
Chat.BorderSizePixel = 0
Chat.Size = UDim2.new(1, 0, 1, 0)
Chat.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
Chat.Position = UDim2.new(1, 0, 0, 0)
Chat.ClipsDescendants = true

local TweenService = game:GetService("TweenService")
local function Tween(...)
	local Tween = TweenService:Create(...)
	Tween:Play()
	return Tween
end

local ChatInfo = TweenInfo.new(0.25)

local ChatClosed = true

local function Set(Offset)
	Tween(Chat, ChatInfo, {Position = UDim2.new(Offset, 0, 0, 0)})
	Tween(Frame, ChatInfo, {Position = UDim2.new(Offset - 1, 0, 0, 0)})
end

local ConversationID

local BackButton = Instance.new("TextButton")
BackButton.Name = "Back"
BackButton.BackgroundTransparency = 1
BackButton.Size = UDim2.new(0, 115, 0, 50)
BackButton.Position = UDim2.new(0, 0, 0, 40)
BackButton.TextColor3 = Color3.new(1, 1, 1)
BackButton.TextSize = 30
BackButton.Font = Enum.Font.Gotham
BackButton.Text = "‹ Back"
BackButton.Activated:Connect(function()
	if not ChatClosed then
		ChatClosed = true
		ConversationID = nil
		Remote:FireServer("Exit")
		Set(1)
	end
end)
BackButton.Parent = Chat

local ChatIcon = Instance.new("ImageLabel")
ChatIcon.Name = "Icon"
ChatIcon.BackgroundTransparency = 1
ChatIcon.Size = UDim2.new(0, 40, 0, 40)
ChatIcon.AnchorPoint = Vector2.new(1, 0)
ChatIcon.Position = UDim2.new(1, -5, 0, 45)
local function Round(Parent)
	local Corners = Instance.new("UICorner")
	Corners.Name = "Corners"
	Corners.CornerRadius = UDim.new(0.5, 0)
	Corners.Parent = Parent
end
Round(ChatIcon)
ChatIcon.Image = ""
ChatIcon.Parent = Chat

local ChatName = Instance.new("TextLabel")
ChatName.Name = "Name"
ChatName.BackgroundTransparency = 1
ChatName.Size = UDim2.new(1, -165, 0, 50)
ChatName.AnchorPoint = Vector2.new(1, 0)
ChatName.Position = UDim2.new(1, -50, 0, 40)
ChatName.TextColor3 = Color3.new(1, 1, 1)
ChatName.TextXAlignment = Enum.TextXAlignment.Right
ChatName.TextSize = 35
ChatName.Font = Enum.Font.GothamBold
ChatName.Text = ""
ChatName.Parent = Chat

local Scrolling = Frame:Clone()
Scrolling.Name = "Scrolling"
Scrolling.Size = UDim2.new(1, 0, 1, -170)
Scrolling.Position = UDim2.new(0, 0, 0, 90)

local ChatList = Scrolling:WaitForChild("List")

local ChatBar = Instance.new("Frame")

local function GetCanvasHeight()
	local Height = ChatList.AbsoluteContentSize.Y
	if Height > 0 then
		Height += 10
	end
	return Height
end

local function GetBottom(Height)
	return Vector2.new(0, math.max((Height or GetCanvasHeight()) - Scrolling.AbsoluteSize.Y, 0))
end

local function SetToBottom()
	Scrolling.CanvasPosition = GetBottom()
end

local function UpdateScrolling()
	local AtBottom = Scrolling.CanvasPosition.Y == GetBottom(Scrolling.CanvasSize.Y.Offset).Y
	Scrolling.Size = UDim2.new(1, 0, 1, -140 - ChatBar.AbsoluteSize.Y)
	Scrolling.CanvasSize = UDim2.new(1, -20, 0, GetCanvasHeight())
	if AtBottom then
		SetToBottom()
	end
end

do
	local Padding = Instance.new("UIPadding")
	Padding.Name = "Padding"
	Padding.PaddingTop = UDim.new(0, 10)
	Padding.Parent = Scrolling
	RenderStepped:Connect(UpdateScrolling)
end

local Outline = Instance.new("UIStroke")
Outline.Name = "Outline"
Outline.Color = Color3.new(0.2, 0.2, 0.2)
Outline.Parent = Scrolling

Scrolling.Parent = Chat

Chat.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.BackgroundTransparency = 1
Title.LayoutOrder = 1
Title.Size = UDim2.new(1, 0, 0, 80)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextYAlignment = Enum.TextYAlignment.Bottom
Title.Font = Enum.Font.GothamBold
Title.TextSize = 45
Title.Text = " Orion"
Title.Parent = Frame

local Add = Instance.new("TextButton")
Add.Name = "Add"
Add.BorderSizePixel = 0
Add.Size = UDim2.new(0, 30, 0, 30)
Add.Position = UDim2.new(1, -45, 1, -35)
Add.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
Add.TextColor3 = Color3.new(1, 1, 1)
Add.Font = Enum.Font.Gotham
Add.TextSize = 30
Add.Text = "+"
Round(Add)
Add.Parent = Title

local Adding = false

local AddMenu, AddEntry, Button = Prompt("Add", "Add...", "Please type the username of the user you want to add and press Add.", "Roblox", "Button")
Button.Text = "Close"
AddMenu.ZIndex = 2

AddMenu.Position = UDim2.new(0, 0, 1, 0)

local AddInfo = TweenInfo.new(0.3)
local function Return()
	if Adding then
		Adding = false
		local User = AddEntry.Text
		if User ~= "" then
			Remote:FireServer("Add", User)
		end
		Tween(AddMenu, AddInfo, {Position = UDim2.new(0, 0, 1, 0)})
	end
end

AddEntry:GetPropertyChangedSignal("Text"):Connect(function()
	if AddEntry.Text == "" then
		Button.Text = "Close"
	else
		Button.Text = "Add"
	end
end)
AddEntry.FocusLost:Connect(function(EnterPressed)
	if EnterPressed then
		Return()
	end
end)
Button.Activated:Connect(Return)

Add.Activated:Connect(function()
	if not Adding and ChatClosed then
		Adding = true
		AddEntry.Text = ""
		Tween(AddMenu, AddInfo, {Position = UDim2.new(0, 0, 0, 0)})
	end
end)

AddMenu.Parent = ScreenGui

local MaxMessageWidth = math.round(game:GetService("Workspace").CurrentCamera.ViewportSize.X * 0.6)

local TextService = game:GetService("TextService")

local NewMessageInfo = TweenInfo.new(0.5)
local StatusInfo = TweenInfo.new(0.5)

local NotifiedIndex, ReadIndex

local TotalIndex = 0

local function MakeMessage(Index, Data, IsNew)
	local Frame = Instance.new("Frame")
	Frame.Name = "Message"
	Frame.BackgroundTransparency = 1
	Frame.LayoutOrder = Index
	local Contents = Data.Contents
	local Size = TextService:GetTextSize(Contents, 20, Enum.Font.Gotham, Vector2.new(MaxMessageWidth, math.huge))
	local Height = Size.Y + 20
	Frame.Size = UDim2.new(1, 0, 0, 0)
	local Inner = Instance.new("Frame")
	Inner.Name = "Message"
	Inner.BorderSizePixel = 0
	Inner.BackgroundColor3 = Color3.new(0.95, 0.95, 0.95)
	local TimeData = DateTime.fromUnixTimestamp(Data.Timestamp):ToLocalTime()
	local Part, Hour = "AM", TimeData.Hour
	if Hour >= 12 then
		Part = "PM"
	end
	if Hour > 12 then
		Hour -= 12
	end
	if Hour == 0 then
		Hour = 12
	end
	local Minute = tostring(TimeData.Minute)
	local TimestampText = tostring(Hour)..":"..string.rep("0", 2 - #Minute)..Minute.." "..Part.." on "..tostring(TimeData.Month).."/"..tostring(TimeData.Day).."/"..tostring(TimeData.Year)
	local Width = math.max(Size.X, TextService:GetTextSize(TimestampText, 10, Enum.Font.Gotham, Vector2.new(1, 1) * math.huge).X)
	Inner.Size = UDim2.new(0, Width + 20, 0, Height)

	local Timestamp = Instance.new("TextLabel")
	Timestamp.Name = "Timestamp"
	Timestamp.BackgroundTransparency = 1
	Timestamp.Size = UDim2.new(1, -10, 0, 15)
	Timestamp.AnchorPoint = Vector2.new(1, 1)
	Timestamp.Position = UDim2.new(1, -10, 1, 0)
	Timestamp.TextColor3 = Color3.new(0.5, 0.5, 0.5)
	Timestamp.TextXAlignment = Enum.TextXAlignment.Right
	Timestamp.Font = Enum.Font.Gotham
	Timestamp.TextSize = 10
	Timestamp.Text = TimestampText

	local Corners = Instance.new("UICorner")
	Corners.Name = "Corners"
	Corners.CornerRadius = UDim.new(0, 5)
	Corners.Parent = Inner

	local AnchorPoint, Position, StartPosition

	local Text = Instance.new("TextLabel")
	if Data.Author == UserId then
		TotalIndex = Index
		if not IsNew then
			if Data.Read then
				ReadIndex = Index
				NotifiedIndex = nil
			elseif Data.Notified then
				NotifiedIndex = Index
			end
		end
		AnchorPoint, Position, StartPosition = Vector2.new(1, 0), UDim2.new(1, -10, 0, 0), UDim2.new(1, 0, 0, 0)
		local Info = Instance.new("Frame")
		Info.Name = "Status"
		Info.BackgroundTransparency = 1
		Info.Size = UDim2.new(0, 3, 1, 0)
		Info.AnchorPoint = Vector2.new(1, 0)
		Info.Position = UDim2.new(1, 0, 0, 0)
		Info.ClipsDescendants = true

		local InnerInfo = Instance.new("Frame")
		InnerInfo.Name = "Inner"
		InnerInfo.BorderSizePixel = 0
		InnerInfo.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
		InnerInfo.Size = UDim2.new(1, Corners.CornerRadius.Offset * 2, 1, 0)
		InnerInfo.AnchorPoint = Vector2.new(1, 0)
		InnerInfo.Position = UDim2.new(1, 0, 0, 0)
		Corners:Clone().Parent = InnerInfo
		InnerInfo.Parent = Info

		local Shown = true

		local function SetRead()
			InnerInfo.BackgroundColor3 = Color3.new(0, 0.6, 1)
		end

		if Data.Read then
			SetRead()
		elseif not Data.Notified then
			Info.Size = UDim2.new(0, 0, 1, 0)
			Shown = false
		end

		local function Show()
			if not Shown then
				Shown = true
				Tween(Info, StatusInfo, {Size = UDim2.new(0, 3, 1, 0)})
			end
		end

		local Connection = Remote.OnClientEvent:Connect(function(Key, ID)
			if ID == ConversationID then
				if Key == "Read" then
					Data.Read = true
					if Data.Notified then
						Tween(InnerInfo, StatusInfo, {BackgroundColor3 = Color3.new(0, 0.6, 1)})
					else
						SetRead()
						Show()
					end
					Data.Notified = true
				elseif Key == "Notified" then
					if not Data.Read then
						Data.Notified = true
						Show()
					end
				end
			end
		end)
		Frame.Destroying:Connect(function()
			Connection:Disconnect()
		end)
		Info.Parent = Inner
		Text.TextColor3 = Color3.new(0, 0, 0)
	else
		AnchorPoint, Position, StartPosition = Vector2.new(0, 0), UDim2.new(0, 10, 0, 0), UDim2.new(0, 0, 0, 0)
		Timestamp.AnchorPoint = Vector2.new(0, 1)
		Timestamp.Position = UDim2.new(0, 10, 1, 0)
		Timestamp.TextXAlignment = Enum.TextXAlignment.Left
		Inner.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
		Text.TextColor3 = Color3.new(1, 1, 1)
	end

	Timestamp.Parent = Inner

	local Goal = UDim2.new(1, 0, 0, Height + 10)

	if IsNew then
		Inner.AnchorPoint = Vector2.new(1, 0) - AnchorPoint
		Inner.Position = StartPosition
		Tween(Frame, NewMessageInfo, {Size = Goal})
		Tween(Inner, NewMessageInfo, {AnchorPoint = AnchorPoint, Position = Position})
	else
		Inner.AnchorPoint = AnchorPoint
		Inner.Position = Position
		Frame.Size = Goal
	end

	Text.Name = "Contents"
	Text.BackgroundTransparency = 1
	Text.Size = UDim2.new(1, -18, 1, -18)
	Text.Position = UDim2.new(0, 9, 0, 9)
	Text.TextXAlignment = Enum.TextXAlignment.Left
	Text.TextYAlignment = Enum.TextYAlignment.Top
	Text.Font = Enum.Font.Gotham
	Text.TextSize = 20
	Text.TextWrapped = true
	Text.Text = Contents
	Text.Parent = Inner
	Inner.Parent = Frame
	Frame.Parent = Scrolling
end

local function Center()
	UpdateScrolling()
	SetToBottom()
end

local function New(Data, IsNew)
	MakeMessage(#Scrolling:GetChildren() - 1, Data, IsNew)
end

ChatBar.Name = "Chat Bar"
ChatBar.BorderSizePixel = 0
ChatBar.Size = UDim2.new(1, -60, 0, 30)
ChatBar.AnchorPoint = Vector2.new(0, 1)
ChatBar.Position = UDim2.new(0, 10, 1, -40)
ChatBar.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
local Corners = Instance.new("UICorner")
Corners.Name = "Corners"
Corners.CornerRadius = UDim.new(0, 15)
Corners.Parent = ChatBar

local Entry = Instance.new("TextBox")
Entry.Name = "Entry"
Entry.BackgroundTransparency = 1
Entry.Size = UDim2.new(1, -20, 1, 0)
Entry.Position = UDim2.new(0, 10, 0, 0)
Entry.TextColor3 = Color3.new(1, 1, 1)
Entry.TextXAlignment = Enum.TextXAlignment.Left
Entry.TextYAlignment = Enum.TextYAlignment.Top
Entry.Font = Enum.Font.Gotham
Entry.TextSize = 30
Entry.ClearTextOnFocus = false
Entry.TextWrapped = true
Entry.ShowNativeInput = false
Entry.PlaceholderColor3 = Color3.new(0.7, 0.7, 0.7)
Entry.Text = ""
Entry.Parent = ChatBar

local Focused = false

Entry.Focused:Connect(function()
	Focused = true
	Scrolling.ScrollingEnabled = false
	Center()
end)

local function UpdateChatBar()
	ChatBar.Size = UDim2.new(1, -60, 0, math.max(TextService:GetTextSize(Entry.Text, 30, Enum.Font.Gotham, Vector2.new(Entry.AbsoluteSize.X, math.huge)).Y, 30))
end

RenderStepped:Connect(function()
	UpdateChatBar()
	if Focused then
		Center()
	end
end)

local Send = Instance.new("TextButton")
Send.Name = "Send"
Send.BorderSizePixel = 0
Send.Size = UDim2.new(0, 30, 0, 30)
Send.AnchorPoint = Vector2.new(1, 0)
Send.Position = UDim2.new(1, -10, 1, -70)
Send.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
Send.TextColor3 = Color3.new(1, 1, 1)
Send.Font = Enum.Font.Roboto
Send.Text = "▲"
Send.TextSize = 17
Round(Send)

local People = {}
local function Person(ID)
	local Index = table.find(People, ID)
	if Index then
		table.remove(People, Index)
	end
	table.insert(People, 1, ID)
end

local SentCallbacks, TimestampCallbacks = {}, {}

local function tick()
	return DateTime.now().UnixTimestamp
end

local function Now()
	pcall(function()
		TimestampCallbacks[ConversationID](tick())
	end)
end

local function SendMessage()
	local Contents = Entry.Text
	Entry.Text = ""
	if tostring(string.gsub(tostring(string.gsub(Contents, "\0", "")), "%s", "")) ~= "" then
		New({Author = UserId, Timestamp = DateTime.now().UnixTimestamp, Notified = false, Read = false, Contents = Contents}, true)
		pcall(function()
			SentCallbacks[ConversationID]()
		end)
		Now()
		Person(ConversationID)
		Remote:FireServer("Send", ConversationID, Contents)
	end
end

Send.Activated:Connect(SendMessage)

Entry.FocusLost:Connect(function(EnterPressed)
	Focused = false
	Scrolling.ScrollingEnabled = true
	if EnterPressed then
		SendMessage()
	end
	UpdateChatBar()
end)

Send.Parent = Chat
ChatBar.Parent = Chat

local DotQuantity = 6
local Radius = 30
local DotSize = 10

local TimeElapsed = 0
local Closed = true
local Closing = false

local LoadingFrame = Instance.new("Frame")
LoadingFrame.Name = "Loading"
LoadingFrame.BorderSizePixel = 0
LoadingFrame.ZIndex = 4
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.new(0, 0, 0)
LoadingFrame.BackgroundTransparency = 1

local Dots = {}

for Index = 1, DotQuantity do
	local Dot = Instance.new("Frame")
	Dot.Name = "Dot"
	Dot.BorderSizePixel = 0
	Dot.Size = UDim2.new(0, DotSize, 0, DotSize)
	Dot.AnchorPoint = Vector2.new(0.5, 0.5)
	Dot.BackgroundColor3 = Color3.new(1, 1, 1)
	Dot.BackgroundTransparency = 1
	Round(Dot)
	Dot.Parent = LoadingFrame
	Dots[Index] = Dot
end

local Full = math.pi * 2

RenderStepped:Connect(function(DeltaTime)
	TimeElapsed += DeltaTime / 2
	TimeElapsed -= math.floor(TimeElapsed)

	local Angle = TweenService:GetValue(TimeElapsed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut) * Full

	local Offset = Full / DotQuantity

	local Transparency = (LoadingFrame.BackgroundTransparency - 0.5) * 2

	for Index, Dot in ipairs(Dots) do
		local Angle = Offset * (Index - 1) - Angle
		local Position = Vector2.new(math.sin(Angle), math.cos(Angle)) * Radius
		Dot.Position = UDim2.new(0.5, Position.X, 0.5, Position.Y)
		Dot.BackgroundTransparency = Transparency
	end
end)

local LoadingInfo = TweenInfo.new(0.5)

local function ShowLoading()
	Closing = false
	if Closed then
		TimeElapsed, Closed = 0, false
	end
	Tween(LoadingFrame, LoadingInfo, {BackgroundTransparency = 0.5})
end

local function HideLoading()
	Closing = true
	coroutine.wrap(function()
		Tween(LoadingFrame, LoadingInfo, {BackgroundTransparency = 1}).Completed:Wait()
		if Closing then
			Closed = true
		end
	end)()
end

LoadingFrame.Parent = ScreenGui

local Colors = {
	Notified = Color3.new(0.5, 0.5, 0.5),
	Read = Color3.new(0, 0.6, 1)
}
local TextColors = {
	Notified = Color3.fromRGB(213, 213, 213),
	Read = Color3.fromRGB(175, 216, 255)
}

local function Queue()
	local Queue = {}
	return function()
		local Item = {}
		table.insert(Queue, Item)
		repeat
			wait()
		until table.find(Queue, Item) <= 1
		local Done = false
		return function()
			if not Done then
				Done = true
				table.remove(Queue, 1)
			end
		end
	end
end

local function NewStatusLabel(Status, Transition, IsNew, Frame)
	local Label = Instance.new("TextLabel")
	Label.Name = "Label"
	Label.BackgroundTransparency = 1
	local GoalSize = UDim2.new(0, TextService:GetTextSize(Status, 14, Enum.Font.GothamBold, Vector2.new(1, 1) * math.huge).X + 13, 0, 15)
	if Transition then
		Label.Size = UDim2.new(0, 0, 0, 15)
	else
		Label.Size = GoalSize
	end
	Label.AnchorPoint = Vector2.new(1, 0)
	Label.Position = UDim2.new(1, -17, 0, 0)
	Label.ClipsDescendants = true
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.TextColor3 = TextColors[Status]
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 14
	Label.Text = Status
	if IsNew then
		Label.TextTransparency = 1
	else
		Label.TextTransparency = 0
	end
	Label.Parent = Frame

	local API = {}
	local Wait = Queue()
	function API:Appear()
		coroutine.wrap(function()
			local Done = Wait()
			if IsNew then
				IsNew = false
				local Goals = {TextTransparency = 0}
				if Transition then
					Goals.Size = GoalSize
				end
				Tween(Label, StatusInfo, Goals).Completed:Wait()
			end
			Done()
		end)()
	end
	local Destroyed = false
	function API:Disappear()
		coroutine.wrap(function()
			local Done = Wait()
			if not (IsNew or Destroyed) then
				Destroyed = true
				Tween(Label, StatusInfo, {TextTransparency = 1}).Completed:Wait()
				Destroy(Label)
			end
			Done()
		end)()
	end
	return API
end
local function NewStatus(Status, Index, IsNew)
	local Frame = Instance.new("Frame")
	Frame.Name = "Status"
	Frame.BackgroundTransparency = 1
	Frame.LayoutOrder = Index
	local GoalSize = UDim2.new(1, 0, 0, 25)
	if IsNew then
		Frame.Size = UDim2.new(1, 0, 0, 0)
	else
		Frame.Size = GoalSize
	end
	local Color = Instance.new("Frame")
	Color.Name = "Color"
	Color.BorderSizePixel = 0
	Color.ZIndex = 2
	Color.Size = UDim2.new(0, 15, 0, 15)
	Color.AnchorPoint = Vector2.new(0.5, 0.5)
	Color.Position = UDim2.new(1, -17, 0, 7)
	Color.BackgroundColor3 = Colors[Status]
	Round(Color)
	local Scale = Instance.new("UIScale")
	Scale.Name = "Scale"
	if IsNew then
		Scale.Scale = 0
	else
		Scale.Scale = 1
	end
	Scale.Parent = Color
	Color.Parent = Frame
	local Label = NewStatusLabel(Status, false, IsNew, Frame)

	local API = {}
	local Wait = Queue()
	function API:Appear()
		coroutine.wrap(function()
			local Done = Wait()
			if IsNew then
				IsNew = false
				Label:Appear()
				Tween(Scale, StatusInfo, {Scale = 1})
				Tween(Frame, StatusInfo, {Size = GoalSize}).Completed:Wait()
			end
			Done()
		end)()
	end
	function API:Transition()
		coroutine.wrap(function()
			local Done = Wait()
			if Status == "Notified" then
				Status = "Read"
				Label:Disappear()
				Label = NewStatusLabel(Status, true, true, Frame)
				Label:Appear()
				Tween(Color, StatusInfo, {BackgroundColor3 = Colors[Status]}).Completed:Wait()
			end
			Done()
		end)()
	end
	local Destroying = false
	function API:Disappear()
		coroutine.wrap(function()
			local Done = Wait()
			if not (IsNew or Destroying) then
				Destroying = true
				Label:Disappear()
				Tween(Color, StatusInfo, {BackgroundTransparency = 1})
				Tween(Frame, StatusInfo, {Size = UDim2.new(1, 0, 0, 0)}).Completed:Wait()
				Destroy(Frame)
			end
			Done()
		end)()
	end
	Frame.Parent = Scrolling
	return API
end

local Statuses = {}

Remote.OnClientEvent:Connect(function(Key, ID)
	if ID == ConversationID then
		local Index = TotalIndex
		local function Status(Status)
			local Status_ = NewStatus(Status, Index, true)
			Status_:Appear()
			Statuses[Status] = Status_
		end
		if ReadIndex ~= Index then
			if Key == "Read" then
				pcall(function()
					Statuses.Read:Disappear()
				end)
				local function New()
					Status("Read")
				end
				if NotifiedIndex then
					if NotifiedIndex == Index then
						Statuses.Notified:Transition()
						Statuses.Read = Statuses.Notified
					else
						pcall(function()
							Statuses.Notified:Disappear()
						end)
						New()
					end
					Statuses.Notified = nil
					NotifiedIndex = nil
				else
					New()
				end
				ReadIndex = Index
			elseif Key == "Notified" then
				if NotifiedIndex ~= Index then
					pcall(function()
						Statuses.Notified:Disappear()
					end)
					Status("Notified")
					NotifiedIndex = Index
				end
			end
		end
	end
end)

local NotifiedCallbacks, ReadCallbacks, RecievedCallbacks = {}, {}, {}

local ChatLoading = false

local function Load(ID, Name)
	if not ChatLoading and ChatClosed then
		ChatLoading = true
		ShowLoading()
		ConversationID = ID
		ChatIcon.Image = Players:GetUserThumbnailAsync(ID, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		ChatName.Text = Name
		Entry.PlaceholderText = "Send to "..Name.."..."
		for _, AChild in ipairs(Scrolling:GetChildren()) do
			if not AChild:IsA("UIListLayout") and not AChild:IsA("UIPadding") and not AChild:IsA("UIStroke") then
				AChild.Visible = false
				Destroy(AChild)
			end
		end
		local Data, Tick
		local Connection = Remote.OnClientEvent:Connect(function(Key, Data_, Tick_)
			if Key == ID then
				Data, Tick = Data_ or {}, Tick_
			end
		end)
		Remote:FireServer("Get", ID)
		repeat
			wait(0.01)
		until Data
		local Last = Data[#Data]
		if Last then
			local Callbacks
			local Timestamp = Tick
			if Last.Author == UserId then
				if Last.Read then
					Callbacks = ReadCallbacks
				elseif Last.Notified then
					Callbacks = NotifiedCallbacks
				else
					Callbacks = SentCallbacks
				end
			else
				if Last.Read then
					Callbacks = RecievedCallbacks
				else
					Timestamp = Last.Timestamp
				end
			end
			pcall(function()
				Callbacks[ID]()
			end)
			if Timestamp then
				pcall(function()
					TimestampCallbacks[ID](Timestamp)
				end)
			end
		end
		Connection:Disconnect()
		NotifiedIndex, ReadIndex = nil, nil
		for Index, Data in ipairs(Data) do
			MakeMessage(Index, Data)
		end
		Statuses = {}
		if ReadIndex then
			Statuses.Read = NewStatus("Read", ReadIndex)
		end
		if NotifiedIndex then
			Statuses.Notified = NewStatus("Notified", NotifiedIndex)
		end
		Entry.Text = ""
		UpdateChatBar()
		if ChatClosed then
			ChatClosed = false
			Set(0)
		end
		Center()
		ChatLoading = false
		HideLoading()
	end
end

Remote.OnClientEvent:Connect(function(Key, Data)
	if Key == "Message" then
		New(Data, true)
		Person(ConversationID)
		pcall(function()
			RecievedCallbacks[ConversationID]()
		end)
		Now()
	end
end)

local Queue = {}

local ShadowInfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear)

local function Notification(ID, Name)
	coroutine.wrap(function()
		local Item = {}
		table.insert(Queue, Item)
		local Shadow = Instance.new("Frame")
		Shadow.Name = "Notification"
		Shadow.BorderSizePixel = 0
		Shadow.ZIndex = 3
		Shadow.Size = UDim2.new(1, 0, 0, 150)
		Shadow.BackgroundColor3 = Color3.new(0, 0, 0)
		Shadow.BackgroundTransparency = 1
		local Fade = Instance.new("UIGradient")
		Fade.Name = "Fade"
		Fade.Rotation = 90
		Fade.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1)
		})
		Fade.Parent = Shadow
		local Frame = Instance.new("Frame")
		Frame.Name = "Notification"
		Frame.BorderSizePixel = 0
		Frame.Size = UDim2.new(1, -20, 0, 50)
		Frame.AnchorPoint = Vector2.new(0, 1)
		Frame.Position = UDim2.new(0, 10, 0, 0)
		Frame.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
		local Corners = Instance.new("UICorner")
		Corners.Name = "Corners"
		Corners.CornerRadius = UDim.new(0, 10)
		Corners.Parent = Frame
		local Icon = Instance.new("ImageLabel")
		Icon.Name = "Icon"
		Icon.BackgroundTransparency = 1
		Icon.Size = UDim2.new(0, 40, 0, 40)
		Icon.AnchorPoint = Vector2.new(0, 0.5)
		Icon.Position = UDim2.new(0, 10, 0.5, 0)
		Round(Icon)
		Icon.Image = Players:GetUserThumbnailAsync(ID, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		Icon.Parent = Frame
		local Label = Instance.new("TextLabel")
		Label.Name = "Name"
		Label.BackgroundTransparency = 1
		Label.Size = UDim2.new(1, -60, 0.4, 0)
		Label.Position = UDim2.new(0, 60, 0.1, 0)
		Label.TextColor3 = Color3.new(1, 1, 1)
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Font = Enum.Font.GothamSemibold
		Label.TextSize = 20
		Label.Text = Name
		local Info = Label:Clone()
		Info.Name = "Info"
		Info.Position = UDim2.new(0, 60, 0.5, 0)
		Info.Font = Enum.Font.Gotham
		Info.Text = "sent a message"
		Info.Parent = Frame
		Label.Parent = Frame
		Frame.Parent = Shadow
		while true do
			if table.find(Queue, Item) < 2 then
				break
			end
			wait(0.01)
		end
		Shadow.Parent = ScreenGui
		Tween(Shadow, ShadowInfo, {BackgroundTransparency = 0.5})
		Tween(Frame, TweenInfo.new(0.25), {Position = UDim2.new(0, 10, 0, 40), AnchorPoint = Vector2.new(0, 0)}).Completed:Wait()
		local Tick = tick()
		while true do
			local TimeElapsed = tick() - Tick
			if TimeElapsed > 3 or (TimeElapsed > 1 and #Queue > 1) then
				break
			end
			wait(0.01)
		end
		Tween(Frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0, 10, 0, 0), AnchorPoint = Vector2.new(0, 1)})
		Tween(Shadow, ShadowInfo, {BackgroundTransparency = 1}).Completed:Wait()
		table.remove(Queue, 1)
		Destroy(Frame)
	end)()
end

local Grey = Color3.new(0.5, 0.5, 0.5)
local Blue = Color3.new(0, 0.6, 1)

local Circle = UDim.new(0.5, 0)
local SquareOutline = UDim.new(0, 4)

local StatusIcons = {
	["Conversation Empty"] = {
		Color = Grey,
		Corner = SquareOutline
	},
	Sent = {
		Fill = true,
		Color = Grey,
		Corner = Circle
	},
	Notified = {
		Fill = true,
		Color = Blue,
		Corner = Circle
	},
	Read = {
		Color = Blue,
		Corner = Circle
	},
	["New Message"] = {
		Fill = true,
		Color = Blue,
		Corner = UDim.new(0, 5)
	},
	Recieved = {
		Color = Blue,
		Corner = SquareOutline
	}
}

local function SetIcon(Frame, Status)
	local Icon = StatusIcons[Status]
	Frame:WaitForChild("Corners").CornerRadius = Icon.Corner
	local Outline = Frame:WaitForChild("Outline")
	local Color, Fill = Icon.Color, Icon.Fill
	Frame.BackgroundColor3, Outline.Color = Color, Color
	Frame.BackgroundTransparency = (Fill and 0) or 1
	if Fill then
		Frame.Size = UDim2.new(0, 16, 0, 16)
	else
		Frame.Size = UDim2.new(0, 14, 0, 14)
	end
	Outline.Enabled = not Fill
end

local Base = "s"

local Units = {
	{"m", 60},
	{"h", 60},
	{"d", 24},
	{"w", 7}
}

local function AddPerson(Data)
	local User = Instance.new("Frame")
	local Name = Data.Name
	User.Name = Name
	User.BorderSizePixel = 0
	User.Size = UDim2.new(1, 0, 0, 72)
	User.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
	local Button = Instance.new("ImageButton")
	Button.Name = Name
	Button.BorderSizePixel = 0
	Button.Image = ""
	Button.Size = UDim2.new(1, 0, 1, -2)
	Button.Position = UDim2.new(0, 0, 0, 2)
	Button.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
	local Icon = Instance.new("ImageLabel")
	Icon.Name = "Icon"
	Icon.BackgroundTransparency = 1
	Icon.Size = UDim2.new(0, 60, 0, 60)
	Icon.AnchorPoint = Vector2.new(0.5, 0.5)
	Icon.Position = UDim2.new(0, 35, 0.5, 0)
	Round(Icon)
	local ID = Data.ID
	local function UpdateIndex()
		User.LayoutOrder = (table.find(People, ID) or 1) + 1
	end
	UpdateIndex()
	RenderStepped:Connect(UpdateIndex)
	Icon.Image = Players:GetUserThumbnailAsync(ID, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size60x60)
	Icon.Parent = Button
	local Label = Instance.new("TextLabel")
	Label.Name = "Name"
	Label.BackgroundTransparency = 1
	Label.Size = UDim2.new(1, -75, 0, 20)
	Label.Position = UDim2.new(0, 75, 0, 15)
	Label.TextColor3 = Color3.new(1, 1, 1)
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Font = Enum.Font.GothamSemibold
	Label.TextSize = 20
	Label.Text = Name
	local StatusLabel = Label:Clone()
	StatusLabel.Name = "Status"
	StatusLabel.Size = UDim2.new(1, -95, 0, 20)
	StatusLabel.Position = UDim2.new(0, 95, 0, 35)
	StatusLabel.Font = Enum.Font.Gotham
	local Grey, Blue = Color3.fromRGB(220, 220, 220), Color3.fromRGB(101, 163, 255)
	StatusLabel.TextColor3 = Grey
	local StatusIcon = Instance.new("Frame")
	StatusIcon.Name = "Status"
	StatusIcon.BorderSizePixel = 0
	StatusIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	StatusIcon.Position = UDim2.new(0, 83, 0, 45)
	Round(StatusIcon)
	local Outline = Instance.new("UIStroke")
	Outline.Name = "Outline"
	Outline.Thickness = 2
	Outline.Parent = StatusIcon
	local Unread = Instance.new("UIGradient")
	Unread.Name = "Unread"
	Unread.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(0.65, 0.65, 1)),
		ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
	})
	local function SetStatus(Status)
		Data.Status = Status
		SetIcon(StatusIcon, Status)
		if Status == "New Message" then
			Unread.Enabled, StatusLabel.TextColor3 = true, Blue
		else
			Unread.Enabled, StatusLabel.TextColor3 = false, Grey
		end
	end
	SetStatus(Data.Status)
	local Timestamp = Data.Timestamp
	RenderStepped:Connect(function()
		local Text = Data.Status
		if Timestamp then
			local Number = tick() - Timestamp
			local Ago = "just now"
			if Number > 10 then
				local Unit = Base
				for _, Data in ipairs(Units) do
					local New = math.floor(Number / Data[2])
					if New > 0 then
						Number, Unit = New, Data[1]
					else
						break
					end
				end
				Ago = tostring(Number)..Unit.." ago"
			end
			Text = Text.." • "..Ago
		end
		StatusLabel.Text = Text
	end)
	local function Now()
		Timestamp = tick()
	end
	Label.Parent = Button
	Unread.Parent = Button
	StatusLabel.Parent = Button
	StatusIcon.Parent = Button
	Button.Activated:Connect(function()
		if not ChatLoading and not Adding then
			Load(ID, Name)
			if Data.Status == "New Message" then
				SetStatus("Recieved")
				Now()
			end
		end
	end)
	Remote.OnClientEvent:Connect(function(Key, ID_)
		if ID_ == ID then
			if Key == "Unread" then
				SetStatus("New Message")
				Now()
				if not ChatClosed or Adding then
					Notification(ID, Name)
				end
				Person(ID)
			elseif Data.Status ~= "New Message" and Data.Status ~= "Recieved" then
				if Key == "Notified" and Data.Status ~= "Read" then
					if Data.Status ~= "Notified" then
						Now()
					end
					SetStatus("Notified")
				elseif Key == "Read" then
					if Data.Status ~= "Read" then
						Now()
					end
					SetStatus("Read")
				end
			end
		end
	end)
	local function Bind(Callbacks, Status)
		Callbacks[ID] = function()
			SetStatus(Status)
		end
	end
	Bind(RecievedCallbacks, "Recieved")
	Bind(SentCallbacks, "Sent")
	Bind(NotifiedCallbacks, "Notified")
	Bind(ReadCallbacks, "Read")
	TimestampCallbacks[ID] = function(Tick)
		Timestamp = Tick
	end

	Button.Parent = User
	User.Parent = Frame
end

local PeopleAdded = false

Remote.OnClientEvent:Connect(function(Key, Others, Name, Status)
	if Key == "People" and not PeopleAdded then
		PeopleAdded = true
		for Index, Data in ipairs(Others) do
			People[Index] = Data.ID
			AddPerson(Data)
		end
	elseif Key == "Add" then
		Person(Others)
		AddPerson({Name = Name, ID = Others, Status = Status})
	end
end)
Remote:FireServer("Get People")
repeat
	wait(0.01)
until not Connection.Connected
wait(3)
coroutine.wrap(function()
	Tween(Loading, TweenInfo.new(1), {BackgroundTransparency = 1, TextTransparency = 1}).Completed:Wait()
	Destroy(Loading)
end)()
Frame.Parent = ScreenGui
