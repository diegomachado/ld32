package;

import haxe.xml.Fast;
import openfl.Assets;
import flixel.addons.tile.FlxTileSpecial;

class Animation 
{
	public var tileId:Int;
	public var frameRate:Float;
	public var frames:Array<Int> = new Array<Int>();

	public function new() {}

	public function toString()
	{
	    return 'TileId: $tileId | Framerate: $frameRate | Frames: $frames';
	}	
}

class TiledAnimations
{
	public static function getTilesetAnimations(data:Dynamic):Map<String, Map<Int, Animation>>
	{
		var source:Fast;

		if (Std.is(data, String)) 
			source = new Fast(Xml.parse(Assets.getText(data)));
		else if (Std.is(data, Xml)) 
			source = new Fast(data);
		else 
			throw "Unknown TMX map format.";

		var tilesetAnimations = new Map<String, Map<Int, Animation>>();
		source = source.node.map;

		for (ts in source.nodes.tileset) 
		{
			var tile = ts.nodes.tile;

			if(!tile.isEmpty())
			{
				var firstGID:Int;
				var animations = new Map<Int,Animation>();		

				for (tileset in source.nodes.tileset) 
				{
					firstGID = 0;
				
					if (tileset.has.firstgid) 
						firstGID = Std.parseInt(tileset.att.firstgid);

					for (t in tileset.nodes.tile) 
					{
						var anim = new Animation();

						for (a in t.nodes.animation) 
						{
							anim.tileId = Std.parseInt(t.att.id) + firstGID;
							
							for (f in a.nodes.frame) 
							{
								anim.frames.push(Std.parseInt(f.att.tileid) + firstGID);
								
								// Flixel is f/s, Tiled is ms/f
								anim.frameRate = 1 / Std.parseInt(f.att.duration) * 1000;
							}
						}
						
						animations.set(Std.parseInt(t.att.id) + firstGID, anim);
					}
				}

				tilesetAnimations.set(ts.att.name, animations);
			}
			else
			{
				tilesetAnimations.set(ts.att.name, new Map<Int, Animation>());
			}
		}
		
		return tilesetAnimations;
	}
}