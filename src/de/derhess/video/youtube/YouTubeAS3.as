package de.derhess.video.youtube
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import mx.core.UIComponent;
	
    //--------------------------------------
	//  Events
	//--------------------------------------
    [Event(name="youtubeStatus", type="de.derhess.video.youtube.YouTubeEvent")]
	[Event(name="youtubePlayerLoaded", type="de.derhess.video.youtube.YouTubeEvent")]
	[Event(name="youtubeError", type="de.derhess.video.youtube.YouTubeEvent")]
	[Event(name="youtubeVideoQuality", type="de.derhess.video.youtube.YouTubeEvent")]
	
    /**
	 * released under MIT License (X11)
	 * http://www.opensource.org/licenses/mit-license.php
	 * 
	 * Class  YouTube Player 
	 * 
	 * @author Florian Weil [derhess.de, Deutschland]
	 * @see http://blog.derhess.de
	 */
    public class YouTubeAS3 extends UIComponent
    {
        //--------------------------------------------------------------------------
        //
        //  Class variables
        //
        //--------------------------------------------------------------------------
        
        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------
        private var loader:Loader;
		private var player:Object;
		private var isPlayerLoaded:Boolean = false;
        //--------------------------------------------------------------------------
        //
        //  Initialization
        //
        //--------------------------------------------------------------------------
        public function YouTubeAS3()
        {
        	
        }
        
        override protected function createChildren():void 
        {
        	super.createChildren();
        	loader = new Loader();
        	loader.contentLoaderInfo.addEventListener(Event.INIT, handleLoaderInit);
			loader.load(new URLRequest("http://www.youtube.com/apiplayer?version=3"));
        }
        //--------------------------------------------------------------------------
        //
        //  toString
        //
        //--------------------------------------------------------------------------
		override public function toString():String
		{
			return "YouTubeAS3{}";
		}
        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------
        /** @private */
		private var _volume:int = 100;
		/**
		 * Accepts an integer between 0 and 100.
		 */
		[Bindable(event="youtube_volumeChanged")]
		public function get volume():int
		{
			return _volume;	
		}
		public function set volume(value:int):void
		{
			_volume = value;
			dispatchEvent(new Event("youtube_volumeChanged"));
			if(isPlayerLoaded)
				player.setVolume(value);
		}
		
		/** @private */
		private var _playerState:Number = -1;;
		/**
		 * Read-only!!
		 */
		[Bindable(event="youtube_playerStateChanged")]
		public function get playerState():Number
		{
			return _playerState;	
		}
		public function set playerState(value:Number):void
		{
			_playerState = value;
			dispatchEvent(new Event("youtube_playerStateChanged"));
		}
		
		/** @private */
		private var _playbackQuality:String = "default";
		/**
		 *
		 */
		[Bindable(event="youtube_playbackQualityChanged")]
		public function get playbackQuality():String
		{
			return _playbackQuality;	
		}
		public function set playbackQuality(value:String):void
		{
			_playbackQuality = value;
			if(isPlayerLoaded)
				player.setPlaybackQuality(value);
			dispatchEvent(new Event("youtube_playbackQualityChanged"));
			
		}
        
        //--------------------------------------------------------------------------
        //
        //  override Functions of the superclass
        //
        //--------------------------------------------------------------------------
        override protected function commitProperties():void 
        {
        	super.commitProperties();
        }
        
        override protected function measure():void 
        {
        	super.measure();
		}
		
        
        override protected function updateDisplayList(unscaledWidth:Number,unscaledHeight:Number):void 
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			
			if(isPlayerLoaded)
				player.setSize(unscaledWidth,unscaledHeight);
		}

        //--------------------------------------------------------------------------
        //
        //  Additional getters and setters
        //
        //--------------------------------------------------------------------------
        public function isMuted():Boolean
        {
        	if(isPlayerLoaded)
        		return player.isMuted();
        	else
        		return false;
        }
        
        public function getVideoBytesLoaded():Number
        {
        	
        	if(isPlayerLoaded)
        		return player.getVideoBytesLoaded();
        	else
        		return 0;
        }
        
        public function getVideoBytesTotal():Number
        {
        	if(isPlayerLoaded)
        		return player.getVideoBytesTotal();
        	else
        		return 0;
        }
        
        public function getVideoStartBytes():Number
        {
        	if(isPlayerLoaded)
        		return player.getVideoStartBytes();
        	else
        		return 0;
        }
        
        
        
        public function getCurrentTime():Number
        {
        	if(isPlayerLoaded)
        		return player.getCurrentTime();
        	else
        		return 0;
        }
        
        public function getDuration():Number
        {
        	if(isPlayerLoaded)
        		return player.getDuration();
        	else
        		return 0
        }
        
        public function getVideoUrl():String
        {
        	if(isPlayerLoaded)
        		return player.getVideoUrl();
        	else
        		return "";
        }
        
        public function getVideoEmbedCode():String
        {
        	if(isPlayerLoaded)
        		return player.getVideoEmbedCode();
        	else
        		return "";
        }
        
        public function getAvailableQualityLevels():Array
        {
        	if(isPlayerLoaded)
        		return player.getAvailableQualityLevels();
        	else
        		return [];
        }
        //--------------------------------------------------------------------------
        //
        //  Methods
        //
        //--------------------------------------------------------------------------
        
        //--------------------------------------------------------------------------
        //
        //  API
        //
        //--------------------------------------------------------------------------
        
        //----------------------------------
		//  load new YouTube videos - look at the Queueing functions YouTube documentation 
		//----------------------------------
        public function cueVideoById(videoId:String, startSeconds:Number, suggestedQuality:String):void
        {
        	if(isPlayerLoaded)
	        	player.cueVideoById(videoId, startSeconds, suggestedQuality);
        	
        }
        
        public function loadVideoById(videoId:String, startSeconds:Number, suggestedQuality:String):void
        {
        	if(isPlayerLoaded)
	        	player.loadVideoById(videoId, startSeconds, suggestedQuality);
        }
        
        public function cueVideoByUrl(mediaContentUrl:String, startSeconds:Number):void
        {
        	if(isPlayerLoaded)
        		player.cueVideoByUrl(mediaContentUrl, startSeconds);
    	}
    	
    	public function loadVideoByUrl(mediaContentUrl:String, startSeconds:Number):void
    	{
    		if(isPlayerLoaded)
    			player.loadVideoByUrl(mediaContentUrl, startSeconds);
    	}
     
        //----------------------------------
		//  Playback controls and player settings
		//----------------------------------
		public function playVideo():void
		{
			if(isPlayerLoaded)
				player.playVideo();
		}
		
		public function pauseVideo():void
		{
			if(isPlayerLoaded)
				player.pauseVideo();
		}
		
		public function stopVideo():void
		{
			if(isPlayerLoaded)
				player.stopVideo();
		}
		
		public function seekTo(seconds:Number, allowSeekAhead:Boolean = true):void
		{
			if(isPlayerLoaded)
				player.seekTo(seconds, allowSeekAhead);	
		}
		//----------------------------------
		//  Sound controll
		//----------------------------------
		public function mute():void
		{
			if(isPlayerLoaded)
				player.mute();
		}
		
		public function unMute():void
		{
			if(isPlayerLoaded)
				player.unMute();
		}
		
		public function destroy():void
		{
			volume = 0;
			if(isPlayerLoaded && player)
			{
				player.removeEventListener("onReady", handlePlayerReady);
			    player.removeEventListener("onError", handlePlayerError);
			    player.removeEventListener("onStateChange", handlePlayerStateChange);
			    player.removeEventListener("onPlaybackQualityChange", handleVideoPlaybackQualityChange);
		    
				player.destroy();
				
				loader.unload();
				loader = null;
				playerState = YouTubePlayingState.UNSTARTED;
			}
		}

        //--------------------------------------------------------------------------
        //
        //  Eventhandling
        //
        //--------------------------------------------------------------------------
        private function handleLoaderInit(event:Event):void 
        {
		    addChild(loader);
		    player = loader.content;
		    player.addEventListener("onReady", handlePlayerReady);
		    player.addEventListener("onError", handlePlayerError);
		    player.addEventListener("onStateChange", handlePlayerStateChange);
		    player.addEventListener("onPlaybackQualityChange", handleVideoPlaybackQualityChange);
		    
		}

		//--------------------------------------------------------------------------
        //
        //  Broadcasting
        //
        //--------------------------------------------------------------------------
		private function handlePlayerReady(event:Event):void 
		{
		    // Event.data contains the event parameter, which is the Player API ID 
		    //trace("player ready:", Object(event).data);
		
		    // Once this event has been dispatched by the player, we can use
		    // cueVideoById, loadVideoById, cueVideoByUrl and loadVideoByUrl
		    // to load a particular YouTube video.
		    isPlayerLoaded = true;
		    
		    player.x = 0;
		    player.y = 0;
		    player.setSize(this.width,this.height);
		    player.setVolume(_volume);
		    var myEvent:YouTubeEvent = new YouTubeEvent(YouTubeEvent.PLAYER_LOADED);
		    dispatchEvent(myEvent);
		}
		
		private function handlePlayerError(event:Event):void 
		{
		    // Event.data contains the event parameter, which is the error code
		    //trace("player error:", Object(event).data);
		    var myEvent:YouTubeEvent = new YouTubeEvent(YouTubeEvent.ERROR);
		    myEvent.errorCode = Object(event).data as Number;
		    dispatchEvent(myEvent);
		}
		
		private function handlePlayerStateChange(event:Event):void 
		{
		    // Event.data contains the event parameter, which is the new player state
		    //trace("player state:", Object(event).data);
		  	this.playerState = Object(event).data as Number;
		  	
		  	var myEvent:YouTubeEvent = new YouTubeEvent(YouTubeEvent.STATUS);
		    myEvent.playerState = playerState;
		    
		    if((playerState != YouTubePlayingState.UNSTARTED) && (playerState != YouTubePlayingState.BUFFERING))
		    {
		    	myEvent.currentTime = getCurrentTime();
		    	myEvent.duration = getDuration();
		    	myEvent.playbackQuality = playbackQuality;
		    } 
		    
		    dispatchEvent(myEvent);
		}
		
		private function handleVideoPlaybackQualityChange(event:Event):void 
		{
		    // Event.data contains the event parameter, which is the new video quality
		    //trace("video quality:", Object(event).data);
		    _playbackQuality = Object(event).data as String;
			dispatchEvent(new Event("youtube_playbackQualityChanged"));
			
			var myEvent:YouTubeEvent = new YouTubeEvent(YouTubeEvent.VIDEO_QUALITY_CHANGE);
		    myEvent.playerState = playerState;
		    myEvent.playbackQuality = _playbackQuality;
		    
		    if((playerState != YouTubePlayingState.UNSTARTED) && (playerState != YouTubePlayingState.BUFFERING))
		    {
		    	myEvent.currentTime = getCurrentTime();
		    	myEvent.duration = getDuration();
		    } 
		    
		    dispatchEvent(myEvent);
		}

    }
}