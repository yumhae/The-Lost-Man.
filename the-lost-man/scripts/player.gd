

extends CharacterBody2D

const SPEED := 130.0

var accent_color := Color(1.0, 0.90, 0.10)

var _anim_t  := 0.0
var _bob_t   := 0.0
var _walking := false

func _ready() -> void:
	_add_collision()
	z_index = 5
	add_to_group("player")

func _add_collision() -> void:
	var col   := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 11.0
	col.shape   = shape
	add_child(col)

func _physics_process(delta: float) -> void:
	var dir := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down")  - Input.get_action_strength("move_up")
	)
	_walking = dir != Vector2.ZERO
	if _walking:
		dir       = dir.normalized()
		_anim_t  += delta * 9.0
	else:
		_anim_t   = 0.0
	velocity = dir * SPEED
	move_and_slide()

	_bob_t += delta * 3.2
	queue_redraw()

func _draw() -> void:
	var walk_sway := sin(_anim_t) * 3.5 if _walking else 0.0
	var bob       := sin(_bob_t) * 3.2


	_draw_ellipse(Vector2(0, 15), Vector2(13, 4.5), Color(0, 0, 0, 0.28))


	var leg := Color(0.18, 0.12, 0.06)
	var shoe := Color(0.10, 0.07, 0.03)
	draw_rect(Rect2(-6,  8 + walk_sway, 5, 8), leg)
	draw_rect(Rect2( 1,  8 - walk_sway, 5, 8), leg)
	draw_rect(Rect2(-7, 16 + walk_sway, 6, 3), shoe)
	draw_rect(Rect2( 1, 16 - walk_sway, 6, 3), shoe)


	var jc  := Color(0.28, 0.20, 0.10)
	var jcd := Color(0.18, 0.12, 0.06)
	draw_rect(Rect2(-8, -5, 16, 14), jc)

	draw_line(Vector2(-6, 3), Vector2(-3, 7), jcd, 2.0)
	draw_line(Vector2( 4, 2), Vector2( 7, 6), jcd, 2.0)
	draw_line(Vector2(-2, 5), Vector2( 0, 8), jcd, 1.5)


	draw_rect(Rect2(-13, -4 + walk_sway * 0.5, 6, 10), jc)
	draw_rect(Rect2(  7, -4 - walk_sway * 0.5, 6, 10), jc)


	var skin := Color(0.87, 0.71, 0.49)
	draw_circle(Vector2(0, -13), 9, skin)


	var hc := Color(0.16, 0.09, 0.03)
	var spikes: Array = [
		[Vector2(-11,-14), Vector2(-8,-27), Vector2(-4,-14)],
		[Vector2( -5,-18), Vector2(-1,-29), Vector2( 2,-17)],
		[Vector2(  1,-19), Vector2( 4,-28), Vector2( 7,-17)],
		[Vector2(  6,-16), Vector2(10,-26), Vector2(11,-13)],
		[Vector2(-10,-10), Vector2(-14,-21),Vector2( -7,-10)],
	]
	for sp in spikes:
		draw_polygon(sp, [hc, hc, hc])


	draw_circle(Vector2(-3.5, -14), 2.8, Color.WHITE)
	draw_circle(Vector2( 3.5, -14), 2.8, Color.WHITE)
	draw_circle(Vector2(-3.0, -14), 1.6, Color(0.1, 0.1, 0.1))
	draw_circle(Vector2( 4.0, -14), 1.6, Color(0.1, 0.1, 0.1))

	draw_circle(Vector2(-2.4, -14.6), 0.7, Color.WHITE)
	draw_circle(Vector2( 4.6, -14.6), 0.7, Color.WHITE)


	var frown := PackedVector2Array([Vector2(-3,-8), Vector2(0,-6), Vector2(3,-8)])
	draw_polyline(frown, Color(0.55, 0.30, 0.20), 1.5)


	_draw_question_mark(Vector2(0.0, -35.0 + bob))


func _draw_question_mark(pos: Vector2) -> void:
	var qc  := accent_color
	var font := ThemeDB.fallback_font
	var fs   := 22


	for i in 4:
		var gc := Color(qc.r, qc.g, qc.b, 0.06 * float(4 - i))
		draw_string(font, pos + Vector2(-7, fs / 2.0), "?",
			HORIZONTAL_ALIGNMENT_LEFT, -1, fs + i * 4, gc)


	draw_string(font, pos + Vector2(-7, fs / 2.0), "?",
		HORIZONTAL_ALIGNMENT_LEFT, -1, fs, qc)

func _draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in 14:
		var a := TAU * float(i) / 14.0
		pts.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(pts, color)
