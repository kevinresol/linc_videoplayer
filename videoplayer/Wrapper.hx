package videoplayer;

import cpp.Callable;

@:keep
@:include('linc_videoplayer.h')
#if !display
@:build(linc.Linc.touch())
@:build(linc.Linc.xml('videoplayer'))
#end
@:native
extern class Wrapper {
    
    @:native('linc::videoplayer::register_callbacks')
    static function registerCallbacks(
        onReady:Callable<Handle->Void>,
        onDurationChanged:Callable<Handle->Int->Void>,
        onError:Callable<Handle->String->Void>,
        onVideoSizeChanged:Callable<Handle->Int->Int->Void>,
        onPlayingStateChanged:Callable<Handle->Bool->Void>
    ):Void;
    
    @:native('linc::videoplayer::create')
    static function create():Handle;
    
    @:native('linc::videoplayer::set_url')
    static function setUrl(_h:Handle, url:String):Void;
    
    @:native('linc::videoplayer::play')
    static function play(_h:Handle):Void;
    
    @:native('linc::videoplayer::pause')
    static function pause(_h:Handle):Void;
    
    @:native('linc::videoplayer::stop')
    static function stop(_h:Handle):Void;
    
    @:native('linc::videoplayer::resume')
    static function resume(_h:Handle):Void;
    
    @:native('linc::videoplayer::seek')
    static function seek(_h:Handle, seconds:Float):Void;
    
    @:native('linc::videoplayer::get_volume')
    static function getVolume(_h:Handle):Float;
    
    @:native('linc::videoplayer::set_volume')
    static function setVolume(_h:Handle, volume:Float):Void;
    
    @:native('linc::videoplayer::get_error')
    static function getError(_h:Handle):cpp.ConstCharStar;
    
    @:native('linc::videoplayer::get_time')
    static function getTime(_h:Handle):Int;
    
    @:native('linc::videoplayer::render_to_texture')
    static function renderToTexture(_h:Handle, textureUnit:Int, textureName:Int):Void;
    
    @:native('linc::videoplayer::destroy')
    static function destroy(_h:Handle):Void;

} //VideoPlayer
