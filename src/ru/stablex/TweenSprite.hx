package ru.stablex;

import flash.display.DisplayObject;
import flash.display.Sprite;

/**
* class TweenSprite implements easy access to <type>motion.Actuate</type> methods and manages registered
* eventListeners
*
*/
class TweenSprite extends Sprite{

    //registered event listeners
    #if haxe3
    private var _listeners : Map<String,List<Dynamic->Void>>;
    #else
    private var _listeners : Hash<List<Dynamic->Void>>;
    #end


    /**
    * Equal to <type>flash.display.Sprite</type>.addEventListener except this ignores `useCapture` and does not support weak references.
    *
    */
    override public function addEventListener (type:String, listener:Dynamic->Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false) : Void{
        //if listeners list is not created
        if( this._listeners == null ){
            #if haxe3
            this._listeners = new Map();
            #else
            this._listeners = new Hash();
            #end
        }

        var listeners : List<Dynamic->Void> = this._listeners.get(type);

        //if we don't have list of listeners for this event, create one
        if( listeners == null ){
            listeners = new List();
            listeners.add(listener);
            this._listeners.set(type, listeners);

        //add listener to the list
        }else{
            listeners.add(listener);
        }

        super.addEventListener(type, listener, false, priority, useWeakReference);
    }//function addEventListener()


    /**
    * Add event listener only if this listener is still not added to this object
    * Ignores `useCapture` and `useWeakReference`
    *
    * @return whether listener was added
    */
    public function addUniqueListener (type:String, listener:Dynamic->Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false) : Bool{
        if( this.hasListener(type, listener) ){
            return false;
        }

        this.addEventListener(type, listener, useCapture, priority, useWeakReference);
        return true;
    }//function addEventListener()


    /**
    * Equal to <type>flash.display.Sprite</type>.removeEventListener except this ignores `useCapture`
    *
    */
    override public function removeEventListener (type:String, listener:Dynamic->Void, useCapture:Bool = false) : Void{
        //remove listener from the list of registered listeners
        if( this._listeners != null ){
            if( this._listeners.exists(type) ) this._listeners.get(type).remove(listener);
        }

        super.removeEventListener(type, listener, false);
    }//function removeEventListener()


    /**
    * Removes all listeners registered for this event
    *
    */
    public function clearEvent (type:String) : Void {
        if( this._listeners != null ){
            var listeners : List<Dynamic->Void> = this._listeners.get(type);
            if( listeners != null ){
                while( listeners.length > 0 ){
                    this.removeEventListener(type, listeners.first());
                }
            }
        }
    }//function clearEvent()


    /**
    * Indicates whether this object has this listener registered for specified event type
    *
    */
    public function hasListener(event:String, listener:Dynamic->Void) : Bool {
        if( this._listeners == null ) return false;

        var lst : List<Dynamic->Void> = this._listeners.get(event);
        if( lst == null ) return false;

        for(l in lst){
            if( l == listener ) return true;
        }

        return false;
    }//function hasListener()


    /**
    * Easy access to <type>motion.Actuate</type>.tween for this object. Equals to <type>motion.Actuate</type>.tween(this, ....).
    * Parameter `easing` should be like this: 'Quad.easeInOut' or 'Back.easeIn' etc. By default it is 'Linear.easeNone'
    *
    */
    public function tween (duration:Float, properties:Dynamic, easing:String = 'Linear.easeNone', overwrite:Bool = true, customActuator = null) {

    }//function tween()


    /**
    * Calls <type>motion.Actuate</type>.stop() for this object. By default `complete` and `sendEvent` equal to false
    *
    */
    public function tweenStop(properties:Dynamic = null, complete:Bool = false, sendEvent:Bool = false) : Void {
    }//function tweenStop()


    /**
    * Free object. Removes all registered eventListeners and children. Also removes itself from parent's display list.
    * If `recursive` is true (by default), tries to call .free(true) for each child (TweenSprite instances only)
    */
    public function free (recursive:Bool = true) : Void{
        this.tweenStop();

        //clear listeners
        if( this._listeners != null ){
            for(event in this._listeners.keys()){
                var listeners : List<Dynamic->Void> = this._listeners.get(event);
                while( !listeners.isEmpty() ){
                    this.removeEventListener(event, listeners.first());
                }
            }
        }

        //release children
        this.freeChildren(recursive);

        //removing from parent's display list
        if( this.parent != null ){
            this.parent.removeChild(this);
        }
    }//function free()


    /**
    * Removes children. If `recursive` = true (default) tries to call .free(true) for TweenSprite instances
    */
    public function freeChildren(recursive:Bool = true) : Void {
        var child : DisplayObject;
        while( this.numChildren > 0 ){
            child = this.removeChildAt(0);

            if( recursive && Std.is(child, TweenSprite) ){
                cast(child, TweenSprite).free(true);
            }
        }
    }//function freeChildren()


}//class TweenSprite