extends AnimatedSprite2D
var speed = 300
var direction
var shoot_count = 0

func _process(delta):
	play("shot")
	move_local_x(direction * speed * delta)
	
func _on_timer_timeout():
	queue_free()

func _on_hitbox_area_entered(area):
		queue_free()

func _on_hitbox_body_entered(body):
	queue_free()
