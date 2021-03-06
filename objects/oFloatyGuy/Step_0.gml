// Idle
function patrol() {
	if (!Player.isMoving) {
		return;
	}
	
	patrol_angle += patrol_dir * PATROL_SPEED
	targetPosX = xstart + dcos(patrol_angle) * PATROL_RADIUS_X
	targetPosY = ystart - dsin(patrol_angle) * PATROL_RADIUS_Y
	
	if (targetPosX > x) {
		image_xscale = 1
	} else if (targetPosX < x) {
		image_xscale = -1
	}
	
	if (stateTimer > PATROL_STATE_TIME and abs(Player.x - x) < aggro_range_x and abs(Player.y - y) < aggro_range_y) {
		stateTimer = 0
		state = floatystates.aggro; // Switch states
		sprite_index = FloatyHover
		audio_play_sound_at(floaty_aggro, x, y, 0, 200, 400, 1, false, 15)
		// start floaty hum
		audio_play_sound_at(floaty_hum, x, y, 0, 200, 400, 1, true, 10)
		
		if (Player.x < x) {
			image_xscale = -1
		} else {
			image_xscale = 1	
		}
	}
}

// Swoop
function aggro() {
	if (!Player.isMoving) {
		return;
	}
	
	if (stateTimer > AGGRO_STATE_TIME) {
		stateTimer = 0
		state = floatystates.shoot
		// ==== RIP floaty guy shoot animation
		// sprite_index = FloatyShoot
		// image_index = 0
		// stop floaty hum
		audio_stop_sound(floaty_hum)
	}
}

function shoot() {
	if (!Player.isMoving) {
		return;
	}
	
	if (stateTimer == SHOOT_DELAY or stateTimer == SHOOT_DELAY_2) {
		var pew = instance_create_layer(x, y, layer, oFloatyGuyAttack)
		if (image_xscale > 0) {
			pew.shootSpeed = 1
		} else {
			pew.shootSpeed = -1
		}
	}
	
	if (stateTimer > SHOOT_STATE_TIME) {
		stateTimer = 0
		state = floatystates.patrol
	}
}

if (Player.isMoving) {
	stateTimer += 1
	image_speed = 1
} else {
	image_speed = 0
}

// move
if (Player.isMoving) {
	var newX = x
	var newY = y
	dir = point_direction(x, y, targetPosX, targetPosY);
	dist = point_distance(x, y, targetPosX, targetPosY);
	if (dist > speed_scale) {
		newX = x + dcos(dir) * speed_scale + knockbackX
		newY = y - dsin(dir) * speed_scale + knockbackY
	} else {
		newX = targetPosX + knockbackX
		newY = targetPosY + knockbackY
	}
	if (!place_meeting(newX, y, oWallBase)) {
		x = newX	
	}
	if (!place_meeting(x, newY, oWallBase)) {
		y = newY
	}
	
	// Recover from knockback
	if (abs(knockbackX) > KNOCKBACK_RECOVERY) {
		knockbackX -= sign(knockbackX) * KNOCKBACK_RECOVERY
	} else {
		knockbackX = 0	
	}
	if (abs(knockbackY) > KNOCKBACK_RECOVERY) {
		knockbackY -= sign(knockbackY) * KNOCKBACK_RECOVERY
	} else {
		knockbackY = 0
	}
}

switch (state) {
	case floatystates.patrol: patrol(); break;
	case floatystates.aggro: aggro(); break;
	case floatystates.shoot: shoot(); break;
}

//if (Player.EMBUSH) {
//	instance_destroy(self);
//}
