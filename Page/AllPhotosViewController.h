//
//  AllPhotosViewController.h
//  Page
//
//  Created by CMR on 3/17/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "ProjectResource.h"
#import "Macro.h"
#import "AllAlbumsViewController.h"

@protocol AllPhotosViewControllerDelegate <NSObject>
@required
- (void)allPhotosViewControllerDidDone;
- (void)allPhotosViewControllerDidSelectPhotoAsset:(PHAsset *)asset thumbnailImage:(UIImage *)thumbnailImage;
- (void)allPhotosViewControllerDidDeselectPhotoAsset:(PHAsset *)asset;

@optional
- (void)allPhotosViewControllerNeedDisableCommon:(BOOL)disableCommon;
@end

@interface AllPhotosViewController : UIViewController <UICollectionViewDelegate, AllAlbumsViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewLayout;

@property (assign, nonatomic) id<AllPhotosViewControllerDelegate> allPhotosDelegate;

@property (weak, nonatomic) ProjectResource *projectResource;

@property (strong, nonatomic) PHFetchResult *assetsFetchResults;

- (void)updateSelectedPhotos;
- (void)deselectPhotoAtLocalIdentifier:(NSString *)localIdentifier;


@end

