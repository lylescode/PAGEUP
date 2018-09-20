//
//  PPhotoView.m
//  DPage
//
//  Created by CMR on 10/25/14.
//  Copyright (c) 2014 BucketLabs. All rights reserved.
//

#import "PPhotoView.h"

@interface PPhotoView ()
{
    CGFloat _photoBrightness;
    CGFloat _photoScale;
    CGPoint _photoTranslation;
    
    
    
    BOOL _cropMode;
    BOOL dragging;
    NSInteger viewIndex;
    UITapGestureRecognizer *tapGesture;
    UIPanGestureRecognizer *panGesture;
    UIPinchGestureRecognizer *pinchGesture;
}
@property (strong, nonatomic) UIView *maskView;
@property (strong, nonatomic) UIImageView *photoImageView;
@property (strong, nonatomic) UIImageView *dimmedPhotoImageView;
@property (strong, nonatomic) UIView *brightnessView;
@property (strong, nonatomic) UIView *dimmedView;

- (void)initPPhotoView;

- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer;
//- (void)panGesture:(UIPanGestureRecognizer *)gestureRecognizer;
//- (void)pinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer;

@end

@implementation PPhotoView

@synthesize brightnessValue;
@synthesize viewRotation;
@synthesize viewCornerRadius;

@synthesize angle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initPPhotoView];
    }
    return self;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initPPhotoView];
}

- (void)initPPhotoView
{
    angle = 0;
    if(viewRotation) {
        angle = [viewRotation floatValue] * (M_PI / 180);
    }
    if(self.viewCornerRadius) {
        self.layer.cornerRadius = MIN(self.bounds.size.height * 0.5, [self.viewCornerRadius floatValue]);
    }
    if(!brightnessValue) {
        //self.brightnessValue = [NSNumber numberWithFloat:-0.05];
        self.brightnessValue = [NSNumber numberWithFloat:0.0];
    }
    
    _photoScale = 1;
    _photoTranslation = CGPointZero;
    
    self.transform = CGAffineTransformMakeRotation(angle);
    
    self.clipsToBounds = YES;
    //self.backgroundColor = [UIColor clearColor];
}

- (void)dealloc
{
    //NSLog(@"PPhotoView dealloc");
    if(self.dimmedView) {
        [self.dimmedView removeFromSuperview];
        self.dimmedView = nil;
    }
    if(self.photoImageView) {
        [self.photoImageView removeFromSuperview];
        self.photoImageView = nil;
    }
    if(self.brightnessView) {
        [self.brightnessView removeFromSuperview];
        self.brightnessView = nil;
    }
    /*
    if(self.maskView) {
        [self.maskView removeFromSuperview];
        self.maskView = nil;
    }
    */
    if(self.dimmedPhotoImageView) {
        [self.dimmedPhotoImageView removeFromSuperview];
        self.dimmedPhotoImageView = nil;
    }
}
- (void)replacePhotoImage:(UIImage *)photo
{
    if(!self.photoImageView) {
        [self setPhotoImage:photo];
    } else {
        self.photoImageView.image = photo;
    }
}
- (void)setPhotoImage:(UIImage *)photo
{
    BOOL isUpdate = NO;
    if(!photo) {
        return;
    }
    if(!self.maskView) {
        self.transform = CGAffineTransformMakeRotation(angle);
        UIView *mView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.maskView = mView;
        self.maskView.clipsToBounds = YES;
        
        self.maskView.transform = CGAffineTransformMakeRotation(angle * -1.);
        [self addSubview:self.maskView];
    }
    if(!self.photoImageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        self.photoImageView = imageView;
        self.photoImageView.contentMode = UIViewContentModeScaleToFill;
        [self.maskView addSubview:self.photoImageView];
        
    } else {
        isUpdate = YES;
    }
    
    if(!self.brightnessView) {
        UIView *bView = [[UIView alloc] init];
        self.brightnessView = bView;
        self.brightnessView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self.maskView addSubview:self.brightnessView];
        
        self.photoBrightness = [self.brightnessValue floatValue];
    }
    
    self.photoImageView.transform = CGAffineTransformIdentity;
    self.photoImageView.image = photo;
    
    if(self.dimmedPhotoImageView) {
        [self.dimmedPhotoImageView removeFromSuperview];
        self.dimmedPhotoImageView = nil;
    }
    
    CGSize originSize = photo.size;
    CGSize viewSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    
    CGFloat aspectFillScale = viewSize.width / originSize.width;
    if(originSize.height * aspectFillScale < viewSize.height) {
        aspectFillScale = viewSize.height / originSize.height;
    }
    
    CGSize aspectFillSize = (CGSize) {
        originSize.width * aspectFillScale,
        originSize.height * aspectFillScale
    };
    
    self.photoImageView.frame = (CGRect) {
        (viewSize.width - aspectFillSize.width) * 0.5,
        (viewSize.height - aspectFillSize.height) * 0.5,
        aspectFillSize.width,
        aspectFillSize.height
    };
    self.brightnessView.frame = self.photoImageView.frame;
    if(isUpdate) {
        self.photoImageView.alpha = 0;
        
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.photoImageView.alpha = 1;
                             
                         } completion:^(BOOL finished) {
                         }];
    }
    
    _photoScale = 1;
    _photoTranslation = self.photoImageView.center;
    
}

