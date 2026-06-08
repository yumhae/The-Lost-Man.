

extends Node2D

var maze:        Array  = []
var tile_size:   int    = 32
var wall_color:  Color  = Color(0.2, 0.2, 0.2)
var wall_top:    Color  = Color(0.3, 0.3, 0.3)
var floor_color: Color  = Color(0.5, 0.5, 0.5)
var floor_alt:   Color  = Color(0.45, 0.45, 0.45)
var level_idx:   int    = 0
var do_animate:  bool   = true

var _t: float = 0.0


var _floor_decorations: Dictionary = {}
var _wall_decorations:  Dictionary = {}
var _crystal_cells:     Array[Vector2i] = []
var _particles:         Array[Dictionary] = []

func _ready() -> void:
	_precompute_decorations()
	_init_particles()

func _precompute_decorations() -> void:
	_floor_decorations.clear()
	_wall_decorations.clear()
	_crystal_cells.clear()
	
	if maze.is_empty():
		return
		
	var rng := RandomNumberGenerator.new()

	rng.seed = 12345 + level_idx * 6789
	
	for yi in maze.size():
		var row: Array = maze[yi]
		for xi in row.size():
			var pos := Vector2i(xi, yi)
			if int(row[xi]) == MazeGenerator.WALL:
				match level_idx:
					0:
						var leaves: Array = []
						for k in rng.randi_range(3, 5):
							leaves.append({
								"offset": Vector2(rng.randf_range(-7, 7), rng.randf_range(-7, 7)),
								"radius": rng.randf_range(5, 10),
								"color_offset": rng.randf_range(0.01, 0.08)
							})
						_wall_decorations[pos] = leaves
					1:
						var dec := {
							"has_moss": rng.randf() < 0.28,
							"moss_offset": Vector2(rng.randf_range(-8, 8), rng.randf_range(-8, 8)),
							"moss_radius": rng.randf_range(4.5, 8.5),
							"brick_variant": rng.randi() % 3
						}
						_wall_decorations[pos] = dec
					2:
						var dec := {
							"has_crack": rng.randf() < 0.32,
							"crack_pts": [
								Vector2(rng.randf_range(-14, 14), rng.randf_range(-14, 14)),
								Vector2(rng.randf_range(-6, 6), rng.randf_range(-6, 6)),
								Vector2(rng.randf_range(-14, 14), rng.randf_range(-14, 14))
							]
						}
						_wall_decorations[pos] = dec
					3:
						var dec := {
							"has_web": rng.randf() < 0.16,
							"web_side": rng.randi() % 4
						}
						_wall_decorations[pos] = dec
			else:

				match level_idx:
					0:
						if rng.randf() < 0.42:
							var is_flower := rng.randf() < 0.32
							var dec := {
								"type": "flower" if is_flower else "grass",
								"offset": Vector2(rng.randf_range(-9, 9), rng.randf_range(-9, 9)),
								"variant": rng.randi() % 3
							}
							_floor_decorations[pos] = dec
					1:
						if rng.randf() < 0.22:
							var dec := {
								"pts": [
									Vector2(rng.randf_range(-13, 13), rng.randf_range(-13, 13)),
									Vector2(rng.randf_range(-5, 5), rng.randf_range(-5, 5)),
									Vector2(rng.randf_range(-13, 13), rng.randf_range(-13, 13))
								]
							}
							_floor_decorations[pos] = dec
					2:
						if (xi * 3 + yi * 7) % 13 == 4:
							_crystal_cells.append(pos)
						elif rng.randf() < 0.35:
							var dec := {
								"offsets": [
									Vector2(rng.randf_range(-10, 10), rng.randf_range(-10, 10)),
									Vector2(rng.randf_range(-10, 10), rng.randf_range(-10, 10))
								],
								"sizes": [rng.randf_range(1.5, 3.2), rng.randf_range(1.2, 2.8)]
							}
							_floor_decorations[pos] = dec
					3:
						var dec := {
							"has_scratch": rng.randf() < 0.12,
							"scratch_pts": [
								Vector2(rng.randf_range(-10, 10), rng.randf_range(-10, 10)),
								Vector2(rng.randf_range(-10, 10), rng.randf_range(-10, 10))
							]
						}
						_floor_decorations[pos] = dec
					4:
						if rng.randf() < 0.55:
							var dec := {
								"offset": Vector2(rng.randf_range(-13, 13), rng.randf_range(-13, 13)),
								"radius": rng.randf_range(0.4, 1.4),
								"color": Color(0.55, 0.88, 1.0, rng.randf_range(0.35, 0.85))
							}
							_floor_decorations[pos] = dec

