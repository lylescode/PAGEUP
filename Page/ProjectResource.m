//
//  ProjectResource.m
//  Page
//
//  Created by CMR on 11/20/14.
//  Copyright (c) 2014 Page. All rights reserved.
//

#import "ProjectResource.h"
#import "LEColorPicker.h"
#import <CoreLocation/CoreLocation.h>
@interface ProjectResource ()
{
    CGSize _pdfResultSize;
}

@end

@implementation ProjectResource


- (id)init
{
    self = [super init];
    if (self) {
        
        ResultSize = CGSizeMake(4096, 4096);
        
        self.photoArray = [NSMutableArray array];
        self.photoAssetDictionaryArray = [NSMutableArray array];
        self.templateDictionary = nil;
        
        _updatedPhotos = NO;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"ProjectResource dealloc");
    self.projectType = nil;
    self.titleString = nil;
    self.locationString = nil;
    
    self.project = nil;
    self.templateDictionary = nil;
    self.templateTextDictionary = nil;
    self.projectDictionary = nil;
    
    self.photoArray = nil;
    self.photoAssetDictionaryArray = nil;
    
    self.photoColorSchemeArray = nil;
}
- (void)prepareForSaveProject
{
    for(PPhotoAsset *asset in self.photoArray) {
        [asset prepareForSaveProject];
    }

}
- (void)setupPhotoAssetsWithPhotoAssetDictionaryArray:(NSArray *)dictionaryArray
{
    NSLog(@"setupPhotoAssetsWithPhotoAssetDictionaryArray");
    for(NSDictionary *photoAssetDictionary in dictionaryArray) {
        PPhotoAsset *photoAsset = [[PPhotoAsset alloc] initWithSavedDictionary:photoAssetDictionary completion:nil];
        [self.photoArray addObject:photoAsset];
    }
}
- (BOOL)shouldAddPhotoAsset
{
    return self.photoArray.count < ProjectResourceMaxPhotoCount;
}

- (BOOL)addedPhotoAsset:(PHAsset *)asset
{
    if(self.photoArray.count == 0) {
        return NO;
    }
    
    //NSLog(@"asset : %@" , asset.localIdentifier);
    
    /*
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        NSString *requestDataUTI = dataUTI;
        NSLog(@"requestDataUTI : %@", requestDataUTI);
        
    }];
    */
    /*
    for(id photo in self.photoArray) {
        if([photo isKindOfClass:[PHAsset class]]) {
            PHAsset *pAsset = (PHAsset *)photo;
            if([pAsset.localIdentifier isEqualToString:asset.localIdentifier]) {
                return YES;
            }
        } else if([photo isKindOfClass:[PPhotoAsset class]]) {
            PPhotoAsset *photoAsset = (PPhotoAsset *)photo;
            if([photoAsset.localIdentifier isEqualToString:asset.localIdentifier]) {
                return YES;
            }
        }
     }
     */
    
    
    for(PPhotoAsset *photoAsset in self.photoArray) {
        if([photoAsset.localIdentifier isEqualToString:asset.localIdentifier]) {
            return YES;
        }
    }
    return NO;
}

- (void)updatePhotoAssetDictionary
{
    self.photoAssetDictionaryArray = [NSMutableArray array];
    for(PPhotoAsset *photoAsset in self.photoArray) {
        [self.photoAssetDictionaryArray addObject:[photoAsset photoAssetDictionary]];
    }
    //NSLog(@"photoAssetDictionaryArray : %@", self.photoAssetDictionaryArray);
}

- (NSInteger)indexOfPhotoAsset:(PHAsset *)asset
{
    NSInteger index = 0;
    for(PPhotoAsset *photoAsset in self.photoArray) {
        if([photoAsset.localIdentifier isEqualToString:asset.localIdentifier]) {
            return index;
        }
        index++;
    }
    return index;
}

