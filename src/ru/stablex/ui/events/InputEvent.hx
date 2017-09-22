package ru.stablex.ui.events;

import flash.events.MouseEvent;
import flash.events.TouchEvent;

#if !mobile
typedef InputEvent = MouseEvent;

@:enum
abstract InputEventType(String) from String to String {
	var CLICK = "click";
	var INPUT_DOWN = "mouseDown";
	var INPUT_MOVE = "mouseMove";
	var INPUT_OUT = "mouseOut";
	var INPUT_OVER = "mouseOver";
	var INPUT_UP = "mouseUp";
}
#else
typedef InputEvent = TouchEvent;

/*@:enum
abstract InputEventType(String) from String to String {
	var CLICK = TouchEvent.TOUCH_TAP;
	var INPUT_DOWN = TouchEvent.TOUCH_BEGIN;
	var INPUT_MOVE = TouchEvent.TOUCH_MOVE;
	var INPUT_OUT = TouchEvent.TOUCH_OUT;
	var INPUT_OVER = TouchEvent.TOUCH_OVER;
	var INPUT_UP = TouchEvent.TOUCH_END;
}*/


@:enum
abstract InputEventType(String) from String to String {
	var CLICK = "touchTap";
	var INPUT_DOWN = "touchBegin";
	var INPUT_MOVE = "touchMove";
	var INPUT_OUT = "touchOut";
	var INPUT_OVER = "touchOver";
	var INPUT_UP = "touchEnd";
}

#end