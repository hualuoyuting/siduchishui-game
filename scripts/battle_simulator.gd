extends Node
## 自动战斗模拟器 - 根据战术和兵力计算结果

# 战术选项
enum Tactics {
    FRONTAL_ASSAULT,   # 正面强攻
    FLANKING,          # 侧翼迂回
    NIGHT_RAID,        # 夜间偷袭
    AMBUSH            # 伏击打援
}

static func simulate_battle(
    red_power: float,
    enemy_power: float,
    tactic: Tactics,
    terrain_bonus: float = 1.0
) -> Dictionary:
    
    # 战术加成
    var tactic_modifier = 1.0
    match tactic:
        Tactics.FRONTAL_ASSAULT:
            tactic_modifier = 1.0    # 无加成，伤亡大
        Tactics.FLANKING:
            tactic_modifier = 1.3    # 有地形加成
        Tactics.NIGHT_RAID:
            tactic_modifier = 1.6     # 偷袭加成大，但失败惩罚
        Tactics.AMBUSH:
            tactic_modifier = 1.4    # 伏击加成
    
    # 最终战力
    var final_red = red_power * tactic_modifier * terrain_bonus
    var final_enemy = enemy_power
    
    # 胜负判定
    var ratio = final_red / max(final_enemy, 1.0)
    var is_victory = ratio > 1.0
    
    # 伤亡计算
    var red_loss = int(red_power * (1.0 - min(ratio, 2.0) * 0.3))
    var enemy_loss = int(enemy_power * min(ratio, 3.0) * 0.4)
    
    # 夜间偷袭有失败概率
    if tactic == Tactics.NIGHT_RAID and randf() < 0.3:
        is_victory = false
        red_loss = int(red_loss * 1.5)
        enemy_loss = int(enemy_loss * 0.5)
    
    return {
        "victory": is_victory,
        "red_loss": red_loss,
        "enemy_loss": enemy_loss,
        "ratio": ratio,
        "tactic": tactic
    }
