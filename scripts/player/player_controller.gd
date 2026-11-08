extends CharacterBody3D
## 第一人称玩家控制器
## 操作: WASD移动, 鼠标视角, Shift奔跑, 空格跳跃

@export var walk_speed: float = 4.0
@export var run_speed: float = 7.0
@export var jump_height: float = 1.5
@export var mouse_sensitivity: float = 0.002
@export var gravity: float = 9.81

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var stamina: PlayerStamina = $PlayerStamina
@onready var health: PlayerHealth = $PlayerHealth

var x_rotation: float = 0.0
var is_running: bool = false

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    display_server_set_window_always_on_top(false)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        var mouse_delta: Vector2 = event.relative
        head.rotate_y(-mouse_delta.x * mouse_sensitivity)
        x_rotation = clamp(x_rotation - mouse_delta.y * mouse_sensitivity, -PI / 2.0, PI / 2.0)
        head.rotation.x = x_rotation

func _physics_process(delta: float) -> void:
    # 重力
    if not is_on_floor():
        velocity.y -= gravity * delta

    # 跳跃
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = sqrt(2.0 * gravity * jump_height)

    # 移动输入
    var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction: Vector3 = (head.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

    # 奔跑判断
    is_running = Input.is_action_pressed("run") and input_dir.y < 0
    
    if is_running and stamina != null:
        if not stamina.consume(delta * 15.0):
            is_running = false

    var speed: float = run_speed if is_running else walk_speed
    velocity.x = direction.x * speed
    velocity.z = direction.z * speed

    move_and_slide()

func display_server_set_window_always_on_top(_v: bool) -> void:
    pass
