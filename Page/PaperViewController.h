//
//  PaperViewController.h
//  Page
//
//  Created by CMR on 4/10/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "WorkStepViewController.h"
@protocol PaperViewControllerDelegate <NSObject>

- (UIImage *)paperViewControllerNeedResultImage;
- (UIImage *)paperViewControllerNeedPreviewImage;
- (void)paperViewControllerDidShareActivityWithImage:(UIImage *)image completion:(void(^)(void))callback;

@end

@interface PaperViewController : WorkStepViewController
@property (assign, nonatomic) id<PaperViewControllerDelegate> paperDelegate;

- (void)updateSelectedPhotos;
- (void)updateTemplate;

@end