- (void)addPhotoAsset:(PHAsset *)asset thumbnailImage:(UIImage *)thumbnailImage completion:(void(^)(void))callback
{
    if([self shouldAddPhotoAsset]) {
        if(self.photoArray.count == 0) {
            if(asset.location) {
                CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                [geocoder reverseGeocodeLocation:asset.location completionHandler:^(NSArray *placemarks, NSError *error) {
                    if (error == nil && [placemarks count] > 0) {
                        CLPlacemark *placemark = [placemarks lastObject];
                        
                        NSString *locationString = [placemark.administrativeArea copy];
                        NSLog(@"addPhotoAsset asset.location : %@", locationString);
                        self.locationString = locationString;
                    } else {
                        NSLog(@"%@", error.debugDescription);
                    }
                }];
            }
        }
        
        PPhotoAsset *photoAsset = [[PPhotoAsset alloc] initWithAsset:asset thumbnailImage:thumbnailImage
                                                          completion:callback];
        [self.photoArray addObject:photoAsset];
    }
    _updatedPhotos = YES;
    self.photoColorSchemeArray = nil;
}
- (void)replaceAssetAtIndex:(NSInteger)assetIndex withAsset:(PHAsset *)asset thumbnailImage:(UIImage *)thumbnailImage completion:(void(^)(void))callback
{
    if(assetIndex < self.photoArray.count) {
        PPhotoAsset *oldPhotoAsset = [self.photoArray objectAtIndex:assetIndex];
        [oldPhotoAsset removeCachedImageFile];
        
        PPhotoAsset *photoAsset = [[PPhotoAsset alloc] initWithAsset:asset thumbnailImage:thumbnailImage
                                                          completion:callback];
        [self.photoArray replaceObjectAtIndex:assetIndex withObject:photoAsset];
    } else {
        // 원래 인덱스에 사진이 없었던 경우 여기서 처리함 (템플릿을 고르고 다시 사진을 고를때 사진수가 변경되는 경우 이렇게 될 수 있음)
        PPhotoAsset *photoAsset = [[PPhotoAsset alloc] initWithAsset:asset thumbnailImage:thumbnailImage
                                                          completion:callback];
        
        [self.photoArray addObject:photoAsset];
    }
    _updatedPhotos = YES;
    self.photoColorSchemeArray = nil;
    
}

- (void)removePhotoAsset:(PHAsset *)asset
{
    NSInteger photoAssetIndex = 0;
    for(PPhotoAsset *photoAsset in self.photoArray) {
        if([photoAsset.localIdentifier isEqualToString:asset.localIdentifier]) {
            [photoAsset removeCachedImageFile];
            [self.photoArray removeObject:photoAsset];
            
            break;
        }
        photoAssetIndex++;
    }
    _updatedPhotos = YES;
    self.photoColorSchemeArray = nil;
}
- (void)removePhotoAssetWithIndex:(NSInteger)assetIndex
{
    PPhotoAsset *oldPhotoAsset = [self.photoArray objectAtIndex:assetIndex];
    [oldPhotoAsset removeCachedImageFile];
    [self.photoArray removeObjectAtIndex:assetIndex];
    _updatedPhotos = YES;
    self.photoColorSchemeArray = nil;
}

- (void)movePhotoAssetAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    PPhotoAsset *currentPhotoAsset = [self.photoArray objectAtIndex:fromIndex];
    [self.photoArray removeObjectAtIndex:fromIndex];
    [self.photoArray insertObject:currentPhotoAsset atIndex:toIndex];
    _updatedPhotos = YES;
    self.photoColorSchemeArray = nil;
}
- (void)swapPhotoAssetsAtIndex:(NSInteger)aIndex bIndex:(NSInteger)bIndex
{
    [self.photoArray exchangeObjectAtIndex:aIndex withObjectAtIndex:bIndex];
    
}

