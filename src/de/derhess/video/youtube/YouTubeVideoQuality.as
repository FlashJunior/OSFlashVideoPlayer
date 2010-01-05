package de.derhess.video.youtube
{
    
	/**
	 * released under MIT License (X11)
	 * http://www.opensource.org/licenses/mit-license.php
	 * 
	 * Class stores the YouTube Player resolution formats
	 * 
	 * @author Florian Weil [derhess.de, Deutschland]
	 * @see http://blog.derhess.de
	 */
	 
    public class YouTubeVideoQuality
    {
        //--------------------------------------------------------------------------
        //
        //  Class variables
        //
        //--------------------------------------------------------------------------
		public static const SMALL:String = "small"; // Player resolution less than 640px by 360px.
		public static const MEDIUM:String = "medium"; // Minimum player resolution of 640px by 360px.
		public static const LARGE:String = "large"; // Minimum player resolution of 854px by 480px.
		public static const HD720:String = "hd720"; // Minimum player resolution of 1280px by 720px.
		public static const DEFAULT:String = "default"; //YouTube selects the appropriate playback quality.
		public static const ALL:Array = ["default","small","medium","large","hd720"];
        //--------------------------------------------------------------------------
        //
        //  Initialization
        //
        //--------------------------------------------------------------------------
        
        public function YouTubeVideoQuality()
        {
			throw new Error("YouTubeVideoQuality is a static class. Creating instances are not allowed!");
        }
        
        
        
        
    }
}