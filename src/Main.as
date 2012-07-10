package
{
	import net.flashpunk.Engine;
	import net.flashpunk.FP;
	
	[SWF(width = "800", height = "600", backgroundColor = "#000000")]
	
	public class Main extends Engine
	{
		public function Main():void 
		{
			super(400, 300, 60, false);
		}
		
		override public function init():void
		{
			FP.screen.scale = 2;
			FP.console.enable();
			
			FP.world = new GameWorld;
		}
	}
}