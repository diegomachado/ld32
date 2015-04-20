package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;
import flixel.util.FlxMath;
import flixel.util.FlxRandom;
import flixel.util.FlxSignal;
import flixel.util.FlxPoint;

class Saw extends FlxSprite
{
	private static inline var MOVE_SPEED:Float = 250;
	private var loop:Bool;
	private var initialPosition = new FlxPoint();

	public function new(x:Float, y:Float, xVelocity:Float, yVelocity:Float, loop:Bool)
	{
		super(x, y);

		initialPosition.set(x, y);

		loadRotatedGraphic("assets/images/saw.png", 16);
		animation.add("spin", [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0], 40, true);
		animation.play("spin");

		this.loop = loop;

		velocity.set(xVelocity, yVelocity);
	}

	public override function update()
	{
		super.update();

		if(loop)
		{
			if(velocity.x > 0)
			{
				if(x > FlxG.width)
					x = initialPosition.x;
			}
			else if(velocity.x < 0)
			{
				if(x + width < 0)
					x = initialPosition.x;
			}

			if(velocity.y > 0)
			{
				if(y > FlxG.height)
					y = initialPosition.y;
			}
			else if(velocity.y < 0)
			{
				if(y + height < 0)
					y = initialPosition.y;
			}

			if(y > FlxG.height + height)
			{
				y = initialPosition.y;
			}
		}


	}

	public override function destroy()
	{
		super.destroy();
	}
}