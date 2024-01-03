Game = {
    Player = {
        id = "",
        coins = {},
        new = function(self, id)
            local obj = {}
            setmetatable(obj, self)
            self.id = id
            self.coins = { [2] = 1, [3] = 1, [4] = 1, [5] = 1, [6] = 1 }
            return obj
        end,
        __index = Game.Player,
    },

    Horse = {
        id = 0,
        position = 0,
        reward = 0,
        new = function(self, id)
            local obj = {}
            setmetatable(obj, self)
            self.id = id
            self.position = 0
            if (id == 1 or id == 9) then
                self.reward = 3
            elseif (id == 2 or id == 8) then
                self.reward = 3
            elseif (id == 3 or id == 7) then
                self.reward = 2
            elseif(id == 4 or id == 6)then
                self.reward = 1
            else
                self.reward = 0
            end
            return obj
        end,
        run = function(self)
            self.position = self.position + 1
            return self.position == 15
        end,
        __index = Game.Horse,
    },
    playerList = {},
    addPlayer = function(self, id)
        table.insert(self.playerList, Game.Player:new(id))
    end,
    horses = {},
    addHorse = function(self)
        table.insert(self.horses, Game.Horse:new(self.horses.length + 1))
    end,
    __index = Game
}

function Game:new(PlayerIdList)
    local obj = {}
    setmetatable(obj, self)
    for _, id in ipairs(PlayerIdList) do
        obj.addPlayer(id)
    end
end
