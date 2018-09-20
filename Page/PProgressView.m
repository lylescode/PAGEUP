//
//  PProgressView.m
//  Page
//
//  Created by CMR on 6/8/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "PProgressView.h"

@implementation PProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"PProgressView" owner:self options:nil];
        
        self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.progressView];
        
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_progressView);

        [self addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:|[_progressView]|"
                                   options:0
                                   metrics:nil
                                   views:viewsDictionary]];
        [self addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:|[_progressView]|"
                                   options:0
                                   metrics:nil
                                   views:viewsDictionary]];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"PProgressView dealloc");
}

- (void)prepareProgress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.transform = CGAffineTransformMakeTranslation(0, -self.progressView.frame.size.height);
        self.progressBar.transform = CGAffineTransformMakeTranslation(-(self.progressBar.frame.size.width * 1), 0);
        [UIView animateWithDuration:0.45 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             self.progressView.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished){
                             
                         }];
    });
}

- (void)updateProgress:(CGFloat)progress
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.progressBar.transform = CGAffineTransformMakeTranslation(-(self.progressBar.frame.size.width * (1-progress)), 0);
                         }
                         completion:^(BOOL finished){
                             
                         }];
    });
    NSLog(@"progress %f", progress);
}

- (void)completeProgress
{
    [UIView animateWithDuration:0.45 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.progressView.transform = CGAffineTransformMakeTranslation(0, -self.progressView.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         
                         [self removeFromSuperview];
                     }];
}

@end
