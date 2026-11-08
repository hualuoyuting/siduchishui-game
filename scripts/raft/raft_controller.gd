extends Node3D
## 竹筏渡河控制器 - 玩家按E登筏，竹筏自动顺流而下

@export var river_speed: float = 3.0
@export var crossing_distance: float = 200.0

@export var raft_seat: Node3D

var start_position: Vector3
var end_position: Vector3
var river_direction: Vector3
var is_crossing: bool = false
var is_boarded: bool = false
var player: Node3D

func _ready() -> void:
    start_position = global_position
    end_position = start_position + Vector3(0, 0, crossing_distance)
    river_direction = (end_position - start_position).normalized()

func _process(delta: float) -> void:
    if not is_boarded and player:
        var dist: float = player.global_position.distance_to(global_position)
        if dist < 3.0 and Input.is_action_just_pressed("interact"):
            board_raft()
    
    if is_crossing and is_boarded:
        global_position += river_direction * river_speed * delta
        
        if global_position.distance_to(end_position) < 5.0:
            arrive_bank()

func _on_body_entered(body: Node3D) -> void:
    if body.is_in_group("player"):
        player = body
        print("靠近竹筏，按E登筏")

func board_raft() -> void:
    is_boarded = true
    is_crossing = true
    
    if player and raft_seat:
        player.global_position = raft_seat.global_position
        player.set_process(false)
        player.set_physics_process(false)
        print("登上竹筏，开始渡河！")

func arrive_bank() -> void:
    is_crossing = false
    
    if player:
        player.set_process(true)
        player.set_physics_process(true)
        
        var mission = MissionManager.instance
        if mission:
            var current = mission.get_current_objective()
            if current and current.type == Objective.ObjectiveType.INTERACT:
                current.complete_interact()
        
        print("成功渡河！")
