class_name GameSettings
extends RefCounted
## Session settings. Inner voice defaults on and is not a story flag.

static var inner_voice: bool = true


static func thought_enabled() -> bool:
	return inner_voice
