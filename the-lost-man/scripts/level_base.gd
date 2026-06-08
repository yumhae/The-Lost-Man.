


extends Node2D


const TILE_SIZE := 32


var _level_idx: int
var _theme:      Dictionary
var _time_total: float
var _time_left:  float
var _running    := false
var _ended      := false
var _paused     := false


var _maze:        Array = []
var _player:      CharacterBody2D
var _npc:         Node2D
var _camera:      Camera2D
var _timer_label: Label
var _bar_style:   StyleBoxFlat
var _timer_bar:   ProgressBar
var _fade_rect:   ColorRect
var _pause_panel: Control




func _ready() -> void:

	process_mode = PROCESS_MODE_ALWAYS

	_level_idx  = GameManager.current_level
	_theme      = GameManager.get_theme()
	_time_total = GameManager.get_time()
	_time_left  = _time_total

	RenderingServer.set_default_clear_color(_theme["bg_color"])

	_gen_maze()
	_build_visuals()
	_build_walls()
	_build_player()
	_build_npc()
	_build_enemies()
	_build_camera()
	_build_hud()
	_build_pause_layer()
	_build_fade_layer()
	_fade_in()
	_running = true
	AudioManager.play_level_music(_level_idx)


func _gen_maze() -> void:


	var openings := [0.18, 0.15, 0.12, 0.09, 0.06]
	MazeGenerator.extra_openings_pct = openings[_level_idx]
	_maze = MazeGenerator.generate(
		GameManager.get_maze_size().x,
		GameManager.get_maze_size().y,
		GameManager.get_maze_seed()
	)


func _build_visuals() -> void:
	var drawer_script: GDScript = load("res://scripts/maze_drawer.gd")
	var drawer := Node2D.new()
	drawer.set_script(drawer_script)
	drawer.name        = "MazeDrawer"
	drawer.maze        = _maze
	drawer.tile_size   = TILE_SIZE
	drawer.wall_color  = _theme["wall_color"]
	drawer.wall_top    = _theme["wall_top"]
	drawer.floor_color = _theme["floor_color"]
	drawer.floor_alt   = _theme["floor_alt"]
	drawer.level_idx   = _level_idx
	drawer.do_animate  = true
	drawer.z_index     = 0
	add_child(drawer)


func _build_walls() -> void:
	var body := StaticBody2D.new()
	body.name = "Walls"
	add_child(body)
	var ts  := TILE_SIZE
	var ts2 := ts / 2.0
	for y in _maze.size():
		for x in _maze[y].size():
			if _maze[y][x] == MazeGenerator.WALL:
				var col   := CollisionShape2D.new()
				var shape := RectangleShape2D.new()
				shape.size    = Vector2(ts, ts)
				col.position  = Vector2(x * ts + ts2, y * ts + ts2)
				col.shape     = shape
				body.add_child(col)


func _build_player() -> void:
	var cell := MazeGenerator.get_start(_maze)
	var ts   := TILE_SIZE
	var ps: GDScript = load("res://scripts/player.gd")
	_player = CharacterBody2D.new()
	_player.set_script(ps)
	_player.name         = "Player"
	_player.position     = Vector2(cell.x * ts + ts / 2.0, cell.y * ts + ts / 2.0)
	_player.accent_color = _theme["accent"]
	add_child(_player)


func _build_npc() -> void:
	var cell := MazeGenerator.get_exit(_maze)
	var ts   := TILE_SIZE
	var ns: GDScript = load("res://scripts/npc_flag_holder.gd")
	_npc = Node2D.new()
	_npc.set_script(ns)
	_npc.name         = "NPCFlagHolder"
	_npc.accent_color = _theme["accent"]
	_npc.position     = Vector2(cell.x * ts + ts / 2.0, cell.y * ts + ts / 2.0)
	_npc.connect("player_arrived", _on_level_complete)
	add_child(_npc)


