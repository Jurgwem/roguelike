extends Node2D

@onready var gm : Node2D = get_node("/root/game/gameManager");

var used : bool = false;
var winChance = 0.0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func play() -> void:
	winChance = randf();
	$AnimatedSprite2D.play("gamble");
	await get_tree().create_timer(4 + (randf() * 3)).timeout;
	if winChance < 0.5:
		$AnimatedSprite2D.animation = "win";
		$winPart.emitting = true;
		gm.coins *= 2;
	else:
		$AnimatedSprite2D.animation = "lose";
		$losePart.emitting = true;
		gm.coins *= 0.5;
	await get_tree().create_timer(2).timeout;
	$AnimatedSprite2D.animation = "idle";
	used = false;

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player" and !used:
		used = true;
		play();
	pass # Replace with function body.
