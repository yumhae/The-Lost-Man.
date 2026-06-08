


extends Control

var _t := 0.0
var _confetti: Array[Dictionary] = []

func _ready() -> void:
	size = Vector2(960, 540)
	_seed_confetti()
	_build_bg()
	_build_confetti_node()
	_build_reunion_scene()
	_build_title()
	_build_info()
	_build_buttons()
	_build_fade_in()
	AudioManager.play_menu_music()


func _build_bg() -> void:
	var bg := ColorRect.new()
	bg.color        = Color(0.02, 0.04, 0.08)
	bg.position     = Vector2.ZERO
	bg.size         = Vector2(960, 540)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)


func _seed_confetti() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 999999
	var palette: Array[Color] = [
		Color(1.0, 0.85, 0.1),  Color(0.2, 0.85, 0.3),
		Color(0.0, 0.80, 1.0),  Color(1.0, 0.3, 0.3),
		Color(0.8, 0.3, 1.0),   Color(1.0, 0.65, 0.0),
	]
	for i in 55:
		_confetti.append({
			"x":    rng.randf() * 960.0,
			"y":    rng.randf() * -540.0,
			"vx":   rng.randf_range(-25.0, 25.0),
			"vy":   rng.randf_range(55.0, 130.0),
			"rot":  rng.randf() * TAU,
			"vrot": rng.randf_range(-3.0, 3.0),
			"w":    rng.randf_range(5.0, 11.0),
			"h":    rng.randf_range(4.0, 8.0),
			"col":  palette[rng.randi() % palette.size()],
		})

func _build_confetti_node() -> void:
	var cdraw := _ConfettiDraw.new(_confetti)
	cdraw.z_index = 2
	add_child(cdraw)


func _build_reunion_scene() -> void:
	var scene := _ReunionDraw.new()
	scene.name = "ReunionScene"
	scene.position = Vector2(480, 315)
	scene.z_index = 3
	add_child(scene)


func _build_title() -> void:
	var sub := Label.new()
	sub.text         = "YOU ESCAPED!"
	sub.position     = Vector2(0, 45)
	sub.size         = Vector2(960, 100)
	sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 82)
	sub.add_theme_color_override("font_color",        Color(1.00, 0.88, 0.10))
	sub.add_theme_color_override("font_shadow_color", Color(0.50, 0.30, 0.00, 0.80))
	sub.add_theme_constant_override("shadow_offset_x", 5)
	sub.add_theme_constant_override("shadow_offset_y", 5)
	sub.name    = "WinTitle"
	sub.z_index = 4
	add_child(sub)

	var main_lbl := Label.new()
	main_lbl.text         = "ALL 5 STAGES COMPLETE!"
	main_lbl.position     = Vector2(0, 130)
	main_lbl.size         = Vector2(960, 50)
	main_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_lbl.add_theme_font_size_override("font_size", 30)
	main_lbl.add_theme_color_override("font_color", Color(0.70, 0.96, 1.00))
	main_lbl.z_index = 4
	add_child(main_lbl)

func _build_info() -> void:
	var infos: Array[String] = [
		"You navigated the Forest, Ruins, Cave, Mansion, and the Void.",
		"The Lost Man has finally found his way home to his Father!",
	]
	for i in infos.size():
		var lbl := Label.new()
		lbl.text         = infos[i]
		lbl.position     = Vector2(0, 178.0 + float(i) * 26.0)
		lbl.size         = Vector2(960, 28)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 17)
		lbl.add_theme_color_override("font_color", Color(0.68, 0.76, 0.88))
		lbl.z_index = 4
		add_child(lbl)


func _build_buttons() -> void:
	_make_btn("▶   PLAY AGAIN", Vector2(292, 425), Color(0.30, 0.90, 0.35), _on_play_again)
	_make_btn("⌂   MAIN MENU",  Vector2(500, 425), Color(0.50, 0.65, 1.00), _on_menu)

func _make_btn(text: String, pos: Vector2, col: Color, cb: Callable) -> void:
	var btn := Button.new()
	btn.text                = text
	btn.position            = pos
	btn.custom_minimum_size = Vector2(190, 58)
	btn.add_theme_font_size_override("font_size", 20)
	btn.add_theme_color_override("font_color",         Color.WHITE)
	btn.add_theme_color_override("font_hover_color",   col)
	btn.add_theme_color_override("font_pressed_color", col.lightened(0.2))

	var n := _sbf(Color(0.06, 0.09, 0.15, 0.95), col.darkened(0.45), false)
	var h := _sbf(Color(col.r*0.18, col.g*0.18, col.b*0.20, 0.97), col, true)
	var p := _sbf(Color(0.03, 0.05, 0.08, 0.98), col.lightened(0.1), true)
	btn.add_theme_stylebox_override("normal",  n)
	btn.add_theme_stylebox_override("hover",   h)
	btn.add_theme_stylebox_override("pressed", p)
	btn.add_theme_stylebox_override("focus",   n)
	btn.pressed.connect(cb)
	add_child(btn)

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


