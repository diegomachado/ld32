package;

import flixel.addons.tile.FlxTilemapExt;
import flixel.addons.tile.FlxTileSpecial;

import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledTile;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectGroup;

import TiledAnimations;

class TiledLevel extends TiledMap
{
	public var tiles:FlxTilemapExt = new FlxTilemapExt();

	public function new(tiledLevel:String)
	{
		super(tiledLevel);

		var tilesetAnimations = TiledAnimations.getTilesetAnimations(tiledLevel);

		for (layer in layers)
		{
			if(layer.name == "tiles")
			{
				tiles.widthInTiles = width;
				tiles.heightInTiles = height;
				tiles.loadMap(layer.tileArray, 
							  Reg.BASE_TILESHEET, 
							  tilesets["base"].tileWidth, 
							  tilesets["base"].tileHeight, 
							  0, 1, 1, 2);

				loadTilemapSpecialTiles(tiles, layer, tilesetAnimations["base"]);

				var floorLeftSlopes = [7];
				var floorRightSlopes = [8];
				var ceilLeftSlopes = [9];
				var ceilRightSlopes = [10];

				tiles.setSlopes(floorLeftSlopes, floorRightSlopes, ceilLeftSlopes, ceilRightSlopes);

				var clouds = [14, 15];
				tiles.setClouds(clouds);
			}
		}
	}

	public function loadTilemapSpecialTiles(tiles:FlxTilemapExt, layer:TiledLayer, animations:Map<Int, Animation>)
	{
		var specialTiles:Array<FlxTileSpecial> = new Array<FlxTileSpecial>();
		var tile:TiledTile;
		var specialTile:FlxTileSpecial;

		for (i in 0...layer.tiles.length) 
		{ 
			tile = layer.tiles[i];
			
			if (tile != null && isSpecialTile(tile, animations)) 
			{
				specialTile = new FlxTileSpecial(tile.tilesetID, tile.isFlipHorizontally, tile.isFlipVertically, tile.rotate);
			
				if(animations.exists(tile.tilesetID))
				{
					var animation = animations.get(tile.tilesetID);
					specialTile.addAnimation(animation.frames, animation.frameRate);
				}

				specialTiles[i] = specialTile;
			} 
			else 
			{
				specialTiles[i] = null;
			}
		}

		tiles.setSpecialTiles(specialTiles);
	}

	public function loadObjects(state:PlayState)
	{
		for (group in objectGroups)
		{
			for (object in group.objects)
			{
				loadObject(object, group, state);
			}
		}
	}

	private function loadObject(object:TiledObject, group:TiledObjectGroup, state:PlayState)
	{
		var x:Int = object.x;
		var y:Int = object.y;
		var width:Int = object.width;
		var height:Int = object.height;
		
		// objects in tiled are aligned bottom-left (top-left in flixel)
		if (object.gid != -1)
			y -= group.map.getGidOwner(object.gid).tileHeight;

		var type = object.type.toLowerCase();
		var name = object.name.toLowerCase();

		switch (type)
		{
			case "player":
				var player = new Player(x, y, state);
				state.player = player;
				state.add(player);
		}
	}

	private inline function isSpecialTile(tile:TiledTile, animations:Dynamic):Bool 
	{
		return (tile.isFlipHorizontally || 
				tile.isFlipVertically || 
				tile.rotate != FlxTileSpecial.ROTATE_0 ||
				animations.exists(tile.tilesetID));
	}
}