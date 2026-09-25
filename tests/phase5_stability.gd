extends SceneTree

const MainScene := preload("res://scenes/main.tscn")
const SEED_SWEEP_COUNT := 100

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var game := MainScene.instantiate()
	root.add_child(game)
	await process_frame

	_check_seed_sweep(game)
	_check_balance_envelope(game)
	_check_last_moment_actions(game)
	_check_repeated_match_resets(game)
	_check_camera_culling_bounds(game)

	game.queue_free()
	await process_frame

	if failures.is_empty():
		print("Phase 5 stability tests passed (%d generated rounds)." % SEED_SWEEP_COUNT)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _check_seed_sweep(game: Node) -> void:
	var expected_floor_count: int = ceili(game.YARD_RECT.size.x / game.WORLD_TILE_SIZE) * ceili(game.YARD_RECT.size.y / game.WORLD_TILE_SIZE)
	for seed in SEED_SWEEP_COUNT:
		game.start_match(seed % game.target_points.size(), 120.0, seed)
		_assert(game.floor_tile_indices.size() == expected_floor_count, "seed %d should fill every floor cell" % seed)
		_assert(game.vegetation_positions.size() > 0, "seed %d should generate vegetation" % seed)
		_assert(game.YARD_RECT.has_point(game.dog_pos) and game.YARD_RECT.has_point(game.owner_pos), "seed %d should keep spawns inside yard" % seed)
		for obstacle_index in game.obstacles.size():
			var obstacle: Rect2 = game.obstacles[obstacle_index]
			_assert(game.YARD_RECT.encloses(obstacle), "seed %d obstacle should stay inside yard" % seed)
			_assert(not game._circle_intersects_rect(game.DOG_SPAWN, game.DOG_RADIUS, obstacle), "seed %d should keep dog spawn clear" % seed)
			_assert(not game._circle_intersects_rect(game.OWNER_SPAWN, game.OWNER_RADIUS, obstacle), "seed %d should keep owner spawn clear" % seed)
			for point in game.target_points:
				_assert(not game._circle_intersects_rect(point, game.INTERACT_RADIUS, obstacle), "seed %d should keep target interaction area clear" % seed)
			for other_index in range(obstacle_index + 1, game.obstacles.size()):
				_assert(not obstacle.intersects(game.obstacles[other_index]), "seed %d should not overlap obstacle collisions" % seed)
		for variant in game.floor_tile_indices:
			_assert(variant >= 0 and variant < game.FLOOR_TILE_SOURCES.size(), "seed %d should use a valid floor tile" % seed)
		for vegetation_index in game.vegetation_positions.size():
			_assert(game.YARD_RECT.has_point(game.vegetation_positions[vegetation_index]), "seed %d vegetation should stay in yard" % seed)
			_assert(game.vegetation_variants[vegetation_index] >= 0, "seed %d vegetation variant should be valid" % seed)


func _check_balance_envelope(game: Node) -> void:
	_assert(game.DOG_SPEED > game.OWNER_SPEED, "dog should retain its base speed advantage")
	var dash_distance: float = game.DOG_SPEED * game.DOG_DASH_SPEED_MULTIPLIER * game.DOG_DASH_DURATION
	var net_range: float = game.NET_SPEED * game.NET_LIFETIME
	_assert(dash_distance >= game.DOG_RADIUS * 6.0, "dash should create meaningful evasion distance")
	_assert(net_range > dash_distance * 2.5, "net should threaten beyond one dash distance")
	_assert(game.HOLD_SECONDS >= 1.0, "eat and clean should leave an interruption window")
	_assert(game.MATCH_SECONDS >= 90.0 and game.MATCH_SECONDS <= 180.0, "match duration should remain in quick-session range")


func _check_last_moment_actions(game: Node) -> void:
	game.start_match(0, 0.05, 5001)
	game.test_force_positions(game.target_pos, game.OWNER_SPAWN)
	game.eat_progress = game.HOLD_SECONDS - 0.02
	game.test_tick_interaction(0.03, true, false)
	game.test_tick_timer(0.10)
	_assert(game.result_title.begins_with("Dog Wins"), "completed eat action should beat timeout on the final frame")

	game.start_match(1, 120.0, 5002)
	game.test_force_positions(game.target_pos, game.OWNER_SPAWN)
	game.test_tick_interaction(0.8, true, false)
	game.test_register_catch()
	_assert(is_zero_approx(game.eat_progress), "catch should reliably interrupt partial eating")
	_assert(game.phase == game.Phase.PLAYING, "first catch should not prematurely end match")


func _check_repeated_match_resets(game: Node) -> void:
	for match_index in 12:
		game.start_match(match_index % game.target_points.size(), 120.0, 7000 + match_index)
		match match_index % 3:
			0:
				game.test_force_positions(game.target_pos, game.OWNER_SPAWN)
				game.test_tick_interaction(game.HOLD_SECONDS + 0.01, true, false)
			1:
				game.test_force_positions(game.DOG_SPAWN, game.target_pos)
				game.test_tick_interaction(game.HOLD_SECONDS + 0.01, false, true)
			2:
				game.test_tick_timer(121.0)
		_assert(game.phase == game.Phase.GAME_OVER, "match %d should reach a result" % match_index)
		game.start_match((match_index + 1) % game.target_points.size(), 120.0, 8000 + match_index)
		_assert(game.phase == game.Phase.PLAYING, "match %d rematch should return to play" % match_index)
		_assert(game.owner_catches == 0 and not game.net_active, "match %d rematch should clear combat state" % match_index)
		_assert(is_zero_approx(game.eat_progress) and is_zero_approx(game.clean_progress), "match %d rematch should clear interaction progress" % match_index)


func _check_camera_culling_bounds(game: Node) -> void:
	game.dog_pos = game.YARD_RECT.position + Vector2(20.0, 20.0)
	game.owner_pos = game.YARD_RECT.end - Vector2(20.0, 20.0)
	game.test_update_camera()
	var visible_rect: Rect2 = game.test_visible_world_rect()
	_assert(visible_rect.has_point(game.dog_pos), "visible world bounds should include dog")
	_assert(visible_rect.has_point(game.owner_pos), "visible world bounds should include owner")
	_assert(visible_rect.size.x > 0.0 and visible_rect.size.y > 0.0, "visible world bounds should remain valid")


func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
