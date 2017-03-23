//hxcpp include should be first
#include <hxcpp.h>
#include <vector>
#include "SDL.h"
#include "./linc_videoplayer.h"

#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

// Forward declaration
namespace linc {
    namespace videoplayer {
        void on_ready(void *handle);
        void on_duration_changed(void *handle, int ms);
        void on_video_size_changed(void *handle, int width, int height);
        void on_error(void *handle, const char *err);
        void on_playing_state_changed(void *handle, bool playing);
    }
}

@interface VrHandle : NSObject

@property(readonly) AVPlayer *player;
@property(readonly) AVPlayerItem *item;
@property(readonly) AVPlayerItemVideoOutput *output;

- (void)play;
- (void)pause;
- (void)stop;
- (void)setUrl:(NSURL *)url;
- (NSString *) getError;

@end

@implementation VrHandle

@synthesize player = _player;
@synthesize item = _item;
@synthesize output = _output;

int itemContext;

- (void)setUrl:(NSURL *)url {

    [self stop];
    
    NSDictionary* settings = @{ (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
    
    _output = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:settings];
    
    _item = [AVPlayerItem playerItemWithAsset:[AVURLAsset URLAssetWithURL:url options:nil]];
    [_item addOutput:_output];
    [_item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:&itemContext];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:_item];
    
    _player = [AVPlayer playerWithPlayerItem:_item];
}

- (void)play {
    if(_player) {
        if(_player.currentItem) {
            [_player play];
        } else if(_item) {
            [_player replaceCurrentItemWithPlayerItem:_item];
            [_player play];
        }
    }
    linc::videoplayer::on_playing_state_changed((__bridge void *)self, true);
}

- (void)pause {
    if(_player) [_player pause];
    linc::videoplayer::on_playing_state_changed((__bridge void *)self, false);
}

- (void)stop {
    [self pause];
    if(_player) [_player replaceCurrentItemWithPlayerItem:nil];
    if(_item) {
        [_item removeObserver:self forKeyPath:@"status"];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_item];
        _item = nil;
    }

}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if (context != &itemContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = AVPlayerItemStatusUnknown;
        // Get the status change from the change dictionary
        NSNumber *statusNumber = change[NSKeyValueChangeNewKey];
        if ([statusNumber isKindOfClass:[NSNumber class]]) {
             status = (AVPlayerItemStatus) statusNumber.integerValue;
        }
        // Switch over the status
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:{
                linc::videoplayer::on_duration_changed((__bridge void *)self, _item.duration.timescale == 0 ? 0 : (int) (_item.duration.value * 1000 / _item.duration.timescale));
                linc::videoplayer::on_video_size_changed((__bridge void *)self, (int) _item.presentationSize.width, (int) _item.presentationSize.height);
                linc::videoplayer::on_ready((__bridge void *)self);
                [self play];
            }   break;
            case AVPlayerItemStatusFailed:{
                NSLog(@"AVPlayerItemStatusFailed");
                AVPlayerItem *item = object;
                linc::videoplayer::on_error((__bridge void *)self, [item.error.description UTF8String]);
            }   break;
            case AVPlayerItemStatusUnknown:
                // Not ready
                break;
        }
    }
}

-(void)itemDidFinishPlaying:(NSNotification *) notification {
    linc::videoplayer::on_playing_state_changed((__bridge void *)self, false);
}

@end



namespace linc {

    namespace videoplayer {
        
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
            return (void *) CFBridgingRetain([[VrHandle alloc] init]);
        }
        
        void set_url(void *handle, const char *url) {
            VrHandle *h = (__bridge VrHandle *) handle;
            [h setUrl:[NSURL URLWithString:[NSString stringWithUTF8String:url]]];
        }
        
        void play(void *handle) {
            VrHandle *h = (__bridge VrHandle *) handle;
            [h play];
        }
        
        void pause(void *handle) {
            VrHandle *h = (__bridge VrHandle *) handle;
            [h pause];
        }
        
        void stop(void *handle) {
            VrHandle *h = (__bridge VrHandle *) handle;
            [h stop];
        }
        
        void resume(void *handle) {
            VrHandle *h = (__bridge VrHandle *) handle;
            [h play];
        }
        
        void seek(void *handle, float seconds) {
            VrHandle *h = (__bridge VrHandle *) handle;
            [h.item seekToTime:CMTimeMake((int) seconds * 1000, 1000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        }
        
        float get_volume(void *handle) {
            VrHandle *h = (__bridge VrHandle *) handle;
            return h.player ? h.player.volume : 1.;
        }
        
        void set_volume(void *handle, float volume) {
            VrHandle *h = (__bridge VrHandle *) handle;
            h.player.volume = volume;
        }
        
        int get_time(void *handle) {
            VrHandle *h = (__bridge VrHandle *) handle;
            CMTime currentTime = [h.item currentTime];
            return currentTime.timescale == 0 ? 0 : (int) (currentTime.value * 1000 / currentTime.timescale);
        }
        
        void render_to_texture(void *handle, int textureUnit, int textureName) {
            VrHandle *h = (__bridge VrHandle *) handle;
            if(!h.item) return;
            
            CMTime time = [h.item currentTime];
            
            CVPixelBufferRef buffer = NULL;
            buffer = [h.output copyPixelBufferForItemTime:time itemTimeForDisplay:nil];
            
            // TODO: check this out -> CVOpenGLESTextureCacheCreateTextureFromImage
            if(buffer != NULL) {
                CVPixelBufferLockBaseAddress(buffer, 0);
                glActiveTexture(textureUnit);
                glBindTexture(GL_TEXTURE_2D, textureName);
                glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int) CVPixelBufferGetWidth(buffer), (int) CVPixelBufferGetHeight(buffer), 0, GL_BGRA, GL_UNSIGNED_BYTE, CVPixelBufferGetBaseAddress(buffer));
                CVPixelBufferUnlockBaseAddress(buffer, 0);
                CVBufferRelease(buffer);
            }
        }
        
        void destroy(void *handle) {
            VrHandle *h = (VrHandle *) CFBridgingRelease(handle);
            [h stop];
        }
        
        void on_ready(void *handle) {
            if(_onReady != null()) _onReady(handle);
        }
        
        void on_duration_changed(void *handle, int ms) {
            if(_onDurationChanged != null()) _onDurationChanged(handle, ms);
        }
        
        void on_video_size_changed(void *handle, int width, int height) {
            if(_onVideoSizeChanged != null()) _onVideoSizeChanged(handle, width, height);
        }
        
        void on_error(void *handle, const char *err) {
            if(_onError != null()) _onError(handle, ::String(err));
        }
        
        void on_playing_state_changed(void *handle, bool playing) {
            if(_onPlayingStateChanged != null()) _onPlayingStateChanged(handle, playing);
        }

    } //videoplayer namespace

} //linc
