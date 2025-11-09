class_name Barrier extends Node2D
# class for barriers

@onready var health_label: Label = $Label

var health: int
var speed: float

func _ready() -> void:
	# called when the node enters the scene tree for the first time
	pass

func _process(delta: float) -> void:
	# called every frame. delta is time since last frame
	position.y += speed * delta

func _on_area_2d_area_entered(area: Area2D) -> void:
	# called when a foreign area collides with the barrier's area
	if area.get_parent() is Bullet:
		health += 1
		health_label.text = str(health)

		var bullet: Bullet = area.get_parent()
		bullet.queue_free()

