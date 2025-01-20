extends Area2D

#@onready var static_body_2d: StaticBody2D = $"../StaticBody2D"
@onready var gm : Node2D= get_node("/root/game/gameManager");
@onready var room : Resource = load("res://INST/room.tscn");
@onready var door : Resource = load("res://INST/wall.tscn")
@onready var raycast : RayCast2D = $raycast;
@onready var hasDoor : RayCast2D = $hasDoor;

var timer : float = 0.0
var x : int = 0;
var y : int = 0;
var used : bool= false;
@export var direction : String;


func _ready() -> void:
	$newRoomIndicator.emitting = false;
	var translation : Array = ["up", "right", "down", "left"];
	var doorInstance : Node = door.instantiate();
	add_child(doorInstance);
	print("n = ", gm.doorCounter, "; trans: ", translation[gm.doorCounter])
	if gm.doorCounter <= 2:
		gm.doorCounter+=1;
	else:
		gm.doorCounter = 0;
		
func _process(delta):
	timer += delta
	if timer >= 5.0: 
		if !raycast.is_colliding() and !hasDoor.is_colliding():
			$newRoomIndicator.emitting = true;
		else:
			$newRoomIndicator.emitting = false;
		timer = 0.0 

func _on_body_entered(body: Node2D) -> void:
	if raycast.is_colliding():
		print("raycast hit!");
		used = true;
	if (direction == "right" and gm.lastRoom == "left") or (direction == "left" and gm.lastRoom == "right") or (direction == "up" and gm.lastRoom == "down") or (direction == "down" and gm.lastRoom == "up"):
		used = true;
		pass;
	if body.name == "player":
		print("current Room: ", gm.roomPos);
		gm.nextRoom = direction;
		print("next room: ", gm.nextRoom);
		if !used:
			gm.enemyCount += 1;
			gm.roomCount += 1;
			print("room count: ", gm.roomCount);
			#add_child(instance);
			print("Room Parent: ", get_parent().get_parent().name)
			var roomInstance : Node2D = room.instantiate();
			$"../..".add_child(roomInstance);
			used = true;
