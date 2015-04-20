package;

import flixel.tile.FlxTilemap;
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
	public var background = new FlxTilemapExt();
	public var collidables = new FlxTilemapExt();
	public var furniture = new FlxTilemapExt();
	public var decoratives = new FlxTilemapExt();

	public function new(tiledLevel:String)
	{
		super(tiledLevel);

		var tilesetAnimations = TiledAnimations.getTilesetAnimations(tiledLevel);

		for (layer in layers)
		{
			if(layer.name == "background")
			{
				background.widthInTiles = width;
				background.heightInTiles = height;
				background.loadMap(layer.tileArray, 
							  	   Reg.BASE_TILESHEET, 
							  	   tilesets["ld-32"].tileWidth, 
							  	   tilesets["ld-32"].tileHeight, 
							  	   0, 1, 1, 1);

				loadTilemapSpecialTiles(background, layer, tilesetAnimations["ld-32"]);
			}

			if(layer.name == "collidables")
			{
				collidables.widthInTiles = width;
				collidables.heightInTiles = height;
				collidables.loadMap(layer.tileArray, 
								    Reg.BASE_TILESHEET, 
								    tilesets["ld-32"].tileWidth, 
								    tilesets["ld-32"].tileHeight, 
								    0, 1, 1, 2);

				loadTilemapSpecialTiles(collidables, layer, tilesetAnimations["ld-32"]);

				var floorLeftSlopes = [7];
				var floorRightSlopes = [8];
				var ceilLeftSlopes = [9];
				var ceilRightSlopes = [10];

				collidables.setSlopes(floorLeftSlopes, floorRightSlopes, ceilLeftSlopes, ceilRightSlopes);

				var clouds = [14, 15];
				collidables.setClouds(clouds);
			}

			if(layer.name == "furniture")
			{
				furniture.widthInTiles = width;
				furniture.heightInTiles = height;
				furniture.loadMap(layer.tileArray, 
							  Reg.BASE_TILESHEET, 
							  tilesets["ld-32"].tileWidth, 
							  tilesets["ld-32"].tileHeight, 
							  0, 1, 1, 1);

				loadTilemapSpecialTiles(furniture, layer, tilesetAnimations["ld-32"]);
			}

			if(layer.name == "decoratives")
			{
				decoratives.widthInTiles = width;
				decoratives.heightInTiles = height;
				decoratives.loadMap(layer.tileArray, 
							  Reg.BASE_TILESHEET, 
							  tilesets["ld-32"].tileWidth, 
							  tilesets["ld-32"].tileHeight, 
							  0, 1, 1, 1);

				loadTilemapSpecialTiles(decoratives, layer, tilesetAnimations["ld-32"]);
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
				var player = new Player(x, y);
				state.player = player;

			case "spikes":	
				var spikes = new Spikes(x, y, width, height);
				state.spikes.add(spikes);

			case "saw":	
				var xVelocity = Std.parseFloat(object.custom.get("xVelocity"));
				var yVelocity = Std.parseFloat(object.custom.get("yVelocity"));
				var loop = (object.custom.get("loop") == "true");

				var saw = new Saw(x, y, xVelocity, yVelocity, loop);
				state.saws.add(saw);

			case "cockroach":
				var isStatic = (object.custom.get("isStatic") == "true");
				var isImmune = (object.custom.get("isImmune") == "true");
				var startPatrol = Std.parseInt(object.custom.get("startPatrol"));
				var endPatrol = Std.parseInt(object.custom.get("endPatrol"));
				var cockroach = new Cockroach(x, y, isStatic, isImmune, startPatrol, endPatrol, state.player);
				state.cockroaches.add(cockroach);

			case "exit":	
				var exit = new Exit(x, y, width, height);
				state.exit = exit;
		}
	}

	private inline function isSpecialTile(tile:TiledTile, animations:Dynamic):Bool 
	{
		return (tile.isFlipHorizontally || 
				tile.isFlipVertically || 
				tile.rotate != FlxTileSpecial.ROTATE_0 ||
				animations.exists(tile.tilesetID));
	}

	public function destroy()
	{
		background.destroy();
		collidables.destroy();
		furniture.destroy();
		decoratives.destroy();
	}

}