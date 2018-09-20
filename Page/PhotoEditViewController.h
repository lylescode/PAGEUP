//
//  PhotoEditViewController.h
//  Page
//
//  Created by CMR on 3/25/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PresentViewController.h"
#import "PTemplate.h"
#import "PPhotoView.h"
#import "ProjectResource.h"
#import "AllPhotosViewController.h"
#import "PhotoBrightnessSliderView.h"

@protocol PhotoEditViewControllerDelegate <NSObject>

- (void)photoEditViewControllerDidClose;
- (void)photoEditViewControllerDidReplacePhoto:(PPhotoView *)photoView photoIndex:(NSInteger)photoIndex;

@end

@interface PhotoEditViewController : PresentViewController <UIGestureRecognizerDelegate, AllPhotosViewControllerDelegate, PhotoBrightnessSliderDelegate>
@property (assign, nonatomic) id<PhotoEditViewControllerDelegate> photoEditDelegate;
@property (weak, nonatomic) ProjectResource *projectResource;

- (void)editPhotoWithPhotoView:(PPhotoView *)photoView photoIndex:(NSInteger)photoIndex;

@end
