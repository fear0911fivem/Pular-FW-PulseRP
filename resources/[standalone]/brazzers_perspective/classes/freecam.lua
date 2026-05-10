---@class brazzers_freecam : OxClass
---@field cam number
---@field fov number
---@field movement table coords
---@field block boolean
---@field lock boolean
local freecam = lib.class('brazzers_freecam')

-- -------------------------------------------------------------------------- --
--                                  Functions                                 --
-- -------------------------------------------------------------------------- --

function freecam:constructor()
    self.cam = nil
    self.fov = 75.0
    self.movement = vector3(0, 0, 0)
    self.block = false
    self.lock = false
end

return freecam:new()