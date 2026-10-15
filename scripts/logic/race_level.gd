class_name RaceLevel
extends RefCounted
## A race as described in data/levels/*.json.

const DEFAULT_STAR_TOLERANCES: Array[float] = [0.10, 0.25]

var id: String = ""
var title_key: String = ""
var start_count: int = 1
var target: int = 1
## Forward speed of the herd, in metres per second.
var speed: float = 5.0
## Distance between two obstacles, in metres.
var spacing: float = 24.0
## Relative gap to the target allowed for 2 stars, then for 1 star.
var star_tolerances: Array[float] = DEFAULT_STAR_TOLERANCES.duplicate()
var obstacles: Array[Obstacle] = []
