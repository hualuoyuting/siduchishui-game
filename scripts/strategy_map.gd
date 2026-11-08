extends Node2D
## 战略大地图 - 加载真实据点数据，绘制地图

@export var map_data_path: String = "res://data/map_data.json"

var locations: Array = []
var selected_location: Dictionary = {}
var red_army_marker: Node2D

signal location_selected(location: Dictionary)

func _ready() -> void:
    load_map_data()
    draw_map()
    spawn_red_marker()

func load_map_data() -> void:
    var file = FileAccess.open(map_data_path, FileAccess.READ)
    if file:
        var json = JSON.parse_string(file.get_as_text())
        locations = json.get("locations", [])

func draw_map() -> void:
    # 绘制地形背景（像素风占位）
    var bg = ColorRect.new()
    bg.color = Color(0.35, 0.32, 0.22)  # 黄土色山地
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    
    # 绘制赤水河
    draw_river()
    
    # 绘制据点
    for loc in locations:
        draw_location(loc)

func draw_river() -> void:
    # 简化：从西向东画一条蓝色曲线
    var river = Line2D.new()
    river.add_point(Vector2(100, 250))
    river.add_point(Vector2(250, 240))
    river.add_point(Vector2(380, 250))
    river.add_point(Vector2(430, 280))
    river.add_point(Vector2(440, 320))
    river.add_point(Vector2(420, 360))
    river.width = 8
    river.default_color = Color(0.2, 0.4, 0.7)  # 蓝色
    add_child(river)

func draw_location(loc: Dictionary) -> void:
    var btn = Button.new()
    btn.text = loc.name
    btn.position = Vector2(loc.x - 40, loc.y - 15)
    btn.size = Vector2(80, 30)
    
    # 按阵营着色
    match loc.faction:
        "红军":
            btn.modulate = Color(0.9, 0.3, 0.3)
        "川军":
            btn.modulate = Color(0.3, 0.5, 0.9)
        "黔军":
            btn.modulate = Color(0.3, 0.8, 0.4)
        "中央军":
            btn.modulate = Color(0.9, 0.7, 0.2)
        "滇军":
            btn.modulate = Color(0.7, 0.5, 0.9)
        _:
            btn.modulate = Color(0.7, 0.7, 0.7)
    
    btn.pressed.connect(_on_location_pressed.bind(loc))
    add_child(btn)

func spawn_red_marker() -> void:
    red_army_marker = Node2D.new()
    var marker = Label.new()
    marker.text = "🔴"
    marker.add_theme_font_size_override("font_size", 24)
    red_army_marker.add_child(marker)
    add_child(red_army_marker)
    update_red_marker_position()

func update_red_marker_position() -> void:
    var loc = locations.filter(func(l): return l.name == GameManager.current_location)
    if loc.size() > 0:
        red_army_marker.position = Vector2(loc[0].x, loc[0].y - 30)

func _on_location_pressed(loc: Dictionary) -> void:
    selected_location = loc
    location_selected.emit(loc)
    print("选择目标: ", loc.name, " 类型: ", loc.type, " 守军: ", loc.faction)
