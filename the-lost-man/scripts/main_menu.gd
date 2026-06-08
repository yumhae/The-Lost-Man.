

extends Control

var _t       := 0.0
var _btns:   Array[Button] = []


var _particles: Array[Dictionary] = []

func _ready() -> void:
	size = Vector2(960, 540)
	_seed_particles()
	_build_bg()
	_build_particles_draw_node()
	_build_title()
	_build_stage_pills()
	_build_buttons()

	var ctrl := Label.new()
	ctrl.text         = "WASD / Arrow Keys to move     ESC to pause"
	ctrl.position     = Vector2(0, 510)
	ctrl.size         = Vector2(960, 24)
	ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ctrl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ctrl.add_theme_font_size_override("font_size", 13)
	ctrl.add_theme_color_override("font_color", Color(0.50, 0.50, 0.60))
	ctrl.z_index = 4
	add_child(ctrl)
	_fade_in()
	AudioManager.play_menu_music()




func _seed_particles() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 8675309
	for i in 38:
		_particles.append({
			"x":     rng.randf() * 960.0,
			"y":     rng.randf() * 540.0,
			"r":     rng.randf_range(2.0, 7.5),
			"speed": rng.randf_range(8.0, 28.0),
			"phase": rng.randf() * TAU,
			"col":   Color(rng.randf_range(0.3, 0.6),
						   rng.randf_range(0.0, 0.2),
						   rng.randf_range(0.6, 1.0),
						   rng.randf_range(0.08, 0.22)),
		})

func _build_bg() -> void:

	var bg := ColorRect.new()
	bg.color        = Color(0.02, 0.02, 0.07)
	bg.position     = Vector2.ZERO
	bg.size         = Vector2(960, 540)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)


	var grid := _GridDraw.new()
	grid.z_index = 1
	add_child(grid)

func _build_particles_draw_node() -> void:
	var pdraw := _ParticleDraw.new(_particles)
	pdraw.z_index = 2
	add_child(pdraw)




func _build_title() -> void:

	var deco_qm := Label.new()
	deco_qm.name         = "DecoQM"
	deco_qm.text         = "?"
	deco_qm.position     = Vector2(0, 20)
	deco_qm.size         = Vector2(960, 200)
	deco_qm.mouse_filter = Control.MOUSE_FILTER_IGNORE
	deco_qm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	deco_qm.add_theme_font_size_override("font_size", 220)
	deco_qm.add_theme_color_override("font_color", Color(1.0, 0.90, 0.10, 0.055))
	deco_qm.z_index = 3
	add_child(deco_qm)


	var title := Label.new()
	title.name         = "Title"
	title.text         = "THE LOST MAN"
	title.position     = Vector2(0, 72)
	title.size         = Vector2(960, 120)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 78)
	title.add_theme_color_override("font_color",        Color(1.00, 0.90, 0.10))
	title.add_theme_color_override("font_shadow_color", Color(0.00, 0.00, 0.00, 0.70))
	title.add_theme_constant_override("shadow_offset_x", 5)
	title.add_theme_constant_override("shadow_offset_y", 5)
	title.z_index = 4
	add_child(title)


	var sub := Label.new()
	sub.text         = "Navigate 5 dangerous mazes before time runs out."
	sub.position     = Vector2(0, 168)
	sub.size         = Vector2(960, 36)
	sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 18)
	sub.add_theme_color_override("font_color", Color(0.72, 0.72, 0.88))
	sub.z_index = 4
	add_child(sub)


func _build_stage_pills() -> void:
	var pill_w   := 140.0
	var pill_h   := 70.0
	var gap      := 12.0
	var total_w  := pill_w * 5 + gap * 4
	var start_x  := (960.0 - total_w) / 2.0
	var labels   := ["FOREST", "RUINS", "CAVE", "MANSION", "VOID"]
	var times    := ["1:30", "1:05", "0:50", "0:35", "0:35"]
	var hunters  := ["2 Hunters", "3 Hunters", "4 Hunters", "5 Hunters", "7 Hunters"]
	var colors: Array[Color] = [
		Color(0.20, 0.68, 0.14, 0.88),
		Color(0.78, 0.62, 0.22, 0.88),
		Color(0.40, 0.18, 0.82, 0.88),
		Color(0.82, 0.14, 0.14, 0.88),
		Color(0.00, 0.75, 1.00, 0.88),
	]
	for i in 5:
		var x := start_x + float(i) * (pill_w + gap)
		var pill := _make_pill(labels[i], times[i], hunters[i], colors[i],
			Vector2(x, 218.0), Vector2(pill_w, pill_h), i + 1)
		add_child(pill)

