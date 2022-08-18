import flixel.util.FlxColor;
import flixel.ui.FlxBar;
import sys.thread.Mutex;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;

class LoadingScreen extends MusicBeatState
{
	var target:MusicBeatState;
	var loadMutex:Mutex;

	var bar:FlxBar;

	public static var progress:Int = 0;

	public var localProg:Int = 0;

	var loadingSong:Bool = false;

	public function new(_target:MusicBeatState, song:Bool = false)
	{
		target = _target;
		#if windows
		Debug.logTrace("bruhg");
		#end
		loadMutex = new Mutex();
		loadingSong = song;
		super();
	}

	var startLoad:Bool = false;

	var bg:FlxSprite;

	override function create()
	{
		Main.dumpCache();
		progress = 0;
		bg = new FlxSprite(0, 0).loadGraphic(Paths.image('loading/loading_screen', 'shared'));
		bg.antialiasing = FlxG.save.data.antialiasing;
		bg.scrollFactor.set();
		bg.updateHitbox();
		bg.ID = 999999;
		add(bg);

		bar = new FlxBar(24, 684, FlxBarFillDirection.LEFT_TO_RIGHT, 1224, 12, this, "localProg", 0, 100);
		bar.createFilledBar(FlxColor.TRANSPARENT, FlxColor.fromRGB(255, 22, 210));
		bar.scrollFactor.set();
		add(bar);
		#if windows
		Debug.logTrace("lets do some loading " + bar);
		#end

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (!startLoad)
		{
			startLoad = true;
			sys.thread.Thread.create(() ->
			{
				loadMutex.acquire();
				#if windows
				Debug.logTrace("reset da assets");
				#end
				MasterObjectLoader.resetAssets();
				target.load();
				target.loadedCompletely = true;
				#if windows
				Debug.logTrace("we done lets gtfo " + target);
				#end
				switchState(target, false, true);
				loadMutex.release();
			});
		}
		localProg = progress;
		super.update(elapsed);
	}
}
