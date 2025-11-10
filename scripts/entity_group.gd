class_name EntityGroup extends Node2D
# class that currently acts as the player controller, manages a group of individual entities

# signals
signal on_barrier_smashed
# variables
#  @export 
@export var starting_entities: int = 1
#  @onready
#   scenes
@onready var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")
@onready var entity_scene: PackedScene = preload("res://scenes/entity.tscn")
#  stats
#   shooting	
var bullet_speed: float = 1000.0
var rate_of_fire: float = 0.5
var shoot_timer: float = 0.0
#   movement
var speed: float = 500.0
#  node collections
var entities: Array[Entity] = []
#  data
var tween_entities_time: float = 0.25

#  temp - placeholder size data until I have real assets
var entity_size = Vector2(15, 30)
var group_size = Vector2(150, 150)

func _ready() -> void:
	# called when the node enters the scene tree for the first time
	_update_entities(starting_entities)

func _process(delta: float) -> void:
	# called every frame. delta is time since last frame
	_handle_movement(delta)
	_handle_shooting(delta)

func _handle_movement(delta: float) -> void:
	# move the group, on the x axis, toward the mouse's x position
	global_position.x = move_toward(global_position.x, get_global_mouse_position().x - (group_size.x / 2), speed * delta)

func _handle_shooting(delta: float) -> void:
	# handles shooting, spawning a bullet for each entity every time the shoot timer exceeds the rate of fire
	shoot_timer += delta
	if shoot_timer > rate_of_fire:
		for bullet in _shoot():
			get_parent().add_child(bullet)
		shoot_timer = 0

func _shoot() -> Array[Bullet]:
	# returns an array of initalized bullets
	var bullets: Array[Bullet] = []
	for entity in entities:
		bullets.append(_create_bullet(entity.global_position))
	return bullets

func _create_bullet(pos: Vector2) -> Bullet:
	# initalizes and returns a bullet, placed at the given position
	var bullet: Bullet = bullet_scene.instantiate()
	bullet.global_position = pos
	bullet.speed = bullet_speed
	bullet.add_to_group("bullets")
	bullet.add_to_group("player_bullets")
	return bullet

func _on_area_2d_area_entered(area: Area2D) -> void:
	# called when a foreign area collides with the group's area
	if area.get_parent() is Barrier:
		var barrier: Barrier = area.get_parent()
		var barrier_health: int = barrier.health
		barrier.queue_free()
		_update_entities(barrier_health)

func _update_entities(amount: int) -> void:
	# base method for adding or removing entities, given a positive or negative amount
	if amount == 0:
		return
	elif amount > 0:
		on_barrier_smashed.emit()
		_add_entities(amount)
	elif amount < 0:
		_remove_entities(-amount)

	_place_entities()

func _add_entities(amount: int) -> void:
	# adds the given amount of entities to the group
	for _i in range(amount):
		var entity: Entity = entity_scene.instantiate()
		entities.append(entity)
		call_deferred("add_child", entity)
	
func _remove_entities(amount: int) -> void:
	# removes the given amount of entities from the group
	for _i in range(amount):
		var entity: Entity = entities.pop_back()
		entity.queue_free()
		entities.erase(entity)

func _place_entities() -> void:
	# places the entities in a properly sized grid after the amount of entities has changed, using a tween for smooth movement

	# math magic
	var sqroot: float = sqrt(entities.size())
	var cols: int = ceil(sqroot)
	var rows: int = ceil((float)(entities.size()) / cols)

	var positions: Array[Vector2] = []

	for row in range(rows):
		for col in range(cols):
			var pos: Vector2 = Vector2(group_size.x / rows * row, group_size.y / cols * col)
			positions.append(pos)
	
	var tween: Tween = create_tween()

	for i in range(entities.size()):
		tween.tween_property(entities[i], "position", positions[i], (tween_entities_time / entities.size()))
