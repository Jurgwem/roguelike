extends Area2D

@onready var gm = get_node("/root/game/gameManager");
var collected = false;
var scaleStep = 0.03;
var spawnLocation = Vector2(0, 0);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent().get_parent().name != "spawnCoins":
		spawnLocation = get_parent().get_parent().position;
		print("coin spawn: ", spawnLocation)
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var num = rng.randi_range(0, 5)
	$AnimatedSprite2D.set_frame_and_progress(num, 0)
	$AnimatedSprite2D.play("idle")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if get_parent().get_parent().name != "spawnCoins":
		global_position = spawnLocation;
	if collected:
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
