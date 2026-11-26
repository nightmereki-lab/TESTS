--[[
    AoTR - Fly Farm (Awakening bar)
    1. Sobe ate 500 e voa (por fisica, sem teleporte) ate ficar em cima do alvo.
    2. Em cima do alvo, desce pra ALTURA.
    3. Perto de ALTURA: flip do jogo (D D / A A). Abaixo disso cai SEM flip ate ALTURA - QUEDA.
       Ai sobe de volta pra ALTURA e volta a flipar.
    4. Skills nas SUBIDAS de volta, alternando: uma subida usa os buffs (4, 5), cai, a subida seguinte
       usa o ataque (2 -> 3, se sobrar lanca), e repete. So gasta buff se o ataque tambem estiver pronto.
    5. Barra de shift a partir de BARRA_TRANSFORMAR (80%) -> para os flips, vai pro ponto inicial, cai e
       aperta 1 ate virar titan (confere se virou antes de apertar de novo).
    6. Titan (Colossal): abre com 4 -> 1 -> 3, depois um ataque atras do outro. Nunca a 5 durante a partida.
    6b. Tela "MISSION COMPLETED" (ou "RAID COMPLETED") apareceu -> para flips e skills, e se estiver de
        titan aperta 5 pra sair (confere se saiu antes de apertar de novo). So nessa tela.
    7. Acabaram as lancas e a barra NAO ta cheia -> segura flipando um tempo, depois para tudo e deixa
       morrer (pro auto click recomecar). (lancas acabaram mas a barra ta cheia -> transforma normal)
    8. Transformacao acabou e a missao NAO completou (sobrou titan) -> voa ate o titan que sobrou e se
       joga nele pra morrer e reiniciar.

    Seguranca:
    - So executa no place PLACE_ID (Outskirts).
    - queue_on_teleport: depois de cada teleporte ele se carrega sozinho de novo (pelo loadstring do GitHub).
    - So aperta tecla com a janela do Roblox em foco.
    - Para sozinho em qualquer sinal de warn/flag (atributo, tela, remote POST, chat de sistema). 1 ja basta.
    - Tecla END desliga tudo na hora (kill switch).
    - Rodar de novo desliga a copia anterior (nunca roda duas vezes).
]]

-- ================= CONFIG =================
local CONFIG = {
    ALVO             = CFrame.new(4628.5205078125, 3.456562042236328, -322.6959228515625),
    PLACE_ID         = 13904207646, -- so executa nesse place (Outskirts); em qualquer outro nao faz nada
    ALTURA_VOO       = 500,  -- altura da viagem ate o alvo (acima do alvo)
    ALTURA           = 250,  -- em cima do alvo, desce pra essa altura e comeca os flips
                             -- (mudou aqui, muda tudo junto: a queda e a subida acompanham)
    VELOCIDADE       = 70,   -- studs/s na ida ate o alvo
    VELOCIDADE_DESCER = 40,  -- studs/s descendo de ALTURA_VOO pra ALTURA

    -- Flip do jogo (tecla simulada)
    FLIP_INTERVALO   = 0.8,  -- segundos entre um flip e outro
    FLIP_VARIACAO    = 0.15, -- +/- aleatorio no intervalo
    TECLA_SEGURA     = 0.05, -- quanto segura cada toque
    TECLA_INTERVALO  = 0.08, -- tempo entre os dois toques do double tap

    -- Subida de volta
    QUEDA            = 80,   -- cai sem flip ate ALTURA - QUEDA (250 -> 170), ai sobe de volta ate
                             -- ALTURA (usando skill na subida) e volta a flipar
    FAIXA_FLIP       = 8,    -- so flipa a ate 8 studs abaixo de ALTURA
    ALTURA_MINIMA    = 80,   -- seguranca: a menos disso do chao -> sobe tambem
    VELOCIDADE_SUBIR = 25,   -- studs/s na subida de volta (devagar = discreto)

    -- Skills HUMANO. Combo: buffs -> 2 -> 3 (hotbar invertido: o ataque de 1 lanca agora e a 2)
    USAR_SKILLS          = true,
    SKILL_TRANSFORMAR    = 1,
    SKILLS_BUFF          = {4, 5},
    SKILL_ATK_PEQUENO    = 2,   -- vem primeiro, precisa de LANCAS_PEQUENO (1 lanca)
    LANCAS_PEQUENO       = 1,
    SKILL_ATK_GRANDE     = 3,   -- vem depois, precisa de LANCAS_GRANDE (4 lancas)
    LANCAS_GRANDE        = 4,
    COMBO_PAUSA          = {0.08, 0.18}, -- entre uma skill e outra (depois de confirmar que saiu)
    COMBO_RETENTATIVA    = 0.3,          -- nao entrou em cooldown nesse tempo -> aperta de novo
    COMBO_MAX_TENTATIVAS = 6,
    TRANSFORMAR_INTERVALO = {0.95, 1.3}, -- barra cheia: aperta 1 a cada ~1s
    BARRA_TRANSFORMAR     = 0.80,        -- transforma a partir de 80% da barra (o jogo deixa)
    MORRER_SEM_LANCA      = true,        -- sem lanca + barra nao cheia -> para tudo e deixa morrer
    SEM_LANCA_ESPERA      = 20,          -- sem lanca: continua flipando/segurando no ar esse tempo antes de
                                         -- desistir (a barra ainda pode encher depois que as lancas acabam)
    TRANSFORMAR_CONFIRMA  = 1.5,         -- depois de apertar 1, espera isso pra ver se virou titan

    -- Skills TITAN (Colossal). NUNCA a 5 (sai do titan)
    TITAN_ABERTURA  = {4, 1, 3},
    TITAN_SKILLS    = {1, 2, 3, 4},
    TITAN_INTERVALO = {0.3, 0.6}, -- um ataque seguido do outro

    -- Fim da missao: tela "MISSION COMPLETED" apareceu -> para flips/skills e aperta 5 pra sair do titan
    -- (a 5 SO e usada aqui, nunca durante a partida)
    SAIR_TITAN_NO_FIM     = true,
    SKILL_SAIR_TITAN      = 5,
    SAIR_TITAN_CONFIRMA   = 2,    -- depois de apertar 5, espera isso (s) pra ver se saiu do titan
    SAIR_TITAN_TENTATIVAS = 5,

    -- Transformacao acabou e a missao NAO completou (sobrou titan): voa ate o titan que sobrou e se joga
    -- nele pra morrer e o auto click reiniciar
    CACAR_TITAN_DEPOIS_DO_SHIFT = true,
    VELOCIDADE_CACAR            = 70,

    TECLA_DESLIGAR = Enum.KeyCode.End, -- kill switch
    DEBUG = true,                       -- mensagens [FlyFarm] no console (F9)
}
-- ==========================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local VIM        = game:GetService("VirtualInputManager")
local LP         = Players.LocalPlayer
while not LP do task.wait(0.5); LP = Players.LocalPlayer end -- jogo ainda carregando

