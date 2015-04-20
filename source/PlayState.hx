package;

import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import flixel.util.FlxTimer;

class PlayState extends FlxState
{
	public var tiledLevel:TiledLevel;
	public var player:Player;
	public var exit:Exit;
	
	public var spikes = new FlxGroup();
	public var saws = new FlxGroup();
	public var cockroaches = new FlxGroup();

	public var fartBar:FlxBar;
	public var deathEmitter:FlxEmitter;
	var _deathTimer:FlxTimer = new FlxTimer();

	var _levelId:Int;

	public function new(levelId = 0)
	{
		super();
		_levelId = levelId;
	}

	override public function create()
	{
		FlxG.state.bgColor = 0xffacbcd7;
		FlxG.camera.fade(FlxColor.BLACK, .33, true);

		var levelId:String;

		levelId = Reg.LEVEL_PATH + Reg.levels[_levelId] + Reg.LEVEL_EXT;

		tiledLevel = new TiledLevel(levelId);
		add(tiledLevel.background);
		add(tiledLevel.collidables);
		add(tiledLevel.furniture);
		add(tiledLevel.decoratives);

		tiledLevel.loadObjects(this);

		add(exit);
		
		if(spikes.length > 0)
			add(spikes);

		if(saws.length > 0)
			add(saws);

		if(cockroaches.length > 0)
			add(cockroaches);

		deathEmitter = new FlxEmitter(0, 0);
		deathEmitter.setSize(8, 8);
		deathEmitter.setXSpeed(-10, 10);
		deathEmitter.setYSpeed( -10, 10);
		deathEmitter.setAlpha(0.3, 1, 0, 0);
		deathEmitter.makeParticles("assets/images/fart-particles.png", 50, 16, true);
		add(deathEmitter);

		add(player);

		fartBar = new FlxBar(5, 5, FlxBar.FILL_LEFT_TO_RIGHT, 30, 10, player, "fartFuel");
		add(fartBar);

		FlxG.mouse.visible = false;

		super.create();
	}
	
	override public function update()
	{
		if(FlxG.keys.justPressed.R || (!player.body.alive && FlxG.keys.anyJustPressed(["Z", "X"])))
			restartLevel();

		super.update();

		FlxG.collide(tiledLevel.collidables, player.body);
		
		if(cockroaches.length > 0)
		{
			FlxG.collide(tiledLevel.collidables, cockroaches);
			FlxG.overlap(player.body, cockroaches, deathByCockroach);
			FlxG.overlap(player.fartEmitter, cockroaches, sickensCockroach);
		}

		if(spikes.length > 0)
			FlxG.overlap(player.body, spikes, death);		
			
		if(saws.length > 0)
			FlxG.overlap(player.body, saws, death);		

		FlxG.overlap(player.body, exit, win);		

		if(player.body.y + player.body.height > FlxG.height)
		{
			restartLevel();
		}
	}

	public function win(player:FlxObject, exit:FlxObject)
	{
		exit.destroy();

	    Reg.currentLevel++;

	    if(Std.int(Reg.currentLevel) == Reg.levels.length)
	    {
	    	FlxG.switchState(new WinState());
	    }
	    else
	    {
	    	FlxG.switchState(new PlayState(Reg.currentLevel));
	    }
	}

	public function death(playerBody:FlxSprite, hazard:FlxObject)
	{
		deathEmitter.setPosition(playerBody.x + playerBody.width / 2,  
								 playerBody.y + playerBody.height / 2);
		deathEmitter.start(true, 1);

		player.playFartSound();
		playerBody.kill();
		_deathTimer.start(1, onDeathTimerEnds, 1);
	}

	public function onDeathTimerEnds(timer:FlxTimer)
	{
		restartLevel();
	}

	public function restartLevel()
	{
		FlxG.switchState(new PlayState(Reg.currentLevel));
	}

	public function deathByCockroach(player:FlxSprite, cockroach:Cockroach)
	{
	    if(!cockroach.isSick)
	    	death(player, cockroach);
	}

	public function sickensCockroach(emitter:FlxObject, cockroach:Cockroach)
	{
		cockroach.sick();
	}

	override public function destroy()
	{
		tiledLevel.destroy();
		player.destroy();
		spikes.destroy();
		saws.destroy();
		cockroaches.destroy();
		deathEmitter.destroy();
		_deathTimer.destroy();

		super.destroy();
	}
}