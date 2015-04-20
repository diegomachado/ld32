package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.effects.FlxFlicker;
import flixel.util.FlxColor;

class MenuState extends FlxState
{
	var _pressZX:FlxText;

	override public function create()
	{
		FlxG.sound.playMusic("assets/music/music.mp3", 0.8, true);

		var background = new FlxSprite(0, 0);
		background.loadGraphic("assets/images/menu-bg.png", false);
		add(background);

		_pressZX = new FlxText(0, 165, 320);
		_pressZX.text = "Press Z or X to start";
		_pressZX.setFormat(null, 12, FlxColor.BLACK, "center");
		add(_pressZX);

		FlxFlicker.flicker(_pressZX, 10, 0.25);

		super.create();
	}
	
	override public function update()
	{
		if(FlxG.keys.anyJustPressed(["Z", "X"]))
			FlxG.switchState(new PlayState());

		super.update();
	}	

	override public function destroy()
	{
		super.destroy();
	}
}