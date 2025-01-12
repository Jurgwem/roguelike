extends Node2D

# Called when the node enters the scene tree for the first time.
var playedFadeIn : bool = false;
var playedFadeOut : bool = false;
var fadeSpeed : float = 0.7;
var chance : float = 0.5;

func _process(delta: float) -> void:
	if playedFadeIn:
		$"../overlay".modulate.a = lerp($"../overlay".modulate.a, $"../overlay".modulate.a - 1, fadeSpeed * delta)
		if $"../overlay".modulate.a <= 0:
			print("finished fade in!");
			playedFadeIn = false;
	if playedFadeOut:
		$"../overlay".modulate.a = lerp($"../overlay".modulate.a, $"../overlay".modulate.a + 1, fadeSpeed * delta)
		if $"../overlay".modulate.a >= 1:
			print("finished fade out!");
			playedFadeOut = false;
			await get_tree().create_timer(1).timeout;
			get_tree().change_scene_to_file("res://SCENES/game.tscn")
	pass
	
func _ready() -> void:
	$Button.modulate.a = 0;
	#await get_tree().create_timer(1).timeout;
	chance = randf();
	if chance <= 0.5:
		$"../bg/fall".emitting = false;
		$"../bg/fall".visible = false;
	chance = randf();
	if chance <= 0.5:
		$"../bg/GPUParticles2D".emitting = false;
		$"../bg/GPUParticles2D".visible = false;
	playedFadeIn = true;
	
func _on_button_button_down() -> void:
	playedFadeIn = false;
	playedFadeOut = true;
	pass # Replace with function body.
