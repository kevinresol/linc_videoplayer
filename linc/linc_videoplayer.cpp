//hxcpp include should be first
#include <hxcpp.h>
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
            jobject handle = env->CallStaticObjectMethod(clazz, _create, activity);
            env->DeleteLocalRef(activity);
            env->DeleteLocalRef(clazz);
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
            jstring ret = (jstring) env->CallObjectMethod((jobject) handle, _getError);
            if(ret == NULL) {
                return NULL;
            } else {
                // TODO: need to release the jstring?
                return env->GetStringUTFChars(ret, NULL);
            }
        }
        
        info get_info(void *handle) {
            info i;
            i.width = env->CallIntMethod((jobject) handle, _getWidth); // :Int;
            i.height = env->CallIntMethod((jobject) handle, _getHeight); // :Int;
            i.time = env->CallIntMethod((jobject) handle, _getTime); // :Int;
            i.duration = env->CallIntMethod((jobject) handle, _getDuration); // :Int;
            i.playing = env->CallBooleanMethod((jobject) handle, _isPlaying); // :Bool;
            i.volume = env->CallFloatMethod((jobject) handle, _getVolume); // :Bool;
            return i;
        }
        
        void render_to_texture(void *handle, int textureUnit, int textureName) {
            env->CallVoidMethod((jobject) handle, _renderToTexture, textureUnit, textureName);
        }
        
        void destroy(void *handle) {
            env->CallVoidMethod((jobject) handle, _destroy);
        }

    } //videoplayer namespace

} //linc