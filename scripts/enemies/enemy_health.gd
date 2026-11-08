extends Node
## 敌人生命系统

signal damaged
signal died

@export var max_health: float = 60.0

var current_health: float
var is_dead: bool = false

func _ready() -> void:
    current_health = max_health

func take_damage(amount: float) -> void:
    if is_dead: return
    current_health -= amount
    damaged.emit()
    
    var parent = get_parent()
    var ai = parent.get_node_or_null("NavigationAgent3D")
    if ai and parent.has_method("on_hit_alert"):
        parent.on_hit_alert(parent.global_position)
    
    if current_health <= 0:
        die()

func die() -> void:
    is_dead = true
    died.emit()
    print(get_parent().name, " 被击毙")
    get_parent().set_process(false)
    get_parent().set_physics_process(false)
    
    var col = get_parent().get_node_or_null("CollisionShape3D")
    if col:
        col.set_deferred("disabled", true)
    
    get_parent().queue_free()
