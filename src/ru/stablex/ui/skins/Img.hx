package ru.stablex.ui.skins;

import flash.geom.Matrix;
import ru.stablex.Assets;
import ru.stablex.ui.widgets.Widget;
import flash.display.BitmapData;

#if ((openfl < "4.0.0") && !woatlas)
import openfl.display.Tilesheet;
import com.nevosoft.isoframework.resources.TextureAtlas;
#end


/**
* Img skin always set widget size the same as `.src` bitmapdata size
*
*/
class Img extends Skin
{    
	private static var matrix:Matrix = new Matrix();
	
	//Asset ID or path to bitmap
    public var src (get,set): String;
    public var _src : String = null;
    /**
    * Use this property instead of `.src`, if you need to directly assign BitmapData instance.
    * `.bitmapData` will be set to null automatically, if you set `.src`.
    * `.src` will be set to null automatically, if you set `.bitmapData`
    */
    public var bitmapData (get,set) : BitmapData;
    private var _bitmapData : BitmapData = null;
    //Smooth bitmap?
    public var smooth : Bool = true;
    // If set to true, the img is scaled to the size of the widget. If false the widget is scaled to the size of the img.
    public var scaleImg = false;
    // If set to true and `scaleImg` is set to true, will maintain the aspect ratio of the image whilst scaling
    public var keepAspect : Bool = false;
    // If set to true as well as `scaleImg` and `keepAspect` the image will be cropped such that it fills the entire widget space
    public var crop : Bool = false;
	
