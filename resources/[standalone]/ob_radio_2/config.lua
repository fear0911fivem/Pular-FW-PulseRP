Config = {}

Config.DefaultVolume = 0.4         -- 0.0 to 1.0
Config.MaxAudioDistance = 30.0     -- meters - beyond this, silent
Config.MuffleStartDistance = 5.0   -- meters - lowpass filter begins
Config.DisableNativeRadio = true   -- Disable GTA's built-in radio

Config.AudioRoofOcclusion = {
    [0] = { occlusion = 0.40, cutoff = 1200 },  -- RAISED
    [1] = { occlusion = 0.65, cutoff = 22000 }, -- LOWERING
    [2] = { occlusion = 0.65, cutoff = 22000 }, -- LOWERED
    [3] = { occlusion = 0.65, cutoff = 22000 }, -- RAISING
    [5] = { occlusion = 0.40, cutoff = 1200 },  -- STUCK_RAISED
    [6] = { occlusion = 0.65, cutoff = 22000 }, -- STUCK_LOWERED
}

-- Vehicles where the radio is disabled.
-- Class 18 = Emergency (police, ambulance, firetruck).
Config.DisableInEmergencyClass = true
-- Additional specific models by name. Example: {'police', 'police2', 'sheriff', 'riot'}
Config.DisabledVehicleModels = {}

