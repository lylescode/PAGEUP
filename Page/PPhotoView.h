//
//  PPhotoView.h
//  DPage
//
//  Created by CMR on 10/25/14.
//  Copyright (c) 2014 BucketLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PPhotoView : UIView <UIGestureRecognizerDelegate>
@property (strong, nonatomic) NSNumber *viewRotation;
@property (strong, nonatomic) NSNumber *viewCornerRadius;
@property (strong, nonatomic) NSNumber *brightnessValue;


@property (assign, nonatomic) CGFloat angle;

@property (assign, nonatomic) CGFloat photoBrightness;
@property (assign, nonatomic) CGFloat photoScale;
@property (assign, nonatomic) CGPoint photoTranslation;

@property (strong, nonatomic) UIImage *photoImage;

@property (assign, nonatomic) BOOL cropMode;

- (void)replacePhotoImage:(UIImage *)photo;
- (void)setPhotoBrightness:(CGFloat)brightness animated:(BOOL)animated;
- (void)setPhotoScale:(CGFloat)pScale animated:(BOOL)animated;
- (void)setPhotoTranslation:(CGPoint)pTranslation animated:(BOOL)animated;
- (void)resizeWithScale:(CGFloat)resizeScale;


// PPhotoView 외부에서(PhotoEditViewController 에서 사용함) panGesture 인식되게 하려고 panGesture 메소드만 퍼블릭으로 처리
- (void)panGestureEnabled:(BOOL)enabled;
- (void)panGesture:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)pinchGestureEnabled:(BOOL)enabled;
- (void)pinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer;

@end
