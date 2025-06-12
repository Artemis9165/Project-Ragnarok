--!strict
local module = {}

export type characterName = 'Guy' | 'Outlaw' | 'Fencer' | 'Special' | 'HolyGrail' | 'Hunter' | 'EscapeArtist' | 'PesteringSnow' | 'Template'

export type GeneralAnimations = {
	Idle : Animation,
	Walk : Animation,
	Sprint : Animation,
	Jump : Animation,
	Fall : Animation
}

export type BlockAnimations = {
	Startup : Animation,
	Hold : Animation
}

export type DashAnimations = {
	Forward: Animation,
	Back: Animation,
	Left: Animation,
	Right: Animation
}

export type combo = {
	One : Animation,
	Two : Animation,
	Three : Animation,
	Four : Animation,
}

export type comboFinishers = {
	Slam : Animation,
	Uppercut : Animation
}

export type M1Animations = {
	Combo : combo,
	ComboFinishers : comboFinishers
}

export type Special = {
	Name : string,
	Animation : Animation | {Animation},
	Cooldown : number,
}

export type Awakening = {
	Name : string,
	Animation : Animation,
	DestroysEnviroment : boolean
}

export type Ultimate = {
	Name : string,
	Animation : Animation,
	DestroysEnviroment : boolean,
	Damage : number,
}

return module
