package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.effects.FlxFlicker;
import flixel.util.FlxColor;

class WinState extends FlxState
{
	override public function create()
	{
		var background = new FlxSprite(0, 0);
		background.loadGraphic("assets/images/win-bg.png", false);
		add(background);

		super.create();
	}
	
	override public function update()
	{
		if(FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new MenuState());

		super.update();
	}	

	override public function destroy()
	{
		super.destroy();
	}
}