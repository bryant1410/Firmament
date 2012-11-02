package firmament.core;

/**
 * Class: FGame
 * Manages the game, including all worlds, cameras, simulation, rendering, etc.
 */


import firmament.core.FCamera;
import firmament.core.FEntity;
import firmament.core.FWorldFactory;
import firmament.process.base.FProcess;
import firmament.process.base.FProcessManager;
import firmament.process.engine.FCameraRenderProcess;
import firmament.process.engine.FWorldStepProcess;
import firmament.utils.loader.serializer.FSerializerFactory;
import haxe.Timer;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.EventDispatcher;
import nme.events.TimerEvent;
import nme.Lib;
import nme.text.TextField;
import nme.utils.Timer;

/**
 * Class: FGame
 */
class FGame extends EventDispatcher
{
	var cameras:Hash<FCamera>;
	var worldHash:Hash<FWorld>; 
	public var enableSimulation:Bool;
	var processManager:FProcessManager;
	//Constant: COLLISION_EVENT
	public static inline var COLLISION_EVENT = 'collision';
	
	//CONSTANT: BEFORE_STEP
	public static inline var BEFORE_STEP = 'beforeStep';
	
	//CONSTANT: AFTER_STEP
	public static inline var AFTER_STEP = 'afterStep';

	//CONSTANT: BEFORE_RENDER
	public static inline var BEFORE_RENDER = 'beforeRender';
	

	//CONSTANT: AFTER_RENDER
	public static inline var AFTER_RENDER = 'afterRender';

	private static var _instance:FGame;

	/**
	 * Constructor: new
	 */
	private function new() 
	{
		super();
		
		this.enableSimulation = true;
		worldHash = new Hash<FWorld>();
		cameras = new Hash<FCamera>();
		var stage = Lib.current.stage;
		this.processManager = new FProcessManager();
		stage.addEventListener(Event.ENTER_FRAME, this_onEnterFrame);
		
		/*var timer = new Timer(33);
		timer.addEventListener(TimerEvent.TIMER, this_step);
		timer.start();
		*/
	}



	public function loadGameConfig(fileName:String){
		var serializer = FSerializerFactory.getSerializerForFile(fileName);
		if (serializer == null) {
			throw ("Appropriate serializer for fileName "+fileName+" could not befound.");
		}
		var string = Assets.getText(fileName);
		var config = serializer.unserialize(string);
	}



	/*
		Function: instance
		returns the singleton instance of FGame.
	*/
	// TODO: Refactor to getInstance
	public static function instance():FGame{
		if(_instance == null){
			_instance = new FGame();
		}
		return _instance;
	}
	
	/**
	 * Function: getWorld
	 *
	 * Returns: an FWorld object of the type provided
	 */
	public function getWorld(type:String):FWorld{
		if(worldHash.exists(type)){
			return worldHash.get(type);
		}
		var w = FWorldFactory.createWorld(type);
		worldHash.set(type, w);

		//set up process for it
		var p = new FWorldStepProcess(w);
		this.processManager.addProcess(p);

		return w;
	}

	public function getWorlds():Hash<FWorld>{
		return this.worldHash;
	}

	/**
	 * Function: getProcessManager
	 */
	public function getProcessManager():FProcessManager {
		return this.processManager;
	}

	/**
	 * Function: addProcess
	 *
	 * Parameters: 
	 *  name - String identifier for object, for retrieval
	 *  p - Process object
	 */
	public function addProcess(?type:String,p:FProcess):Void {
		this.processManager.addProcess(p);
	}

	/**
	 * Function: addCamera
	 * 
	 * Adds a new <FCamera> object to the game. Cameras must be added to the game in order for them to work.
	 * 
	 * Parameters:
	 *	name - String the name to call the camera. Used for getting the right camera.
	 *	c - <FCamera> The camera to add
	 */
	public function addCamera(name:String,c:FCamera):Void {
		this.cameras.set(name,c);
		this.processManager.addProcess(new FCameraRenderProcess(c));
	}


	/**
	 *	Function: getCamera
	 *	Parameters:
	 *		name - String the name of the camera to retrieve
	 *	Returns: <FCamera>
	*/
	public function getCamera(name:String):FCamera{
		return this.cameras.get(name);
	}
	
	
	
	private function doStep():Void {
		this.dispatchEvent(new Event(FGame.BEFORE_STEP));
		this.processManager.step();
		this.dispatchEvent(new Event(FGame.AFTER_STEP));
	}



	private function this_onEnterFrame (event:Event):Void {
		//trace('this is called.');
		
		//var start = haxe.Timer.stamp();
		this.doStep();
		//trace("step time: "+(haxe.Timer.stamp() - start));
		
	
		
	} 


}
