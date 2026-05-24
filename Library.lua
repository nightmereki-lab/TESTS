if getgenv().Library then
    getgenv().Library:Unload()
end

local Library do 
    local Workspace = game:GetService("Workspace")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local RunService = game:GetService("RunService")
    local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    local Lighting = game:GetService("Lighting")

    gethui = gethui or function() return CoreGui end

    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera
    local Mouse = LocalPlayer:GetMouse()

    local FromRGB = Color3.fromRGB
    local FromHSV = Color3.fromHSV
    local FromHex = Color3.fromHex

    local RGBSequence = ColorSequence.new
    local RGBSequenceKeypoint = ColorSequenceKeypoint.new
    local NumSequence = NumberSequence.new
    local NumSequenceKeypoint = NumberSequenceKeypoint.new

    local UDim2New = UDim2.new
    local UDimNew = UDim.new
    local UDim2FromOffset = UDim2.fromOffset
    local Vector2New = Vector2.new
    local Vector3New = Vector3.new

    local MathClamp = math.clamp
    local MathFloor = math.floor
    local MathAbs = math.abs
    local MathSin = math.sin
    local MathMin = math.min
    local MathMax = math.max

    local TableInsert = table.insert
    local TableFind = table.find
    local TableRemove = table.remove
    local TableConcat = table.concat
    local TableClone = table.clone
    local TableUnpack = table.unpack

    local StringFormat = string.format
    local StringFind = string.find
    local StringGSub = string.gsub
    local StringLower = string.lower
    local StringLen = string.len

    local InstanceNew = Instance.new
    local RectNew = Rect.new
    
    local task_wait = task.wait
    local task_delay = task.delay
    local pcall = pcall
    local typeof = typeof
    local ipairs = ipairs
    local pairs = pairs

    Library = {
        Theme = {},
        MenuKeybind = tostring(Enum.KeyCode.RightControl), 
        Flags = {},
        Tween = {
            Time = 0.2,
            Style = Enum.EasingStyle.Circular,
            Direction = Enum.EasingDirection.Out
        },
        FadeSpeed = 0.2,
        Folders = {
            Directory = "homxiide",
            Configs = "homxiide/Configs",
            Assets = "homxiide/Assets",
        },
        Pages = {},
        Sections = {},
        Connections = {},
        Threads = {},
        ThemeMap = {},
        ThemeItems = {},
        OpenFrames = {},
        SetFlags = {},
        UnnamedConnections = 0,
        UnnamedFlags = 0,
        Holder = nil,
        NotifHolder = nil,
        UnusedHolder = nil,
        Font = nil
    }

    Library.__index = Library
    Library.Sections.__index = Library.Sections
    Library.Pages.__index = Library.Pages

    local Keys = {
        ["Unknown"]           = "Unknown",
        ["Backspace"]         = "Back",
        ["Tab"]               = "Tab",
        ["Clear"]             = "Clear",
        ["Return"]            = "Return",
        ["Pause"]             = "Pause",
        ["Escape"]            = "Escape",
        ["Space"]             = "Space",
        ["QuotedDouble"]      = '"',
        ["Hash"]              = "#",
        ["Dollar"]            = "$",
        ["Percent"]           = "%",
        ["Ampersand"]         = "&",
        ["Quote"]             = "'",
        ["LeftParenthesis"]   = "(",
        ["RightParenthesis"]  = " )",
        ["Asterisk"]          = "*",
        ["Plus"]              = "+",
        ["Comma"]             = ",",
        ["Minus"]             = "-",
        ["Period"]            = ".",
        ["Slash"]             = "`",
        ["Three"]             = "3",
        ["Seven"]             = "7",
        ["Eight"]             = "8",
        ["Colon"]             = ":",
        ["Semicolon"]         = ";",
        ["LessThan"]          = "<",
        ["GreaterThan"]       = ">",
        ["Question"]          = "?",
        ["Equals"]            = "=",
        ["At"]                = "@",
        ["LeftBracket"]       = "LeftBracket",
        ["RightBracket"]      = "RightBracked",
        ["BackSlash"]         = "BackSlash",
        ["Caret"]             = "^",
        ["Underscore"]        = "_",
        ["Backquote"]         = "`",
        ["LeftCurly"]         = "{",
        ["Pipe"]              = "|",
        ["RightCurly"]        = "}",
        ["Tilde"]             = "~",
        ["Delete"]            = "Delete",
        ["End"]               = "End",
        ["KeypadZero"]        = "Keypad0",
        ["KeypadOne"]         = "Keypad1",
        ["KeypadTwo"]         = "Keypad2",
        ["KeypadThree"]       = "Keypad3",
        ["KeypadFour"]        = "Keypad4",
        ["KeypadFive"]        = "Keypad5",
        ["KeypadSix"]         = "Keypad6",
        ["KeypadSeven"]       = "Keypad7",
        ["KeypadEight"]       = "Keypad8",
        ["KeypadNine"]        = "Keypad9",
        ["KeypadPeriod"]      = "KeypadP",
        ["KeypadDivide"]      = "KeypadD",
        ["KeypadMultiply"]    = "KeypadM",
        ["KeypadMinus"]       = "KeypadM",
        ["KeypadPlus"]        = "KeypadP",
        ["KeypadEnter"]       = "KeypadE",
        ["KeypadEquals"]      = "KeypadE",
        ["Insert"]            = "Insert",
        ["Home"]              = "Home",
        ["PageUp"]            = "PageUp",
        ["PageDown"]          = "PageDown",
        ["RightShift"]        = "RightShift",
        ["LeftShift"]         = "LeftShift",
        ["RightControl"]      = "RightControl",
        ["LeftControl"]       = "LeftControl",
        ["LeftAlt"]           = "LeftAlt",
        ["RightAlt"]          = "RightAlt"
    }

    local Themes = {
        ["Preset"] = {
            ["Background"] = FromRGB(10, 11, 12),
            ["Outline"] = FromRGB(22, 24, 23),
            ["Inline"] = FromRGB(18, 20, 22),
            ["Accent"] = FromRGB(255, 0, 0),
            ["Text"] = FromRGB(236, 245, 253),
            ["Element"] = FromRGB(25, 29, 31)
        }
    }

    Library.Theme = TableClone(Themes["Preset"])

    for _, Value in pairs(Library.Folders) do 
        if not isfolder(Value) then
            makefolder(Value)
        end
    end

    local Tween = {} do
        Tween.__index = Tween

        Tween.Create = function(self, Item, Info, Goal, IsRawItem)
            Item = IsRawItem and Item or Item.Instance
            Info = Info or TweenInfo.new(Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction)

            local NewTween = {
                Tween = TweenService:Create(Item, Info, Goal),
                Info = Info,
                Goal = Goal,
                Item = Item
            }
            NewTween.Tween:Play()
            setmetatable(NewTween, Tween)
            return NewTween
        end

        Tween.GetProperty = function(self, Item)
            Item = Item or self.Item 
            if Item:IsA("Frame") then
                return { "BackgroundTransparency" }
            elseif Item:IsA("TextLabel") or Item:IsA("TextButton") then
                return { "TextTransparency", "BackgroundTransparency" }
            elseif Item:IsA("ImageLabel") or Item:IsA("ImageButton") then
                return { "BackgroundTransparency", "ImageTransparency" }
            elseif Item:IsA("ScrollingFrame") then
                return { "BackgroundTransparency", "ScrollBarImageTransparency" }
            elseif Item:IsA("TextBox") then
                return { "TextTransparency", "BackgroundTransparency" }
            elseif Item:IsA("UIStroke") then 
                return { "Transparency" }
            end
        end

        Tween.FadeItem = function(self, Item, Property, Visibility, Speed)
            Item = Item or self.Item 
            local OldTransparency = Item[Property]
            Item[Property] = Visibility and 1 or OldTransparency

            local NewTween = Tween:Create(Item, TweenInfo.new(Speed or Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction), {
                [Property] = Visibility and OldTransparency or 1
            }, true)

            Library:Connect(NewTween.Tween.Completed, function()
                if not Visibility then 
                    task_wait()
                    Item[Property] = OldTransparency
                end
            end)

            return NewTween
        end

        Tween.Get = function(self)
            if not self.Tween then return end
            return self.Tween, self.Info, self.Goal
        end

        Tween.Pause = function(self)
            if self.Tween then self.Tween:Pause() end
        end

        Tween.Play = function(self)
            if self.Tween then self.Tween:Play() end
        end

        Tween.Clean = function(self)
            if not self.Tween then return end
            self:Pause()
            self = nil
        end
    end

    local Instances = {} do
        Instances.__index = Instances

        Instances.Create = function(self, Class, Properties)
            local NewItem = {
                Instance = InstanceNew(Class),
                Properties = Properties,
                Class = Class
            }
            setmetatable(NewItem, Instances)
            for Property, Value in pairs(NewItem.Properties) do
                NewItem.Instance[Property] = Value
            end
            return NewItem
        end

        Instances.AddToTheme = function(self, Properties)
            if self.Instance then Library:AddToTheme(self, Properties) end
            return self
        end

        Instances.ChangeItemTheme = function(self, Properties)
            if self.Instance then Library:ChangeItemTheme(self, Properties) end
        end

        Instances.Connect = function(self, Event, Callback, Name)
            if self.Instance and self.Instance[Event] then 
                return Library:Connect(self.Instance[Event], Callback, Name)
            end
        end

        Instances.Tween = function(self, Info, Goal)
            if self.Instance then return Tween:Create(self, Info, Goal) end
        end

        Instances.Disconnect = function(self, Name)
            if self.Instance then return Library:Disconnect(Name) end
        end

        Instances.Clean = function(self)
            if self.Instance then 
                self.Instance:Destroy()
                self = nil
            end
        end

        Instances.MakeDraggable = function(self)
            if not self.Instance then return end
        
            local Gui = self.Instance
            local Dragging = false 
            local DragStart, StartPosition, InputChanged
        
            local Set = function(Input)
                local DragDelta = Input.Position - DragStart
                local NewX = StartPosition.X.Offset + DragDelta.X
                local NewY = StartPosition.Y.Offset + DragDelta.Y

                local ScreenSize = Gui.Parent.AbsoluteSize
                local GuiSize = Gui.AbsoluteSize
        
                NewX = MathClamp(NewX, 0, ScreenSize.X - GuiSize.X)
                NewY = MathClamp(NewY, 0, ScreenSize.Y - GuiSize.Y)
        
                self:Tween(TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(0, NewX, 0, NewY)})
            end
        
            self:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    DragStart = Input.Position
                    StartPosition = Gui.Position
        
                    if InputChanged then return end
        
                    InputChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Dragging = false
                            InputChanged:Disconnect()
                            InputChanged = nil
                        end
                    end)
                end
            end)
        
            Library:Connect(UserInputService.InputChanged, function(Input)
                if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) and Dragging then
                    Set(Input)
                end
            end)
        
            return Dragging
        end

        Instances.MakeResizeable = function(self, Minimum, Maximum)
            if not self.Instance then return end

            local Gui = self.Instance
            local Resizing = false 
            local CurrentSide, StartMouse, StartPosition, StartSize
            local EdgeThickness = 2

            local MakeEdge = function(Name, Position, Size)
                local Button = Instances:Create("TextButton", {
                    Name = "\0",
                    Size = Size,
                    Position = Position,
                    BackgroundColor3 = FromRGB(166, 147, 243),
                    BackgroundTransparency = 1,
                    Text = "",
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Parent = Gui,
                    ZIndex = 99999,
                })
                Button:AddToTheme({BackgroundColor3 = "Accent"})
                return Button
            end

            local Edges = {
                {Button = MakeEdge("Left", UDim2New(0, 0, 0, 0), UDim2New(0, EdgeThickness, 1, 0)), Side = "L"},
                {Button = MakeEdge("Right", UDim2New(1, -EdgeThickness, 0, 0), UDim2New(0, EdgeThickness, 1, 0)), Side = "R"},
                {Button = MakeEdge("Top", UDim2New(0, 0, 0, 0), UDim2New(1, 0, 0, EdgeThickness)), Side = "T"},
                {Button = MakeEdge("Bottom", UDim2New(0, 0, 1, -EdgeThickness), UDim2New(1, 0, 0, EdgeThickness)), Side = "B"},
            }

            local BeginResizing = function(Side)
                Resizing = true 
                CurrentSide = Side 
                StartMouse = UserInputService:GetMouseLocation()
                StartPosition = Vector2New(Gui.Position.X.Offset, Gui.Position.Y.Offset)
                StartSize = Vector2New(Gui.Size.X.Offset, Gui.Size.Y.Offset)
                
                for _, Value in ipairs(Edges) do 
                    Value.Button.Instance.BackgroundTransparency = (Value.Side == Side) and 0 or 1
                end
            end

            local EndResizing = function()
                Resizing = false 
                CurrentSide = nil
                for _, Value in ipairs(Edges) do 
                    Value.Button.Instance.BackgroundTransparency = 1
                end
            end

            for _, Value in ipairs(Edges) do 
                Value.Button:Connect("InputBegan", function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        BeginResizing(Value.Side)
                    end
                end)
            end

            Library:Connect(UserInputService.InputEnded, function(Input)
                if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and Resizing then
                    EndResizing()
                end
            end)

            Library:Connect(RunService.RenderStepped, function()
                if not Resizing or not CurrentSide then return end

                local MouseLocation = UserInputService:GetMouseLocation()
                local dx = MouseLocation.X - StartMouse.X
                local dy = MouseLocation.Y - StartMouse.Y
            
                local x, y = StartPosition.X, StartPosition.Y
                local w, h = StartSize.X, StartSize.Y

                if CurrentSide == "L" then
                    x = StartPosition.X + dx
                    w = StartSize.X - dx
                elseif CurrentSide == "R" then
                    w = StartSize.X + dx
                elseif CurrentSide == "T" then
                    y = StartPosition.Y + dy
                    h = StartSize.Y - dy
                elseif CurrentSide == "B" then
                    h = StartSize.Y + dy
                end
            
                if w < Minimum.X then
                    if CurrentSide == "L" then x = x - (Minimum.X - w) end
                    w = Minimum.X
                end
                if h < Minimum.Y then
                    if CurrentSide == "T" then y = y - (Minimum.Y - h) end
                    h = Minimum.Y
                end
            
                self:Tween(TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2FromOffset(x, y)})
                self:Tween(TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2FromOffset(w, h)})
            end)
        end

        Instances.OnHover = function(self, Function)
            if self.Instance then return Library:Connect(self.Instance.MouseEnter, Function) end
        end

        Instances.OnHoverLeave = function(self, Function)
            if self.Instance then return Library:Connect(self.Instance.MouseLeave, Function) end
        end
    end

    local CustomFont = {} do
        function CustomFont:New(Name, Weight, Style, Data)
            if not isfile(Data.Id) then 
                writefile(Data.Id, game:HttpGet(Data.Url))
            end

            local FontData = {
                name = Name,
                faces = {
                    {
                        name = Name,
                        weight = Weight,
                        style = Style,
                        assetId = getcustomasset(Data.Id)
                    }
                }
            }

            writefile(StringFormat("%s/%s.font", Library.Folders.Assets, Name), HttpService:JSONEncode(FontData))
            return Font.new(getcustomasset(StringFormat("%s/%s.font", Library.Folders.Assets, Name)))
        end

        Library.Font = CustomFont:New("OutfitMedium", 400, "Regular", {
            Id = "OutfitMedium",
            Url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/Outfit-Medium.ttf"
        })
    end

    Library.Holder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "\0",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder = 2,
        ResetOnSpawn = false
    })

    Library.UnusedHolder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "\0",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        Enabled = false,
        ResetOnSpawn = false
    })

    Library.Unload = function(self)
        for _, Value in ipairs(self.Connections) do 
            Value.Connection:Disconnect()
        end
        for _, Value in ipairs(self.Threads) do 
            coroutine.close(Value)
        end
        if self.Holder then 
            self.Holder:Clean()
        end
        Library = nil 
        getgenv().Library = nil
    end

    Library.Round = function(self, Number, Float)
        local Multiplier = 1 / (Float or 1)
        return MathFloor(Number * Multiplier) / Multiplier
    end

    Library.Thread = function(self, Function)
        local NewThread = coroutine.create(Function)
        coroutine.wrap(function()
            coroutine.resume(NewThread)
        end)()
        TableInsert(self.Threads, NewThread)
        return NewThread
    end
    
    Library.SafeCall = function(self, Function, ...)
        local Success, Result = pcall(Function, ...)
        if not Success then
            warn(Result)
            return false
        end
        return Success
    end

    Library.Connect = function(self, Event, Callback, Name)
        Name = Name or StringFormat("connection_number_%s_%s", self.UnnamedConnections + 1, HttpService:GenerateGUID(false))

        local NewConnection = {
            Event = Event,
            Callback = Callback,
            Name = Name,
            Connection = nil
        }

        Library:Thread(function()
            NewConnection.Connection = Event:Connect(Callback)
        end)

        TableInsert(self.Connections, NewConnection)
        return NewConnection
    end

    Library.Disconnect = function(self, Name)
        for _, Connection in ipairs(self.Connections) do 
            if Connection.Name == Name then
                Connection.Connection:Disconnect()
                break
            end
        end
    end

    Library.NextFlag = function(self)
        self.UnnamedFlags = self.UnnamedFlags + 1
        return StringFormat("flag_number_%s_%s", self.UnnamedFlags, HttpService:GenerateGUID(false))
    end

    Library.AddToTheme = function(self, Item, Properties)
        Item = Item.Instance or Item 

        local ThemeData = {
            Item = Item,
            Properties = Properties,
        }

        for Property, Value in pairs(ThemeData.Properties) do
            if type(Value) == "string" then
                Item[Property] = self.Theme[Value] or Value
            else
                Item[Property] = Value()
            end
        end

        TableInsert(self.ThemeItems, ThemeData)
        self.ThemeMap[Item] = ThemeData
    end

    Library.ToRich = function(self, Text, Color)
        return StringFormat('<font color="rgb(%s, %s, %s)">%s</font>', MathFloor(Color.R * 255), MathFloor(Color.G * 255), MathFloor(Color.B * 255), Text)
    end

    Library.GetConfig = function(self)
        local Config = {} 
        Library:SafeCall(function()
            for Index, Value in pairs(Library.Flags) do 
                if type(Value) == "table" and Value.Key then
                    Config[Index] = {Key = tostring(Value.Key), Mode = Value.Mode}
                elseif type(Value) == "table" and Value.Color then
                    Config[Index] = {Color = "#" .. Value.HexValue, Alpha = Value.Alpha}
                else
                    Config[Index] = Value
                end
            end
        end)
        return HttpService:JSONEncode(Config)
    end

    Library.LoadConfig = function(self, Config)
        local Decoded = HttpService:JSONDecode(Config)
        local Success, Result = Library:SafeCall(function()
            for Index, Value in pairs(Decoded) do 
                local SetFunction = Library.SetFlags[Index]
                if SetFunction then
                    if type(Value) == "table" and Value.Key then 
                        SetFunction(Value)
                    elseif type(Value) == "table" and Value.Color then
                        SetFunction(Value.Color, Value.Alpha)
                    else
                        SetFunction(Value)
                    end
                end
            end
        end)
        return Success, Result
    end

    Library.DeleteConfig = function(self, Config)
        local Path = Library.Folders.Configs .. "/" .. Config
        if isfile(Path) then delfile(Path) end
    end

    Library.RefreshConfigsList = function(self, Element)
        local List = listfiles(Library.Folders.Configs)
        local ReturnList = {}

        for Index = 1, #List do 
            local File = List[Index]
            if File:sub(-5) == ".json" then
                local Position = File:find(".json", 1, true)
                local StartPosition = Position
                local Character = File:sub(Position, Position)
                while Character ~= "/" and Character ~= "\\" and Character ~= "" do
                    Position = Position - 1
                    Character = File:sub(Position, Position)
                end
                if Character == "/" or Character == "\\" then
                    TableInsert(ReturnList, File:sub(Position + 1, StartPosition - 1))
                end
            end
        end
        Element:Refresh(ReturnList)
    end

    Library.ChangeItemTheme = function(self, Item, Properties)
        Item = Item.Instance or Item
        if self.ThemeMap[Item] then 
            self.ThemeMap[Item].Properties = Properties
        end
    end

    Library.ChangeTheme = function(self, Theme, Color)
        self.Theme[Theme] = Color
        for _, Item in ipairs(self.ThemeItems) do
            for Property, Value in pairs(Item.Properties) do
                if type(Value) == "string" and Value == Theme then
                    Item.Item[Property] = Color
                elseif type(Value) == "function" then
                    Item.Item[Property] = Value()
                end
            end
        end
    end

    Library.IsMouseOverFrame = function(self, Frame)
        Frame = Frame.Instance
        local MousePosition = Vector2New(Mouse.X, Mouse.Y)
        return MousePosition.X >= Frame.AbsolutePosition.X and MousePosition.X <= Frame.AbsolutePosition.X + Frame.AbsoluteSize.X 
        and MousePosition.Y >= Frame.AbsolutePosition.Y and MousePosition.Y <= Frame.AbsolutePosition.Y + Frame.AbsoluteSize.Y
    end

    Library.Lerp = function(self, Start, Finish, Time)
        return Start + (Finish - Start) * Time
    end

    Library.CompareVectors = function(self, PointA, PointB)
        return (PointA.X < PointB.X) or (PointA.Y < PointB.Y)
    end

    Library.IsClipped = function(self, Object, Column)
        local BoundryTop = Column.AbsolutePosition
        local BoundryBottom = BoundryTop + Column.AbsoluteSize
        local Top = Object.AbsolutePosition
        local Bottom = Top + Object.AbsoluteSize 
        return Library:CompareVectors(Top, BoundryTop) or Library:CompareVectors(BoundryBottom, Bottom)
    end

    Library.CreateColorpicker = function(self, Data)
        local Colorpicker = {
            Flag = Data.Flag, 
            Hue = 0,
            Saturation = 0,
            Value = 0,
            Color = FromRGB(0, 0, 0),
            Hex = "#000000",
            IsOpen = false 
        }

        local Items = {} do 
            Items["ColorpickerButton"] = Instances:Create("TextButton", {
                Parent = Data.Parent.Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                AutoButtonColor = false,
                Size = UDim2New(0, 20, 0, 16),
                BorderSizePixel = 0,
                TextSize = 14,
                BackgroundColor3 = FromRGB(148, 255, 237)
            })
            
            Instances:Create("UICorner", {
                Parent = Items["ColorpickerButton"].Instance,
                CornerRadius = UDimNew(0, 6)
            })
            
            Instances:Create("UIStroke", {
                Parent = Items["ColorpickerButton"].Instance,
                Color = Library.Theme["Outline"],
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = 'Outline'})
            
            Items["Glow"] = Instances:Create("ImageLabel", {
                Parent = Items["ColorpickerButton"].Instance,
                ImageColor3 = FromRGB(148, 255, 237),
                ScaleType = Enum.ScaleType.Slice,
                ImageTransparency = 0.8,
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 25, 1, 25),
                AnchorPoint = Vector2New(0.5, 0.5),
                Image = "http://www.roblox.com/asset/?id=18245826428",
                BackgroundTransparency = 1,
                Position = UDim2New(0.5, 0, 0.5, 0),
                ZIndex = 2,
                BorderSizePixel = 0,
                SliceCenter = RectNew(Vector2New(21, 21), Vector2New(79, 79))
            })            

            Items["ColorpickerWindow"] = Instances:Create("TextButton", {
                Parent = Library.UnusedHolder.Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                AutoButtonColor = false,
                Position = UDim2New(0, 94, 0, 60),
                Size = UDim2New(0, 160, 0, 160),
                BorderSizePixel = 0,
                TextSize = 14,
                BackgroundColor3 = Library.Theme["Background"]
            }):AddToTheme({BackgroundColor3 = 'Background'})
            
            Instances:Create("UICorner", {
                Parent = Items["ColorpickerWindow"].Instance,
                CornerRadius = UDimNew(0, 6)
            })
            
            Items["Palette"] = Instances:Create("TextButton", {
                Parent = Items["ColorpickerWindow"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                AutoButtonColor = false,
                Position = UDim2New(0, 8, 0, 8),
                Size = UDim2New(1, -40, 1, -16),
                BorderSizePixel = 0,
                TextSize = 14,
                BackgroundColor3 = FromRGB(148, 255, 237)
            })
            
            Instances:Create("UICorner", {
                Parent = Items["Palette"].Instance,
                CornerRadius = UDimNew(0, 5)
            })
            
            Items["Saturation"] = Instances:Create("Frame", {
                Parent = Items["Palette"].Instance,
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 1, 1, 0),
                BorderSizePixel = 0
            })
            
            Instances:Create("UIGradient", {
                Parent = Items["Saturation"].Instance,
                Transparency = NumSequence{NumSequenceKeypoint(0, 1), NumSequenceKeypoint(1, 0)}
            })
            
            Instances:Create("UICorner", {
                Parent = Items["Saturation"].Instance,
                CornerRadius = UDimNew(0, 5)
            })
            
            Items["Value"] = Instances:Create("Frame", {
                Parent = Items["Palette"].Instance,
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 1, 1, 1),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(0, 0, 0)
            })
            
            Instances:Create("UIGradient", {
                Parent = Items["Value"].Instance,
                Rotation = 90,
                Transparency = NumSequence{NumSequenceKeypoint(0, 1), NumSequenceKeypoint(1, 0)}
            })
            
            Instances:Create("UICorner", {
                Parent = Items["Value"].Instance,
                CornerRadius = UDimNew(0, 5)
            })
            
            Items["PaletteDragger"] = Instances:Create("Frame", {
                Parent = Items["Palette"].Instance,
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(0, 5, 0, 5),
                BorderSizePixel = 0
            })
            
            Instances:Create("UIStroke", {
                Parent = Items["PaletteDragger"].Instance
            })
            
            Instances:Create("UICorner", {
                Parent = Items["PaletteDragger"].Instance,
                CornerRadius = UDimNew(1, 0)
            })
            
            Items["Hue"] = Instances:Create("TextButton", {
                Parent = Items["ColorpickerWindow"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                AutoButtonColor = false,
                AnchorPoint = Vector2New(1, 0),
                Position = UDim2New(1, -8, 0, 8),
                Size = UDim2New(0, 15, 1, -16),
                BorderSizePixel = 0,
                TextSize = 14
            })
            
            Instances:Create("UIGradient", {
                Parent = Items["Hue"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 0, 0)), RGBSequenceKeypoint(0.17, FromRGB(255, 255, 0)), RGBSequenceKeypoint(0.33, FromRGB(0, 255, 0)), RGBSequenceKeypoint(0.5, FromRGB(0, 255, 255)), RGBSequenceKeypoint(0.67, FromRGB(0, 0, 255)), RGBSequenceKeypoint(0.83, FromRGB(255, 0, 255)), RGBSequenceKeypoint(1, FromRGB(255, 0, 0))}
            })
            
            Instances:Create("UICorner", {
                Parent = Items["Hue"].Instance,
                CornerRadius = UDimNew(0, 6)
            })
            
            Items["HueDragger"] = Instances:Create("Frame", {
                Parent = Items["Hue"].Instance,
                BackgroundTransparency = 1,
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(0, 15, 0, 15),
                BorderSizePixel = 0
            })
            
            Instances:Create("UICorner", {
                Parent = Items["HueDragger"].Instance,
                CornerRadius = UDimNew(1, 0)
            })
            
            Instances:Create("UIStroke", {
                Parent = Items["HueDragger"].Instance
            })            
        end

        function Colorpicker:Get() return Colorpicker.Color end

        function Colorpicker:Update()
            local Hue, Saturation, Value = Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value
            Colorpicker.Color = FromHSV(Hue, Saturation, Value)
            Colorpicker.HexValue = Colorpicker.Color:ToHex()

            Library.Flags[Colorpicker.Flag] = {
                Color = Colorpicker.Color,
                HexValue = Colorpicker.HexValue
            }

            Items["ColorpickerButton"]:Tween(nil, {BackgroundColor3 = Colorpicker.Color})
            Items["Glow"]:Tween(nil, {ImageColor3 = Colorpicker.Color})
            Items["Palette"]:Tween(nil, {BackgroundColor3 = FromHSV(Hue, 1, 1)})

            if Data.Callback then 
                Library:SafeCall(Data.Callback, Colorpicker.Color)
            end
        end

        local SlidingPalette = false
        local PaletteChanged
        
        function Colorpicker:SlidePalette(Input)
            if not Input or not SlidingPalette then return end

            local ValueX = MathClamp(1 - (Input.Position.X - Items["Palette"].Instance.AbsolutePosition.X) / Items["Palette"].Instance.AbsoluteSize.X, 0, 1)
            local ValueY = MathClamp(1 - (Input.Position.Y - Items["Palette"].Instance.AbsolutePosition.Y) / Items["Palette"].Instance.AbsoluteSize.Y, 0, 1)

            Colorpicker.Saturation = ValueX
            Colorpicker.Value = ValueY

            local SlideX = MathClamp((Input.Position.X - Items["Palette"].Instance.AbsolutePosition.X) / Items["Palette"].Instance.AbsoluteSize.X, 0, 0.955)
            local SlideY = MathClamp((Input.Position.Y - Items["Palette"].Instance.AbsolutePosition.Y) / Items["Palette"].Instance.AbsoluteSize.Y, 0, 0.955)

            Items["PaletteDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(SlideX, 0, SlideY, 0)})
            Colorpicker:Update()
        end
        
        local SlidingHue = false
        local HueChanged

        function Colorpicker:SlideHue(Input)
            if not Input or not SlidingHue then return end
            
            local ValueY = MathClamp((Input.Position.Y - Items["Hue"].Instance.AbsolutePosition.Y) / Items["Hue"].Instance.AbsoluteSize.Y, 0, 1)
            Colorpicker.Hue = ValueY

            local SlideY = MathClamp((Input.Position.Y - Items["Hue"].Instance.AbsolutePosition.Y) / Items["Hue"].Instance.AbsoluteSize.Y, 0, 0.91)
            Items["HueDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(0, 0, SlideY, 0)})
            Colorpicker:Update()
        end

        local Debounce = false
        local RenderStepped  

        function Colorpicker:SetOpen(Bool)
            if Debounce then return end
            Colorpicker.IsOpen = Bool
            Debounce = true 

            if Colorpicker.IsOpen then 
                Items["ColorpickerWindow"].Instance.Visible = true
                Items["ColorpickerWindow"].Instance.Parent = Library.Holder.Instance
                
                RenderStepped = RunService.RenderStepped:Connect(function()
                    Items["ColorpickerWindow"].Instance.Position = UDim2New(
                        0, 
                        Items["ColorpickerButton"].Instance.AbsolutePosition.X, 
                        0, 
                        Items["ColorpickerButton"].Instance.AbsolutePosition.Y + Items["ColorpickerButton"].Instance.AbsoluteSize.Y + 5
                    )
                end)

                for Value, _ in pairs(Library.OpenFrames) do 
                    if Value ~= Colorpicker then Value:SetOpen(false) end
                end
                Library.OpenFrames[Colorpicker] = Colorpicker 
            else
                Library.OpenFrames[Colorpicker] = nil
                if RenderStepped then 
                    RenderStepped:Disconnect()
                    RenderStepped = nil
                end
            end

            local Descendants = Items["ColorpickerWindow"].Instance:GetDescendants()
            TableInsert(Descendants, Items["ColorpickerWindow"].Instance)

            local NewTween
            for _, Value in ipairs(Descendants) do 
                local TransparencyProperty = Tween:GetProperty(Value)
                if TransparencyProperty then
                    if not Value.ClassName:find("UI") then 
                        Value.ZIndex = (Colorpicker.IsOpen and Data.Section.IsSettings and 9) or (Colorpicker.IsOpen and not Data.Section.IsSettings and 3) or 1
                    end

                    if type(TransparencyProperty) == "table" then 
                        for _, Property in ipairs(TransparencyProperty) do 
                            NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                        end
                    else
                        NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                    end
                end
            end
            
            NewTween.Tween.Completed:Connect(function()
                Debounce = false 
                Items["ColorpickerWindow"].Instance.Visible = Colorpicker.IsOpen
                task_wait(0.2)
                Items["ColorpickerWindow"].Instance.Parent = not Colorpicker.IsOpen and Library.UnusedHolder.Instance or Library.Holder.Instance
            end)
        end

        function Colorpicker:Set(Color)
            if type(Color) == "table" then
                Color = FromRGB(Color[1], Color[2], Color[3])
            elseif type(Color) == "string" then
                Color = FromHex(Color)
            end 

            Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value = Color:ToHSV()
            local PaletteValueX = MathClamp(1 - Colorpicker.Saturation, 0, 0.955)
            local PaletteValueY = MathClamp(1 - Colorpicker.Value, 0, 0.955)
            local SlideY = MathClamp(Colorpicker.Hue, 0, 0.955)

            Items["PaletteDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(PaletteValueX, 0, PaletteValueY, 0)})
            Items["HueDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(0, 0, SlideY, 0)})
            Colorpicker:Update()
        end

        Items["ColorpickerButton"]:Connect("MouseButton1Down", function()
            Colorpicker:SetOpen(not Colorpicker.IsOpen)
        end)

        Items["Palette"]:Connect("InputBegan", function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                SlidingPalette = true 
                Colorpicker:SlidePalette(Input)

                if PaletteChanged then return end
                PaletteChanged = Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        SlidingPalette = false
                        PaletteChanged:Disconnect()
                        PaletteChanged = nil
                    end
                end)
            end
        end)

        Items["Hue"]:Connect("InputBegan", function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                SlidingHue = true 
                Colorpicker:SlideHue(Input)

                if HueChanged then return end
                HueChanged = Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        SlidingHue = false
                        HueChanged:Disconnect()
                        HueChanged = nil
                    end
                end)
            end
        end)

        Library:Connect(UserInputService.InputChanged, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                if SlidingPalette then Colorpicker:SlidePalette(Input) end
                if SlidingHue then Colorpicker:SlideHue(Input) end
            end
        end)

        Library:Connect(UserInputService.InputBegan, function(Input)
            if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and Colorpicker.IsOpen then
                if not Library:IsMouseOverFrame(Items["ColorpickerWindow"]) then
                    Colorpicker:SetOpen(false)
                end
            end
        end)

        if Data.Default then Colorpicker:Set(Data.Default) end

        Library.SetFlags[Colorpicker.Flag] = function(Value)
            Colorpicker:Set(Value)
        end

        return Colorpicker, Items 
    end

    local Keys = Keys

    Library.CreateKeybind = function(self, Data)
        local Keybind = {
            Flag = Data.Flag,
            Value = "",
            Key = "",
            Mode = "",
            Toggled = false,
            Picking = false,
            IsOpen = false 
        }

        local Items = {} do 
            Items["KeyButton"] = Instances:Create("TextButton", {
                Parent = Data.Parent.Instance,
                FontFace = Library.Font,
                TextColor3 = Library.Theme["Text"],
                TextTransparency = 0.5,
                Text = "[C]",
                AutoButtonColor = false,
                Size = UDim2New(0, 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                BorderColor3 = FromRGB(0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 16
            }):AddToTheme({TextColor3 = 'Text'})      
            
            Items["KeybindWindow"] = Instances:Create("TextButton", {
                Parent = Library.UnusedHolder.Instance,
                Visible = false,
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                AutoButtonColor = false,
                Position = UDim2New(0, 10, 0, 10),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.XY,
                TextSize = 14,
                BackgroundColor3 = Library.Theme["Background"]
            }):AddToTheme({BackgroundColor3 = 'Background'})
            
            Instances:Create("UICorner", {
                Parent = Items["KeybindWindow"].Instance,
                CornerRadius = UDimNew(0, 6)
            })
            
            Items["Toggle"] = Instances:Create("TextButton", {
                Parent = Items["KeybindWindow"].Instance,
                FontFace = Library.Font,
                TextColor3 = Library.Theme["Text"],
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "Toggle",
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Size = UDim2New(0, 0, 0, 15),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 14
            }):AddToTheme({TextColor3 = 'Text'})
            
            Instances:Create("UIListLayout", {
                Parent = Items["KeybindWindow"].Instance,
                Padding = UDimNew(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            
            Instances:Create("UIPadding", {
                Parent = Items["KeybindWindow"].Instance,
                PaddingTop = UDimNew(0, 10),
                PaddingBottom = UDimNew(0, 10),
                PaddingRight = UDimNew(0, 10),
                PaddingLeft = UDimNew(0, 10)
            })
            
            Items["Hold"] = Instances:Create("TextButton", {
                Parent = Items["KeybindWindow"].Instance,
                FontFace = Library.Font,
                TextColor3 = Library.Theme["Text"],
                TextTransparency = 0.5,
                Text = "Hold",
                AutoButtonColor = false,
                Size = UDim2New(0, 0, 0, 15),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                BorderColor3 = FromRGB(0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 14
            }):AddToTheme({TextColor3 = 'Text'})
            
            Items["Always"] = Instances:Create("TextButton", {
                Parent = Items["KeybindWindow"].Instance,
                FontFace = Library.Font,
                TextColor3 = Library.Theme["Text"],
                TextTransparency = 0.5,
                Text = "Always",
                AutoButtonColor = false,
                Size = UDim2New(0, 0, 0, 15),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                BorderColor3 = FromRGB(0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 14
            }):AddToTheme({TextColor3 = 'Text'})
        end

        local Modes = {
            Toggle = Items["Toggle"],
            Hold = Items["Hold"],
            Always = Items["Always"]
        }

        local Debounce = false
        local RenderStepped  

        function Keybind:SetOpen(Bool)
            if Debounce then return end
            Keybind.IsOpen = Bool
            Debounce = true 

            if Keybind.IsOpen then 
                Items["KeybindWindow"].Instance.Visible = true
                Items["KeybindWindow"].Instance.Parent = Library.Holder.Instance
                
                RenderStepped = RunService.RenderStepped:Connect(function()
                    Items["KeybindWindow"].Instance.Position = UDim2New(
                        0, 
                        Items["KeyButton"].Instance.AbsolutePosition.X, 
                        0, 
                        Items["KeyButton"].Instance.AbsolutePosition.Y + Items["KeyButton"].Instance.AbsoluteSize.Y + 5
                    )
                end)

                for Value, _ in pairs(Library.OpenFrames) do 
                    if Value ~= Keybind then Value:SetOpen(false) end
                end
                Library.OpenFrames[Keybind] = Keybind 
            else
                Library.OpenFrames[Keybind] = nil
                if RenderStepped then 
                    RenderStepped:Disconnect()
                    RenderStepped = nil
                end
            end

            local Descendants = Items["KeybindWindow"].Instance:GetDescendants()
            TableInsert(Descendants, Items["KeybindWindow"].Instance)

            local NewTween
            for _, Value in ipairs(Descendants) do 
                local TransparencyProperty = Tween:GetProperty(Value)
                if TransparencyProperty then
                    if not Value.ClassName:find("UI") then Value.ZIndex = Keybind.IsOpen and 4 or 1 end
                    if type(TransparencyProperty) == "table" then 
                        for _, Property in ipairs(TransparencyProperty) do 
                            NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                        end
                    else
                        NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                    end
                end
            end
            
            NewTween.Tween.Completed:Connect(function()
                Debounce = false 
                Items["KeybindWindow"].Instance.Visible = Keybind.IsOpen
                task_wait(0.2)
                Items["KeybindWindow"].Instance.Parent = not Keybind.IsOpen and Library.UnusedHolder.Instance or Library.Holder.Instance
            end)
        end

        function Keybind:SetMode(Mode)
            for Index, Value in pairs(Modes) do 
                Value:Tween(nil, {TextTransparency = (Index == Mode) and 0 or 0.5})
            end

            Library.Flags[Keybind.Flag] = {
                Mode = Keybind.Mode,
                Key = Keybind.Key,
                Toggled = Keybind.Toggled
            }

            if Data.Callback then Library:SafeCall(Data.Callback, Keybind.Toggled) end
        end

        function Keybind:Press(Bool)
            if Keybind.Mode == "Toggle" then 
                Keybind.Toggled = not Keybind.Toggled
            elseif Keybind.Mode == "Hold" then 
                Keybind.Toggled = Bool
            elseif Keybind.Mode == "Always" then 
                Keybind.Toggled = true
            end

            Library.Flags[Keybind.Flag] = {
                Mode = Keybind.Mode,
                Key = Keybind.Key,
                Toggled = Keybind.Toggled
            }

            if Data.Callback then Library:SafeCall(Data.Callback, Keybind.Toggled) end
        end

        function Keybind:Get() return Keybind.Key, Keybind.Mode, Keybind.Toggled end

        function Keybind:Set(Key)
            if StringFind(tostring(Key), "Enum") then 
                Keybind.Key = tostring(Key)
                Key = (Key.Name == "Backspace") and "None" or Key.Name

                local KeyString = Keys[Keybind.Key] or StringGSub(Key, "Enum.", "") or "None"
                local TextToDisplay = StringGSub(StringGSub(KeyString, "KeyCode.", ""), "UserInputType.", "") or "None"

                Keybind.Value = TextToDisplay
                Items["KeyButton"].Instance.Text = "["..TextToDisplay.."]"

                Library.Flags[Keybind.Flag] = {
                    Mode = Keybind.Mode,
                    Key = Keybind.Key,
                    Toggled = Keybind.Toggled
                }

                if Data.Callback then Library:SafeCall(Data.Callback, Keybind.Toggled) end
            elseif type(Key) == "table" then
                local RealKey = (Key.Key == "Backspace") and "None" or Key.Key
                Keybind.Key = tostring(Key.Key)
                Keybind.Mode = Key.Mode or "Toggle"
                Keybind:SetMode(Keybind.Mode)

                local KeyString = Keys[Keybind.Key] or StringGSub(tostring(RealKey), "Enum.", "") or RealKey
                local TextToDisplay = KeyString and StringGSub(StringGSub(KeyString, "KeyCode.", ""), "UserInputType.", "") or "None"

                Keybind.Value = TextToDisplay
                Items["KeyButton"].Instance.Text = "["..TextToDisplay.."]"

                if Data.Callback then Library:SafeCall(Data.Callback, Keybind.Toggled) end
            elseif TableFind({"Toggle", "Hold", "Always"}, Key) then
                Keybind.Mode = Key
                Keybind:SetMode(Key)
                if Data.Callback then Library:SafeCall(Data.Callback, Keybind.Toggled) end
            end

            Keybind.Picking = false
        end

        Items["KeyButton"]:Connect("MouseButton1Click", function()
            Keybind.Picking = true 
            Items["KeyButton"].Instance.Text = "..."

            local InputBegan
            InputBegan = UserInputService.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.Keyboard then 
                    Keybind:Set(Input.KeyCode)
                else
                    Keybind:Set(Input.UserInputType)
                end
                InputBegan:Disconnect()
                InputBegan = nil
            end)
        end)

        Library:Connect(UserInputService.InputBegan, function(Input)
            if Keybind.Value == "None" then return end

            local targetInput = tostring(Input.KeyCode) == Keybind.Key or tostring(Input.UserInputType) == Keybind.Key
            if targetInput then
                if Keybind.Mode == "Toggle" then 
                    Keybind:Press()
                else
                    Keybind:Press(true)
                end
            end

            if Input.UserInputType == Enum.UserInputType.MouseButton1 and Keybind.IsOpen then
                if not Library:IsMouseOverFrame(Items["KeybindWindow"]) then
                    Keybind:SetOpen(false)
                end
            end
        end)

        Library:Connect(UserInputService.InputEnded, function(Input)
            if Keybind.Value == "None" then return end

            local targetInput = tostring(Input.KeyCode) == Keybind.Key or tostring(Input.UserInputType) == Keybind.Key
            if targetInput then
                if Keybind.Mode == "Hold" then 
                    Keybind:Press(false)
                elseif Keybind.Mode == "Always" then 
                    Keybind:Press(true)
                end
            end
        end)

        Items["KeyButton"]:Connect("MouseButton2Down", function()
            Keybind:SetOpen(not Keybind.IsOpen)
        end)

        Items["Toggle"]:Connect("MouseButton1Down", function()
            Keybind.Mode = "Toggle"
            Keybind:SetMode("Toggle")
        end)

        Items["Hold"]:Connect("MouseButton1Down", function()
            Keybind.Mode = "Hold"
            Keybind:SetMode("Hold")
        end)

        Items["Always"]:Connect("MouseButton1Down", function()
            Keybind.Mode = "Always"
            Keybind:SetMode("Always")
        end)

        if Data.Default then 
            Keybind:Set({
                Mode = Data.Mode or "Toggle",
                Key = Data.Default,
            })
        end

        Library.SetFlags[Keybind.Flag] = function(Value)
            Keybind:Set(Value)
        end
        
        return Keybind, Items 
    end

    do 
        Library.Watermark = function(self, Name, Logo)
            local Watermark = {}
            local Items = {} do 
                Items["Watermark"] = Instances:Create("Frame", {
                    Parent = Library.Holder.Instance,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0.5, 0),
                    Position = UDim2New(0.5, 0, 0, 20),
                    Size = UDim2New(0, 0, 0, 35),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundColor3 = Library.Theme["Background"]
                }):AddToTheme({BackgroundColor3 = 'Background'})

                Items["Watermark"]:MakeDraggable()
                
                Instances:Create("UICorner", {
                    Parent = Items["Watermark"].Instance,
                    CornerRadius = UDimNew(0, 6)
                })
                
                Instances:Create("UIPadding", {
                    Parent = Items["Watermark"].Instance,
                    PaddingRight = UDimNew(0, 8),
                    PaddingLeft = UDimNew(0, 8)
                })
                
                Items["Logo"] = Instances:Create("ImageLabel", {
                    Parent = Items["Watermark"].Instance,
                    ScaleType = Enum.ScaleType.Fit,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0, 0.5),
                    Image = Logo,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0.5, 0),
                    Size = UDim2New(0, 25, 0, 25),
                    BorderSizePixel = 0
                })
                
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Watermark"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme["Text"],
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "Perccss in my sodaa",
                    AnchorPoint = Vector2New(0, 0.5),
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 34, 0.5, -1),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 18
                }):AddToTheme({TextColor3 = 'Text'})
            end

            function Watermark:SetText(Text)
                Items["Text"].Instance.Text = tostring(Text)
            end

            function Watermark:SetVisibility(Bool)
                Items["Watermark"].Instance.Visible = Bool 
            end

            function Watermark:SetCenter()
                local CenterPosition = Items["Watermark"].Instance.AbsolutePosition
                task_wait()
                Items["Watermark"].Instance.AnchorPoint = Vector2New(0, 0)
                Items["Watermark"].Instance.Position = UDim2New(0, CenterPosition.X, 0, CenterPosition.Y)
            end

            Watermark:SetText(Name)
            Watermark:SetCenter()
            return Watermark 
        end

        Library.Window = function(self, Data)
            Data = Data or {}

            local Window = {
                Name = Data.Name or Data.name or "Window",
                SubName = Data.SubName or Data.subname or "",
                Logo = Data.Logo or Data.logo or "rbxassetid://81441172534384",
                Pages = {},
                Items = {},
                IsOpen = false,
                MinimizeButton = nil,
                SearchableElements = {}
            }

            function Window:RegisterElement(Element, Type, Name, Section, Page)
                TableInsert(self.SearchableElements, {
                    Element = Element,
                    Type = Type,
                    Name = Name,
                    Section = Section,
                    Page = Page
                })
            end

            local Items = {} do
                Items["MainFrame"] = Instances:Create("Frame", {
                    Parent = Library.Holder.Instance,
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Position = UDim2New(0.522, 0, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 673, 0, 511),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Background"]
                }):AddToTheme({BackgroundColor3 = 'Background'})

                Items["MainFrame"]:MakeDraggable()
                Items["MainFrame"]:MakeResizeable(Vector2New(673, 511), Vector2New(9999, 9999))
                
                Instances:Create("UICorner", {
                    Parent = Items["MainFrame"].Instance,
                    CornerRadius = UDimNew(0, 6)
                })
                
                Items["Sidebar"] = Instances:Create("Frame", {
                    Parent = Items["MainFrame"].Instance,
                    BackgroundTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 200, 1, 0),
                    BorderSizePixel = 0
                })
                
                local BottomSeparator = InstanceNew("Frame")
                BottomSeparator.Parent = Items["Sidebar"].Instance
                BottomSeparator.AnchorPoint = Vector2New(0, 1)
                BottomSeparator.Position = UDim2New(0, 0, 1, -85)
                BottomSeparator.Size = UDim2New(1, 0, 0, 1)
                BottomSeparator.BackgroundColor3 = Library.Theme.Outline
                BottomSeparator.BorderSizePixel = 0

                local BottomTab = InstanceNew("Frame")
                BottomTab.Parent = Items["Sidebar"].Instance
                BottomTab.AnchorPoint = Vector2New(0, 1)
                BottomTab.Position = UDim2New(0, 0, 1, 20)
                BottomTab.Size = UDim2New(1, 0, 0, 105)
                BottomTab.BackgroundTransparency = 1

                local Avatar = InstanceNew("ImageLabel")
                Avatar.Parent = BottomTab
                Avatar.BackgroundTransparency = 1
                Avatar.Size = UDim2New(0, 52, 0, 52)
                Avatar.Position = UDim2New(0, 12, 0, 12)

                local AvatarCorner = InstanceNew("UICorner")
                AvatarCorner.CornerRadius = UDimNew(1, 0)
                AvatarCorner.Parent = Avatar

                local Username = InstanceNew("TextLabel")
                Username.Parent = BottomTab
                Username.BackgroundTransparency = 1
                Username.Position = UDim2New(0, 74, 0, 16)
                Username.Size = UDim2New(1, -84, 0, 18)
                Username.TextXAlignment = Enum.TextXAlignment.Left
                Username.FontFace = Library.Font
                Username.TextSize = 16
                Username.TextColor3 = Library.Theme.Text

                local anonConfigPath = "homxiide/anonymous_config.json"
                local isAnonymous = false

                if isfile(anonConfigPath) then
                    local success, decoded = pcall(function()
                        return HttpService:JSONDecode(readfile(anonConfigPath))
                    end)
                    if success and decoded and decoded.Anonymous ~= nil then
                        isAnonymous = decoded.Anonymous
                    end
                else
                    writefile(anonConfigPath, HttpService:JSONEncode({Anonymous = false}))
                end

                local function updateProfileDisplay()
                    if isAnonymous then
                        Avatar.Image = "rbxassetid://10444634125"
                        Username.Text = "Anonymous"
                    else
                        Avatar.Image = Players:GetUserThumbnailAsync(
                            LocalPlayer.UserId,
                            Enum.ThumbnailType.HeadShot,
                            Enum.ThumbnailSize.Size420x420
                        )
                        Username.Text = LocalPlayer.Name
                    end
                end

                updateProfileDisplay()

                local ProfileButton = InstanceNew("TextButton")
                ProfileButton.Size = UDim2New(1, 0, 1, 0)
                ProfileButton.BackgroundTransparency = 1
                ProfileButton.Text = ""
                ProfileButton.Parent = BottomTab
                ProfileButton.ZIndex = 5

                local currentDialog = nil

                local function toggleAnonymousMenu()
                    if currentDialog then
                        currentDialog:Destroy()
                        currentDialog = nil
                        return
                    end

                    local dialog = InstanceNew("Frame")
                    dialog.Name = "AnonymousDialog"
                    dialog.Size = UDim2New(0, 260, 0, 80)
                    dialog.Position = UDim2New(0.5, -130, 0.5, -40)
                    dialog.BackgroundColor3 = Library.Theme.Background
                    dialog.Parent = Items["MainFrame"].Instance
                    dialog.ZIndex = 10000
                    currentDialog = dialog

                    local stroke = InstanceNew("UIStroke")
                    stroke.Color = FromRGB(255, 0, 0)
                    stroke.Thickness = 1.5
                    stroke.Parent = dialog

                    local corner = InstanceNew("UICorner")
                    corner.CornerRadius = UDimNew(0, 8)
                    corner.Parent = dialog

                    local label = InstanceNew("TextLabel")
                    label.Size = UDim2New(0.6, 0, 1, 0)
                    label.Position = UDim2New(0.08, 0, 0, 0)
                    label.Text = "Modo Anônimo"
                    label.TextColor3 = Library.Theme.Text
                    label.FontFace = Library.Font
                    label.TextSize = 16
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.BackgroundTransparency = 1
                    label.ZIndex = 10001
                    label.Parent = dialog

                    local toggleContainer = InstanceNew("TextButton")
                    toggleContainer.Size = UDim2New(0, 45, 0, 24)
                    toggleContainer.Position = UDim2New(0.92, -45, 0.5, -12)
                    toggleContainer.BackgroundColor3 = isAnonymous and Library.Theme.Accent or Library.Theme.Element
                    toggleContainer.Text = ""
                    toggleContainer.AutoButtonColor = false
                    toggleContainer.ZIndex = 10001
                    toggleContainer.Parent = dialog

                    local tcCorner = InstanceNew("UICorner")
                    tcCorner.CornerRadius = UDimNew(1, 0)
                    tcCorner.Parent = toggleContainer

                    local tcStroke = InstanceNew("UIStroke")
                    tcStroke.Color = FromRGB(255, 0, 0)
                    tcStroke.Thickness = 1.5
                    tcStroke.Parent = toggleContainer

                    local circle = InstanceNew("Frame")
                    circle.Size = UDim2New(0, 16, 0, 16)
                    circle.Position = isAnonymous and UDim2New(1, -20, 0.5, -8) or UDim2New(0, 4, 0.5, -8)
                    circle.BackgroundColor3 = FromRGB(255, 255, 255)
                    circle.ZIndex = 10002
                    circle.Parent = toggleContainer

                    local circleCorner = InstanceNew("UICorner")
                    circleCorner.CornerRadius = UDimNew(1, 0)
                    circleCorner.Parent = circle

                    toggleContainer.MouseButton1Click:Connect(function()
                        isAnonymous = not isAnonymous
                        writefile(anonConfigPath, HttpService:JSONEncode({Anonymous = isAnonymous}))
                        updateProfileDisplay()

                        local targetPos = isAnonymous and UDim2New(1, -20, 0.5, -8) or UDim2New(0, 4, 0.5, -8)
                        local targetColor = isAnonymous and Library.Theme.Accent or Library.Theme.Element
                        
                        TweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
                        TweenService:Create(toggleContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = targetColor}):Play()
                    end)
                end

                ProfileButton.MouseButton1Click:Connect(function()
                    toggleAnonymousMenu()
                end)

                local ExpiresLabel = InstanceNew("TextLabel")
                ExpiresLabel.Parent = BottomTab
                ExpiresLabel.BackgroundTransparency = 1
                ExpiresLabel.Position = UDim2New(0, 74, 0, 38)
                ExpiresLabel.Size = UDim2New(0, 52, 0, 16)
                ExpiresLabel.TextXAlignment = Enum.TextXAlignment.Left
                ExpiresLabel.Text = "Status:"
                ExpiresLabel.FontFace = Library.Font
                ExpiresLabel.TextSize = 13
                ExpiresLabel.TextTransparency = 0.4
                ExpiresLabel.TextColor3 = Library.Theme.Text

                local Countdown = InstanceNew("TextLabel")
                Countdown.Parent = BottomTab
                Countdown.BackgroundTransparency = 1
                Countdown.Position = UDim2New(0, 130, 0, 38)
                Countdown.Size = UDim2New(1, -140, 0, 16)
                Countdown.TextXAlignment = Enum.TextXAlignment.Left
                Countdown.FontFace = Library.Font
                Countdown.TextSize = 13
                Countdown.TextColor3 = Library.Theme.Accent

                local phrases = {"Best Hub", "100% Safe", "Fast Loading", "No Lag", "Undetected", "Active Support"}
                Countdown.Text = phrases[1]
                local currentIndex = 1

                Library:Thread(function()
                    while true do
                        task_wait(3)
                        currentIndex = currentIndex % #phrases + 1

                        local fadeOut = TweenService:Create(Countdown, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1})
                        fadeOut:Play()
                        fadeOut.Completed:Wait()
                        
                        Countdown.Text = phrases[currentIndex]
                        
                        local fadeIn = TweenService:Create(Countdown, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 0})
                        fadeIn:Play()
                        fadeIn.Completed:Wait()
                    end
                end)

                Instances:Create("Frame", {
                    Parent = Items["Sidebar"].Instance,
                    AnchorPoint = Vector2New(1, 0),
                    Position = UDim2New(1, 0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 1, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Outline"]
                }):AddToTheme({BackgroundColor3 = 'Outline'})
                
                Items["Top"] = Instances:Create("Frame", {
                    Parent = Items["Sidebar"].Instance,
                    BackgroundTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 0, 70),
                    BorderSizePixel = 0
                })
                
                Items["Logo"] = Instances:Create("ImageLabel", {
                    Parent = Items["Top"].Instance,
                    ScaleType = Enum.ScaleType.Fit,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Image = Window.Logo,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 20, 0, 20),
                    Size = UDim2New(0, 30, 0, 30),
                    BorderSizePixel = 0
                })
                
                Items["Title"] = Instances:Create("TextLabel", {
                    Parent = Items["Top"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme["Text"],
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Window.Name,
                    Size = UDim2New(0, 0, 0, 14),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 60, 0, 15),
                    TextWrapped = true,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 18
                }):AddToTheme({TextColor3 = 'Text'})
                
                Items["Subtitle"] = Instances:Create("TextLabel", {
                    Parent = Items["Top"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme["Text"],
                    TextTransparency = 0.4,
                    Text = Window.SubName,
                    Size = UDim2New(0, 0, 0, 14),
                    BorderColor3 = FromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 60, 0, 36),
                    TextWrapped = true,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 16
                }):AddToTheme({TextColor3 = 'Text'})
                
                Instances:Create("Frame", {
                    Parent = Items["Top"].Instance,
                    AnchorPoint = Vector2New(0, 1),
                    Position = UDim2New(0, 0, 1, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 0, 1),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Outline"]
                }):AddToTheme({BackgroundColor3 = 'Outline'})

                Items["SearchBarContainer"] = Instances:Create("Frame", {
                    Parent = Items["Sidebar"].Instance,
                    Name = "SearchBarContainer",
                    Position = UDim2New(0, 8, 0, 78),
                    Size = UDim2New(1, -16, 0, 32),
                    BackgroundColor3 = Library.Theme["Element"],
                    BorderSizePixel = 0
                }):AddToTheme({BackgroundColor3 = 'Element'})

                Instances:Create("UICorner", {
                    Parent = Items["SearchBarContainer"].Instance,
                    CornerRadius = UDimNew(0, 6)
                })

                Instances:Create("UIStroke", {
                    Parent = Items["SearchBarContainer"].Instance,
                    Color = Library.Theme["Outline"],
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = 'Outline'})

                Items["SearchIcon"] = Instances:Create("ImageLabel", {
                    Parent = Items["SearchBarContainer"].Instance,
                    Name = "SearchIcon",
                    ScaleType = Enum.ScaleType.Fit,
                    Image = "rbxassetid://11419712174",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 8, 0.5, -8),
                    Size = UDim2New(0, 16, 0, 16),
                    BorderSizePixel = 0,
                    ImageColor3 = Library.Theme["Text"],
                    ImageTransparency = 0.5
                }):AddToTheme({ImageColor3 = 'Text'})

                Items["SearchInput"] = Instances:Create("TextBox", {
                    Parent = Items["SearchBarContainer"].Instance,
                    Name = "SearchInput",
                    FontFace = Library.Font,
                    PlaceholderText = "Search section or Fun",
                    PlaceholderColor3 = FromRGB(133, 139, 143),
                    TextSize = 14,
                    TextColor3 = Library.Theme["Text"],
                    Text = "",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 30, 0, 0),
                    Size = UDim2New(1, -38, 1, 0),
                    BorderSizePixel = 0,
                    TextXAlignment = Enum.TextXAlignment.Left
                }):AddToTheme({TextColor3 = 'Text'})
                
                Items["Pages"] = Instances:Create("ScrollingFrame", {
                    Parent = Items["Sidebar"].Instance,
                    Active = true,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    BorderSizePixel = 0,
                    CanvasSize = UDim2New(0, 0, 0, 0),
                    ScrollBarImageColor3 = Library.Theme["Accent"],
                    MidImage = "rbxassetid://128693616966482",
                    BorderColor3 = FromRGB(0, 0, 0),
                    ScrollBarThickness = 3,
                    Size = UDim2New(1, -16, 1, -225),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 8, 0, 118),
                    BottomImage = "rbxassetid://128693616966482",
                    TopImage = "rbxassetid://128693616966482"
                }):AddToTheme({ScrollBarImageColor3 = 'Accent'})
                
                Instances:Create("UIListLayout", {
                    Parent = Items["Pages"].Instance,
                    Padding = UDimNew(0, 8),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                Instances:Create("UIPadding", {
                    Parent = Items["Pages"].Instance,
                    PaddingTop = UDimNew(0, 8),
                    PaddingBottom = UDimNew(0, 8),
                    PaddingRight = UDimNew(0, 8),
                    PaddingLeft = UDimNew(0, 8)
                })

                Items["Content"] = Instances:Create("Frame", {
                    Parent = Items["MainFrame"].Instance,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 200, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, -200, 1, 0),
                    BorderSizePixel = 0
                })                
                
                Window.Items = Items
            end

            local searchOverlay = Instances:Create("Frame", {
                Parent = Items["MainFrame"].Instance,
                Name = "SearchOverlay",
                Size = UDim2New(1, 0, 1, 0),
                Position = UDim2New(0, 0, 0, 0),
                BackgroundColor3 = FromRGB(10, 10, 10),
                BackgroundTransparency = 1,
                Visible = false,
                ZIndex = 500
            })

            local searchPopup = Instances:Create("Frame", {
                Parent = searchOverlay.Instance,
                Name = "SearchPopup",
                AnchorPoint = Vector2New(0.5, 0.5),
                Position = UDim2New(0.5, 0, 0.5, 0),
                Size = UDim2New(0, 420, 0, 320),
                BackgroundColor3 = Library.Theme["Inline"],
                BorderSizePixel = 0,
                ZIndex = 501
            }):AddToTheme({BackgroundColor3 = 'Inline'})

            Instances:Create("UICorner", {
                Parent = searchPopup.Instance,
                CornerRadius = UDimNew(0, 8)
            })

            Instances:Create("UIStroke", {
                Parent = searchPopup.Instance,
                Color = Library.Theme["Outline"],
                Thickness = 1.5,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = 'Outline'})

            Instances:Create("TextLabel", {
                Parent = searchPopup.Instance,
                FontFace = Library.Font,
                Text = "Search Results",
                TextColor3 = Library.Theme["Text"],
                TextSize = 16,
                Size = UDim2New(1, -20, 0, 40),
                Position = UDim2New(0, 15, 0, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 502
            }):AddToTheme({TextColor3 = 'Text'})

            local SearchCloseBtn = Instances:Create("TextButton", {
                Parent = searchPopup.Instance,
                FontFace = Library.Font,
                Text = "X",
                TextColor3 = Library.Theme["Text"],
                TextSize = 16,
                Size = UDim2New(0, 30, 0, 30),
                Position = UDim2New(1, -35, 0, 5),
                BackgroundTransparency = 1,
                ZIndex = 502
            }):AddToTheme({TextColor3 = 'Text'})

            local SearchScroll = Instances:Create("ScrollingFrame", {
                Parent = searchPopup.Instance,
                Active = true,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2New(1, -20, 1, -55),
                Position = UDim2New(0, 10, 0, 45),
                CanvasSize = UDim2New(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = Library.Theme["Accent"],
                ZIndex = 502
            }):AddToTheme({ScrollBarImageColor3 = 'Accent'})

            Instances:Create("UIListLayout", {
                Parent = SearchScroll.Instance,
                Padding = UDimNew(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            local isSearchOpen = false
            local function setSearchOpen(bool)
                if isSearchOpen == bool then return end
                isSearchOpen = bool

                if bool then
                    searchOverlay.Instance.Visible = true
                    searchPopup.Instance.Size = UDim2New(0, 300, 0, 200)
                    searchOverlay.Instance.BackgroundTransparency = 1
                    
                    TweenService:Create(searchOverlay.Instance, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5}):Play()
                    TweenService:Create(searchPopup.Instance, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2New(0, 420, 0, 320)}):Play()
                else
                    TweenService:Create(searchOverlay.Instance, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
                    local tween = TweenService:Create(searchPopup.Instance, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2New(0, 300, 0, 200)})
                    tween:Play()
                    tween.Completed:Connect(function()
                        if not isSearchOpen then searchOverlay.Instance.Visible = false end
                    end)
                end
            end

            SearchCloseBtn:Connect("MouseButton1Click", function()
                setSearchOpen(false)
                Items["SearchInput"].Instance.Text = ""
            end)

            local function performSearch(query)
                for _, child in ipairs(SearchScroll.Instance:GetChildren()) do
                    if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") then
                        child:Destroy()
                    end
                end

                if query == "" then
                    setSearchOpen(false)
                    return
                end

                setSearchOpen(true)
                query = StringLower(query)

                local matches = {}
                for _, info in ipairs(Window.SearchableElements) do
                    if StringFind(StringLower(info.Name), query, 1, true) then
                        TableInsert(matches, info)
                    end
                end

                if #matches == 0 then
                    Instances:Create("TextLabel", {
                        Parent = SearchScroll.Instance,
                        FontFace = Library.Font,
                        Text = "No results found.",
                        TextColor3 = Library.Theme["Text"],
                        TextSize = 14,
                        Size = UDim2New(1, 0, 0, 40),
                        BackgroundTransparency = 1,
                        TextTransparency = 0.5,
                        ZIndex = 503
                    }):AddToTheme({TextColor3 = 'Text'})
                    return
                end

                for _, match in ipairs(matches) do
                    local itemButton = Instances:Create("TextButton", {
                        Parent = SearchScroll.Instance,
                        Size = UDim2New(1, -6, 0, 42),
                        BackgroundColor3 = Library.Theme["Element"],
                        BorderSizePixel = 0,
                        Text = "",
                        AutoButtonColor = false,
                        ZIndex = 503
                    }):AddToTheme({BackgroundColor3 = 'Element'})

                    Instances:Create("UICorner", {
                        Parent = itemButton.Instance,
                        CornerRadius = UDimNew(0, 6)
                    })

                    Instances:Create("UIStroke", {
                        Parent = itemButton.Instance,
                        Color = Library.Theme["Outline"],
                        Thickness = 1,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    }):AddToTheme({Color = 'Outline'})

                    Instances:Create("ImageLabel", {
                        Parent = itemButton.Instance,
                        Size = UDim2New(0, 18, 0, 18),
                        Position = UDim2New(0, 10, 0.5, -9),
                        BackgroundTransparency = 1,
                        Image = match.Page.Icon,
                        ImageColor3 = Library.Theme["Text"],
                        BorderSizePixel = 0,
                        ZIndex = 504
                    }):AddToTheme({ImageColor3 = 'Text'})

                    local pathText = StringFormat("[%s > %s]", match.Page.Name, match.Section.Name)
                    Instances:Create("TextLabel", {
                        Parent = itemButton.Instance,
                        FontFace = Library.Font,
                        Text = StringFormat("%s <font color='rgb(150, 150, 150)'>%s</font>", match.Name, pathText),
                        TextColor3 = Library.Theme["Text"],
                        TextSize = 14,
                        RichText = true,
                        Size = UDim2New(1, -70, 1, 0),
                        Position = UDim2New(0, 36, 0, 0),
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 504
                    }):AddToTheme({TextColor3 = 'Text'})

                    Instances:Create("TextLabel", {
                        Parent = itemButton.Instance,
                        FontFace = Library.Font,
                        Text = "→",
                        TextColor3 = Library.Theme["Accent"],
                        TextSize = 16,
                        Size = UDim2New(0, 30, 1, 0),
                        Position = UDim2New(1, -40, 0, 0),
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        ZIndex = 504
                    }):AddToTheme({TextColor3 = 'Accent'})

                    local elemColor = Library.Theme["Element"]
                    local hoverColor = FromRGB(
                        MathMin(elemColor.R * 255 + 12, 255),
                        MathMin(elemColor.G * 255 + 12, 255),
                        MathMin(elemColor.B * 255 + 12, 255)
                    )

                    itemButton:Connect("MouseEnter", function()
                        TweenService:Create(itemButton.Instance, TweenInfo.new(0.15), {BackgroundColor3 = hoverColor}):Play()
                    end)

                    itemButton:Connect("MouseLeave", function()
                        TweenService:Create(itemButton.Instance, TweenInfo.new(0.15), {BackgroundColor3 = Library.Theme["Element"]}):Play()
                    end)

                    itemButton:Connect("MouseButton1Click", function()
                        for _, p in ipairs(Window.Pages) do
                            p:Turn(p == match.Page)
                        end

                        setSearchOpen(false)
                        Items["SearchInput"].Instance.Text = ""

                        local sectionOutline = match.Section.Items["SectionOutline"].Instance
                        local originalColor = sectionOutline.BackgroundColor3

                        TweenService:Create(sectionOutline, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Library.Theme["Accent"]}):Play()

                        task_delay(1, function()
                            TweenService:Create(sectionOutline, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundThickness = 0, BackgroundColor3 = originalColor}):Play()
                        end)
                    end)
                end
            end

            Library:Connect(Items["SearchInput"].Instance:GetPropertyChangedSignal("Text"), function()
                performSearch(Items["SearchInput"].Instance.Text)
            end)
            
            local Debounce = false

            function Window:SetCenter()
                local CenterPosition = Items["MainFrame"].Instance.AbsolutePosition
                task_wait()
                Items["MainFrame"].Instance.AnchorPoint = Vector2New(0, 0)
                Items["MainFrame"].Instance.Position = UDim2New(0, CenterPosition.X, 0, CenterPosition.Y)
            end

            function Window:SetOpen(Bool)
                if Debounce then return end
                Window.IsOpen = Bool
                Debounce = true 

                if Window.IsOpen then Items["MainFrame"].Instance.Visible = true end

                if not Bool then
                    for _, OpenFrame in pairs(Library.OpenFrames) do OpenFrame:SetOpen(false) end
                end

                local Descendants = Items["MainFrame"].Instance:GetDescendants()
                TableInsert(Descendants, Items["MainFrame"].Instance)

                local NewTween
                for _, Value in ipairs(Descendants) do 
                    local TransparencyProperty = Tween:GetProperty(Value)
                    if TransparencyProperty then
                        if type(TransparencyProperty) == "table" then 
                            for _, Property in ipairs(TransparencyProperty) do 
                                NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                            end
                        else
                            NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                        end
                    end
                end
                
                NewTween.Tween.Completed:Connect(function()
                    Debounce = false 
                    Items["MainFrame"].Instance.Visible = Window.IsOpen
                end)
            end

            if Data.MinimizeButton ~= false then
                local ToggleButton = InstanceNew("ImageButton")
                ToggleButton.Name = "ToggleButton"
                ToggleButton.Parent = Library.Holder.Instance
                ToggleButton.Size = UDim2New(0, 70, 0, 70)
                ToggleButton.Position = UDim2New(0.03, 0, 0.4, 0)
                ToggleButton.BackgroundColor3 = FromRGB(15, 15, 15)
                ToggleButton.Image = "rbxassetid://128395878680071"
                ToggleButton.AutoButtonColor = false
                ToggleButton.Active = true
                ToggleButton.ZIndex = 9999

                local UICorner = InstanceNew("UICorner")
                UICorner.CornerRadius = UDimNew(0, 18)
                UICorner.Parent = ToggleButton

                local UIStroke = InstanceNew("UIStroke")
                UIStroke.Color = FromRGB(255, 0, 0)
                UIStroke.Thickness = 3
                UIStroke.Parent = ToggleButton

                local UIGradient = InstanceNew("UIGradient")
                UIGradient.Color = RGBSequence{
                    RGBSequenceKeypoint(0, FromRGB(255, 0, 0)),
                    RGBSequenceKeypoint(1, FromRGB(0, 0, 0))
                }
                UIGradient.Rotation = 45
                UIGradient.Parent = ToggleButton

                local Shadow = InstanceNew("Frame")
                Shadow.Name = "Shadow"
                Shadow.Parent = ToggleButton
                Shadow.AnchorPoint = Vector2New(0.5, 0.5)
                Shadow.Position = UDim2New(0.5, 0, 0.5, 4)
                Shadow.Size = UDim2New(1, 8, 1, 8)
                Shadow.BackgroundColor3 = FromRGB(255, 0, 0)
                Shadow.BackgroundTransparency = 0.8
                Shadow.ZIndex = 0

                local ShadowCorner = InstanceNew("UICorner")
                ShadowCorner.CornerRadius = UDimNew(0, 20)
                ShadowCorner.Parent = Shadow

                ToggleButton.ZIndex = 2

                ToggleButton.MouseEnter:Connect(function()
                    TweenService:Create(ToggleButton, TweenInfo.new(0.15), { Size = UDim2New(0, 75, 0, 75) }):Play()
                end)

                ToggleButton.MouseLeave:Connect(function()
                    TweenService:Create(ToggleButton, TweenInfo.new(0.15), { Size = UDim2New(0, 70, 0, 70) }):Play()
                end)

                ToggleButton.MouseButton1Click:Connect(function()
                    Window:SetOpen(not Window.IsOpen)
                end)

                local dragging = false
                local dragInput, dragStart, startPos

                local function updateDrag(input)
                    local delta = input.Position - dragStart
                    ToggleButton.Position = UDim2New(
                        startPos.X.Scale,
                        startPos.X.Offset + delta.X,
                        startPos.Y.Scale,
                        startPos.Y.Offset + delta.Y
                    )
                end

                ToggleButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        dragStart = input.Position
                        startPos = ToggleButton.Position

                        input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then
                                dragging = false
                            end
                        end)
                    end
                end)

                ToggleButton.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        dragInput = input
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if input == dragInput and dragging then
                        updateDrag(input)
                    end
                end)

                Window.MinimizeButton = ToggleButton
            end

            Library:Connect(UserInputService.InputBegan, function(Input)
                if tostring(Input.KeyCode) == Library.MenuKeybind or tostring(Input.UserInputType) == Library.MenuKeybind then
                    Window:SetOpen(not Window.IsOpen)
                end
            end)

            Window:SetCenter()
            task_wait()
            Window:SetOpen(true)
            return setmetatable(Window, Library)
        end

        Library.Page = function(self, Data)
            Data = Data or {}

            local Page = {
                Window = self,
                Name = Data.Name or Data.name or "Page",
                Icon = Data.Icon or Data.icon or "rbxassetid://72196061405823",
                Items = {},
                Active = false
            }

            local Items = {} do 
                Items["Inactive"] = Instances:Create("TextButton", {
                    Parent = Page.Window.Items["Pages"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, 35),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    TextSize = 14,
                    BackgroundColor3 = Library.Theme["Accent"]
                }):AddToTheme({BackgroundColor3 = 'Accent'})
                
                Items["Background"] = Instances:Create("Frame", {
                    Parent = Items["Inactive"].Instance,
                    BackgroundTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 0, 0, 35),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Accent"]
                }):AddToTheme({BackgroundColor3 = 'Accent'})
                
                Items["Icon"] = Instances:Create("ImageLabel", {
                    Parent = Items["Inactive"].Instance,
                    ScaleType = Enum.ScaleType.Fit,
                    ImageTransparency = 0.4,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0, 0.5),
                    Image = Page.Icon,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 8, 0.5, 0),
                    Size = UDim2New(0, 18, 0, 18),
                    BorderSizePixel = 0
                }):AddToTheme({ImageColor3 = 'Text'})
                
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Inactive"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme["Text"],
                    TextTransparency = 0.4,
                    Text = Page.Name,
                    Size = UDim2New(0, 0, 0, 15),
                    AnchorPoint = Vector2New(0, 0.5),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 38, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 16
                }):AddToTheme({TextColor3 = 'Text'})
                
                Instances:Create("UICorner", {
                    Parent = Items["Background"].Instance,
                    CornerRadius = UDimNew(0, 6)
                })                

                Items["Page"] = Instances:Create("Frame", {
                    Parent = Library.UnusedHolder.Instance,
                    Visible = false,
                    BackgroundTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 1, 0),
                    BorderSizePixel = 0
                })
                
                Instances:Create("UIListLayout", {
                    Parent = Items["Page"].Instance,
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalFlex = Enum.UIFlexAlignment.Fill,
                    Padding = UDimNew(0, 10),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                Items["Column"] = Instances:Create("ScrollingFrame", {
                    Parent = Items["Page"].Instance,
                    ScrollBarImageColor3 = FromRGB(0, 0, 0),
                    Active = true,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollBarThickness = 0,
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 1, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    CanvasSize = UDim2New(0, 0, 0, 0)
                })
                
                Instances:Create("UIPadding", {
                    Parent = Items["Column"].Instance,
                    PaddingTop = UDimNew(0, 10),
                    PaddingBottom = UDimNew(0, 10),
                    PaddingRight = UDimNew(0, 10),
                    PaddingLeft = UDimNew(0, 10)
                })
                
                Instances:Create("UIListLayout", {
                    Parent = Items["Column"].Instance,
                    Padding = UDimNew(0, 10),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })           
                
                Page.Items = Items
            end

            local Debounce = false

            function Page:Turn(Bool)
                if Debounce then return end
                Page.Active = Bool 
                Debounce = true
                Items["Page"].Instance.Visible = Bool 
                Items["Page"].Instance.Parent = Bool and Page.Window.Items["Content"].Instance or Library.UnusedHolder.Instance

                if Page.Active then
                    Items["Background"]:Tween(nil, {BackgroundTransparency = 0, Size = UDim2New(1, 0, 0, 35)})
                    Items["Text"]:ChangeItemTheme({TextColor3 = function() return FromRGB(0, 0, 0) end})
                    Items["Icon"]:ChangeItemTheme({ImageColor3 = function() return FromRGB(0, 0, 0) end})
                    Items["Text"]:Tween(nil, {TextColor3 = FromRGB(0, 0, 0), TextTransparency = 0})
                    Items["Icon"]:Tween(nil, {ImageColor3 = FromRGB(0, 0, 0), ImageTransparency = 0})
                else
                    Items["Background"]:Tween(nil, {BackgroundTransparency = 1, Size = UDim2New(0, 0, 0, 35)})
                    Items["Text"]:ChangeItemTheme({TextColor3 = "Text"})
                    Items["Icon"]:ChangeItemTheme({ImageColor3 = "Text"})
                    Items["Text"]:Tween(nil, {TextColor3 = Library.Theme.Text, TextTransparency = 0.4})
                    Items["Icon"]:Tween(nil, {ImageColor3 = Library.Theme.Text, ImageTransparency = 0.4})
                end

                local AllInstances = Items["Page"].Instance:GetDescendants()
                TableInsert(AllInstances, Items["Page"].Instance)
                
                local NewTween 
                for _, Value in ipairs(AllInstances) do 
                    local TransparencyProperty = Tween:GetProperty(Value)
                    if TransparencyProperty then 
                        if type(TransparencyProperty) == "table" then 
                            for _, Property in ipairs(TransparencyProperty) do 
                                NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                            end
                        else
                            NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                        end
                    end
                end

                Library:Connect(NewTween.Tween.Completed, function()
                    Debounce = false
                end)
            end

            Items["Inactive"]:Connect("MouseButton1Down", function()
                for _, Value in ipairs(Page.Window.Pages) do 
                    if not (Value == Page and Page.Active) then
                        Value:Turn(Value == Page)
                    end
                end
            end)

            if #Page.Window.Pages == 0 then 
                Page:Turn(true)
            end

            TableInsert(Page.Window.Pages, Page)
            return setmetatable(Page, Library.Pages)
        end

        local OriginalSectionFunction = Library.Pages.Section
        Library.Pages.Section = function(self, Data)
            Data = Data or {}

            local Section = {
                Window = self.Window,
                Page = self,
                Name = Data.Name or Data.name or "Section",
                Side = Data.Side or Data.side or 1,
                Icon = Data.Icon or Data.icon or "rbxassetid://127136375066593",
                Items = {}
            }

            local Items = {} do
                Items["SectionOutline"] = Instances:Create("Frame", {
                    Parent = Section.Page.Items["Column"].Instance,
                    Size = UDim2New(1, 0, 0, 50),
                    BorderColor3 = FromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Library.Theme["Outline"]
                }):AddToTheme({BackgroundColor3 = 'Outline'})
                
                Instances:Create("UICorner", {
                    Parent = Items["SectionOutline"].Instance
                })
                
                Items["Section"] = Instances:Create("Frame", {
                    Parent = Items["SectionOutline"].Instance,
                    Position = UDim2New(0, 1, 0, 1),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, -2, 1, -2),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Inline"]
                }):AddToTheme({BackgroundColor3 = 'Inline'})
                
                Instances:Create("UICorner", {
                    Parent = Items["Section"].Instance
                })
                
                Items["Top"] = Instances:Create("Frame", {
                    Parent = Items["Section"].Instance,
                    BackgroundTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 0, 40),
                    BorderSizePixel = 0
                })
                
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Top"].Instance,
                    FontFace = Library.Font,
                    TextWrapped = true,
                    TextColor3 = Library.Theme["Text"],
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Section.Name,
                    Size = UDim2New(0, 0, 0, 14),
                    AnchorPoint = Vector2New(0, 0.5),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 40, 0.5, -2),
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 16
                }):AddToTheme({TextColor3 = 'Text'})
                
                Instances:Create("Frame", {
                    Parent = Items["Top"].Instance,
                    AnchorPoint = Vector2New(0, 1),
                    Position = UDim2New(0, 0, 1, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 0, 1),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Outline"]
                }):AddToTheme({BackgroundColor3 = 'Outline'})
                
                Items["Icon"] = Instances:Create("ImageLabel", {
                    Parent = Items["Top"].Instance,
                    ImageColor3 = Library.Theme["Text"],
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0, 0.5),
                    Image = Section.Icon,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 10, 0.5, 0),
                    Size = UDim2New(0, 18, 0, 18),
                    BorderSizePixel = 0
                }):AddToTheme({ImageColor3 = 'Text'})
                
                Items["Content"] = Instances:Create("Frame", {
                    Parent = Items["Section"].Instance,
                    BorderColor3 = FromRGB(0, 0, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0, 40),
                    Size = UDim2New(1, 0, 0, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.Y
                })
                
                Instances:Create("UIPadding", {
                    Parent = Items["Content"].Instance,
                    PaddingTop = UDimNew(0, 6),
                    PaddingBottom = UDimNew(0, 10),
                    PaddingRight = UDimNew(0, 10),
                    PaddingLeft = UDimNew(0, 10)
                })
                
                Instances:Create("UIListLayout", {
                    Parent = Items["Content"].Instance,
                    Padding = UDimNew(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })                
                
                Section.Items = Items
            end

            return setmetatable(Section, Library.Sections)
        end

        Library.Sections.Toggle = function(self, Data)
            Data = Data or {}

            local Toggle = {
                Window = self.Window,
                Page = self.Page,
                Section = self,
                Name = Data.Name or Data.name or "Toggle",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Default = Data.Default or Data.default or false,
                Callback = Data.Callback or Data.callback or function() end,
                Value = false
            }

            local Items = {} do 
                Items["Toggle"] = Instances:Create("TextButton", {
                    Parent = Toggle.Section.Items["Content"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(1, 0),
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, 20),
                    BorderSizePixel = 0,
                    TextSize = 14
                })
                
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Toggle"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme["Text"],
                    TextTransparency = 0.5,
                    Text = Toggle.Name,
                    Size = UDim2New(0, 0, 0, 15),
                    AnchorPoint = Vector2New(0, 0.5),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 16
                }):AddToTheme({TextColor3 = 'Text'})
                
                Items["Indicator"] = Instances:Create("Frame", {
                    Parent = Items["Toggle"].Instance,
                    AnchorPoint = Vector2New(1, 0.5),
                    Position = UDim2New(1, 0, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 35, 0, 18),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Element"]
                }):AddToTheme({BackgroundColor3 = 'Element'})
                
                Instances:Create("UICorner", {
                    Parent = Items["Indicator"].Instance
                })
                
                Instances:Create("UIStroke", {
                    Parent = Items["Indicator"].Instance,
                    Color = Library.Theme["Outline"],
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = 'Outline'})
                
                Items["Circle"] = Instances:Create("Frame", {
                    Parent = Items["Indicator"].Instance,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0, 0.5),
                    BackgroundTransparency = 0.5,
                    Position = UDim2New(0, 4, 0.5, 0),
                    Size = UDim2New(0, 10, 0, 10),
                    BorderSizePixel = 0
                }):AddToTheme({BackgroundColor3 = function() return FromRGB(255, 255, 255) end})
                
                Instances:Create("UICorner", {
                    Parent = Items["Circle"].Instance,
                    CornerRadius = UDimNew(1, 0)
                })
                
                Items["Glow"] = Instances:Create("ImageLabel", {
                    Parent = Items["Circle"].Instance,
                    ImageColor3 = Library.Theme["Accent"],
                    ScaleType = Enum.ScaleType.Slice,
                    ImageTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 25, 1, 25),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Image = "http://www.roblox.com/asset/?id=18245826428",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    BorderSizePixel = 0,
                    SliceCenter = RectNew(Vector2New(21, 21), Vector2New(79, 79))
                }):AddToTheme({ImageColor3 = 'Accent'})                
            end

            function Toggle:Get() return Toggle.Value end

            function Toggle:Set(Value)
                Toggle.Value = Value 
                Library.Flags[Toggle.Flag] = Value 

                if Toggle.Value then 
                    Items["Glow"]:Tween(nil, {ImageTransparency = 0.7})
                    Items["Circle"]:ChangeItemTheme({BackgroundColor3 = "Accent"})
                    Items["Circle"]:Tween(nil, {
                        AnchorPoint = Vector2New(1, 0.5),
                        Position = UDim2New(1, -3, 0.5, 0),
                        BackgroundTransparency = 0,
                        BackgroundColor3 = Library.Theme.Accent
                    })
                    Items["Text"]:Tween(nil, {TextTransparency = 0})
                else
                    Items["Glow"]:Tween(nil, {ImageTransparency = 1})
                    Items["Circle"]:ChangeItemTheme({BackgroundColor3 = function() return FromRGB(255, 255, 255) end})
                    Items["Circle"]:Tween(nil, {
                        AnchorPoint = Vector2New(0, 0.5),
                        Position = UDim2New(0, 3, 0.5, 0),
                        BackgroundTransparency = 0.6,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })
                    Items["Text"]:Tween(nil, {TextTransparency = 0.5})
                end

                if Toggle.Callback then Library:SafeCall(Toggle.Callback, Toggle.Value) end
            end

            function Toggle:SetVisibility(Bool)
                Items["Toggle"].Instance.Visible = Bool 
            end

            function Toggle:Colorpicker(Data)
                Data = Data or {}
                local Colorpicker = {
                    Window = Toggle.Window,
                    Page = Toggle.Page,
                    Section = Toggle.Section,
                    Flag = Data.Flag or Data.flag or Library:NextFlag(),
                    Default = Data.Default or Data.default or FromRGB(255, 255, 255),
                    Callback = Data.Callback or Data.callback or function() end,
                    Alpha = Data.Alpha or Data.alpha or false
                }

                local NewColorpicker, _ = Library:CreateColorpicker({
                    Parent = Items["SubElements"] or Items["Toggle"],
                    Page = Colorpicker.Page,
                    Section = Colorpicker.Section,
                    Flag = Colorpicker.Flag,
                    Default = Colorpicker.Default,
                    Callback = Colorpicker.Callback,
                    Alpha = Colorpicker.Alpha
                })
                return NewColorpicker
            end

            function Toggle:Keybind(Data)
                Data = Data or {}
                local Keybind = {
                    Window = Toggle.Window,
                    Page = Toggle.Page,
                    Section = Toggle.Section,
                    Flag = Data.Flag or Data.flag or Library:NextFlag(),
                    Default = Data.Default or Data.default or Enum.KeyCode.E,
                    Callback = Data.Callback or Data.callback or function() end,
                    Mode = Data.Mode or Data.mode or "Toggle"
                }

                local NewKeybind, _ = Library:CreateKeybind({
                    Parent = Items["SubElements"] or Items["Toggle"],
                    Page = Keybind.Page,
                    Section = Keybind.Section,
                    Flag = Keybind.Flag,
                    Default = Keybind.Default,
                    Mode = Keybind.Mode,
                    Callback = Keybind.Callback
                })
                return NewKeybind
            end

            Items["Toggle"]:Connect("MouseButton1Down", function()
                Toggle:Set(not Toggle.Value)
            end)

            Toggle:Set(Toggle.Default)
            Toggle.Section.Window:RegisterElement(Toggle, "Toggle", Toggle.Name, Toggle.Section, Toggle.Page)

            Library.SetFlags[Toggle.Flag] = function(Value)
                Toggle:Set(Value)
            end

            return Toggle 
        end

        Library.Sections.Button = function(self, Data)
            Data = Data or {}

            local Button = {
                Window = self.Window,
                Page = self.Page,
                Section = self,
                Name = Data.Name or Data.name or "Button",
                Callback = Data.Callback or Data.callback or function() end
            }

            local Items = {} do 
                Items["Button"] = Instances:Create("TextButton", {
                    Parent = Button.Section.Items["Content"].Instance,
                    TextColor3 = Library.Theme["Text"],
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    Size = UDim2New(1, 0, 0, 30),
                    Selectable = false,
                    Active = false,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Element"]
                }):AddToTheme({BackgroundColor3 = 'Element'})
                
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Button"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme["Text"],
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Button.Name,
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 16
                }):AddToTheme({TextColor3 = 'Text'})
                
                Instances:Create("UICorner", {
                    Parent = Items["Button"].Instance,
                    CornerRadius = UDimNew(0, 6)
                })
                
                Items["Stroke"] = Instances:Create("UIStroke", {
                    Parent = Items["Button"].Instance,
                    Color = Library.Theme["Outline"],
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = 'Outline'})
                
                Items["Icon"] = Instances:Create("ImageLabel", {
                    Parent = Items["Button"].Instance,
                    ImageColor3 = Library.Theme["Text"],
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 16, 0, 16),
                    AnchorPoint = Vector2New(1, 0.5),
                    Image = "rbxassetid://117716971575946",
                    BackgroundTransparency = 1,
                    Position = UDim2New(1, -6, 0.5, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0
                }):AddToTheme({ImageColor3 = 'Text'})                
            end 

            function Button:SetVisibility(Bool)
                Items["Button"].Instance.Visible = Bool
            end

            function Button:Press()
                Items["Stroke"]:ChangeItemTheme({Color = "Accent"})
                Items["Stroke"]:Tween(nil, {Color = Library.Theme.Accent})
                task_wait(0.1)
                Library:SafeCall(Button.Callback)
                Items["Stroke"]:ChangeItemTheme({Color = "Outline"})
                Items["Stroke"]:Tween(nil, {Color = Library.Theme.Outline})
            end

            Items["Button"]:Connect("MouseButton1Down", function() Button:Press() end)
            Button.Section.Window:RegisterElement(Button, "Button", Button.Name, Button.Section, Button.Page)
            return Button
        end

        Library.Sections.Slider = function(self, Data)
            Data = Data or {}

            local Min = Data.Min or Data.min or 0
            local Max = Data.Max or Data.max or 100
            local Default = Data.Default or Data.default or 0

            -- Proteção para garantir que os valores limites não sejam NaN ou Infinitos
            if Min ~= Min or Min == math.huge or Min == -math.huge then Min = 0 end
            if Max ~= Max or Max == math.huge or Max == -math.huge then Max = 100 end
            if Default ~= Default then Default = Min end
            if Min >= Max then Max = Min + 1 end

            local Slider = {
                Window = self.Window,
                Page = self.Page,
                Section = self,
                Name = Data.Name or Data.name or "Slider",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Min = Min,
                Default = Default,
                Max = Max,
                Suffix = Data.Suffix or Data.suffix or "",
                Decimals = Data.Decimals or Data.decimals or 1,
                Callback = Data.Callback or Data.callback or function() end,
                Value = 0,
                Sliding = false
            }

            local Items = {} do 
                Items["Slider"] = Instances:Create("Frame", {
                    Parent = Slider.Section.Items["Content"].Instance,
                    BackgroundTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 0, 20),
                    BorderSizePixel = 0
                })
                
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Slider"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme["Text"],
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Slider.Name,
                    AnchorPoint = Vector2New(0, 0.5),
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0.5, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 16
                }):AddToTheme({TextColor3 = 'Text'})
                
                Items["RealSlider"] = Instances:Create("TextButton", {
                    Parent = Items["Slider"].Instance,
                    Active = false,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(1, 0.5),
                    Position = UDim2New(1, -40, 0.5, 0),
                    Size = UDim2New(0, 200, 0, 9),
                    Selectable = false,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Element"]
                }):AddToTheme({BackgroundColor3 = 'Element'})
                
                Instances:Create("UICorner", {
                    Parent = Items["RealSlider"].Instance,
                    CornerRadius = UDimNew(0, 6)
                })
                
                Instances:Create("UIStroke", {
                    Parent = Items["RealSlider"].Instance,
                    Color = Library.Theme["Outline"],
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = 'Outline'})
                
                Items["Accent"] = Instances:Create("Frame", {
                    Parent = Items["RealSlider"].Instance,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0.6, 0, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Accent"]
                }):AddToTheme({BackgroundColor3 = 'Accent'})
                
                Instances:Create("UICorner", {
                    Parent = Items["Accent"].Instance,
                    CornerRadius = UDimNew(0, 6)
                })
                
                Items["Glow"] = Instances:Create("ImageLabel", {
                    Parent = Items["Accent"].Instance,
                    ImageColor3 = Library.Theme["Accent"],
                    ScaleType = Enum.ScaleType.Slice,
                    ImageTransparency = 0.8,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 25, 1, 25),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Image = "http://www.roblox.com/asset/?id=18245826428",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    SliceCenter = RectNew(Vector2New(21, 21), Vector2New(79, 79))
                }):AddToTheme({ImageColor3 = 'Accent'})
                
                Items["Dragger"] = Instances:Create("Frame", {
                    Parent = Items["Accent"].Instance,
                    AnchorPoint = Vector2New(0, 0.5),
                    Position = UDim2New(1, -4, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 13, 0, 13),
                    BorderSizePixel = 0
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["Dragger"].Instance,
                    CornerRadius = UDimNew(0, 6)
                })
                
                Items["Glow2"] = Instances:Create("ImageLabel", {
                    Parent = Items["Dragger"].Instance,
                    ImageColor3 = Library.Theme["Accent"],
                    ScaleType = Enum.ScaleType.Slice,
                    ImageTransparency = 0.8,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 25, 1, 25),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Image = "http://www.roblox.com/asset/?id=18245826428",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    SliceCenter = RectNew(Vector2New(21, 21), Vector2New(79, 79))
                }):AddToTheme({ImageColor3 = 'Accent'})
                
                Items["Value"] = Instances:Create("TextLabel", {
                    Parent = Items["Slider"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme["Text"],
                    TextTransparency = 0.5,
                    Text = "50%",
                    Size = UDim2New(0, 0, 0, 15),
                    AnchorPoint = Vector2New(1, 0.5),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2New(1, 0, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 16
                }):AddToTheme({TextColor3 = 'Text'})                
            end

            function Slider:Get() return Slider.Value end

            function Slider:SetVisibility(Bool)
                Items["Slider"].Instance.Visible = Bool
            end

            function Slider:Set(Value)
                -- Verifica se o valor passado é um número válido e diferente de NaN
                if typeof(Value) ~= "number" or Value ~= Value then
                    Value = Slider.Min
                end

                local ClampedValue = MathClamp(Value, Slider.Min, Slider.Max)
                Slider.Value = Library:Round(ClampedValue, Slider.Decimals)

                -- Dupla validação pós-arredondamento
                if Slider.Value ~= Slider.Value then
                    Slider.Value = Slider.Min
                end

                Library.Flags[Slider.Flag] = Slider.Value

                local Range = Slider.Max - Slider.Min
                local Scale = (Range <= 0) and 0 or (Slider.Value - Slider.Min) / Range

                -- Protege a escala de distorções visuais
                if Scale ~= Scale or Scale == math.huge or Scale == -math.huge then
                    Scale = 0
                else
                    Scale = MathClamp(Scale, 0, 1)
                end

                Items["Accent"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2New(Scale, 0, 1, 0)})
                Items["Value"].Instance.Text = StringFormat("%s%s", Slider.Value, Slider.Suffix)

                if Slider.Callback then Library:SafeCall(Slider.Callback, Slider.Value) end
            end

            local InputChanged 
            Items["RealSlider"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Slider.Sliding = true
                    local RealSliderSizeX = Items["RealSlider"].Instance.AbsoluteSize.X
                    local SizeX = 0
                    
                    if RealSliderSizeX > 0 then
                        SizeX = (Input.Position.X - Items["RealSlider"].Instance.AbsolutePosition.X) / RealSliderSizeX
                    end
                    
                    if SizeX ~= SizeX or SizeX == math.huge or SizeX == -math.huge then
                        SizeX = 0
                    else
                        SizeX = MathClamp(SizeX, 0, 1)
                    end

                    local Value = ((Slider.Max - Slider.Min) * SizeX) + Slider.Min
                    Slider:Set(Value)

                    if InputChanged then return end
                    InputChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Slider.Sliding = false
                            InputChanged:Disconnect()
                            InputChanged = nil
                        end
                    end)
                end
            end)

            Library:Connect(UserInputService.InputChanged, function(Input)
                if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) and Slider.Sliding then
                    local RealSliderSizeX = Items["RealSlider"].Instance.AbsoluteSize.X
                    local SizeX = 0
                    
                    if RealSliderSizeX > 0 then
                        SizeX = (Input.Position.X - Items["RealSlider"].Instance.AbsolutePosition.X) / RealSliderSizeX
                    end
                    
                    if SizeX ~= SizeX or SizeX == math.huge or SizeX == -math.huge then
                        SizeX = 0
                    else
                        SizeX = MathClamp(SizeX, 0, 1)
                    end

                    local Value = ((Slider.Max - Slider.Min) * SizeX) + Slider.Min
                    Slider:Set(Value)
                end
            end)

            if Slider.Default then Slider:Set(Slider.Default) end
            Slider.Section.Window:RegisterElement(Slider, "Slider", Slider.Name, Slider.Section, Slider.Page)

            Library.SetFlags[Slider.Flag] = function(Value) Slider:Set(Value) end
            return Slider 
        end

        local OriginalSectionDropdown = Library.Sections.Dropdown
        Library.Sections.Dropdown = function(self, Data)
            Data = Data or {}

            local Dropdown = {
                Window = self.Window,
                Page = self.Page,
                Section = self,
                Name = Data.Name or Data.name or "Dropdown",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Items = Data.Items or Data.items or {"One", "Two", "Three"},
                Default = Data.Default or Data.default or nil,
                Callback = Data.Callback or Data.callback or function() end,
                Multi = Data.Multi or Data.multi or false,
                Value = {},
                Options = {},
                IsOpen = false
            }

            local Items = {} do 
                Items["Dropdown"] = Instances:Create("Frame", {
                    Parent = Dropdown.Section.Items["Content"].Instance,
                    BackgroundTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 0, 30),
                    BorderSizePixel = 0
                })
                
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Dropdown"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme["Text"],
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Dropdown.Name,
                    AnchorPoint = Vector2New(0, 0.5),
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0.5, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 16
                }):AddToTheme({TextColor3 = 'Text'})
                
                Items["RealDropdown"] = Instances:Create("TextButton", {
                    Parent = Items["Dropdown"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(1, 1),
                    Position = UDim2New(1, 0, 1, 0),
                    Size = UDim2New(0, 200, 0, 30),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = Library.Theme["Element"]
                }):AddToTheme({BackgroundColor3 = 'Element'})
                
                Instances:Create("UICorner", {
                    Parent = Items["RealDropdown"].Instance,
                    CornerRadius = UDimNew(0, 6)
                })
                
                Instances:Create("UIStroke", {
                    Parent = Items["RealDropdown"].Instance,
                    Color = Library.Theme["Outline"],
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = 'Outline'})
                
                Items["Value"] = Instances:Create("TextLabel", {
                    Parent = Items["RealDropdown"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme["Text"],
                    TextTransparency = 0.5,
                    Text = "--",
                    Size = UDim2New(1, -45, 0, 15),
                    AnchorPoint = Vector2New(0, 0.5),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 8, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    TextSize = 16,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextXAlignment = Enum.TextXAlignment.Left
                }):AddToTheme({TextColor3 = 'Text'})
                
                Items["Icon"] = Instances:Create("ImageLabel", {
                    Parent = Items["RealDropdown"].Instance,
                    ImageColor3 = Library.Theme["Text"],
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(1, 0.5),
                    Image = "rbxassetid://72690112230014",
                    BackgroundTransparency = 1,
                    Position = UDim2New(1, -8, 0.5, 0),
                    Size = UDim2New(0, 16, 0, 16),
                    BorderSizePixel = 0
                }):AddToTheme({ImageColor3 = 'Text'})
                
                Instances:Create("Frame", {
                    Parent = Items["RealDropdown"].Instance,
                    AnchorPoint = Vector2New(1, 0),
                    Position = UDim2New(1, -32, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 1, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Outline"]
                }):AddToTheme({BackgroundColor3 = 'Outline'})       
                
                Items["OptionHolder"] = Instances:Create("TextButton", {
                    Parent = Library.UnusedHolder.Instance,
                    Visible = false,
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    Size = UDim2New(0, 200, 0, 0),
                    Position = UDim2New(0, 54, 0, 236),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    TextSize = 14,
                    BackgroundColor3 = Library.Theme["Inline"]
                }):AddToTheme({BackgroundColor3 = 'Inline'})
                
                Instances:Create("UICorner", {
                    Parent = Items["OptionHolder"].Instance
                })
                
                Instances:Create("UIListLayout", {
                    Parent = Items["OptionHolder"].Instance,
                    Padding = UDimNew(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                Instances:Create("UIPadding", {
                    Parent = Items["OptionHolder"].Instance,
                    PaddingTop = UDimNew(0, 10),
                    PaddingBottom = UDimNew(0, 10),
                    PaddingRight = UDimNew(0, 10),
                    PaddingLeft = UDimNew(0, 10)
                })
            end

            function Dropdown:Get() return Dropdown.Value end

            function Dropdown:SetVisibility(Bool)
                Items["Dropdown"].Instance.Visible = Bool
            end

            local Debounce = false 
            local RenderStepped 

            function Dropdown:SetOpen(Bool)
                if Debounce then return end
                Dropdown.IsOpen = Bool
                Debounce = true 

                if Dropdown.IsOpen then 
                    Items["OptionHolder"].Instance.Visible = true
                    Items["OptionHolder"].Instance.Parent = Library.Holder.Instance
                    
                    RenderStepped = RunService.RenderStepped:Connect(function()
                        Items["OptionHolder"].Instance.Position = UDim2New(0, Items["RealDropdown"].Instance.AbsolutePosition.X, 0, Items["RealDropdown"].Instance.AbsolutePosition.Y - 25)
                        Items["OptionHolder"].Instance.Size = UDim2New(0, Items["RealDropdown"].Instance.AbsoluteSize.X, 0, 0)
                    end)

                    for Value, _ in pairs(Library.OpenFrames) do 
                        if Value ~= Dropdown and not Dropdown.Section.IsSettings then 
                            Value:SetOpen(false)
                        end
                    end
                    Library.OpenFrames[Dropdown] = Dropdown 
                else
                    Library.OpenFrames[Dropdown] = nil
                    if RenderStepped then 
                        RenderStepped:Disconnect()
                        RenderStepped = nil
                    end
                end

                local Descendants = Items["OptionHolder"].Instance:GetDescendants()
                TableInsert(Descendants, Items["OptionHolder"].Instance)

                local NewTween
                for _, Value in ipairs(Descendants) do 
                    local TransparencyProperty = Tween:GetProperty(Value)
                    if TransparencyProperty then
                        if not Value.ClassName:find("UI") then Value.ZIndex = Dropdown.IsOpen and 3 or 1 end
                        if type(TransparencyProperty) == "table" then 
                            for _, Property in ipairs(TransparencyProperty) do 
                                NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                            end
                        else
                            NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                        end
                    end
                end
                
                NewTween.Tween.Completed:Connect(function()
                    Debounce = false 
                    Items["OptionHolder"].Instance.Visible = Dropdown.IsOpen
                    task_wait(0.2)
                    Items["OptionHolder"].Instance.Parent = not Dropdown.IsOpen and Library.UnusedHolder.Instance or Library.Holder.Instance
                end)
            end

            function Dropdown:Set(Option)
                if Dropdown.Multi then 
                    if type(Option) ~= "table" then return end
                    Dropdown.Value = Option
                    Library.Flags[Dropdown.Flag] = Option

                    for _, Value in ipairs(Option) do
                        local OptionData = Dropdown.Options[Value]
                        if OptionData then
                            OptionData.Selected = true 
                            OptionData:Toggle("Active")
                        end
                    end
                    Items["Value"].Instance.Text = TableConcat(Option, ", ")
                else
                    local OptionData = Dropdown.Options[Option]
                    if not OptionData then return end

                    Dropdown.Value = Option
                    Library.Flags[Dropdown.Flag] = Option

                    for _, Value in pairs(Dropdown.Options) do
                        if Value ~= OptionData then
                            Value.Selected = false 
                            Value:Toggle("Inactive")
                        else
                            Value.Selected = true 
                            Value:Toggle("Active")
                        end
                    end
                    Items["Value"].Instance.Text = Option
                end

                if Dropdown.Callback then Library:SafeCall(Dropdown.Callback, Dropdown.Value) end
            end

            function Dropdown:Add(Option)
                local OptionButton = Instances:Create("TextButton", {
                    Parent = Items["OptionHolder"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, 20),
                    BorderSizePixel = 0,
                    TextSize = 14
                })
                
                local OptionLiner = Instances:Create("Frame", {
                    Parent = OptionButton.Instance,
                    BackgroundTransparency = 1,
                    Size = UDim2New(0, 3, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Accent"]
                }):AddToTheme({BackgroundColor3 = 'Accent'})
                
                local OptionGlow = Instances:Create("ImageLabel", {
                    Parent = OptionLiner.Instance,
                    ImageColor3 = Library.Theme["Accent"],
                    ScaleType = Enum.ScaleType.Slice,
                    ImageTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 25, 1, 25),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Image = "http://www.roblox.com/asset/?id=18245826428",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    BorderSizePixel = 0,
                    SliceCenter = RectNew(Vector2New(21, 21), Vector2New(79, 79))
                }):AddToTheme({ImageColor3 = 'Accent'})
                
                Instances:Create("UICorner", {
                    Parent = OptionLiner.Instance,
                    CornerRadius = UDimNew(1, 0)
                })
                
                local OptionText = Instances:Create("TextLabel", {
                    Parent = OptionButton.Instance,
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme["Text"],
                    TextTransparency = 0.5,
                    Text = Option,
                    Size = UDim2New(1, -15, 0, 15),
                    AnchorPoint = Vector2New(0, 0.5),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    TextSize = 16,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextXAlignment = Enum.TextXAlignment.Left
                }):AddToTheme({TextColor3 = 'Text'})
                
                local OptionData = {
                    Button = OptionButton,
                    Name = Option,
                    Liner = OptionLiner,
                    Glow = OptionGlow,
                    Text = OptionText,
                    Selected = false
                }
                
                function OptionData:Toggle(Value)
                    if Value == "Active" then
                        OptionData.Liner:Tween(nil, {BackgroundTransparency = 0, Size = UDim2New(0, 3, 1, 0)})
                        OptionData.Glow:Tween(nil, {ImageTransparency = 0.7})
                        OptionData.Text:Tween(nil, {Position = UDim2New(0, 12, 0.5 ,0), Size = UDim2New(1, -20, 0, 15), TextTransparency = 0})
                    else
                        OptionData.Liner:Tween(nil, {BackgroundTransparency = 1, Size = UDim2New(0, 3, 0, 0)})
                        OptionData.Glow:Tween(nil, {ImageTransparency = 1})
                        OptionData.Text:Tween(nil, {Position = UDim2New(0, 0, 0.5 ,0), Size = UDim2New(1, -15, 0, 15), TextTransparency = 0.5})
                    end
                end

                function OptionData:Set()
                    OptionData.Selected = not OptionData.Selected

                    if Dropdown.Multi then 
                        local Index = TableFind(Dropdown.Value, OptionData.Name)
                        if Index then 
                            TableRemove(Dropdown.Value, Index)
                        else
                            TableInsert(Dropdown.Value, OptionData.Name)
                        end

                        OptionData:Toggle(Index and "Inactive" or "Active")
                        Library.Flags[Dropdown.Flag] = Dropdown.Value

                        local TextFormat = #Dropdown.Value > 0 and TableConcat(Dropdown.Value, ", ") or "..."
                        Items["Value"].Instance.Text = TextFormat
                    else
                        if OptionData.Selected then 
                            Dropdown.Value = OptionData.Name
                            Library.Flags[Dropdown.Flag] = OptionData.Name
                            OptionData.Selected = true
                            OptionData:Toggle("Active")

                            for _, Value in pairs(Dropdown.Options) do 
                                if Value ~= OptionData then
                                    Value.Selected = false 
                                    Value:Toggle("Inactive")
                                end
                            end
                            Items["Value"].Instance.Text = OptionData.Name
                        else
                            Dropdown.Value = nil
                            Library.Flags[Dropdown.Flag] = nil
                            OptionData.Selected = false
                            OptionData:Toggle("Inactive")
                            Items["Value"].Instance.Text = "..."
                        end
                    end

                    if Dropdown.Callback then Library:SafeCall(Dropdown.Callback, Dropdown.Value) end
                end

                OptionButton:Connect("MouseButton1Down", function() OptionData:Set() end)
                Dropdown.Options[OptionData.Name] = OptionData
                return OptionData
            end

            function Dropdown:Remove(Option)
                if Dropdown.Options[Option] then
                    Dropdown.Options[Option].Button:Clean()
                    Dropdown.Options[Option] = nil
                end
            end

            function Dropdown:Refresh(List)
                for _, Value in pairs(Dropdown.Options) do 
                    Dropdown:Remove(Value.Name)
                end
                for _, Value in ipairs(List) do 
                    Dropdown:Add(Value)
                end
            end

            Items["RealDropdown"]:Connect("MouseButton1Down", function()
                Dropdown:SetOpen(not Dropdown.IsOpen)
            end)

            Library:Connect(UserInputService.InputBegan, function(Input)
                if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and Dropdown.IsOpen then
                    if not Library:IsMouseOverFrame(Items["OptionHolder"]) then
                        Dropdown:SetOpen(false)
                    end
                end
            end)

            Items["RealDropdown"]:Connect("Changed", function(Property)
                if Property == "AbsolutePosition" and Dropdown.IsOpen then
                    Dropdown.IsOpen = not Library:IsClipped(Items["OptionHolder"].Instance, Dropdown.Section.Items["Section"].Instance.Parent)
                    Items["OptionHolder"].Instance.Visible = Dropdown.IsOpen
                end
            end)

            for _, Value in ipairs(Dropdown.Items) do Dropdown:Add(Value) end
            if Dropdown.Default then Dropdown:Set(Dropdown.Default) end

            Dropdown.Section.Window:RegisterElement(Dropdown, "Dropdown", Dropdown.Name, Dropdown.Section, Dropdown.Page)
            Library.SetFlags[Dropdown.Flag] = function(Value) Dropdown:Set(Value) end
            return Dropdown
        end

        Library.Sections.Label = function(self, Name)
            local Label = {
                Window = self.Window,
                Page = self.Page,
                Section = self,
                Name = Name or "Label"
            }

            local Items = {} do 
                Items["Label"] = Instances:Create("Frame", {
                    Parent = Label.Section.Items["Content"].Instance,
                    BackgroundTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 0, 20),
                    BorderSizePixel = 0
                })
                
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Label"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme["Text"],
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Label.Name,
                    AnchorPoint = Vector2New(0, 0.5),
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0.5, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 16
                }):AddToTheme({TextColor3 = 'Text'})
                
                Items["SubElements"] = Instances:Create("Frame", {
                    Parent = Items["Label"].Instance,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(1, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2New(1, 0, 0, 0),
                    Size = UDim2New(0, 0, 1, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X
                })
                
                Instances:Create("UIListLayout", {
                    Parent = Items["SubElements"].Instance,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    Padding = UDimNew(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })                
            end

            function Label:SetText(Text)
                Items["Text"].Instance.Text = tostring(Text)
            end

            function Label:SetVisibility(Bool)
                Items["Label"].Instance.Visible = Bool
            end

            function Label:Colorpicker(Data)
                Data = Data or {}
                local Colorpicker = {
                    Window = Label.Window,
                    Page = Label.Page,
                    Section = Label.Section,
                    Flag = Data.Flag or Data.flag or Library:NextFlag(),
                    Default = Data.Default or Data.default or FromRGB(255, 255, 255),
                    Callback = Data.Callback or Data.callback or function() end,
                    Alpha = Data.Alpha or Data.alpha or false
                }

                local NewColorpicker, _ = Library:CreateColorpicker({
                    Parent = Items["SubElements"],
                    Page = Colorpicker.Page,
                    Section = Colorpicker.Section,
                    Flag = Colorpicker.Flag,
                    Default = Colorpicker.Default,
                    Callback = Colorpicker.Callback,
                    Alpha = Colorpicker.Alpha
                })
                return NewColorpicker
            end

            function Label:Keybind(Data)
                Data = Data or {}
                local Keybind = {
                    Window = Label.Window,
                    Page = Label.Page,
                    Section = Label.Section,
                    Flag = Data.Flag or Data.flag or Library:NextFlag(),
                    Default = Data.Default or Data.default or Enum.KeyCode.E,
                    Callback = Data.Callback or Data.callback or function() end,
                    Mode = Data.Mode or Data.mode or "Toggle"
                }

                local NewKeybind, _ = Library:CreateKeybind({
                    Parent = Items["SubElements"],
                    Page = Keybind.Page,
                    Section = Keybind.Section,
                    Flag = Keybind.Flag,
                    Default = Keybind.Default,
                    Mode = Keybind.Mode,
                    Callback = Keybind.Callback
                })
                return NewKeybind
            end

            return Label
        end

        Library.Sections.Textbox = function(self, Data)
            Data = Data or {}

            local Textbox = {
                Window = self.Window,
                Page = self.Page,
                Section = self,
                Name = Data.Name or Data.name or "Textbox",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Default = Data.Default or Data.default or "",
                Callback = Data.Callback or Data.callback or function() end,
                Placeholder = Data.Placeholder or Data.placeholder or "Placeholder",
                Numeric = Data.Numeric or Data.numeric or false,
                Finished = Data.Finished or Data.finished or false,
                Value = ""
            }

            local Items = {} do 
                Items["Textbox"] = Instances:Create("Frame", {
                    Parent = Textbox.Section.Items["Content"].Instance,
                    BackgroundTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 0, 30),
                    BorderSizePixel = 0
                })
                
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Textbox"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme["Text"],
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Textbox.Name,
                    AnchorPoint = Vector2New(0, 0.5),
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0.5, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 16
                }):AddToTheme({TextColor3 = 'Text'})
                
                Items["Background"] = Instances:Create("Frame", {
                    Parent = Items["Textbox"].Instance,
                    Active = true,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(1, 1),
                    Size = UDim2New(0, 0, 0, 30),
                    Position = UDim2New(1, 0, 1, 0),
                    Selectable = true,
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundColor3 = Library.Theme["Element"]
                }):AddToTheme({BackgroundColor3 = 'Element'})
                
                Instances:Create("UICorner", {
                    Parent = Items["Background"].Instance,
                    CornerRadius = UDimNew(0, 6)
                })
                
                Instances:Create("UIStroke", {
                    Parent = Items["Background"].Instance,
                    Color = Library.Theme["Outline"],
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = 'Outline'})
                
                Instances:Create("UIPadding", {
                    Parent = Items["Background"].Instance,
                    PaddingRight = UDimNew(0, 8),
                    PaddingLeft = UDimNew(0, 8)
                })
                
                Items["Input"] = Instances:Create("TextBox", {
                    Parent = Items["Background"].Instance,
                    FontFace = Library.Font,
                    Active = false,
                    TextTransparency = 0,
                    AnchorPoint = Vector2New(0, 0.5),
                    PlaceholderColor3 = FromRGB(133, 139, 143),
                    PlaceholderText = Textbox.Placeholder,
                    TextSize = 16,
                    Size = UDim2New(0, 0, 0, 15),
                    TextColor3 = Library.Theme["Text"],
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    Selectable = false,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0.5, 0),
                    CursorPosition = -1,
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X
                }):AddToTheme({TextColor3 = 'Text'})                
            end
            
            function Textbox:Get() return Textbox.Value end

            function Textbox:SetVisibility(Bool)
                Items["Textbox"].Instance.Visible = Bool
            end

            function Textbox:Set(Value)
                if Textbox.Numeric and (not tonumber(Value)) and StringLen(tostring(Value)) > 0 then
                    Value = Textbox.Value
                end

                Textbox.Value = Value
                Items["Input"].Instance.Text = Value
                Library.Flags[Textbox.Flag] = Value

                if Textbox.Callback then Library:SafeCall(Textbox.Callback, Value) end
            end

            if Textbox.Finished then 
                Items["Input"]:Connect("FocusLost", function(PressedEnter)
                    if PressedEnter then Textbox:Set(Items["Input"].Instance.Text) end
                end)
            else
                Library:Connect(Items["Input"].Instance:GetPropertyChangedSignal("Text"), function()
                    Textbox:Set(Items["Input"].Instance.Text)
                end)
            end

            if Textbox.Default then Textbox:Set(Textbox.Default) end
            Textbox.Section.Window:RegisterElement(Textbox, "Textbox", Textbox.Name, Textbox.Section, Textbox.Page)
            Library.SetFlags[Textbox.Flag] = function(Value) Textbox:Set(Value) end
            return Textbox
        end
    end

    Library.CreateSettingsPage = function(self, Window, Watermark)
        local SettingsPage = Window:Page({Name = "Settings", Icon = "rbxassetid://128742673777519"})
        do
            local ThemingSection = SettingsPage:Section({Name = "Theming", Icon = "rbxassetid://73803440257131"})
            do
                for Index, Value in pairs(Library.Theme) do 
                    ThemingSection:Label(Index):Colorpicker({
                        Flag = Index.."_ThemingThing",
                        Default = Value,
                        Alpha = 0,
                        Callback = function(NewVal)
                            Library.Theme[Index] = NewVal
                            Library:ChangeTheme(Index, NewVal)
                        end
                    })
                end
            end

            local ConfigsSection = SettingsPage:Section({Name = "Configs", Icon = "rbxassetid://74885853379841"}) do 
                local ConfigName, ConfigSelected
    
                local ConfigsDropdown = ConfigsSection:Dropdown({
                    Name = "Configs", 
                    Flag = "Configs",
                    Items = {}, 
                    Multi = false,
                    MaxSize = 120,
                    Callback = function(Value) ConfigSelected = Value end
                })
    
                ConfigsSection:Textbox({
                    Name = "Config name",
                    Placeholder = "Config name",
                    Flag = "ConfigName",
                    Callback = function(Value) ConfigName = Value end
                })
    
                ConfigsSection:Button({
                    Name = "Create",
                    Callback = function()
                        if ConfigName and ConfigName ~= "" then
                            local Path = Library.Folders.Configs .. "/" .. ConfigName .. ".json"
                            if not isfile(Path) then
                                writefile(Path, Library:GetConfig())
                                Library:RefreshConfigsList(ConfigsDropdown)
                            end
                        end
                    end
                })
    
                ConfigsSection:Button({
                    Name = "Load",
                    Callback = function()
                        if ConfigSelected and ConfigSelected ~= "" then
                            Library:LoadConfig(readfile(Library.Folders.Configs .. "/" .. ConfigSelected..".json"))
                        end
                    end
                })
    
                ConfigsSection:Button({
                    Name = "Save",
                    Callback = function()
                        if ConfigSelected and ConfigSelected ~= "" then
                            writefile(Library.Folders.Configs .. "/" .. ConfigSelected..".json", Library:GetConfig())
                        end
                    end
                })
    
                ConfigsSection:Button({
                    Name = "Delete",
                    Callback = function()
                        if ConfigSelected and ConfigSelected ~= "" then
                            delfile(Library.Folders.Configs .. "/" .. ConfigSelected..".json")
                            Library:RefreshConfigsList(ConfigsDropdown)
                        end
                    end
                })
    
                ConfigsSection:Button({
                    Name = "Refresh",
                    Callback = function() Library:RefreshConfigsList(ConfigsDropdown) end
                })
    
                Library:RefreshConfigsList(ConfigsDropdown)
            end
        end
        return SettingsPage
    end
end

Library.LucideIconsUrl = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua"
Library.IconPacks = Library.IconPacks or {}
Library.ActiveIconPack = "lucide"

function Library:LoadIconPack(Url, PackName)
    PackName = PackName or "lucide"
    if self.IconPacks[PackName] then return self.IconPacks[PackName] end

    local Success, Result = pcall(function()
        local Source = game:HttpGet(Url)
        local Chunk = loadstring(Source)
        if not Chunk then return {} end
        local Icons = Chunk()
        return (type(Icons) == "table") and Icons or {}
    end)

    self.IconPacks[PackName] = Success and Result or {}
    return self.IconPacks[PackName]
end

function Library:SetIconPack(PackName)
    self.ActiveIconPack = PackName or "lucide"
end

function Library:GetIconPack(PackName)
    PackName = PackName or self.ActiveIconPack or "lucide"
    if not self.IconPacks[PackName] then
        if PackName == "lucide" then
            self:LoadIconPack(self.LucideIconsUrl, "lucide")
        else
            self.IconPacks[PackName] = {}
        end
    end
    return self.IconPacks[PackName] or {}
end

function Library:ResolveIcon(Icon, PackName)
    if not Icon or Icon == "" or typeof(Icon) ~= "string" then return Icon end
    if Icon:match("^rbxassetid://") or Icon:match("^https?://") then return Icon end
    local Icons = self:GetIconPack(PackName)
    return Icons[StringLower(Icon)] or Icon
end

local OriginalWindowFunction = Library.Window
Library.Window = function(self, Data)
    Data = Data or {}
    Data.Logo = self:ResolveIcon(Data.Logo)
    Data.logo = self:ResolveIcon(Data.logo)
    if Data.WatermarkLogo then Data.WatermarkLogo = self:ResolveIcon(Data.WatermarkLogo) end
    return OriginalWindowFunction(self, Data)
end

local OriginalSectionFunc = Library.Pages.Section
Library.Pages.Section = function(self, Data)
    Data = Data or {}
    Data.Icon = Library:ResolveIcon(Data.Icon or Data.icon)
    Data.icon = Data.Icon
    return OriginalSectionFunc(self, Data)
end

Library.CreateWindow = function(self, Data)
    Data = Data or {}
    local Window = self:Window(Data)
    local Watermark

    if Data.WatermarkEnabled then
        Watermark = self:Watermark(
            Data.WatermarkText or Data.Name or "Window",
            self:ResolveIcon(Data.WatermarkLogo or Data.Logo)
        )
        Window.Watermark = Watermark
    end

    Window._AutoSettingsEnabled = Data.SettingsTabEnabled and true or false
    Window._AutoSettingsWatermark = Watermark

    local OriginalPage = Window.Page
    local CreatingSettings = false

    local function ReorderTabs()
        local Order = 1
        for _, Value in ipairs(Window.Pages) do
            if Value ~= Window.SettingsPage and Value.Items and Value.Items["Inactive"] then
                Value.Items["Inactive"].Instance.LayoutOrder = Order
                Order = Order + 1
            end
        end
        if Window.SettingsPage and Window.SettingsPage.Items and Window.SettingsPage.Items["Inactive"] then
            Window.SettingsPage.Items["Inactive"].Instance.LayoutOrder = 999999
        end
    end

    local function EnsureSettings()
        if not Window._AutoSettingsEnabled or Window.SettingsPage or CreatingSettings then
            ReorderTabs()
            return
        end
        CreatingSettings = true
        Window.SettingsPage = Library:CreateSettingsPage(Window, Window._AutoSettingsWatermark)
        CreatingSettings = false
        ReorderTabs()
    end

    local function WrappedPage(_, TabData)
        TabData = TabData or {}
        TabData.Icon = Library:ResolveIcon(TabData.Icon or TabData.icon)
        TabData.icon = TabData.Icon

        local Page = OriginalPage(Window, TabData)
        EnsureSettings()
        ReorderTabs()
        return Page
    end

    Window.Page = WrappedPage
    Window.CreateTab = WrappedPage
    Window.CreatePage = WrappedPage
    return Window
end

Library.CreateTab = Library.Page
Library.Pages.CreateSection = Library.Pages.Section

Library.Sections.CreateButton = Library.Sections.Button
Library.Sections.CreateToggle = Library.Sections.Toggle
Library.Sections.CreateSlider = Library.Sections.Slider
Library.Sections.CreateDropdown = Library.Sections.Dropdown
Library.Sections.CreateTextbox = Library.Sections.Textbox
Library.Sections.CreateLabel = Library.Sections.Label

local function NormalizeNamedData(NameOrData, Icon)
    if type(NameOrData) == "table" then
        local Data = TableClone(NameOrData)
        if Data.Title and not (Data.Name or Data.name) then Data.Name = Data.Title end
        if Data.title and not (Data.Name or Data.name) then Data.Name = Data.title end
        if Icon and not (Data.Icon or Data.icon) then Data.Icon = Icon end
        return Data
    end

    local Data = { Name = NameOrData }
    if Icon ~= nil then Data.Icon = Icon end
    return Data
end

function Library:AddTab(NameOrData, Icon)
    local Data = NormalizeNamedData(NameOrData, Icon)
    Data.Icon = self:ResolveIcon(Data.Icon or Data.icon)
    Data.icon = Data.Icon
    return self.CreateTab and self:CreateTab(Data) or self:Page(Data)
end

function Library.Pages:AddSection(NameOrData, Icon)
    local Data = NormalizeNamedData(NameOrData, Icon)
    Data.Icon = Library:ResolveIcon(Data.Icon or Data.icon)
    Data.icon = Data.Icon
    return self.CreateSection and self:CreateSection(Data) or self:Section(Data)
end

function Library.Sections:AddButton(NameOrData, Callback)
    if type(NameOrData) == "table" then
        return self:CreateButton(NormalizeNamedData(NameOrData))
    end
    return self:CreateButton({ Name = NameOrData, Callback = Callback })
end

function Library.Sections:AddToggle(NameOrData, FlagOrCallback, Default, Callback)
    if type(NameOrData) == "table" then
        return self:CreateToggle(NormalizeNamedData(NameOrData))
    end
    local RealCallback = (type(FlagOrCallback) == "function") and FlagOrCallback or Callback
    return self:CreateToggle({
        Name = NameOrData,
        Flag = (type(FlagOrCallback) == "string") and FlagOrCallback or nil,
        Default = Default,
        Callback = RealCallback
    })
end

function Library.Sections:AddSlider(NameOrData, Min, Max, Default, Callback)
    if type(NameOrData) == "table" then
        return self:CreateSlider(NormalizeNamedData(NameOrData))
    end
    return self:CreateSlider({ Name = NameOrData, Min = Min, Max = Max, Default = Default, Callback = Callback })
end

function Library.Sections:AddDropdown(NameOrData, Items, Default, Callback)
    if type(NameOrData) == "table" then
        return self:CreateDropdown(NormalizeNamedData(NameOrData))
    end
    return self:CreateDropdown({ Name = NameOrData, Items = Items, Default = Default, Callback = Callback })
end

function Library.Sections:AddTextbox(NameOrData, Placeholder, Callback)
    if type(NameOrData) == "table" then
        return self:CreateTextbox(NormalizeNamedData(NameOrData))
    end
    return self:CreateTextbox({ Name = NameOrData, Placeholder = Placeholder, Callback = Callback })
end

function Library.Sections:AddLabel(TextOrData)
    if type(TextOrData) == "table" then
        local Data = NormalizeNamedData(TextOrData)
        return self:CreateLabel(Data.Name or Data.Text or Data.text or "Label")
    end
    return self:CreateLabel(TextOrData)
end

getgenv().Library = Library
return Library