func _build_fade_in() -> void:
	var fl := CanvasLayer.new()
	fl.layer = 30
	add_child(fl)
	var overlay := ColorRect.new()
	overlay.color        = Color.BLACK
	overlay.position     = Vector2.ZERO
	overlay.size         = Vector2(960, 540)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fl.add_child(overlay)
	var tw := create_tween()
	tw.tween_property(overlay, "color", Color(0, 0, 0, 0), 0.70)

func _process(delta: float) -> void:
	_t += delta
	var title := get_node_or_null("WinTitle")
	if title:
		var bob:   float = sin(_t * 2.2) * 6.0
		var pulse: float = sin(_t * 3.0) * 0.04
		title.position.y = 45.0 + bob
		title.add_theme_color_override("font_color",
			Color(1.0, 0.88 + pulse, 0.10 - pulse))

func _on_play_again() -> void: GameManager.start_game(0)
func _on_menu()       -> void: GameManager.go_to_menu()


class _ConfettiDraw extends Node2D:
	var _data: Array[Dictionary]
	var _t    := 0.0

	func _init(data: Array[Dictionary]) -> void:
		_data = data

	func _process(delta: float) -> void:
		_t += delta
		for p in _data:
			p["y"]   = float(p["y"])   + float(p["vy"])   * delta
			p["x"]   = float(p["x"])   + float(p["vx"])   * delta
			p["rot"] = float(p["rot"]) + float(p["vrot"]) * delta
			if float(p["y"]) > 580.0:
				p["y"] = -30.0
				p["x"] = randf() * 960.0
		queue_redraw()

	func _draw() -> void:
		for p in _data:
			var hw: float = float(p["w"]) * 0.5
			var hh: float = float(p["h"]) * 0.5
			var cx: float = p["x"]
			var cy: float = p["y"]
			var r:  float = p["rot"]
			var pts := PackedVector2Array([
				Vector2(cx + cos(r) * hw - sin(r) * hh,
				        cy + sin(r) * hw + cos(r) * hh),
				Vector2(cx + cos(r + PI/2) * hw - sin(r + PI/2) * hh,
				        cy + sin(r + PI/2) * hw + cos(r + PI/2) * hh),
				Vector2(cx + cos(r + PI) * hw - sin(r + PI) * hh,
				        cy + sin(r + PI) * hw + cos(r + PI) * hh),
				Vector2(cx + cos(r + 3*PI/2) * hw - sin(r + 3*PI/2) * hh,
				        cy + sin(r + 3*PI/2) * hw + cos(r + 3*PI/2) * hh),
			])
			draw_colored_polygon(pts, p["col"])