func _init_particles() -> void:
	_particles.clear()
	if level_idx in [0, 1, 2, 3]:
		var rng := RandomNumberGenerator.new()
		rng.seed = 9999 + level_idx
		var p_count := 35 + level_idx * 8
		for i in p_count:
			var max_w: float = 960.0
			var max_h: float = 540.0
			if not maze.is_empty():
				max_w = float(maze[0].size() * tile_size)
				max_h = float(maze.size() * tile_size)
			_particles.append({
				"pos": Vector2(rng.randf() * max_w, rng.randf() * max_h),
				"speed": rng.randf_range(8.0, 22.0),
				"phase": rng.randf() * TAU,
				"size": rng.randf_range(1.2, 3.2),
				"vel_dir": Vector2(rng.randf_range(-0.7, 0.7), rng.randf_range(-1.2, -0.4)).normalized()
			})

func _process(delta: float) -> void:
	if do_animate:
		_t += delta
		_update_particles(delta)
		queue_redraw()

func _update_particles(delta: float) -> void:
	if maze.is_empty() or _particles.is_empty(): return
	var max_w: float = float(maze[0].size() * tile_size)
	var max_h: float = float(maze.size() * tile_size)
	for p in _particles:
		var speed: float = p["speed"]
		var phase: float = p["phase"] + _t * 2.0
		var dir: Vector2 = p["vel_dir"]
		var sway := Vector2(cos(phase) * 6.0 * delta, 0.0)
		p["pos"] += (dir * speed * delta) + sway
		

		if p["pos"].y < 0:
			p["pos"].y = max_h
			p["pos"].x = randf_range(0, max_w)
		if p["pos"].x < 0:
			p["pos"].x = max_w
		elif p["pos"].x > max_w:
			p["pos"].x = 0

func _draw() -> void:
	_draw_maze()
	match level_idx:
		2: _draw_cave_crystals()
		4: _draw_void_grid()
	_draw_particles()