func _make_pill(stage_name: String, time_str: String, hunter_str: String,
				col: Color, pos: Vector2, sz: Vector2, num: int) -> Control:
	var c := Control.new()
	c.position = pos
	c.size     = sz
	c.z_index  = 4

	var bg := ColorRect.new()
	bg.color    = Color(col.r, col.g, col.b, 0.16)
	bg.position = Vector2.ZERO
	bg.size     = sz
	c.add_child(bg)

	var border_line := ColorRect.new()
	border_line.color    = Color(col.r, col.g, col.b, 0.55)
	border_line.position = Vector2.ZERO
	border_line.size     = Vector2(sz.x, 2)
	c.add_child(border_line)

	var num_lbl := Label.new()
	num_lbl.text     = "STAGE %d" % num
	num_lbl.position = Vector2(0, 5)
	num_lbl.size     = Vector2(sz.x, 20)
	num_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	num_lbl.add_theme_font_size_override("font_size", 12)
	num_lbl.add_theme_color_override("font_color", col)
	c.add_child(num_lbl)

	var name_lbl := Label.new()
	name_lbl.text     = stage_name
	name_lbl.position = Vector2(0, 22)
	name_lbl.size     = Vector2(sz.x, 22)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 15)
	name_lbl.add_theme_color_override("font_color", Color.WHITE)
	c.add_child(name_lbl)

	var time_lbl := Label.new()
	time_lbl.text     = "⏱ " + time_str
	time_lbl.position = Vector2(0, 40)
	time_lbl.size     = Vector2(sz.x, 16)
	time_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	time_lbl.add_theme_font_size_override("font_size", 12)
	time_lbl.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
	c.add_child(time_lbl)

	var hunter_lbl := Label.new()
	hunter_lbl.text     = "☠ " + hunter_str
	hunter_lbl.position = Vector2(0, 54)
	hunter_lbl.size     = Vector2(sz.x, 14)
	hunter_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hunter_lbl.add_theme_font_size_override("font_size", 11)
	hunter_lbl.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35, 0.85))
	c.add_child(hunter_lbl)

	return c


func _build_buttons() -> void:


	var btn_y := 310.0
	_btns.append(_make_menu_btn(
		"▶   PLAY",  Vector2(380, btn_y),      Color(0.25, 0.88, 0.38), _on_play))
	_btns.append(_make_menu_btn(
		"✕   QUIT",  Vector2(380, btn_y + 68), Color(0.88, 0.24, 0.24), _on_quit))

func _make_menu_btn(text: String, pos: Vector2, col: Color, cb: Callable) -> Button:
	var btn := Button.new()
	btn.text                = text
	btn.position            = pos
	btn.custom_minimum_size = Vector2(200, 56)
	btn.add_theme_font_size_override("font_size", 22)
	btn.add_theme_color_override("font_color",         Color.WHITE)
	btn.add_theme_color_override("font_hover_color",   col)
	btn.add_theme_color_override("font_pressed_color", col.darkened(0.15))

	var n := _sbf(Color(0.10, 0.10, 0.20, 0.93), col.darkened(0.4),  false)
	var h := _sbf(Color(col.r * 0.20, col.g * 0.18, col.b * 0.22, 0.96), col, true)
	var p := _sbf(Color(0.05, 0.05, 0.12, 0.97), col.lightened(0.1), true)
	btn.add_theme_stylebox_override("normal",  n)
	btn.add_theme_stylebox_override("hover",   h)
	btn.add_theme_stylebox_override("pressed", p)
	btn.add_theme_stylebox_override("focus",   n)
	btn.pressed.connect(cb)
	add_child(btn)   
	return btn

func _sbf(bg: Color, border: Color, glow: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color     = bg
	s.border_color = border
	s.set_border_width_all(2 if not glow else 3)
	s.set_corner_radius_all(9)
	if glow:
		s.shadow_color = Color(border.r, border.g, border.b, 0.38)
		s.shadow_size  = 7
	return s


func _fade_in() -> void:
	var overlay := ColorRect.new()
	overlay.color        = Color.BLACK
	overlay.position     = Vector2.ZERO
	overlay.size         = Vector2(960, 540)
	overlay.z_index      = 100
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)
	var tw := create_tween()
	tw.tween_property(overlay, "color", Color(0, 0, 0, 0), 0.65)

func _process(delta: float) -> void:
	_t += delta

	var deco := get_node_or_null("DecoQM")
	if deco:
		deco.position.y = 20.0 + sin(_t * 1.2) * 12.0

	var title := get_node_or_null("Title")
	if title:
		var pulse := sin(_t * 2.5) * 0.04
		title.add_theme_color_override("font_color",
			Color(1.0, 0.90 + pulse, 0.10 - pulse))

func _on_play() -> void:
	GameManager.start_game(0)

func _on_quit() -> void:
	get_tree().quit()


class _GridDraw extends Node2D:
	func _draw() -> void:
		var col := Color(0.25, 0.20, 0.55, 0.06)
		for x in range(0, 961, 48):
			draw_line(Vector2(x, 0), Vector2(x, 540), col, 1.0)
		for y in range(0, 541, 48):
			draw_line(Vector2(0, y), Vector2(960, y), col, 1.0)

class _ParticleDraw extends Node2D:
	var _data: Array[Dictionary]
	var _t    := 0.0

	func _init(data: Array[Dictionary]) -> void:
		_data = data

	func _process(delta: float) -> void:
		_t += delta
		queue_redraw()

	func _draw() -> void:
		for p in _data:
			var bob: float = sin(_t * float(p["speed"]) * 0.18 + float(p["phase"])) * 22.0
			var x:   float = p["x"]
			var y:   float = fmod(float(p["y"]) - _t * float(p["speed"]) * 0.28 + bob + 540.0, 540.0)
			draw_circle(Vector2(x, y), float(p["r"]), p["col"])
