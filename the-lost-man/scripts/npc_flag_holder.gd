

extends Node2D

signal player_arrived

var accent_color := Color(0.20, 0.90, 0.30)

var _t       := 0.0
var _arrived := false

func _ready() -> void:
	_build_detector()
	z_index = 4

func _build_detector() -> void:
	var area  := Area2D.new()
	var col   := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 24.0
	col.shape    = shape
	area.add_child(col)
	area.body_entered.connect(_on_body_entered)
	add_child(area)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not _arrived:
		_arrived = true
		player_arrived.emit()

func _process(delta: float) -> void:
	_t += delta * 2.4
	queue_redraw()

func _draw() -> void:

	_draw_ellipse(Vector2(0, 14), Vector2(12, 4), Color(0, 0, 0, 0.28))


	draw_rect(Rect2(-7, -4, 14, 13), Color(0.22, 0.44, 0.82))


	var skin := Color(0.52, 0.82, 0.52)
	draw_circle(Vector2(0, -13), 8, skin)


	draw_arc(Vector2(0, -18), 8, deg_to_rad(195), deg_to_rad(345), 10,
		Color(0.78, 0.62, 0.10), 4.5)


	draw_arc(Vector2(0, -11), 4, deg_to_rad(15), deg_to_rad(165), 10,
		Color(0.18, 0.52, 0.18), 2.0)


	draw_arc(Vector2(-3, -14), 2.2, deg_to_rad(200), deg_to_rad(340), 6,
		Color(0.10, 0.10, 0.10), 2.0)
	draw_arc(Vector2( 3, -14), 2.2, deg_to_rad(200), deg_to_rad(340), 6,
		Color(0.10, 0.10, 0.10), 2.0)


	draw_rect(Rect2(7, -18, 2, 32), Color(0.55, 0.38, 0.08))


	var wave := sin(_t) * 7.0
	var fp := PackedVector2Array([
		Vector2(9,  -36),
		Vector2(30 + wave, -36),
		Vector2(28 + wave * 0.7, -27),
		Vector2(9,  -27),
	])
	draw_colored_polygon(fp, accent_color)
	draw_polyline(fp, accent_color.darkened(0.20), 1.0)


	_draw_star(Vector2(19.0 + wave * 0.5, -31.5), 5.0, Color(1.0, 1.0, 0.50))


	var glow_alpha := (sin(_t * 1.5) * 0.5 + 0.5) * 0.12
	draw_arc(Vector2(0, -5), 28, 0, TAU, 24,
		Color(accent_color.r, accent_color.g, accent_color.b, glow_alpha + 0.06), 6.0)


	draw_rect(Rect2(-5, 9, 4, 8), Color(0.28, 0.50, 0.28))
	draw_rect(Rect2( 1, 9, 4, 8), Color(0.28, 0.50, 0.28))


func _draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in 12:
		var a := TAU * float(i) / 12.0
		pts.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(pts, color)

func _draw_star(center: Vector2, radius: float, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in 10:
		var a   := TAU * float(i) / 10.0 - PI / 2.0
		var r   := radius if i % 2 == 0 else radius * 0.42
		pts.append(center + Vector2(cos(a) * r, sin(a) * r))
	draw_colored_polygon(pts, color)
