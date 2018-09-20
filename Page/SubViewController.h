//
//  SubViewController.h
//  Page
//
//  Created by CMR on 11/17/14.
//  Copyright (c) 2014 Page. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Macro.h"

typedef enum {
    AnimationDirectionFromRight,
    AnimationDirectionFromLeft,
} AnimationDirection;


@protocol AnimationDelegate <NSObject>
- (void)showAnimationWillFinish:(id)sender;
- (void)showAnimationDidFinish:(id)sender;
- (void)hideAnimationWillFinish:(id)sender;
- (void)hideAnimationDidFinish:(id)sender;
@end

@interface SubViewController : UIViewController
{
    __weak id<AnimationDelegate> animationDelegate;
    
    UIViewAnimationOptions animationOptions;
    CGFloat animationDuration;
}

@property (weak, nonatomic) id<AnimationDelegate> animationDelegate;

- (void)showViewController:(AnimationDirection)animationDirection animated:(BOOL)animated completion:(void(^)(void))callback;
- (void)hideViewController:(AnimationDirection)animationDirection animated:(BOOL)animated completion:(void(^)(void))callback;



@end