- (UIImage *)photoImage
{
    return self.photoImageView.image;
    
    
}



- (CGFloat)photoBrightness
{
    return _photoBrightness;
}

- (void)setPhotoBrightness:(CGFloat)brightness
{
    [self setPhotoBrightness:brightness animated:NO];
}
- (void)setPhotoBrightness:(CGFloat)brightness animated:(BOOL)animated
{
    
    _photoBrightness = brightness;
    if(self.brightnessView) {
        self.brightnessValue = [NSNumber numberWithFloat:brightness];
        
        UIColor *brightnessColor;
        if(brightness < 0) {
            brightnessColor = [UIColor colorWithWhite:0 alpha:-brightness];
        } else {
            brightnessColor = [UIColor colorWithWhite:1 alpha:brightness];
        }
        
        if(animated) {
            [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.brightnessView.backgroundColor = brightnessColor;
                             }
                             completion:^(BOOL finished){
                                 if(finished) {
                                     
                                 }
                             }];
        } else {
            self.brightnessView.backgroundColor = brightnessColor;
        }
    }
}

- (void)setPhotoScale:(CGFloat)pScale animated:(BOOL)animated
{
    _photoScale = MAX(1, pScale);
    
    if(animated) {
        [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.photoImageView.transform = CGAffineTransformMakeScale(_photoScale, _photoScale);
                             
                             if(self.dimmedPhotoImageView) {
                                 self.dimmedPhotoImageView.transform = CGAffineTransformMakeScale(_photoScale, _photoScale);
                             }
                         }
                         completion:^(BOOL finished){
                             if(finished) {
                                 
                             }
                         }];
    } else {
        self.photoImageView.transform = CGAffineTransformMakeScale(_photoScale, _photoScale);
        
        if(self.dimmedPhotoImageView) {
            self.dimmedPhotoImageView.transform = CGAffineTransformMakeScale(_photoScale, _photoScale);
        }
    }
}

- (void)setPhotoScale:(CGFloat)pScale
{
    [self setPhotoScale:pScale animated:NO];
}
- (CGFloat)photoScale
{
    return _photoScale;
}

- (void)setPhotoTranslation:(CGPoint)pTranslation animated:(BOOL)animated
{
    CGRect originalFrame = self.photoImageView.frame;
    
    _photoTranslation = pTranslation;
    self.photoImageView.center = _photoTranslation;
    
    CGRect photoFrame = self.photoImageView.frame;
    
    if(photoFrame.origin.x > 0) {
        
        _photoTranslation.x -= photoFrame.origin.x;
    }
    if(photoFrame.origin.y > 0) {
        _photoTranslation.y -= photoFrame.origin.y;
    }
    
    CGFloat rightBorder = photoFrame.origin.x + photoFrame.size.width;
    if(rightBorder < self.frame.size.width) {
        _photoTranslation.x += (self.frame.size.width - rightBorder);
    }
    
    CGFloat bottomBorder = photoFrame.origin.y + photoFrame.size.height;
    if(bottomBorder < self.frame.size.height) {
        _photoTranslation.y += (self.frame.size.height - bottomBorder);
    }
    
    if(animated) {
        self.photoImageView.frame = originalFrame;
        
        [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.photoImageView.center = _photoTranslation;
                             if(self.dimmedPhotoImageView) {
                                 self.dimmedPhotoImageView.center = _photoTranslation;
                             }
                         }
                         completion:^(BOOL finished){
                             if(finished) {
                                 
                             }
                         }];
    } else {
        self.photoImageView.center = _photoTranslation;
        if(self.dimmedPhotoImageView) {
            self.dimmedPhotoImageView.center = _photoTranslation;
        }
    }
}
- (void)setPhotoTranslation:(CGPoint)pTranslation
{
    [self setPhotoTranslation:pTranslation animated:NO];
}

- (CGPoint)photoTranslation
{
    return _photoTranslation;
}

