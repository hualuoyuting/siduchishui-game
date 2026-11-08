extends Node
## 任务管理器 - 管理当前章节的所有目标

signal mission_complete
signal objective_complete

var chapter_title: String = "第一章：土城突围"
var chapter_date: String = "1935年1月29日"

var objectives: Array[Objective] = []
var current_objective_index: int = 0
var is_mission_complete: bool = false

static var instance: MissionManager

func _ready() -> void:
    instance = self
    for obj in objectives:
        obj.is_completed = false
    if objectives.size() > 0:
        objectives[0].is_active = true
        print("当前目标: ", objectives[0].description)

func _process(_delta: float) -> void:
    if is_mission_complete: return
    
    if current_objective_index < objectives.size():
        var current: Objective = objectives[current_objective_index]
        if current.is_active and current.check_complete():
            complete_objective(current)

func complete_objective(obj: Objective) -> void:
    obj.is_completed = true
    obj.is_active = false
    objective_complete.emit()
    print("目标完成: ", obj.description)
    
    current_objective_index += 1
    
    if current_objective_index < objectives.size():
        objectives[current_objective_index].is_active = true
        print("新目标: ", objectives[current_objective_index].description)
    else:
        is_mission_complete = true
        mission_complete.emit()
        print("章节任务全部完成！")

func get_current_objective() -> Objective:
    if current_objective_index < objectives.size():
        return objectives[current_objective_index]
    return null

func get_all_objectives() -> Array:
    return objectives
