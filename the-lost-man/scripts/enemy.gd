



extends Node2D

signal caught_player

const TILE_SIZE := 32


var speed:        float = 55.0
var detect_range: float = 150.0
var maze_ref:     Array = []
var player_ref:   Node2D = null


var _cell:     Vector2i = Vector2i.ZERO
var _next_pos: Vector2  = Vector2.ZERO
var _dir:      Vector2i = Vector2i(1, 0)


var _t:        float = 0.0
var _chase:    bool  = false
var _eye_pulse: float = 0.0


func _ready() -> void:
	_build_area()

	_cell     = Vector2i(int(position.x) / TILE_SIZE,
	                     int(position.y) / TILE_SIZE)

	position  = Vector2(float(_cell.x) * TILE_SIZE + TILE_SIZE * 0.5,
	                    float(_cell.y) * TILE_SIZE + TILE_SIZE * 0.5)
	_next_pos = position
	z_index   = 5
	_pick_direction()

func _build_area() -> void:
	var area  := Area2D.new()
	var col   := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 13.0
	col.shape    = shape
	area.monitoring = true
	area.add_child(col)
	area.body_entered.connect(_on_body_entered)
	add_child(area)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		caught_player.emit()




func _process(delta: float) -> void:
	_t         += delta
	_eye_pulse  = sin(_t * 5.5) * 0.25 + 0.75


	var dist: float = position.distance_to(_next_pos)
	if dist <= speed * delta + 1.0:
		position = _next_pos
		_pick_direction()
	else:
		position = position.move_toward(_next_pos, speed * delta)


	if player_ref != null and player_ref.position.distance_to(position) < 15.0:
		caught_player.emit()

	queue_redraw()

func _pick_direction() -> void:
	if maze_ref.is_empty():
		return

	var cx: int = _cell.x
	var cy: int = _cell.y
	var back := Vector2i(-_dir.x, -_dir.y)


	var valid: Array[Vector2i] = []
	var dirs_list := [Vector2i(0,-1), Vector2i(1,0), Vector2i(0,1), Vector2i(-1,0)]
	for d: Vector2i in dirs_list:
		var nx := cx + d.x
		var ny := cy + d.y
		if ny >= 0 and ny < maze_ref.size():
			var row: Array = maze_ref[ny]
			if nx >= 0 and nx < row.size():
				if int(row[nx]) != MazeGenerator.WALL:

					if d != back or valid.is_empty():
						valid.append(d)

	if valid.is_empty():
		return


	_chase = false
	var chosen: Vector2i = valid[randi() % valid.size()]

	if player_ref != null:
		var to_player: Vector2 = player_ref.position - position
		if to_player.length() < detect_range and valid.size() > 1:
			_chase = true

			var best_dot: float = -999.0
			for d: Vector2i in valid:
				var dot: float = Vector2(float(d.x), float(d.y)).dot(to_player.normalized())
				if dot > best_dot:
					best_dot = dot
					chosen   = d

	_dir  = chosen
	_cell = Vector2i(cx + chosen.x, cy + chosen.y)
	_next_pos = Vector2(
		float(_cell.x) * TILE_SIZE + TILE_SIZE * 0.5,
		float(_cell.y) * TILE_SIZE + TILE_SIZE * 0.5
	)




func _draw() -> void:
	var bob: float = sin(_t * 3.8) * 2.5


	for i in 7:
		var a:   float = float(i) / 7.0 * TAU + _t * 1.4
		var jit: float = sin(_t * 2.8 + float(i) * 0.9) * 3.0
		var wx:  float = cos(a) * (12.0 + jit)
		var wy:  float = sin(a) * (9.0  + jit * 0.6) + bob
		var r:   float = 4.0 + sin(_t * 3.5 + float(i)) * 1.5
		draw_circle(Vector2(wx, wy), r, Color(0.14, 0.0, 0.22, 0.40))


	_draw_blob(Vector2(0.0, bob),       Vector2(14.0, 11.0), Color(0.05, 0.00, 0.09, 0.96))
	_draw_blob(Vector2(0.0, bob - 2.0), Vector2(10.0,  8.5), Color(0.10, 0.00, 0.16, 0.88))


	var ey: float = -3.0 + bob

	draw_circle(Vector2(-4.5, ey), 5.5, Color(0.9, 0.0, 0.0, _eye_pulse * 0.4))
	draw_circle(Vector2( 4.5, ey), 5.5, Color(0.9, 0.0, 0.0, _eye_pulse * 0.4))

	draw_circle(Vector2(-4.5, ey), 3.0, Color(1.0, 0.18, 0.0, _eye_pulse))
	draw_circle(Vector2( 4.5, ey), 3.0, Color(1.0, 0.18, 0.0, _eye_pulse))

	draw_rect(Rect2(-5.3, ey - 1.2, 1.6, 2.4), Color(0.22, 0.0, 0.0))
	draw_rect(Rect2( 3.7, ey - 1.2, 1.6, 2.4), Color(0.22, 0.0, 0.0))


	if _chase:
		var ring_a: float = (sin(_t * 9.0) * 0.5 + 0.5) * 0.50 + 0.15
		draw_arc(Vector2(0.0, bob), 22.0, 0.0, TAU, 22,
			Color(1.0, 0.05, 0.05, ring_a), 3.0)

		for i in 6:
			var sa: float = float(i) / 6.0 * TAU + _t * 4.0
			var inner := Vector2(cos(sa) * 22.0, sin(sa) * 22.0 + bob)
			var outer := Vector2(cos(sa) * 28.0, sin(sa) * 28.0 + bob)
			draw_line(inner, outer, Color(1.0, 0.1, 0.1, ring_a * 0.7), 1.5)


func _draw_blob(center: Vector2, radii: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in 18:
		var a:   float = TAU * float(i) / 18.0
		var jit: float = sin(_t * 6.5 + float(i) * 0.75) * 1.8
		pts.append(center + Vector2(
			cos(a) * (radii.x + jit),
			sin(a) * (radii.y + jit * 0.6)
		))
	draw_colored_polygon(pts, color)
