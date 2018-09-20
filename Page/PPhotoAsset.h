//
//  PPhotoAsset.h
//  Page
//
//  Created by CMR on 11/25/14.
//  Copyright (c) 2014 Page. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "Macro.h"

@interface PPhotoAsset : NSObject

@property (strong, nonatomic) NSString *localIdentifier;
@property (strong, nonatomic) NSString *cacheImageName;
@property (strong, nonatomic) NSString *cacheThumbnailName;
@property (strong, nonatomic) UIImage *photoImage;
@property (strong, nonatomic) UIImage *thumbnailImage;

- (id)initWithAsset:(PHAsset *)asset thumbnailImage:(UIImage *)thumbnail completion:(void(^)(void))callback;
- (id)initWithSavedDictionary:(NSDictionary *)photoDictionary completion:(void(^)(void))callback;
- (void)prepareForSaveProject;
- (UIImage *)loadCachedImage;
- (UIImage *)loadCachedThumbnail;
- (void)removeCachedImageFile;
- (NSDictionary *)photoAssetDictionary;

@end
