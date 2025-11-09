class_name World extends Node2D
# The main game enviroment

# variables
#  constants
const BARRIER_AMOUNT_RANGE: Vector2i = Vector2i(1, 3)
#  @onready
#   nodes
@onready var player_group: EntityGroup = get_node("PlayerGroup")
@onready var barrier_spawn_timer: Timer = get_node("BarrierSpawnTimer")
#   scenes
@onready var barrier_scene: PackedScene = preload("res://scenes/barrier.tscn")
#  stats
#   barriers
var barrier_speed: float = 100.0
var barrier_health_range: Array[int] = [-25, -10]
#  data
#   barriers
var barrier_x_positions: Array[float] = [1080.0 / 3.0 - 100, 1080.0 / 3.0 * 2.0 - 200, 1080.0 - 300] # make this less messy
var barrier_spawn_time_options: Vector2i = Vector2i(5, 10)

func _ready() -> void:
	# called when the node enters the scene tree for the first time
	pass

func _process(_delta: float) -> void:
	# called every frame. delta is time since last frame
	pass

func _on_barrier_spawn_timer_timeout() -> void:
	# called when the barrier spawn timer times out. Spawns 1-3 barriers in a row. 
	var barrier_amount: int = randi_range(BARRIER_AMOUNT_RANGE.x, BARRIER_AMOUNT_RANGE.y)
	var position_choices: Array[float] = barrier_x_positions.duplicate()

	for _i in range(barrier_amount):
		var barrier: Barrier = barrier_scene.instantiate()
		var pos: float = position_choices.pick_random()

		position_choices.erase(pos)

		barrier.global_position = Vector2(pos, -100)
		barrier.health = randi_range(barrier_health_range[0], barrier_health_range[1])
		barrier.speed = barrier_speed
		add_child(barrier)

	barrier_spawn_timer.wait_time = randi_range(barrier_spawn_time_options.x, barrier_spawn_time_options.y)
	barrier_spawn_timer.start()


# each time the player succesfully absorbs a barrier, increase the barrier health range
