extends Resource
## 任务目标 - 可序列化的目标定义

enum ObjectiveType { REACH, KILL, DEFEND, INTERACT, SURVIVE }

@export var description: String = "到达目的地"
@export var type: ObjectiveType = ObjectiveType.REACH

@export var target_point: Node3D
@export var reach_distance: float = 5.0

@export var required_kills: int = 0
var current_kills: int = 0

@export var interact_tag: String = "Raft"

@export var survive_time: float = 0.0
var survive_timer: float = 0.0

var is_completed: bool = false
var is_active: bool = false

func check_complete() -> bool:
    if is_completed: return true
    
    match type:
        ObjectiveType.REACH:
            return check_reach()
        ObjectiveType.KILL:
            return current_kills >= required_kills
        ObjectiveType.SURVIVE, ObjectiveType.DEFEND:
            return check_survive()
        ObjectiveType.INTERACT:
            return is_completed
    return false

func check_reach() -> bool:
    if target_point == null: return false
    var player = get_tree().get_first_node_in_group("player")
    if player == null: return false
    var dist: float = player.global_position.distance_to(target_point.global_position)
    return dist <= reach_distance

func check_survive() -> bool:
    survive_timer += get_process_delta_time()
    return survive_timer >= survive_time

func add_kill() -> void:
    current_kills += 1

func complete_interact() -> void:
    is_completed = true

func get_progress() -> float:
    match type:
        ObjectiveType.KILL:
            return float(current_kills) / required_kills
        ObjectiveType.SURVIVE, ObjectiveType.DEFEND:
            return survive_timer / survive_time
        _:
            return 1.0 if is_completed else 0.0
