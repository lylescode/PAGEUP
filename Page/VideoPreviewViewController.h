//
//  VideoPreviewViewController.h
//  Page
//
//  Created by CMR on 5/14/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "PresentViewController.h"
#import "ProjectResource.h"
#import "PTemplate.h"

@protocol VideoPreviewViewControllerDelegate <NSObject>

- (void)videoPreviewViewControllerDidClose;
- (void)videoPreviewViewControllerDidShareActivityWithVideoURL:(NSURL *)videoURL;

@end

@interface VideoPreviewViewController : PresentViewController

@property (assign, nonatomic) id<VideoPreviewViewControllerDelegate> videoPreviewDelegate;
@property (strong, nonatomic) ProjectResource *projectResource;


@end
