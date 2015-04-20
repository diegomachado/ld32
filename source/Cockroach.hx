package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.FlxRandom;

class Cockroach extends FlxSprite
{
	public static inline var WALK_SPEED:Int = 100;
	public static inline var MAX_WALK_SPEED:Int = 100;
	public static inline var MAX_FALL_VELOCITY:Int = 250;
	public static inline var DRAG:Int = 100;
	public static inline var GRAVITY:Int = 800;
	public static inline var SICK_TIME:Int = 2;

	public var isSick = false;
	var _sickTimer:FlxTimer = new FlxTimer();

	private var _isStatic:Bool;
	private var _isImmune:Bool;

	private var _startPatrol:Int;
	private var _endPatrol:Int;
	private var _goingToStart = true;

	private var _player:Player;

	public function new(x:Int, y:Int, isStatic:Bool, isImmune:Bool, startPatrol:Int, endPatrol:Int, player:Player)
	{
		super(x, y);

		_isStatic = isStatic;
		_isImmune = isImmune;
		_player = player;
		
		if(_isImmune)
			loadGraphic(Reg.IMMUNE_COCKROACH_SPRITE, true, 32, 32);
		else
			loadGraphic(Reg.COCKROACH_SPRITE, true, 32, 32);

		width = 18;
		height = 29;
		offset.set(8, 3);

		maxVelocity.set(MAX_WALK_SPEED, MAX_FALL_VELOCITY);
		acceleration.y = GRAVITY;

		_startPatrol = startPatrol;
		_endPatrol = endPatrol;

		animation.add("idle", [0, 1], 10, true);
		animation.add("walk", [2, 3, 4], 10, true);

		if(_isStatic)
			animation.play("idle");
		else
			animation.play("walk");
	}

	public override function update()
	{
		velocity.x = 0;

		if(!_isStatic)
		{
			if(_goingToStart)
			{
				velocity.x -= WALK_SPEED;
				flipX = true;

				if(x <=_startPatrol)
					_goingToStart = false;
			}
			else
			{
				velocity.x += WALK_SPEED;
				flipX = false;

				if((x - width / 2) >= _endPatrol)
					_goingToStart = true;
			}
		}
		else
		{
			if(_player.body.x > x)
				flipX = false;
			else 
				flipX = true;
		}

		super.update();
	}

	public function sick()
	{
		if(!isSick && !_isImmune)
		{
			FlxG.sound.play(Reg.SICK_SOUNDS_PATH + FlxRandom.intRanged(1, 3) + ".wav", 0.6);
			isSick = true;
			color = 0x11FF00;
			_sickTimer.start(SICK_TIME, onSickEnds, 1);
			maxVelocity.x = MAX_WALK_SPEED / 3;
		}
	}

	public function onSickEnds(timer:FlxTimer)
	{
		color = 0xFFFFFF;
		maxVelocity.x = MAX_WALK_SPEED;
	    isSick = false;
	}


	public override function destroy()
	{
		super.destroy();
	}
}