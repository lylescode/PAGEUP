//
//  PlayerView.m
//  Page
//
//  Created by CMR on 8/7/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "PlayerView.h"

@implementation PlayerView


+ (Class)layerClass
{
    return [AVPlayerLayer class];
}


- (AVPlayer*)player
{
    return [(AVPlayerLayer*)[self layer] player];
}


- (void)setPlayer:(AVPlayer*)player
{
    [(AVPlayerLayer*)[self layer] setPlayer:player];
}


@end
