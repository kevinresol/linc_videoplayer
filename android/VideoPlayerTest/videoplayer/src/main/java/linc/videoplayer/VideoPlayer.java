package linc.videoplayer;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.SurfaceTexture;
import android.media.MediaPlayer;
import android.opengl.GLES11;
import android.opengl.GLES11Ext;
import android.opengl.GLES20;
import android.opengl.GLUtils;
import android.util.Log;
import android.view.Surface;

import java.io.IOException;
import java.nio.Buffer;
import java.nio.ByteBuffer;

/**
 * Created by kevin on 15/3/2017.
 */

public class VideoPlayer {

    private static final String TAG = "VideoPlayer";
    private MediaPlayer player;
    private SurfaceTexture surfaceTexture;
    private Context context;

    public VideoPlayer(Context context) {
        Log.i(TAG, "Creating MediaPlayer");
        this.context = context;
        player = new MediaPlayer();
        Log.i(TAG, "Created MediaPlayer");
    }

    public static VideoPlayer create(Context context) {
        return new VideoPlayer(context);
    }

    public void setUrl(String url) {
        try {
            player.setDataSource(url);
            player.prepare();
        } catch(IOException ex) {
            Log.i(TAG, ex.getMessage());
            Log.i(TAG, ex.toString());
            ex.printStackTrace();
        }
    }


    public void play() {
        player.start();
    }
    public void pause() {
        player.pause();
    }
    public void stop() {
        player.stop();
    }
    public void resume() {
        player.start();
    }
    public void seek(float seconds) {
        player.seekTo((int) (seconds * 1000));
    }
    public void setVolume(float volume) {
        player.setVolume(volume, volume);
    }
    public String getError() {
        return "";
    }

    public void renderToTexture(int textureUnit, int textureName) {
        if(surfaceTexture == null) {
            surfaceTexture = new SurfaceTexture(textureName);
            player.setSurface(new Surface(surfaceTexture));
        }
        surfaceTexture.updateTexImage();
    }
    public void destroy() {

    }

    public int getWidth() {

        return player.getVideoWidth();
    }
    public int getHeight() {
        return player.getVideoHeight();
    }
    public int getTime() {
        return player.getCurrentPosition();
    }
    public int getDuration() {
        return player.getDuration();
    }
    public boolean isPlaying() {
        return player.isPlaying();
    }
    public float getVolume() {
        return (float) 0.1;
    }
}
