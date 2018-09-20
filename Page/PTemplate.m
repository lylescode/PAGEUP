//
//  PTemplate.m
//  DPage
//
//  Created by CMR on 10/25/14.
//  Copyright (c) 2014 BucketLabs. All rights reserved.
//

#import "PTemplate.h"
#import "NSString+Color.h"
#import "Utils.h"
@interface PTemplate ()

- (void)setupNibView;
- (void)setupTextItems;
- (void)setupImageItems;
- (void)sortAllItems;

@end

@implementation PTemplate
@synthesize loadedNibView;

- (id)initWithFrame:(CGRect)frame templateDictionary:(NSMutableDictionary *)dictionary
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;
        
        angle = 0;
        scale = 1;
        
        [[NSBundle mainBundle] loadNibNamed:[dictionary objectForKey:@"NibName"] owner:self options:nil];
        previewResizeScale = frame.size.width / loadedNibView.frame.size.width;
        if(frame.size.height < loadedNibView.frame.size.height * previewResizeScale) {
            previewResizeScale = frame.size.height / loadedNibView.frame.size.height;
        }
        nibViewFrame = loadedNibView.frame;
        loadedNibView.backgroundColor = [UIColor clearColor];
        loadedNibView.autoresizesSubviews = NO;
        
        originalTemplateFrame = loadedNibView.frame;
        
        scale = previewResizeScale;
        self.templateDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    }
    return self;
}

- (id)initWithScale:(CGFloat)resizeScale templateDictionary:(NSMutableDictionary *)dictionary
{
    self = [super init];
    if (self) {
        
        self.clipsToBounds = YES;
        
        angle = 0;
        scale = 1;
        
        [[NSBundle mainBundle] loadNibNamed:[dictionary objectForKey:@"NibName"] owner:self options:nil];
        previewResizeScale = resizeScale;
        nibViewFrame = loadedNibView.frame;
        loadedNibView.backgroundColor = [UIColor clearColor];
        loadedNibView.autoresizesSubviews = NO;
        
        originalTemplateFrame = loadedNibView.frame;
        
        scale = previewResizeScale;
        self.templateDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
        
    }
    return self;
}

- (void)setupTemplate
{
    [self setupNibView];
}

- (void)awakeFromNib
{
    //NSLog(@"awakeFromNib");
    [super awakeFromNib];
}

- (void)dealloc
{
    //MARK;
    self.templateDictionary = nil;
    self.projectDictionary = nil;
    self.templateTextDictionary = nil;
    
    self.textGroupViewPropertiesArray = nil;
    self.photoViewPropertiesArray = nil;
    self.flatViewPropertiesArray = nil;
    self.imageViewPropertiesArray = nil;
    self.textGroupViewArray = nil;
    self.photoViewArray = nil;
    self.flatViewArray = nil;
    self.imageViewArray = nil;
    self.allItemArray = nil;
    
    if(self.textGroupViewArray) {
        for(UIView *textItem in self.textGroupViewArray) {
            [textItem removeFromSuperview];
        }
        self.textGroupViewArray = nil;
    }
    if(self.photoViewArray) {
        for(UIView *photoView in self.photoViewArray) {
            [photoView removeFromSuperview];
        }
        self.photoViewArray = nil;
    }
    if(self.flatViewArray) {
        for(UIView *flatView in self.flatViewArray) {
            [flatView removeFromSuperview];
        }
        self.flatViewArray = nil;
    }
    if(self.imageViewArray) {
        for(UIView *imageView in self.imageViewArray) {
            [imageView removeFromSuperview];
        }
        self.imageViewArray = nil;
    }
    
    self.allItemArray = nil;
    
    self.backgroundView = nil;
    self.originalBackgroundColor = nil;
    
    if(loadedNibView != nil) {
        [loadedNibView removeFromSuperview];
        self.loadedNibView = nil;
    }
}

- (void)showCreatingAnimation
{
    NSArray *targetViews = [Utils shuffleArray:[self.loadedNibView subviews]];
    CGFloat animationDelay = 0.55;
    CGFloat duration = 0.65;
    CGFloat damping = 0.95;
    CGFloat velocity = 0;
    CGFloat delay = 0.028;
    
    CGFloat flatViewDelay = 0.3;
    CGFloat textGroupViewDelay = 0.45;
    
    for(id item in targetViews) {
        UIView *targetView = (UIView *)item;
        CGAffineTransform targetViewTransform;
        CGFloat targetViewAlpha;
        
        if(targetView.hidden == NO) {
            if([item isKindOfClass:[PFlatView class]]) {
                targetViewAlpha = targetView.alpha;
                targetViewTransform = targetView.transform;
                
                targetView.alpha = 0;
                CGFloat translationX = (CGFloat)(arc4random() % 20) - 10;
                CGFloat scaleValue = (CGFloat)((arc4random() % 50) + 100) * 0.01;
                targetView.transform = CGAffineTransformTranslate(targetView.transform, translationX, 0);
                if(arc4random() % 2 == 1) {
                    targetView.transform = CGAffineTransformScale(targetView.transform, scaleValue, 1);
                } else {
                    targetView.transform = CGAffineTransformScale(targetView.transform, 1, scaleValue);
                }
                
                [UIView animateWithDuration:duration delay:animationDelay + flatViewDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     targetView.transform = targetViewTransform;
                                     targetView.alpha = targetViewAlpha;
                                 }
                                 completion:^(BOOL finished){
                                 }];
                animationDelay += delay;
            } else if([item isKindOfClass:[PTextGroupView class]]) {
                targetViewAlpha = targetView.alpha;
                targetViewTransform = targetView.transform;
                
                targetView.alpha = 0;
                
                CGFloat translationX = (CGFloat)(arc4random() % 30) - 15;
                targetView.transform = CGAffineTransformTranslate(targetView.transform, translationX, 0);
                
                [UIView animateWithDuration:duration delay:animationDelay + textGroupViewDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     targetView.transform = targetViewTransform;
                                     targetView.alpha = targetViewAlpha;
                                 }
                                 completion:^(BOOL finished){
                                 }];
                animationDelay += delay;
            } else if([item isKindOfClass:[PPhotoView class]]) {
                targetViewAlpha = targetView.alpha;
                targetViewTransform = targetView.transform;
                
                targetView.alpha = 0;
                CGFloat translationX = (CGFloat)(arc4random() % 20) - 10;
                CGFloat translationY = (CGFloat)(arc4random() % 20) - 10;
                targetView.transform = CGAffineTransformTranslate(targetView.transform, translationX, translationY);
                targetView.transform = CGAffineTransformScale(targetView.transform, 1.5, 1.5);
                
                [UIView animateWithDuration:duration + 0.15 delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     targetView.transform = targetViewTransform;
                                     targetView.alpha = targetViewAlpha;
                                 }
                                 completion:^(BOOL finished){
                                 }];
                animationDelay += delay;
            } else if([item isKindOfClass:[PImageView class]]) {
                targetViewAlpha = targetView.alpha;
                
                targetView.alpha = 0;
                
                [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     targetView.alpha = targetViewAlpha;
                                 }
                                 completion:^(BOOL finished){
                                 }];
                animationDelay += delay;
            } else {
                targetViewAlpha = targetView.alpha;
                targetView.alpha = 0;
                
                [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     targetView.alpha = targetViewAlpha;
                                 }
                                 completion:^(BOOL finished){
                                 }];
            }
            
        }
    }
    
}