- (void)removeAllPhotoAssetCachedImageFiles
{
    NSLog(@"removeAllPhotoAssetCachedImageFiles");
    for(PPhotoAsset *photoAsset in self.photoArray) {
        [photoAsset removeCachedImageFile];
    }
}

- (NSArray *)photoColorSchemes
{
    if(self.photoColorSchemeArray) {
        return self.photoColorSchemeArray;
    }
    else {
        
        LEColorPicker *colorPicker = [[LEColorPicker alloc] init];
        
        NSMutableArray *colorSchemes = [NSMutableArray array];
        for(PPhotoAsset *photoAsset in self.photoArray) {
            UIImage *photoImage = photoAsset.thumbnailImage;
            if(photoAsset.thumbnailImage) {
                photoImage = photoAsset.photoImage;
            }
            
            LEColorScheme *colorScheme = [colorPicker colorSchemeFromImage:photoImage];
            NSDictionary *colorSchemeDictionary = @{
                                                    @"backgroundColor": [UIColor colorWithCGColor:colorScheme.backgroundColor.CGColor],
                                                    @"primaryTextColor": [UIColor colorWithCGColor:colorScheme.primaryTextColor.CGColor],
                                                    @"secondaryTextColor": [UIColor colorWithCGColor:colorScheme.secondaryTextColor.CGColor]
                                                    };
            [colorSchemes addObject:colorSchemeDictionary];
        }
        
        self.photoColorSchemeArray = [NSArray arrayWithArray:colorSchemes];
    }
    
    return self.photoColorSchemeArray;
    
}

