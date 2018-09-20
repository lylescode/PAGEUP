//
//  ImportViewController.h
//  Page
//
//  Created by CMR on 11/21/14.
//  Copyright (c) 2014 Page. All rights reserved.
//

#import "WorkStepViewController.h"
#import <Photos/Photos.h>
#import "PPhotoAsset.h"
#import "ProjectResource.h"

//#import "AssetLibraryRootListViewController.h"
//#import "AssetGridViewController.h"
#import "AllPhotosViewController.h"

@protocol ImportViewControllerDelegate <NSObject>

- (void)importViewControllerDidChangePhoto;

@end


@interface ImportViewController : WorkStepViewController <UINavigationControllerDelegate, UIGestureRecognizerDelegate, AllPhotosViewControllerDelegate>

@property (assign, nonatomic) id<ImportViewControllerDelegate> importDelegate;
@end
