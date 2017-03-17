package videoplayer;

class VideoPlayer {
	
	var _h:cpp.Pointer<Void>;
	
	public function new() {
		_h = Wrapper.create();
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
	public function setVolume(volume:Float):Void {
		Wrapper.setVolume(_h, volume);
	}
	public function getError():String {
		return Wrapper.getError(_h);
	}
	public function getInfo():Info {
		return Wrapper.getInfo(_h);
	}
	public function renderToTexture(textureUnit:Int, textureName:Int):Void {
		Wrapper.renderToTexture(_h, textureUnit, textureName);
	}
	public function destroy():Void {
		Wrapper.destroy(_h);
	}
}