- (void)pixelPerfect
{
    NSArray *templateSubviews = [self.loadedNibView subviews];
    for(id item in templateSubviews) {
        UIView *itemView = (UIView *)item;
        CGAffineTransform itemTransform = itemView.transform;
        itemView.transform = CGAffineTransformIdentity;
        
        CGRect itemFrame = (CGRect){
            floor(itemView.frame.origin.x),
            floor(itemView.frame.origin.y),
            floor(itemView.frame.size.width) + 1,
            floor(itemView.frame.size.height) + 1
        };
        
        if([item isKindOfClass:[PPhotoView class]]) {
            itemView.frame = itemFrame;
        } else if([item isKindOfClass:[PFlatView class]]) {
            itemView.frame = itemFrame;
        }
        itemView.transform = itemTransform;
    }
}

- (NSDictionary *)updateProjectDictionary
{
    NSArray *templateSubviews = [self.loadedNibView subviews];
    NSMutableArray *targetItems = [NSMutableArray array];
    for(id item in templateSubviews) {
        if([item isKindOfClass:[PTextGroupView class]]) {
            [targetItems addObject:item];
        } else if([item isKindOfClass:[PPhotoView class]]) {
            [targetItems addObject:item];
        } else if([item isKindOfClass:[PFlatView class]]) {
            [targetItems addObject:item];
        }
    }
    
    NSSortDescriptor *tagDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tag" ascending:YES];
    NSArray *sortedTargetItem = [targetItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:tagDescriptor]];
    
    
    NSMutableArray *textGroups = [NSMutableArray array];
    NSMutableArray *photoViews = [NSMutableArray array];
    NSMutableArray *flatViews = [NSMutableArray array];
    
    for (id item in sortedTargetItem) {
        UIView *itemView = (UIView *)item;
        NSNumber *itemTag = [NSNumber numberWithInteger:itemView.tag];
        CGRect itemFrame = (CGRect){
            itemView.frame.origin.x / previewResizeScale,
            itemView.frame.origin.y / previewResizeScale,
            itemView.frame.size.width / previewResizeScale,
            itemView.frame.size.height / previewResizeScale
        };
        
        if([item isKindOfClass:[PTextGroupView class]]) {
            PTextGroupView *textGroupView = (PTextGroupView *)item;
            CGAffineTransform textGroupViewTransform = textGroupView.transform;
            textGroupView.transform = CGAffineTransformIdentity;
            
            // TextGroupView 에 rotation 이 적용되어있는 경우가 있기 때문에 transform = CGAffineTransformIdentity; 후에 itemFrame 을 다시 계산
            itemFrame = (CGRect){
                textGroupView.frame.origin.x / previewResizeScale,
                textGroupView.frame.origin.y / previewResizeScale,
                textGroupView.frame.size.width / previewResizeScale,
                textGroupView.frame.size.height / previewResizeScale
            };
            
            NSMutableArray *labels = [NSMutableArray array];
            
            for(id subItem in [textGroupView subviews]) {
                if([subItem isKindOfClass:[PUILabel class]]) {
                    
                    PUILabel *label = (PUILabel *)subItem;
                    NSNumber *labelTag = [NSNumber numberWithInteger:label.tag];
                    
                    CGRect labelFrame = (CGRect){
                        label.frame.origin.x / previewResizeScale,
                        label.frame.origin.y / previewResizeScale,
                        label.frame.size.width / previewResizeScale,
                        label.frame.size.height / previewResizeScale
                    };
                    
                    NSDictionary *labelDictionary = @{
                                                      @"Class"  : NSStringFromClass([label class]),
                                                      @"OriginFrame" : NSStringFromCGRect(label.originFrame),
                                                      @"Frame"  : NSStringFromCGRect(labelFrame),
                                                      @"Tag"    : labelTag,
                                                      
                                                      @"OriginText" : label.originText,
                                                      @"Text"   : label.text,
                                                      
                                                      @"OriginFontName" : label.originFont.fontName,
                                                      @"OriginFontSize" : [NSNumber numberWithFloat:label.originFont.pointSize],
                                                      
                                                      @"FontName"   :label.font.fontName,
                                                      @"FontSize"   :[NSNumber numberWithFloat:label.font.pointSize / previewResizeScale],
                                                      @"TextColor"  :[Utils NSStringFromUIColor:label.textColor],
                                                      @"Alignment"  :[NSNumber numberWithInteger:label.textAlignment]
                                                      };
                    
                    [labels addObject:labelDictionary];
                }
            }
            
            textGroupView.transform = textGroupViewTransform;
            
            NSDictionary *itemDictionary = @{
                                             @"Class"   : NSStringFromClass([textGroupView class]),
                                             @"Frame"   : NSStringFromCGRect(itemFrame),
                                             @"Tag"     : itemTag,
                                             @"Labels"  : [NSArray arrayWithArray:labels]
                                             };
            
            [textGroups addObject:itemDictionary];
            
        } else if([item isKindOfClass:[PPhotoView class]]) {
            
            PPhotoView *photoView = (PPhotoView *)item;
            
            CGPoint photoTranslation = (CGPoint) {
                photoView.photoTranslation.x / previewResizeScale,
                photoView.photoTranslation.y / previewResizeScale
            };
            
            NSDictionary *itemDictionary = @{
                                             @"Class"   : NSStringFromClass([photoView class]),
                                             @"Frame"   : NSStringFromCGRect(itemFrame),
                                             @"Tag"     : itemTag,
                                             @"PhotoBrightness"     : [NSNumber numberWithFloat:photoView.photoBrightness],
                                             @"PhotoScale"          : [NSNumber numberWithFloat:photoView.photoScale],
                                             @"PhotoTranslation"    : NSStringFromCGPoint(photoTranslation)
                                             };
            [photoViews addObject:itemDictionary];
        } else if([item isKindOfClass:[PCubeView class]]) {
            
            PCubeView *cubeView = (PCubeView *)item;
            CGAffineTransform flatViewTransform = cubeView.transform;
            cubeView.transform = CGAffineTransformIdentity;
            
            // TextGroupView 에 rotation 이 적용되어있는 경우가 있기 때문에 transform = CGAffineTransformIdentity; 후에 itemFrame 을 다시 계산
            itemFrame = (CGRect){
                cubeView.frame.origin.x / previewResizeScale,
                cubeView.frame.origin.y / previewResizeScale,
                cubeView.frame.size.width / previewResizeScale,
                cubeView.frame.size.height / previewResizeScale
            };
            
            cubeView.transform = flatViewTransform;
            
            NSMutableDictionary *propertiesDictionary = [NSMutableDictionary dictionary];
            [propertiesDictionary setObject:[Utils NSStringFromUIColor:cubeView.backgroundColor] forKey:@"BackgroundColor"];
            
            if(cubeView.viewRotation) {
                [propertiesDictionary setObject:cubeView.viewRotation forKey:@"ViewRotation"];
            }
            if(cubeView.viewCornerRadius) {
                [propertiesDictionary setObject:cubeView.viewCornerRadius forKey:@"ViewCornerRadius"];
            }
            if(cubeView.viewBorderWidth) {
                [propertiesDictionary setObject:cubeView.viewBorderWidth forKey:@"ViewBorderWidth"];
            }
            if(cubeView.viewBorderColor) {
                [propertiesDictionary setObject:[Utils NSStringFromUIColor:cubeView.viewBorderColor] forKey:@"ViewBorderColor"];
            }
            if(cubeView.shapeColor) {
                [propertiesDictionary setObject:[Utils NSStringFromUIColor:cubeView.shapeColor] forKey:@"ShapeColor"];
            }
            
            
            NSDictionary *itemDictionary = @{@"Class"   : NSStringFromClass([cubeView class]),
                                             @"Frame"   : NSStringFromCGRect(itemFrame),
                                             @"Tag"     : itemTag,
                                             
                                             @"Properties"  : [NSDictionary dictionaryWithDictionary:propertiesDictionary]
                                             };
            [flatViews addObject:itemDictionary];
            
        } else if([item isKindOfClass:[PFlatView class]]) {
            
            PFlatView *flatView = (PFlatView *)item;
            CGAffineTransform flatViewTransform = flatView.transform;
            flatView.transform = CGAffineTransformIdentity;
            
            // TextGroupView 에 rotation 이 적용되어있는 경우가 있기 때문에 transform = CGAffineTransformIdentity; 후에 itemFrame 을 다시 계산
            itemFrame = (CGRect){
                flatView.frame.origin.x / previewResizeScale,
                flatView.frame.origin.y / previewResizeScale,
                flatView.frame.size.width / previewResizeScale,
                flatView.frame.size.height / previewResizeScale
            };
            
            flatView.transform = flatViewTransform;
            NSMutableDictionary *propertiesDictionary = [NSMutableDictionary dictionary];
            
            [propertiesDictionary setObject:[Utils NSStringFromUIColor:flatView.backgroundColor] forKey:@"BackgroundColor"];
            
            if(flatView.viewRotation) {
                [propertiesDictionary setObject:flatView.viewRotation forKey:@"ViewRotation"];
            }
            if(flatView.viewCornerRadius) {
                [propertiesDictionary setObject:flatView.viewCornerRadius forKey:@"ViewCornerRadius"];
            }
            if(flatView.viewBorderWidth) {
                [propertiesDictionary setObject:flatView.viewBorderWidth forKey:@"ViewBorderWidth"];
            }
            if(flatView.viewBorderColor) {
                [propertiesDictionary setObject:[Utils NSStringFromUIColor:flatView.viewBorderColor] forKey:@"ViewBorderColor"];
            }
            
            
            NSDictionary *itemDictionary = @{@"Class"   : NSStringFromClass([flatView class]),
                                             @"Frame"   : NSStringFromCGRect(itemFrame),
                                             @"Tag"     : itemTag,
                                             
                                             @"Properties"  : [NSDictionary dictionaryWithDictionary:propertiesDictionary]
                                             };
            
            [flatViews addObject:itemDictionary];
            MARK;
            
        }
    }
    
    
    NSDictionary *updatedDictionary = @{
                                        @"TextGroups"   : textGroups,
                                        @"PhotoViews"   : photoViews,
                                        @"FlatViews"    : flatViews,
                                        
                                        // optional
                                        @"BackgroundColor" : [Utils NSStringFromUIColor:self.backgroundView.backgroundColor]
                                        };
    self.projectDictionary = [NSMutableDictionary dictionaryWithDictionary:updatedDictionary];
    return updatedDictionary;
}
- (void)setupProjectDictionary:(NSDictionary *)project
{
    self.projectDictionary = [NSMutableDictionary dictionaryWithDictionary:project];
    
    NSArray *templateSubviews = [self.loadedNibView subviews];
    
    NSMutableArray *textGroups = [NSMutableArray array];
    NSMutableArray *photoViews = [NSMutableArray array];
    NSMutableArray *flatViews = [NSMutableArray array];
    
    for(id item in templateSubviews) {
        if([item isKindOfClass:[PTextGroupView class]]) {
            [textGroups addObject:item];
        } else if([item isKindOfClass:[PPhotoView class]]) {
            [photoViews addObject:item];
        } else if([item isKindOfClass:[PFlatView class]]) {
            [flatViews addObject:item];
        }
    }
    
    NSSortDescriptor *tagDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tag" ascending:YES];
    NSArray *sortedTextGroups = [textGroups sortedArrayUsingDescriptors:[NSArray arrayWithObject:tagDescriptor]];
    NSArray *sortedPhotoViews = [photoViews sortedArrayUsingDescriptors:[NSArray arrayWithObject:tagDescriptor]];
    NSArray *sortedFlatViews = [flatViews sortedArrayUsingDescriptors:[NSArray arrayWithObject:tagDescriptor]];
    
    
    NSArray *textGroupDictionaryArray = [self.projectDictionary objectForKey:@"TextGroups"];
    NSArray *photoViewDictionaryArray = [self.projectDictionary objectForKey:@"PhotoViews"];
    NSArray *flatViewDictionaryArray = [self.projectDictionary objectForKey:@"FlatViews"];
    
    if([self.projectDictionary objectForKey:@"BackgroundColor"]) {
        self.backgroundView.backgroundColor = [Utils UIColorFromRGBString:[self.projectDictionary objectForKey:@"BackgroundColor"]];
    }
    
    NSInteger index = 0;
    
    if(textGroupDictionaryArray.count == sortedTextGroups.count) {
        for (id item in sortedTextGroups) {
            UIView *itemView = (UIView *)item;
            
            NSDictionary *textGroupDictionary = [textGroupDictionaryArray objectAtIndex:index];
            NSInteger dTag = [[textGroupDictionary objectForKey:@"Tag"] integerValue];
            if(dTag != itemView.tag) {
                NSLog(@"tag match error");
            }
            CGRect dFrame = CGRectFromString([textGroupDictionary objectForKey:@"Frame"]);
            CGRect itemFrame = (CGRect) {
                dFrame.origin.x * previewResizeScale,
                dFrame.origin.y * previewResizeScale,
                dFrame.size.width * previewResizeScale,
                dFrame.size.height * previewResizeScale
            };
            
            itemView.frame = itemFrame;
            index++;
            
            NSArray *dLabels = [textGroupDictionary objectForKey:@"Labels"];
            if([item isKindOfClass:[PTextGroupView class]]) {
                PTextGroupView *textGroupView = (PTextGroupView *)item;
                textGroupView.transform = CGAffineTransformIdentity;
                
                // TextGroupView 에 rotation 이 적용되어있는 경우가 있기 때문에 transform = CGAffineTransformIdentity; 후에 itemFrame 을 다시 계산
                itemFrame = (CGRect) {
                    dFrame.origin.x * previewResizeScale,
                    dFrame.origin.y * previewResizeScale,
                    dFrame.size.width * previewResizeScale,
                    dFrame.size.height * previewResizeScale
                };
                
                textGroupView.frame = itemFrame;
                
                NSInteger labelIndex = 0;
                for(id subItem in [textGroupView subviews]) {
                    
                    
                    if([subItem isKindOfClass:[PUILabel class]]) {
                        
                        PUILabel *label = (PUILabel *)subItem;
                        NSDictionary *labelDictionary = [dLabels objectAtIndex:labelIndex];
                        CGRect dLabelFrame = CGRectFromString([labelDictionary objectForKey:@"Frame"]);
                        CGRect labelFrame = (CGRect) {
                            dLabelFrame.origin.x * previewResizeScale,
                            dLabelFrame.origin.y * previewResizeScale,
                            dLabelFrame.size.width * previewResizeScale,
                            dLabelFrame.size.height * previewResizeScale
                        };
                        
                        label.frame = labelFrame;
                        //label.backgroundColor = [UIColor redColor];
                        
                        label.originFont = [UIFont fontWithName:[labelDictionary objectForKey:@"OriginFontName"] size:[[labelDictionary objectForKey:@"OriginFontSize"] floatValue]];
                        label.font = [UIFont fontWithName:[labelDictionary objectForKey:@"FontName"] size:[[labelDictionary objectForKey:@"FontSize"] floatValue] * previewResizeScale];
                        
                        label.textColor = [Utils UIColorFromRGBString:[labelDictionary objectForKey:@"TextColor"]];
                        label.textAlignment = [[labelDictionary objectForKey:@"Alignment"] integerValue];
                        
                        label.originText = [labelDictionary objectForKey:@"OriginText"];
                        label.text = [labelDictionary objectForKey:@"Text"];
                        label.paragraphText = label.text;
                        
                        
                        labelIndex++;
                    } else {
                        
                    }
                }
                
                textGroupView.transform = CGAffineTransformMakeRotation(textGroupView.angle);
                textGroupView.transform = CGAffineTransformScale(textGroupView.transform, textGroupView.scale, textGroupView.scale);
            }
        }
    }
    
    
    index = 0;
    if(photoViewDictionaryArray.count == sortedPhotoViews.count) {
        for (id item in sortedPhotoViews) {
            UIView *itemView = (UIView *)item;
            
            NSDictionary *photoViewDictionary = [photoViewDictionaryArray objectAtIndex:index];
            NSInteger dTag = [[photoViewDictionary objectForKey:@"Tag"] integerValue];
            if(dTag != itemView.tag) {
                NSLog(@"tag match error");
            }
            CGRect dFrame = CGRectFromString([photoViewDictionary objectForKey:@"Frame"]);
            CGRect itemFrame = (CGRect) {
                dFrame.origin.x * previewResizeScale,
                dFrame.origin.y * previewResizeScale,
                dFrame.size.width * previewResizeScale,
                dFrame.size.height * previewResizeScale
            };
            
            itemView.frame = itemFrame;
            index++;
            
            if([item isKindOfClass:[PPhotoView class]]) {
                PPhotoView *photoView = (PPhotoView *)item;
                if([photoViewDictionary objectForKey:@"PhotoBrightness"]) {
                    CGFloat photoBrightness = [[photoViewDictionary objectForKey:@"PhotoBrightness"] floatValue];
                    photoView.photoBrightness = photoBrightness;
                } else {
                    photoView.photoBrightness = -0.05;
                }
                
                CGFloat photoScale = [[photoViewDictionary objectForKey:@"PhotoScale"] floatValue];
                CGPoint photoTranslation = CGPointFromString([photoViewDictionary objectForKey:@"PhotoTranslation"]);
                
                CGPoint coverntTranslation = (CGPoint) {
                    photoTranslation.x * previewResizeScale,
                    photoTranslation.y * previewResizeScale
                };
                
                photoView.photoScale = photoScale;
                photoView.photoTranslation = coverntTranslation;
            }
        }
    }

    index = 0;
    if(flatViewDictionaryArray.count == sortedFlatViews.count) {
        for (id item in sortedFlatViews) {
            UIView *itemView = (UIView *)item;
            
            NSDictionary *flatViewDictionary = [flatViewDictionaryArray objectAtIndex:index];
            NSInteger dTag = [[flatViewDictionary objectForKey:@"Tag"] integerValue];
            if(dTag != itemView.tag) {
                NSLog(@"tag match error");
            }
            
            
            PFlatView *flatView = (PFlatView *)item;
            
            NSDictionary *properties = [flatViewDictionary objectForKey:@"Properties"];
            NSLog(@"properties : %@", properties);
            
            if([properties objectForKey:@"BackgroundColor"]) {
                flatView.backgroundColor = [Utils UIColorFromRGBString:[properties objectForKey:@"BackgroundColor"]];
            }
            if([properties objectForKey:@"ViewRotation"]) {
                NSNumber *viewRotation = [properties objectForKey:@"ViewRotation"];
                flatView.viewRotation = viewRotation;
            }
            if([properties objectForKey:@"ViewCornerRadius"]) {
                NSNumber *viewCornerRadius = [properties objectForKey:@"ViewCornerRadius"];
                flatView.viewCornerRadius = viewCornerRadius;
            }
            if([properties objectForKey:@"ViewBorderWidth"]) {
                NSNumber *viewBorderWidth = [properties objectForKey:@"ViewBorderWidth"];
                flatView.viewBorderWidth = viewBorderWidth;
            }
            if([properties objectForKey:@"ViewBorderColor"]) {
                UIColor *viewBorderColor = [Utils UIColorFromRGBString:[properties objectForKey:@"ViewBorderColor"]];
                flatView.viewBorderColor = viewBorderColor;
            }
            
            
            if([item isKindOfClass:[PCubeView class]]) {
                PCubeView *cubeView = (PCubeView *)item;
                
                if([properties objectForKey:@"ShapeColor"]) {
                    UIColor *shapeColor = [Utils UIColorFromRGBString:[properties objectForKey:@"ShapeColor"]];
                    cubeView.shapeColor = shapeColor;
                }
            }
            
            CGAffineTransform flatViewTransform = flatView.transform;
            flatView.transform = CGAffineTransformIdentity;
            CGRect dFrame = CGRectFromString([flatViewDictionary objectForKey:@"Frame"]);
            
            // FlatView 에 rotation 이 적용되어있는 경우가 있기 때문에 transform = CGAffineTransformIdentity; 후에 itemFrame 을 다시 계산
            CGRect itemFrame = (CGRect) {
                dFrame.origin.x * previewResizeScale,
                dFrame.origin.y * previewResizeScale,
                dFrame.size.width * previewResizeScale,
                dFrame.size.height * previewResizeScale
            };
            
            flatView.frame = itemFrame;
            
            flatView.transform = flatViewTransform;
            
            [flatView updateProperties];
            [flatView resizeWithScale:previewResizeScale];
            
            index++;
        }
    }
}

