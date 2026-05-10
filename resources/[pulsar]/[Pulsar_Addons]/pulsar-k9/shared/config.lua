return {
    K9 = {
        -- "" = unassigned default; bind still appears in FiveM Settings → Key Bindings (pulsar-kbs).
        K9KeyCommands = "",
        K9KeyFollowAttack = "",
        job = "police",                                        -- Job that can use the K9
        DogName = "Police K9",                                 -- Global name of the dog
        DogCoords = vector4(475.241, -1005.609, 26.853, 287.516), -- Vector4 for the dog's spawn (x, y, z, heading)
        searchTime = 10,                                       -- Time it takes to search (in seconds)
        illegalItems = {                                       -- List of illegal items (Change this to whatever you'd want the dog to search for)
            "coke_brick",
            "diamond"
        },
        DogModelProps = {
            [1] = {
                Header = "Police K9 1",                    -- Name of the dog
                Description = "Police Issued K9 Unit Dog", -- Description of the dog
                Dog = "a_c_shepherd",                      -- Model
                Colour = 1,                                -- Texture Variant
                Vest = 1                                   -- Vest Variant
            },
            [2] = {
                Header = "Police K9 2",
                Description = "Police Issued K9 Unit Dog",
                Dog = "a_c_shepherd",
                Colour = 2,
                Vest = 2
            },
            [3] = {
                Header = "Police K9 3",
                Description = "Police Issued K9 Unit Dog",
                Dog = "a_c_shepherd",
                Colour = 3,
                Vest = 3
            }
        },
        Animations = { -- Animations for the dog
            sit = {    -- Sit animation
                dict = "creatures@rottweiler@amb@world_dog_sitting@idle_a",
                anim = "idle_b"
            },
            laydown = { -- Laydown animation
                dict = "creatures@rottweiler@amb@sleep_in_kennel@",
                anim = "sleep_in_kennel"
            },
            searchhit = { -- Finshed search animation
                dict = "creatures@rottweiler@indication@",
                anim = "indicate_high"
            }
        }
    }
}
