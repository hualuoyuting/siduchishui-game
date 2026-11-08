extends Control
## 战前战术选择界面

signal battle_started(result: Dictionary)

var selected_target: Dictionary
var selected_tactic: int = 0
var main_force_pct: int = 60
var decoy_pct: int = 25
var reserve_pct: int = 15

func setup(target: Dictionary) -> void:
    selected_target = target
    $TargetLabel.text = "进攻目标: " + target.name
    $TacticLabel.text = "选择战术:"
    update_display()

func update_display() -> void:
    var tactics = ["正面强攻", "侧翼迂回", "夜间偷袭", "伏击打援"]
    $TacticOption.text = tactics[selected_tactic]
    $ForceLabel.text = "主攻: %d%%  佯动: %d%%  预备队: %d%%" % [main_force_pct, decoy_pct, reserve_pct]

func _on_next_tactic() -> void:
    selected_tactic = (selected_tactic + 1) % 4
    update_display()

func _on_start_battle() -> void:
    var gm = GameManager.instance
    var red_power = gm.get_army_power()
    
    # 敌人战力（根据目标据点估算）
    var enemy_power = 5000.0
    match selected_target.faction:
        "黔军": enemy_power = 4000.0
        "川军": enemy_power = 6000.0
        "中央军": enemy_power = 8000.0
        "滇军": enemy_power = 7000.0
    
    # 兵力分配加成
    var force_bonus = main_force_pct / 100.0
    red_power *= force_bonus
    
    var result = BattleSimulator.simulate_battle(
        red_power, enemy_power, selected_tactic, 1.0
    )
    
    gm.take_battle_result(result.red_loss, result.enemy_loss, result.victory)
    battle_started.emit(result)
