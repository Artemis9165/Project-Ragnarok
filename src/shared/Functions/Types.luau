--!strict
local module = {}

export type characterName = 'Guy' | 'Outlaw' | 'Fencer' | 'Special' | 'HolyGrail' | 'Hunter' | 'EscapeArtist' | 'PesteringSnow' | 'Template'

export type stateName = 'blocking' | 'comboCount' | 'jumping' | 'attacking' | 'hurting' | 'comboCooldown' | 'attackDebounce' | 'lastComboTime' | 'sprinting' | 'dashing'

export type stateType = 'combat' | 'misc'

export type combatState = {
	blocking: boolean,
	comboCount: number,
	jumping: boolean,
	attacking: boolean,
	hurting: boolean,
	comboCooldown: boolean,
	attackDebounce: boolean,
	lastComboTime: number,
}

export type miscState = {
	sprinting: boolean,
	dashing: boolean,
}

export type PlayerState = {
	combat: combatState,
	misc: miscState,
}

return module
