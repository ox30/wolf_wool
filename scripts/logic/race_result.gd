class_name RaceResult
extends RefCounted
## Outcome of a whole race, compared with its target.

enum Failure { NONE, BRIDGE_COLLAPSED, HERD_LOST }

const MAX_STARS: int = 3

var arrived: int
var target: int
var failure: Failure
var stars: int


func _init(p_arrived: int, p_target: int, p_failure: Failure, tolerances: Array[float]) -> void:
	arrived = p_arrived
	target = p_target
	failure = p_failure
	stars = 0 if failure != Failure.NONE else compute_stars(arrived, target, tolerances)


func is_success() -> bool:
	return failure == Failure.NONE


## 3 stars for the exact target, then one star less per tolerance step
## (e.g. [0.10, 0.25]: within 10 % → 2 stars, within 25 % → 1 star).
static func compute_stars(p_arrived: int, p_target: int, tolerances: Array[float]) -> int:
	var gap: int = absi(p_arrived - p_target)
	if gap == 0:
		return MAX_STARS
	var stars_left: int = MAX_STARS - 1
	for tolerance: float in tolerances:
		if float(gap) <= tolerance * float(p_target):
			return stars_left
		stars_left -= 1
		if stars_left <= 0:
			break
	return 0
