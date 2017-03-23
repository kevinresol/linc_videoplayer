#pragma once

//hxcpp include should always be first    
#include <hxcpp.h>

//include other library includes as needed
// #include "../lib/____"

namespace linc {

    namespace videoplayer {

        typedef struct info {
            int width;
            int height;
            int duration;
            int time;
            bool playing;
            float volume;
        } info;

        void register_callbacks(
            ::cpp::Function<void(cpp::Pointer<void>)> onReady,
            ::cpp::Function<void(cpp::Pointer<void>, int)> onPositionChanged,
            ::cpp::Function<void(cpp::Pointer<void>, ::String)> onError,
            ::cpp::Function<void(cpp::Pointer<void>, int, int)> onVideoSizeChanged,
            ::cpp::Function<void(cpp::Pointer<void>, bool)> onPlayingStateChanged
        );
        
        extern void* create();
        extern void set_url(void *handle, const char *urlString);
        extern void play(void *handle);
        extern void pause(void *handle);
        extern void stop(void *handle);
        extern void resume(void *handle);
        extern void seek(void *handle, float seconds);
        extern float get_volume(void *handle);
        extern void set_volume(void *handle, float volume);
        extern int get_time(void *handle);
        extern void render_to_texture(void *handle, int textureUnit, int textureName);
        extern void destroy(void *handle);

    } //videoplayer namespace

} //linc