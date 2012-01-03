package com.fj.video {
	
	/* ****************************************************** *\
	* 	OPEN SOURCE FLASH VIDEO PLAYER
	* 	
	* 	Preview/Generator:
	* 	  http://www.flashjunior.ch/archiv/flvplayer/2/
	* 	
	* 	Source/Code:
	* 	  http://github.com/FlashJunior/OSFlashVideoPlayer
	* 	
	* 	Author:
	* 	  Martin Bommeli
	* 	  http://www.flashjunior.ch
	* 	
	* 	Original graphics and some part of codes:
	* 	  Abdulhalim Kara
	* 	  http://www.abdulhalimkara.com/
	*
	\* ****************************************************** */
	import de.derhess.video.youtube.YouTubeError;

	import flash.events.SecurityErrorEvent;
	import flash.events.AsyncErrorEvent;

	import de.derhess.video.youtube.YouTubePlayingState;
	import de.derhess.video.youtube.YouTubeVideoQuality;
	import de.derhess.video.youtube.YouTubeEvent;
	import de.derhess.video.youtube.FlashYouTube;

	import com.fj.utils.StopDragButton;

	import flash.display.Loader;
	import flash.net.URLRequest;

	import nl.demonsters.debugger.MonsterDebugger;

	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.SharedObject;
	import flash.utils.Timer;
	import flash.geom.Rectangle
	
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.greensock.plugins.*;
	TweenPlugin.activate([TintPlugin]);
	
	
	public class VideoPlayer extends MovieClip{
		public static var STAGE:Stage;
		
		private var seekbarWidth:uint;
		private var volumebarWidth:uint;
		private var stageWidth:uint;
		private var stageHeight:uint;
		
		public var currentState:String;
		public var currentVideo:String;
		
		private var sharedObj:SharedObject;
		private var soundtransform:SoundTransform;
		
		private var stopScrubDrag:StopDragButton;
		private var stopVScrubDrag:StopDragButton;
		
		private var lastState:String;
		
		public var video_mc : MovieClip;
		private var video:Video;
		
		private var connection:NetConnection;
		private var stream:NetStream;
		public var videoTime:Number = 0;
		public var videoDuration:Number = 0;
		
		private var loader:MovieClip;
		
		private var ctrlBar:MovieClip;
		
		private var welcome:MovieClip;		
		
		private var autoHideTimer:Timer;
		
		private var buttomSpacing:Number;
		
		private var videoSrc:String;
		private var videoType: String;
		private var youTubePlayer : FlashYouTube;
		//private var vimeoPlayer : VimeoPlayer;
		
		public function VideoPlayer(videoSrc:String, videoType:String){
			MonsterDebugger.trace(this, "VideoPlayer - init");
			
			ctrlBar = this["controllerbar_mc"];
			loader = this["loader_mc"];
			welcome = this["welcome_mc"];
			
			this.videoSrc = videoSrc;
			this.videoType = videoType;
			
			//stopScrubDrag = new StopDragButton();
			//stopVScrubDrag = new StopDragButton();
			
			removeChild(loader);
			
			sharedObj = SharedObject.getLocal("osvideoplayervolumelevel");
			
			hideErrorTxt();
			
			init();
			
			if(OSFlashVideoPlayer.imgSrc != ""){
				var imageLoader:Loader = new Loader();
				var imageRequest:URLRequest = new URLRequest(String(OSFlashVideoPlayer.imgSrc));
				
				imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(evt:Event):void{
				    try{
				        welcome.img_mc.addChild(imageLoader.content);
				    }catch(e){
				        welcome.img_mc.addChild(imageLoader);
				    }
					
					stageResize();
				});
				
				imageLoader.load(imageRequest);
			}
			
			setCTRLButton(welcome.play_btn, handleBigPlayClick);
		}
		
		
		public function init():void{
			STAGE.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			STAGE.addEventListener(FullScreenEvent.FULL_SCREEN, handleFullScreenEvent);
			STAGE.addEventListener(Event.RESIZE, stageResize);
			
			if(OSFlashVideoPlayer.autohide == "true"){
				STAGE.addEventListener(Event.MOUSE_LEAVE, handleMouseLeave);
				
				STAGE.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
				
				autoHideTimer = new Timer(3000);
				autoHideTimer.addEventListener(TimerEvent.TIMER, handleAutoHideTimerTick);
				
				ctrlBar.y = STAGE.stageHeight+20;
				
				buttomSpacing = 0;
			}else{
				buttomSpacing = ctrlBar.bg_mc.height;
			}
			
			TweenLite.to(ctrlBar.bar_seek_mc.bar_mc, 0, {tint:OSFlashVideoPlayer.seekbarColor});
			TweenLite.to(ctrlBar.bar_volume_mc.bar_mc, 0, {tint:OSFlashVideoPlayer.seekbarColor});
			
			TweenLite.to(ctrlBar.bar_seek_mc.bar_loader_mc, 0, {tint:OSFlashVideoPlayer.loadingbarColor});
			
			TweenLite.to(ctrlBar.bar_seek_mc.bg_mc, 0, {tint:OSFlashVideoPlayer.seekbarbgColor});
			TweenLite.to(ctrlBar.bar_volume_mc.bg_mc, 0, {tint:OSFlashVideoPlayer.seekbarbgColor});
			
			TweenLite.to(ctrlBar.time_mc.bg, 0, {tint:OSFlashVideoPlayer.seekbarbgColor});
			
			TweenLite.to(ctrlBar.time_mc.time_txt, 0, {tint:OSFlashVideoPlayer.textColor});
			TweenLite.to(ctrlBar.time_mc.duration_txt, 0, {tint:OSFlashVideoPlayer.textColor});
			TweenLite.to(ctrlBar.time_mc.div, 0, {tint:OSFlashVideoPlayer.textColor});
						
			if(OSFlashVideoPlayer.fullscreenMode == "false"){
				ctrlBar.fullscreen_btn.visible = false;
				ctrlBar.fullscreen_btn.width = 0;
			}else{
				setCTRLButton(ctrlBar.fullscreen_btn, switchFullScreenMode);
			}
				
			if(videoType == "youtube"){
				youTubePlayer = new FlashYouTube();
				youTubePlayer.addEventListener(YouTubeEvent.PLAYER_LOADED, youtubeHandlePlayerLoaded);
				youTubePlayer.addEventListener(YouTubeEvent.STATUS, youtubeHandlePlayingState);
				youTubePlayer.addEventListener(YouTubeEvent.ERROR, youtubeHandleError);

				video_mc.addChild(youTubePlayer);
				
			}else if(videoType == "vimeo"){
				//vimeoPlayer = new VimeoPlayer(videoSrc, 200, 200, 1);
				//video_mc.addChild(vimeoPlayer);
			}else{
				soundtransform = new SoundTransform();
				connection = new NetConnection();
				connection.addEventListener(NetStatusEvent.NET_STATUS, conNetStatusHandler);
				connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler)
				connection.connect(null);
			}			
			
			ctrlBar.bar_seek_mc.scrub_mc.lockCenter = false;
			ctrlBar.bar_seek_mc.scrub_mc.dragBounds = new Rectangle(0, 0, ctrlBar.bar_seek_mc.bg_mc.width-ctrlBar.bar_seek_mc.scrub_mc.width, 0);
			
			ctrlBar.bar_seek_mc.scrub_mc.stopDragBtn = new StopDragButton().registerDragBtn(ctrlBar.bar_seek_mc.scrub_mc);
			
			ctrlBar.bar_volume_mc.scrub_mc.sc = ctrlBar.bar_volume_mc.sc_mc;
			
			ctrlBar.bar_volume_mc.scrub_mc.lockCenter = false;
			ctrlBar.bar_volume_mc.scrub_mc.dragBounds = new Rectangle(0, 0, ctrlBar.bar_volume_mc.bg_mc.width-ctrlBar.bar_volume_mc.scrub_mc.width, 0);
			
			ctrlBar.bar_volume_mc.scrub_mc.stopDragBtn = new StopDragButton().registerDragBtn(ctrlBar.bar_volume_mc.scrub_mc);			
			
			time = 0;
			duration = 0;
			ctrlBar.bar_seek_mc.scrub_mc.x = ctrlBar.bar_seek_mc.sc_mc.x;
			ctrlBar.bar_seek_mc.bar_mc.width = 0.1;
			ctrlBar.bar_seek_mc.bar_loader_mc.width = 0.1;
			
			ctrlBar.pause_btn.visible = false;
			disableCTRLButton(ctrlBar.pause_btn, pauseVideo);
			disableCTRLButton(ctrlBar.play_btn, playVideo);
			
			disableCTRLButton(ctrlBar.bar_seek_mc.scrub_mc, null, changeScrubState);
			disableCTRLButton(ctrlBar.bar_volume_mc.scrub_mc, null, changeVolumeScrubState);
			
			if(ctrlBar.bar_volume_mc.speaker_mc){
				disableCTRLButton(ctrlBar.bar_volume_mc.speaker_mc, toggleMute);
			}
			
			stageResize();
			updateCTRLButtonsPosition();
		}


		private function handleAddedToStage(e:Event):void{
			ctrlBar.bar_volume_mc.scrub_mc.x = sharedObj.data.volume != undefined ? Number(ctrlBar.bar_volume_mc.scrub_mc.sc.x + sharedObj.data.volume) : ctrlBar.bar_volume_mc.scrub_mc.x;
			ctrlBar.bar_volume_mc.scrub_mc.x = ctrlBar.bar_volume_mc.scrub_mc.x < ctrlBar.bar_volume_mc.scrub_mc.sc.x ? ctrlBar.bar_volume_mc.scrub_mc.sc.x : (ctrlBar.bar_volume_mc.scrub_mc.x > ctrlBar.bar_volume_mc.scrub_mc.sc.x + volumebarWidth ? ctrlBar.bar_volume_mc.scrub_mc.sc.x + volumebarWidth : ctrlBar.bar_volume_mc.scrub_mc.x);
			
			addChildAt(welcome, getChildIndex(video_mc) + 1);
			
			setCTRLButton(ctrlBar.play_btn, playVideo);
			setCTRLButton(ctrlBar.bar_volume_mc.scrub_mc, null, changeVolumeScrubState);
			if(ctrlBar.bar_volume_mc.speaker_mc){
				setCTRLButton(ctrlBar.bar_volume_mc.speaker_mc, toggleMute);
			}
			
			ctrlBar.bar_volume_mc.hit_mc.addEventListener(MouseEvent.MOUSE_DOWN, startVScrubDraging);
			ctrlBar.bar_volume_mc.hit_mc.buttonMode = true;
			
			updateVolume();
			
			if(OSFlashVideoPlayer.autoplay == "true"){playVideo();}
		}

			
		private function get duration():Number{
			return videoDuration;
		}
		
		private function set duration(value:Number):void{
			var minute:uint = uint(value / 60);
			var second:uint = uint(value % 60);
			
			ctrlBar.time_mc.duration_txt.text = "";
			if(minute < 10){
				ctrlBar.time_mc.duration_txt.text = "0";
			}
			ctrlBar.time_mc.duration_txt.appendText(minute.toString() + ":");
			
			if(second < 10){
				ctrlBar.time_mc.duration_txt.appendText("0");
			}
			ctrlBar.time_mc.duration_txt.appendText(second.toString());
			
			videoDuration = value;
		}
		
		private function set time(value:Number):void{
			value = value > duration ? duration : value;
			
			var minute:uint = uint(value / 60);
			var second:uint = uint(value % 60);
			
			ctrlBar.time_mc.time_txt.text = "";
			if(minute < 10){
				ctrlBar.time_mc.time_txt.text = "0";
			}
			ctrlBar.time_mc.time_txt.appendText(minute.toString() + ":");
			
			if(second < 10){
				ctrlBar.time_mc.time_txt.appendText("0");
			}
			ctrlBar.time_mc.time_txt.appendText(second.toString());
			
			videoTime = value;
		}
		
		private function handleMouseLeave(e:Event):void{
			MonsterDebugger.trace(this, "handleMouseLeave");
			
			if(ctrlBar.y < STAGE.stageHeight && !STAGE.getChildByName("stopDragButton")){
				TweenLite.to(ctrlBar, 0.5, {y:STAGE.stageHeight+20, ease:Quad.easeOut});
			}			autoHideTimer.stop();
		}
		
		private function handleMouseMove(e:MouseEvent=null):void{
			autoHideTimer.stop();
			autoHideTimer.start();
			MonsterDebugger.trace(this, "handleMouseMove ");
			MonsterDebugger.trace(this, e);
			
			var endPos:uint = STAGE.stageHeight-ctrlBar.bg_mc.height;
			if(ctrlBar.y > endPos){
				TweenLite.to(ctrlBar, 0.5, {y:endPos, ease:Quad.easeOut});
			}
		}
		
		private function handleAutoHideTimerTick(e:TimerEvent):void{
			MonsterDebugger.trace(this, "handleAutoHideTimerTick");
			if(ctrlBar.y < STAGE.stageHeight && !ctrlBar.hitTestPoint(STAGE.mouseX, STAGE.mouseY)){
				MonsterDebugger.trace(this, "handleAutoHideTimerTick IF");
				TweenLite.to(ctrlBar, 0.5, {y:STAGE.stageHeight+20, ease:Quad.easeOut});
			}
		}
		
		private function switchFullScreenMode(e:MouseEvent):void{
			if(STAGE.displayState == "normal"){
				STAGE.displayState = "fullScreen";
			}else{
				STAGE.displayState = "normal";
			}
			stageResize();
		}
		private function handleFullScreenEvent(e:FullScreenEvent):void{
			stageResize();
		}
		
		private function handleBigPlayClick(e:MouseEvent):void{
			ctrlBar.play_btn.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
		private var bytesL:*;
		private var bytesT:*;
		public function updateLoadingbar(e:Event = null):void{
			if(videoType == "youtube"){
				bytesL = youTubePlayer.getVideoBytesLoaded();
				bytesT = youTubePlayer.getVideoBytesTotal();
			}else if(videoType == "vimeo"){
				
			
			}else{
				bytesL = stream.bytesLoaded;
				bytesT = stream.bytesTotal;
			}			
			ctrlBar.bar_seek_mc.bar_loader_mc.width = bytesL / bytesT * seekbarWidth;
			
			ctrlBar.bar_seek_mc.scrub_mc.dragBounds = new Rectangle(0, 0, ctrlBar.bar_seek_mc.bg_mc.width-ctrlBar.bar_seek_mc.scrub_mc.width, 0); // (x=1, y=3, w=11, h=13)
			
			
			if(bytesL >= bytesT){removeEventListener(Event.ENTER_FRAME, updateLoadingbar);}
		}
		
		private function updateTime(e:Event):void{
			ctrlBar.bar_seek_mc.bar_mc.width = (ctrlBar.bar_seek_mc.scrub_mc.x - ctrlBar.bar_seek_mc.sc_mc.x) > 0 ? ((ctrlBar.bar_seek_mc.scrub_mc.x - ctrlBar.bar_seek_mc.sc_mc.x) <= seekbarWidth ? (ctrlBar.bar_seek_mc.scrub_mc.x - ctrlBar.bar_seek_mc.sc_mc.x) : seekbarWidth) : 0.1;
			time = (ctrlBar.bar_seek_mc.bar_mc.width / seekbarWidth) * duration;
		}
		
		private function stageResize(e:Event=null):void{
			stageWidth = STAGE.stageWidth;
			stageHeight = STAGE.stageHeight;
			
			if(videoType == "youtube"){
				youTubePlayer.setSize(stageWidth, stageHeight-buttomSpacing);
				
			}else if(videoType == "vimeo"){
				//vimeoPlayer.setSize(stageWidth, stageHeight-buttomSpacing);
			
			}else{
				scaleMCtoMax(video_mc);
				scaleMCtoMax(welcome.img_mc);
			}
			
			ctrlBar.errortxt_mc.txt.width = stageWidth;
			
			updateCTRLButtonsPosition();
			
			if(OSFlashVideoPlayer.autohide == "true"){
				if(ctrlBar.y > STAGE.stageHeight-ctrlBar.bg_mc.height){
					ctrlBar.y = STAGE.stageHeight+20;
				}else{
					ctrlBar.y = stageHeight - ctrlBar.bg_mc.height;
				}				
			}else{
				ctrlBar.y = stageHeight - ctrlBar.bg_mc.height;
			}
			
			welcome.play_btn.x = Math.round(STAGE.stageWidth / 2);
			welcome.play_btn.y = Math.round((STAGE.stageHeight-buttomSpacing) / 2);	

			loader.x = Math.round(STAGE.stageWidth / 2);
			loader.y = Math.round((STAGE.stageHeight-buttomSpacing) / 2);
			
			updateLoadingbar();
		}
		
		private function updateCTRLButtonsPosition():void{
			var itemMargin:uint = 10;
			
			if(OSFlashVideoPlayer.fullscreenMode == "false"){
				ctrlBar.bar_volume_mc.x = stageWidth - ctrlBar.bar_volume_mc.bg_mc.width - itemMargin;
			}else{
				ctrlBar.fullscreen_btn.x 	= stageWidth - ctrlBar.fullscreen_btn.width - itemMargin;	
				ctrlBar.bar_volume_mc.x		= ctrlBar.fullscreen_btn.x - ctrlBar.bar_volume_mc.bg_mc.width - itemMargin;
			}
			
			ctrlBar.bar_volume_mc.scrub_mc.x 		= ctrlBar.bar_volume_mc.sc_mc.x + int(ctrlBar.bar_volume_mc.scrub_mc.x - ctrlBar.bar_volume_mc.sc_mc.x);
			
			ctrlBar.time_mc.x						= ctrlBar.bar_volume_mc.x - ctrlBar.time_mc.width - itemMargin;
			
			ctrlBar.bar_seek_mc.bg_mc.width 		= ctrlBar.time_mc.x - ctrlBar.bar_seek_mc.x - itemMargin;
			ctrlBar.bar_seek_mc.hit_mc.width 		= ctrlBar.bar_seek_mc.bg_mc.width - 4;
			
			ctrlBar.bg_mc.width 					= stageWidth;
		
			if(ctrlBar.time_mc.x < ctrlBar.pause_btn.x+ctrlBar.pause_btn.width){
				ctrlBar.time_mc.visible = ctrlBar.bar_seek_mc.visible = false;
			}else{
				ctrlBar.time_mc.visible = ctrlBar.bar_seek_mc.visible = true;
			}			
			
			if(ctrlBar.bar_volume_mc.x < ctrlBar.pause_btn.x+ctrlBar.pause_btn.width){
				ctrlBar.bar_volume_mc.visible = false;
			}else{
			 	ctrlBar.bar_volume_mc.visible = true;			
			}
			 	
			if(ctrlBar.fullscreen_btn.x < ctrlBar.pause_btn.x+ctrlBar.pause_btn.width){
				ctrlBar.fullscreen_btn.visible = false;
			}else{
				ctrlBar.fullscreen_btn.visible = true;			
			}
			
			seekbarWidth = ctrlBar.bar_seek_mc.hit_mc.width;
			volumebarWidth = ctrlBar.bar_volume_mc.hit_mc.width;
		}

		private function scaleMCtoMax(mc:MovieClip):void{
			mc.height = stageHeight-buttomSpacing;
			mc.scaleX = mc.scaleY;
			
			if(mc.width > stageWidth){
				mc.width = stageWidth;
				mc.scaleY = mc.scaleX;
			}
			
			mc.x = (stageWidth - mc.width) / 2;
			mc.y = ((stageHeight- buttomSpacing) - mc.height) / 2;
		}
		
		private function metaDataHandler(info:Object):void{
			duration = info.duration;
			video.width = info.width;
			video.height = info.height;
			initScrubling();
		}
		
		private function initScrubling():void{
			setCTRLButton(ctrlBar.bar_seek_mc.scrub_mc, null, changeScrubState);
			
			addEventListener(Event.ENTER_FRAME, updateTime);
			addEventListener(Event.ENTER_FRAME, updateScrub);
			ctrlBar.bar_seek_mc.hit_mc.addEventListener(MouseEvent.MOUSE_DOWN, startScrubDraging);
			ctrlBar.bar_seek_mc.hit_mc.buttonMode = true;
			
			stageResize();
		}
		
		
		private function conNetStatusHandler(e:NetStatusEvent):void{
			if(e.info.code == "NetConnection.Connect.Success"){
				var clientObj:Object = new Object();
				clientObj.onMetaData = metaDataHandler;
				//clientObj.onCuePoint = cuePointHandler;
				
				stream = new NetStream(connection);
				stream.bufferTime = 5;
				stream.client = clientObj;
				stream.checkPolicyFile = true;
				
				video = new Video();
				video.smoothing = true;
				video_mc.addChild(video);
				video.attachNetStream(stream);
				
				stageResize();
				
				stream.addEventListener(NetStatusEvent.NET_STATUS, strNetStatusHandler);
				stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			}
		}
		
		private function strNetStatusHandler(e:NetStatusEvent):void{
			var code:String = e.info.code;	
			if(code == "NetStream.Play.StreamNotFound"){
				showError("Stream not found: " + videoSrc);
			} else if(code == "NetStream.Play.Start"){
				addEventListener(Event.ENTER_FRAME, updateLoadingbar);
				if(!contains(loader)){addChild(loader);}
				setPlayedState();				
			} else if(code == "NetStream.Play.Stop"){
				if(OSFlashVideoPlayer.videoLoop == "false"){
					if(lastState == null){
						if (!contains(welcome)){
							addChildAt(welcome, getChildIndex(video_mc) + 1);
							stream.seek(0);
							pauseVideo();
						}
					}
				}else{
					stream.seek(0);
					//pauseVideo();
				}			
			} else if(code == "NetStream.Pause.Notify"){
				setPausedState();
			} else if(code == "NetStream.Unpause.Notify"){
				setPlayedState();
			} else if(code == "NetStream.Buffer.Full" || code == "NetStream.Buffer.Flush"){
				stageResize();
				if(contains(loader)){removeChild(loader);}
			}
		}
		
		private function handleKeyDown(e:KeyboardEvent):void{
			if(STAGE.getChildByName("stopDragButton") || STAGE.displayState == "fullScreen") return;
			
			if(e.keyCode == 32){
				if(currentState == "playing"){pauseVideo();}else{playVideo();}
			}
		}
		
		private function playVideo(e:MouseEvent = null):void{
			removeWelcome();
			
			if(videoType == "youtube"){
				setPlayedState();
				
				if(!currentVideo){
					youTubePlayer.playVideo();
					return;
				}
				
			}else if(videoType == "vimeo"){
			
			
			}else{
				if(!currentVideo){
					stream.play(currentVideo = videoSrc);
					return;
				}			
				
				setPlayedState();
				
				if(stream.time >= duration - 1){stream.seek(0);}
				
				stream.resume();
			}
		}
		
		public function pauseVideo(e:MouseEvent = null):void{
			setPausedState();
			if(videoType == "youtube"){
				youTubePlayer.pauseVideo();
			}else if(videoType == "vimeo"){
				//vimeoPlayer.pause();
			
			}else{
				stream.pause();
			}
		}
		
		private function seekVideo(e:MouseEvent):void{
			if(duration > 0){
				var newSeek:* = Math.min(duration - 1, (ctrlBar.bar_seek_mc.bar_mc.width / seekbarWidth) * duration);
				if(videoType == "youtube") {
					youTubePlayer.seekTo(newSeek);
				}else if(videoType == "vimeo"){
					//vimeoPlayer.seekTo(newSeek);
					
				}else{
					stream.seek(newSeek);
				}
			}
		}
		
		private function setPlayedState():void{
			currentState = "playing";
			ctrlBar.play_btn.visible = false;
			ctrlBar.pause_btn.visible = true;
			disableCTRLButton(ctrlBar.play_btn, playVideo);
			setCTRLButton(ctrlBar.pause_btn, pauseVideo);
			stageResize();
		}
		
		private function setPausedState():void{
			currentState = "paused";
			ctrlBar.pause_btn.visible = false;
			ctrlBar.play_btn.visible = true;
			disableCTRLButton(ctrlBar.pause_btn, pauseVideo);
			setCTRLButton(ctrlBar.play_btn, playVideo);
		}
		
		private function removeWelcome():void{
			if(contains(welcome)){removeChild(welcome);}
		}


		/*
		 * Scrubbling functionality
		 */
		private function changeScrubState(e:MouseEvent):void{
			if(e.type == "mouseDown"){
				removeWelcome();
				
				lastState = currentState;
				if(videoType == "youtube") {
					youTubePlayer.pauseVideo();
				}else if(videoType == "vimeo"){
					//vimeoPlayer.pause();

				}else{
					stream.pause();
				}
				
				removeEventListener(Event.ENTER_FRAME, updateScrub);
				
			var btn:MovieClip = MovieClip(e.currentTarget);
				btn.stopDragBtn.addEventListener(MouseEvent.MOUSE_MOVE, seekVideo);
				btn.stopDragBtn.addEventListener(MouseEvent.MOUSE_UP, stopScrubDraging);
				STAGE.addEventListener(Event.MOUSE_LEAVE, stopScrubDraging);
				
				STAGE.addChild(btn.stopDragBtn);
			}
		}
		
		private function startScrubDraging(e:MouseEvent):void{
			ctrlBar.bar_seek_mc.scrub_mc.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
			ctrlBar.bar_seek_mc.scrub_mc.x = ctrlBar.bar_seek_mc.sc_mc.x + (ctrlBar.bar_seek_mc.sc_mc.mouseX < 0 ? 0 : (ctrlBar.bar_seek_mc.sc_mc.mouseX > seekbarWidth ? seekbarWidth : ctrlBar.bar_seek_mc.sc_mc.mouseX));
			ctrlBar.bar_seek_mc.scrub_mc.x += ctrlBar.bar_seek_mc.sc_mc.mouseX > 0 ? (ctrlBar.bar_seek_mc.sc_mc.mouseX < seekbarWidth ? -8 : 0) : 0;
			ctrlBar.bar_seek_mc.scrub_mc.y = ctrlBar.bar_seek_mc.sc_mc.y;
			
			var newSeek:* = ((ctrlBar.bar_seek_mc.scrub_mc.x - ctrlBar.bar_seek_mc.sc_mc.x) / seekbarWidth) * duration;
			if(videoType=="youtube") {
				youTubePlayer.seekTo(newSeek);
			}else if(videoType == "vimeo"){
				//vimeoPlayer.seekTo(newSeek);

			}else{
				stream.seek(newSeek);
			}
		}
		
		private function stopScrubDraging(e:Event):void{
			var stopDragButton:MovieClip;
			
			if(e.currentTarget is Stage){
				if(!STAGE.contains(STAGE.getChildByName("stopDragButton"))) return;

				stopDragButton = MovieClip(STAGE.getChildByName("stopDragButton"));
			}else{
				stopDragButton = MovieClip(e.currentTarget);
			}
			
			STAGE.removeEventListener(Event.MOUSE_LEAVE, stopScrubDraging);
			stopDragButton.removeEventListener(MouseEvent.MOUSE_UP, stopScrubDraging);
			stopDragButton.removeEventListener(MouseEvent.MOUSE_MOVE, seekVideo);
			
			if(lastState == "playing"){
				if(videoType == "youtube") {
					youTubePlayer.playVideo();
					if(youTubePlayer.getCurrentTime() < duration){
						setPlayedState();
					}
					
				}else if(videoType == "vimeo"){
					/*vimeoPlayer.play();
					if(vimeoPlayer.getCurrentVideoTime() < duration){
						setPlayedState();
					}*/		
			
				}else{
					stream.resume();
					if(stream.time < duration){
						setPlayedState();
					}
				}
			}
			
			
			lastState = null;
			
			ctrlBar.bar_seek_mc.scrub_mc.x = ctrlBar.bar_seek_mc.scrub_mc.x < ctrlBar.bar_seek_mc.sc_mc.x ? ctrlBar.bar_seek_mc.sc_mc.x : (ctrlBar.bar_seek_mc.scrub_mc.x > ctrlBar.bar_seek_mc.sc_mc.x + seekbarWidth ? ctrlBar.bar_volume_mc.scrub_mc.sc.x + seekbarWidth : ctrlBar.bar_seek_mc.scrub_mc.x);
			ctrlBar.bar_seek_mc.scrub_mc.y = ctrlBar.bar_seek_mc.sc_mc.y;
			
			addEventListener(Event.ENTER_FRAME, updateScrub);
			
			if(STAGE.contains(stopDragButton)){STAGE.removeChild(stopDragButton);}
		}
		
		private var timeV:*;
		private function updateScrub(e:Event):void{
			if(videoType == "youtube") {
				duration = youTubePlayer.getDuration();
				timeV = youTubePlayer.getCurrentTime();
			}else if(videoType == "vimeo"){
				//duration = vimeoPlayer.getDuration();
				//timeV =	vimeoPlayer.getCurrentVideoTime();
			
			}else{
				timeV = stream.time;
			}
			if(duration > 0) ctrlBar.bar_seek_mc.scrub_mc.x = ctrlBar.bar_seek_mc.sc_mc.x + (timeV / duration) * seekbarWidth;
		}


		/*
		 * Volume functionality
		 */
		private function changeVolumeScrubState(e:MouseEvent):void{
			if(e.type == "mouseDown"){
				addEventListener(Event.ENTER_FRAME, updateVolume);
			var btn:MovieClip = MovieClip(e.currentTarget);
				btn.stopDragBtn.addEventListener(MouseEvent.MOUSE_UP, stopVolumeScrubDraging);
				STAGE.addEventListener(Event.MOUSE_LEAVE, stopVolumeScrubDraging);
				STAGE.addChild(btn.stopDragBtn);
			}
		}
		
		private function toggleMute(e:MouseEvent=null):void{
			if(ctrlBar.bar_volume_mc.scrub_mc.x>0){
				ctrlBar.bar_volume_mc.scrub_mc.x = 0;				
				updateVolume();
				setVolume(0);
			}else{
				ctrlBar.bar_volume_mc.scrub_mc.x = ctrlBar.bar_volume_mc.bg_mc.width-ctrlBar.bar_volume_mc.scrub_mc.width;			
				updateVolume();
				setVolume(1);				
			}
		}		
		
		private function startVScrubDraging(e:MouseEvent):void{
			ctrlBar.bar_volume_mc.scrub_mc.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
			ctrlBar.bar_volume_mc.scrub_mc.x = ctrlBar.bar_volume_mc.scrub_mc.sc.x + (ctrlBar.bar_volume_mc.scrub_mc.sc.mouseX < 0 ? 0 : (ctrlBar.bar_volume_mc.scrub_mc.sc.mouseX > volumebarWidth ? volumebarWidth : ctrlBar.bar_volume_mc.scrub_mc.sc.mouseX));
			ctrlBar.bar_volume_mc.scrub_mc.x += ctrlBar.bar_volume_mc.scrub_mc.sc.mouseX > 0 ? (ctrlBar.bar_volume_mc.scrub_mc.sc.mouseX < volumebarWidth ? -5 : 0) : 0;
			ctrlBar.bar_volume_mc.scrub_mc.y = ctrlBar.bar_volume_mc.scrub_mc.sc.y;
		}
		
		private function stopVolumeScrubDraging(e:Event):void{
			var stopDragButton:MovieClip;
			
			if(e.currentTarget is Stage){
				if(!STAGE.contains(STAGE.getChildByName("stopDragButton"))) return;
				
				stopDragButton = MovieClip(STAGE.getChildByName("stopDragButton"));
			}else{
				stopDragButton = MovieClip(e.currentTarget);
			}
			
			STAGE.removeEventListener(Event.MOUSE_LEAVE, stopVolumeScrubDraging);
			stopDragButton.removeEventListener(MouseEvent.MOUSE_UP, stopVolumeScrubDraging);
			removeEventListener(Event.ENTER_FRAME, updateVolume);
			
			
			ctrlBar.bar_volume_mc.scrub_mc.x = ctrlBar.bar_volume_mc.scrub_mc.x < ctrlBar.bar_volume_mc.scrub_mc.sc.x ? ctrlBar.bar_volume_mc.scrub_mc.sc.x : (ctrlBar.bar_volume_mc.scrub_mc.x > ctrlBar.bar_volume_mc.scrub_mc.sc.x + volumebarWidth ? ctrlBar.bar_volume_mc.scrub_mc.sc.x + volumebarWidth : ctrlBar.bar_volume_mc.scrub_mc.x);
			ctrlBar.bar_volume_mc.scrub_mc.y = ctrlBar.bar_volume_mc.scrub_mc.sc.y;
			
			if(STAGE.contains(stopDragButton)){STAGE.removeChild(stopDragButton);}
			
			sharedObj.data.volume = ctrlBar.bar_volume_mc.scrub_mc.x - ctrlBar.bar_volume_mc.scrub_mc.sc.x;
			try{
				sharedObj.flush();
			}catch(er:Error){
				showError("Could not write SharedObject[sharedObj] to disk! Error : " + er);
			}
		}

		private function updateVolume(e:Event=null):void{
			ctrlBar.bar_volume_mc.bar_mc.width = (ctrlBar.bar_volume_mc.scrub_mc.x - ctrlBar.bar_volume_mc.sc_mc.x) > 0 ? ((ctrlBar.bar_volume_mc.scrub_mc.x - ctrlBar.bar_volume_mc.sc_mc.x) < volumebarWidth ? (ctrlBar.bar_volume_mc.scrub_mc.x - ctrlBar.bar_volume_mc.sc_mc.x) : volumebarWidth) : 0.01;
			
			setVolume((ctrlBar.bar_volume_mc.bar_mc.width / volumebarWidth));
		}
		
		private function setVolume(v:Number):void{
			if(videoType == "youtube"){
				youTubePlayer.volume = v*100;
			}else if(videoType == "vimeo"){
			
			}else{				
				soundtransform.volume = v;				
				stream.soundTransform = soundtransform;
			}	
		}
		
		
		/*
		 * Button actions
		 */		 
		public function setCTRLButton(btn:MovieClip, clickFun:Function = null, stateFun:Function = null):void{
			btn.buttonMode = true;
			if(stateFun!= null){
				btn.addEventListener(MouseEvent.MOUSE_OVER, stateFun);
				btn.addEventListener(MouseEvent.MOUSE_OUT, stateFun);
				btn.addEventListener(MouseEvent.MOUSE_DOWN, stateFun);
				btn.addEventListener(MouseEvent.MOUSE_UP, stateFun);
			}else{
				setCTRLBtnOutState(btn);
				btn.addEventListener(MouseEvent.MOUSE_OVER, changeCTRLButtonState);
				btn.addEventListener(MouseEvent.MOUSE_OUT, changeCTRLButtonState);
				btn.addEventListener(MouseEvent.CLICK, clickFun);
			}
		}
		public function disableCTRLButton(btn:MovieClip, clickFcn:Function, stateFun:Function = null):void{
			if(stateFun!= null){
				btn.removeEventListener(MouseEvent.MOUSE_OVER, stateFun);
				btn.removeEventListener(MouseEvent.MOUSE_OUT, stateFun);
				btn.removeEventListener(MouseEvent.MOUSE_DOWN, stateFun);
				btn.removeEventListener(MouseEvent.MOUSE_UP, stateFun);
			}else{
				btn.removeEventListener(MouseEvent.MOUSE_OVER, changeCTRLButtonState);
				btn.removeEventListener(MouseEvent.MOUSE_OUT, changeCTRLButtonState);
				btn.removeEventListener(MouseEvent.CLICK, clickFcn);
			}
		}
		private function setCTRLBtnOverState(btn:MovieClip):void{
			if(btn.getChildByName("gfx")){
				TweenLite.to(btn.gfx, 0.5, {tint:OSFlashVideoPlayer.btnOverColor});
			}
			if(btn.getChildByName("ico")){
				TweenLite.to(btn.ico, 0.5, {tint:OSFlashVideoPlayer.btnHighlightColor, alpha:0.8});
			}
		}
		private function setCTRLBtnOutState(btn:MovieClip):void{
			if(btn.getChildByName("gfx")){
				TweenLite.to(btn.gfx, 0.5, {tint:OSFlashVideoPlayer.btnOutColor});
			}
			if(btn.getChildByName("ico")){
				TweenLite.to(btn.ico, 0.5, {tint:OSFlashVideoPlayer.btnHighlightColor, alpha:1.0});
			}
		}
		private function changeCTRLButtonState(e:MouseEvent):void{		
			switch(e.type){
				case "mouseOver":
					setCTRLBtnOverState(MovieClip(e.currentTarget));
					break;
				default :
					setCTRLBtnOutState(MovieClip(e.currentTarget));
			}
		}
		
		
		/*
		 * Error
		 */
		 private function showError(txt:String=""):void{
		 	MonsterDebugger.trace(this, txt);
		 	ctrlBar.errortxt_mc.visible = true;
			ctrlBar.errortxt_mc.txt.text = txt;
		 }

		 private function hideErrorTxt():void{
		 	MonsterDebugger.trace(this, "hideErrorTxt");
		 	ctrlBar.errortxt_mc.visible = false;
		 }
		 
		private function securityErrorHandler(e:SecurityErrorEvent):void{
			showError("securityErrorHandler: " + e);
		}
		
		private function asyncErrorHandler(e:AsyncErrorEvent):void{
			showError("asyncErrorHandler: " + e.text);
		}
		
		private function youtubeHandleError(event:YouTubeEvent):void{
			var message:String = "";
			switch(event.errorCode){
				case YouTubeError.VIDEO_NOT_FOUND:
					message = "YouTube Video not found ("+event.errorCode+")";
					break;
				case YouTubeError.VIDEO_NOT_ALLOWED:
					message = "YouTube Video not allowed ("+event.errorCode+")";
					break;
				case YouTubeError.EMBEDDING_NOT_ALLOWED:
					message = "YouTube Embedding not allowed ("+event.errorCode+")";
					break;      
				default:
					message = "YouTube Error ("+event.errorCode+")";
					break;
			}
			showError(message);
		}
		
		/*
		 * youtube actions
		 */		
		private function youtubeHandlePlayerLoaded(event:YouTubeEvent):void{
			removeWelcome();
			youTubePlayer.cueVideoById(videoSrc,0,YouTubeVideoQuality.DEFAULT);    	
			initScrubling();
			stageResize();
			if(OSFlashVideoPlayer.autoplay == "true"){playVideo();}
		}

		private function youtubeHandlePlayingState(event:YouTubeEvent):void{
			switch(event.playerState){
				case YouTubePlayingState.BUFFERING:
					MonsterDebugger.trace(this, "YouTubePlayingState: BUFFERING");
					//if(!contains(loader)){addChild(loader);}
					break;
				case YouTubePlayingState.UNSTARTED:
					MonsterDebugger.trace(this, "YouTubePlayingState: UNSTARTED");
					break;
				case YouTubePlayingState.PLAYING:
					MonsterDebugger.trace(this, "YouTubePlayingState: PLAYING");
					//if(contains(loader)){removeChild(loader);}
					addEventListener(Event.ENTER_FRAME, updateLoadingbar);
					setPlayedState();
					break;
				case YouTubePlayingState.PAUSE:
					MonsterDebugger.trace(this, "YouTubePlayingState: PAUSE");
					setPausedState();
					break;
				case YouTubePlayingState.VIDEO_CUED:
					MonsterDebugger.trace(this, "YouTubePlayingState: Video is cued");
					break;
				case YouTubePlayingState.VIDEO_ENDED:
					if(OSFlashVideoPlayer.videoLoop == "false"){
						if(lastState == null){
							if (!contains(welcome)){
								addChildAt(welcome, getChildIndex(video_mc) + 1);
								youTubePlayer.seekTo(0);
								pauseVideo();
							}
						}
					}else{
						youTubePlayer.seekTo(0);
						//pauseVideo();
					}
					break;
				default:
					//"uh what happens?? " + event.playerState;
					break;
			}
			 
		}
	}
}