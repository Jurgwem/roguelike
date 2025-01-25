extends Node2D

@onready var player : Node2D = get_node("/root/game/player");
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	global_position = player.global_position
	if get_tree().get_node_count_in_group("enemy") != 0:
		visible = true;
		look_at(get_tree().get_nodes_in_group("enemy")[0].global_position);
	else:
		visible = false;
	pass