- (UIImage *)resultImage
{
    PTemplate *templateView = [[PTemplate alloc] initWithFrame:CGRectMake(0, 0, ResultSize.width, ResultSize.height) templateDictionary:self.templateDictionary];
    [templateView setupTemplate];
    templateView.userInteractionEnabled = NO;
    [templateView setPhotosWithPhotoArray:self.photoArray];
    [templateView setupProjectDictionary:self.projectDictionary];
    [templateView pixelPerfect];
    UIGraphicsBeginImageContext(templateView.frame.size);
    [templateView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

- (NSURL *)resultPDF
{
    UIView *templateWrapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ResultSize.width, ResultSize.height)];
    
    
    PTemplate *templateView = [[PTemplate alloc] initWithFrame:CGRectMake(0, 0, ResultSize.width, ResultSize.height) templateDictionary:self.templateDictionary];
    [templateView setupTemplate];
    templateView.userInteractionEnabled = NO;
    [templateView setPhotosWithPhotoArray:self.photoArray];
    [templateView setupProjectDictionary:self.projectDictionary];
    
    [templateView pixelPerfect];
    templateWrapView.frame = templateView.frame;
    [templateWrapView addSubview:templateView];
    
    _pdfResultSize = templateView.frame.size;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyMMdd_HHmm"];
    
    NSDate *date = [NSDate date];
    
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    
    
    NSString *PDFFilename = [NSString stringWithFormat:@"PAGEUP_%@.pdf", formattedDateString];
    NSString *pdfPath = [NSTemporaryDirectory() stringByAppendingPathComponent:PDFFilename];
    NSURL *pdfURL = [[NSURL alloc] initFileURLWithPath:pdfPath];
    
    //NSLog(@"pdfPath : %@", pdfPath);
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError *error = nil;
    BOOL isDir;
    if([fileManager fileExistsAtPath:pdfPath isDirectory:&isDir] == YES) {
        //NSLog(@"이미 있음");
        BOOL removeSuccess = [fileManager removeItemAtPath:pdfPath error:&error];
        if(removeSuccess) {
            //NSLog(@"기존 파일 삭제");
        }
    }
    
    //NSLog(@"_pdfResultSize : %@", NSStringFromCGSize(_pdfResultSize));
    
    UIGraphicsBeginPDFContextToFile(pdfPath, CGRectZero, nil);
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, _pdfResultSize.width, _pdfResultSize.height), nil);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSArray *targetViews = [templateView.loadedNibView subviews];
    UIView *backgroundView = (UIView *)[targetViews firstObject];
    
    UIView *targetSuperView = templateView.loadedNibView;
    targetSuperView.layer.anchorPoint = CGPointMake(0,0);
    targetSuperView.layer.position = CGPointMake(0, 0);
    
    [self pdfDrawRect:backgroundView.frame withColor:backgroundView.backgroundColor opacity:1];
    
    for(int i = 1 ; i < targetViews.count ; i++) {
        UIView *targetView = (UIView *)[targetViews objectAtIndex:i];
        CGRect targetFrame = targetView.frame;
        
        if(targetView.hidden == NO) {
            if([targetView isKindOfClass:[PTextGroupView class]]) {
                PTextGroupView *textGroupView = (PTextGroupView *)targetView;
                
                CGFloat rotation = 0;
                CGAffineTransform t;
                CGAffineTransform r;
                
                
                
                for(id subItem in [textGroupView subviews]) {
                    UIView *subView = (UIView *)subItem;
                    CGRect subViewFrame = [targetView convertRect:subView.frame toView:targetSuperView];
                    
                    CGContextSaveGState(context);
                    
                    if(textGroupView.viewRotation) {
                        
                        //[self pdfDrawRect:subViewFrame withColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:0.35]];
                        
                        rotation = [textGroupView.viewRotation floatValue];
                        
                        CGAffineTransform targetTransform = targetView.transform;
                        targetView.transform = CGAffineTransformIdentity;
                        subViewFrame = [templateWrapView.layer convertRect:targetView.layer.frame fromLayer:targetSuperView.layer];
                        
                        //[self pdfDrawRect:subViewFrame withColor:[UIColor colorWithRed:1 green:1 blue:0 alpha:0.35]];
                        
                        
                        targetSuperView.transform = CGAffineTransformMakeRotation(-rotation * M_PI/180.0);
                        r = CGAffineTransformMakeRotation(rotation * M_PI/180.0);
                        CGContextConcatCTM(context, r);
                        
                        targetSuperView.layer.position = CGPointZero;
                        
                        //NSLog(@"targetSuperView.layer.frame : %@", NSStringFromCGRect(targetSuperView.layer.frame));
                        //NSLog(@"targetSuperView.frame : %@", NSStringFromCGRect(targetSuperView.frame));
                        
                        CGPoint centerPoint = [templateWrapView.layer convertPoint:targetView.center fromLayer:targetSuperView.layer];
                        
                        centerPoint.x -= targetSuperView.layer.frame.origin.x;
                        centerPoint.y -= targetSuperView.layer.frame.origin.y;
                        //NSLog(@"centerPoint : %@", NSStringFromCGPoint(centerPoint));
                        
                        CGRect contextBounds = CGContextGetClipBoundingBox(context);
                        CGPoint translation = contextBounds.origin;
                        //NSLog(@"contextBounds : %@", NSStringFromCGRect(contextBounds));
                        
                        CGContextConcatCTM(context, CGAffineTransformInvert(r));
                        
                        targetView.transform = targetTransform;
                        targetSuperView.transform = CGAffineTransformIdentity;
                        
                        t = CGAffineTransformMakeTranslation(translation.x, translation.y);
                        
                        CGContextConcatCTM(context, r);
                        CGContextConcatCTM(context, t);
                        
                        contextBounds = CGContextGetClipBoundingBox(context);
                        //NSLog(@"contextBounds : %@", NSStringFromCGRect(contextBounds));
                        
                        subViewFrame.origin = CGPointMake(centerPoint.x - (subViewFrame.size.width / 2), centerPoint.y - (subViewFrame.size.height / 2));
                        //NSLog(@"draw frame: %@", NSStringFromCGRect(subViewFrame));
                    }
                    
                    
                    if([subItem isKindOfClass:[PUILabel class]]) {
                        PUILabel *label = (PUILabel *)subItem;
                        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                        paragraphStyle.alignment = label.textAlignment;
                        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                        
                        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithAttributedString:label.attributedText];
                        [attString addAttribute:NSForegroundColorAttributeName value:label.textColor range:NSMakeRange(0, attString.string.length)];
                        [attString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attString.string.length)];
                        
                        [self pdfDrawText:attString withFrame:subViewFrame textAlignment:label.textAlignment];
                        
                    } else if(subView.hidden == NO) {
                        // View 캡쳐해서 그림
                        UIGraphicsBeginImageContextWithOptions(subViewFrame.size, NO, 1);
                        [subView.layer renderInContext:UIGraphicsGetCurrentContext()];
                        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        
                        [image drawInRect:subViewFrame];
                    }
                    
                    CGContextRestoreGState(context);
                }
                
                

            } else if([targetView isKindOfClass:[PPhotoView class]]) {
                //UIGraphicsBeginImageContextWithOptions(targetFrame.size, NO, 2);
                // 스케일 주면 품질은 좋아지지만 용량이 너무 커짐
                UIGraphicsBeginImageContextWithOptions(targetFrame.size, NO, 1);
                [targetView.layer renderInContext:UIGraphicsGetCurrentContext()];
                UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                [image drawInRect:targetFrame];
                
            } else if([targetView isKindOfClass:[PCubeView class]]) {
                PCubeView *cubeView = (PCubeView *)targetView;
                
                [self pdfDrawCubeRect:targetFrame withColor:cubeView.shapeColor opacity:cubeView.alpha];
                
            } else if([targetView isKindOfClass:[PFlatView class]]) {
                
                PFlatView *flatView = (PFlatView *)targetView;
                
                CGFloat rotation = 0;
                CGAffineTransform t;
                CGAffineTransform r;
                
                CGContextSaveGState(context);
                
                if(flatView.viewRotation) {
                    
                    //[self pdfDrawRect:targetFrame withColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:1] opacity:0.35];
                    
                    rotation = [flatView.viewRotation floatValue];
                    
                    CGAffineTransform targetTransform = targetView.transform;
                    targetView.transform = CGAffineTransformIdentity;
                    targetFrame = [templateWrapView.layer convertRect:targetView.layer.frame fromLayer:targetSuperView.layer];
                    
                    //[self pdfDrawRect:targetFrame withColor:[UIColor colorWithRed:1 green:1 blue:0 alpha:1] opacity:0.35];
                    
                    
                    targetSuperView.transform = CGAffineTransformMakeRotation(-rotation * M_PI/180.0);
                    r = CGAffineTransformMakeRotation(rotation * M_PI/180.0);
                    CGContextConcatCTM(context, r);
                    
                    targetSuperView.layer.position = CGPointZero;
                    
                    //NSLog(@"targetSuperView.layer.frame : %@", NSStringFromCGRect(targetSuperView.layer.frame));
                    //NSLog(@"targetSuperView.frame : %@", NSStringFromCGRect(targetSuperView.frame));
                    
                    CGPoint centerPoint = [templateWrapView.layer convertPoint:targetView.center fromLayer:targetSuperView.layer];
                    
                    centerPoint.x -= targetSuperView.layer.frame.origin.x;
                    centerPoint.y -= targetSuperView.layer.frame.origin.y;
                    //NSLog(@"centerPoint : %@", NSStringFromCGPoint(centerPoint));
                    
                    CGRect contextBounds = CGContextGetClipBoundingBox(context);
                    CGPoint translation = contextBounds.origin;
                    //NSLog(@"contextBounds : %@", NSStringFromCGRect(contextBounds));
                    
                    CGContextConcatCTM(context, CGAffineTransformInvert(r));
                    
                    targetView.transform = targetTransform;
                    targetSuperView.transform = CGAffineTransformIdentity;
                    
                    t = CGAffineTransformMakeTranslation(translation.x, translation.y);
                    
                    CGContextConcatCTM(context, r);
                    CGContextConcatCTM(context, t);
                    
                    contextBounds = CGContextGetClipBoundingBox(context);
                    //NSLog(@"contextBounds : %@", NSStringFromCGRect(contextBounds));
                    
                    targetFrame.origin = CGPointMake(centerPoint.x - (targetFrame.size.width / 2), centerPoint.y - (targetFrame.size.height / 2));
                    //NSLog(@"draw frame: %@", NSStringFromCGRect(targetFrame));
                }
                
                
                
                if(targetView.layer.cornerRadius != 0) {
                    if(targetView.layer.cornerRadius < CGRectGetHeight(targetFrame) / 2) {
                        
                        [self pdfDrawRoundedRect:targetFrame withColor:targetView.backgroundColor cornerRadius:targetView.layer.cornerRadius opacity:targetView.alpha];
                        
                    } else {
                        
                        [self pdfDrawCircle:targetFrame withColor:targetView.backgroundColor opacity:targetView.alpha];
                    }
                    
                } else if(targetView.layer.borderWidth != 0) {
                    
                    [self pdfDrawBorderRect:targetFrame borderWidth:targetView.layer.borderWidth withColor:[UIColor colorWithCGColor:targetView.layer.borderColor] opacity:targetView.alpha];
                } else {
                    // 아무 값이 없으면 Rect 그림
                    [self pdfDrawRect:targetFrame withColor:targetView.backgroundColor opacity:targetView.alpha];
                }
                
                
                
                CGContextRestoreGState(context);
                
            } else if(targetView.hidden == NO) {
                UIGraphicsBeginImageContextWithOptions(targetFrame.size, NO, 1);
                [targetView.layer renderInContext:UIGraphicsGetCurrentContext()];
                UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                [image drawInRect:targetFrame];
            }
        }
        
    }
    
    UIGraphicsEndPDFContext();
    
    return pdfURL;
}

