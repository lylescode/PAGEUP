//
//  AssetGridViewController.h
//  Page
//
//  Created by CMR on 11/20/14.
//  Copyright (c) 2014 Page. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "ProjectResource.h"
#import "Macro.h"
@protocol AssetGridViewControllerDelegate <NSObject>

- (void)assetGridViewControllerDidDone;
- (void)assetGridViewControllerDidSelectPhotoAsset:(PHAsset *)asset;
- (void)assetGridViewControllerDidDeselectPhotoAsset:(PHAsset *)asset;

@end

@interface AssetGridViewController : UICollectionViewController

@property (assign, nonatomic) id<AssetGridViewControllerDelegate> assetGridDelegate;

@property (strong, nonatomic) UIBarButtonItem *doneButton;

@property (weak, nonatomic) ProjectResource *projectResource;

@property (strong) PHFetchResult *assetsFetchResults;
@property (strong) PHAssetCollection *assetCollection;

- (void)deselectPhotoAtLocalIdentifier:(NSString *)localIdentifier;

@end
