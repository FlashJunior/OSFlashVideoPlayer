package de.derhess.video.youtube
{
    
	/**
	 * released under MIT License (X11)
	 * http://www.opensource.org/licenses/mit-license.php
	 * 
	 * Class stores the YouTube Errors
	 * 
	 * @author Florian Weil [derhess.de, Deutschland]
	 * @see http://blog.derhess.de
	 */
	 
    public class YouTubeError
    {
        //--------------------------------------------------------------------------
        //
        //  Class variables
        //
        //--------------------------------------------------------------------------
		public static const VIDEO_NOT_FOUND:Number = 100;
		public static const VIDEO_NOT_ALLOWED:Number = 101; 
		public static const EMBEDDING_NOT_ALLOWED:Number = 150;
        //--------------------------------------------------------------------------
        //
        //  Initialization
        //
        //--------------------------------------------------------------------------
        
        public function YouTubeError()
        {
			throw new Error("YouTubeError is a static class. Creating instances are not allowed!");
        }
        
        
        
        
    }
}