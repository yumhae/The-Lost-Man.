


class_name MazeGenerator

const WALL  := 1
const FLOOR := 0
const START := 2
const EXIT  := 3



static var extra_openings_pct: float = 0.12




static func generate(width: int, height: int, rng_seed: int) -> Array:
	var w: int = width  + (1 if width  % 2 == 0 else 0)
	var h: int = height + (1 if height % 2 == 0 else 0)


	var grid: Array = []
	for y in h:
		var row: Array = []
		for _x in w:
			row.append(WALL)
		grid.append(row)

	var rng := RandomNumberGenerator.new()
	rng.seed = rng_seed


	grid[1][1] = FLOOR
	var stack: Array[Vector2i] = [Vector2i(1, 1)]

	while not stack.is_empty():
		var cur: Vector2i = stack.back()
		var nbrs := _wall_neighbors(grid, cur, w, h)
		if nbrs.is_empty():
			stack.pop_back()
		else:
			var nxt: Vector2i = nbrs[rng.randi() % nbrs.size()]

			grid[(cur.y + nxt.y) / 2][(cur.x + nxt.x) / 2] = FLOOR
			grid[nxt.y][nxt.x] = FLOOR
			stack.append(nxt)


	_add_extra_openings(grid, w, h, rng)


	grid[1][1]         = START
	grid[h - 2][w - 2] = EXIT
	return grid


static func get_start(grid: Array) -> Vector2i:
	for y in grid.size():
		for x in grid[y].size():
			if grid[y][x] == START:
				return Vector2i(x, y)
	return Vector2i(1, 1)


static func get_exit(grid: Array) -> Vector2i:
	for y in grid.size():
		for x in grid[y].size():
			if grid[y][x] == EXIT:
				return Vector2i(x, y)
	return Vector2i(grid[0].size() - 2, grid.size() - 2)


static func _wall_neighbors(grid: Array, pos: Vector2i, w: int, h: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for d: Vector2i in [Vector2i(0,-2), Vector2i(2,0), Vector2i(0,2), Vector2i(-2,0)]:
		var n := pos + d
		if n.x > 0 and n.x < w-1 and n.y > 0 and n.y < h-1:
			if grid[n.y][n.x] == WALL:
				result.append(n)
	return result




static func _add_extra_openings(grid: Array, w: int, h: int, rng: RandomNumberGenerator) -> void:

	var candidates: Array[Vector2i] = []
	for y in range(1, h - 1):
		for x in range(1, w - 1):
			if grid[y][x] != WALL:
				continue

			if x - 1 >= 1 and x + 1 < w - 1:
				if grid[y][x - 1] != WALL and grid[y][x + 1] != WALL:
					candidates.append(Vector2i(x, y))
					continue

			if y - 1 >= 1 and y + 1 < h - 1:
				if grid[y - 1][x] != WALL and grid[y + 1][x] != WALL:
					candidates.append(Vector2i(x, y))


	var to_remove: int = int(float(candidates.size()) * extra_openings_pct)

	for i in range(candidates.size() - 1, 0, -1):
		var j: int = rng.randi() % (i + 1)
		var tmp: Vector2i = candidates[i]
		candidates[i] = candidates[j]
		candidates[j] = tmp

	for i in to_remove:
		var c: Vector2i = candidates[i]
		grid[c.y][c.x] = FLOOR