Config.Stations = {
    {
        id = 'OB_RADIO_1',
        label = 'J7 Radio',
        logo = 'j7radio.png',
        songs = {
            { file = 'badhabits.ogg', title = 'Bad Habits', artist = 'KUURO', duration = 187 },
        },
    },
    {
        id = 'OB_RADIO_2',
        label = 'Sleep Token.FM',
        logo = 'sleeptoken.png',
        songs = {
            { file = 'gethsemane.ogg', title = 'Gethsemane', artist = 'Sleep Token', duration = 384 },
        },
    },
    {
        id = 'OB_RADIO_3',
        label = 'DnB Radio',
        logo = 'dnb.png',
        songs = {
            { file = 'stepaway.ogg', title = 'Step Away', artist = 'Chase & Status', duration = 248 },
            { file = 'nightshift.ogg', title = 'Night Shift', artist = 'Charlotte Pink', duration = 175 },
            { file = 'phoneline.ogg', title = 'Phoneline', artist = 'Pola & Bryson & Emily Makis', duration = 225 },
            { file = 'naked.ogg', title = 'Naked', artist = 'Kenya Grace', duration = 224 },
            { file = 'rusko_somebody_to_love.ogg', title = 'Somebody To Love (Sigma Remix)', artist = 'Rusko', duration = 347 },
            { file = 'porter_robinson_language.ogg', title = 'Language', artist = 'Porter Robinson', duration = 369 },
            { file = 'andy_c_heartbeat_loud.ogg', title = 'Heartbeat Loud', artist = 'Andy C', duration = 192 },
            { file = 'delta_heavy_bad_decisions.ogg', title = 'Bad Decisions', artist = 'Delta Heavy', duration = 195 },
            { file = 'chase_status_end_credits.ogg', title = 'End Credits', artist = 'Chase & Status', duration = 204 },
            { file = 'rudimental_feel_the_love.ogg', title = 'Feel The Love', artist = 'Rudimental', duration = 241 },
            { file = 'sigma_changing.ogg', title = 'Changing', artist = 'Sigma', duration = 208 },
            { file = 'rova_take_me_higher.ogg', title = 'Take Me Higher', artist = 'Rova', duration = 180 },
            { file = 'high_contrast_agony_ecstasy.ogg', title = 'The Agony & The Ecstasy', artist = 'High Contrast', duration = 202 },
            { file = 'wilkinson_dirty_love.ogg', title = 'Dirty Love', artist = 'Wilkinson', duration = 193 },
            { file = 'sub_focus_elevate.ogg', title = 'Elevate', artist = 'Sub Focus', duration = 193 },
            { file = 'nate_band_drugs_i_like.ogg', title = 'Drugs I Like', artist = 'Nate Band', duration = 199 },
            { file = 'skepsis_been_here_before.ogg', title = 'Been Here Before', artist = 'Skepsis', duration = 170 },
            { file = 'sigma_adrenaline_rush.ogg', title = 'Adrenaline Rush', artist = 'Sigma', duration = 195 },
            { file = 'luude_oh_my.ogg', title = 'Oh My', artist = 'Luude', duration = 159 },
        },
    },
    {
        id = 'OB_RADIO_4',
        label = 'Dave.FM',
        logo = 'dave.png',
        songs = {
            { file = 'verdansk.ogg', title = 'Verdansk', artist = 'Dave', duration = 319 },
        },
    },
    {
        id = 'OB_RADIO_5',
        label = 'Drinks On Me.FM',
        logo = 'drinksonme.png',
        songs = {
            { file = 'wherehaveyoubeen.ogg', title = 'Where Have You Been', artist = 'Drinks On Me', duration = 180 },
        },
    },
    {
        id = 'OB_RADIO_6',
        label = 'Billie Eilish.FM',
        logo = 'billie.png',
        songs = {
            { file = 'happierthanever.ogg', title = 'Happier Than Ever', artist = 'Billie Eilish', duration = 315 },
        },
    },
    {
        id = 'OB_RADIO_7',
        label = 'OldSchool.FM',
        logo = 'oldschool.png',
        songs = {
            { file = 'california_love.ogg',       title = 'California Love',       artist = '2Pac',                    duration = 285 },
            { file = 'drop_it_like_its_hot.ogg',  title = "Drop It Like It's Hot", artist = 'Snoop Dogg',              duration = 263 },
            { file = 'gangstas_paradise.ogg',     title = "Gangsta's Paradise",    artist = 'Coolio',                  duration = 256 },
            { file = 'gold_digger.ogg',           title = 'Gold Digger',           artist = 'Kanye West',              duration = 221 },
            { file = 'got_5_on_it.ogg',           title = 'I Got 5 On It',         artist = 'Luniz',                   duration = 256 },
            { file = 'hate_it_or_love_it.ogg',    title = 'Hate It or Love It',    artist = 'The Game',                duration = 206 },
            { file = 'how_we_do.ogg',             title = 'How We Do',             artist = 'The Game',                duration = 264 },
            { file = 'hypnotize.ogg',             title = 'Hypnotize',             artist = 'The Notorious B.I.G.',    duration = 230 },
            { file = 'in_da_club.ogg',            title = 'In Da Club',            artist = '50 Cent',                 duration = 248 },
            { file = 'juicy.ogg',                 title = 'Juicy',                 artist = 'The Notorious B.I.G.',    duration = 286 },
            { file = 'ms_jackson.ogg',            title = 'Ms. Jackson',           artist = 'OutKast',                 duration = 298 },
            { file = 'next_episode.ogg',          title = 'The Next Episode',      artist = 'Dr. Dre',                 duration = 197 },
            { file = 'no_diggity.ogg',            title = 'No Diggity',            artist = 'Blackstreet',             duration = 270 },
            { file = 'pimp.ogg',                  title = 'P.I.M.P.',              artist = '50 Cent',                 duration = 299 },
            { file = 'whats_the_difference.ogg',  title = "What's the Difference", artist = 'Dr. Dre',                 duration = 244 },
            { file = 'work_it.ogg',               title = 'Work It',               artist = 'Missy Elliott',           duration = 265 },
            { file = 'x_gon_give_it.ogg',         title = "X Gon' Give It to Ya",  artist = 'DMX',                     duration = 219 },
        },
    },
    {
        id = 'OB_RADIO_8',
        label = 'Nostalgia Radio',
        logo = 'nostalgia.png',
        songs = {
            { file = 'cod_115.ogg',                                  title = '115',                                      artist = 'Treyarch', duration = 228 },
            { file = 'cod_a_light_from_the_shore_feat_teemu_m_ntysaari.ogg', title = 'A Light From The Shore (feat. Teemu Mäntysaari)', artist = 'Treyarch', duration = 412 },
            { file = 'cod_abracadavre.ogg',                          title = 'Abracadavre',                              artist = 'Treyarch', duration = 370 },
            { file = 'cod_alone.ogg',                                title = 'Alone',                                    artist = 'Treyarch', duration = 345 },
            { file = 'cod_always_running.ogg',                       title = 'Always Running',                           artist = 'Treyarch', duration = 359 },
            { file = 'cod_archangel.ogg',                            title = 'Archangel',                                artist = 'Treyarch', duration = 310 },
            { file = 'cod_beauty_of_annihilation.ogg',               title = 'Beauty Of Annihilation',                   artist = 'Treyarch', duration = 273 },
            { file = 'cod_beauty_of_annihilation_remix.ogg',         title = 'Beauty Of Annihilation (Remix)',           artist = 'Treyarch', duration = 218 },
            { file = 'cod_carrion.ogg',                              title = 'Carrion',                                  artist = 'Treyarch', duration = 258 },
            { file = 'cod_coming_home.ogg',                          title = 'Coming Home',                              artist = 'Treyarch', duration = 203 },
            { file = 'cod_dead_again.ogg',                           title = 'Dead Again',                               artist = 'Treyarch', duration = 289 },
            { file = 'cod_dead_ended.ogg',                           title = 'Dead Ended',                               artist = 'Treyarch', duration = 253 },
            { file = 'cod_dead_flowers.ogg',                         title = 'Dead Flowers',                             artist = 'Treyarch', duration = 302 },
            { file = 'cod_i_am_the_well.ogg',                        title = 'I Am The Well',                            artist = 'Treyarch', duration = 271 },
            { file = 'cod_lost.ogg',                                 title = 'Lost',                                     artist = 'Treyarch', duration = 234 },
            { file = 'cod_lullaby_for_a_deadman.ogg',                title = 'Lullaby For A Deadman',                    artist = 'Treyarch', duration = 246 },
            { file = 'cod_pareidolia.ogg',                           title = 'Pareidolia',                               artist = 'Treyarch', duration = 370 },
            { file = 'cod_samantha_s_ballad.ogg',                    title = "Samantha's Ballad",                        artist = 'Treyarch', duration = 230 },
            { file = 'cod_shockwave.ogg',                            title = 'Shockwave',                                artist = 'Treyarch', duration = 247 },
            { file = 'cod_snakeskin_boots.ogg',                      title = 'Snakeskin Boots',                          artist = 'Treyarch', duration = 181 },
            { file = 'cod_the_gift.ogg',                             title = 'The Gift',                                 artist = 'Treyarch', duration = 270 },
            { file = 'cod_the_one.ogg',                              title = 'The One',                                  artist = 'Treyarch', duration = 291 },
            { file = 'cod_undone.ogg',                               title = 'Undone',                                   artist = 'Treyarch', duration = 231 },
            { file = 'cod_undone_alternate_version.ogg',             title = 'Undone (Alternate Version)',               artist = 'Treyarch', duration = 330 },
            { file = 'cod_we_all_fall_down.ogg',                     title = 'We All Fall Down',                         artist = 'Treyarch', duration = 190 },
            { file = 'cod_where_are_we_going.ogg',                   title = 'Where Are We Going',                       artist = 'Treyarch', duration = 144 },
            { file = 'cod_where_are_we_going_2018_edition.ogg',      title = 'Where Are We Going (2018 Edition)',        artist = 'Treyarch', duration = 309 },
        },
    },
}
