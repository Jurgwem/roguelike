extends CharacterBody2D

@onready var gm : Node2D = get_node("/root/game/gameManager");
@onready var player : Node2D = get_node("/root/game/player");
@onready var spawnpoint : Node2D = get_node("/root/game/spawnCenter/spawnPoint");

const SPEED : float = 400.0;
const DAMPING : Vector2 = Vector2(0.95, 0.95);
const MAX_SPEED : float = 25;
const KNOCKBACK : float = 12;
var hasSpawned : bool = false;
var playedScale : bool = false;
var playedPart : bool = false;
var health : int = 25;
var color : float = 0;

func _ready() -> void:
	visible = false;
	gm.enemyCount += 1;
	await get_tree().create_timer(randf()).timeout;
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
	if hasSpawned and !playedScale:
		scale = lerp(scale, scale + Vector2(0.5, 0.5), 8 * delta);
		if scale >= Vector2(1, 1):
			playedScale = true;
	if hasSpawned and playedScale:
		velocity *= DAMPING;
		if (health >= 1):
			if (velocity.x < MAX_SPEED and velocity.y < MAX_SPEED) and (velocity.x > (MAX_SPEED * -1) and velocity.y > (MAX_SPEED * -1)):
				var distance_vector : Vector2 = player.global_position - global_position;
				velocity = distance_vector.normalized() * (SPEED * 100) * delta;
			$AnimatedSprite2D.global_rotation = 0;
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
