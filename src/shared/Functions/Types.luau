--!strict
local public = {}

export type characterName = 'Guy' | 'Outlaw' | 'Fencer' | 'Special' | 'HolyGrail' | 'Hunter' | 'EscapeArtist' | 'PesteringSnow' | 'Template'

export type stateName = 'blocking' | 'comboCount' | 'jumping' | 'attacking' | 'hurting' | 'comboCooldown' | 'attackDebounce' | 'lastComboTime' | 'sprinting' | 'dashing' | 'isSpaceDown' | 'special1' | 'special2' | 'special3' | 'special4'

export type specialName = 'special1' | 'special2' | 'special3' | 'special4'  | 'specialR' | 'awakenedSpecial1' | 'awakenedSpecial2' | 'awakenedSpecial3' | 'awakenedSpecial4' | 'awakenedSpecialR' | 'ultimate'

export type stateType = 'combat' | 'misc' | 'specialsCooldown'

export type detectionType = 'raycast' | 'region3'

export type m1AttackType = 'm1' | 'uppercut' | 'slam'

export type dashType = 'Forward' | 'Back' | 'Side'

export type specialKeybind = '1' | '2' | '3' | '4' | 'R' | ''

export type grabType = 'Soft Grab' | 'Soft Command Grab' | 'Hard Command Grab'

export type counterType = 'm1' | 'special'

export type special = {
	name : string,
	keybind : specialKeybind,
	cooldown : number,
}

export type damagingSpecial = {
	general : special,
	damage : number | {number},
}

export type blockBreakSpecial = {
	general : damagingSpecial,
	blockPercentage : number
}

export type grabSpecial = {
	general : damagingSpecial,
	grabType : grabType
}

export type counterSpecial = {
	general : damagingSpecial,
	counterType : counterType | {counterType}
}

export type universalDamagePromotion = {
	general : special,
	duration : number,
	percentIncrease : number
}

export type specialType = special | damagingSpecial | blockBreakSpecial | grabSpecial | counterSpecial | universalDamagePromotion

export type specialData = {
	awakenedSpecial1 : specialType,
	awakenedSpecial2 : specialType,
	awakenedSpecial3 : specialType,
	awakenedSpecial4 : specialType,
	special1 : specialType,
	special2 : specialType,
	special3 : specialType,
	special4 : specialType,
}

export type specialDataR = {
	general : specialData,
	specialR : specialType
}

export type combatState = {
	blocking : boolean,
	comboCount : number,
	jumping : boolean,
	attacking : boolean,
	hurting : boolean,
	comboCooldown : boolean,
	attackDebounce : boolean,
	lastComboTime : number,
}

export type miscState = {
	sprinting : boolean,
	dashing : boolean,
	isSpaceDown : boolean
}

export type PlayerState = {
	combat : combatState,
	misc : miscState,
}

public.determineSpecialType = function(value) : string
	if value.counterType then return 'counter' end
	if value.grabType then return 'grab' end
	if value.blockPercentage then return 'blockBreaker' end
	if type(value.damage) == 'table' then return 'multiHit' end
	if value.damage then return 'damaging' end
	return 'regular'
end

return public
