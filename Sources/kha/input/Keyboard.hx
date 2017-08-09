package kha.input;

import haxe.Timer;
import js.Browser;
import js.html.FocusEvent;
import js.html.InputEvent;
import js.html.MouseEvent;
import kha.network.Controller;

@:allow(kha.SystemImpl)
@:expose
class Keyboard extends Controller {
	private static var textInput:Dynamic;
	private static var enableTextEvents:Bool = false;
	public static function get(num: Int = 0): Keyboard {
		return SystemImpl.getKeyboard(num);
	}
	
	public function notify(downListener: KeyCode->Void, upListener: KeyCode->Void, pressListener: String->Void = null): Void {
		if (downListener != null) downListeners.push(downListener);
		if (upListener != null) upListeners.push(upListener);
		if (pressListener != null) pressListeners.push(pressListener);
	}
	
	public function remove(downListener: KeyCode->Void, upListener: KeyCode->Void, pressListener: String->Void): Void {
		if (downListener != null) downListeners.remove(downListener);
		if (upListener != null) upListeners.remove(upListener);
		if (pressListener != null) pressListeners.remove(pressListener);
	}
	
	public function show(): Void {
		if (textInput == null) {
				
				textInput = cast Browser.document.createElement ('input');
				textInput.type = 'text';
				textInput.style.position = 'absolute';
				textInput.style.opacity = "0";
				textInput.style.color = "transparent";
				textInput.value = "";
				
				untyped textInput.autocapitalize = "off";
				untyped textInput.autocorrect = "off";
				textInput.autocomplete = "off";
				
				// TODO: Position for mobile browsers better
				
				textInput.style.left = "0px";
				textInput.style.top = "50%";
				
				if (~/(iPad|iPhone|iPod).*OS 8_/gi.match (Browser.window.navigator.userAgent)) {
					
					textInput.style.fontSize = "0px";
					textInput.style.width = '0px';
					textInput.style.height = '0px';
					
				} else {
					
					textInput.style.width = '1px';
					textInput.style.height = '1px';
					
				}
				
				untyped (textInput.style).pointerEvents = 'none';
				textInput.style.zIndex = "-10000000";
				
				Browser.document.body.appendChild (textInput);
				
			}
			
			if (!enableTextEvents) {
				
				textInput.addEventListener ('input', handleInputEvent, true);
				textInput.addEventListener ('blur', handleFocusEvent, true);
				
			}
			
			textInput.focus ();
			
			enableTextEvents = true;
	}

	public function hide(): Void {
		if (textInput != null) {
			
			textInput.removeEventListener ('input', handleInputEvent, true);
			textInput.removeEventListener ('blur', handleFocusEvent, true);
			
			textInput.blur ();
			
		}
		
		enableTextEvents = false;
	}
	
	private function handleInputEvent (event:InputEvent):Void {
		
		if (!event.isChar()) return;
		for (listener in pressListeners) {
			listener(String.fromCharCode(event.which));
		}
	}
	
	
	private function handleMouseEvent (event:MouseEvent):Void {
		
		
		
	}
	
	private function handleFocusEvent (event:FocusEvent):Void {
		
		if (enableTextEvents) {
			
			Timer.delay (function () { textInput.focus (); }, 20);
			
		}
		
	}

	private static var instance: Keyboard;
	private var downListeners: Array<KeyCode->Void>;
	private var upListeners: Array<KeyCode->Void>;
	private var pressListeners: Array<String->Void>;
	
	private function new() {
		super();
		downListeners = [];
		upListeners = [];
		pressListeners = [];
		instance = this;
	}
	
	@input
	private function sendDownEvent(code: KeyCode): Void {
		#if sys_server
		//js.Node.console.log(kha.Scheduler.time() + " Down: " + key + " from " + kha.network.Session.the().me.id);
		#end
		for (listener in downListeners) {
			listener(code);
		}
	}
	
	@input
	private function sendUpEvent(code: KeyCode): Void {
		#if sys_server
		//js.Node.console.log(kha.Scheduler.time() + " Up: " + key + " from " + kha.network.Session.the().me.id);
		#end
		for (listener in upListeners) {
			listener(code);
		}
	}

	@input
	private function sendPressEvent(char: String): Void {
		for (listener in pressListeners) {
			listener(char);
		}
	}
}
