//hxcpp include should be first
#include <hxcpp.h>
#include <vector>
#include "SDL.h"
#include <jni.h>
#include <android/log.h>
#include "./linc_videoplayer.h"

namespace linc {

    namespace videoplayer {
        
        JNIEnv* env;
        jmethodID _create;
        jmethodID _setUrl;
        jmethodID _play;
        jmethodID _pause;
        jmethodID _stop;
        jmethodID _resume;
        jmethodID _seek;
        jmethodID _setVolume;
        jmethodID _getError;
        jmethodID _getWidth;
        jmethodID _getHeight;
        jmethodID _getTime;
        jmethodID _getDuration;
        jmethodID _isPlaying;
        jmethodID _getVolume;
        jmethodID _renderToTexture;
        jmethodID _destroy;
        
        std::vector<void*> handles;
        
        ::cpp::Function<void(cpp::Pointer<void>)> _onReady = NULL;
        ::cpp::Function<void(cpp::Pointer<void>, int)> _onDurationChanged = NULL;
        ::cpp::Function<void(cpp::Pointer<void>, ::String)> _onError = NULL;
        ::cpp::Function<void(cpp::Pointer<void>, int, int)> _onVideoSizeChanged = NULL;
        ::cpp::Function<void(cpp::Pointer<void>, bool)> _onPlayingStateChanged = NULL;
        
        void register_callbacks(
            ::cpp::Function<void(cpp::Pointer<void>)> onReady,
            ::cpp::Function<void(cpp::Pointer<void>, int)> onDurationChanged,
            ::cpp::Function<void(cpp::Pointer<void>, ::String)> onError,
            ::cpp::Function<void(cpp::Pointer<void>, int, int)> onVideoSizeChanged,
            ::cpp::Function<void(cpp::Pointer<void>, bool)> onPlayingStateChanged
        ) {
            _onReady = onReady;
            _onDurationChanged = onDurationChanged;
            _onError = onError;
            _onVideoSizeChanged = onVideoSizeChanged;
            _onPlayingStateChanged = onPlayingStateChanged;
        }

        void* create() {
            env = (JNIEnv*)SDL_AndroidGetJNIEnv();
            jclass clazz = env->FindClass("linc/videoplayer/VideoPlayer");
            _create = env->GetStaticMethodID(clazz, "create", "(Landroid/content/Context;)Llinc/videoplayer/VideoPlayer;");
            _setUrl = env->GetMethodID(clazz, "setUrl", "(Ljava/lang/String;)V");
            _play = env->GetMethodID(clazz, "play", "()V");
            _pause = env->GetMethodID(clazz, "pause", "()V");
            _stop = env->GetMethodID(clazz, "stop", "()V");
            _resume = env->GetMethodID(clazz, "resume", "()V");
            _seek = env->GetMethodID(clazz, "seek", "(F)V");
            _setVolume = env->GetMethodID(clazz, "setVolume", "(F)V");
            _getError = env->GetMethodID(clazz, "getError", "()Ljava/lang/String;");
            _getWidth = env->GetMethodID(clazz, "getWidth", "()I");
            _getHeight = env->GetMethodID(clazz, "getHeight", "()I");
            _getTime = env->GetMethodID(clazz, "getTime", "()I");
            _getDuration = env->GetMethodID(clazz, "getDuration", "()I");
            _isPlaying = env->GetMethodID(clazz, "isPlaying", "()Z");
            _getVolume = env->GetMethodID(clazz, "getVolume", "()F");
            _renderToTexture = env->GetMethodID(clazz, "renderToTexture", "(II)V");
            _destroy = env->GetMethodID(clazz, "destroy", "()V");

            jobject activity = (jobject)SDL_AndroidGetActivity();
            jobject handle = env->NewGlobalRef(env->CallStaticObjectMethod(clazz, _create, activity));
            env->DeleteLocalRef(activity);
            env->DeleteLocalRef(clazz);
            handles.push_back(handle);
            return handle;
        }
        
        void set_url(void *handle, const char *url) {
            jstring jurl = env->NewStringUTF(url);
            env->CallVoidMethod((jobject) handle, _setUrl, jurl);
            env->DeleteLocalRef(jurl);
        }
        
        void play(void *handle) {
            env->CallVoidMethod((jobject) handle, _play);
        }
        
        void pause(void *handle) {
            env->CallVoidMethod((jobject) handle, _pause);
        }
        
        void stop(void *handle) {
            env->CallVoidMethod((jobject) handle, _stop);
        }
        
        void resume(void *handle) {
            env->CallVoidMethod((jobject) handle, _resume);
        }
        
        void seek(void *handle, float seconds) {
            env->CallVoidMethod((jobject) handle, _seek, seconds);
        }
        
