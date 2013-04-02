package com.moogaloop
{
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import flash.system.*;
    import flash.utils.*;

    public class VimeoPlayer extends Sprite
    {
        private var container:Sprite;
        private var moogaloop:Object = false;
        private var player_mask:Sprite;
        private var player_width:int = 590;
        private var player_height:int = 300;
        private var load_timer:Timer;

        public function VimeoPlayer(param1:int, param2:int, param3:int, param4:int = 0)
        {
            this.container = new Sprite();
            this.player_mask = new Sprite();
            this.load_timer = new Timer(200);
            this.setDimensions(param2, param3);
            Security.allowDomain("http://bitcast.vimeo.com");
            var _loc_5:* = new Loader();
            var _loc_6:* = new URLRequest("https://api.vimeo.com/moogaloop_api.swf?clip_id=" + param1 + "&width=" + param2 + "&height=" + param3 + "&fullscreen=" + param4);
            _loc_5.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onComplete);
            _loc_5.load(_loc_6);
            return;
        }// end function

        private function setDimensions(param1:int, param2:int) : void
        {
            this.player_width = param1;
            this.player_height = param2;
            return;
        }// end function

        private function onComplete(event:Event) : void
        {
            this.container.addChild(event.target.loader.content);
            this.moogaloop = event.target.loader.content;
            addChild(this.player_mask);
            this.container.mask = this.player_mask;
            addChild(this.container);
            this.redrawMask();
            this.load_timer.addEventListener(TimerEvent.TIMER, this.playerLoadedCheck);
            this.load_timer.start();
            return;
        }// end function

        private function playerLoadedCheck(event:TimerEvent) : void
        {
            if (this.moogaloop.player_loaded)
            {
                this.load_timer.stop();
                this.load_timer.removeEventListener(TimerEvent.TIMER, this.playerLoadedCheck);
                this.moogaloop.disableMouseMove();
                stage.addEventListener(MouseEvent.MOUSE_MOVE, this.mouseMove);
                dispatchEvent(new Event(Event.COMPLETE));
            }
            return;
        }// end function

        private function mouseMove(event:MouseEvent) : void
        {
            if (event.stageX >= this.x && event.stageX <= this.x + this.player_width && event.stageY >= this.y && event.stageY <= this.y + this.player_height)
            {
                this.moogaloop.mouseMove(event);
            }
            else
            {
                this.moogaloop.mouseOut();
            }
            return;
        }// end function

        private function redrawMask() : void
        {
            var _loc_2:* = this.player_mask.graphics;
            with (this.player_mask.graphics)
            {
                beginFill(0, 1);
                drawRect(container.x, container.y, player_width, player_height);
                endFill();
            }
            return;
        }// end function

        public function play() : void
        {
            this.moogaloop.api_play();
            return;
        }// end function

        public function pause() : void
        {
            this.moogaloop.api_pause();
            return;
        }// end function

        public function getDuration() : int
        {
            return this.moogaloop.api_getDuration();
        }// end function

        public function seekTo(param1:int) : void
        {
            this.moogaloop.api_seekTo(param1);
            return;
        }// end function

        public function changeColor(param1:String) : void
        {
            this.moogaloop.api_changeColor(param1);
            return;
        }// end function

        public function loadVideo(param1:int) : void
        {
            this.moogaloop.api_loadVideo(param1);
            return;
        }// end function

        public function setSize(param1:int, param2:int) : void
        {
            this.setDimensions(param1, param2);
            this.moogaloop.api_setSize(param1, param2);
            this.redrawMask();
            return;
        }// end function

        public function setLoop(param1:int) : void
        {
            this.moogaloop.api_setLoop(param1);
            return;
        }// end function

        public function setVolume(param1:int) : void
        {
            this.moogaloop.api_setVolume(param1);
            return;
        }// end function

    }
}
