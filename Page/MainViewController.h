//
//  MainViewController.h
//  Page
//
//  Created by CMR on 11/17/14.
//  Copyright (c) 2014 Page. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#import "WorkRootViewController.h"
#import "AboutViewController.h"

#import "TooltipViewController.h"

#import "ProjectResource.h"

@interface MainViewController : UIViewController <UIDocumentInteractionControllerDelegate, HomeViewControllerDelegate, WorkRootViewControllerDelegate, AboutViewControllerDelegate, TooltipViewControllerDelegate>


@end
