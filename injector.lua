-- LocalScript для инжектора/эксплойта: Компактный Executor Lite

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local SpamCommandActive = false
local MIN_SPAM_DELAY = 0.01

-- === 1. Создание GUI-Меню и Элементов ===

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExecutorLiteGUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 350) 
Frame.Position = UDim2.new(0.1, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 1
Frame.BorderColor3 = Color3.fromRGB(15, 15, 15)
Frame.Parent = ScreenGui
Frame.Active = true
Frame.Visible = false 

local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 25) 
TitleBar.Text = "Executor Lite"
TitleBar.Font = Enum.Font.SourceSansBold
TitleBar.TextSize = 16
TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TitleBar.Parent = Frame
TitleBar.Active = true

-- Кнопка Открытия (Toggle)
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 80, 0, 20) 
OpenButton.Position = UDim2.new(0, 5, 0, 5) 
OpenButton.Text = "Открыть"
OpenButton.Font = Enum.Font.SourceSansBold
OpenButton.TextSize = 14
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50) 
OpenButton.Parent = ScreenGui
OpenButton.ZIndex = 2 

-- Кнопка Закрытия (X)
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -25, 0, 2) 
CloseButton.AnchorPoint = Vector2.new(1, 0)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 16
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) 
CloseButton.Parent = TitleBar 


-- --- Элементы внутри Frame ---

-- 1. Поле для одноразового выполнения кода
local CodeInput = Instance.new("TextBox")
CodeInput.Size = UDim2.new(0.9, 0, 0.25, 0) 
CodeInput.Position = UDim2.new(0.05, 0, 0.08, 0)
CodeInput.MultiLine = true
CodeInput.PlaceholderText = "Код для одноразового выполнения"
CodeInput.Text = CodeInput.PlaceholderText
CodeInput.Font = Enum.Font.Code
CodeInput.TextSize = 12
CodeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
CodeInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CodeInput.ClearTextOnFocus = true
CodeInput.Parent = Frame

-- 2. Поле для спам-команды
local SpamCodeInput = Instance.new("TextBox")
SpamCodeInput.Size = UDim2.new(0.9, 0, 0.25, 0) 
SpamCodeInput.Position = UDim2.new(0.05, 0, 0.35, 0)
SpamCodeInput.MultiLine = true
SpamCodeInput.PlaceholderText = "Код для спама (будет выполняться циклично)"
SpamCodeInput.Text = SpamCodeInput.PlaceholderText
SpamCodeInput.Font = Enum.Font.Code
SpamCodeInput.TextSize = 12
SpamCodeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpamCodeInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpamCodeInput.ClearTextOnFocus = true
SpamCodeInput.Parent = Frame

-- 3. Поле для ввода скорости спама (в одну строку с лейблом)
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.4, 0, 0.07, 0)
SpeedLabel.Position = UDim2.new(0.05, 0, 0.63, 0)
SpeedLabel.Text = "Скорость (сек):"
SpeedLabel.Font = Enum.Font.SourceSans
SpeedLabel.TextSize = 14
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = Frame

local SpamSpeedInput = Instance.new("TextBox")
SpamSpeedInput.Size = UDim2.new(0.5, 0, 0.07, 0)
SpamSpeedInput.Position = UDim2.new(0.45, 0, 0.63, 0)
SpamSpeedInput.Text = tostring(MIN_SPAM_DELAY)
SpamSpeedInput.Font = Enum.Font.SourceSansBold
SpamSpeedInput.TextSize = 14
SpamSpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpamSpeedInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SpamSpeedInput.Parent = Frame

-- 4. Кнопки управления выполнением (в одну строку)
local ExecuteButton = Instance.new("TextButton")
ExecuteButton.Size = UDim2.new(0.45, 0, 0.08, 0)
ExecuteButton.Position = UDim2.new(0.05, 0, 0.73, 0)
ExecuteButton.Text = "ВЫПОЛНИТЬ"
ExecuteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ExecuteButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
ExecuteButton.Parent = Frame

local ClearButton = Instance.new("TextButton")
ClearButton.Size = UDim2.new(0.45, 0, 0.08, 0)
ClearButton.Position = UDim2.new(0.5, 0, 0.73, 0)
ClearButton.Text = "ОЧИСТИТЬ"
ClearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ClearButton.Parent = Frame

-- 5. Кнопка Спама (Toggle)
local SpamToggleButton = Instance.new("TextButton")
SpamToggleButton.Size = UDim2.new(0.9, 0, 0.08, 0)
SpamToggleButton.Position = UDim2.new(0.05, 0, 0.83, 0) 
SpamToggleButton.Text = "ВКЛЮЧИТЬ СПАМ КОМАНДОЙ"
SpamToggleButton.Font = Enum.Font.SourceSansBold
SpamToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpamToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
SpamToggleButton.Parent = Frame

-- 6. Статус
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0.94, 0)
StatusLabel.Text = "Готов к работе"
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 12
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
StatusLabel.Parent = Frame


-- --- 2. Логика Скрытия/Открытия и Спама (без изменений) ---