func _build_enemies() -> void:
	var count: int   = GameManager.get_enemy_count()
	var spd:   float = GameManager.get_enemy_speed()
	var rng_d: float = GameManager.get_enemy_range()
	var enemy_script: GDScript = load("res://scripts/enemy.gd")

	var spawn_pts := _get_enemy_spawns(count)
	for pt: Vector2i in spawn_pts:
		var ts: int = TILE_SIZE
		var e := Node2D.new()
		e.set_script(enemy_script)
		e.set("speed",        spd)
		e.set("detect_range", rng_d)
		e.set("maze_ref",     _maze)
		e.set("player_ref",   _player)
		e.position = Vector2(
			float(pt.x) * ts + ts * 0.5,
			float(pt.y) * ts + ts * 0.5
		)
		e.connect("caught_player", _on_enemy_caught)
		add_child(e)


func _get_enemy_spawns(count: int) -> Array[Vector2i]:
	var start  := MazeGenerator.get_start(_maze)
	var pool:    Array[Vector2i] = []

	for yi in _maze.size():
		var row: Array = _maze[yi]
		for xi in row.size():
			if int(row[xi]) != MazeGenerator.WALL:
				var pos := Vector2i(xi, yi)

				if pos.distance_to(start) > 5.0:
					pool.append(pos)

	pool.shuffle()
	var result: Array[Vector2i] = []
	for i in mini(count, pool.size()):
		result.append(pool[i])
	return result


func _build_camera() -> void:
	_camera = Camera2D.new()
	_camera.name                     = "Cam"
	_camera.position_smoothing_enabled = true
	_camera.position_smoothing_speed   = 6.0
	_camera.limit_left                 = 0
	_camera.limit_top                  = -56
	_camera.limit_right                = _maze[0].size() * TILE_SIZE
	_camera.limit_bottom               = _maze.size()    * TILE_SIZE
	_player.add_child(_camera)
	_camera.make_current()


func _build_hud() -> void:
	var hud := CanvasLayer.new()
	hud.name  = "HUD"
	hud.layer = 10
	add_child(hud)


	var top_bar := ColorRect.new()
	top_bar.color    = Color(0, 0, 0, 0.55)
	top_bar.position = Vector2.ZERO
	top_bar.size     = Vector2(960, 54)
	hud.add_child(top_bar)


	var line := ColorRect.new()
	line.color    = _theme["accent"]
	line.position = Vector2(0, 53)
	line.size     = Vector2(960, 1)
	hud.add_child(line)


	var stage_lbl := Label.new()
	stage_lbl.text = "STAGE %d / %d" % [_level_idx + 1, GameManager.LEVEL_COUNT]
	stage_lbl.position = Vector2(14, 5)
	stage_lbl.add_theme_font_size_override("font_size", 19)
	stage_lbl.add_theme_color_override("font_color", _theme["text_color"])
	hud.add_child(stage_lbl)


	var name_lbl := Label.new()
	name_lbl.text = "▶  " + GameManager.get_level_name()
	name_lbl.position = Vector2(14, 28)
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", _theme["accent"])
	hud.add_child(name_lbl)


	_timer_label = Label.new()
	_timer_label.text = _fmt_time(_time_left)
	_timer_label.position = Vector2(750, 8)
	_timer_label.size     = Vector2(196, 40)
	_timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_timer_label.add_theme_font_size_override("font_size", 28)
	_timer_label.add_theme_color_override("font_color", _theme["timer_color"])
	hud.add_child(_timer_label)


	_bar_style = StyleBoxFlat.new()
	_bar_style.bg_color = _theme["timer_color"]
	_bar_style.content_margin_top = 0
	_bar_style.content_margin_bottom = 0
	_bar_style.content_margin_left = 0
	_bar_style.content_margin_right = 0
	
	var bar_bg := StyleBoxFlat.new()
	bar_bg.bg_color = Color(0, 0, 0, 0.45)
	bar_bg.content_margin_top = 0
	bar_bg.content_margin_bottom = 0
	bar_bg.content_margin_left = 0
	bar_bg.content_margin_right = 0

	_timer_bar = ProgressBar.new()
	_timer_bar.position       = Vector2(0, 54)
	_timer_bar.size           = Vector2(960, 4)
	_timer_bar.custom_minimum_size = Vector2(960, 4)
	_timer_bar.max_value      = _time_total
	_timer_bar.value          = _time_left
	_timer_bar.show_percentage = false
	_timer_bar.add_theme_stylebox_override("background", bar_bg)
	_timer_bar.add_theme_stylebox_override("fill", _bar_style)
	hud.add_child(_timer_bar)


	var enemy_count: int = GameManager.get_enemy_count()
	var skull_str: String = ""
	for _i in enemy_count:
		skull_str += "☠ "
	var enemy_lbl := Label.new()
	enemy_lbl.text = skull_str.strip_edges() + "  HUNTERS"
	enemy_lbl.position = Vector2(0, 16)
	enemy_lbl.size     = Vector2(960, 28)
	enemy_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	enemy_lbl.add_theme_font_size_override("font_size", 15)
	enemy_lbl.add_theme_color_override("font_color", Color(1.0, 0.28, 0.28, 0.90))
	hud.add_child(enemy_lbl)


	var hint := Label.new()
	hint.text = "WASD / Arrows: Move          ESC: Pause"
	hint.position = Vector2(0, 525)
	hint.size     = Vector2(960, 18)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.32))
	hud.add_child(hint)


