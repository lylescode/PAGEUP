//
//  PPhotoAsset.m
//  Page
//
//  Created by CMR on 11/25/14.
//  Copyright (c) 2014 Page. All rights reserved.
//

#import "PPhotoAsset.h"
@interface PPhotoAsset ()
{
    PHImageRequestID requestID;
}

- (void)moveToDocumentDirectoryWithCachedImage;
- (void)moveToDocumentDirectoryWithCachedThumbnail;
- (void)writeCachedImageFileWithImageData:(NSData *)imageData thumbnailData:(NSData *)thumbnailData;
@end

@implementation PPhotoAsset

- (id)initWithAsset:(PHAsset *)asset thumbnailImage:(UIImage *)thumbnail completion:(void(^)(void))callback
{
    self = [super init];
    if (self) {
        self.localIdentifier = [NSString stringWithString:asset.localIdentifier];
        
        PHImageManager *imageManager = [PHImageManager defaultManager];
        
        requestID = [imageManager requestImageDataForAsset:asset
                                                   options:nil
                                             resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                                                 
                                                 NSData *thumbnailData = UIImageJPEGRepresentation(thumbnail, 0.6);
                                                 [self writeCachedImageFileWithImageData:imageData thumbnailData:thumbnailData];
                                                 
                                                 self.photoImage = [self loadCachedImage];
                                                 self.thumbnailImage = thumbnail;
                                                 
                                                 if(callback != nil) {
                                                     callback();
                                                 }
                                             }];
        
    }
    return self;
}

- (id)initWithSavedDictionary:(NSDictionary *)photoDictionary completion:(void(^)(void))callback
{
    self = [super init];
    if (self) {
        
        self.localIdentifier = [NSString stringWithString:[photoDictionary objectForKey:@"localIdentifier"]];
        self.cacheImageName = [NSString stringWithString:[photoDictionary objectForKey:@"cacheImageName"]];
        self.cacheThumbnailName = [NSString stringWithString:[photoDictionary objectForKey:@"cacheThumbnailName"]];
        self.photoImage = [self loadCachedImage];
        self.thumbnailImage = [self loadCachedThumbnail];
        
        if(callback != nil) {
            callback();
        }
        //TODO: 저장했던 프로젝트 불러올때 여기서 썸네일, 이미지, localIdentifier 까치 생성해주기
    }
    return self;
}

- (void)dealloc
{
    self.localIdentifier = nil;
    self.cacheImageName = nil;
    self.cacheThumbnailName = nil;
    self.photoImage = nil;
    self.thumbnailImage = nil;
    
    PHImageManager *imageManager = [PHImageManager defaultManager];
    [imageManager cancelImageRequest:requestID];
}

- (void)prepareForSaveProject
{
    [self moveToDocumentDirectoryWithCachedImage];
    [self moveToDocumentDirectoryWithCachedThumbnail];
}
- (void)writeCachedImageFileWithImageData:(NSData *)imageData thumbnailData:(NSData *)thumbnailData
{
    NSString *imageName = @"pageup_cached";
    NSString *thumbnailName = @"pageup_cached_thumbnail";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSInteger r = arc4random() % 100000000;
    NSString *imageFullname = [NSString stringWithFormat:@"%@_%li.JPG",imageName, (long)r];
    NSString *thumbnailFullname = [NSString stringWithFormat:@"%@_%li.JPG",thumbnailName, (long)r];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:imageFullname];
    NSString *thumbnailPath;
    
    //NSString *thumbnailPath = [documentsDirectory stringByAppendingPathComponent:thumbnailFullname];
    
    BOOL isDir;
    while ([fileManager fileExistsAtPath:imagePath isDirectory:&isDir] == YES) {
        r = arc4random() % 100000000;
        
        imageFullname = [NSString stringWithFormat:@"%@_%li.JPG",imageName, (long)r];
        thumbnailFullname = [NSString stringWithFormat:@"%@_%li.JPG",thumbnailName, (long)r];
        
        imagePath = [documentsDirectory stringByAppendingPathComponent:imageFullname];
        //thumbnailPath = [documentsDirectory stringByAppendingPathComponent:thumbnailFullname];
    }
    self.cacheImageName = imageFullname;
    self.cacheThumbnailName = thumbnailFullname;
    
    imagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:imageFullname];
    thumbnailPath = [NSTemporaryDirectory() stringByAppendingPathComponent:thumbnailFullname];
    
    if (![imageData writeToFile:imagePath atomically:YES] || ![thumbnailData writeToFile:thumbnailPath atomically:YES] ) {
        NSLog(@"Failed to cache image data to disk");
    } else {
        NSLog(@"cached image path %@", imagePath);
        NSLog(@"cached thumbnail path %@", thumbnailPath);
    }
}

