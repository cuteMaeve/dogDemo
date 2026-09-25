extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var game := MainScene.instantiate()
	root.add_child(game)
	await process_frame

	_check_visual_assets(game)
	_check_audio_setup(game)
	_check_intro_and_rematch_state(game)
	_check_controlled_random_generation(game)
	_check_obstacle_layout_safety(game)
	_check_vegetation_coverage_and_reaction(game)

	game.queue_free()
	await process_frame

	if failures.is_empty():
		print("Phase 4 smoke tests passed.")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _check_visual_assets(game: Node) -> void:
	_assert(game.DOG_TEXTURE.get_size() == Vector2(32.0, 16.0), "dog sprite sheet should load")
	_assert(game.OWNER_WALK_TEXTURE.get_size() == Vector2(64.0, 64.0), "owner walk sprite sheet should load")
	_assert(game.FLOOR_TEXTURE.get_size() == Vector2(352.0, 417.0), "floor tileset should load")
	_assert(game.NATURE_TEXTURE.get_size() == Vector2(384.0, 336.0), "nature tileset should load")
	_assert(game.NET_TEXTURE.get_size() == Vector2(33.0, 25.0), "net sprite should load")
	_assert(game.UI_PANEL_TEXTURE.get_size() == Vector2(16.0, 16.0), "wood UI panel should load")


func _check_audio_setup(game: Node) -> void:
	_assert(game.music_player != null, "music player should exist")
	_assert(game.music_player.stream == game.MUSIC_STREAM, "music player should use selected soundtrack")
	_assert(game.sfx_players.size() == 3, "sound pool should contain three players")
	for player in game.sfx_players:
		_assert(player is AudioStreamPlayer, "sound pool entries should be audio players")


func _check_intro_and_rematch_state(game: Node) -> void:
	_assert(game.intro_time_left > 0.0, "match should begin with an intro countdown")
	game.intro_time_left = 0.0
	game.start_match(2, 42.0)
	_assert(is_equal_approx(game.intro_time_left, game.INTRO_DURATION), "quick rematch should restore intro countdown")
	_assert(is_equal_approx(game.time_left, 42.0), "quick rematch should preserve requested match time")
	_assert(game.phase == game.Phase.PLAYING, "quick rematch should return to playing state")


func _check_controlled_random_generation(game: Node) -> void:
	game.start_match(0, 120.0, 13579)
	var first_floor: PackedInt32Array = game.floor_tile_indices.duplicate()
	var first_kinds: PackedInt32Array = game.obstacle_kinds.duplicate()
	var first_positions: Array[Vector2] = game.vegetation_positions.duplicate()
	var first_layout: int = game.obstacle_layout_index
	var used_floor_variants := {}
	for variant in first_floor:
		used_floor_variants[variant] = true
	_assert(used_floor_variants.size() >= 3, "floor generation should mix at least three tile variants")
	_assert(not game.FLOOR_TILE_SOURCES.has(Rect2(80.0, 208.0, 16.0, 16.0)), "floor generation should exclude the mismatched green transition tile")
	_assert(not game.FLOOR_TILE_SOURCES.has(Rect2(48.0, 208.0, 16.0, 16.0)), "floor generation should exclude the second green transition tile")
	for source in game.TREE_SOURCES:
		_assert(source.size == Vector2(32.0, 32.0), "tree crops should contain exactly one 32x32 tree")
	for source in game.STUMP_SOURCES:
		_assert(source.size == Vector2(32.0, 32.0), "stump crops should contain exactly one 32x32 stump")
	for source in game.ROCK_SOURCES:
		_assert(source.size in [Vector2(32.0, 32.0), Vector2(48.0, 48.0)], "rock crops should contain one complete rock without the following atlas row")
	game.start_match(0, 120.0, 13579)
	_assert(game.floor_tile_indices == first_floor, "same seed should reproduce floor tiles")
	_assert(game.obstacle_kinds == first_kinds and game.obstacle_layout_index == first_layout, "same seed should reproduce obstacle layout")
	_assert(game.vegetation_positions == first_positions, "same seed should reproduce vegetation positions")
	game.start_match(0, 120.0, 24680)
	_assert(game.floor_tile_indices != first_floor, "different seed should change floor tiles")
	_assert(game.vegetation_positions != first_positions, "different seed should change vegetation positions")


func _check_obstacle_layout_safety(game: Node) -> void:
	var observed_layouts := {}
	var observed_kinds := {}
	for seed in range(30):
		game.start_match(seed % game.target_points.size(), 120.0, seed + 1000)
		observed_layouts[game.obstacle_layout_index] = true
		for kind in game.obstacle_kinds:
			observed_kinds[kind] = true
		for point in game.target_points:
			for obstacle in game.obstacles:
				_assert(not game._circle_intersects_rect(point, game.INTERACT_RADIUS, obstacle), "controlled obstacle layout should keep every target accessible")
	_assert(observed_layouts.size() == game.obstacle_layouts.size(), "seed sample should exercise every validated obstacle layout")
	_assert(observed_kinds.size() == 3, "seed sample should exercise trees, rocks, and stumps")


func _check_vegetation_coverage_and_reaction(game: Node) -> void:
	game.start_match(0, 120.0, 424242)
	var columns: int = ceili(game.YARD_RECT.size.x / game.WORLD_TILE_SIZE)
	var rows: int = ceili(game.YARD_RECT.size.y / game.WORLD_TILE_SIZE)
	var coverage: float = float(game.vegetation_positions.size()) / float(columns * rows)
	_assert(coverage >= 0.58 and coverage <= 0.61, "vegetation coverage should stay near sixty percent")
	_assert(not game.vegetation_positions.is_empty(), "vegetation generation should create patches")
	for position in game.vegetation_positions:
		for obstacle in game.obstacles:
			_assert(not obstacle.grow(game.VEGETATION_OBSTACLE_CLEARANCE).has_point(position), "vegetation should keep a clear visual gap around obstacles")
	game.dog_pos = game.vegetation_positions[0]
	game.test_tick_vegetation(0.2, true, false)
	_assert(game.vegetation_sway[0] > 0.0, "moving through vegetation should trigger sway")
	_assert(game.vegetation_sound_cooldown > 0.0, "vegetation contact should throttle rustle sound")


func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
