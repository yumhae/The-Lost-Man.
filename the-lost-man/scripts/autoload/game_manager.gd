


extends Node


const LEVEL_COUNT  := 5
const LEVEL_PATHS  := [
	"res://scenes/levels/level_1.tscn",
	"res://scenes/levels/level_2.tscn",
	"res://scenes/levels/level_3.tscn",
	"res://scenes/levels/level_4.tscn",
	"res://scenes/levels/level_5.tscn",
]
const LEVEL_NAMES  := ["FOREST", "ANCIENT RUINS", "DARK CAVE", "HAUNTED MANSION", "THE VOID"]

const LEVEL_TIMES  := [90.0, 65.0, 50.0, 35.0, 35.0]

const MAZE_SIZES   := [Vector2i(21,15), Vector2i(25,19), Vector2i(29,21), Vector2i(33,25), Vector2i(39,29)]
const MAZE_SEEDS   := [42, 137, 512, 999, 7777]

const ENEMY_COUNTS := [2, 3, 4, 5, 7]
const ENEMY_SPEEDS := [62.0, 78.0, 92.0, 108.0, 128.0]
const ENEMY_RANGES := [160.0, 200.0, 250.0, 300.0, 380.0]


const LEVEL_THEMES := [

	{
		"wall_color":  Color(0.13, 0.28, 0.07),
		"wall_top":    Color(0.20, 0.42, 0.11),
		"floor_color": Color(0.42, 0.65, 0.22),
		"floor_alt":   Color(0.38, 0.60, 0.20),
		"bg_color":    Color(0.22, 0.48, 0.09),
		"accent":      Color(0.85, 0.98, 0.15),
		"text_color":  Color(0.92, 1.00, 0.72),
		"timer_color": Color(0.45, 1.00, 0.28),
		"glow":        Color(0.40, 1.00, 0.20, 0.18),
	},

	{
		"wall_color":  Color(0.38, 0.30, 0.18),
		"wall_top":    Color(0.54, 0.43, 0.27),
		"floor_color": Color(0.66, 0.55, 0.38),
		"floor_alt":   Color(0.60, 0.50, 0.34),
		"bg_color":    Color(0.30, 0.23, 0.12),
		"accent":      Color(0.98, 0.82, 0.35),
		"text_color":  Color(1.00, 0.95, 0.76),
		"timer_color": Color(1.00, 0.88, 0.28),
		"glow":        Color(1.00, 0.80, 0.10, 0.18),
	},

	{
		"wall_color":  Color(0.07, 0.07, 0.16),
		"wall_top":    Color(0.13, 0.13, 0.26),
		"floor_color": Color(0.17, 0.17, 0.30),
		"floor_alt":   Color(0.14, 0.14, 0.26),
		"bg_color":    Color(0.02, 0.02, 0.09),
		"accent":      Color(0.55, 0.20, 0.95),
		"text_color":  Color(0.80, 0.68, 1.00),
		"timer_color": Color(0.60, 0.32, 1.00),
		"glow":        Color(0.50, 0.10, 0.90, 0.20),
	},

	{
		"wall_color":  Color(0.18, 0.06, 0.06),
		"wall_top":    Color(0.30, 0.11, 0.11),
		"floor_color": Color(0.36, 0.21, 0.21),
		"floor_alt":   Color(0.30, 0.17, 0.17),
		"bg_color":    Color(0.07, 0.02, 0.02),
		"accent":      Color(0.95, 0.18, 0.18),
		"text_color":  Color(1.00, 0.78, 0.78),
		"timer_color": Color(1.00, 0.28, 0.28),
		"glow":        Color(1.00, 0.10, 0.10, 0.20),
	},

	{
		"wall_color":  Color(0.02, 0.02, 0.10),
		"wall_top":    Color(0.04, 0.08, 0.22),
		"floor_color": Color(0.12, 0.18, 0.38),
		"floor_alt":   Color(0.09, 0.14, 0.32),
		"bg_color":    Color(0.00, 0.00, 0.05),
		"accent":      Color(0.00, 0.88, 1.00),
		"text_color":  Color(0.48, 0.92, 1.00),
		"timer_color": Color(0.00, 0.92, 1.00),
		"glow":        Color(0.00, 0.80, 1.00, 0.25),
	},
]


var current_level: int = 0


func _ready() -> void:
	_setup_input()

func _setup_input() -> void:
	_bind("move_up",    [KEY_W, KEY_UP])
	_bind("move_down",  [KEY_S, KEY_DOWN])
	_bind("move_left",  [KEY_A, KEY_LEFT])
	_bind("move_right", [KEY_D, KEY_RIGHT])
	_bind("pause_game", [KEY_ESCAPE, KEY_P])

func _bind(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	else:
		InputMap.action_erase_events(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)


func start_game(from_level: int = 0) -> void:
	current_level = from_level
	_load_level()

func _load_level() -> void:
	get_tree().change_scene_to_file(LEVEL_PATHS[current_level])

func complete_level() -> void:
	current_level += 1
	if current_level >= LEVEL_COUNT:
		get_tree().change_scene_to_file("res://scenes/win_screen.tscn")
	else:
		_load_level()

func game_over() -> void:
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func go_to_menu() -> void:
	get_tree().paused = false
	current_level = 0
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func get_theme()        -> Dictionary: return LEVEL_THEMES[current_level]
func get_time()         -> float:      return LEVEL_TIMES[current_level]
func get_level_name()   -> String:     return LEVEL_NAMES[current_level]
func get_maze_size()    -> Vector2i:   return MAZE_SIZES[current_level]
func get_maze_seed()    -> int:        return MAZE_SEEDS[current_level]
func get_enemy_count()  -> int:        return ENEMY_COUNTS[current_level]
func get_enemy_speed()  -> float:      return ENEMY_SPEEDS[current_level]
func get_enemy_range()  -> float:      return ENEMY_RANGES[current_level]
