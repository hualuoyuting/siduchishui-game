extends Node
## 玩家生命系统

signal damaged
signal healed
signal died

@export var max_health: float = 100.0
@export var heal_per_second: float = 0.0

var current_health: float
var is_dead: bool = false

func _ready() -> void:
    current_health = max_health

func _process(delta: float) -> void:
    if heal_per_second > 0 and not is_dead and current_health < max_health:
        current_health = min(max_health, current_health + heal_per_second * delta)
        healed.emit()

func take_damage(amount: float) -> void:
    if is_dead: return
    current_health -= amount
    damaged.emit()
    if current_health <= 0:
        current_health = 0
        die()

func heal(amount: float) -> void:
    if is_dead: return
    current_health = min(max_health, current_health + amount)
    healed.emit()

func die() -> void:
    is_dead = true
    died.emit()
    print("玩家阵亡")

func get_health_percent() -> float:
    return current_health / max_health
