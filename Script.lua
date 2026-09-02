local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

-- ⚙️ Configurações
local WHITE_CROSSHAIR = "rbxassetid://79963539800097"
local TARGET_TOOL_NAME = "Gun" -- Nome da Tool que ativa o sistema
local ATIVADO = false -- Inicia desativado até a Tool ser equipada

-- Variáveis de arrasto
local arrastando = false
local diferenca = Vector2.new()

-- 🛡️ Função para criar UI (não será destruída no respawn)
local function criarUI()
-- Remove UI antiga se existir
if player.PlayerGui:FindFirstChild("ControleCrosshair") then
player.PlayerGui:FindFirstChild("ControleCrosshair"):Destroy()
end

local TelaUI = Instance.new("ScreenGui")
TelaUI.Name = "ControleCrosshair"
TelaUI.Parent = player.PlayerGui
TelaUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
TelaUI.ResetOnSpawn = false -- 🔑 IMPORTA NÃO DESTRUIR NO RESPAWN/MORRER

local Botao = Instance.new("TextButton")
Botao.Name = "BotaoToggle"
Botao.Size = UDim2.new(0, 130, 0, 45)
Botao.Position = UDim2.new(0.82, 0, 0.06, 0) -- Posição inicial
Botao.BackgroundColor3 = Color3.new(0.8, 0.15, 0.15)
Botao.TextColor3 = Color3.new(1, 1, 1)
Botao.Font = Enum.Font.GothamBold
Botao.TextScaled = true
Botao.Text = "DESATIVADO"
Botao.ZIndex = 10
Botao.Parent = TelaUI

-- ✅ SISTEMA DE ARRASTAR/MOVER O BOTÃO
Botao.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
arrastando = true
local posMouse = Vector2.new(mouse.X, mouse.Y)
diferenca = posMouse - Vector2.new(Botao.AbsolutePosition.X, Botao.AbsolutePosition.Y)
input.Changed:Wait()
arrastando = false
end
end)

Botao.InputChanged:Connect(function(input)
if arrastando and input.UserInputType == Enum.UserInputType.MouseMovement then
local posNova = Vector2.new(mouse.X, mouse.Y) - diferenca
Botao.Position = UDim2.new(0, posNova.X, 0, posNova.Y)
end
end)

return Botao
end

-- Cria a interface
local Botao = criarUI()

-- 🔧 Atualiza a interface e a mira
local function atualizarEstado(ativo)
ATIVADO = ativo
if ATIVADO then
Botao.BackgroundColor3 = Color3.new(0.15, 0.75, 0.25)
Botao.Text = "ATIVADO"
mouse.Icon = WHITE_CROSSHAIR
else
Botao.BackgroundColor3 = Color3.new(0.8, 0.15, 0.15)
Botao.Text = "DESATIVADO"
mouse.Icon = ""
end
end

-- 🎯 Monitoramento da Tool "Gun"
local function monitorarTool(tool)
if not tool:IsA("Tool") or tool.Name ~= TARGET_TOOL_NAME then return end

-- Evita reconectar a mesma ferramenta
if tool:GetAttribute("CrosshairConectado") then return end
tool:SetAttribute("CrosshairConectado", true)

tool.Equipped:Connect(function()
atualizarEstado(true)
end)

tool.Unequipped:Connect(function()
atualizarEstado(false)
end)
end

-- 🔄 Lógica de carregamento do personagem
local function onCharacterAdded(character)
atualizarEstado(false) -- Garante reset ao renascer

-- Conecta ferramentas já presentes no personagem (equipadas)
for _, child in ipairs(character:GetChildren()) do
monitorarTool(child)
end
character.ChildAdded:Connect(monitorarTool)

-- Conecta ferramentas presentes na Mochila
local backpack = player:WaitForChild("Backpack")
for _, tool in ipairs(backpack:GetChildren()) do
monitorarTool(tool)
end
backpack.ChildAdded:Connect(monitorarTool)
end

-- Inicialização
if player.Character then
task.spawn(onCharacterAdded, player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)
