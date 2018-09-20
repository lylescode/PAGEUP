//
//  PTextGroupView.h
//  DPage
//
//  Created by CMR on 10/15/14.
//  Copyright (c) 2014 BucketLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTextGroupView : UIView

@property (strong, nonatomic) NSNumber *viewRotation;
@property (assign, nonatomic) BOOL fixedPosition;

@property (assign, nonatomic) CGFloat angle;
@property (assign, nonatomic) CGFloat scale;

- (void)resizeWithScale:(CGFloat)resizeScale;
- (void)adjustTextGroupSize;

@end
