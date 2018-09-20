//
//  SubViewController.m
//  Page
//
//  Created by CMR on 11/17/14.
//  Copyright (c) 2014 Page. All rights reserved.
//

#import "SubViewController.h"

@interface SubViewController ()

@end

@implementation SubViewController
@synthesize animationDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        animationOptions = UIViewAnimationOptionCurveEaseInOut;
        animationDuration = 0.5;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)showViewController:(AnimationDirection)animationDirection animated:(BOOL)animated completion:(void(^)(void))callback
{
    [animationDelegate showAnimationWillFinish:self];
    self.view.hidden = NO;
    
    if(animated) {
        CGFloat animationDelay = 0;
        CGFloat duration = animationDuration;
        CGFloat damping = 0.85;
        CGFloat velocity = 1;
        
        
        if(animationDirection == AnimationDirectionFromRight) {
            
        } else if(animationDirection == AnimationDirectionFromLeft) {
            
            
        }
        
        self.view.alpha = 0;
        [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                         animations:^{
                             self.view.alpha = 1;
                         }
                         completion:^(BOOL finished){
                             if(callback != nil) {
                                 callback();
                             }
                             [animationDelegate showAnimationDidFinish:self];
                         }];
        
    } else {
        if(callback != nil) {
            callback();
        }
        [animationDelegate showAnimationDidFinish:self];
    }
}
- (void)hideViewController:(AnimationDirection)animationDirection animated:(BOOL)animated completion:(void(^)(void))callback
{
    [animationDelegate hideAnimationWillFinish:self];
    
    if(animated) {
        
        CGFloat animationDelay = 0;
        CGFloat duration = animationDuration;
        CGFloat damping = 1;
        CGFloat velocity = 0.1;
        
        if(animationDirection == AnimationDirectionFromRight) {
            
        } else if(animationDirection == AnimationDirectionFromLeft) {
            
        }
        [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                         animations:^{
                             self.view.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             self.view.alpha = 1;
                             self.view.hidden = YES;
                             if(callback != nil) {
                                 callback();
                             }
                             [animationDelegate hideAnimationDidFinish:self];
                         }];
    } else {
        if(callback != nil) {
            callback();
        }
        [animationDelegate hideAnimationDidFinish:self];
    }
}


@end
