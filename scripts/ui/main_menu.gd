extends Control
## 主菜单 - 章节选择

func _on_chapter1_pressed() -> void:
    GameManager.instance.load_chapter(1)

func _on_chapter2_pressed() -> void:
    GameManager.instance.load_chapter(2)

func _on_chapter3_pressed() -> void:
    GameManager.instance.load_chapter(3)

func _on_chapter4_pressed() -> void:
    GameManager.instance.load_chapter(4)

func _on_quit_pressed() -> void:
    get_tree().quit()
