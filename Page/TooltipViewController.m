//
//  TooltipViewController.m
//  Page
//
//  Created by CMR on 8/12/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "TooltipViewController.h"
#import "Utils.h"

@interface TooltipViewController ()
{
    UITapGestureRecognizer *tapGesture;
}
- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer;
@end

@implementation TooltipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)dealloc
{
    [self.view removeGestureRecognizer:tapGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showHomeTooltip
{
    self.homeTooltipView.alpha = 1;
    self.homeTooltipView.hidden = NO;
    
    [self showAnimationWithTargetViews:[Utils shuffleArray:[self.homeTooltipView subviews]]];
}

- (void)showPhotosTooltip
{
    self.photosTooltipView.alpha = 1;
    self.photosTooltipView.hidden = NO;
    
    [self showAnimationWithTargetViews:[Utils shuffleArray:[self.photosTooltipView subviews]]];
}
- (void)showLayoutTooltip
{
    self.layoutsTooltipView.alpha = 1;
    self.layoutsTooltipView.hidden = NO;
    
    [self showAnimationWithTargetViews:[Utils shuffleArray:[self.layoutsTooltipView subviews]]];
}
- (void)showEditTooltip
{
    self.editTooltipView.alpha = 1;
    self.editTooltipView.hidden = NO;
    
    [self showAnimationWithTargetViews:[Utils shuffleArray:[self.editTooltipView subviews]]];
}
- (void)showTemplateEditTooltip
{
    self.templateEditTooltipView.alpha = 1;
    self.templateEditTooltipView.hidden = NO;
    
    [self showAnimationWithTargetViews:[Utils shuffleArray:[self.templateEditTooltipView subviews]]];
}

- (void)hiddenAllTooltip
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(!self.homeTooltipView.hidden) {
        [defaults setObject:@YES forKey:TOOLTIP_HOME_KEY];
    }
    else if(!self.photosTooltipView.hidden) {
        [defaults setObject:@YES forKey:TOOLTIP_PHOTOS_KEY];
    }
    else if(!self.layoutsTooltipView.hidden) {
        [defaults setObject:@YES forKey:TOOLTIP_LAYOUTS_KEY];
    }
    else if(!self.editTooltipView.hidden) {
        [defaults setObject:@YES forKey:TOOLTIP_EDIT_KEY];
    }
    else if(!self.templateEditTooltipView.hidden) {
        [defaults setObject:@YES forKey:TOOLTIP_TEMPLATEEDIT_KEY];
    }
    [defaults synchronize];
    
    [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
                         
                         self.homeTooltipView.alpha = 0;
                         self.photosTooltipView.alpha = 0;
                         self.layoutsTooltipView.alpha = 0;
                         self.editTooltipView.alpha = 0;
                         self.templateEditTooltipView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         if(finished) {
                             self.homeTooltipView.hidden = YES;
                             self.photosTooltipView.hidden = YES;
                             self.layoutsTooltipView.hidden = YES;
                             self.editTooltipView.hidden = YES;
                             self.templateEditTooltipView.hidden = YES;
                             
                             [self.tooltipDelegate tooltipViewControllerDidClose];
                         }
                     }];
    
}

- (void)showAnimationWithTargetViews:(NSArray *)targetViews
{
    CGFloat animationDelay = 0.55;
    CGFloat duration = 0.55;
    CGFloat damping = 1;
    CGFloat velocity = 1;
    CGFloat delay = 0.023;
    
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.65];
                     }
                     completion:^(BOOL finished){
                     }];
    
    for(id item in targetViews) {
        UIView *targetView = (UIView *)item;
        CGAffineTransform targetViewTransform;
        CGFloat targetViewAlpha;
        
        if(targetView.hidden == NO) {
            if([item isKindOfClass:[UIImageView class]]) {
                targetViewAlpha = targetView.alpha;
                targetViewTransform = targetView.transform;
                
                targetView.alpha = 0;
                CGFloat translationX = (CGFloat)(arc4random() % 20) - 10;
                CGFloat scaleValue = (CGFloat)((arc4random() % 50) + 100) * 0.01;
                targetView.transform = CGAffineTransformTranslate(targetView.transform, translationX, 0);
                if(arc4random() % 2 == 1) {
                    targetView.transform = CGAffineTransformScale(targetView.transform, scaleValue, 1);
                } else {
                    targetView.transform = CGAffineTransformScale(targetView.transform, 1, scaleValue);
                }
                
                [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     targetView.transform = targetViewTransform;
                                     targetView.alpha = targetViewAlpha;
                                 }
                                 completion:^(BOOL finished){
                                 }];
                animationDelay += delay;
            } else if([item isKindOfClass:[UILabel class]]) {
                targetViewAlpha = targetView.alpha;
                targetViewTransform = targetView.transform;
                
                targetView.alpha = 0;
                
                CGFloat translationX = (CGFloat)(arc4random() % 30) - 15;
                targetView.transform = CGAffineTransformTranslate(targetView.transform, translationX, 0);
                
                [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     targetView.transform = targetViewTransform;
                                     targetView.alpha = targetViewAlpha;
                                 }
                                 completion:^(BOOL finished){
                                 }];
                animationDelay += delay;
            }
        }
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        [self hiddenAllTooltip];
    }
}

@end
