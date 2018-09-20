//
//  AboutViewController.h
//  Page
//
//  Created by CMR on 7/13/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "VideoPlayerView.h"
#import "AboutTopView.h"
#import "AboutTutorialSectionView.h"
#import "AboutTooltipView.h"
#import "AboutFooterMenuView.h"

@protocol AboutViewControllerDelegate <NSObject>

- (void)aboutViewControllerDidClose;

@end

@interface AboutViewController : UIViewController <AboutTooltipViewDelegate, AboutFooterMenuViewDelegate, VideoPlayerViewDelegate, UIScrollViewDelegate, MFMailComposeViewControllerDelegate>

@property (assign, nonatomic) id<AboutViewControllerDelegate> aboutDelegate;
@property (strong, nonatomic) VideoPlayerView *videoPlayerView;
@end
