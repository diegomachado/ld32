package;

import flixel.util.FlxSave;

class Reg
{
	public static inline var SOUND_PATH:String = "assets/sounds/";
	public static inline var PLAYER_SPRITE:String = "assets/images/cook.png";
	public static inline var IMMUNE_COCKROACH_SPRITE:String = "assets/images/immune-cockroach.png";
	public static inline var COCKROACH_SPRITE:String = "assets/images/cockroach.png";
	public static inline var BASE_TILESHEET:String = "assets/images/ld-32.png";
	public static inline var LEVEL_PATH:String = "assets/data/";
	public static inline var LEVEL_EXT:String = ".tmx";

	public static inline var FART_SOUNDS_PATH:String = "assets/sounds/fart";
	public static inline var JUMP_SOUNDS_PATH:String = "assets/sounds/jump";
	public static inline var SICK_SOUNDS_PATH:String = "assets/sounds/sick";

	public static var currentLevel = 0;
	public static var levels = ["1", "2", "3", "4", "5", "6", "7", "8"];
}