func _build_pause_layer() -> void:
	var layer := CanvasLayer.new()
	layer.name         = "PauseLayer"
	layer.layer        = 20
	layer.process_mode = PROCESS_MODE_ALWAYS
	add_child(layer)

	_pause_panel = Control.new()
	_pause_panel.name     = "PausePanel"
	_pause_panel.visible  = false
	_pause_panel.position = Vector2.ZERO
	_pause_panel.size     = Vector2(960, 540)
	layer.add_child(_pause_panel)


	var overlay := ColorRect.new()
	overlay.color    = Color(0, 0, 0, 0.72)
	overlay.position = Vector2.ZERO
	overlay.size     = Vector2(960, 540)
	_pause_panel.add_child(overlay)


	var box := ColorRect.new()
	box.color    = Color(0.04, 0.04, 0.10, 0.96)
	box.position = Vector2(330, 130)
	box.size     = Vector2(300, 240)
	_pause_panel.add_child(box)


	var border := ColorRect.new()
	border.color    = _theme["accent"]
	border.position = Vector2(330, 130)
	border.size     = Vector2(300, 3)
	_pause_panel.add_child(border)


	var ptitle := Label.new()
	ptitle.text     = "PAUSED"
	ptitle.position = Vector2(330, 145)
	ptitle.size     = Vector2(300, 55)
	ptitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ptitle.add_theme_font_size_override("font_size", 38)
	ptitle.add_theme_color_override("font_color", _theme["accent"])
	_pause_panel.add_child(ptitle)

	_pause_btn("RESUME",       Vector2(380, 215), _on_resume)
	_pause_btn("RESTART STAGE",Vector2(380, 268), _on_restart)
	_pause_btn("MAIN MENU",    Vector2(380, 321), GameManager.go_to_menu)

func _pause_btn(text: String, pos: Vector2, cb: Callable) -> Button:
	var btn := Button.new()
	btn.text     = text
	btn.position = pos
	btn.size     = Vector2(200, 42)
	btn.add_theme_font_size_override("font_size", 17)
	btn.add_theme_color_override("font_color",       Color.WHITE)
	btn.add_theme_color_override("font_hover_color", _theme["accent"])
	btn.add_theme_color_override("font_pressed_color",_theme["accent"].darkened(0.2))

	var norm := _btn_style(Color(0.10, 0.10, 0.22, 0.88), _theme["accent"].darkened(0.5))
	var hov  := _btn_style(Color(0.18, 0.14, 0.34, 0.95), _theme["accent"])
	btn.add_theme_stylebox_override("normal",  norm)
	btn.add_theme_stylebox_override("hover",   hov)
	btn.add_theme_stylebox_override("pressed", _btn_style(Color(0.05,0.05,0.12,0.95), _theme["accent"]))

	btn.pressed.connect(cb)
	_pause_panel.add_child(btn)
	return btn

func _btn_style(bg: Color, border: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(2)
	s.set_corner_radius_all(6)
	return s


func _build_fade_layer() -> void:
	var layer := CanvasLayer.new()
	layer.name  = "FadeLayer"
	layer.layer = 30
	add_child(layer)

	_fade_rect = ColorRect.new()
	_fade_rect.color        = Color.BLACK
	_fade_rect.position     = Vector2.ZERO
	_fade_rect.size         = Vector2(960, 540)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_fade_rect)

