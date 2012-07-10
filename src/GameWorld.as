package
{
	import flash.display.BlendMode;
	import flash.geom.ColorTransform;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Point;
	import net.flashpunk.graphics.Backdrop;
	
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.World;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.masks.Grid;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	
	public class GameWorld extends World
	{
		[Embed(source = '../assets/floor.png')] public static const FLOOR_BG:Class;
		private var lightsVec:Array = new Array();
		
		private var torch_power:Number = 100;
		private var torch_angle:Number = 60;
		private var torch_angle_step:Number = 30;
		private var walk_speed:Number = 3;
		private var radius:Number = 8;
		private var player:Entity;
		
		override public function begin():void
		{
			FP.screen.color = 0x555544;
			
			addGraphic(new Backdrop(FLOOR_BG, true, true));
			super.begin();
			
			var playerImg:Image = new Image(new BitmapData(16, 16, false, 0xffff0000));
			add(player = new Entity(30, 30, playerImg));
			playerImg.x -= 8;
			playerImg.y -= 8;
			player.setHitbox(16, 16, 8, 8);
			
			for (var i:int = 0; i < 20; i++)
			{
				var wall:Entity = new Entity(Math.random()*400, Math.random()*300, new Image(new BitmapData(16, 16, false, 0xff335555)))
				wall.setHitbox(16, 16);
				wall.type = "solid";
				add(wall);
			}
		}
		
		override public function update():void
		{
			if (Input.check(Key.UP))	player.y-=3;
			if (Input.check(Key.DOWN))	player.y+=3;
			if (Input.check(Key.LEFT))	player.x-=3;
			if (Input.check(Key.RIGHT))	player.x+=3;
			super.update();
			calculateLightPoints();
			
		}
		
		private function calculateLightPoints():void
		{
			lightsVec = new Array();
			var dist_x:Number = player.x - Input.mouseX - FP.camera.x;
			var dist_y:Number = player.y - Input.mouseY - FP.camera.y;
			var angle:Number = -Math.atan2(dist_x, dist_y);
			var _rotation:Number = angle / (Math.PI / 180);
			var ppoint:Point = new Point();
			
			for (var x:int = 0; x <= torch_angle; x += (torch_angle / torch_angle_step)) 
			{
				var ray_angle:Number = angle/(Math.PI/180)-90-(torch_angle/2)+x;
				var ray_angle:Number = ray_angle * (Math.PI / 180);
				
				var e:Entity = FP.world.collideLine("solid", player.x, player.y, 
					player.x + (torch_power) * Math.cos(ray_angle),
					player.y + (torch_power) * Math.sin(ray_angle),
					1, ppoint);
				if (e != null) {
					lightsVec.push( { x: ppoint.x - FP.camera.x, y: ppoint.y - FP.camera.y} );
				}
				else
				{
					lightsVec.push( { x: player.x - FP.camera.x + (torch_power) * Math.cos(ray_angle),
									  y: player.y - FP.camera.y + (torch_power) * Math.sin(ray_angle)});
				}
				
			}
		}
		
		override public function render():void
		{
			super.render();
				
			var canvas:BitmapData = new BitmapData(FP.width, FP.height, false, 0xFFFFFF);
			var colorTransform:ColorTransform = new ColorTransform(1, 1, 1, 0.1);
			
			canvas.fillRect(canvas.rect, 0xffffff);
			
			var light:Shape = new Shape();
			light.graphics.beginFill(0x000000);
			light.graphics.lineStyle(0);
			light.graphics.moveTo(player.x - FP.camera.x, player.y - FP.camera.y);
			for (var i:int = 0; i < lightsVec.length; i++) 
			{
				light.graphics.lineTo(lightsVec[i].x, lightsVec[i].y);
			}
			light.graphics.lineTo(player.x - FP.camera.x, player.y - FP.camera.y);
			light.graphics.endFill();
			canvas.draw(light);
			FP.buffer.draw(canvas, null, colorTransform, BlendMode.SUBTRACT);
		}
	}
}