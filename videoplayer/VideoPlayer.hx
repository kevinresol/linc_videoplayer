package videoplayer;

import cpp.Callable;

class VideoPlayer {
	
	static var players:Array<VideoPlayer> = [];
	
	var _h:Handle;
	
	public function new() {
		_h = Wrapper.create();
		players.push(this);
		_init();
	}
	public function setUrl(url:String):Void {
		Wrapper.setUrl(_h, url);
	}
	public function play():Void {
		Wrapper.play(_h);
	}
	public function pause():Void {
		Wrapper.pause(_h);
	}
	public function stop():Void {
		Wrapper.stop(_h);
	}
	public function resume():Void {
		Wrapper.resume(_h);
	}
	public function seek(seconds:Float):Void {
		Wrapper.seek(_h, seconds);
	}
	public function getVolume():Float {
		return Wrapper.getVolume(_h);
	}
	public function setVolume(volume:Float):Void {
		Wrapper.setVolume(_h, volume);
	}
	public function getTime():Int {
		return Wrapper.getTime(_h);
	}
	public function renderToTexture(textureUnit:Int, textureName:Int):Void {
		Wrapper.renderToTexture(_h, textureUnit, textureName);
	}
	public function destroy():Void {
		Wrapper.destroy(_h);
		players.remove(this);
	}
	
	public dynamic function onReady() {
		trace('onReady');
	}
	public dynamic function onDurationChanged(ms:Int) {
		trace('onDurationChanged: $ms ms');
	}
	public dynamic function onError(err:String) {
		trace('onError');
	}
	public dynamic function onVideoSizeChanged(width:Int, height:Int) {
		trace('onVideoSizeChanged: $width x $height');
	}
	public dynamic function onPlayingStateChanged(playing:Bool) {
		trace('onPlayingStateChanged: $playing');
	}
	
	static var inited = false;
	static function _init() {
		if(inited) return;
		inited = true;
		Wrapper.registerCallbacks(
			Callable.fromStaticFunction(_onReady),
			Callable.fromStaticFunction(_onDurationChanged),
			Callable.fromStaticFunction(_onError),
			Callable.fromStaticFunction(_onVideoSizeChanged),
			Callable.fromStaticFunction(_onPlayingStateChanged)
		);
	}
	
	static function _onReady(_h:Handle) {
		for(p in players) {
			if(p._h == _h) {
				p.onReady();
				return;
			}
		}
		trace('_onReady');
	}
	
	static function _onDurationChanged(_h:Handle, ms:Int) {
		for(p in players) {
			if(p._h == _h) {
				p.onDurationChanged(ms);
				return;
			}
		}
		trace('_onDurationChanged');
	}
	
	static function _onError(_h:Handle, err:String) {
		for(p in players) {
			if(p._h == _h) {
				p.onError(err);
				return;
			}
		}
		trace('_onError');
	}
	
	static function _onVideoSizeChanged(_h:Handle, width:Int, height:Int) {
		for(p in players) {
			if(p._h == _h) {
				p.onVideoSizeChanged(width, height);
				return;
			}
		}
		trace('_onVideoSizeChanged');
	}
	
	static function _onPlayingStateChanged(_h:Handle, playing:Bool) {
		for(p in players) {
			if(p._h == _h) {
				p.onPlayingStateChanged(playing);
				return;
			}
		}
		trace('_onPlayingStateChanged');
	}
	
}