class_name Bullet extends Node2D
# class for bullets

var speed: float 

func _physics_process(delta: float) -> void:
    # called every frame. delta is time since last frame
    position.y -= speed * delta