class _ReunionDraw extends Node2D:
	var _t: float = 0.0

	func _process(delta: float) -> void:
		_t += delta
		queue_redraw()

	func _draw() -> void:
		var bob := sin(_t * 2.8) * 2.5
		var heartbeat := sin(_t * 4.2) * 0.12 + 0.88
		

		_draw_ellipse(Vector2(0, 36), Vector2(100, 14), Color(0.12, 0.38, 0.18))
		_draw_ellipse(Vector2(0, 36), Vector2(80, 10), Color(0.16, 0.48, 0.22))


		var sx: float = -22.0
		var sy: float = 12.0
		

		_draw_ellipse(Vector2(sx, sy + 25), Vector2(13, 4.5), Color(0, 0, 0, 0.35))
		

		var leg_c := Color(0.18, 0.12, 0.06)
		var shoe_c := Color(0.10, 0.07, 0.03)
		draw_rect(Rect2(sx - 5, sy + 16, 4, 10), leg_c)
		draw_rect(Rect2(sx + 1, sy + 16, 4, 10), leg_c)
		draw_rect(Rect2(sx - 6, sy + 24, 5, 2.5), shoe_c)
		draw_rect(Rect2(sx + 1, sy + 24, 5, 2.5), shoe_c)
		

		var jc := Color(0.28, 0.20, 0.10)
		draw_rect(Rect2(sx - 7, sy + 3, 14, 14), jc)

		draw_rect(Rect2(sx + 5, sy + 6, 18, 3.5), jc)

		draw_rect(Rect2(sx - 11, sy + 4, 4, 9), jc)
		

		var skin := Color(0.87, 0.71, 0.49)
		draw_circle(Vector2(sx, sy - 5), 8.5, skin)
		

		var hc := Color(0.16, 0.09, 0.03)
		var son_spikes: Array = [
			[Vector2(sx - 10, sy - 6), Vector2(sx - 7, sy - 18), Vector2(sx - 3, sy - 6)],
			[Vector2(sx - 5,  sy - 10), Vector2(sx - 1, sy - 20), Vector2(sx + 2, sy - 9)],
			[Vector2(sx + 1,  sy - 10), Vector2(sx + 4, sy - 19), Vector2(sx + 7, sy - 9)],
		]
		for sp in son_spikes:
			draw_polygon(sp, [hc, hc, hc])
			

		draw_arc(Vector2(sx - 2, sy - 6), 2.0, deg_to_rad(20), deg_to_rad(160), 6, Color(0.1, 0.1, 0.1), 1.5)
		draw_arc(Vector2(sx + 3.5, sy - 6), 2.0, deg_to_rad(20), deg_to_rad(160), 6, Color(0.1, 0.1, 0.1), 1.5)
		

		draw_arc(Vector2(sx + 1, sy - 2), 3.2, deg_to_rad(15), deg_to_rad(165), 8, Color(0.55, 0.20, 0.15), 1.8)
		

		var fx: float = 22.0
		var fy: float = 4.0
		

		_draw_ellipse(Vector2(fx, fy + 33), Vector2(15, 5.0), Color(0, 0, 0, 0.35))
		

		var f_leg := Color(0.15, 0.20, 0.28)
		var f_shoe := Color(0.08, 0.08, 0.12)
		draw_rect(Rect2(fx - 6, fy + 22, 5, 12), f_leg)
		draw_rect(Rect2(fx + 1, fy + 22, 5, 12), f_leg)
		draw_rect(Rect2(fx - 7, fy + 32, 6, 3), f_shoe)
		draw_rect(Rect2(fx + 1, fy + 32, 6, 3), f_shoe)
		

		var f_jc := Color(0.24, 0.28, 0.35)
		draw_rect(Rect2(fx - 8, fy + 4, 16, 19), f_jc)

		draw_rect(Rect2(fx - 22, fy + 8, 15, 3.5), f_jc)

		draw_rect(Rect2(fx + 8, fy + 5, 4, 11), f_jc)
		

		var f_skin := Color(0.85, 0.69, 0.47)
		draw_circle(Vector2(fx, fy - 6), 9.5, f_skin)
		

		var f_hc := Color(0.85, 0.85, 0.88)
		var fat_spikes: Array = [
			[Vector2(fx - 11, fy - 7), Vector2(fx - 8, fy - 24), Vector2(fx - 4, fy - 7)],
			[Vector2(fx - 6,  fy - 11), Vector2(fx - 1, fy - 26), Vector2(fx + 2, fy - 10)],
			[Vector2(fx + 1,  fy - 11), Vector2(fx + 5, fy - 25), Vector2(fx + 8, fy - 10)],
			[Vector2(fx + 5,  fy - 8), Vector2(fx + 9, fy - 22), Vector2(fx + 11, fy - 8)],
		]
		for sp in fat_spikes:
			draw_polygon(sp, [f_hc, f_hc, f_hc])
			

		draw_arc(Vector2(fx - 3.5, fy - 7), 2.0, deg_to_rad(20), deg_to_rad(160), 6, Color(0.1, 0.1, 0.1), 1.5)
		draw_arc(Vector2(fx + 2, fy - 7), 2.0, deg_to_rad(20), deg_to_rad(160), 6, Color(0.1, 0.1, 0.1), 1.5)
		

		draw_arc(Vector2(fx - 1, fy - 3), 3.0, deg_to_rad(15), deg_to_rad(165), 8, Color(0.50, 0.18, 0.12), 1.8)


		var hx: float = 0.0
		var hy: float = -28.0 + bob
		_draw_heart(Vector2(hx, hy), 9.0 * heartbeat, Color(1.0, 0.18, 0.24))

		draw_arc(Vector2(hx, hy), 18.0, 0, TAU, 16, Color(1.0, 0.18, 0.24, 0.15 * (2.0 - heartbeat)), 2.0)

	func _draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
		var pts := PackedVector2Array()
		for i in 12:
			var a := TAU * float(i) / 12.0
			pts.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
		draw_colored_polygon(pts, color)

	func _draw_heart(center: Vector2, size: float, color: Color) -> void:
		var pts := PackedVector2Array()
		var steps := 24
		for i in steps:
			var t := float(i) / float(steps) * TAU
			var x := 16.0 * pow(sin(t), 3)
			var y := -(13.0 * cos(t) - 5.0 * cos(2*t) - 2.0 * cos(3*t) - cos(4*t))
			pts.append(center + Vector2(x, y) * (size / 16.0))
		draw_colored_polygon(pts, color)
