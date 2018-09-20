//
//  PlayerView.h
//  Page
//
//  Created by CMR on 8/7/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class AVPlayer;
@interface PlayerView : UIView

@property (weak, nonatomic) AVPlayer *player;

@end
