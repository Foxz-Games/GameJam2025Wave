class_name Hurtbox extends Area2D

signal received_damage(damage: int, attacker: String)

@export var health: Health

func _ready() -> void:
	connect('area_entered', _on_area_entered)

func _on_area_entered(hitbox: Hitbox) -> void:
	if hitbox == null:
		return 
	 
	health.health -= hitbox.damage
	received_damage.emit(hitbox.damage, hitbox.get_parent().name)
