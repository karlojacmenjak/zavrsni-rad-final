extends KinematicBody2D

const smallCreatureCreator = preload("res://World/NPC/NPCs/SmallCreatureCreator.tscn")

onready var texture = $Texture
onready var animation_player = $AnimationPlayer

var speed : = 1.5
var path : = PoolVector2Array() setget set_path
var walk_state = true
var attack_friendly = false
var attack_body = null

func _ready():
	pass

func _process(_delta):
	if attack_friendly:
		path = PoolVector2Array([global_position,attack_body.global_position])
	animation_control(walk_state)
	move_along_path()

func createCharacter(type, category, state):
	var creator = smallCreatureCreator.instance()
	texture.texture = creator.getTextureForCreature(type,category,state)
	if texture.texture != null:
		creator.queue_free()

func move_along_path():
	var start_point := position
	for _i in range(path.size()):
		walk_state = false
		var distance_to_next : = start_point.distance_to(path[0])
		if not distance_to_next < 1.0:
			var normal_dir = (path[0] - start_point)
# warning-ignore:return_value_discarded
			move_and_collide(normal_dir.normalized()*speed)
			walk_state = true
			break
		start_point = path[0]
		path.remove(0)

func animation_control(state):
	if state:
		texture.scale = Vector2.ONE
		animation_player.play("NPCswalk")
		return
	texture.rotation_degrees = 0
	animation_player.play("NPCsidle")

func set_path(value : PoolVector2Array):
	path = value
	if value.size() == 0:
		return

func _on_Timer_timeout():
	queue_free()


func _on_Area2D_body_entered(body):
	attack_body = body
	attack_friendly = true


func _on_Area2D_body_exited(_body):
	attack_body = null
	attack_friendly = false
