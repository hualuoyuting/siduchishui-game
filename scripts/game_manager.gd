extends Node
## 游戏总管理器 - 全局单例

signal game_paused
signal game_resumed

var current_chapter: int = 1
var is_game_paused: bool = false
var game_time: float = 0.0

static var instance: GameManager

func _ready() -> void:
    if instance != null and instance != self:
        queue_free()
        return
    instance = self
    process_mode = Node.PROCESS_MODE_ALWAYS
    
func _process(delta: float) -> void:
    if not is_game_paused:
        game_time += delta

func pause_game() -> void:
    is_game_paused = true
    get_tree().paused = true
    game_paused.emit()

func resume_game() -> void:
    is_game_paused = false
    get_tree().paused = false
    game_resumed.emit()

func load_chapter(chapter: int) -> void:
    current_chapter = chapter
    var scene_name = "res://scenes/chapter%d.tscn" % chapter
    get_tree().change_scene_to_file(scene_name)

func quit_game() -> void:
    get_tree().quit()
