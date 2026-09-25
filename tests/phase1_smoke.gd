extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var game := MainScene.instantiate()
	root.add_child(game)
	await process_frame

	_check_spawn_points(game)
	_check_dog_win(game)
	_check_owner_clean_win(game)
	_check_timeout_win(game)
	_check_cancel_interaction(game)
	_check_restart_state(game)
	game.queue_free()
	await process_frame

	if failures.is_empty():
		print("Phase 1 smoke tests passed.")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _check_spawn_points(game: Node) -> void:
	for index in game.target_points.size():
		game.start_match(index, 120.0)
		_assert(game.YARD_RECT.has_point(game.target_pos), "target %d is outside yard" % index)
		for obstacle in game.obstacles:
			_assert(not game._circle_intersects_rect(game.target_pos, game.INTERACT_RADIUS, obstacle), "target %d interaction radius overlaps obstacle" % index)


func _check_dog_win(game: Node) -> void:
	game.start_match(0, 120.0)
	game.test_force_positions(game.target_pos, Vector2(1130.0, 620.0))
	game.test_tick_interaction(1.6, true, false)
	_assert(game.phase == game.Phase.GAME_OVER, "dog hold should end match")
	_assert(game.result_title.begins_with("Dog Wins"), "dog hold should produce dog win")


func _check_owner_clean_win(game: Node) -> void:
	game.start_match(1, 120.0)
	game.test_force_positions(Vector2(150.0, 620.0), game.target_pos)
	game.test_tick_interaction(1.6, false, true)
	_assert(game.phase == game.Phase.GAME_OVER, "owner hold should end match")
	_assert(game.result_title.begins_with("Owner Wins"), "owner clean should produce owner win")


func _check_timeout_win(game: Node) -> void:
	game.start_match(2, 0.1)
	game.test_tick_timer(0.2)
	_assert(game.phase == game.Phase.GAME_OVER, "timer reaching zero should end match")
	_assert(game.result_title.begins_with("Owner Wins"), "timeout should produce owner win")


func _check_cancel_interaction(game: Node) -> void:
	game.start_match(3, 120.0)
	game.test_force_positions(game.target_pos, Vector2(1130.0, 620.0))
	game.test_tick_interaction(0.8, true, false)
	game.test_tick_interaction(0.1, false, false)
	_assert(is_zero_approx(game.eat_progress), "releasing eat should reset progress")
	game.test_tick_interaction(0.8, true, false)
	_assert(game.phase == game.Phase.PLAYING, "reset progress should prevent early dog win")


func _check_restart_state(game: Node) -> void:
	game.start_match(4, 42.0)
	_assert(game.phase == game.Phase.PLAYING, "restart should return to playing")
	_assert(not game.target_discovered, "restart should hide target")
	_assert(is_equal_approx(game.time_left, 42.0), "restart should apply forced timer")


func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
