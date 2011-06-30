package watercolor.factories.svg
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import mx.utils.Base64Decoder;
	
	import spark.primitives.BitmapImage;
	import spark.primitives.Rect;
	
	import watercolor.factories.svg.namespaces.ns_xlink;
	import watercolor.factories.svg.util.SVGAttributes;
	import watercolor.factories.svg.util.URIManager;

	/**
	 * Spark BitmapImage Factory
	 * 
	 * SVG Documentation: http://www.w3.org/TR/SVG/struct.html#ImageElement
	 * Spark Documentation: http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/spark/primitives/BitmapImage.html
	 */ 
	public class BitmapImageFactory
	{
		public function BitmapImageFactory()
		{
		}
		
		/**
		 * Create Spark BitmapImage from SVG Image
		 */ 
		public static function createSparkFromSVG(node:XML, uriManager:URIManager, element:BitmapImage = null):BitmapImage
		{
			if (!element)
			{
				element = new BitmapImage();
			}
			
			// Decorate through parents
			GraphicElementFactory.createSparkFromSVG(node, uriManager, element);
			
			// fillmode - The default value is BitmapFillMode.SCALE.
			
			// TODO: svg preserveAspectRatio - Look into supporting all the various 
			// 		 values such as meet, slice, xMin, xMid, etc.
			// 		 @see http://www.w3.org/TR/SVG/coords.html#PreserveAspectRatioAttribute
			
			// smooth - The default value is false.
			
			// source
			var qnEntity:QName = new QName(ns_xlink, "href"); 
			var xlinkEntity:XMLList = node.attribute(qnEntity);
			
			// TODO: Figure out why old svg library had both xLinkEntity and @ns_xlink::href
			var d:String = "";
			
			if(xlinkEntity.length() > 0)
			{
				d = xlinkEntity;
			}
			
			if(node.@ns_xlink::href.length() > 0)
			{
				d = node.@ns_xlink::href;
			}
			
			//Parse Embedded images
						
			if(d.indexOf("data:") == 0){
				//Pull out datatype
				var parts:Array = d.split(";");
				var meta:String = parts[0];
				var data:String = parts[1];
				var splData:Array = data.split(",");
				data = splData[1];
				
				//TODO: check meta what type of image should be decoded
				var dec:Base64Decoder = new Base64Decoder();
				dec.decode(data);
				var bytes:ByteArray = dec.flush();
				var ldr:Loader = new Loader();
				ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event){
					var decodedBitmapData:BitmapData = Bitmap(e.target.content).bitmapData;
					element.source = decodedBitmapData;
				});
				ldr.loadBytes(bytes);
				
				
			}else{
				element.source = d;
			}
			
			
			
			
			return element;
		}
		
		public static function createSVGFromSpark(element:BitmapImage):XML
		{
			// TODO: Generate SVG
			return null;
		}
	}
}