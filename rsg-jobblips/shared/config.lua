Config = {}
Config.DefaultBlipColor = `BLIP_MODIFIER_MP_COLOR_1` -- White
Config.DefaultBlipSprite = GetHashKey("blip_ambient_ped_medium")
Config.DefaultBlipScale = 0.2
Config.BlipsEnabled = true
Config.Jobs = {
    ['vallaw'] = {
        tracked = true,
        blipColor = `BLIP_MODIFIER_MP_COLOR_1`, -- blue
        blipSprite = GetHashKey("blip_hat")
    },
	['blklaw'] = {
        tracked = true,
        blipColor = `BLIP_MODIFIER_MP_COLOR_1`, -- blue
        blipSprite = GetHashKey("blip_hat")
    },
	['rholaw'] = {
        tracked = true,
        blipColor = `BLIP_MODIFIER_MP_COLOR_1`, -- blue
        blipSprite = GetHashKey("blip_hat")
    },
	['stdenlaw'] = {
        tracked = true,
        blipColor = `BLIP_MODIFIER_MP_COLOR_1`, -- blue
        blipSprite = GetHashKey("blip_hat")
    },
	['strlaw'] = {
        tracked = true,
        blipColor = `BLIP_MODIFIER_MP_COLOR_1`, -- blue
        blipSprite = GetHashKey("blip_hat")
    },
    ['medic'] = {
        tracked = true,
        blipColor = `BLIP_MODIFIER_MP_COLOR_30`, -- red
        blipSprite = GetHashKey("blip_shop_doctor")
    },
	['horsetrainer'] = {
        tracked = true,
        blipColor = `BLIP_MODIFIER_MP_COLOR_6`, -- red
        blipSprite = GetHashKey("blip_stable")
    },
	['unemployed'] = {
        tracked = true,
        blipColor = `BLIP_MODIFIER_MP_COLOR_32`, -- red
        blipSprite = GetHashKey("blip_weapon_melee")
    }
}