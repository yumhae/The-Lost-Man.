

extends Control

var _t := 0.0
var _level_idx: int
var _level_name: String

func _ready() -> void:
	size        = Vector2(960, 540)
	_level_idx  = GameManager.current_level
	_level_name = GameManager.get_level_name()

	_build_bg()
	_build_vignette()
	_build_title()
	_build_info()
	_build_buttons()
	_build_fade_in()
	AudioManager.stop_music()


func _build_bg() -> void:
	var bg := ColorRect.new()
	bg.color        = Color(0.04, 0.00, 0.00)
	bg.position     = Vector2.ZERO
	bg.size         = Vector2(960, 540)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

func _build_vignette() -> void:
	var vignode := _VignetteDraw.new()
	vignode.z_index = 1
	add_child(vignode)


func _build_title() -> void:
	var ghost := Label.new()
	ghost.name         = "GhostTitle"
	ghost.text         = "TIME'S UP!"
	ghost.position     = Vector2(0, 120)
	ghost.size         = Vector2(960, 130)
	ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ghost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ghost.add_theme_font_size_override("font_size", 88)
	ghost.add_theme_color_override("font_color", Color(0.55, 0.00, 0.00, 0.45))
	ghost.z_index = 2
	add_child(ghost)

	var lbl := Label.new()
	lbl.name         = "MainTitle"
	lbl.text         = "TIME'S UP!"
	lbl.position     = Vector2(0, 115)
	lbl.size         = Vector2(960, 130)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 88)
	lbl.add_theme_color_override("font_color",        Color(1.00, 0.10, 0.10))
	lbl.add_theme_color_override("font_shadow_color", Color(0.60, 0.00, 0.00, 0.80))
	lbl.add_theme_constant_override("shadow_offset_x", 6)
	lbl.add_theme_constant_override("shadow_offset_y", 6)
	lbl.z_index = 3
	add_child(lbl)

func _build_info() -> void:
	var lbl := Label.new()
	lbl.text         = "Stage %d  %s  could not be escaped in time." % [_level_idx + 1, _level_name]
	lbl.position     = Vector2(0, 258)
	lbl.size         = Vector2(960, 36)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 20)
	lbl.add_theme_color_override("font_color", Color(0.78, 0.58, 0.58))
	lbl.z_index = 4
	add_child(lbl)


func _build_buttons() -> void:
	_make_btn("↺   RETRY",     Vector2(292, 322), Color(0.95, 0.28, 0.10), _on_retry)
	_make_btn("⌂   MAIN MENU", Vector2(500, 322), Color(0.50, 0.60, 1.00), _on_menu)

func _make_btn(text: String, pos: Vector2, col: Color, cb: Callable) -> void:
	var btn := Button.new()
	btn.text                = text
	btn.position            = pos
	btn.custom_minimum_size = Vector2(190, 58)
	btn.add_theme_font_size_override("font_size", 20)
	btn.add_theme_color_override("font_color",         Color.WHITE)
	btn.add_theme_color_override("font_hover_color",   col)
	btn.add_theme_color_override("font_pressed_color", col.lightened(0.2))

	var n := _sbf(Color(0.12, 0.04, 0.04, 0.95), col.darkened(0.45), false)
	var h := _sbf(Color(col.r*0.22, col.g*0.06, col.b*0.10, 0.97), col, true)
	var p := _sbf(Color(0.06, 0.02, 0.02, 0.98), col.lightened(0.1), true)
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
	tw.tween_property(overlay, "color", Color(0, 0, 0, 0), 0.55)

func _process(delta: float) -> void:
	_t += delta
	var main_title := get_node_or_null("MainTitle")
	if main_title:
		var shake: float = sin(_t * 28.0) * 3.5 * exp(-_t * 0.55)
		main_title.position.x = shake
	var ghost := get_node_or_null("GhostTitle")
	if ghost:
		var s2: float = sin(_t * 20.0) * 4.5 * exp(-_t * 0.55)
		ghost.position.x = s2 + 4.0

func _on_retry() -> void: GameManager.start_game(GameManager.current_level)
func _on_menu()  -> void: GameManager.go_to_menu()


class _VignetteDraw extends Node2D:
	func _draw() -> void:
		var center := Vector2(480, 270)
		for i in 12:
			var r:     float = 580.0 - float(i) * 40.0
			var alpha: float = float(i) / 12.0 * 0.45
			draw_arc(center, r, 0, TAU, 32,
				Color(0.55, 0.00, 0.00, alpha), float(40))