-- Queue teleport: no proximo teleporte (recomecar partida, lobby -> missao) o script roda sozinho de novo.
-- Fica ANTES da trava de place: assim ate no lobby ele ja deixa agendado pra quando entrar na missao.
do
    local SCRIPT_URL = "https://raw.githubusercontent.com/nightmereki-lab/TESTS/refs/heads/main/farm.lua"
    local queue = queue_on_teleport or queueonteleport or queue_on_tp
        or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
    local genv = getgenv and getgenv() or _G
    if queue and not genv.__ffQueued then
        genv.__ffQueued = true
        pcall(queue, ('loadstring(game:HttpGet("%s"))()'):format(SCRIPT_URL))
    end
end

-- Trava de place: fora do Outskirts o script nao faz nada (nem voa, nem aperta tecla)
if game.PlaceId ~= CONFIG.PLACE_ID then
    print(("[FlyFarm] Place errado (%d). So roda no %d. Nada foi executado."):format(game.PlaceId, CONFIG.PLACE_ID))
    return
end

-- ================= CICLO DE VIDA =================
-- Funciona no live-reload do Real (STATE) e em executor normal.
-- O stop global vale pros dois modos: qualquer jeito que rodar de novo desliga a copia anterior.
local env = getgenv()
if env.__ffStop then pcall(env.__ffStop) end