- (NSDictionary *)templateTextDictionary
{
    // textGroup 내에 label 에 특성에 따라 텍스트 딕셔너리 생성
    /*
     title
     subtitle
     date
     description
     footer
     photoTitles
     photoDescriptions
     
     */
    
    
    NSMutableDictionary *textDictionary = (_templateTextDictionary) ? _templateTextDictionary : [NSMutableDictionary dictionary];
    
    NSMutableArray *photoTitles = [NSMutableArray array];
    NSMutableArray *photoDescriptions = [NSMutableArray array];
    
    NSArray *templateSubviews = [self.loadedNibView subviews];
    NSMutableArray *targetItems = [NSMutableArray array];
    for(id item in templateSubviews) {
        if([item isKindOfClass:[PTextGroupView class]]) {
            [targetItems addObject:item];
        }
    }
    
    NSSortDescriptor *tagDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tag" ascending:YES];
    NSArray *sortedTargetItem = [targetItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:tagDescriptor]];
    
    for (id item in sortedTargetItem) {
        
        if([item isKindOfClass:[PTextGroupView class]]) {
            PTextGroupView *textGroupView = (PTextGroupView *)item;
            
            for(id subItem in [textGroupView subviews]) {
                if([subItem isKindOfClass:[PUILabel class]]) {
                    
                    PUILabel *label = (PUILabel *)subItem;
                    if(label.textType) {
                        if([label.textType isEqualToString:@"photoTitle"]) {
                            if(label.editedText) {
                                label.editedText = NO;
                                [photoTitles addObject:[NSString stringWithString:label.text]];
                            }
                            
                        } else if([label.textType isEqualToString:@"photoDescription"]) {
                            if(label.editedText) {
                                label.editedText = NO;
                                [photoDescriptions addObject:[NSString stringWithString:label.text]];
                            }
                        } else {
                            if(label.editedText) {
                                label.editedText = NO;
                                [textDictionary setObject:[NSString stringWithString:label.text] forKey:label.textType];
                            }
                        }
                    }
                    
                    
                }
            }
        }
    }
    
    if(photoTitles.count > 0) {
        [textDictionary setObject:[NSArray arrayWithArray:photoTitles] forKey:@"photoTitles"];
    }
    
    if(photoDescriptions.count > 0) {
        [textDictionary setObject:[NSArray arrayWithArray:photoDescriptions] forKey:@"photoDescriptions"];
    }
    
    return [NSDictionary dictionaryWithDictionary:textDictionary];
}

