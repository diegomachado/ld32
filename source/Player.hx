package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.util.FlxRandom;

import PlayState;

class Player extends FlxSprite
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
	public static inline var FART_RECOVER_RATE:Int = 1;

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
	var _canFartBoost = true;
	
	var _fartBoostTimer:FlxTimer = new FlxTimer();
	var _fartBoostTimerStarted = false;

	private var JUMP_KEYS = ["Z"];
	private var FART_KEYS = ["X"];
	private var LEFT_KEYS = ["LEFT"];
	private var RIGHT_KEYS = ["RIGHT"];
	private var DOWN_KEYS = ["DOWN"];

	public function new(x:Float, y:Float, state:PlayState)
	{
		levelState = state;
		
		super(x,y);
		
		loadGraphic(Reg.PLAYER_SPRITE, true, 32, 32);
		width = 10;
		height = 20;
		offset.set(10, 12);

		animation.add("idle", [0]);
		animation.add("walk", [1, 2, 3], 10, true);
		animation.add("fall", [4]);
		animation.add("jump", [5]);

		animation.play("idle");

		drag.x = DRAG;
		acceleration.y = GRAVITY;
		maxVelocity.set(MAX_WALK_SPEED, MAX_FALL_VELOCITY);

		fartFuel = FART_MAX_FUEL;

		FlxG.watch.add(this, "_onGround");
		FlxG.watch.add(this, "_canJump");
		FlxG.watch.add(this, "_canVariableJump");
		FlxG.watch.add(this, "_canFart");
		FlxG.watch.add(this, "fartFuel");
		FlxG.watch.add(this, "velocity");
		FlxG.watch.add(this, "acceleration");
	}

	override public function update()
	{
		_onGround = isTouching(FlxObject.FLOOR);

		walk();
		jump();
		fartJetpack();
		animate();

		super.update();
	}

	private function walk()
	{
		acceleration.x = 0;

		if(FlxG.keys.anyPressed(LEFT_KEYS.concat(RIGHT_KEYS)) && FlxG.keys.anyJustPressed(FART_KEYS) && _onGround)
		{
			var hasFartBoostFuel = fartFuel >= FART_BOOST_CONSUME;

			if(_canFartBoost && hasFartBoostFuel)
			{
				_fartBoostTimer.start(FART_BOOST_TIME, onFartBoostEnds, 1);
				maxVelocity.x = MAX_WALK_SPEED * (1 + FART_BOOST_PERCENTAGE / 100);
				fartFuel -= Std.int(FART_BOOST_CONSUME);
			}
		}

		if(FlxG.keys.anyPressed(LEFT_KEYS))
		{
			acceleration.x -= drag.x;
			flipX = true;
			offset.x = 11;
		}
		else if(FlxG.keys.anyPressed(RIGHT_KEYS))
		{
			acceleration.x += drag.x;
			flipX = false;
			offset.x = 10;
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
			velocity.y = -JUMP_SPEED;
			_canJump = false;
			_canVariableJump = true;
		}
		else if(FlxG.keys.anyPressed(JUMP_KEYS) && !_canJump && _canVariableJump)
		{
			if(!_variableJumpTimerStarted)
			{
				_variableJumpTimer.start(JUMP_TIME, onVariableJumpEnds, 1);
				_variableJumpTimerStarted = true;
			}

			velocity.y = -JUMP_SPEED;
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

		if(FlxG.keys.anyPressed(FART_KEYS) && _canFart && FlxRandom.chanceRoll(30))
		{
			velocity.y = -FART_POWER;
			fartFuel -= FART_CONSUME_RATE;
		}
		
		if(_onGround && fartFuelIncomplete)
		{
			fartFuel += FART_RECOVER_RATE;
		}
	}

	public function animate()
	{

		if(velocity.y >= 0)
			animation.play("jump");

		if(velocity.y < 0)
			animation.play("fall");
		
		if(velocity.x != 0 && _onGround)
			animation.play("walk");

	    if(velocity.x == 0 && velocity.y == 0)
	    	animation.play("idle");
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
		maxVelocity.x = MAX_WALK_SPEED;
		_canFartBoost = true;
	}

}