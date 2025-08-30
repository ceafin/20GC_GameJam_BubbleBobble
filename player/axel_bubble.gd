extends CharacterBody2D
class_name AxelBubble

@export var speed      : float = 300.0
@export var spread_deg : float = 5.0   # small random aim jitter

# Just start out going right
var dir : int

func _ready() -> void:
	var angle : float = deg_to_rad( randf_range( -spread_deg, spread_deg ) )
	velocity = ( Vector2.RIGHT * dir * speed ).rotated( angle )

func _physics_process(delta: float) -> void:
	var the_collision : KinematicCollision2D = move_and_collide( velocity * delta )
	if !the_collision:
		return
	else:
		var the_collider : Object = the_collision.get_collider()
		# If we hit a monster: tell it to handle its own "turn into a bubble" logic
		if the_collider is BaseMonster:
			if the_collider.has_method("turn_into_bubble"):
				the_collider.turn_into_bubble()

		# It hit something, so queue_free anyways at this point
		queue_free()
		return

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
