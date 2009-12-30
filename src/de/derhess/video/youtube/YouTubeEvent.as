package de.derhess.video.youtube
{
	 /**
	 * released under MIT License (X11)
	 * http://www.opensource.org/licenses/mit-license.php
	 * 
	 * Class for managing the YouTube Events for the YouTube Flex Player
	 * 
	 * @author Florian Weil [derhess.de, Deutschland]
	 * @see http://blog.derhess.de
	 */
     
	import flash.events.Event; 
	 
    public class YouTubeEvent extends Event
    {
        //--------------------------------------------------------------------------
        //
        //  Class variables
        //
        //--------------------------------------------------------------------------
		public static const STATUS:String = "youtubeStatus";
		public static const PLAYER_LOADED:String = "youtubePlayerLoaded";
		public static const ERROR:String = "youtubeError";
		public static const VIDEO_QUALITY_CHANGE:String = "youtubeVideoQuality";
        //--------------------------------------------------------------------------
        //
        //  Initialization
        //
        //--------------------------------------------------------------------------
        
        public function YouTubeEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false)
        {
            super(type, bubbles, cancelable);
            init();
        }
        /**
         * @private
         * Initializes the instance.
         */
        private function init():void
        {
            currentTime = 0;
			duration = 0;
			playerState = -1;
			playbackQuality = "default";
			errorCode = 0;
        }
        
        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------
        
        
        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------
        public var currentTime:Number;
		public var duration:Number;
		public var playerState:Number;
		public var errorCode:Number;
		public var playbackQuality:String;
        
        //--------------------------------------------------------------------------
        //
        //  Additional getters and setters
        //
        //--------------------------------------------------------------------------
        
        
        
        //--------------------------------------------------------------------------
        //
        //  API
        //
        //--------------------------------------------------------------------------
        
        /**
         * Completely destroys the instance and frees all objects for the garbage
         * collector by setting their references to null.
         */
        public function destroy():void
        {
            
        }
        
        //--------------------------------------------------------------------------
        //
        //  Overridden methods: _SuperClassName_
        //
        //--------------------------------------------------------------------------
        override public function clone():Event 
        {	
        	var event:YouTubeEvent = new YouTubeEvent(type);
        	event.playerState = this.playerState;
        	event.currentTime = this.currentTime;
        	event.duration = this.duration;
        	event.errorCode = this.errorCode;
        	event.playbackQuality = this.playbackQuality;
            return event;
        }
        
        override public function toString():String 
        {
            return "YouTubeEvent{playerState:" + playerState + ", playbackQuality:" + playbackQuality +", currentTime:" + currentTime.toString()+",duration:"+duration.toString()+", errorCode:"+errorCode.toString()+"}";
        }
        
        
        
    }
}