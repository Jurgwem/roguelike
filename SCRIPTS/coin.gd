extends Area2D

@onready var player : Node2D = get_node("/root/game/player");
@onready var gm : Node2D = get_node("/root/game/gameManager");

var collected : bool = false;
var scaleStep : float = 0.03;
var spawnLocation : Vector2 = Vector2(0, 0);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawnLocation = global_position;
	#if get_parent().get_parent().name != "spawnCoins":
	#	spawnLocation = get_parent().get_parent().position;
	#	print("coin spawn: ", spawnLocation)
	var rng : RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	var num : int = rng.randi_range(0, 5)
	$AnimatedSprite2D.set_frame_and_progress(num, 0)
	$AnimatedSprite2D.play("idle")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	#if get_parent().get_parent().name != "spawnCoins":
	#	global_position = spawnLocation;
	if collected:
		global_position = player.position + Vector2(0, -32);
		$"../parts".emitting = false;
		scale -= Vector2(scaleStep, scaleStep);
		if scale <= Vector2(0, 0):
			get_parent().queue_free()
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" and !collected:
		gm.coins += 1;
		print("collected coin.")
		collected = true;
	pass # Replace with function body
