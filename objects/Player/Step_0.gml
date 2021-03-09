key_left = keyboard_check(vk_left);
key_right = keyboard_check(vk_right);
key_jump = keyboard_check_pressed(vk_up);
key_drop = keyboard_check(vk_down) and unlocks[0];
key_attack = keyboard_check_pressed(vk_space);

// Movement //////////////////////////////////////

var move = key_right - key_left;
var tryingToRun = key_right || key_left;
xSpeed = move * WALK_SPEED + xKnockback;

if (!dead) {
	//x = x + xSpeed
	if (check_for_wall(x + xSpeed, y, true)) {
		// grid align
		// x = round(x)
		while (!check_for_wall(x + sign(xSpeed), y, true)) {
			x += sign(xSpeed);	
		}
		xSpeed = 0;
		xKnockback = 0;
	} else {
		x += xSpeed;
		if (xKnockback > 0) {
			xKnockback = max(0, xKnockback - X_KNOCKBACK_RECOVERY)
		} else if (xKnockback < 0) {
			xKnockback = min(0, xKnockback + X_KNOCKBACK_RECOVERY)
		}
	}


	if (inAir) {
		ySpeed = min(TERMINAL_VELOCITY, ySpeed + GRAV);
		// if we hold the "drop" key, do not include one-way colliders
		if (check_for_wall(x, y + ySpeed, !key_drop)) {
			// grid align
			// y = round(y)
			while (!check_for_wall(x, y + sign(ySpeed), true)) {
				y += sign(ySpeed);	
			}
			if (ySpeed > 0) {
				// landed
				inAir = false;
				doubleJumped = false;
			}
			ySpeed = 0;
		} else {
			y += ySpeed;
		}
	} else {
		// Save last known position, but not on one-way walls
		if (step mod 10 == 0 && check_for_wall(x, y + 1, false)) {
			last_known_pos[0] = x;
			last_known_pos[1] = y;
		}
		ySpeed = 0;
		// if we hold the "drop" key, do not include one-way colliders
		if (!check_for_wall(x, y + 1, !key_drop)) {
			if (jumpBuffer == 0) {
				jumpBuffer = 5;
			}
			inAir = true;
		}
	}

	if (key_jump and ((!inAir or jumpBuffer > 0) or (unlocks[1] and !doubleJumped))) {
		if (!inAir) {
			inAir = true;
		} else {
			if (jumpBuffer > 0) {
				jumpBuffer = 0;
			} else {
				// TODO: make double jump functions
				inst = instance_create_layer(x, y, layer, oJumpCloud);
				with (inst) {
					image_xscale = Player.image_xscale;
					SPEED = Player.xSpeed;
				}
				audio_play_sound(dolby_digital_jump_deeper, 100, false)
				doubleJumped = true;
			}
		}
		ySpeed = JUMP_SPEED;
	}
} else {
	// if dead
	move = 0
	tryingToRun = false
	xSpeed = 0
	ySpeed = 0
}

isMoving = (xSpeed != 0) or (ySpeed != 0) or isMovingFromAttack

x = round(x)
y = round(y)

camera_set_view_pos(view_camera[0], x - 180, y - 240)
audio_listener_position(x, y, 0)
audio_listener_orientation(0, 0, 1, 0, -1, 0)

// Animation and facing ////////////////////////////////////

if (move > 0) {
	image_xscale = 1	
} else if (move < 0) {
	image_xscale = -1
}

if (!dead) {
	if (inAir) {
		if (ySpeed < 0) {
			sprite_index = LEAP_SPRITE;	
		} else {
			sprite_index = FALL_SPRITE;
		}
	} else {
		if (tryingToRun) {
			sprite_index = RUN_SPRITE;	
		} else {
			sprite_index = IDLE_SPRITE;
		}
	}
}

// Attack //////////////////////////////////////

if (isMoving) {
	chargeBar = min(CHARGE_BAR_MAX, chargeBar + (RECHARGE_RATE * (1 + unlocks[2])))
	if (chargeBar == CHARGE_BAR_MAX) {
		forceRecharge = false;	
	}
}

if (key_attack && !dead && !isMovingFromAttack && chargeBar > 0 && !forceRecharge) {
	var attack = instance_create_layer(x + 18 * sign(image_xscale), y - 12, layer, oPlayerAttack)
	attack.image_xscale = image_xscale + (unlocks[2] * sign(image_xscale) * 0.5)
	attack.image_yscale = image_yscale + (unlocks[2] * 0.1)
	
	isMovingFromAttack = true
	alarm_set(1, 15)
	
	chargeBar = max(0, chargeBar - ATTACK_DISCHARGE)
	if (chargeBar == 0) {
		forceRecharge = true
	}
}

if (isMoving) {
	invulnRemaining -= 1	
}

jumpBuffer = max(0, jumpBuffer - 1);

// increment step
step += 1
if (step == 60) {
	step = 0;
}


// TODO REMOVE THESE

if (keyboard_check(vk_f6)) {
	unlocks[0] = true
	unlocks[1] = true
	unlocks[2] = true
	unlocks[3] = true
}


if (keyboard_check(vk_f8)) {
	game_end();
}

if (keyboard_check(vk_f9)) {
	room_goto_next();
}
