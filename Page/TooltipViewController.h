//
//  TooltipViewController.h
//  Page
//
//  Created by CMR on 8/12/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@protocol TooltipViewControllerDelegate <NSObject>

- (void)tooltipViewControllerDidClose;

@end

@interface TooltipViewController : UIViewController

@property (assign, nonatomic) id<TooltipViewControllerDelegate> tooltipDelegate;

@property (weak, nonatomic) IBOutlet UIView *homeTooltipView;
@property (weak, nonatomic) IBOutlet UIView *photosTooltipView;
@property (weak, nonatomic) IBOutlet UIView *layoutsTooltipView;
@property (weak, nonatomic) IBOutlet UIView *editTooltipView;
@property (weak, nonatomic) IBOutlet UIView *templateEditTooltipView;


- (void)showHomeTooltip;
- (void)showPhotosTooltip;
- (void)showLayoutTooltip;
- (void)showEditTooltip;
- (void)showTemplateEditTooltip;

- (void)hiddenAllTooltip;
@end
