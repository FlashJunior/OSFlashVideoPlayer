package de.derhess.video.youtube
{
    
	/**
	 * released under MIT License (X11)
	 * http://www.opensource.org/licenses/mit-license.php
	 * 
	 * Class stores the PlayingStates of the VideoPlayer
	 * 
	 * @author Florian Weil [derhess.de, Deutschland]
	 * @see http://blog.derhess.de
	 */
	 
    public class YouTubePlayingState
    {
        //--------------------------------------------------------------------------
        //
        //  Class variables
        //
        //--------------------------------------------------------------------------
        public static const UNSTARTED:Number = -1; // will be dispatched when player is not already loaded
		public static const PLAYING:Number = 1; // will be dispatched when the video is playing
		public static const PAUSE:Number = 2; // will be dispatched when the video is paused
		public static const VIDEO_ENDED:Number = 0; // will be dispatched when the playhead reach the end of the video
		public static const BUFFERING:Number = 3; // will be dispatched when the playhead reach the end of the video
		public static const VIDEO_CUED:Number = 5;
        //--------------------------------------------------------------------------
        //
        //  Initialization
        //
        //--------------------------------------------------------------------------
        
        public function YouTubePlayingState()
        {
			throw new Error("YouTubePlayingState is a static class. Creating instances are not allowed!");
        }
        
        
        
        
    }
}