- (void)pdfDrawCircle:(CGRect)frame withColor:(UIColor *)color opacity:(CGFloat)opacity
{
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    UIColor *drawColor = [UIColor colorWithRed:r green:g blue:b alpha:opacity];
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    //CGContextSetStrokeColorWithColor(currentContext, color.CGColor);
    CGContextSetFillColorWithColor(currentContext, drawColor.CGColor);
    CGContextFillEllipseInRect (currentContext, frame);
    //CGContextFillPath(currentContext);
}


- (void)pdfDrawBorderRect:(CGRect)frame borderWidth:(CGFloat)borderWidth withColor:(UIColor *)color opacity:(CGFloat)opacity
{
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    UIColor *drawColor = [UIColor colorWithRed:r green:g blue:b alpha:opacity];
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(currentContext, drawColor.CGColor);
    CGContextStrokeRectWithWidth(currentContext, frame, borderWidth);
    CGContextDrawPath(currentContext, kCGPathStroke);
}

- (void)pdfDrawRect:(CGRect)frame withColor:(UIColor *)color opacity:(CGFloat)opacity
{
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    UIColor *drawColor = [UIColor colorWithRed:r green:g blue:b alpha:opacity];
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    //CGContextSetStrokeColorWithColor(currentContext, color.CGColor);
    CGContextSetFillColorWithColor(currentContext, drawColor.CGColor);
    CGContextFillRect(currentContext, frame);
    //CGContextFillPath(currentContext);
}

