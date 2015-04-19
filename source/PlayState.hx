package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import flixel.tile.FlxTilemap;

import flixel.ui.FlxBar;

import TiledLevel;

class PlayState extends FlxState
{
	public var tiledLevel:TiledLevel;
	public var player:Player;
	public var fartBar:FlxBar;

	override public function create()
	{
		FlxG.state.bgColor = 0xffacbcd7;
		
		tiledLevel = new TiledLevel(Reg.BASE_LEVEL);
		add(tiledLevel.tiles);
		tiledLevel.loadObjects(this);

		fartBar = new FlxBar(5, 5, FlxBar.FILL_LEFT_TO_RIGHT, 30, 10, player, "fartFuel");
		add(fartBar);

		FlxG.mouse.visible = false;

		super.create();
	}
	
	override public function update()
	{
		if(FlxG.keys.justPressed.R)
			FlxG.resetState();

		super.update();

		FlxG.collide(tiledLevel.tiles, player.body);
	}

	override public function destroy()
	{
		super.destroy();
	}
}