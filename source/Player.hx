package;

import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxRandom;
import flixel.util.FlxTimer;

import PlayState;

class Player extends FlxGroup
{
	public static inline var WALK_SPEED:Int = 600;
	public static inline var MAX_WALK_SPEED:Int = 150;
	public static inline var DRAG:Int = 700;
	public static inline var GRAVITY:Int = 800;
	public static inline var MAX_FALL_VELOCITY:Int = 250;
	
	public static inline var JUMP_SPEED:Int = 165;
	public static inline var JUMP_TIME:Float = 0.1;
	public static inline var GHOST_JUMP_TIME:Float = 0.1;

	public static inline var FART_POWER:Int = 120;
	public static inline var FART_MAX_FUEL:Int = 120;
	public static inline var FART_CONSUME_RATE:Int = 10;
	public static inline var FART_RECOVER_RATE:Int = 2;

	public static inline var FART_BOOST_PERCENTAGE:Int = 50;
	public static inline var FART_BOOST_TIME:Float = 0.4;
	public static inline var FART_BOOST_CONSUME:Float = FART_MAX_FUEL / 2;

	var levelState:PlayState;

	var _onGround = false;

	var _canJump = false;
	var _canVariableJump = false;
	var _variableJumpTimer:FlxTimer = new FlxTimer();
	var _variableJumpTimerStarted = false;

	var _ghostJumpTimer:FlxTimer = new FlxTimer();
	var _ghostJumpTimerStarted = false;

	public var fartFuel:Int;
	var _canFart = false;

	var _canFartMelee = true;
	var _fartMeleeTimer:FlxTimer = new FlxTimer();

	var _canFartBoost = true;
	var _fartBoostTimer:FlxTimer = new FlxTimer();

	public var body:FlxSprite;
	public var fartEmitter:FlxEmitter;

	private var JUMP_KEYS = ["Z"];
	private var FART_KEYS = ["X"];
	private var LEFT_KEYS = ["LEFT"];
	private var RIGHT_KEYS = ["RIGHT"];
	private var DOWN_KEYS = ["DOWN"];

	public function new(x:Float, y:Float)
	{
		super();
		
		body = new FlxSprite(x, y);
		body.loadGraphic(Reg.PLAYER_SPRITE, true, 32, 32);
		body.width = 10;
		body.height = 20;
		body.offset.set(10, 12);

		body.animation.add("idle", [0]);
		body.animation.add("walk", [1, 2, 3, 2], 10, true);
		body.animation.add("fall", [4]);
		body.animation.add("jump", [5]);

		body.animation.play("idle");

		body.drag.x = DRAG;
		body.acceleration.y = GRAVITY;
		body.maxVelocity.set(MAX_WALK_SPEED, MAX_FALL_VELOCITY);

		fartFuel = FART_MAX_FUEL;

		fartEmitter = new FlxEmitter(x / 2, y / 2);
		fartEmitter.setSize(8, 8);
		fartEmitter.setXSpeed(10, 20);
		fartEmitter.setYSpeed( -10, 10);
		fartEmitter.setAlpha(0.3, 1, 0, 0);
		fartEmitter.makeParticles("assets/images/fart-particles.png", 50, 16, true);

		add(fartEmitter);
		add(body);
	}

	override public function update()
	{
		_onGround = body.isTouching(FlxObject.FLOOR);

		walk();
		jump();
		fartJetpack();
		fartBoost();
		fartMelee();
		animate();

		if(body.flipX)
		{
			fartEmitter.setPosition(body.x + body.width / 2, body.y + body.height - 10);
			fartEmitter.setXSpeed(5 - body.velocity.x / 5, 40 - body.velocity.x / 5);
		}
		else
		{
			fartEmitter.setPosition(body.x + body.width / 2 - 8, body.y + body.height - 10);
			fartEmitter.setXSpeed(-40 - body.velocity.x / 5, 5 - body.velocity.x / 5);
		}

		if(_onGround)
		{
			fartEmitter.setYSpeed(-10, 10);
		}

		super.update();
	}

	private function walk()
	{
		body.acceleration.x = 0;

		if(FlxG.keys.anyPressed(LEFT_KEYS))
		{
			body.acceleration.x -= WALK_SPEED;
			body.flipX = true;
			body.offset.x = 11;
		}
		else if(FlxG.keys.anyPressed(RIGHT_KEYS))
		{
			body.acceleration.x += WALK_SPEED;
			body.flipX = false;
			body.offset.x = 10;
		}
	}

