package videoplayer;

@:include('linc_videoplayer.h')
@:native('::cpp::Struct<linc::videoplayer::info>')
extern class Info {
	var width:Int;
	var height:Int;
	var time:Int;
	var duration:Int;
	var playing:Bool;
	var volume:Float;
}
