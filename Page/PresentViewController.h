//
//  PresentViewController.h
//  Page
//
//  Created by CMR on 11/20/14.
//  Copyright (c) 2014 Page. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Macro.h"

@protocol PresentDelegate <NSObject>
- (void)presentWillFinish:(id)sender;
- (void)presentDidFinish:(id)sender;
- (void)dismissWillFinish:(id)sender;
- (void)dismissDidFinish:(id)sender;
@end


@interface PresentViewController : UIViewController
{
    __weak id<PresentDelegate> presentDelegate;
    
    UIViewAnimationOptions animationOptions;
    CGFloat animationDuration;
}

@property (weak, nonatomic) id<PresentDelegate> presentDelegate;

- (void)presentViewControllerAnimated:(BOOL)animated completion:(void(^)(void))callback;
- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void(^)(void))callback;


@end
