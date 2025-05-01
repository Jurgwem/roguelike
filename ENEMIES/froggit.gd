extends CharacterBody2D

@onready var gm : Node2D = get_node("/root/game/gameManager");
@onready var player : Node2D = get_node("/root/game/player");
@onready var spawnpoint : Node2D = get_node("/root/game/spawnCenter/spawnPoint");

var endName : String = "froggit";
const SPEED : float = 800.0;
const DAMPING : Vector2 = Vector2(0.95, 0.95);
const MAX_SPEED : float = 25;
const KNOCKBACK : float = 8;
const GRAVITY : int = 1600;
var hasSpawned : bool = false;
var playedScale : bool = false;
var playedPart : bool = false;
var health : int = 6;
var color : float = 0;
var jumpTimer : float = 0.0;
var pausedTimer : float = 0.0;
var paused : bool = false;

func _ready() -> void:
	health *= gm.difficulty;
	visible = false;
	gm.enemyCount += 1;
	await get_tree().create_timer(randf() / 2).timeout;
	visible = true;
	global_position = spawnpoint.global_position;
	global_position += Vector2(randf(), randf());
	scale = Vector2(0.1, 0.1);
	hasSpawned = true;
	velocity = Vector2(0, 0);
	pass

func _physics_process(delta: float) -> void:
	color = lerp(modulate.g, 1.0, 3.2 * delta);
	modulate = Color(1,color,color);
	#modulate = Color(1,0,0);
	if hasSpawned and !playedScale:
		scale = lerp(scale, scale + Vector2(0.5, 0.5), 8 * delta);
		if scale >= Vector2(1 * gm.enemyScale, 1 * gm.enemyScale):
			playedScale = true;
			
	pausedTimer += delta;
	if pausedTimer > 1:
		paused = true;
		
	if hasSpawned and playedScale and paused:
		velocity.x *= DAMPING.x;
		if not is_on_floor():
			$AnimatedSprite2D.frame = 1;
			velocity.y += GRAVITY * delta
		else:
			$AnimatedSprite2D.rotation = 0;
			$AnimatedSprite2D.frame = 0;
		if (health >= 1):
			#if is_on_floor() and (velocity.x < MAX_SPEED and velocity.y < MAX_SPEED) and (velocity.x > (MAX_SPEED * -1) and velocity.y > (MAX_SPEED * -1)):
			if is_on_floor() and velocity.y <= 4:
				if jumpTimer > 1:
					jumpTimer = randf();
					var distance_vector : Vector2 = player.global_position - global_position;
					velocity = distance_vector.normalized() * (SPEED * 100) * delta;
					$AnimatedSprite2D.rotation = (global_position - player.global_position).angle() - deg_to_rad(90);
				else:
					jumpTimer += delta;
			#$AnimatedSprite2D.global_rotation = 0;
		else:
			$CollisionShape2D.scale = Vector2(0, 0);
			rotation = lerp_angle(rotation, deg_to_rad(rotation_degrees + 10), 16 * delta);
			if !playedPart:
					$diePart.emitting = true;
					playedPart = true;
			if rotation_degrees >= 45:
				scale = lerp(scale, scale - Vector2(0.5, 0.5), 10 * delta);
				if scale <= Vector2(0, 0):
					gm.enemyCount -= 1;
					queue_free();

		move_and_slide()


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if body.health >= 1:
			var distance_vector_player : Vector2 = global_position - body.global_position;
			velocity = distance_vector_player * KNOCKBACK;
			body.velocity = distance_vector_player * -1 * (KNOCKBACK/2);
			#velocity = distance_vector.normalized() * (knockback * 100);
			#move_and_slide()
	pass # Replace with function body.