- (void)resizeWithScale:(CGFloat)resizeScale
{
    if(self.viewCornerRadius) {
        self.layer.cornerRadius = MIN(self.bounds.size.height * 0.5, [self.viewCornerRadius floatValue] * resizeScale);
    }
}


- (void)setCropMode:(BOOL)cropMode
{
    _cropMode = cropMode;
    if(cropMode) {
        view = (UIView *)[self superview]
        //viewIndex = [[self superview].subviews indexOfObject:self];
        //[[self superview] bringSubviewToFront:self];
        self.clipsToBounds = NO;
        
        
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        tapGesture.delegate = self;
        tapGesture.numberOfTapsRequired = 1;
        
        
        panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        panGesture.delegate = self;
        
        pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
        pinchGesture.delegate = self;
        
        [self addGestureRecognizer:tapGesture];
        [self addGestureRecognizer:panGesture];
        [self addGestureRecognizer:pinchGesture];
        
        
        if(!self.dimmedView) {
            UIView *dView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2048, 2048)];
            self.dimmedView = dView;
            self.dimmedView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
            self.dimmedView.userInteractionEnabled = NO;
        }
        self.dimmedView.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
        self.dimmedView.alpha = 0;
        
        if(!self.dimmedPhotoImageView) {
            UIImageView *dPImageView = [[UIImageView alloc] init];
            self.dimmedPhotoImageView = dPImageView;
            self.dimmedPhotoImageView.contentMode = UIViewContentModeScaleToFill;
        }
        self.dimmedPhotoImageView.transform = CGAffineTransformMakeScale(_photoScale, _photoScale);
        self.dimmedPhotoImageView.frame = self.photoImageView.frame;
        self.dimmedPhotoImageView.image = self.photoImageView.image;
        self.dimmedPhotoImageView.alpha = 0;
        
        
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.dimmedPhotoImageView.alpha = 0.20;
                             self.dimmedView.alpha = 1;
                         }
                         completion:^(BOOL finished){
                         }];
        
        [self addSubview:self.dimmedView];
        [self addSubview:self.dimmedPhotoImageView];
        [self bringSubviewToFront:self.maskView];
        
        
    } else {
        //[[self superview] insertSubview:self atIndex:viewIndex];
        [self removeGestureRecognizer:tapGesture];
        [self removeGestureRecognizer:panGesture];
        [self removeGestureRecognizer:pinchGesture];
        
        if(self.dimmedPhotoImageView) {
            [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.dimmedPhotoImageView.alpha = 0;
                             }
                             completion:^(BOOL finished){
                                 if(finished) {
                                     self.clipsToBounds = YES;
                                     [self.dimmedPhotoImageView removeFromSuperview];
                                 }
                             }];
        }
        if(self.dimmedView) {
            [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.dimmedView.alpha = 0;
                             }
                             completion:^(BOOL finished){
                                 if(finished) {
                                     [self.dimmedView removeFromSuperview];
                                 }
                             }];
        }
    }
    
}

- (BOOL)cropMode
{
    return _cropMode;
}

- (void)panGestureEnabled:(BOOL)enabled
{
    if(panGesture) {
        panGesture.enabled = enabled;
    }
}
- (void)pinchGestureEnabled:(BOOL)enabled
{
    if(pinchGesture) {
        pinchGesture.enabled = enabled;
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        //NSLog(@"Tap");
    }
}

- (void)panGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        //NSLog(@"Pan Began");
        dragging = YES;
    } else if ([gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gestureRecognizer translationInView:self];
        
        CGPoint newPhotoTranslation = (CGPoint) {
            self.photoTranslation.x + translation.x,
            self.photoTranslation.y + translation.y
        };
        
        [self setPhotoTranslation:newPhotoTranslation animated:YES];
        
        [gestureRecognizer setTranslation:CGPointZero inView:self];
        
    } else if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        //NSLog(@"Pan Ended");
        dragging = NO;
    }
    
}
- (void)pinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer
{
    
    //[self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged)
    {
        CGFloat pinchScale = [gestureRecognizer scale];
        
        [self setPhotoScale:self.photoScale * pinchScale animated:YES];
        
        [gestureRecognizer setScale:1];
    }
}


// scale and rotation transforms are applied relative to the layer's anchor point
// this method moves a gesture recognizer's view's anchor point between the user's fingers
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        UIView *gestureRecognizerView = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:gestureRecognizerView];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:gestureRecognizerView.superview];
        
        gestureRecognizerView.layer.anchorPoint = CGPointMake(locationInView.x / gestureRecognizerView.bounds.size.width, locationInView.y / gestureRecognizerView.bounds.size.height);
        gestureRecognizerView.center = locationInSuperview;
        
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if(dragging) {
        return NO;
    }
    return YES;
}

@end
