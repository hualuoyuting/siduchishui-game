extends Node3D
## 武器系统 - 射击、换弹、弹药管理

@export var weapon_name: String = "汉阳造步枪"
@export var damage: float = 25.0
@export var fire_rate: float = 1.5
@export var magazine_size: int = 5
@export var reload_time: float = 2.5
@export var range: float = 100.0

@export var current_ammo: int = 5
@export var reserve_ammo: int = 30

@onready var fire_point: Node3D = $FirePoint
@onready var camera: Camera3D = get_viewport().get_camera_3d()

var next_fire_time: float = 0.0
var is_reloading: bool = false

func _ready() -> void:
    current_ammo = magazine_size

func _process(_delta: float) -> void:
    if is_reloading: return

    if Input.is_action_pressed("fire") and Time.get_ticks_msec() / 1000.0 >= next_fire_time:
        fire()

    if Input.is_action_just_pressed("reload") and current_ammo < magazine_size and reserve_ammo > 0:
        reload()

func fire() -> void:
    next_fire_time = Time.get_ticks_msec() / 1000.0 + 1.0 / fire_rate

    if current_ammo <= 0:
        print("弹药耗尽，按R换弹")
        return

    current_ammo -= 1

    # 射线检测
    var from: Vector3 = camera.global_position
    var dir: Vector3 = -camera.global_transform.basis.z
    var to: Vector3 = from + dir * range

    var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
    var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
    query.collide_with_areas = true
    var hit: Dictionary = space_state.intersect_ray(query)

    if not hit.is_empty():
        var collider: CollisionObject3D = hit.collider
        print("命中: ", collider.name)
        
        var enemy_health = collider.get_node_or_null("EnemyHealth")
        if enemy_health == null:
            enemy_health = collider.get_node_or_null("../EnemyHealth")
        if enemy_health != null and enemy_health.has_method("take_damage"):
            enemy_health.take_damage(damage)

func reload() -> void:
    is_reloading = true
    print("开始换弹...")
    
    await get_tree().create_timer(reload_time).timeout
    
    var need: int = magazine_size - current_ammo
    var take: int = min(need, reserve_ammo)
    current_ammo += take
    reserve_ammo -= take
    
    is_reloading = false
    print("换弹完成")

func get_current_ammo() -> int:
    return current_ammo

func get_reserve_ammo() -> int:
    return reserve_ammo

func is_reloading_weapon() -> bool:
    return is_reloading