- (void)moveToDocumentDirectoryWithCachedImage
{
    if(!self.cacheImageName) {
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Temporary 디렉토리에 파일이 있으면 Document 디렉토리로 이동
    NSString *imagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:self.cacheImageName];
    BOOL isDir;
    if([fileManager fileExistsAtPath:imagePath isDirectory:&isDir] == YES) {
        
        NSString *documentImagePath = [documentsDirectory stringByAppendingPathComponent:self.cacheImageName];
        NSError *error = nil;
        if (![fileManager moveItemAtPath:imagePath toPath:documentImagePath error:&error]) {
            NSLog(@"Failed to preview image data to disk");
        } else {
            NSLog(@"moveToDocumentDirectoryWithCachedImage %@", documentImagePath);
        }
    }

}
- (void)moveToDocumentDirectoryWithCachedThumbnail
{
    
    if(!self.cacheThumbnailName) {
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Temporary 디렉토리에 파일이 있으면 Document 디렉토리로 이동
    NSString *imagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:self.cacheThumbnailName];
    BOOL isDir;
    if([fileManager fileExistsAtPath:imagePath isDirectory:&isDir] == YES) {
        
        NSString *documentImagePath = [documentsDirectory stringByAppendingPathComponent:self.cacheThumbnailName];
        NSError *error = nil;
        if (![fileManager moveItemAtPath:imagePath toPath:documentImagePath error:&error]) {
            NSLog(@"Failed to preview image data to disk");
        } else {
            NSLog(@"moveToDocumentDirectoryWithCachedThumbnail %@", documentImagePath);
        }
    }
}

- (UIImage *)loadCachedImage
{
    if(!self.cacheImageName) {
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:self.cacheImageName];
    
    // Document 디렉토리에 파일이 없으면 Temporary 디렉토리 검색
    BOOL isDir;
    if([fileManager fileExistsAtPath:imagePath isDirectory:&isDir] == YES) {
        UIImage *cachedImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
        NSLog(@"loadCachedImage size : %@", NSStringFromCGSize(cachedImage.size));
        return cachedImage;
    }
    
    imagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:self.cacheImageName];
    if([fileManager fileExistsAtPath:imagePath isDirectory:&isDir] == YES) {
        UIImage *cachedImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
        NSLog(@"loadCachedImage size : %@", NSStringFromCGSize(cachedImage.size));
        return cachedImage;
    }
    
    return nil;
}

- (UIImage *)loadCachedThumbnail
{
    if(!self.cacheThumbnailName) {
        return nil;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *thumbnailPath = [documentsDirectory stringByAppendingPathComponent:self.cacheThumbnailName];
    
    // Document 디렉토리에 파일이 없으면 Temporary 디렉토리 검색
    BOOL isDir;
    if([fileManager fileExistsAtPath:thumbnailPath isDirectory:&isDir] == YES) {
        UIImage *cachedThumbnail = [[UIImage alloc] initWithContentsOfFile:thumbnailPath];
        return cachedThumbnail;
    }
    
    thumbnailPath = [NSTemporaryDirectory() stringByAppendingPathComponent:self.cacheThumbnailName];
    if([fileManager fileExistsAtPath:thumbnailPath isDirectory:&isDir] == YES) {
        UIImage *cachedThumbnail = [[UIImage alloc] initWithContentsOfFile:thumbnailPath];
        return cachedThumbnail;
    }
    
    return nil;
}
- (void)removeCachedImageFile
{
    if(!self.cacheImageName) {
        return;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:self.cacheImageName];
    NSString *thumbnailPath = [documentsDirectory stringByAppendingPathComponent:self.cacheThumbnailName];
    
    NSError *error = nil;
    if(![fileManager removeItemAtPath:imagePath error:&error] || ![fileManager removeItemAtPath:thumbnailPath error:&error]) {
        NSLog(@"Failed to cache image remove from disk : %@", error);
    } else {
        //NSLog(@"cached image removed : %@", self.cacheImageName);
        //NSLog(@"cached thumbnail removed : %@", self.cacheThumbnailName);
    }
    
    //NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    //NSLog(@"removeCachedImageFile directoryContents : %@", directoryContents);
}

- (NSDictionary *)photoAssetDictionary
{
    NSMutableDictionary *photoDictionary = [NSMutableDictionary dictionary];
    [photoDictionary setObject:[NSString stringWithString:self.localIdentifier] forKey:@"localIdentifier"];
    [photoDictionary setObject:[NSString stringWithString:self.cacheImageName] forKey:@"cacheImageName"];
    [photoDictionary setObject:[NSString stringWithString:self.cacheThumbnailName] forKey:@"cacheThumbnailName"];
    return [NSDictionary dictionaryWithDictionary:photoDictionary];
}

@end
