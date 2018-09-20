//
//  WorkStepViewController.h
//  Page
//
//  Created by CMR on 3/18/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Macro.h"
#import "ProjectResource.h"

@protocol WorkStepViewControllerDelegate <NSObject>

- (void)workStepViewControllerNeedDisableScroll:(BOOL)disableScroll;
- (void)workStepViewControllerNeedDisableCommon:(BOOL)disableCommon;
- (void)workStepViewControllerShouldNext;
- (void)workStepViewControllerShouldBack;

@end

@interface WorkStepViewController : UIViewController
{
    BOOL activated;
}

@property (weak, nonatomic) id<WorkStepViewControllerDelegate> workStepDelegate;
@property (weak, nonatomic) ProjectResource *projectResource;

- (void)willActivateWork;
- (void)activateWork;
- (void)deactivateWork;
- (BOOL)workInterfaceIsLandscape;

- (void)prepareForSaveProject;

@end