func _fade_in() -> void:
	_fade_rect.color = Color.BLACK
	var tw := create_tween()
	tw.tween_property(_fade_rect, "color", Color(0, 0, 0, 0), 0.55)

func _fade_out_then(cb: Callable) -> void:
	var tw := create_tween()
	tw.tween_property(_fade_rect, "color", Color.BLACK, 0.40)
	tw.tween_callback(cb)




func _process(delta: float) -> void:

	if Input.is_action_just_pressed("pause_game"):
		_toggle_pause(not _paused)
		return

	if _ended or _paused:
		return

	_time_left -= delta
	_update_hud()

	if _time_left <= 0.0:
		_time_left = 0.0
		_trigger_game_over()

func _toggle_pause(state: bool) -> void:
	_paused       = state
	_pause_panel.visible = state
	get_tree().paused    = state

func _on_resume()  -> void: _toggle_pause(false)
func _on_restart() -> void:
	get_tree().paused = false
	GameManager.start_game(GameManager.current_level)


func _update_hud() -> void:
	_timer_bar.value   = _time_left
	_timer_label.text  = _fmt_time(_time_left)


	var ratio := clampf(_time_left / _time_total, 0.0, 1.0)
	var col: Color
	if ratio > 0.5:
		col = _theme["timer_color"].lerp(Color(1.0, 0.82, 0.08), (1.0 - ratio) * 2.0)
	else:
		col = Color(1.0, 0.82, 0.08).lerp(Color(1.0, 0.12, 0.12), (0.5 - ratio) * 2.0)
	_bar_style.bg_color = col


	if _time_left < 10.0:
		var intensity := (10.0 - _time_left) / 10.0
		var shake     := intensity * 4.0
		_timer_label.position.x = 750.0 + randf_range(-shake, shake)
		_timer_label.add_theme_color_override("font_color",
			Color(1.0, 0.12 + randf() * 0.08, 0.12))
	else:
		_timer_label.position.x = 750.0
		_timer_label.add_theme_color_override("font_color", _theme["timer_color"])


func _trigger_game_over() -> void:
	if _ended: return
	_ended   = true
	_running = false
	AudioManager.play_sfx_death()
	_fade_out_then(GameManager.game_over)

func _on_enemy_caught() -> void:
	if _ended: return
	_ended   = true
	_running = false
	AudioManager.play_sfx_death()

	var flash_layer := CanvasLayer.new()
	flash_layer.layer = 26
	add_child(flash_layer)
	var flash := ColorRect.new()
	flash.color        = Color(1, 0, 0, 0)
	flash.position     = Vector2.ZERO
	flash.size         = Vector2(960, 540)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_layer.add_child(flash)
	var tw := create_tween()
	tw.tween_property(flash, "color", Color(1, 0, 0, 0.80), 0.07)
	tw.tween_property(flash, "color", Color(1, 0, 0, 0.0),  0.28)
	tw.tween_callback(func() -> void:
		_fade_out_then(GameManager.game_over)
	)

func _on_level_complete() -> void:
	if _ended: return
	_ended   = true
	_running = false
	AudioManager.play_sfx_win()
	_play_win_flash()

func _play_win_flash() -> void:

	var flash_layer := CanvasLayer.new()
	flash_layer.layer = 25
	add_child(flash_layer)
	var flash := ColorRect.new()
	flash.color    = Color(1, 1, 1, 0)
	flash.position = Vector2.ZERO
	flash.size     = Vector2(960, 540)
	flash_layer.add_child(flash)

	var tw := create_tween()
	tw.tween_property(flash, "color", Color(1, 1, 1, 0.85), 0.12)
	tw.tween_property(flash, "color", Color(1, 1, 1, 0.0),  0.30)
	tw.tween_callback(func() -> void:
		_fade_out_then(GameManager.complete_level)
	)


func _fmt_time(t: float) -> String:
	var secs:   int = int(t)
	var mins:   int = secs / 60
	var rem_s:  int = secs % 60
	var tenths: int = int((t - float(secs)) * 10)
	return "%d:%02d.%d" % [mins, rem_s, tenths]
