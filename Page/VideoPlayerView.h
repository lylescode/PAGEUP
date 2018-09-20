//
//  VideoPlayerView.h
//  Page
//
//  Created by CMR on 8/7/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerView.h"

@protocol VideoPlayerViewDelegate <NSObject>

- (void)videoPlayerViewDidPlay;
- (void)videoPlayerViewDidStop;


@end

@interface VideoPlayerView : UIView
@property (assign, nonatomic) id<VideoPlayerViewDelegate> videoPlayerDelegate;
@property (strong, nonatomic) UIView *playerView;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) NSString *currentVideoFilename;


- (void)updateFrame;
- (void)playVideoWithVideoFilename:(NSString *)videoFilename;
- (void)playVideo;
- (void)pauseVideo;
- (void)stopVideo;
- (void)stopVideoWithFade;

@end
