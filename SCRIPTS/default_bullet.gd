extends Node2D

@onready var player : Node2D = get_node("/root/game/player");

var damage : int = 10;
var speed : int = 16;
var inaccuracy : float = 4; #overall degrees, aka spread
var hit : bool = false;
var collisions : int = 0;

var lifetime : int = 0;
var maxLifetime : int = 256;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.visible = false;
	if get_parent().name == "Start":
		speed = 4;
		inaccuracy = 1;
		scale = Vector2(0.7, 0.7);
		global_position = get_node("/root/Start/startPlayer").global_position;
		position += Vector2(0, -2.3);
	else:
		global_position = player.global_position;
	look_at(get_global_mouse_position())
	rotation -= deg_to_rad(((randf() * inaccuracy) - (inaccuracy / 2)) * player.spreadMod);
	position += Vector2(50, 0).rotated(rotation)
	$Sprite2D.visible = true;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if !hit:
		position += Vector2(speed * player.speedMod, 0).rotated(rotation)
		
		if get_tree().get_node_count_in_group("enemy") != 0:
			rotation = lerp_angle(rotation, (get_tree().get_nodes_in_group("enemy")[0].global_position - global_position).angle(), player.homingMod * _delta);
		
		lifetime += 1;
	if lifetime >= maxLifetime:
		queue_free();
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("actualWall"):
		$hit.emitting = true;
		$Area2D.queue_free();
		$trail.queue_free();
		$Sprite2D.visible = false;
		hit = true;
		collisions = player.pierce;
		await get_tree().create_timer(1).timeout;
		queue_free();
	if body.is_in_group("enemy") and !hit:
		body.health -= damage * player.damageMod;
		body.modulate = Color(1,0.25,0.25);
		$hit.emitting = true;
		if collisions >= player.pierce:
			hit = true;
			$Area2D.queue_free();
			$trail.queue_free();
			$Sprite2D.visible = false;
			await get_tree().create_timer(1).timeout;
			#print(body.name, " Hit!", " health: ", body.health);
			queue_free();
		collisions += 1;
			
	if !hit and body.name != "player" and !body.is_in_group("enemy"):
		$hit.emitting = true;
		if collisions >= player.pierce:
			hit = true;
			$Area2D.queue_free();
			$trail.queue_free();
			$Sprite2D.visible = false;
			await get_tree().create_timer(1).timeout;
			queue_free();
		collisions += 1;
	pass # Replace with function body.
