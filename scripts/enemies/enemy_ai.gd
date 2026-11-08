extends CharacterBody3D
## 敌人AI - 巡逻/警戒/战斗状态机

enum EnemyState { PATROLLING, ALERTED, COMBAT, RETREAT }

@export var enemy_type: String = "川军士兵"
@export var patrol_speed: float = 2.0
@export var chase_speed: float = 4.0
@export var attack_range: float = 20.0
@export var attack_damage: float = 8.0
@export var attack_interval: float = 2.0
@export var detection_range: float = 15.0
@export var lose_target_range: float = 25.0

@export var patrol_points: Array[Node3D] = []
@export var patrol_loop: bool = true

@onready var health: EnemyHealth = $EnemyHealth
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

var player: Node3D
var current_state: EnemyState = EnemyState.PATROLLING
var patrol_index: int = 0
var last_attack_time: float = 0.0

func _ready() -> void:
    var player_node = get_tree().get_first_node_in_group("player")
    if player_node:
        player = player_node
    change_state(EnemyState.PATROLLING)

func _physics_process(delta: float) -> void:
    if health and health.is_dead:
        return

    match current_state:
        EnemyState.PATROLLING:
            patrol()
        EnemyState.ALERTED:
            alerted()
        EnemyState.COMBAT:
            combat()
        EnemyState.RETREAT:
            retreat()

func change_state(new_state: EnemyState) -> void:
    current_state = new_state
    match new_state:
        EnemyState.PATROLLING:
            navigation_agent.speed = patrol_speed
            if patrol_points.size() > 0:
                navigation_agent.target_position = patrol_points[patrol_index].global_position
        EnemyState.COMBAT:
            navigation_agent.speed = chase_speed

func patrol() -> void:
    if patrol_points.size() == 0: return

    if navigation_agent.is_navigation_finished():
        patrol_index += 1
        if patrol_index >= patrol_points.size():
            if patrol_loop:
                patrol_index = 0
            else:
                return
        navigation_agent.target_position = patrol_points[patrol_index].global_position

    if player:
        var dist: float = global_position.distance_to(player.global_position)
        if dist < detection_range:
            change_state(EnemyState.COMBAT)

    var next_pos: Vector3 = navigation_agent.get_next_path_position()
    velocity = (next_pos - global_position).normalized() * patrol_speed
    move_and_slide()

func alerted() -> void:
    if player:
        var dist: float = global_position.distance_to(player.global_position)
        if dist < detection_range:
            change_state(EnemyState.COMBAT)
        elif dist > lose_target_range:
            change_state(EnemyState.PATROLLING)

func combat() -> void:
    if player == null: return

    var dist: float = global_position.distance_to(player.global_position)

    if dist > lose_target_range:
        change_state(EnemyState.ALERTED)
        return

    if dist > attack_range:
        navigation_agent.target_position = player.global_position
        var next_pos: Vector3 = navigation_agent.get_next_path_position()
        velocity = (next_pos - global_position).normalized() * chase_speed
        move_and_slide()
    else:
        velocity = Vector3.ZERO
        look_at(player.global_position, Vector3.UP)
        
        if Time.get_ticks_msec() / 1000.0 - last_attack_time >= attack_interval:
            attack()
            last_attack_time = Time.get_ticks_msec() / 1000.0

func retreat() -> void:
    if patrol_points.size() > 0:
        navigation_agent.target_position = patrol_points[0].global_position

func attack() -> void:
    print(enemy_type, " 攻击玩家，造成 ", attack_damage, " 伤害")
    
    var player_health = player.get_node_or_null("PlayerHealth")
    if player_health and player_health.has_method("take_damage"):
        var hit_chance: float = clamp(1.0 - global_position.distance_to(player.global_position) / attack_range, 0.0, 1.0)
        if randf() < hit_chance * 0.6:
            player_health.take_damage(attack_damage)

func on_hit_alert(sound_position: Vector3) -> void:
    if current_state == EnemyState.PATROLLING:
        change_state(EnemyState.ALERTED)
        navigation_agent.target_position = sound_position
