//
//  WorkRootViewController.h
//  Page
//
//  Created by CMR on 3/17/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Constants.h"

#import "WorkStepViewController.h"
#import "ImportViewController.h"
#import "TemplateViewController.h"
#import "EditorViewController.h"
#import "PaperViewController.h"
#import "ExportViewController.h"

@protocol WorkRootViewControllerDelegate <NSObject>

- (void)workRootViewControllerNeedPhotosTooltip;
- (void)workRootViewControllerNeedLayoutsTooltip;
- (void)workRootViewControllerNeedEditTooltip;
- (void)workRootViewControllerNeedTemplateEditTooltip;
- (void)workRootViewControllerDidBack;
- (void)workRootViewControllerDidShareActivityWithImage:(UIImage *)image completion:(void(^)(void))callback;
- (void)workRootViewControllerDidShareActivityWithPDFURL:(NSURL *)PDFURL completion:(void(^)(void))callback;
- (void)workRootViewControllerDidShareActivityWithVideoURL:(NSURL *)videoURL completion:(void(^)(void))callback;
@end

@interface WorkRootViewController : UIViewController <UIGestureRecognizerDelegate, UIScrollViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, WorkStepViewControllerDelegate, ImportViewControllerDelegate, TemplateViewControllerDelegate, EditorViewControllerDelegate, PaperViewControllerDelegate, ExportViewControllerDelegate>
@property (assign, nonatomic) id<WorkRootViewControllerDelegate> workDelegate;
@property (weak, nonatomic) ProjectResource *workingProjectResource;

- (void)setupWorkingProject;
- (void)willActivateWorkAtStep:(NSInteger)stepIndex;
- (void)activateWorkAtStep:(NSInteger)stepIndex;
- (void)activateWorkAtStep:(NSInteger)stepIndex useScroll:(BOOL)useScroll;

- (void)saveCurrentProject;
- (void)saveCurrentProjectWithPreviewImage:(BOOL)updatePreview;
- (void)updateCurrentProject;

@end
