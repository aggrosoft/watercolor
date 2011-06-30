package watercolor.utils
{
	
	import flash.geom.Matrix;
	import flash.utils.Dictionary;
	
	import mx.geom.Transform;
	
	import watercolor.elements.Element;
	import watercolor.factories.svg.util.SVGAttributes;

	public class SVGUtil
	{

		public var SVGtoWCmap:Dictionary = new Dictionary();

		public function SVGUtil()
		{
			SVGtoWCmap['rect'] = rectFactory;
		}
		
		public static function prepareForWatercolor(data:XML):XML{
			data = convertStylesToAttributes(data);
			data = inheritAttributes(data);
			return data;
		}
		
		public static function convertStylesToAttributes(data:XML):XML{
			//Take the @style attribute and make real xml attributes out of it
			styleToAttributes(data);
			//Do this for all children
			var qname:QName = new QName(null, "*");
			for each(var childNode:XML in data[qname])
			{
				convertStylesToAttributes(childNode);
			}
			return data;
		}
		
		protected static function styleToAttributes(node:XML):void{
			if(node.@style.length() > 0){
				var attributes:Array = SVGAttributes.parseStyle(node.@style);
				for each(var o:Object in attributes){
					node["@"+o.key] = o.value;
				}
			}
		}
		
		public static function inheritAttributes(data:XML):XML{
			
			inheritAttributesToChildren(data);
			
			var qname:QName = new QName(null, "*");
			for each(var childNode:XML in data[qname])
			{
				inheritAttributes(childNode);
			}
			return data;
		}
		
		protected static function inheritAttributesToChildren(node:XML):void{
			var attributeNames:XMLList = node.attributes();
			var attributesToCopy:Object = getAttributesNeededToInherit(attributeNames);
			
			for(var key:String in attributesToCopy){
				var val:String = attributesToCopy[key];
				var qname:QName = new QName(null, "*");
				for each(var childNode:XML in node[qname])
				{
					//Only if not defined in child
					if(childNode["@"+key].length() == 0){
						childNode["@"+key] = val;	
					}					
				}
			}
		}
		
		protected static var inheritedAttributes:Array = [
			'clip-rule','color','color-interpolation',
			'color-interpolation-filters', 'color-profile',
			'color-rendering', 'cursor', 'direction', 'fill',
			'fill-opacity','fill-rule','font','font-family',
			'font-size','font-size-adjust','font-stretch',
			'font-style','font-variant','font-weight',
			'glyph-orientation-horizontal','glyph-orientation-vertical',
			'image-rendering','kerning','letter-spacing',
			'marker','marker-end','marker-mid','marker-start',
			'pointer-events','shape-rendering','stroke',
			'stroke-dasharray','stroke-dashoffset',
			'stroke-linecap','stroke-linejoin','stroke-miterlimit',
			'stroke-opacity','stroke-width','text-anchor',
			'text-rendering','visibility','word-spacing',
			'writing-mode'
		];
		
		protected static function getAttributesNeededToInherit(xml:XMLList):Object{
			var len:uint = xml.length();
			var result:Object = new Object();
			for(var i:uint = 0; i<len; i++){
				var attrName:String = xml[i].name();
				var attrValue:String = xml[i].toString();
				if(inheritedAttributes.indexOf(attrName) !== -1){
					result[attrName] = attrValue;
				}
			}
			return result;
		}
		
		public static function getTransform(svgtransform:String):Transform{
			/*
			The value of the ‘transform’ attribute is a <transform-list>, 
			which is defined as a list of transform definitions, which are applied 
			in the order provided. The individual transform definitions are separated by 
			whitespace and/or a comma.
			
			transform="translate(20,20) scale(2)"
			or
			transform="translate(20,20),scale(2)"
			
			*/
			
			//Split into functions
			var funcs:Array = svgtransform.split(/(?<!\d)[,\s](?!\()/);
			var flen:uint = funcs.length;
			
			//Now apply one function after the other to our transform
			var t:Transform = new Transform();
			var m:Matrix = new Matrix();
			
			for(var i:uint=0;i<flen;i++){
				var func:String = funcs[i];
				var fsplit:Array = func.split("(");
				var fname:String = fsplit[0];
				var fparams:String = fsplit[1];
				fparams = fparams.replace(")","");
				var paramArray:Array = fparams.split(",");
				
				switch(fname){
					case "matrix":
						m = new Matrix(paramArray[0],paramArray[1],paramArray[2],paramArray[3],paramArray[4],paramArray[5]);
						break;
					case "translate":
						var tX:Number = Number(paramArray[0]);
						var tY:Number = paramArray.length > 1 ? Number(paramArray[1]) : 0;
						m.translate(tX,tY);
						break;
					case "scale":
						var sX:Number = Number(paramArray[0]);
						var sY:Number = paramArray.length > 1 ? Number(paramArray[1]) : sX;
						m.scale(sX,sY);
						break;
					case "rotate":
						var angle:Number = Number(paramArray[0]);
						if(paramArray.length > 1){
							var rtX:Number = Number(paramArray[1]);
							var rtY:Number = Number(paramArray[2]);
							m.translate(rtX,rtY);
							m.rotate(angle);
							m.translate(rtX*-1,rtY*-1);
						}else{
							m.rotate(angle);							
						}
						break;
					//TODO: skewX, skewY
				}				
			}
			
			t.matrix = m;
			return t;
		}
		
		public static function convertSVGtoWatercolor(data:XML, map:Dictionary = null):Vector.<Element>
		{
			var result:Vector.<Element>;
			return result;
		}

		public static function rectFactory(data:XML):Element
		{
			var result:Element;
			return result;
		}
	}
}