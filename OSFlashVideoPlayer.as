package 
{
    import com.fj.utils.*;
    import com.fj.video.*;
    import com.gskinner.utils.*;
    import com.moogaloop.*;
    import flash.display.*;
    import flash.events.*;
    import flash.external.*;
    import flash.net.*;
    import flash.system.*;
    import nl.demonsters.debugger.*;

    public class OSFlashVideoPlayer extends MovieClip
    {
        private var videoMovie:Object;
        private var debugger:MonsterDebugger;
        private var sharedObj:SharedObject;
        public static var videoSrc:String;
        public static var imgSrc:String;
        public static var fullscreenMode:String;
        public static var videoLoop:String;
        public static var autohide:String;
        public static var autoplay:String;
        public static var seekbarColor:String;
        public static var seekbarbgColor:String;
        public static var loadingbarColor:String;
        public static var textColor:String;
        public static var btnOutColor:String;
        public static var btnOverColor:String;
        public static var btnHighlightColor:String;

        public function OSFlashVideoPlayer()
        {
            if (loaderInfo.bytesLoaded >= loaderInfo.bytesTotal)
            {
                this.init();
            }
            else
            {
                loaderInfo.addEventListener(Event.COMPLETE, this.init, false, 0, true);
            }
            return;
        }// end function

        private function init(event:Event = null) : void
        {
            Security.allowDomain("*");
            this.debugger = new MonsterDebugger(this);
            MonsterDebugger.enabled = false;
            MonsterDebugger.clearTraces();
            MonsterDebugger.trace(this, "OSFlashVideoPlayer - init");
            this.sharedObj = SharedObject.getLocal("osvideoplayervolumelevel");
            loaderInfo.removeEventListener(Event.COMPLETE, this.init);
            addEventListener(Event.ADDED_TO_STAGE, this.initPlayer);
            return;
        }// end function

        private function initPlayer(event:Event) : void
        {
            var _loc_2:RegExp = null;
            var _loc_3:* = undefined;
            var _loc_4:Boolean = false;
            var _loc_5:Boolean = false;
            removeEventListener(Event.ADDED_TO_STAGE, this.initPlayer);
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            var _loc_6:* = stage;
            StopDragButton.STAGE = stage;
            VideoPlayer.STAGE = _loc_6;
            imgSrc = stage.loaderInfo.parameters["image"];
            videoSrc = stage.loaderInfo.parameters["movie"];
            videoLoop = stage.loaderInfo.parameters["loop"];
            fullscreenMode = stage.loaderInfo.parameters["fullscreen"];
            autohide = stage.loaderInfo.parameters["autohide"];
            autoplay = stage.loaderInfo.parameters["autoplay"];
            seekbarColor = stage.loaderInfo.parameters["color_seekbar"];
            seekbarbgColor = stage.loaderInfo.parameters["color_seekbarbg"];
            loadingbarColor = stage.loaderInfo.parameters["color_loadingbar"];
            textColor = stage.loaderInfo.parameters["color_text"];
            btnOutColor = stage.loaderInfo.parameters["color_button_out"];
            btnOverColor = stage.loaderInfo.parameters["color_button_over"];
            btnHighlightColor = stage.loaderInfo.parameters["color_button_highlight"];
            if (!videoSrc)
            {
                videoSrc = "http://www.flashjunior.ch/archiv/flvplayer/movies/kuga.mp4";
            }
            else
            {
                videoSrc = videoSrc;
            }
            if (!imgSrc)
            {
                imgSrc = "";
            }
            else
            {
                imgSrc = imgSrc;
            }
            if (!autohide)
            {
                autohide = "false";
            }
            else
            {
                autohide = autohide;
            }
            if (!autoplay)
            {
                autoplay = "false";
            }
            else
            {
                autoplay = autoplay;
            }
            if (!videoLoop)
            {
                videoLoop = "false";
            }
            else
            {
                videoLoop = videoLoop;
            }
            if (!fullscreenMode)
            {
                fullscreenMode = "true";
            }
            else
            {
                fullscreenMode = fullscreenMode;
            }
            if (!seekbarColor)
            {
                seekbarColor = "0x13ABEC";
            }
            else
            {
                seekbarColor = seekbarColor;
            }
            if (!seekbarbgColor)
            {
                seekbarbgColor = "0x333333";
            }
            else
            {
                seekbarbgColor = seekbarbgColor;
            }
            if (!loadingbarColor)
            {
                loadingbarColor = "0x828282";
            }
            else
            {
                loadingbarColor = loadingbarColor;
            }
            if (!textColor)
            {
                textColor = "0xffffff";
            }
            else
            {
                textColor = textColor;
            }
            if (!btnOutColor)
            {
                btnOutColor = "0x333333";
            }
            else
            {
                btnOutColor = btnOutColor;
            }
            if (!btnOverColor)
            {
                btnOverColor = "0x000000";
            }
            else
            {
                btnOverColor = btnOverColor;
            }
            if (!btnHighlightColor)
            {
                btnHighlightColor = "0xffffff";
            }
            else
            {
                btnHighlightColor = btnHighlightColor;
            }
            if (StringUtils.contains(videoSrc, "youtube.com"))
            {
                _loc_2 = RegExp("http://www.youtube.com/v/(.+?)(&.*|$)");
                _loc_3 = _loc_2.exec(videoSrc);
                _loc_4 = false;
                if (_loc_3)
                {
                    videoSrc = _loc_3[1].toString();
                    _loc_4 = true;
                }
                else
                {
                    _loc_2 = /youtube\.com\/watch\?v=([^&\/]+)""youtube\.com\/watch\?v=([^&\/]+)/;
                    _loc_3 = _loc_2.exec(videoSrc);
                    if (_loc_3)
                    {
                        videoSrc = _loc_3[1].toString();
                        _loc_4 = true;
                    }
                }
                this.videoMovie = new VideoPlayer(videoSrc, "youtube");
            }
            else if (StringUtils.contains(videoSrc, "vimeo.com"))
            {
                _loc_2 = RegExp("vimeo.com/(.+?)(&.*|$)");
                _loc_3 = _loc_2.exec(videoSrc);
                _loc_5 = false;
                if (_loc_3)
                {
                    videoSrc = _loc_3[1].toString();
                    _loc_5 = true;
                }
                if (fullscreenMode == "true")
                {
                    fullscreenMode = "1";
                }
                else
                {
                    fullscreenMode = "0";
                }
                this.videoMovie = new VimeoPlayer(int(videoSrc), stage.stageWidth, stage.stageHeight, Number(fullscreenMode));
                this.videoMovie.addEventListener(Event.COMPLETE, this.handleVimeoPlayerReady);
            }
            else
            {
                this.videoMovie = new VideoPlayer(videoSrc, "normal");
            }
            addChild(this.videoMovie);
            if (ExternalInterface.available)
            {
                ExternalInterface.addCallback("getVideoTimeData", this.getTimeData);
            }
            if (ExternalInterface.available)
            {
                ExternalInterface.call("onVideoPlayerInited");
            }
            return;
        }// end function

        private function handleVimeoPlayerReady(event:Event) : void
        {
            var _loc_2:Number = NaN;
            if (autoplay == "true")
            {
                this.videoMovie.play();
            }
            this.videoMovie.changeColor(seekbarColor.substr(2));
            if (videoLoop == "false")
            {
                _loc_2 = 0;
            }
            else
            {
                _loc_2 = 1;
            }
            if (this.sharedObj.data.volume == undefined)
            {
                this.sharedObj.data.volume = 100;
            }
            this.videoMovie.setLoop(_loc_2);
            this.videoMovie.setVolume(Number(this.sharedObj.data.volume));
            return;
        }// end function

        public function getTimeData()
        {
            return {duration:this.videoMovie.videoDuration, currentTime:this.videoMovie.videoTime, playing:this.videoMovie.currentState == "playing"};
        }// end function

    }
}
