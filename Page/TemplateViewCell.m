//
//  TemplateViewCell.m
//  Page
//
//  Created by CMR on 12/3/14.
//  Copyright (c) 2014 Page. All rights reserved.
//

#import "TemplateViewCell.h"

@implementation TemplateViewCell


- (void)awakeFromNib {
    
    [super awakeFromNib];
    self.borderView.hidden = YES;
    self.borderView.alpha = 0;
    self.clipsToBounds = NO;
}

- (void)dealloc
{
    if(_templateView) {
        [_templateView removeFromSuperview];
        _templateView = nil;
    }
    if(self.shadowView) {
        [self.shadowView removeFromSuperview];
        self.shadowView = nil;
    }
}

- (void)prepareForReuse
{
    if(_templateView) {
        [_templateView removeFromSuperview];
        _templateView = nil;
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        self.borderView.hidden = NO;
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.borderView.alpha = 1;
                         }
                         completion:^(BOOL finished){
                         }];
    } else {
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.borderView.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             if(finished) {
                                 self.borderView.hidden = YES;
                             }
                         }];
    }
}

- (void)setTemplateView:(UIView *)templateView {
    if(_templateView) {
        [_templateView removeFromSuperview];
        _templateView = nil;
    }
    if(!self.shadowView) {
        UIView *shadow = [[UIView alloc] init];
        shadow.backgroundColor = [UIColor whiteColor];
        [self addSubview:shadow];
        self.shadowView = shadow;
        
    }
    _templateView = templateView;
    self.shadowView.frame = templateView.frame;
    self.shadowView.layer.masksToBounds = NO;
    self.shadowView.layer.shadowOpacity = 0.15f;
    self.shadowView.layer.shadowRadius = 4.0f;
    self.shadowView.layer.shadowOffset = CGSizeZero;
    self.shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRect:templateView.bounds].CGPath;
    [self addSubview:templateView];
    
}

- (void)fadeAnimation
{
    if(_templateView) {
        _templateView.alpha = 0;
        
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _templateView.alpha = 1;
                         }
                         completion:^(BOOL finished){
                         }];
    }
}

- (void)highlightAnimation
{
    if(_templateView) {
        
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        animation.timingFunctions = @[
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]
                                      ];
        
        animation.values = @[ @(1), @(0.9), @(1.05), @(0.98), @(1.01), @(1) ];
        animation.duration = 0.75;
        
        [self.layer addAnimation:animation forKey:@"shake"];
    }
}

@end
