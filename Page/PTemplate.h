//
//  PTemplate.h
//  DPage
//
//  Created by CMR on 10/25/14.
//  Copyright (c) 2014 BucketLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPhotoAsset.h"
#import "PTextGroupView.h"
#import "PPhotoView.h"
#import "PFlatView.h"
#import "PCubeView.h"
#import "PImageView.h"
#import "PCoverImageView.h"
#import "PUILabel.h"

@interface PTemplate : UIView
{
    UIView *loadedNibView;
    UIImage *capturedImage;
    
    CGRect originalTemplateFrame;
    CGRect nibViewFrame;
    
    CGFloat nibViewResizeRatio;
    CGFloat previewResizeScale;
    
    CGFloat angle;
    CGFloat scale;
    CGFloat opacity;
}

@property (strong, nonatomic) IBOutlet UIView *loadedNibView;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIColor *originalBackgroundColor;

@property (strong, nonatomic) NSMutableDictionary *templateTextDictionary;
@property (strong, nonatomic) NSMutableDictionary *projectDictionary;
@property (weak, nonatomic) NSMutableDictionary *templateDictionary;

@property (strong, nonatomic) NSArray *textGroupViewPropertiesArray;
@property (strong, nonatomic) NSArray *photoViewPropertiesArray;
@property (strong, nonatomic) NSArray *flatViewPropertiesArray;
@property (strong, nonatomic) NSArray *imageViewPropertiesArray;

@property (strong, nonatomic) NSArray *textGroupViewArray;
@property (strong, nonatomic) NSArray *photoViewArray;
@property (strong, nonatomic) NSArray *flatViewArray;
@property (strong, nonatomic) NSArray *imageViewArray;
@property (strong, nonatomic) NSArray *allItemArray;

@property (strong, nonatomic) NSString *locationString;


- (id)initWithFrame:(CGRect)frame templateDictionary:(NSDictionary *)dictionary;
- (id)initWithScale:(CGFloat)resizeScale templateDictionary:(NSDictionary *)dictionary;
- (void)setupTemplate;

- (void)showCreatingAnimation;

- (void)pixelPerfect;

- (NSDictionary *)updateProjectDictionary;
- (void)setupProjectDictionary:(NSDictionary *)project;

- (NSDictionary *)templateTextDictionary;
- (void)setTemplateTextWithDictionary:(NSDictionary *)textDictionary;
- (void)setTemplateTextWithFooterString:(NSString *)footerString;
- (void)setPhotosWithPhotoArray:(NSArray *)photoArray;
- (void)setPhotosWithPhotoArray:(NSArray *)photoArray useThumbnail:(BOOL)useThumnail;
- (id)editableItemAtContainsPoint:(CGPoint)point fromView:(UIView *)fromView;
- (id)draggableItemAtContainsPoint:(CGPoint)point fromView:(UIView *)fromView;


@end
