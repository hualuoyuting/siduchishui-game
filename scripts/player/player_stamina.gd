extends Node
## 玩家体力系统 - 奔跑消耗，静止恢复

@export var max_stamina: float = 100.0
@export var run_cost_per_second: float = 15.0
@export var recover_per_second: float = 20.0
@export var recover_delay: float = 1.0

var current_stamina: float
var last_run_time: float = -999.0

func _ready() -> void:
    current_stamina = max_stamina

func _process(delta: float) -> void:
    if Time.get_ticks_msec() / 1000.0 - last_run_time > recover_delay and current_stamina < max_stamina:
        current_stamina = min(max_stamina, current_stamina + recover_per_second * delta)

func consume(amount: float) -> bool:
    if current_stamina < amount:
        return false
    current_stamina -= amount
    last_run_time = Time.get_ticks_msec() / 1000.0
    return true

func get_stamina_percent() -> float:
    return current_stamina / max_stamina
