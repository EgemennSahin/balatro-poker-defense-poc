local MAX_TOWERS = 8
local MAX_WAVES = 5

local waves = {
    {count = 8, type = 'normal', hp = 12},
    {count = 8, type = 'fast', hp = 8},
    {count = 8, type = 'armored', hp = 20, armor = 3},
    {count = 8, type = 'mixed'},
    {count = 1, type = 'boss', hp = 100, armor = 4},
}

local function enemy_for(state)
    local wave = waves[state.wave]
    if not wave then return nil end

    local enemy_type = wave.type
    if enemy_type == 'mixed' then
        enemy_type = ({'normal', 'fast', 'armored'})[(state.enemy - 1) % 3 + 1]
    end

    local spec = {
        normal = {hp = 12, armor = 0, speed = 1},
        fast = {hp = 8, armor = 0, speed = 2},
        armored = {hp = 20, armor = 3, speed = 1},
        boss = {hp = 100, armor = 4, speed = 1},
    }
    local result = copy_table(spec[enemy_type])
    result.type = enemy_type
    if wave.type ~= 'mixed' then
        result.hp = wave.hp or result.hp
        result.armor = wave.armor or result.armor
    end
    return result
end

local function new_state()
    return {wave = 1, enemy = 1, position = 8, lives = 10, towers = {}}
end

local function get_enemy(state)
    if state.complete or state.failed then return nil end
    if state.wave > MAX_WAVES then
        state.complete = true
        return nil
    end
    if not state.enemy_hp then
        local spec = enemy_for(state)
        if not spec then return nil end
        state.enemy_type = spec.type
        state.enemy_hp = spec.hp
        state.enemy_armor = spec.armor
        state.enemy_speed = spec.speed
    end
    return state
end

local function advance_enemy(state, cleared)
    state.enemy = state.enemy + 1
    if state.enemy > waves[state.wave].count then
        state.wave = state.wave + 1
        state.enemy = 1
        if state.wave > MAX_WAVES then
            state.complete = cleared
            state.failed = not cleared
        end
    end
    state.enemy_hp = nil
    state.position = 8
end

local function get_tower(state, card)
    for i, tower in ipairs(state.towers) do
        if tower.id == card.playing_card then return tower, i end
    end
    if #state.towers >= MAX_TOWERS then return nil end
    local tower = {
        id = card.playing_card,
        rank = card.base.id or 2,
        suit = card.base.suit,
    }
    state.towers[#state.towers + 1] = tower
    return tower, #state.towers
end

local function fire_hand(state, context)
    local hand = context.scoring_hand or {}
    local hand_name = context.scoring_name or 'High Card'
    if state.complete or state.failed then return 0, 0, hand_name end
    local pair = hand_name == 'Pair' or hand_name == 'Two Pair'
        or hand_name == 'Three of a Kind' or hand_name == 'Full House'
        or hand_name == 'Four of a Kind' or hand_name == 'Five of a Kind'
        or hand_name == 'Flush House' or hand_name == 'Flush Five'
    local flush = hand_name == 'Flush' or hand_name == 'Straight Flush'
    local straight = hand_name == 'Straight' or hand_name == 'Straight Flush'
    local total_damage, fired = 0, 0

    for _, playing_card in ipairs(hand) do
        local tower = get_tower(state, playing_card)
        local enemy = get_enemy(state)
        if tower and enemy then
            local damage = tower.rank
            if pair then damage = damage + 2 end
            if flush then damage = damage + 2 end
            if straight then damage = damage + 2 end
            if tower.suit == 'Clubs' and state.enemy_type == 'fast' then damage = damage + 3 end
            if tower.suit ~= 'Spades' then damage = math.max(1, damage - state.enemy_armor) end

            state.enemy_hp = state.enemy_hp - damage
            total_damage = total_damage + damage
            fired = fired + 1

            if state.enemy_hp <= 0 then
                if tower.suit == 'Hearts' then state.lives = math.min(10, state.lives + 1) end
                if tower.suit == 'Diamonds' then ease_dollars(1) end
                advance_enemy(state, true)
            end
        end
    end

    local current = get_enemy(state)
    if current then
        current.position = current.position - current.enemy_speed
        if current.position <= 0 then
            state.lives = state.lives - 1
            if state.lives <= 0 then state.failed = true end
            advance_enemy(state, false)
        end
    end

    return total_damage, fired, hand_name
end

SMODS.Joker {
    key = 'lane_commander',
    atlas = 'Joker',
    pos = {x = 0, y = 0},
    rarity = 1,
    weight = 100,
    cost = 4,
    blueprint_compat = false,
    loc_txt = {
        name = 'Lane Commander',
        text = {
            'The first 8 scored cards become towers',
            'Played poker hands activate their towers',
            'Suit and hand type change each attack',
            'Lane: Wave #1# / Lives #2#',
        },
    },
    loc_vars = function(self, info_queue, card)
        local state = G.GAME and G.GAME.poker_defense
        return {vars = {state and math.min(state.wave, MAX_WAVES) or 1, state and state.lives or 10}}
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            G.GAME.poker_defense = G.GAME.poker_defense or new_state()
            local state = G.GAME.poker_defense
            local damage, fired, hand_name = fire_hand(state, context)
            sendDebugMessage(('hand=%s towers=%d damage=%d wave=%d enemy=%d hp=%s lives=%d')
                :format(hand_name, fired, damage, state.wave, state.enemy,
                    tostring(state.enemy_hp), state.lives), 'PokerDefense')

            local message = state.complete and 'Lane Clear!'
                or state.failed and 'Lane Breached!'
                or (damage .. ' Damage')
            return {chips = damage, message = message, colour = G.C.CHIPS}
        end
    end,
}

SMODS.DrawStep {
    key = 'pokerdefense_lane',
    order = 45,
    conditions = {vortex = false, facing = 'front', front_hidden = false},
    func = function(card)
        if not card.config.center.key:match('lane_commander$') then return end
        local state = G.GAME and G.GAME.poker_defense
        if not state then return end

        local suit_colors = G.C.SUITS or {}
        local left, step, y, radius = 0.16, 0.095, card.T.h - 0.14, 0.025
        love.graphics.push('all')
        prep_draw(card, 1)
        love.graphics.setColor({0.25, 0.25, 0.30, 1})
        love.graphics.line(left, y, left + 7 * step, y)
        for slot = 1, MAX_TOWERS do
            local x = left + (slot - 1) * step
            local tower = state.towers[slot]
            if tower then
                love.graphics.setColor(suit_colors[tower.suit] or G.C.WHITE)
                love.graphics.circle('fill', x, y, radius)
            else
                love.graphics.setColor({0.12, 0.12, 0.15, 0.9})
                love.graphics.circle('line', x, y, radius)
            end
        end
        if not state.complete and not state.failed then
            local enemy_x = left + (state.position - 1) * step
            love.graphics.setColor(G.C.RED)
            love.graphics.polygon('fill', enemy_x, y - 0.065, enemy_x - 0.025, y - 0.025, enemy_x + 0.025, y - 0.025)
        end
        love.graphics.pop()
    end,
}

sendDebugMessage('Loaded', 'PokerDefense')