local function openMenu()
    Frame.Visible = true
    OpenButton.Visible = false
end

local function closeMenu()
    Frame.Visible = false
    OpenButton.Visible = true
end

local function toggleSpamCommand()
    SpamCommandActive = not SpamCommandActive
    
    if SpamCommandActive then
        SpamToggleButton.Text = "ВЫКЛЮЧИТЬ СПАМ КОМАНДОЙ"
        SpamToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        print("!!! СПАМ КОМАНДОЙ ВКЛЮЧЕН !!!")
    else
        SpamToggleButton.Text = "ВКЛЮЧИТЬ СПАМ КОМАНДОЙ"
        SpamToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        print("--- СПАМ КОМАНДОЙ ВЫКЛЮЧЕН ---")
    end
end

OpenButton.MouseButton1Click:Connect(openMenu)
CloseButton.MouseButton1Click:Connect(closeMenu)
SpamToggleButton.MouseButton1Click:Connect(toggleSpamCommand)

-- Цикл спама
task.spawn(function()
    local lastCode = ""
    local compiledCode = nil

    while true do
        if SpamCommandActive then
            local currentCode = SpamCodeInput.Text
            local currentSpeed = tonumber(SpamSpeedInput.Text) or MIN_SPAM_DELAY
            local delay = math.max(currentSpeed, MIN_SPAM_DELAY)

            if currentCode ~= lastCode then
                lastCode = currentCode
                local success, chunk = pcall(loadstring, currentCode)
                
                if success and chunk then
                    compiledCode = chunk
                    StatusLabel.Text = "Спам-команда скомпилирована. Задержка: " .. string.format("%.2f", delay) .. " сек."
                    StatusLabel.TextColor3 = Color3.fromRGB(50, 200, 50)
                else
                    compiledCode = nil
                    StatusLabel.Text = "Ошибка компиляции спам-команды!"
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                end
            end
            
            if compiledCode then
                local success, err = pcall(compiledCode)
                if not success then
                    print("Ошибка выполнения спам-команды: " .. tostring(err))
                    StatusLabel.Text = "Ошибка выполнения спам-команды! Спам остановлен."
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                    SpamCommandActive = false
                    toggleSpamCommand()
                end
            end
            task.wait(delay)
        else
            task.wait(0.1)
        end
    end
end)


-- --- 3. Логика Перетаскивания (Dragging Logic) - ИСПРАВЛЕНО ---

local dragStart = nil
local dragOffset = nil -- Смещение клика/касания относительно верхнего левого угла Frame
local UserInputService = game:GetService("UserInputService")

-- Привязываем логику перетаскивания к TitleBar
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        
        -- Вычисляем смещение: насколько точка клика отличается от позиции Frame
        dragOffset = Frame.AbsolutePosition - input.Position
        
        dragStart = input.Position
        Frame.ZIndex = 2
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragStart = nil
        dragOffset = nil
        Frame.ZIndex = 1
    end
end)

-- Отслеживаем движение мыши/касания
UserInputService.InputChanged:Connect(function(input)
    -- Проверяем, что перетаскивание активно и это движение мыши/пальца
    if dragStart and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        
        -- Новая позиция Frame = Текущая позиция курсора + Смещение
        local newPosition = input.Position + dragOffset
        
        -- Применяем новую позицию (переводим в абсолютные пиксельные координаты)
        Frame.Position = UDim2.new(0, newPosition.X, 0, newPosition.Y)
    end
end)


-- --- 4. Логика выполнения кода (Execute Once) (без изменений) ---

ExecuteButton.MouseButton1Click:Connect(function()
    local code = CodeInput.Text
    
    if string.len(code) > 0 and code ~= CodeInput.PlaceholderText then
        StatusLabel.Text = "Выполнение..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        
        local success, result = pcall(function()
            local chunk = loadstring(code)
            
            if chunk then
                local executeSuccess, executeResult = pcall(chunk)
                return executeSuccess, executeResult
            else
                return false, "Ошибка: не удалось загрузить код (chunk is nil)"
            end
        end)
        
        if success and result then
            local executeSuccess, executeResult = unpack(result)
            
            if executeSuccess then
                StatusLabel.Text = "Успешно выполнено!"
                StatusLabel.TextColor3 = Color3.fromRGB(50, 200, 50)
            else
                StatusLabel.Text = "Ошибка выполнения: " .. tostring(executeResult)
                StatusLabel.TextColor3 = Color3.fromRGB(200, 50, 50)
            end
        else
            StatusLabel.Text = "Критическая ошибка: " .. tostring(result)
            StatusLabel.TextColor3 = Color3.fromRGB(200, 50, 50)
        end
        
    else
        StatusLabel.Text = "Ошибка: Поле для одноразового кода пустое."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
    end
end)

ClearButton.MouseButton1Click:Connect(function()
    CodeInput.Text = CodeInput.PlaceholderText
    SpamCodeInput.Text = SpamCodeInput.PlaceholderText
    StatusLabel.Text = "Поля для кода очищены."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
end)
