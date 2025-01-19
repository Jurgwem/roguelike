extends Node2D

@onready var player : Node2D = get_node("/root/game/player");

var damage : int = 10;
var speed : int = 16;
var inaccuracy : float = 4; #overall degrees, aka spread
var hit : bool = false;

var lifetime : int = 0;
var maxLifetime : int = 250;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent().name == "Start":
		speed = 4;
		inaccuracy = 1;
		scale = Vector2(0.7, 0.7);
		position = get_node("/root/Start/startPlayer").position;
		position += Vector2(0, -2.3);
	else:
		position = player.position;
	look_at(get_global_mouse_position())
	rotation -= deg_to_rad(((randf() * inaccuracy) - (inaccuracy / 2)) * player.spreadMod);
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if !hit:
		position += Vector2(speed * player.speedMod, 0).rotated(rotation)
		lifetime += 1;
	if lifetime >= maxLifetime:
		queue_free();
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and !hit:
		body.health -= damage * player.damageMod;
		hit = true;
		$hit.emitting = true;
		$Area2D.queue_free();
		$trail.queue_free();
		$Sprite2D.visible = false;
		await get_tree().create_timer(1).timeout;
		#print(body.name, " Hit!", " health: ", body.health);
		queue_free();
	if !hit and body.name != "player":
		hit = true;
		$hit.emitting = true;
		$Area2D.queue_free();
		$trail.queue_free();
		$Sprite2D.visible = false;
		await get_tree().create_timer(1).timeout;
		queue_free();
	pass # Replace with function body.