func _draw_maze() -> void:
	var ts: int = tile_size
	for yi in maze.size():
		var row: Array = maze[yi]
		for xi in row.size():
			var rx: int = xi * ts
			var ry: int = yi * ts
			var pos := Vector2i(xi, yi)
			
			if int(row[xi]) == MazeGenerator.WALL:

				draw_rect(Rect2(rx, ry, ts, ts), wall_color)
				

				if level_idx == 1 and _wall_decorations.has(pos):
					var dec: Dictionary = _wall_decorations[pos]
					var dc := wall_color.darkened(0.24)

					draw_line(Vector2(rx, ry + 10), Vector2(rx + ts, ry + 10), dc)
					draw_line(Vector2(rx, ry + 21), Vector2(rx + ts, ry + 21), dc)

					if dec["brick_variant"] == 0:
						draw_line(Vector2(rx + 8, ry), Vector2(rx + 8, ry + 10), dc)
						draw_line(Vector2(rx + 24, ry), Vector2(rx + 24, ry + 10), dc)
						draw_line(Vector2(rx + 16, ry + 10), Vector2(rx + 16, ry + 21), dc)
						draw_line(Vector2(rx + 8, ry + 21), Vector2(rx + 8, ry + ts), dc)
						draw_line(Vector2(rx + 24, ry + 21), Vector2(rx + 24, ry + ts), dc)
					else:
						draw_line(Vector2(rx + 16, ry), Vector2(rx + 16, ry + 10), dc)
						draw_line(Vector2(rx + 8, ry + 10), Vector2(rx + 8, ry + 21), dc)
						draw_line(Vector2(rx + 24, ry + 10), Vector2(rx + 24, ry + 21), dc)
						draw_line(Vector2(rx + 16, ry + 21), Vector2(rx + 16, ry + ts), dc)
					

					if dec["has_moss"]:
						var mpos: Vector2 = Vector2(rx + ts/2, ry + ts/2) + dec["moss_offset"]
						draw_circle(mpos, dec["moss_radius"], Color(0.25, 0.44, 0.16, 0.65))
						draw_circle(mpos + Vector2(2, -1), dec["moss_radius"] * 0.7, Color(0.30, 0.50, 0.20, 0.65))
				

				elif level_idx == 2 and _wall_decorations.has(pos):
					var dec: Dictionary = _wall_decorations[pos]
					if dec["has_crack"]:
						var origin := Vector2(rx + ts/2, ry + ts/2)
						var pts := PackedVector2Array([
							origin + dec["crack_pts"][0],
							origin + dec["crack_pts"][1],
							origin + dec["crack_pts"][2]
						])
						draw_polyline(pts, Color(0.02, 0.02, 0.08, 0.8), 1.2)
						

				elif level_idx == 3 and _wall_decorations.has(pos):
					var dec: Dictionary = _wall_decorations[pos]
					if dec["has_web"]:
						var wp := Vector2(rx, ry)
						var c_web := Color(0.85, 0.85, 0.90, 0.35)
						match dec["web_side"]:
							0:
								draw_line(wp, wp + Vector2(10, 0), c_web, 1.0)
								draw_line(wp, wp + Vector2(0, 10), c_web, 1.0)
								draw_line(wp, wp + Vector2(7, 7), c_web, 0.7)
							1:
								wp.x += ts
								draw_line(wp, wp + Vector2(-10, 0), c_web, 1.0)
								draw_line(wp, wp + Vector2(0, 10), c_web, 1.0)
								draw_line(wp, wp + Vector2(-7, 7), c_web, 0.7)
							2:
								wp.y += ts
								draw_line(wp, wp + Vector2(10, 0), c_web, 1.0)
								draw_line(wp, wp + Vector2(0, -10), c_web, 1.0)
								draw_line(wp, wp + Vector2(7, -7), c_web, 0.7)
							3:
								wp += Vector2(ts, ts)
								draw_line(wp, wp + Vector2(-10, 0), c_web, 1.0)
								draw_line(wp, wp + Vector2(0, -10), c_web, 1.0)
								draw_line(wp, wp + Vector2(-7, -7), c_web, 0.7)
				

				draw_rect(Rect2(rx, ry, ts, 4), wall_top)
				draw_rect(Rect2(rx, ry + 4, 3, ts - 4), wall_top.lerp(wall_color, 0.45))
				draw_rect(Rect2(rx, ry + ts - 3, ts, 3), wall_color.darkened(0.28))
				

				if level_idx == 0 and _wall_decorations.has(pos):
					var leaves: Array = _wall_decorations[pos]
					for leaf in leaves:
						var lpos: Vector2 = Vector2(rx + ts/2, ry + ts/2) + leaf["offset"]
						var lcol: Color = wall_top.lightened(leaf["color_offset"]) if leaf["offset"].y < 0 else wall_color.darkened(leaf["color_offset"])
						draw_circle(lpos, leaf["radius"], lcol)
						
			else:

				var col: Color = floor_alt if (xi + yi) % 2 == 1 else floor_color
				draw_rect(Rect2(rx, ry, ts, ts), col)
				draw_rect(Rect2(rx, ry + ts - 1, ts, 1), col.darkened(0.10))
				

				if level_idx == 0 and _floor_decorations.has(pos):
					var dec: Dictionary = _floor_decorations[pos]
					var origin: Vector2 = Vector2(rx + ts/2, ry + ts/2) + dec["offset"]
					if dec["type"] == "flower":

						var p_col: Color = Color(1, 1, 1) if dec["variant"] == 0 else (Color(1.0, 0.38, 0.38) if dec["variant"] == 1 else Color(1.0, 0.80, 0.20))
						draw_circle(origin + Vector2(-2, -2), 1.8, p_col)
						draw_circle(origin + Vector2(2, -2), 1.8, p_col)
						draw_circle(origin + Vector2(-2, 2), 1.8, p_col)
						draw_circle(origin + Vector2(2, 2), 1.8, p_col)

						draw_circle(origin, 1.2, Color(1.0, 0.90, 0.10))
					else:

						draw_line(origin, origin + Vector2(-2.5, -6), Color(0.18, 0.44, 0.08), 1.2)
						draw_line(origin, origin + Vector2(0.0, -8), Color(0.20, 0.48, 0.10), 1.2)
						draw_line(origin, origin + Vector2(2.5, -6), Color(0.18, 0.44, 0.08), 1.2)
						

				elif level_idx == 1 and _floor_decorations.has(pos):
					var dec: Dictionary = _floor_decorations[pos]
					var origin := Vector2(rx + ts/2, ry + ts/2)
					var pts := PackedVector2Array([
						origin + dec["pts"][0],
						origin + dec["pts"][1],
						origin + dec["pts"][2]
					])
					draw_polyline(pts, Color(0.25, 0.20, 0.10, 0.45), 1.0)
					

				elif level_idx == 2 and _floor_decorations.has(pos):
					var dec: Dictionary = _floor_decorations[pos]
					var origin := Vector2(rx + ts/2, ry + ts/2)
					draw_circle(origin + dec["offsets"][0], dec["sizes"][0], col.darkened(0.18))
					draw_circle(origin + dec["offsets"][1], dec["sizes"][1], col.darkened(0.24))
					

				elif level_idx == 3:
					var bw: float = float(ts) / 3.0
					var dc := col.darkened(0.18)
					var lc := col.lightened(0.10)

					draw_line(Vector2(rx + bw, ry), Vector2(rx + bw, ry + ts), dc, 0.8)
					draw_line(Vector2(rx + bw * 2, ry), Vector2(rx + bw * 2, ry + ts), dc, 0.8)

					if _floor_decorations.has(pos):
						var dec: Dictionary = _floor_decorations[pos]
						if dec["has_scratch"]:
							draw_line(Vector2(rx + bw * 1.5, ry + 6), Vector2(rx + bw * 1.5, ry + ts - 3), lc.lerp(col, 0.6), 0.5)
						

				elif level_idx == 4 and _floor_decorations.has(pos):
					var dec: Dictionary = _floor_decorations[pos]
					var spos: Vector2 = Vector2(rx + ts/2, ry + ts/2) + dec["offset"]
					draw_circle(spos, dec["radius"], dec["color"])