- (void)pdfDrawRoundedRect:(CGRect)frame withColor:(UIColor *)color cornerRadius:(CGFloat)radius opacity:(CGFloat)opacity
{
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    UIColor *drawColor = [UIColor colorWithRed:r green:g blue:b alpha:opacity];
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(currentContext, drawColor.CGColor);
    
    
    CGFloat minx = CGRectGetMinX(frame), midx = CGRectGetMidX(frame), maxx = CGRectGetMaxX(frame);
    CGFloat miny = CGRectGetMinY(frame), midy = CGRectGetMidY(frame), maxy = CGRectGetMaxY(frame);
    

    // Start at 1
    CGContextMoveToPoint(currentContext, minx, midy);
    // Add an arc through 2 to 3
    CGContextAddArcToPoint(currentContext, minx, miny, midx, miny, radius);
    // Add an arc through 4 to 5
    CGContextAddArcToPoint(currentContext, maxx, miny, maxx, midy, radius);
    // Add an arc through 6 to 7
    CGContextAddArcToPoint(currentContext, maxx, maxy, midx, maxy, radius);
    // Add an arc through 8 to 9
    CGContextAddArcToPoint(currentContext, minx, maxy, minx, midy, radius);
    // Close the path 
    CGContextClosePath(currentContext);
    // Fill & stroke the path 
    CGContextFillPath(currentContext);
}