    /**
    * Draw skin
    *
    */
	#if ((openfl < "4.0.0") && !woatlas)
    override public function draw(w:Widget):Void 
	{
		var bmp:BitmapData = this._bitmapData;
		var atlas:TextureAtlas = null;

        if (bmp == null && this.src != null)
		{
			atlas = com.nevosoft.isoframework.ResourceManager.instance.getAtlasOfRegion(this.src);
			if (atlas == null)
			{
				bmp = Assets.getBitmapData(this.src);
				if (bmp == null)
				{
					Err.trigger('Bitmap not found: ' + this.src);
					return;
				}
			}
            
        } else if (bmp == null)
		{
            Err.trigger('Bitmap is not specified');
			return;
        }
		
		if (atlas == null)
		{
#if wodrawrect 
			var tilesheet = com.nevosoft.isoframework.ResourceManager.instance.getTilesheet(this.src);
			if (tilesheet == null)
			{
				tilesheet = com.nevosoft.isoframework.ResourceManager.instance.registerTilesheet(this.src, bmp);
				tilesheet.addTileRect(bmp.rect);
			}
#end
			
			//scale widget to image (default)
			if (!scaleImg) 
			{
				if (w.w != bmp.width || w.h != bmp.height)
				{
					w.resize(bmp.width, bmp.height);
				}
				
#if wodrawrect
				w.graphics.drawTiles(tilesheet, [0.0, 0.0, 0], this.smooth);
#else
				w.graphics.beginBitmapFill(bmp, null, false, this.smooth);
				w.graphics.drawRect(0, 0, bmp.width, bmp.height);
				w.graphics.endFill();
#end
			//scale image to widget
			} 
			else 
			{
				matrix.identity();
				var scaleX = w.w / bmp.width;
				var scaleY = w.h / bmp.height;

				if (keepAspect)
				{
					scaleX = scaleY = (this.crop ? Math.max(scaleX, scaleY) : Math.min(scaleX, scaleY));
					matrix.scale (scaleX, scaleY);
					matrix.translate(
						(w.w - bmp.width * scaleX) * 0.5,
						(w.h - bmp.height * scaleY) * 0.5
					);
				} 
				else 
				{
					matrix.scale(scaleX, scaleY);
				}
				
#if wodrawrect 
				w.graphics.drawTiles(tilesheet, [0.0, 0.0, 0, scaleX, 0.0, 0.0, scaleY], this.smooth, Tilesheet.TILE_TRANS_2x2);
#else
				w.graphics.beginBitmapFill(bmp, matrix, false, this.smooth);
				if (this.crop) 
				{
					w.graphics.drawRect(0, 0, w.w, w.h);
				}
				else 
				{
					w.graphics.drawRect(matrix.tx, matrix.ty, bmp.width * scaleX, bmp.height * scaleY);
				}
				
				w.graphics.endFill();
#end
			}
		}
		else
		{
			var tileId:Int = atlas.getImageId(this.src);
			var tileRect = atlas.getImageRect(this.src);
			if (!scaleImg)
			{
				if (w.w != tileRect.width || w.h != tileRect.height)
				{
					w.resize(tileRect.width, tileRect.height);
				}
				
				w.graphics.drawTiles(atlas.tileSheet, [0, 0, tileId], this.smooth);
			}
			else
			{
				var scaleX = w.w / tileRect.width;
				var scaleY = w.h / tileRect.height;

				matrix.identity();
				
				if (keepAspect) 
				{
					scaleX = scaleY = (this.crop ? Math.max(scaleX, scaleY) : Math.min(scaleX, scaleY));
					matrix.scale (scaleX, scaleY);
					matrix.translate(
						(w.w - tileRect.width * scaleX) * 0.5,
						(w.h - tileRect.height * scaleY) * 0.5
					);
				} 
				else 
				{
					matrix.scale(scaleX, scaleY);
				}
				
				if (this.crop) 
				{
					w.graphics.drawTiles(atlas.tileSheet, [0, 0, tileRect.x, tileRect.y, tileRect.width / scaleX, tileRect.height / scaleY, matrix.a, matrix.b, matrix.c, matrix.d], this.smooth, Tilesheet.TILE_TRANS_2x2 | Tilesheet.TILE_RECT);
				} 
				else 
				{
					w.graphics.drawTiles(atlas.tileSheet, [matrix.tx, matrix.ty, tileId, matrix.a, matrix.b, matrix.c, matrix.d], this.smooth, Tilesheet.TILE_TRANS_2x2);
				}
			}
		}
		
    }//function draw()
	#else
	override public function draw (w:Widget) : Void {
		
		var bmp : BitmapData = this._bitmapData;

        if( bmp == null && this.src != null ){
            bmp = Assets.getBitmapData(this.src);
            if( bmp == null ){
                Err.trigger('Bitmap not found: ' + this.src);
				return;
            }
        }else if( bmp == null ){
            Err.trigger('Bitmap is not specified');
			return;
        }

        //scale widget to image (default)
        if (!scaleImg) {
            if( w.w != bmp.width || w.h != bmp.height ){
                w.resize(bmp.width, bmp.height);
            }
            w.graphics.beginBitmapFill(bmp, null, false, this.smooth);
            w.graphics.drawRect(0, 0, bmp.width, bmp.height);
            w.graphics.endFill();

        //scale image to widget
        } else {
			
			matrix.identity();
            var scaleX = w.w / bmp.width;
            var scaleY = w.h / bmp.height;

            if (keepAspect) {
                scaleX = scaleY = (this.crop ? Math.max(scaleX, scaleY) : Math.min(scaleX, scaleY));
                matrix.scale (scaleX, scaleY);
                matrix.translate(
                    (w.w - bmp.width * scaleX) * 0.5,
                    (w.h - bmp.height * scaleY) * 0.5
                );
            } else {
                matrix.scale(scaleX, scaleY);
            }

            w.graphics.beginBitmapFill(bmp, matrix, false, this.smooth);
            if (this.crop) {
                w.graphics.drawRect(0, 0, w.w, w.h);
            } else {
                w.graphics.drawRect(matrix.tx, matrix.ty, bmp.width * scaleX, bmp.height * scaleY);
            }
            w.graphics.endFill();
        }
    }
	#end


/*******************************************************************************
*   GETTERS / SETTERS
*******************************************************************************/


    /**
    * Getter src
    *
    */
    private inline function get_src() : String {
        return this._src;
    }//function get_src()


    /**
    * Setter src
    *
    */
    private inline function set_src(src:String) : String {
        if( src != null ){
            this._bitmapData = null;
        }
        return this._src = src;
    }//function set_src()


    /**
    * Getter bitmapData
    *
    */
    private inline function get_bitmapData() : BitmapData {
        return this._bitmapData;
    }//function get_bitmapData()


    /**
    * Setter bitmapData
    *
    */
    private inline function set_bitmapData(bitmapData:BitmapData) : BitmapData {
        if( bitmapData != null ){
            this._src = null;
        }
        return this._bitmapData = bitmapData;
    }//function set_bitmapData()

}//class Img
