extends Node
## Local orb ownership; local saves are not protected against client tampering.
signal orb_added(orb_id: StringName)

const KNOWN_ORBS := [&"orb_flame", &"orb_tides", &"orb_nature", &"orb_storms", &"orb_eternity"]
var _owned: Dictionary = {}

func add_unique_orb(orb_id: StringName) -> bool:
	if orb_id not in KNOWN_ORBS or _owned.has(orb_id):
		return false
	_owned[orb_id] = true
	orb_added.emit(orb_id)
	return true

func has_orb(orb_id: StringName) -> bool:
	return _owned.has(orb_id)

func orb_count() -> int:
	return _owned.size()
