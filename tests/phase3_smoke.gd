extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var game := MainScene.instantiate()
	root.add_child(game)
	await process_frame

	_check_separate_discovery(game)
	_check_sniff_heat_bands(game)
	_check_sniff_cooldown(game)
	_check_sniff_has_no_directional_output(game)
	_check_restart_resets_information(game)
	_check_map_is_four_times_larger(game)
	_check_camera_keeps_both_players_visible(game)
	_check_camera_zoom_changes_with_distance(game)
	game.queue_free()
	await process_frame

	if failures.is_empty():
		print("Phase 3 smoke tests passed.")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _check_separate_discovery(game: Node) -> void:
	game.start_match(0, 120.0)
	game.test_force_positions(Vector2(1130.0, 620.0), game.target_pos)
	_assert(not game.dog_target_discovered, "owner discovery should not mark dog as discoverer")
	_assert(game.owner_target_discovered, "owner should discover target by proximity")
	game.test_force_positions(game.target_pos, Vector2(1130.0, 620.0))
	_assert(game.dog_target_discovered, "dog should discover target by proximity")


func _check_sniff_heat_bands(game: Node) -> void:
	var offsets := [
		[Vector2(200.0, 0.0), "HOT"],
		[Vector2(400.0, 0.0), "WARM"],
		[Vector2(800.0, 0.0), "FAINT"],
		[Vector2(1200.0, 0.0), "COLD"],
	]
	for sample in offsets:
		game.start_match(5, 120.0)
		game.dog_pos = game.target_pos + sample[0]
		_assert(game.test_sniff(), "sniff should start when ready")
		_assert(game.sniff_heat_level == sample[1], "sniff band should be %s" % sample[1])


func _check_sniff_cooldown(game: Node) -> void:
	game.start_match(5, 120.0)
	_assert(game.test_sniff(), "ready sniff should activate")
	_assert(not game.test_sniff(), "sniff should be blocked during cooldown")
	game.test_tick_combat(game.SNIFF_COOLDOWN + 0.01)
	_assert(game.test_sniff(), "sniff should reactivate after cooldown")


func _check_sniff_has_no_directional_output(game: Node) -> void:
	game.start_match(5, 120.0)
	game.dog_pos = game.target_pos + Vector2(400.0, 0.0)
	game.test_sniff()
	var horizontal_heat: String = game.sniff_heat_level
	game.start_match(5, 120.0)
	game.dog_pos = game.target_pos + Vector2(0.0, 400.0)
	game.test_sniff()
	_assert(game.sniff_heat_level == horizontal_heat, "equal distances should give equal heat regardless of direction")


func _check_restart_resets_information(game: Node) -> void:
	game.start_match(0, 120.0)
	game.test_force_positions(game.target_pos, game.target_pos)
	game.test_sniff()
	game.start_match(1, 120.0)
	_assert(not game.dog_target_discovered and not game.owner_target_discovered, "restart should reset both discovery states")
	_assert(game.sniff_heat_level.is_empty(), "restart should clear prior sniff feedback")
	_assert(is_zero_approx(game.sniff_cooldown_left), "restart should reset sniff cooldown")


func _check_map_is_four_times_larger(game: Node) -> void:
	var old_area: float = game.LEGACY_YARD_SIZE.x * game.LEGACY_YARD_SIZE.y
	var new_area: float = game.YARD_RECT.size.x * game.YARD_RECT.size.y
	_assert(is_equal_approx(new_area, old_area * 4.0), "yard area should be four times the original")
	for point in game.target_points:
		_assert(game.YARD_RECT.has_point(point), "every target point should stay inside enlarged yard")
	for obstacle in game.obstacles:
		_assert(game.YARD_RECT.encloses(obstacle), "every obstacle should stay inside enlarged yard")


func _check_camera_keeps_both_players_visible(game: Node) -> void:
	game.dog_pos = game.YARD_RECT.position + Vector2(game.DOG_RADIUS, game.DOG_RADIUS)
	game.owner_pos = game.YARD_RECT.end - Vector2(game.OWNER_RADIUS, game.OWNER_RADIUS)
	game.test_update_camera()
	for player_pos in [game.dog_pos, game.owner_pos]:
		var screen_pos: Vector2 = game.test_world_to_screen(player_pos)
		_assert(screen_pos.x >= 0.0 and screen_pos.x <= game.VIEW_SIZE.x, "camera should keep player within horizontal view")
		_assert(screen_pos.y >= 0.0 and screen_pos.y <= game.VIEW_SIZE.y, "camera should keep player within vertical view")


func _check_camera_zoom_changes_with_distance(game: Node) -> void:
	game.dog_pos = Vector2(1000.0, 650.0)
	game.owner_pos = Vector2(1050.0, 650.0)
	game.test_update_camera()
	var close_zoom: float = game.camera_zoom
	game.dog_pos = game.YARD_RECT.position + Vector2(20.0, 20.0)
	game.owner_pos = game.YARD_RECT.end - Vector2(20.0, 20.0)
	game.test_update_camera()
	_assert(game.camera_zoom < close_zoom, "camera should zoom out when players separate")


func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