- (void)setTemplateTextWithDictionary:(NSDictionary *)textDictionary
{
    //projectResource 에 저장했던 text dictionary 를 템플릿에 있는 레이블들에 적용
    
    _templateTextDictionary = [NSMutableDictionary dictionaryWithDictionary:textDictionary];
    
    //NSLog(@"textDictionary : %@" , _templateDictionary);
    
    /*
    NSString *titleString       = [textDictionary objectForKey:@"title"];
    NSString *subtitleString    = [textDictionary objectForKey:@"subtitle"];
    NSString *dateString        = [textDictionary objectForKey:@"date"];
    NSString *descriptionString = [textDictionary objectForKey:@"description"];
    NSString *footerString      = [textDictionary objectForKey:@"footer"];
    */
    NSArray *photoTitles = [NSArray array];
    if([textDictionary objectForKey:@"photoTitles"]) {
        photoTitles = [textDictionary objectForKey:@"photoTitles"];
    }
    
    NSArray *photoDescriptions = [NSArray array];
    if([textDictionary objectForKey:@"photoDescriptions"]) {
        photoDescriptions = [textDictionary objectForKey:@"photoDescriptions"];
    }
    
    NSInteger photoTitleIndex = 0;
    NSInteger photoDescriptionIndex = 0;
    
    NSArray *templateSubviews = [self.loadedNibView subviews];
    NSMutableArray *targetItems = [NSMutableArray array];
    for(id item in templateSubviews) {
        if([item isKindOfClass:[PTextGroupView class]]) {
            [targetItems addObject:item];
        }
    }
    
    NSSortDescriptor *tagDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tag" ascending:YES];
    NSArray *sortedTargetItem = [targetItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:tagDescriptor]];
    
    for (id item in sortedTargetItem) {
        
        PTextGroupView *textGroupView = (PTextGroupView *)item;
        
        for(id subItem in [textGroupView subviews]) {
            if([subItem isKindOfClass:[PUILabel class]]) {
                
                PUILabel *label = (PUILabel *)subItem;
                if(label.textType) {
                    if([label.textType isEqualToString:@"photoTitle"]) {
                        if(photoTitleIndex < photoTitles.count) {
                            label.paragraphText = photoTitles[photoTitleIndex];
                            photoTitleIndex++;
                        }
                        
                        
                    } else if([label.textType isEqualToString:@"photoDescription"]) {
                        if(photoDescriptionIndex < photoDescriptions.count) {
                            label.paragraphText = photoDescriptions[photoDescriptionIndex];
                            photoDescriptionIndex++;
                        }
                        
                        
                    } else {
                        if([textDictionary objectForKey:label.textType]) {
                            label.paragraphText = [textDictionary objectForKey:label.textType];
                        }
                    }
                }
                
                
            }
        }
    }
}
- (void)setTemplateTextWithFooterString:(NSString *)footerString
{
    NSLog(@"setTemplateTextWithFooterString : %@", footerString);
    NSMutableDictionary *textDictionary = (_templateTextDictionary) ? _templateTextDictionary : [NSMutableDictionary dictionary];
    
    [textDictionary setObject:[NSString stringWithString:footerString] forKey:@"footer"];
    
    NSArray *templateSubviews = [self.loadedNibView subviews];
    NSMutableArray *targetItems = [NSMutableArray array];
    for(id item in templateSubviews) {
        if([item isKindOfClass:[PTextGroupView class]]) {
            [targetItems addObject:item];
        }
    }
    
    for (id item in targetItems) {
        
        if([item isKindOfClass:[PTextGroupView class]]) {
            PTextGroupView *textGroupView = (PTextGroupView *)item;
            
            for(id subItem in [textGroupView subviews]) {
                if([subItem isKindOfClass:[PUILabel class]]) {
                    
                    PUILabel *label = (PUILabel *)subItem;
                    
                    if(label.textType) {
                        if([label.textType isEqualToString:@"footer"]) {
                            label.paragraphText = [textDictionary objectForKey:@"footer"];
                        }
                    }
                    
                    
                }
            }
        }
    }

}

