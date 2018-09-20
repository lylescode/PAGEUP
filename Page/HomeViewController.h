//
//  HomeViewController.h
//  Page
//
//  Created by CMR on 11/17/14.
//  Copyright (c) 2014 Page. All rights reserved.
//

#import "SubViewController.h"
#import "ProjectCollectionViewLayout.h"
#import "Project.h"
#import "ProjectResource.h"

#import "HomeMenuViewController.h"
#import "HomeShareViewController.h"
#import "VideoPreviewViewController.h"

@protocol HomeViewControllerDelegate <NSObject>

- (void)homeViewControllerNeedTooltip;
- (void)homeViewControllerDidNewProject;
- (void)homeViewControllerDidNewWithProjectType:(NSString *)projectType;
- (void)homeViewControllerDidLoadProject:(Project *)project;
- (void)homeViewControllerDidAbout;

- (void)homeViewControllerDidShareActivityWithImage:(UIImage *)image completion:(void(^)(void))callback;
- (void)homeViewControllerDidShareActivityWithPDF:(NSURL *)PDFURL completion:(void(^)(void))callback;
- (void)homeViewControllerDidShareActivityWithVideoURL:(NSURL *)videoURL completion:(void(^)(void))callback;

@end

@interface HomeViewController : SubViewController <MosaicCollectionViewLayoutDelegate, HomeMenuViewControllerDelegate, HomeShareViewControllerDelegate, VideoPreviewViewControllerDelegate, UIAlertViewDelegate, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>

@property (assign, nonatomic) id<HomeViewControllerDelegate> homeDelegate;
@property (weak, nonatomic) IBOutlet UIView *bottomBarView;

@end
