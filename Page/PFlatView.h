//
//  PFlatView.h
//  DPage
//
//  Created by CMR on 10/27/14.
//  Copyright (c) 2014 BucketLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PFlatView : UIView
@property (strong, nonatomic) UIColor *originalColor;
@property (strong, nonatomic) NSNumber *viewRotation;
@property (strong, nonatomic) NSNumber *viewCornerRadius;
@property (strong, nonatomic) NSNumber *viewBorderWidth;
@property (strong, nonatomic) UIColor *viewBorderColor;
@property (assign, nonatomic) BOOL fixedPosition;
@property (assign, nonatomic) BOOL relationBackground;
@property (assign, nonatomic) BOOL useDefaultColor;

@property (assign, nonatomic) CGFloat angle;

- (void)updateProperties;
- (void)resizeWithScale:(CGFloat)resizeScale;
- (BOOL)isLine;

@end