- (void)setPhotosWithPhotoArray:(NSArray *)photoArray
{
    [self setPhotosWithPhotoArray:photoArray useThumbnail:NO];
}
- (void)setPhotosWithPhotoArray:(NSArray *)photoArray useThumbnail:(BOOL)useThumnail
{
    if(photoArray.count > 0) {
        
        NSInteger index = 0;
        for(PPhotoAsset *photoAsset in photoArray) {
            if(index < self.photoViewArray.count) {
                PPhotoView *photoView = self.photoViewArray[index];
                
                if(useThumnail) {
                    [photoView setPhotoImage:photoAsset.thumbnailImage];
                } else {
                    [photoView setPhotoImage:photoAsset.photoImage];
                }
            }
            
            index ++;
        }
        
    }
}

- (void)updatePhotoAtIndex:(NSInteger)photoIndex
{
    
}

- (id)editableItemAtContainsPoint:(CGPoint)point fromView:(UIView *)fromView
{
    
    CGPoint convertPoint = [loadedNibView convertPoint:point fromView:fromView];
    
    NSArray *reverseSubviews = [[[loadedNibView subviews] reverseObjectEnumerator] allObjects];
    for(id item in reverseSubviews)
    {
        UIView *itemView = (UIView *)item;
        CGRect itemFrame = itemView.frame;
        if(CGRectGetWidth(itemFrame) < 50) {
            itemFrame = CGRectMake(itemFrame.origin.x - 25, itemFrame.origin.y, itemFrame.size.width + 50, itemFrame.size.height);
        }
        if(CGRectGetHeight(itemFrame) < 50) {
            itemFrame = CGRectMake(itemFrame.origin.x, itemFrame.origin.y - 25, itemFrame.size.width, itemFrame.size.height + 50);
        }
        
        if([item isKindOfClass:[PTextGroupView class]]) {
            if(CGRectContainsPoint(itemFrame, convertPoint)) {
                return item;
            }
        } else if([item isKindOfClass:[PPhotoView class]]) {
            if(CGRectContainsPoint(itemFrame, convertPoint)) {
                return item;
            }
        }
    }
    return nil;
}

