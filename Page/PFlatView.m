//
//  PFlatView.m
//  DPage
//
//  Created by CMR on 10/27/14.
//  Copyright (c) 2014 BucketLabs. All rights reserved.
//

#import "PFlatView.h"
@interface PFlatView ()

- (void)initPFlatView;
@end

@implementation PFlatView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initPFlatView];
    }
    return self;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initPFlatView];
}
- (void)dealloc
{
    self.originalColor = nil;
}

- (void)initPFlatView
{
    self.originalColor = self.backgroundColor;
    self.angle = 0;
    if(self.viewRotation) {
        self.angle = [self.viewRotation floatValue] * (M_PI / 180);
    }
    if(self.viewCornerRadius) {
        self.layer.cornerRadius = MIN(self.bounds.size.height * 0.5, [self.viewCornerRadius floatValue]);
    }
    if(self.viewBorderColor) {
        self.originalColor = self.viewBorderColor;
        self.layer.borderColor = self.viewBorderColor.CGColor;
    }
    if(self.viewBorderWidth) {
        self.layer.borderWidth = [self.viewBorderWidth floatValue];
    }
    
    self.transform = CGAffineTransformMakeRotation(self.angle);
    
    self.clipsToBounds = YES;
}

- (void)updateProperties
{
    if(self.viewBorderColor) {
        self.backgroundColor = [UIColor clearColor];
        
        self.originalColor = self.viewBorderColor;
        self.layer.borderColor = self.viewBorderColor.CGColor;
    }
}

- (void)resizeWithScale:(CGFloat)resizeScale
{
    CGFloat displayScale = [[UIScreen mainScreen] scale];
    CGFloat minimumPixel = 1 / displayScale;
    
    if(self.viewCornerRadius) {
        self.layer.cornerRadius = MIN(self.bounds.size.height * 0.5, [self.viewCornerRadius floatValue] * resizeScale);
    }
    if(self.viewBorderWidth) {
        self.layer.borderWidth = MAX(minimumPixel, [self.viewBorderWidth floatValue] * resizeScale);
    }
}

- (BOOL)isLine
{
    if(self.viewBorderWidth.floatValue > 0) {
        return YES;
    }
    
    CGFloat width, height;
    
    width = CGRectGetWidth(self.frame);
    height = CGRectGetHeight(self.frame);
    
    CGFloat ratio = width / height;
    
    if(ratio <= 1) {
        return (ratio < 0.25) ? YES : NO;
    } else {
        return (ratio > 4) ? YES : NO;
    }
}
@end
