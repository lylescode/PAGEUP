//
//  PCubeView.m
//  Page
//
//  Created by CMR on 6/23/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "PCubeView.h"
@interface PCubeView ()

- (void)initPCubeView;

@end

@implementation PCubeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initPCubeView];
    }
    return self;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initPCubeView];
}

- (void)dealloc
{
    self.shapeColor = nil;
}

- (void)initPCubeView
{
    //TODO: 큐브 그리는 기능 추가
    self.originalColor = self.backgroundColor;
    
    self.angle = 0;
    if(self.viewRotation) {
        self.angle = [self.viewRotation floatValue] * (M_PI / 180);
    }
    if(self.viewCornerRadius) {
        self.layer.cornerRadius = MIN(self.bounds.size.height * 0.5, [self.viewCornerRadius floatValue]);
    }
    if(self.viewBorderColor) {
        self.layer.borderColor = self.viewBorderColor.CGColor;
    }
    if(self.viewBorderWidth) {
        self.layer.borderWidth = [self.viewBorderWidth floatValue];
    }
    
    self.transform = CGAffineTransformMakeRotation(self.angle);
    
    self.clipsToBounds = YES;
    
    self.shapeColor = self.backgroundColor;
    //self.shapeColor = [UIColor redColor];
    self.backgroundColor = [UIColor clearColor];
    
    [self setNeedsDisplay];
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
    
    [self setNeedsDisplay];
}

- (void)updateProperties
{
    [super updateProperties];
    if(self.shapeColor) {
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)drawRect:(CGRect)rect
{
    NSLog(@"PCubeView drawRect");
    
    CGFloat displayScale = [[UIScreen mainScreen] scale];
    CGFloat polySize = (self.frame.size.height / 2 * displayScale); // change this
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    
    CGAffineTransform t0 = CGContextGetCTM(currentContext);
    t0 = CGAffineTransformInvert(t0);
    CGContextConcatCTM(currentContext, t0);
    
    //Begin drawing setup
    CGContextBeginPath(currentContext);
    CGContextSetRGBStrokeColor(currentContext, 0, 0, 0, 1);
    CGContextSetFillColorWithColor(currentContext, self.shapeColor.CGColor);
    //CGContextSetLineWidth(context, 2.0);
    
    CGPoint center;
    
    //Start drawing polygon
    center = CGPointMake((self.bounds.size.width / 2) * displayScale, (self.bounds.size.height / 2) * displayScale);
    CGContextMoveToPoint(currentContext, center.x, center.y + polySize);
    for(int i = 1; i < 6; ++i)
    {
        CGFloat x = polySize * sinf(i * 2.0 * M_PI / 6);
        CGFloat y = polySize * cosf(i * 2.0 * M_PI / 6);
        CGContextAddLineToPoint(currentContext, center.x + x, center.y + y);
    }
    
    //Finish Drawing
    CGContextClosePath(currentContext);
    CGContextFillPath(currentContext);
    CGContextRestoreGState(currentContext);
}

@end