local STATE = STATE or (function()
    local s, conns, cleanups = {}, {}, {}
    function s.connect(sig, fn) local c = sig:Connect(fn); conns[#conns + 1] = c; return c end
    function s.onCleanup(fn) cleanups[#cleanups + 1] = fn end
    function s.alive() return true end
    s._stop = function()
        for _, c in ipairs(conns) do c:Disconnect() end
        for _, f in ipairs(cleanups) do pcall(f) end
    end
    return s
end)()

local parado = false
local function vivo() return not parado and STATE.alive() end

local function status(msg)
    if CONFIG.DEBUG then print("[FlyFarm] " .. msg) end
end

local function desligar(motivo)
    if parado then return end
    parado = true
    status("DESLIGADO: " .. motivo)
    if STATE._stop then STATE._stop() end
end
env.__ffStop = function() desligar("outra copia iniciou") end

local function rand(a, b) return a + math.random() * (b - a) end

-- roda uma funcao de loop protegida: erro nao mata a thread em silencio
local function protegido(nome, fn)
    task.spawn(function()
        while vivo() do
            local ok, err = pcall(fn)
            if not ok then
                status(("Erro em %s: %s"):format(nome, tostring(err)))
                task.wait(1)
            end
        end
    end)
end

-- ================= PERSONAGEM =================
local function getRoot()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hrp and hum and hum.Health > 0 then return char, hrp end
end

-- "barra cheia" = a partir de BARRA_TRANSFORMAR (80%), que ja da pra transformar
local function barraCheia()
    local bar, max = LP:GetAttribute("Bar"), LP:GetAttribute("Max_Bar")
    return type(bar) == "number" and type(max) == "number" and max > 0
        and bar >= max * CONFIG.BARRA_TRANSFORMAR
end

local function transformado()
    local char = LP.Character
    return char ~= nil and char:GetAttribute("Shifter") ~= nil
end

local function lancas()
    local char = LP.Character
    local n = char and char:GetAttribute("Spears")
    return type(n) == "number" and n or 0
end

-- ================= CHAO (raycast a cada 0.25s) =================
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
local ultimoRay, ultimaAltura = 0, math.huge
local function alturaDoChao(hrp)
    if os.clock() - ultimoRay < 0.25 then return ultimaAltura end
    ultimoRay = os.clock()
    local filtro = { LP.Character }
    for _, nome in ipairs({ "Characters", "Titans" }) do
        local f = workspace:FindFirstChild(nome)
        if f then filtro[#filtro + 1] = f end
    end
    rayParams.FilterDescendantsInstances = filtro
    local hit = workspace:Raycast(hrp.Position, Vector3.new(0, -2000, 0), rayParams)
    ultimaAltura = hit and (hrp.Position.Y - hit.Position.Y) or math.huge
    return ultimaAltura
end

-- ================= ACHAR TITAN VIVO (mesma deteccao do aot r.lua) =================
-- Titans ficam em workspace.Titans. Titan de verdade = Model com Humanoid vivo e hitbox de nuca
-- (Hitboxes.Hit.Nape). Pega o mais perto pela nuca e devolve a parte do corpo pra onde voar.
local function napeOf(titan)
    local hb = titan:FindFirstChild("Hitboxes")
    local hit = hb and hb:FindFirstChild("Hit")
    local nape = hit and hit:FindFirstChild("Nape")
    if nape and nape:IsA("BasePart") then return nape end
    return nil
end

local function titanAlive(titan)
    local hum = titan and titan.Parent and titan:FindFirstChildOfClass("Humanoid")
    return hum ~= nil and hum.Health > 0
end

local function acharTitan(hrp)
    local pasta = workspace:FindFirstChild("Titans")
    if not pasta then return nil end
    local melhor, melhorDist = nil, math.huge
    for _, t in ipairs(pasta:GetChildren()) do
        if t:IsA("Model") and titanAlive(t) then
            local nape = napeOf(t)
            if nape then
                local d = (nape.Position - hrp.Position).Magnitude
                if d < melhorDist then
                    -- voa pro corpo (onde ele pega/bate), nao pra nuca
                    melhor = t:FindFirstChild("HumanoidRootPart") or t.PrimaryPart or nape
                    melhorDist = d
                end
            end
        end
    end
    return melhor, melhorDist
end

-- ================= MOVIMENTO (fisica, nao teleporte) =================
local function mover(hrp, destino, velocidade)
    local delta = destino - hrp.Position
    local dist = delta.Magnitude
    if dist < 2 then
        hrp.AssemblyLinearVelocity = Vector3.zero
        return true
    end
    hrp.AssemblyLinearVelocity = delta.Unit * math.min(velocidade, dist * 6) -- freia perto do destino
    hrp.AssemblyAngularVelocity = Vector3.zero
    return false
end

-- ================= TECLAS =================
local VK = { D = 0x44, A = 0x41, S = 0x53, ["1"] = 0x31, ["2"] = 0x32, ["3"] = 0x33, ["4"] = 0x34, ["5"] = 0x35 }
local KC = { D = Enum.KeyCode.D, A = Enum.KeyCode.A, S = Enum.KeyCode.S, ["1"] = Enum.KeyCode.One,
             ["2"] = Enum.KeyCode.Two, ["3"] = Enum.KeyCode.Three, ["4"] = Enum.KeyCode.Four, ["5"] = Enum.KeyCode.Five }
local temKeypress = keypress ~= nil and keyrelease ~= nil

local function emFoco()
    if isrbxactive then return isrbxactive() end
    return true
end

local presas = {}
local function apertar(k, down)
    k = tostring(k)
    if not VK[k] then return end
    presas[k] = down or nil
    if temKeypress then
        if down then keypress(VK[k]) else keyrelease(VK[k]) end
    else
        VIM:SendKeyEvent(down, KC[k], false, game)
    end
end

local function soltarTudo()
    for k in pairs(presas) do pcall(apertar, k, false) end
end

local function tocar(k)
    if not (vivo() and emFoco()) then return end
    apertar(k, true)
    task.wait(CONFIG.TECLA_SEGURA + math.random() * 0.04)
    apertar(k, false)
end

local function doubleTap(k)
    if not (vivo() and emFoco()) then return end
    apertar(k, true)
    task.wait(CONFIG.TECLA_SEGURA + math.random() * 0.03)
    apertar(k, false)
    task.wait(CONFIG.TECLA_INTERVALO + math.random() * 0.04)
    apertar(k, true)
    task.wait(CONFIG.TECLA_SEGURA + math.random() * 0.03)
    apertar(k, false)
end

-- ================= HOTBAR / COOLDOWN =================
local function slotSkill(n)
    local ok, slot = pcall(function()
        return LP.PlayerGui.Interface.HUD.Main.Top["7"].Hotbar["Skill_" .. n]
    end)
    return ok and slot or nil
end

local function cooldownUI(n)
    local slot = slotSkill(n)
    return slot and slot:FindFirstChild("Cooldown", true)
end

local function skillPronta(n)
    local cd = cooldownUI(n)
    if not cd then return true end -- sem hotbar (ex: titan) -> assume pronta
    return not cd.Visible
end

local function todasProntas(lista)
    for _, n in ipairs(lista) do
        if not skillPronta(n) then return false end
    end
    return true
end

local function escolherSkill(lista)
    local prontas = {}
    for _, n in ipairs(lista) do
        if n ~= 5 and skillPronta(n) then prontas[#prontas + 1] = n end
    end
    return #prontas > 0 and prontas[math.random(#prontas)] or nil
end

-- ================= FIM DA MISSAO =================
-- O jogo mostra "MISSION COMPLETED" (ou "RAID COMPLETED") no PlayerGui quando a partida acaba.
local TITULOS_FIM = { ["MISSION COMPLETED"] = true, ["RAID COMPLETED"] = true }
local fimDeMissao = false -- tela de complete aparecendo: flips e skills param

local function textoLimpo(obj)
    local t = obj.ContentText ~= "" and obj.ContentText or obj.Text
    t = t:gsub("<[^>]->", ""):gsub("^%s+", ""):gsub("%s+$", "")
    return t:upper()
end

local function guiVisivel(obj)
    local cur = obj
    while cur and cur ~= LP.PlayerGui do
        if cur:IsA("GuiObject") and not cur.Visible then return false end
        if cur:IsA("ScreenGui") and not cur.Enabled then return false end
        cur = cur.Parent
    end
    return cur ~= nil and obj.AbsoluteSize.X > 0 and obj.AbsoluteSize.Y > 0
end

-- guarda o titulo achado; varre o PlayerGui no maximo 1x por segundo
local tituloFim, ultimaVarredura = nil, 0
local function telaDeCompleteAberta()
    if tituloFim and tituloFim.Parent and guiVisivel(tituloFim) and TITULOS_FIM[textoLimpo(tituloFim)] then
        return true
    end
    -- o guardado sumiu ou esta escondido: procura de novo (o jogo pode criar uma tela nova por partida)
    if os.clock() - ultimaVarredura < 1 then return false end
    ultimaVarredura = os.clock()
    local gui = LP:FindFirstChildOfClass("PlayerGui")
    if not gui then return false end
    for i, d in ipairs(gui:GetDescendants()) do
        if i % 800 == 0 then task.wait() end
        if (d:IsA("TextLabel") or d:IsA("TextButton")) and TITULOS_FIM[textoLimpo(d)] and guiVisivel(d) then
            tituloFim = d
            return true
        end
    end
    return false
end

-- ================= ESTADO =================
local alvoPos  = CONFIG.ALVO.Position
local topo     = alvoPos + Vector3.new(0, CONFIG.ALTURA, 0) -- onde fica flipando
local fase     = "subindo" -- subindo -> indo -> descendo -> flipando <-> voltando
local cruzeiro = alvoPos.Y + CONFIG.ALTURA_VOO -- altura da viagem (500, ou mais se ja tiver mais alto)
local alvoSubida = topo.Y -- ate onde sobe na fase "voltando"

local tocandoFlip = false -- no meio do double tap
local usandoSkill = false -- no meio de uma skill (flip espera)
local emCombo     = false -- etapa do combo rodando (segura os flips)
local numSubida   = 0     -- conta as subidas de volta (cada uma usa uma etapa do combo)
local modoShift   = false -- barra cheia: sem flip, vai pro ponto inicial e cai apertando 1
local shiftEtapa  = "indo" -- "indo" = voltando pro ponto inicial; "caindo" = solto, apertando 1
local modoMorrer  = false -- sem lanca + barra nao cheia: nao faz mais nada, deixa morrer
local semLancaDesde = nil
local modoCacar   = false -- saiu do titan sem a missao completar: vai se jogar no titan que sobrou
local eraTitan    = false -- (fica aqui em cima porque o Heartbeat e o respawn tambem usam)

local function chegou() return fase == "flipando" or fase == "voltando" end

-- Sem lanca e barra nao cheia por SEM_LANCA_ESPERA segundos -> modoMorrer.
-- So conta quando o atributo "Spears" existe (no spawn ele ainda nao existe e daria falso 0).
local function checarMorrer()
    if not CONFIG.MORRER_SEM_LANCA then return end
    if modoMorrer then
        if barraCheia() then
            modoMorrer = false; status("Barra encheu, saindo do modo morrer pra transformar")
        end
        return
    end
    local char = LP.Character
    local n = char and char:GetAttribute("Spears")
    if chegou() and type(n) == "number" and n <= 0 and not barraCheia() and not transformado() then
        if not semLancaDesde then
            semLancaDesde = os.clock()
            status(("Lancas acabaram: segurando no ar flipando por %ds esperando a barra"):format(CONFIG.SEM_LANCA_ESPERA))
        end
        if os.clock() - semLancaDesde >= CONFIG.SEM_LANCA_ESPERA then
            modoMorrer = true
            status("Sem lanca e barra nao cheia: parei tudo, deixando morrer pra recomecar")
        end
    else
        semLancaDesde = nil
    end
end

-- ================= MOVIMENTO (Heartbeat) =================
STATE.connect(RunService.Heartbeat, function()
    if parado then return end
    local char, hrp = getRoot()
    if not char then return end

    -- Saiu do titan sem a missao completar: voa ate o titan que sobrou e se joga nele (pra morrer e reiniciar)
    if modoCacar then
        if fimDeMissao or transformado() then
            modoCacar = false; status("Missao completou (ou transformou de novo), parei de ir no titan")
        else
            local alvo = acharTitan(hrp)
            if alvo then
                -- mira no corpo do titan e continua empurrando: encosta nele e ele pega/mata
                mover(hrp, alvo.Position, CONFIG.VELOCIDADE_CACAR)
            end
            -- sem titan achado: nao segura nada, so cai
        end
        return
    end

    checarMorrer()
    if modoMorrer then return end -- nao segura mais nada: cai e morre

    -- Barra cheia (depois de chegar): volta pro ponto inicial, ai solta e cai apertando 1
    if modoShift and chegou() and not transformado() then
        if shiftEtapa == "indo" then
            if mover(hrp, topo, CONFIG.VELOCIDADE) then
                shiftEtapa = "caindo"; status("No ponto inicial, caindo pra transformar")
            end
        elseif alturaDoChao(hrp) < CONFIG.ALTURA_MINIMA then
            -- caiu ate perto do chao e NAO transformou: volta pro ponto e tenta de novo (nao larga no chao)
            shiftEtapa = "indo"; status("Nao transformou na queda, voltando pro ponto pra tentar de novo")
        end
        return -- "caindo": nao segura nada, so cai (o loop de skills aperta o 1)
    end

    if fase == "subindo" then
        -- sobe ate 500 (se o chao do spawn ja for mais alto, usa a altura atual: nunca desce pra dentro do chao)
        cruzeiro = math.max(alvoPos.Y + CONFIG.ALTURA_VOO, hrp.Position.Y)
        if mover(hrp, Vector3.new(hrp.Position.X, cruzeiro, hrp.Position.Z), CONFIG.VELOCIDADE) then
            fase = "indo"; status(("No alto (%d), indo ate o alvo"):format(math.floor(cruzeiro - alvoPos.Y)))
        end

    elseif fase == "indo" then
        if mover(hrp, Vector3.new(topo.X, cruzeiro, topo.Z), CONFIG.VELOCIDADE) then
            fase = "descendo"; status(("Em cima do alvo, descendo pra %d"):format(CONFIG.ALTURA))
        end

    elseif fase == "descendo" then
        -- em cima do alvo o chao e baixo (terreno), entao aqui pode descer tranquilo
        if mover(hrp, topo, CONFIG.VELOCIDADE_DESCER) then
            fase = "flipando"; status("Cheguei em " .. CONFIG.ALTURA .. ", flips + skills")
        end

    elseif fase == "voltando" then
        if barraCheia() or transformado() then
            fase = "flipando"; status("Barra cheia, parei de subir")
            return
        end
        -- sobe so no eixo Y: o lado (X/Z) fica livre
        if hrp.Position.Y >= alvoSubida then
            fase = "flipando"; status("Voltei pra altura")
            return
        end
        local v = hrp.AssemblyLinearVelocity
        hrp.AssemblyLinearVelocity = Vector3.new(v.X, CONFIG.VELOCIDADE_SUBIR, v.Z)

    elseif fase == "flipando" then
        if transformado() or barraCheia() then return end
        local caiu = hrp.Position.Y < topo.Y - CONFIG.QUEDA
        if caiu or alturaDoChao(hrp) < CONFIG.ALTURA_MINIMA then
            alvoSubida = topo.Y
            numSubida += 1
            fase = "voltando"; status(("Caiu ate %d, voltando pra %d"):format(CONFIG.ALTURA - CONFIG.QUEDA, CONFIG.ALTURA))
        end
    end
end)

-- ================= LOOP 1: FLIPS =================
local lado = "D"
local function esperaFlip()
    task.wait(math.max(0.3, CONFIG.FLIP_INTERVALO + rand(-CONFIG.FLIP_VARIACAO, CONFIG.FLIP_VARIACAO)))
end
protegido("flips", function()
    if fimDeMissao then task.wait(0.3) return end -- missao acabou: nao flipa mais
    if barraCheia() and not modoShift and not transformado() then
        modoShift, shiftEtapa = true, "indo"
        status("Barra cheia: parei os flips, indo pro ponto inicial pra transformar")
    end

    local _, hrp = getRoot()
    if not (chegou() and hrp and emFoco() and not modoShift and not modoMorrer and not modoCacar) then
        task.wait(0.2)
        return
    end

    -- so flipa la em cima (perto de ALTURA). Caindo ou subindo de volta: sem flip
    if fase ~= "flipando" or hrp.Position.Y < topo.Y - CONFIG.FAIXA_FLIP then
        task.wait(0.1)
        return
    end

    -- lado pela posicao: direita do ponto de origem -> A, esquerda -> D (sempre volta pro meio)
    local cam = workspace.CurrentCamera
    if cam then
        local r = cam.CFrame.RightVector
        local plano = Vector3.new(r.X, 0, r.Z)
        local off = plano.Magnitude > 0 and (hrp.Position - topo):Dot(plano.Unit) or 0
        if math.abs(off) > 5 then
            lado = off > 0 and "A" or "D"
        else
            lado = lado == "D" and "A" or "D"
        end
    end

    while usandoSkill and vivo() do task.wait() end
    tocandoFlip = true
    doubleTap(lado)
    tocandoFlip = false
    esperaFlip()
end)

-- ================= SKILLS =================
-- durante o combo a trava fica presa: as skills da etapa saem inteiras, sem flip no meio
local function usar(n)
    while tocandoFlip and vivo() do task.wait() end
    usandoSkill = true
    task.wait(rand(0.05, 0.12)) -- reacao humana
    tocar(n)
    if not emCombo then usandoSkill = false end
end

-- aperta e confirma que saiu (entrou em cooldown); se o jogo ignorou (animacao da anterior), tenta de novo
local function usarConfirmado(n)
    if not cooldownUI(n) then usar(n); return true end
    for _ = 1, CONFIG.COMBO_MAX_TENTATIVAS do
        if not skillPronta(n) then return true end
        if not (vivo() and emFoco()) then return false end
        usar(n)
        local t = os.clock()
        while os.clock() - t < CONFIG.COMBO_RETENTATIVA do
            if not skillPronta(n) then return true end
            task.wait(0.03)
        end
    end
    return false
end

local function podeSeguir()
    return vivo() and not fimDeMissao and not modoShift and not modoMorrer and not modoCacar
        and not transformado() and chegou() and getRoot() ~= nil and emFoco()
end

-- Combo humano em duas subidas:
--   subida 1: buffs (4, 5)  ->  cai  ->  subida 2: ataque (2 -> 3, se sobrar lanca)  ->  repete
-- So gasta buff se os ataques tambem estiverem prontos (pra eles sairem na subida seguinte).
local etapaCombo  = "buff" -- o que a PROXIMA subida vai usar: "buff" ou "atk"
local subidaUsada = 0      -- numero da ultima subida que ja usou skill (uma etapa por subida)

local function tentarComboHumano()
    if subidaUsada == numSubida then return end -- essa subida ja usou a etapa dela
    local l = lancas()
    if l < CONFIG.LANCAS_PEQUENO then return end -- sem lanca: so flipa
    local usarGrande = (l - CONFIG.LANCAS_PEQUENO) >= CONFIG.LANCAS_GRANDE

    local ataque = {CONFIG.SKILL_ATK_PEQUENO}
    if usarGrande then ataque[#ataque + 1] = CONFIG.SKILL_ATK_GRANDE end

    local seq
    if etapaCombo == "buff" then
        local tudo = table.clone(CONFIG.SKILLS_BUFF)
        for _, n in ipairs(ataque) do tudo[#tudo + 1] = n end
        if not todasProntas(tudo) then return end -- algo em cooldown: espera (nao gasta buff sozinho)
        seq = table.clone(CONFIG.SKILLS_BUFF)
    else
        if not todasProntas(ataque) then return end -- ataque em cooldown: tenta de novo na mesma subida
        seq = ataque
    end

    subidaUsada = numSubida
    status(("Subida %d, %s (%d lancas): %s"):format(numSubida, etapaCombo == "buff" and "buffs" or "ataque", l, table.concat(seq, " -> ")))
    while tocandoFlip and vivo() do task.wait() end
    emCombo, usandoSkill = true, true -- segura os flips ate a etapa acabar
    local ok, err = pcall(function()
        for i, n in ipairs(seq) do
            if not podeSeguir() then break end
            if n == CONFIG.SKILL_ATK_GRANDE and lancas() < CONFIG.LANCAS_GRANDE then continue end
            if n == CONFIG.SKILL_ATK_PEQUENO and lancas() < CONFIG.LANCAS_PEQUENO then continue end
            if not usarConfirmado(n) then status("Skill " .. n .. " nao saiu") end
            if i < #seq then task.wait(rand(CONFIG.COMBO_PAUSA[1], CONFIG.COMBO_PAUSA[2])) end
        end
    end)
    emCombo, usandoSkill = false, false -- sempre libera os flips, mesmo se deu erro
    if not ok then error(err) end
    etapaCombo = etapaCombo == "buff" and "atk" or "buff" -- proxima subida faz a outra etapa
end

-- ================= LOOP 2: SKILLS / TRANSFORMAR =================
local proxTransformar, proxTitan = 0, 0
local tentativasShift = 0
local aberturaIdx = 1
protegido("skills", function()
    task.wait(rand(0.2, 0.35))
    if fimDeMissao then return end -- missao acabou: o loop do fim cuida do 5
    if modoMorrer then return end -- nao usa skill nenhuma, so espera morrer
    if modoCacar then return end  -- indo se jogar no titan: sem skill
    if not (chegou() and getRoot() and emFoco()) then return end

    local titan = transformado()
    if not titan and eraTitan and not fimDeMissao and CONFIG.CACAR_TITAN_DEPOIS_DO_SHIFT then
        eraTitan = false
        modoCacar = true
        status("Transformacao acabou e a missao nao completou: indo me jogar no titan que sobrou")
        return
    end
    if titan and not eraTitan then
        modoShift = false
        aberturaIdx = 1
        proxTitan = os.clock() + rand(0.8, 1.4)
        status("Transformou! Abrindo com " .. table.concat(CONFIG.TITAN_ABERTURA, " -> "))
    end
    eraTitan = titan

    if not titan and (modoShift or barraCheia()) then
        -- so aperta o 1 depois de chegar no ponto inicial e soltar (caindo)
        if modoShift and shiftEtapa == "caindo" and os.clock() >= proxTransformar then
            tentativasShift += 1
            status(("Apertando %d pra transformar (tentativa %d)"):format(CONFIG.SKILL_TRANSFORMAR, tentativasShift))
            usar(CONFIG.SKILL_TRANSFORMAR)
            -- verificacao: confere se virou titan antes de apertar de novo
            local t = os.clock()
            while os.clock() - t < CONFIG.TRANSFORMAR_CONFIRMA and vivo() do
                if transformado() then break end
                task.wait(0.1)
            end
            if transformado() then
                status(("Transformou na tentativa %d"):format(tentativasShift))
                tentativasShift = 0
            elseif not barraCheia() then
                -- a barra caiu abaixo do minimo sem transformar: volta ao ciclo normal
                status("Barra abaixo do minimo e nao transformou, voltando ao ciclo normal")
                modoShift, tentativasShift = false, 0
            end
            proxTransformar = os.clock() + rand(0.3, 0.6) -- a confirmacao ja esperou ~1.5s
        end

    elseif titan then
        if CONFIG.USAR_SKILLS and os.clock() >= proxTitan then
            local n
            if aberturaIdx <= #CONFIG.TITAN_ABERTURA then
                n = CONFIG.TITAN_ABERTURA[aberturaIdx]
                aberturaIdx += 1
            else
                n = escolherSkill(CONFIG.TITAN_SKILLS)
            end
            if n and n ~= 5 then
                status("Titan skill " .. n)
                usarConfirmado(n) -- confirma que saiu antes de partir pra proxima
            end
            proxTitan = os.clock() + rand(CONFIG.TITAN_INTERVALO[1], CONFIG.TITAN_INTERVALO[2])
        end

    elseif CONFIG.USAR_SKILLS then
        -- combo humano na SUBIDA de volta: uma subida buffs, a seguinte ataque (2 -> 3)
        if fase == "voltando" then tentarComboHumano() end
    end
end)

-- ================= LOOP 3: FIM DA MISSAO =================
-- Tela "MISSION COMPLETED" apareceu: para flips/skills e, se estiver de titan, aperta 5 pra sair.
-- A 5 so e apertada aqui, e so com essa tela aberta.
local tentativasSair = 0
protegido("fim", function()
    task.wait(0.3)
    local aberta = telaDeCompleteAberta()
    if aberta and not fimDeMissao then
        fimDeMissao, tentativasSair = true, 0
        status("Missao completa: parei flips e skills")
    elseif not aberta and fimDeMissao then
        fimDeMissao = false
        status("Tela de complete fechou")
    end

    if not (fimDeMissao and CONFIG.SAIR_TITAN_NO_FIM and transformado()) then return end
    if tentativasSair >= CONFIG.SAIR_TITAN_TENTATIVAS or not (vivo() and emFoco()) then return end

    while (tocandoFlip or usandoSkill) and vivo() do task.wait() end -- espera tecla que ja tava saindo
    tentativasSair += 1
    status(("Missao completa: apertando %d pra sair do titan (tentativa %d)"):format(CONFIG.SKILL_SAIR_TITAN, tentativasSair))
    task.wait(rand(0.15, 0.35)) -- reacao humana
    tocar(tostring(CONFIG.SKILL_SAIR_TITAN))

    -- confirma que saiu antes de apertar de novo
    local t = os.clock()
    while os.clock() - t < CONFIG.SAIR_TITAN_CONFIRMA and vivo() do
        if not transformado() then break end
        task.wait(0.1)
    end
    if not transformado() then
        status("Saiu do titan")
    elseif tentativasSair >= CONFIG.SAIR_TITAN_TENTATIVAS then
        status(("Nao saiu do titan depois de %d tentativas, parei de apertar"):format(tentativasSair))
    end
end)

-- ================= SEGURANCA =================
-- Qualquer sinal de warn/flag -> para tudo na hora (mesmo que seja so 1)

-- 1) Atributos no player: Exploiter/Blacklisted (os que o jogo usa) ou qualquer um com nome de warn/strike/flag
local NOMES_ATRIBUTO = { "exploit", "blacklist", "warn", "strike", "flag", "ban", "kick", "cheat", "suspic", "punish" }
local function atributoSuspeito(nome, valor)
    if valor == nil or valor == false or valor == 0 or valor == "" then return false end
    if type(valor) == "string" and string.lower(valor) == "false" then return false end
    local n = string.lower(nome)
    for _, p in ipairs(NOMES_ATRIBUTO) do
        if string.find(n, p, 1, true) then return true end
    end
    return false
end
for nome, valor in pairs(LP:GetAttributes()) do
    if atributoSuspeito(nome, valor) then
        desligar(("atributo de aviso no player: %s=%s - PARE de usar nessa conta"):format(nome, tostring(valor)))
        break
    end
end
STATE.connect(LP.AttributeChanged, function(nome)
    local valor = LP:GetAttribute(nome)
    if atributoSuspeito(nome, valor) then
        desligar(("recebeu aviso: %s=%s - PARE de usar nessa conta"):format(nome, tostring(valor)))
    end
end)

-- 2) Mensagens de aviso (mesma lista do aot r.lua). Texto >= 200 caracteres e ignorado
-- (descricoes de loja tipo "WARNING: If you do NOT have..." sao longas e nao contam).
local WARN_PHRASES = {
    "you have been flagged", "account flagged", "account has been suspended", "suspicious activity detected",
    "cheating detected", "exploit detected", "you will be banned", "you have been banned", "shadow banned",
    "shadowban issued", "under review for", "anti-cheat triggered", "anticheat triggered", "automated detection",
    "reviewed by our team", "violation of terms", "kicked for suspicious",
    "ถูกแบน", "แบนถาวร", "คำเตือน", "ตรวจพบการโกง", "ตรวจพบการใช้", "บัญชีถูกระงับ", "ระงับการใช้งาน",
}
local WARN_KEYWORDS = {
    "banned", "shadow ban", "shadowban", "exploiter", "exploiting", "cheating", "cheater",
    "suspended", "anti-cheat", "anticheat", "flagged", "violation", "suspicious",
    "warn", "strike", "moderation", "penalt",
    "แบน", "โกง", "เตือน", "ระงับ",
}
local function textoSuspeito(txt)
    if type(txt) ~= "string" then return false end
    local t = string.lower(txt)
    if t == "" or #t >= 200 then return false end
    for _, p in ipairs(WARN_PHRASES) do
        if string.find(t, p, 1, true) then return true end
    end
    for _, k in ipairs(WARN_KEYWORDS) do
        if string.find(t, k, 1, true) then return true end
    end
    return false
end
local function avisar(origem, txt)
    desligar(("%s: \"%s\" - PARE de usar nessa conta"):format(origem, string.sub(tostring(txt), 1, 80)))
end

-- 2a) Texto na tela (so o que APARECER depois de iniciar; o que ja tava la e do proprio jogo)
local function mostrando(obj)
    local cur = obj
    while cur and cur ~= game do
        if cur:IsA("GuiObject") and not cur.Visible then return false end
        if cur:IsA("ScreenGui") then return cur.Enabled end
        cur = cur.Parent
    end
    return true
end
local function guiPropria(obj)
    local g = obj:FindFirstAncestorOfClass("ScreenGui")
    if not g then return false end
    local n = g.Name
    return string.find(n, "Smooth Hub", 1, true) or string.find(n, "SmoothHub", 1, true)
        or string.find(n, "Cascade", 1, true)
end
local function vigiarLabel(obj)
    if not (obj:IsA("TextLabel") or obj:IsA("TextButton")) then return end
    if obj.Name == "Username" or guiPropria(obj) then return end -- nome de amigo / menu do hub = ruido
    local function checar()
        if not parado and textoSuspeito(obj.Text) and mostrando(obj) then avisar("aviso na tela", obj.Text) end
    end
    checar()
    -- popups costumam nascer vazios e o texto vem depois
    STATE.connect(obj:GetPropertyChangedSignal("Text"), checar)
    STATE.connect(obj:GetPropertyChangedSignal("Visible"), checar)
end
task.spawn(function()
    local pg = LP:WaitForChild("PlayerGui", 30)
    if not pg or parado then return end
    STATE.connect(pg.DescendantAdded, function(obj)
        if not parado then pcall(vigiarLabel, obj) end
    end)
end)

-- 2b) Mensagem que o servidor manda pelo remote POST
task.spawn(function()
    local ok, post = pcall(function()
        return game:GetService("ReplicatedStorage"):WaitForChild("Assets", 15):WaitForChild("Remotes", 15)
            :FindFirstChild("POST")
    end)
    if not ok or not post or parado then return end
    STATE.connect(post.OnClientEvent, function(...)
        for _, v in ipairs({ ... }) do
            if type(v) == "string" and #v > 3 and textoSuspeito(v) then
                avisar("aviso do servidor (POST)", v)
                return
            end
        end
    end)
end)

-- 2c) Mensagem de sistema no chat (sem TextSource = nao e outro jogador falando)
pcall(function()
    local tcs = game:GetService("TextChatService")
    STATE.connect(tcs.MessageReceived, function(msg)
        if msg.TextSource == nil and textoSuspeito(msg.Text) then
            avisar("aviso no chat", msg.Text)
        end
    end)
end)

-- Kill switch
STATE.connect(UIS.InputBegan, function(input, gpe)
    if not gpe and input.KeyCode == CONFIG.TECLA_DESLIGAR then
        desligar("tecla " .. CONFIG.TECLA_DESLIGAR.Name)
    end
end)

-- Renasceu: recomeca. Se o "personagem novo" for o titan da transformacao, nao mexe.
STATE.connect(LP.CharacterAdded, function()
    task.wait(1)
    if parado or transformado() then return end
    -- voltou a ser humano depois do titan (personagem novo) e a missao nao completou -> vai se jogar no titan
    local saiuDoTitan = eraTitan and not fimDeMissao and CONFIG.CACAR_TITAN_DEPOIS_DO_SHIFT
    modoShift, usandoSkill, tocandoFlip, eraTitan = false, false, false, false
    shiftEtapa = "indo"
    modoMorrer, semLancaDesde = false, nil
    if saiuDoTitan then
        modoCacar = true
        fase = "flipando" -- conta como "ja chegou" (nao refaz a viagem)
        status("Saiu do titan e a missao nao completou: indo me jogar no titan que sobrou")
    else
        modoCacar = false
        fase = "subindo"; status("Renasceu, recomecando")
    end
end)

STATE.onCleanup(function()
    parado = true
    soltarTudo()
    if env.__ffStop then env.__ffStop = nil end
end)

if not parado then
    status(("Iniciado | Barra %s/%s | END desliga"):format(tostring(LP:GetAttribute("Bar")),
        tostring(LP:GetAttribute("Max_Bar"))))
end
