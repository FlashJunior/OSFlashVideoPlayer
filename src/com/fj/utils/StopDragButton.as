package com.fj.utils{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	public class StopDragButton extends MovieClip{
		public static var STAGE:Stage;
		public var registeredDragBtn:MovieClip;
		
		public function StopDragButton(){
			this.name = "stopDragButton";
			
			graphics.beginFill(0x000000, 0);
			graphics.drawRect(0, 0, 100, 100);
			graphics.endFill();
			
			init();
		}
		
		public function registerDragBtn(btn:MovieClip):StopDragButton{
			registeredDragBtn = btn;
			return this;
		}
		
		private function init():void{
			this.addEventListener(Event.ADDED_TO_STAGE, startdrag);
			this.addEventListener(Event.REMOVED_FROM_STAGE, stopdrag);
		}
		
		private function startdrag(event:Event):void{
			this.width = STAGE.stageWidth;
			this.height = STAGE.stageHeight;
			
			if(!registeredDragBtn) return;
			
			var lockCenter:Boolean = registeredDragBtn.lockCenter ? registeredDragBtn.lockCenter : false;
			var bounds:Rectangle = registeredDragBtn.dragBounds ? registeredDragBtn.dragBounds : null;
			
			registeredDragBtn.startDrag(lockCenter, bounds);
		}
		
		private function stopdrag(event:Event):void{
			if(!registeredDragBtn) return;	
			registeredDragBtn.stopDrag();
		}
	}
}