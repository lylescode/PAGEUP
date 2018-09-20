//
//  PImageView.h
//  DPage
//
//  Created by CMR on 10/15/14.
//  Copyright (c) 2014 BucketLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PImageView : UIImageView

@property (strong, nonatomic) NSNumber *viewRotation;
@property (strong, nonatomic) NSNumber *defaultAlpha;
@property (strong, nonatomic) UIColor *defaultColor;
@property (strong, nonatomic) NSString *imageName;

@property (assign, nonatomic) CGFloat angle;
@property (assign, nonatomic) CGFloat scale;
@property (assign, nonatomic) BOOL noneColored;
@property (assign, nonatomic) BOOL relationBackground;

@property (strong, nonatomic) UIColor *_imageColor;
@property (strong, nonatomic) UIImage *_originalImage;
@property (strong, nonatomic) UIColor *imageColor;
@property (strong, nonatomic) UIImage *originalImage;

- (void)resizeWithScale:(CGFloat)resizeScale;

@end
