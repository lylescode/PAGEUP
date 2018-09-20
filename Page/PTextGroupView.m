//
//  PTextGroupView.m
//  DPage
//
//  Created by CMR on 10/15/14.
//  Copyright (c) 2014 BucketLabs. All rights reserved.
//

#import "PTextGroupView.h"
#import "PUILabel.h"

@interface PTextGroupView ()
- (void)initTextGroupView;

@end

@implementation PTextGroupView

@synthesize viewRotation;

@synthesize angle;
@synthesize scale;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initTextGroupView];
    }
    return self;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initTextGroupView];
}

- (void)initTextGroupView
{
    angle = 0;
    scale = 1;
    if(viewRotation != nil) {
        angle = [viewRotation floatValue] * (M_PI / 180);
    }
    for(id item in [self subviews]) {
        
        if([item isKindOfClass:[PUILabel class]]) {
            PUILabel *label = (PUILabel *)item;
            
            label.adjustsFontSizeToFitWidth = NO;
            label.minimumScaleFactor = 0.1;
        }
    }
    self.transform = CGAffineTransformMakeRotation(angle);
    self.transform = CGAffineTransformScale(self.transform, scale, scale);
}


- (void)resizeWithScale:(CGFloat)resizeScale
{
    for(id item in [self subviews]) {
        
        if([item isKindOfClass:[PUILabel class]]) {
            PUILabel *label = (PUILabel *)item;
            [label resizeWithScale:resizeScale];
        } else {
            
            UIView *itemView = (UIView *)item;
            CGRect itemFrame = (CGRect){
                itemView.frame.origin.x * resizeScale,
                itemView.frame.origin.y * resizeScale,
                itemView.frame.size.width * resizeScale,
                itemView.frame.size.height * resizeScale
            };
            itemView.frame = itemFrame;
        }
        
    }
    
}

- (void)adjustTextGroupSize
{
    //NSLog(@"adjustTextGroupSize");
    CGRect adjustFrame = (CGRect) {
        self.frame.origin.x,
        self.frame.origin.y,
        0,
        0
    };
    CGFloat leftMargin = self.frame.size.width;
    CGFloat topMargin = self.frame.size.height;
    for(id item in [self subviews]) {
        UIView *subView = (UIView *)item;
        if(subView.frame.origin.x < leftMargin) {
            leftMargin = subView.frame.origin.x;
        }
        if(subView.frame.origin.x < topMargin) {
            topMargin = subView.frame.origin.y;
        }
        
        CGFloat subViewRight = subView.frame.origin.x + subView.frame.size.width;
        CGFloat subViewBottom = subView.frame.origin.y + subView.frame.size.height;
        if(subViewRight > adjustFrame.size.width) {
            adjustFrame.size.width = subViewRight;
        }
        if(subViewBottom > adjustFrame.size.height) {
            adjustFrame.size.height = subViewBottom;
        }
    }
    adjustFrame.size.width = adjustFrame.size.width + leftMargin;
    adjustFrame.size.height = adjustFrame.size.height + topMargin;
    
    
    //NSLog(@"adjustTextGroupSize current frame : %@", NSStringFromCGRect(self.frame));
    //NSLog(@"adjustTextGroupSizemeasure frame : %@", NSStringFromCGRect(adjustFrame));
    
    self.frame = adjustFrame;
    
}

@end