- (void)pdfDrawCubeRect:(CGRect)frame withColor:(UIColor *)color opacity:(CGFloat)opacity
{
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    UIColor *drawColor = [UIColor colorWithRed:r green:g blue:b alpha:opacity];
    
    CGFloat polySize = (frame.size.height / 2); // change this
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    
    CGAffineTransform t0 = CGContextGetCTM(currentContext);
    t0 = CGAffineTransformInvert(t0);
    CGContextConcatCTM(currentContext, t0);
    
    //Begin drawing setup
    CGContextBeginPath(currentContext);
    CGContextSetRGBStrokeColor(currentContext, 0, 0, 0, 1);
    CGContextSetFillColorWithColor(currentContext, drawColor.CGColor);
    //CGContextSetLineWidth(context, 2.0);
    
    CGPoint center;
    
    //Start drawing polygon
    center = CGPointMake(frame.origin.x + (frame.size.width / 2), frame.origin.y + (frame.size.height / 2));
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



- (void)pdfDrawText:(NSAttributedString *)attString withFrame:(CGRect)frame textAlignment:(NSTextAlignment)textAlignment;
{
    CGRect rect = [attString boundingRectWithSize:frame.size
                                  options:NSStringDrawingUsesLineFragmentOrigin
                                  context:nil];
    CGRect drawRect = frame;
    if(textAlignment == NSTextAlignmentCenter) {
        drawRect = (CGRect) {
            frame.origin.x + ((frame.size.width - rect.size.width) / 2),
            frame.origin.y + ((frame.size.height - rect.size.height) / 2),
            rect.size.width,
            rect.size.height
        };
    } else if(textAlignment == NSTextAlignmentLeft) {
        drawRect = (CGRect) {
            frame.origin.x,
            frame.origin.y + ((frame.size.height - rect.size.height) / 2),
            rect.size.width,
            rect.size.height
        };
    } else {
        drawRect = (CGRect) {
            frame.origin.x + (frame.size.width - rect.size.width),
            frame.origin.y + ((frame.size.height - rect.size.height) / 2),
            rect.size.width,
            rect.size.height
        };
        
    }
    [attString drawInRect:drawRect];
}

- (void)addLineWithFrame:(CGRect)frame withColor:(UIColor *)color opacity:(CGFloat)opacity
{
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    UIColor *drawColor = [UIColor colorWithRed:r green:g blue:b alpha:opacity];
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(currentContext, drawColor.CGColor);
    
    // this is the thickness of the line
    CGContextSetLineWidth(currentContext, frame.size.height);
    
    CGPoint startPoint = frame.origin;
    CGPoint endPoint = CGPointMake(frame.origin.x + frame.size.width, frame.origin.y);
    
    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(currentContext, endPoint.x, endPoint.y);
    
    CGContextClosePath(currentContext);
    CGContextDrawPath(currentContext, kCGPathFillStroke);
}

- (void)addImage:(UIImage *)image atPoint:(CGPoint)point
{
    CGRect imageFrame = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [image drawInRect:imageFrame];
}
@end