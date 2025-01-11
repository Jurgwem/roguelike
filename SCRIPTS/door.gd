extends StaticBody2D

var dScale : float = 1.0;
var dRot : String = "none";
var dRotNum : int = 0;
var random : float = randf();
var bend : bool = false;
var hasRun : bool = false;
var chance : float = 0.8;
var fallback : bool = false;
var keepRunning : bool = false;
var makeUseless : bool = false;

@onready var gm : Node2D= get_node("/root/game/gameManager");
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var translation : Array = ["up", "right", "down", "left"];
	var rot : int = gm.doorCounter;
	dRotNum = rot;
	var direction : String = translation[rot]
	dRot = direction;
	rotation = (deg_to_rad(rot * 90));
	await get_tree().create_timer(0.1).timeout
	if direction == "up":
		position.x = gm.roomPos.x;
		position.y = gm.roomPos.y - 328;
	if direction == "down":
		position.x = gm.roomPos.x;
		position.y = gm.roomPos.y + 328;
	if direction == "right":
		position.y = gm.roomPos.y;
		position.x = gm.roomPos.x + 608;
		scale.x = 1.1;
	if direction == "left":
		position.y = gm.roomPos.y;
		position.x = gm.roomPos.x - 608;
		scale.x = 1.1;
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if !makeUseless:
		if !hasRun and gm.enemyCount == 0:
			#await get_tree().create_timer(randf()).timeout
			var willDespawn :float = randf();	#chance calculation
			chance = willDespawn;
			print(dRot, " - ", chance)
			hasRun = true;
		
		#keepRunnig = make sure it finished despawning, fallback = continue if chance or raycasts start but not continue
		if keepRunning or ((hasRun and !$raycastStraight.is_colliding() and gm.enemyCount == 0) and (chance < 0.5 or gm.randomDoor >= 2 or fallback or $raycastToRoom.is_colliding())):
			keepRunning = true;
			$GPUParticles2D.emitting = true;
			if $raycastStraight.is_colliding() or $raycastToRoom.is_colliding() or chance > 0.5:
				fallback = true;
			else:
				gm.hasDoor = true;
			
			$CollisionShape2D.disabled = true;
			var step : int = 2;
			if random < 0.5:
				bend = true;

			if dRot == "up":
				position.y += step;
			if dRot == "down":
				position.y -= step;
			if dRot == "left":
				position.x += step;
			if dRot == "right":
				position.x -= step;
				
			if bend:
				rotation+=(0.05);
			else:
				rotation-=(0.05);
			scale -= Vector2(0.02, 0.02);
			
			if scale <= Vector2(0.5, 0.5):
				$GPUParticles2D.emitting = false;
			
			if scale <= Vector2(0, 0):
				get_parent().queue_free();
		elif hasRun:
			print("Door not open")
			gm.randomDoor += 1;
			makeUseless = true;
		
	