- (id)draggableItemAtContainsPoint:(CGPoint)point fromView:(UIView *)fromView
{
    CGPoint convertPoint = [loadedNibView convertPoint:point fromView:fromView];
    
    NSArray *reverseSubviews = [[[loadedNibView subviews] reverseObjectEnumerator] allObjects];
    for(id item in reverseSubviews)
    {
        UIView *itemView = (UIView *)item;
        CGRect itemFrame = itemView.frame;
        if(CGRectGetWidth(itemFrame) < 50) {
            itemFrame = CGRectMake(itemFrame.origin.x - 25, itemFrame.origin.y, itemFrame.size.width + 50, itemFrame.size.height);
        }
        if(CGRectGetHeight(itemFrame) < 50) {
            itemFrame = CGRectMake(itemFrame.origin.x, itemFrame.origin.y - 25, itemFrame.size.width, itemFrame.size.height + 50);
        }
        
        if([item isKindOfClass:[PTextGroupView class]]) {
            PTextGroupView *textGroupView = (PTextGroupView *)item;
            if(!textGroupView.fixedPosition) {
                if(CGRectContainsPoint(itemFrame, convertPoint)) {
                    return item;
                }
            }
        } else if([item isKindOfClass:[PFlatView class]]) {
            PFlatView *flatView = (PFlatView *)item;
            if(!flatView.fixedPosition) {
                if(CGRectContainsPoint(itemFrame, convertPoint)) {
                    return item;
                }
            }
        }
    }
    return nil;
}




