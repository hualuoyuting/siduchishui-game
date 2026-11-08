extends Node
## 全局游戏状态管理

signal turn_changed(turn: int)
signal chapter_changed(chapter: int)
signal army_updated

var chapter: int = 1
var turn: int = 0

# 红军状态
var red_army: int = 37000       # 兵力
var supply: int = 100            # 补给
var morale: int = 80             # 士气 0-100

# 当前位置
var current_location: String = "土城"

# 历史事件记录
var battle_log: Array = []

static var instance: GameManager

func _ready() -> void:
    instance = self
    process_mode = Node.PROCESS_MODE_ALWAYS

func new_turn() -> void:
    turn += 1
    turn_changed.emit(turn)

func take_battle_result(red_loss: int, enemy_loss: int, is_victory: bool) -> void:
    red_army -= red_loss
    supply += int(enemy_loss * 0.5) if is_victory else -int(enemy_loss * 0.3)
    
    if not is_victory:
        morale = max(0, morale - 10)
    else:
        morale = min(100, morale + 5)
    
    battle_log.append({
        "turn": turn,
        "red_loss": red_loss,
        "enemy_loss": enemy_loss,
        "victory": is_victory
    })
    
    army_updated.emit()

func get_army_power() -> float:
    return red_army * (morale / 100.0) * (supply / 100.0 + 0.5)

func load_chapter(ch: int) -> void:
    chapter = ch
    chapter_changed.emit(ch)