        void set_volume(void *handle, float volume) {
            env->CallVoidMethod((jobject) handle, _setVolume, volume);
        }
        
        const char* get_error(void *handle) {
            jstring jstr = (jstring) env->CallObjectMethod((jobject) handle, _getError);
            if(jstr == NULL) {
                return NULL;
            } else {
                const char *cstr = env->GetStringUTFChars(jstr, NULL);
                env->DeleteLocalRef(jstr);
                return cstr;
            }
        }
        
        int get_time(void *handle) {
            return env->CallIntMethod((jobject) handle, _getTime);
        }
        
        void render_to_texture(void *handle, int textureUnit, int textureName) {
            env->CallVoidMethod((jobject) handle, _renderToTexture, textureUnit, textureName);
        }
        
        void destroy(void *handle) {
            // TODO: remove from handles
            env->DeleteGlobalRef((jobject) handle);
            env->CallVoidMethod((jobject) handle, _destroy);
        }
        
        void* get_stored_handle(JNIEnv* env, void *handle) {
            for(int i = 0; i < handles.size(); i++) {
                jobject stored = (jobject) handles[i];
                if(env->IsSameObject(stored, (jobject) handle))
                    return stored;
            }
            return NULL;
        }
        
        void on_ready(JNIEnv* env, void *handle) {
            if(_onReady != null()) {
                void* stored = get_stored_handle(env, handle);
                if(stored != NULL) _onReady(stored);
            }
        }
        
        void on_duration_changed(JNIEnv* env, void *handle, int ms) {
            if(_onDurationChanged != null()) {
                void* stored = get_stored_handle(env, handle);
                if(stored != NULL) _onDurationChanged(stored, ms);
            }
        }
        
        void on_video_size_changed(JNIEnv* env, void *handle, int width, int height) {
            if(_onVideoSizeChanged != null()) {
                void* stored = get_stored_handle(env, handle);
                if(stored != NULL) _onVideoSizeChanged(stored, width, height);
            }
        }
        
        void on_error(JNIEnv* env, void *handle, const char *err) {
            if(_onError != null()) {
                void* stored = get_stored_handle(env, handle);
                if(stored != NULL) _onError(stored, ::String(err));
            }
        }
        
        void on_playing_state_changed(JNIEnv* env, void *handle, bool playing) {
            if(_onPlayingStateChanged != null()) {
                void* stored = get_stored_handle(env, handle);
                if(stored != NULL) _onPlayingStateChanged(stored, playing);
            }
        }
        
        struct AutoHaxe {

            int base;
            const char *message;
            AutoHaxe(const char *inMessage) {  
                base = 0;
                message = inMessage;
                ::hx::SetTopOfStack(&base, true);
            }

            ~AutoHaxe() {
                ::hx::SetTopOfStack((int*)0, true);
            }
        };
        

    } //videoplayer namespace

} //linc

#ifdef __cplusplus
extern "C" {
#endif

JNIEXPORT void JNICALL Java_linc_videoplayer_VideoPlayer_onError(JNIEnv* env, jobject object, jstring err) {
    linc::videoplayer::AutoHaxe haxe("Java_linc_videoplayer_VideoPlayer_onError");
    const char* _err = env->GetStringUTFChars(err, JNI_FALSE);
    linc::videoplayer::on_error(env, object, _err);
    env->ReleaseStringUTFChars(err, _err);
}

JNIEXPORT void JNICALL Java_linc_videoplayer_VideoPlayer_onVideoSizeChanged(JNIEnv* env, jobject object, jint width, jint height) {
    linc::videoplayer::AutoHaxe haxe("Java_linc_videoplayer_VideoPlayer_onVideoSizeChanged");
    linc::videoplayer::on_video_size_changed(env, object, width, height);
}

JNIEXPORT void JNICALL Java_linc_videoplayer_VideoPlayer_onDurationChanged(JNIEnv* env, jobject object, jint ms) {
    linc::videoplayer::AutoHaxe haxe("Java_linc_videoplayer_VideoPlayer_onDurationChanged");
    linc::videoplayer::on_duration_changed(env, object, ms);
}

JNIEXPORT void JNICALL Java_linc_videoplayer_VideoPlayer_onReady(JNIEnv* env, jobject object) {
    linc::videoplayer::AutoHaxe haxe("Java_linc_videoplayer_VideoPlayer_onReady");
    linc::videoplayer::on_ready(env, object);
}

JNIEXPORT void JNICALL Java_linc_videoplayer_VideoPlayer_onPlayingStateChanged(JNIEnv* env, jobject object, jboolean playing) {
    linc::videoplayer::AutoHaxe haxe("Java_linc_videoplayer_VideoPlayer_onPlayingStateChanged");
    linc::videoplayer::on_playing_state_changed(env, object, playing);
}

#ifdef __cplusplus
}
#endif