- (void)setupNibView
{
    //NSLog(@"previewResizeScale : %f", previewResizeScale);
    self.frame = CGRectMake(0, 0, originalTemplateFrame.size.width * previewResizeScale, originalTemplateFrame.size.height * previewResizeScale);
    
    
    self.backgroundView = (UIView *)[loadedNibView subviews][0];
    self.originalBackgroundColor = self.backgroundView.backgroundColor;
    
    CGSize viewSize = self.frame.size;
    CGSize nibViewSize = loadedNibView.frame.size;
    
    nibViewResizeRatio = viewSize.width / nibViewSize.width;
    if(viewSize.height < nibViewSize.height * nibViewResizeRatio)
    {
        nibViewResizeRatio = viewSize.height / nibViewSize.height;
    }
    
    CGFloat displayScale = [[UIScreen mainScreen] scale];
    CGFloat minimumPixel = 1 / displayScale;
    
    NSMutableArray *textGroups = [[NSMutableArray alloc] init];
    NSMutableArray *photoViews = [[NSMutableArray alloc] init];
    NSMutableArray *flatViews = [[NSMutableArray alloc] init];
    NSMutableArray *imageViews = [[NSMutableArray alloc] init];
    for(id item in [loadedNibView subviews])
    {
        if([item isKindOfClass:[PTextGroupView class]])
        {
            PTextGroupView *textGroupView = (PTextGroupView *)item;
            textGroupView.transform = CGAffineTransformIdentity;
            
            textGroupView.frame = (CGRect) {
                textGroupView.frame.origin.x * nibViewResizeRatio,
                textGroupView.frame.origin.y * nibViewResizeRatio,
                textGroupView.frame.size.width * nibViewResizeRatio,
                textGroupView.frame.size.height * nibViewResizeRatio
            };
            [textGroupView resizeWithScale:nibViewResizeRatio];
            
            textGroupView.transform = CGAffineTransformMakeRotation(textGroupView.angle);
            textGroupView.transform = CGAffineTransformScale(textGroupView.transform, textGroupView.scale, textGroupView.scale);
            [textGroups addObject:textGroupView];
        }
        else if([item isKindOfClass:[PPhotoView class]])
        {
            PPhotoView *photoView = (PPhotoView *)item;
            photoView.transform = CGAffineTransformIdentity;
            
            photoView.frame = (CGRect) {
                photoView.frame.origin.x * nibViewResizeRatio,
                photoView.frame.origin.y * nibViewResizeRatio,
                photoView.frame.size.width * nibViewResizeRatio,
                photoView.frame.size.height * nibViewResizeRatio
            };
            [photoView resizeWithScale:nibViewResizeRatio];
            photoView.transform = CGAffineTransformMakeRotation(photoView.angle);
            
            [photoViews addObject:photoView];
        }
        else if([item isKindOfClass:[PFlatView class]])
        {
            PFlatView *flatView = (PFlatView *)item;
            flatView.transform = CGAffineTransformIdentity;
            
            // 1 pixel 라인인 경우 리사이즈된 크기에서 보이지 않는 것 때문에 최소 픽셀을 지정해줌
            flatView.frame = (CGRect) {
                flatView.frame.origin.x * nibViewResizeRatio,
                flatView.frame.origin.y * nibViewResizeRatio,
                MAX(minimumPixel, flatView.frame.size.width * nibViewResizeRatio),
                MAX(minimumPixel, flatView.frame.size.height * nibViewResizeRatio)
            };
            [flatView resizeWithScale:nibViewResizeRatio];
            flatView.transform = CGAffineTransformMakeRotation(flatView.angle);
            
            [flatViews addObject:flatView];
        }
        else if([item isKindOfClass:[PImageView class]])
        {
            PImageView *imageView = (PImageView *)item;
            imageView.frame = (CGRect) {
                imageView.frame.origin.x * nibViewResizeRatio,
                imageView.frame.origin.y * nibViewResizeRatio,
                imageView.frame.size.width * nibViewResizeRatio,
                imageView.frame.size.height * nibViewResizeRatio
            };
            
            [imageViews addObject:imageView];
        }
        else if([item isKindOfClass:[PCoverImageView class]])
        {
            PCoverImageView *imageView = (PCoverImageView *)item;
            imageView.frame = (CGRect) {
                imageView.frame.origin.x * nibViewResizeRatio,
                imageView.frame.origin.y * nibViewResizeRatio,
                imageView.frame.size.width * nibViewResizeRatio,
                imageView.frame.size.height * nibViewResizeRatio
            };
            
            [imageViews addObject:imageView];
        } else if([item isKindOfClass:[UIImageView class]]) {
            // 레이아웃 참고용 이미지들 메모리에서 해제 하기 위해 넣은 코드임
            UIImageView *imageView = (UIImageView *)item;
            if(imageView.hidden) {
                imageView.image = nil;
            } else {
                
                UIView *otherView = (UIView *)item;
                otherView.frame = (CGRect) {
                    otherView.frame.origin.x * nibViewResizeRatio,
                    otherView.frame.origin.y * nibViewResizeRatio,
                    otherView.frame.size.width * nibViewResizeRatio,
                    otherView.frame.size.height * nibViewResizeRatio
                };
            }
        }
        else
        {
            //((UIView *)item).hidden = YES;
            UIView *otherView = (UIView *)item;
            otherView.frame = (CGRect) {
                otherView.frame.origin.x * nibViewResizeRatio,
                otherView.frame.origin.y * nibViewResizeRatio,
                otherView.frame.size.width * nibViewResizeRatio,
                otherView.frame.size.height * nibViewResizeRatio
            };
            //NSLog(@"?????? undefined item : %@", item);
        }
    }
    
    loadedNibView.frame = CGRectMake(0, 0, nibViewSize.width * nibViewResizeRatio, nibViewSize.height * nibViewResizeRatio);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, loadedNibView.frame.size.width, loadedNibView.frame.size.height);
    
    [self addSubview:loadedNibView];
    
    self.textGroupViewArray = [NSArray arrayWithArray:textGroups];
    self.photoViewArray = [NSArray arrayWithArray:photoViews];
    self.flatViewArray = [NSArray arrayWithArray:flatViews];
    self.imageViewArray = [NSArray arrayWithArray:imageViews];
    
    [self setupTextItems];
    [self setupImageItems];
    [self sortAllItems];
    
    self.allItemArray = [[[textGroups arrayByAddingObjectsFromArray:photoViews] arrayByAddingObjectsFromArray:flatViews] arrayByAddingObjectsFromArray:imageViews];
}



