package linc.videoplayer;

import android.content.Context;
import android.graphics.SurfaceTexture;
import android.media.MediaPlayer;
import android.util.Log;
import android.view.Surface;

import java.io.IOException;

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

        final VideoPlayer self = this;
        player.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mp) {
                self.onReady();
                self.onDurationChanged(player.getDuration());
                self.play();
            }
        });

        player.setOnVideoSizeChangedListener(new MediaPlayer.OnVideoSizeChangedListener() {
            @Override
            public void onVideoSizeChanged(MediaPlayer mp, int width, int height) {
                self.onVideoSizeChanged(width, height);
            }
        });

        player.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(MediaPlayer mp) {
                self.onPlayingStateChanged(false);
            }
        });

        player.setOnSeekCompleteListener(new MediaPlayer.OnSeekCompleteListener() {
            @Override
            public void onSeekComplete(MediaPlayer mp) {
                self.onPlayingStateChanged(true);
            }
        });

        player.setOnErrorListener(new MediaPlayer.OnErrorListener() {
            @Override
            public boolean onError(MediaPlayer mp, int what, int extra) {
                self.onError("Error - what:" + what + ", extra:" + extra + " (see: https://developer.android.com/reference/android/media/MediaPlayer.OnErrorListener.html)");
                return false;
            }
        });
    }

    public static VideoPlayer create(Context context) {
        return new VideoPlayer(context);
    }

    public void setUrl(String url) {
        Log.i("VIDEOPLAYER", "set url: " + url);
        try {
            onPlayingStateChanged(true);
            player.reset();
            player.setDataSource(url);
            player.prepareAsync();
        } catch(IOException ex) {
            onError(ex.toString() + " " + ex.getMessage());
        } catch(IllegalArgumentException ex) {
            onError(ex.toString() + " " + ex.getMessage());
        } catch(SecurityException ex) {
            onError(ex.toString() + " " + ex.getMessage());
        } catch(IllegalStateException ex) {
            onError(ex.toString() + " " + ex.getMessage());
        }
    }


    public void play() {
        player.start();
        onPlayingStateChanged(true);
    }
    public void pause() {
        player.pause();
        onPlayingStateChanged(false);
    }
    public void stop() {
        player.stop();
        onPlayingStateChanged(false);
    }
    public void resume() {
        player.start();
        onPlayingStateChanged(true);
    }
    public void seek(float seconds) {
        player.seekTo((int) (seconds * 1000));
    }
    public void setVolume(float volume) {
        player.setVolume(volume, volume);
    }

    public void renderToTexture(int textureUnit, int textureName) {
        if(surfaceTexture == null) {
            surfaceTexture = new SurfaceTexture(textureName);
            player.setSurface(new Surface(surfaceTexture));
        }
        surfaceTexture.updateTexImage();
    }
    public void destroy() {
        // TODO
    }

    public int getTime() {
        return player.getCurrentPosition();
    }

    private native void onVideoSizeChanged(int width, int height);
    private native void onDurationChanged(int ms);
    private native void onPlayingStateChanged(boolean playing);
    private native void onReady();
    private native void onError(String err);
}
