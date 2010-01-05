/* github bug ? */

package {
	
	/* ****************************************************** *\
	* 	OPEN SOURCE FLASH VIDEO PLAYER
	* 	
	* 	Preview/Generator:
	* 	  http://www.flashjunior.ch/archiv/flvplayer/
	* 	
	* 	Source/Code:
	* 	  http://github.com/FlashJunior/OSFlashVideoPlayer
	* 	
	* 	Problems/Issues:
	* 	  http://github.com/FlashJunior/OSFlashVideoPlayer/issues/labels/bug
	* 	
	* 	Feature request:
	* 	  http://github.com/FlashJunior/OSFlashVideoPlayer/issues/labels/feature
	* 	
	* 	Author:
	* 	  Martin Bommeli
	* 	  http://www.flashjunior.ch
	* 	
	* 	Original graphics and some part of codes:
	* 	  Abdulhalim Kara
	* 	  http://www.abdulhalimkara.com/
	*
	*
	* 	Special thanks to:
	* 	  Abdulhalim Kara (www.abdulhalimkara.com) for help, some codes and very nice skin
	* 	  Florian Weil (www.derhess.de) for his youtube classes
	* 	  DIVIO (www.divio.ch) for given time
	*
	\* ****************************************************** */
	
	import flash.net.SharedObject;
	import flash.system.Security;
	
	import flash.display.MovieClip;
	import flash.events.Event;


	import com.moogaloop.VimeoPlayer;
		
	import com.gskinner.utils.StringUtils;
	
	import com.fj.utils.StopDragButton;
	import com.fj.video.VideoPlayer;
	
	import nl.demonsters.debugger.MonsterDebugger;

	public class OSFlashVideoPlayer extends MovieClip{		
		private var videoMovie:*;
		private var debugger:MonsterDebugger;		
		
		public static var videoSrc : String;
		public static var imgSrc : String;
		
		public static var fullscreenMode : String;
		public static var videoLoop : String;
		public static var autohide : String;
		
		public static var autoplay : String;
		
		public static var seekbarColor:String;
		public static var seekbarbgColor:String;		
		public static var loadingbarColor:String;		
		public static var textColor:String;		
		public static var btnOutColor:String;
		public static var btnOverColor:String;
		public static var btnHighlightColor:String;
				
		private var sharedObj : SharedObject;

		public function OSFlashVideoPlayer(){
			if(loaderInfo.bytesLoaded >= loaderInfo.bytesTotal){
				init();
			}else{
				loaderInfo.addEventListener(Event.COMPLETE, init, false, 0, true);
			}
		}
		
		private function init(e:Event = null):void{		
			Security.allowDomain("*");			
			debugger = new MonsterDebugger(this);
			MonsterDebugger.enabled = false;
			MonsterDebugger.clearTraces();
			
			MonsterDebugger.trace(this, "OSFlashVideoPlayer - init");
			
			sharedObj = SharedObject.getLocal("osvideoplayervolumelevel");
			
			loaderInfo.removeEventListener(Event.COMPLETE, init);
			addEventListener(Event.ADDED_TO_STAGE, initPlayer);
		}
		
		private function initPlayer(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE, initPlayer);		
	
            stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
            stage.align = flash.display.StageAlign.TOP_LEFT;
			
			VideoPlayer.STAGE = StopDragButton.STAGE = stage;
			
			imgSrc 				= stage.loaderInfo.parameters["image"];
			videoSrc 			= stage.loaderInfo.parameters["movie"];			
			videoLoop 			= stage.loaderInfo.parameters["loop"];
			fullscreenMode 		= stage.loaderInfo.parameters["fullscreen"];
			autohide 			= stage.loaderInfo.parameters["autohide"];
			autoplay 			= stage.loaderInfo.parameters["autoplay"];
			seekbarColor 		= stage.loaderInfo.parameters["color_seekbar"];
			seekbarbgColor 		= stage.loaderInfo.parameters["color_seekbarbg"];
			loadingbarColor 	= stage.loaderInfo.parameters["color_loadingbar"];
			textColor 			= stage.loaderInfo.parameters["color_text"];
			btnOutColor 		= stage.loaderInfo.parameters["color_button_out"];
			btnOverColor 		= stage.loaderInfo.parameters["color_button_over"];
			btnHighlightColor 	= stage.loaderInfo.parameters["color_button_highlight"];
			
			!videoSrc ? videoSrc = "http://www.flashjunior.ch/archiv/flvplayer/movies/kuga.mp4" : videoSrc = videoSrc;
			//TEST flv 			!videoSrc ? videoSrc = "http://www.flashjunior.ch/archiv/flvplayer/movies/sad.flv" : videoSrc = videoSrc;
			//TEST youtube 1 	!videoSrc ? videoSrc = "http://www.youtube.com/watch?v=YFa59lK-kpo" : videoSrc = videoSrc;
			//TEST youtube 1 	!videoSrc ? videoSrc = "http://www.youtube.com/v/XrPNl_gZlvY" : videoSrc = videoSrc;
			//TEST vimeo 1 		!videoSrc ? videoSrc = "http://vimeo.com/7917744" : videoSrc = videoSrc;
			//TEST vimeo 2		!videoSrc ? videoSrc = "http://www.vimeo.com/3740633" : videoSrc = videoSrc;
			
			!imgSrc ? imgSrc = "" : imgSrc = imgSrc;
			//TEST				!imgSrc ? imgSrc = "http://www.flashjunior.ch/archiv/flvplayer/2/vorschau.jpg" : imgSrc = imgSrc;			
			
			!autohide ? autohide = "false" : autohide = autohide;
			!autoplay ? autoplay = "false" : autoplay = autoplay;
			!videoLoop ? videoLoop = "false" : videoLoop = videoLoop;
			!fullscreenMode ? fullscreenMode = "true" : fullscreenMode = fullscreenMode;
			!seekbarColor ? seekbarColor = "0x13ABEC" : seekbarColor = seekbarColor;
			!seekbarbgColor ? seekbarbgColor = "0x333333" : seekbarbgColor = seekbarbgColor;
			!loadingbarColor ? loadingbarColor = "0x828282" : loadingbarColor = loadingbarColor;
			!textColor ? textColor = "0xffffff" : textColor = textColor;
			!btnOutColor ? btnOutColor = "0x333333" : btnOutColor = btnOutColor;			
			!btnOverColor ? btnOverColor = "0x000000" : btnOverColor = btnOverColor;
			!btnHighlightColor ? btnHighlightColor = "0xffffff" : btnHighlightColor = btnHighlightColor;
			
			var regex:RegExp;
			var regexResult:*;
			
			if(StringUtils.contains(videoSrc, "youtube.com")){
				regex = RegExp("http://www.youtube.com/v/(.+?)(\&.*|$)");
				regexResult = regex.exec(videoSrc);
				var youtubeCheck:Boolean = false;
				
				if(regexResult){
					videoSrc = regexResult[1].toString();
					youtubeCheck = true;
				}else{
					regex = /youtube\.com\/watch\?v=([^&\/]+)/;
					regexResult = regex.exec(videoSrc);
					if(regexResult){
						videoSrc = regexResult[1].toString();
						youtubeCheck = true;
					}
				}
				
				videoMovie = new VideoPlayer(videoSrc, "youtube");							
				
			} else if(StringUtils.contains(videoSrc, "vimeo.com")){
				regex = RegExp("vimeo.com/(.+?)(\&.*|$)");
				regexResult = regex.exec(videoSrc);
				var vimeoCheck:Boolean = false;
				if(regexResult){
					videoSrc = regexResult[1].toString();
					vimeoCheck = true;
				}
				
				if(fullscreenMode == "true"){
					fullscreenMode = "1";
				}else{
					fullscreenMode = "0";
				}
				
				videoMovie = new VimeoPlayer(int(videoSrc), stage.stageWidth, stage.stageHeight, Number(fullscreenMode));
				videoMovie.addEventListener(Event.COMPLETE, handleVimeoPlayerReady);
			} else{
				videoMovie = new VideoPlayer(videoSrc, "normal");
			}
			
			addChild(videoMovie);
		}
		
		private function handleVimeoPlayerReady(e:Event):void{
			if(autoplay == "true"){videoMovie.play();}
			
			videoMovie.changeColor(seekbarColor.substr(2));
			
			var p_n:Number;
			if(videoLoop=="false"){
				p_n = 0;
			}else{
				p_n = 1;
			}
			
			if(sharedObj.data.volume == undefined){
				sharedObj.data.volume = 100;
			}
			
			videoMovie.setLoop(p_n);
			videoMovie.setVolume(Number(sharedObj.data.volume));
		}
	}
}