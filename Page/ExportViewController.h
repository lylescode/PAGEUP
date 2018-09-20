//
//  ExportViewController.h
//  Page
//
//  Created by CMR on 3/19/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "WorkStepViewController.h"

@protocol ExportViewControllerDelegate <NSObject>

- (UIImage *)exportViewControllerNeedResultImage;
- (UIImage *)exportViewControllerNeedPreviewImage;
- (void)exportViewControllerDidShareActivityWithImage:(UIImage *)image completion:(void(^)(void))callback;

@end

@interface ExportViewController : WorkStepViewController
@property (assign, nonatomic) id<ExportViewControllerDelegate> exportDelegate;

- (void)updateSelectedPhotos;
- (void)updateTemplate;

@end