	private function jump()
	{
		if(_onGround)
		{
			_canJump = true;
			_canVariableJump = false;
			_ghostJumpTimer.start(GHOST_JUMP_TIME, onGhostJumpEnds, 1);
		}

		if(FlxG.keys.anyJustPressed(JUMP_KEYS) && _canJump)
		{
			body.velocity.y = -JUMP_SPEED;
			_canJump = false;
			_canVariableJump = true;
			playJumpSound();
		}
		else if(FlxG.keys.anyPressed(JUMP_KEYS) && !_canJump && _canVariableJump)
		{
			if(!_variableJumpTimerStarted)
			{
				_variableJumpTimer.start(JUMP_TIME, onVariableJumpEnds, 1);
				_variableJumpTimerStarted = true;
			}

			body.velocity.y = -JUMP_SPEED;
		}
		else if(FlxG.keys.anyJustReleased(JUMP_KEYS)) 
		{
			_canVariableJump = false;
		}
	}

	private function fartJetpack()
	{
		_canFart = (!_onGround && !_canJump && !_canVariableJump && (fartFuel > 0));
		var fartFuelIncomplete = (fartFuel < FART_MAX_FUEL);

		if(FlxG.keys.anyJustPressed(FART_KEYS))
		{
			fartEmitter.setYSpeed(10, 40);
			fartEmitter.start(false, 1, 0.0015, 100);
		}

		fartEmitter.on = false;

		if(FlxG.keys.anyPressed(FART_KEYS) && _canFart && FlxRandom.chanceRoll(30))
		{
			body.velocity.y = -FART_POWER;
			fartFuel -= FART_CONSUME_RATE;
			fartEmitter.on = true;
			playFartSound();
		}
		
		if(_onGround && fartFuelIncomplete)
		{
			fartEmitter.on = false;
			fartFuel += FART_RECOVER_RATE;
		}
	}

	private function fartBoost()
	{
		if(FlxG.keys.anyJustPressed(FART_KEYS))
			playFartSound();

		if(FlxG.keys.anyPressed(LEFT_KEYS.concat(RIGHT_KEYS)) && FlxG.keys.anyJustPressed(FART_KEYS) && _onGround)
		{
			var hasFartBoostFuel = fartFuel >= FART_BOOST_CONSUME;

			if(_canFartBoost && hasFartBoostFuel)
			{
				_fartBoostTimer.start(FART_BOOST_TIME, onFartBoostEnds, 1);
				body.maxVelocity.x = MAX_WALK_SPEED * (1 + FART_BOOST_PERCENTAGE / 100);
				fartFuel -= Std.int(FART_BOOST_CONSUME);
				fartEmitter.start(true, 1, 50);
			}
		}
	}

	private function fartMelee()
	{
		if(FlxG.keys.anyJustPressed(FART_KEYS) && _onGround)
		{
			var hasFartBoostFuel = fartFuel >= FART_BOOST_CONSUME;

			if(_canFartMelee && hasFartBoostFuel)
			{
				_fartMeleeTimer.start(FART_BOOST_TIME, onFartMeleeEnds, 1);
				fartFuel -= Std.int(FART_BOOST_CONSUME);
				fartEmitter.start(true, 1, 50);
			}
		}
	}

	public function animate()
	{
		if(body.velocity.y >= 0)
			body.animation.play("jump");

		if(body.velocity.y < 0)
			body.animation.play("fall");
		
		if(body.velocity.x != 0 && _onGround)
			body.animation.play("walk");

	    if(body.velocity.x == 0 && body.velocity.y == 0)
	    	body.animation.play("idle");
	}

	private function playJumpSound()
	{
		FlxG.sound.play(Reg.JUMP_SOUNDS_PATH + FlxRandom.intRanged(1, 3) + ".wav", 0.25);
	}

	public function playFartSound()
	{
		FlxG.sound.play(Reg.FART_SOUNDS_PATH + FlxRandom.intRanged(1, 3) + ".mp3", 0.5);
	}

	private function onVariableJumpEnds(timer:FlxTimer)
	{
	    _canJump = false;
	    _canVariableJump = false;
	    _variableJumpTimerStarted = false;
	}

	private function onGhostJumpEnds(timer:FlxTimer)
	{
		_canJump = false;
	}

	private function onFartBoostEnds(timer:FlxTimer)
	{
		body.maxVelocity.x = MAX_WALK_SPEED;
		_canFartBoost = true;
	}

	private function onFartMeleeEnds(timer:FlxTimer)
	{
		_canFartMelee = true;
	}
}