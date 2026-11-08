extends CanvasLayer
## HUD 控制器 - 显示血量、体力、弹药、任务目标

@onready var health_bar: ProgressBar = $UI/HealthBar
@onready var stamina_bar: ProgressBar = $UI/StaminaBar
@onready var ammo_label: Label = $UI/AmmoLabel
@onready var objective_label: Label = $UI/ObjectiveLabel
@onready var chapter_title_label: Label = $UI/ChapterTitle

var player: Node3D
var health_script: PlayerHealth
var stamina_script: PlayerStamina
var weapon_script: WeaponSystem

func _ready() -> void:
    player = get_tree().get_first_node_in_group("player")
    if player:
        health_script = player.get_node_or_null("PlayerHealth")
        stamina_script = player.get_node_or_null("PlayerStamina")
        weapon_script = player.get_node_or_null("Camera3D/WeaponSystem")
    
    var mission = MissionManager.instance
    if mission and chapter_title_label:
        chapter_title_label.text = mission.chapter_title + "  " + mission.chapter_date

func _process(_delta: float) -> void:
    if health_bar and health_script:
        health_bar.value = health_script.get_health_percent() * 100
    
    if stamina_bar and stamina_script:
        stamina_bar.value = stamina_script.get_stamina_percent() * 100
    
    if ammo_label and weapon_script:
        ammo_label.text = "弹药: %d / %d" % [weapon_script.get_current_ammo(), weapon_script.get_reserve_ammo()]
    
    if objective_label:
        var mission = MissionManager.instance
        if mission:
            var obj = mission.get_current_objective()
            if obj:
                objective_label.text = "🎯 " + obj.description
            else:
                objective_label.text = ""