- (void)setupTextItems
{
    
    for(PTextGroupView *textGroupView in self.textGroupViewArray) {

        
        for(id subItem in [textGroupView subviews]) {
            if([subItem isKindOfClass:[PUILabel class]]) {
                
                PUILabel *label = (PUILabel *)subItem;
                
                if([label.textType isEqualToString:@"date"]) {
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
                    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
                    
                    NSDate *date = [NSDate date];
                    
                    NSString *formattedDateString = [dateFormatter stringFromDate:date];
                    
                    label.paragraphText = formattedDateString;
                    
                    //NSLog(@"formattedDateString: %@", formattedDateString);
                    
                    
                } else if([label.textType isEqualToString:@"MMMM"]) {
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"MMMM"];
                    
                    NSDate *date = [NSDate date];
                    
                    NSString *formattedDateString = [dateFormatter stringFromDate:date];
                    
                    label.paragraphText = formattedDateString;
                    
                    
                } else if([label.textType isEqualToString:@"MM"]) {
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"MM"];
                    
                    NSDate *date = [NSDate date];
                    
                    NSString *formattedDateString = [dateFormatter stringFromDate:date];
                    
                    label.paragraphText = formattedDateString;
                    
                    
                } else if([label.textType isEqualToString:@"dd"]) {
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"dd"];
                    
                    NSDate *date = [NSDate date];
                    
                    NSString *formattedDateString = [dateFormatter stringFromDate:date];
                    
                    label.paragraphText = formattedDateString;
                    
                    
                } else if([label.textType isEqualToString:@"longstyle"]) {
                    //July 23, 2015
                    
                    NSString *localizedDateTime = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
                    
                    
                    label.paragraphText = localizedDateTime;
                    
                    
                } else if([label.textType isEqualToString:@"timeshort"]) {
                    //11:00 PM
                    
                    NSString *localizedDateTime = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
                    
                    
                    label.paragraphText = localizedDateTime;
                    
                    
                } else if([label.textType isEqualToString:@"datetodate"]) {
                    //July 23 - 31, 2015
                    
                    
                    NSDateFormatter *todayFormatter = [[NSDateFormatter alloc] init];
                    [todayFormatter setDateFormat:@"d"];
                    NSDate *date = [NSDate date];
                    NSDate *toDate = [NSDate date];
                    
                    if([[todayFormatter stringFromDate:date] integerValue] < 15) {
                        toDate = [NSDate dateWithTimeIntervalSinceNow:3 * (24 * 60 * 60)];
                    }
                    else {
                        date = [NSDate dateWithTimeIntervalSinceNow:-(3 * (24 * 60 * 60))];
                    }
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    NSDateFormatter *toDateFormatter = [[NSDateFormatter alloc] init];
                    
                    NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
                    if([language isEqualToString:@"ko"]) {
                        [dateFormatter setDateFormat:@"yyyy. M. d"];
                        [toDateFormatter setDateFormat:@"d"];
                    }
                    else if([language isEqualToString:@"ja"]) {
                        [dateFormatter setDateFormat:@"yyyy. M. d"];
                        [toDateFormatter setDateFormat:@"d"];
                    }
                    else if([language isEqualToString:@"zh"]) {
                        [dateFormatter setDateFormat:@"yyyy. M. d"];
                        [toDateFormatter setDateFormat:@"d"];
                    }
                    else {
                        [dateFormatter setDateFormat:@"MMM d"];
                        [toDateFormatter setDateFormat:@"d, yyyy"];
                    }
                    
                    NSString *formattedDateString = [NSString stringWithFormat:@"%@ - %@", [dateFormatter stringFromDate:date], [toDateFormatter stringFromDate:toDate]];
                    
                    label.paragraphText = formattedDateString;
                    
                    
                } else if([label.textType isEqualToString:@"location"]) {
                    if(self.locationString) {
                        label.paragraphText = [self.locationString uppercaseString];
                    }
                }
            }
        }

    }
    
}


- (void)setupImageItems
{
}

- (void)sortAllItems
{
    for(PTextGroupView *item in self.textGroupViewArray)
    {
        [loadedNibView bringSubviewToFront:item];
    }
}



@end