func _draw_cave_crystals() -> void:
	var ts: int = tile_size
	for cell: Vector2i in _crystal_cells:
		var cx: float = float(cell.x * ts + ts / 2)
		var cy: float = float(cell.y * ts + ts / 2)
		var pulse: float = sin(_t * 2.2 + float(cell.x) * 0.7 + float(cell.y) * 0.5) * 0.5 + 0.5
		var alpha: float = 0.25 + pulse * 0.35

		draw_circle(Vector2(cx, cy), 6.5 + pulse * 2.5, Color(0.55, 0.15, 0.95, alpha * 0.32))
		draw_circle(Vector2(cx, cy), 4.5 + pulse * 1.0, Color(0.65, 0.25, 0.95, alpha * 0.50))

		draw_circle(Vector2(cx, cy), 2.5, Color(0.85, 0.50, 1.00, alpha))


func _draw_void_grid() -> void:
	var ts: int = tile_size
	for yi in maze.size():
		var row: Array = maze[yi]
		for xi in row.size():
			if int(row[xi]) != MazeGenerator.WALL:
				var rx: float = float(xi * ts)
				var ry: float = float(yi * ts)
				var glow: float = (sin(_t * 1.8 + float(xi) * 0.28 + float(yi) * 0.41) * 0.5 + 0.5) * 0.18
				var c: Color    = Color(0.0, 0.65 + glow, 1.0, 0.28 + glow)

				draw_line(Vector2(rx, ry),          Vector2(rx + ts, ry),    c, 1.0)
				draw_line(Vector2(rx, ry),          Vector2(rx, ry + ts),    c, 1.0)


func _draw_particles() -> void:
	if _particles.is_empty(): return
	match level_idx:
		0:
			for p in _particles:
				var alpha := (sin(_t * 3.0 + p["pos"].x) * 0.4 + 0.6) * 0.7
				var col := Color(0.85, 0.98, 0.15, alpha)
				var glow_col := Color(0.85, 0.98, 0.15, alpha * 0.35)
				draw_circle(p["pos"], p["size"] + 3.0, glow_col)
				draw_circle(p["pos"], p["size"], col)
		1:
			for p in _particles:
				var alpha := (sin(_t * 4.0 + p["pos"].y) * 0.3 + 0.7) * 0.8
				var col := Color(0.98, 0.55, 0.15, alpha)
				var glow_col := Color(0.98, 0.25, 0.05, alpha * 0.3)
				draw_circle(p["pos"], p["size"] + 2.0, glow_col)
				draw_circle(p["pos"], p["size"], col)
		2:
			for p in _particles:
				var alpha := (sin(_t * 2.5 + p["pos"].x * 0.05) * 0.35 + 0.65) * 0.6
				var col := Color(0.35, 0.82, 1.00, alpha) if int(p["pos"].x) % 2 == 0 else Color(0.82, 0.35, 1.00, alpha)
				draw_circle(p["pos"], p["size"], col)
		3:
			for p in _particles:
				var alpha := (cos(_t * 1.8 + p["pos"].x * 0.05) * 0.4 + 0.4) * 0.6
				var col := Color(0.75, 0.20, 0.95, alpha)
				var glow_col := Color(0.40, 0.10, 0.90, alpha * 0.4)
				draw_circle(p["pos"], p["size"] + 4.0, glow_col)
				draw_circle(p["pos"], p["size"], col)
