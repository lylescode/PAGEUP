//
//  PImageView.m
//  DPage
//
//  Created by CMR on 10/15/14.
//  Copyright (c) 2014 BucketLabs. All rights reserved.
//

#import "PImageView.h"

@implementation PImageView

@synthesize viewRotation;
@synthesize defaultAlpha;
@synthesize defaultColor;
@synthesize imageName;

@synthesize angle;
@synthesize scale;
@synthesize noneColored;
@synthesize _imageColor;
@synthesize _originalImage;

- (id)init
{
    self = [super init];
    if (self) {
        angle = 0;
        scale = 1;
        if(viewRotation != nil) {
            angle = [viewRotation floatValue] * (M_PI / 180);
        }
        
        self.transform = CGAffineTransformMakeRotation(angle);
        self.transform = CGAffineTransformScale(self.transform, scale, scale);
        
        if(imageName == nil) {
            self.imageName = @"";
        }
        if(defaultAlpha) {
            self.alpha = [defaultAlpha floatValue];
        }
        if(defaultColor) {
            [self setImageColor:defaultColor];
        } else {
            //[self setImageColor:[UIColor whiteColor]];
        }
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeScaleToFill;
    }
    return self;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    angle = 0;
    scale = 1;
    if(viewRotation != nil) {
        angle = [viewRotation floatValue] * (M_PI / 180);
    }
    
    self.transform = CGAffineTransformMakeRotation(angle);
    self.transform = CGAffineTransformScale(self.transform, scale, scale);
    
    if(imageName == nil) {
        self.imageName = @"";
    }
    if(defaultAlpha != nil) {
        self.alpha = [defaultAlpha floatValue];
    }
    if(defaultColor != nil) {
        [self setImageColor:defaultColor];
    } else {
        [self setImageColor:[UIColor whiteColor]];
    }
    self.backgroundColor = [UIColor clearColor];
    self.contentMode = UIViewContentModeScaleToFill;
}

- (void)dealloc
{
    self.defaultAlpha = nil;
    self.defaultColor = nil;
    self.imageName = nil;
    self._imageColor = nil;
    self._originalImage = nil;
}

- (void)resizeWithScale:(CGFloat)resizeScale
{
    
}

- (void)setOriginalImage:(UIImage *)image
{
    if(image == nil) {
        return;
    }
    self._originalImage = image;
    
    float imageWHRatio = _originalImage.size.width / _originalImage.size.height;
    float frameWHRatio = self.frame.size.width / self.frame.size.height;
    if(imageWHRatio != frameWHRatio) {
        float newWidth = self.frame.size.height * imageWHRatio;
        CGPoint currentCenter = self.center;
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newWidth, self.frame.size.height);
        self.center = currentCenter;
    }
    
    self.image = _originalImage;
    if(_imageColor != nil) {
        [self setImageColor:_imageColor];
    }
}

- (UIImage *)originalImage
{
    return _originalImage;
}

- (void)setImageColor:(UIColor *)color
{
    if(self.image == nil) {
        return;
    }
    if(noneColored) {
        return;
    }
    self._imageColor = color;
    if(_originalImage == nil) {
        self._originalImage = self.image;
    }
    
    UIImage *coloredImage;
    
    CGSize imageSize = _originalImage.size;
    // 컬러 이미지 생성
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, imageSize.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGRect rect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    // draw tint color
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [color setFill];
    CGContextFillRect(context, rect);
    
    // mask by alpha values of original image
    CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
    CGContextDrawImage(context, rect, _originalImage.CGImage);
    
    coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.image = coloredImage;
    
}

- (UIColor *)imageColor
{
    if(_imageColor == nil) {
        self._imageColor = [UIColor whiteColor];
    }
    return _imageColor;
}
@end
