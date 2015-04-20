package;

import flixel.FlxG;
import flixel.FlxObject;

import PlayState;

class Spikes extends FlxObject
{
	public function new(x:Float, y:Float, width:Int, height:Int)
	{
		super(x,y);

		this.width = width;
		this.height = height;
	}
}