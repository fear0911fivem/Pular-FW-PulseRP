-- aggregator for all pulsar item files
-- returns a flat array of every item across all categories
-- add new item files here when you add them, thats it

local files = {
    'data.pulsar-items.misc',
    'data.pulsar-items.medical',
    'data.pulsar-items.drugs',
    'data.pulsar-items.tools',
    'data.pulsar-items.labor',
    'data.pulsar-items.crafting',
    'data.pulsar-items.fishing',
    'data.pulsar-items.containers',
    'data.pulsar-items.evidence',
    'data.pulsar-items.unique',
    'data.pulsar-items.loot',
    'data.pulsar-items.robbery',
    'data.pulsar-items.vehicles',
    'data.pulsar-items.dangerous',
    'data.pulsar-items.food.food',
    'data.pulsar-items.food.alcohol',
    'data.pulsar-items.food.bakery',
    'data.pulsar-items.food.beanmachine',
    'data.pulsar-items.food.burgershot',
    'data.pulsar-items.food.ingredients',
    'data.pulsar-items.food.noodles',
    'data.pulsar-items.food.pizza_this',
    'data.pulsar-items.food.prego',
    'data.pulsar-items.food.prison',
    'data.pulsar-items.food.sandwich',
    'data.pulsar-items.food.train',
    'data.pulsar-items.food.uwu',
    'data.pulsar-items.weapons.base',
    'data.pulsar-items.weapons.ammo',
    'data.pulsar-items.weapons.bullets',
    'data.pulsar-items.weapons.attachments',
    'data.pulsar-items.weapons.bobcat',
}

local all = {}
for _, path in ipairs(files) do
    local items = lib.load(path)
    if items then
        for i = 1, #items do
            all[#all + 1] = items[i]
        end
    else
        print('^3[pulsar-items] file not found: ' .. path .. '^0')
    end
end

return all
