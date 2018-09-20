//
//  VideoPlayerView.m
//  Page
//
//  Created by CMR on 8/7/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "VideoPlayerView.h"

@interface VideoPlayerView ()
- (void)itemDidFinishPlaying;
@end

@implementation VideoPlayerView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIView *playerView = [[PlayerView alloc] init];
        /*
        if(self.bounds.size.width < self.bounds.size.height) {
            playerView.frame = CGRectMake(0, 0, self.bounds.size.width - 10, self.bounds.size.width - 10);
        } else {
            playerView.frame = CGRectMake(0, 0, self.bounds.size.height - 10, self.bounds.size.height - 10);
        }
        playerView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        */
        
        
        [self addSubview:playerView];
        
        self.playerView = playerView;
    }
    return self;
}

- (void)dealloc
{
    [self stopVideo];
    [self.playerView removeFromSuperview];
    self.playerView = nil;
}
- (void)updateFrame
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.playerView.frame = CGRectMake(10, 67, self.bounds.size.width - 20, self.bounds.size.height - 132);
    }
    else {
        self.playerView.frame = CGRectMake(10, 52, self.bounds.size.width - 20, self.bounds.size.height - 162);
    }
    
    [self setPlayerLayerFrame:self.playerView.layer.bounds];
}
- (void)playVideoWithVideoFilename:(NSString *)videoFilename
{
    [self stopVideo];
    
    if (self.player == nil) {
        
        self.currentVideoFilename = videoFilename;
        NSString *path = [[NSBundle mainBundle] pathForResource:videoFilename ofType:nil];
        NSURL *url = [NSURL fileURLWithPath:path];
        AVPlayer *player = [[AVPlayer alloc] initWithURL:url];
        player.volume = 0;
        player.muted = YES;
        player.allowsExternalPlayback = NO;
        
        self.player = player;
        
        [player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(itemDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
        
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        
        self.playerView.alpha = 0;
        
        [self.playerView.layer addSublayer:self.playerLayer];
        
        [self updateFrame];
        
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                         withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
        
        
        
    }
}

- (void)playVideo
{
    if(self.player) {
        int32_t timeScale = self.player.currentItem.asset.duration.timescale;
        CMTime ctime = CMTimeMakeWithSeconds(0, timeScale);
        [self.player seekToTime:ctime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        [self.player play];
        
        [self.videoPlayerDelegate videoPlayerViewDidPlay];
    }
}
- (void)pauseVideo
{
    [self.player pause];
}

- (void)stopVideo
{
    if (self.player != nil) {
        @try {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
        }
        @catch (NSException *exception) {}
        [self.player pause];
        
        [self.player removeObserver:self forKeyPath:@"status"];
        [self.playerLayer removeFromSuperlayer];
        
        self.playerLayer = nil;
        self.player = nil;
        self.currentVideoFilename = nil;
        
        
        [self.videoPlayerDelegate videoPlayerViewDidStop];
    }
    
}
- (void)stopVideoWithFade
{
    if (self.player != nil) {
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.playerView.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             if(finished) {
                                 [self stopVideo];
                             }
                         }];
    }
}

- (void)itemDidFinishPlaying
{
    int32_t timeScale = self.player.currentItem.asset.duration.timescale;
    CMTime ctime = CMTimeMakeWithSeconds(0, timeScale);
    [self.player seekToTime:ctime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.player play];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if (object == self.player && [keyPath isEqualToString:@"status"]) {
        if (self.player.status == AVPlayerStatusReadyToPlay) {
            [UIView animateWithDuration:0.25
                             animations:^{
                                 self.playerView.alpha = 1;
                             }];
        } else if (self.player.status == AVPlayerStatusFailed) {
            // something went wrong. player.error should contain some information
        }
    }
}
- (void)setPlayerLayerFrame:(CGRect)frame
{
    if (self.playerLayer != nil) {
        CALayer *videolayer = self.playerLayer;
        [CATransaction begin];
        [CATransaction setAnimationDuration:0];
        [CATransaction setDisableActions:YES];
        videolayer.frame = frame;
        [CATransaction commit];
    }
}

@end

