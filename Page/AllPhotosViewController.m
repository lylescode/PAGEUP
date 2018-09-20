//
//  AllPhotosViewController.m
//  Page
//
//  Created by CMR on 3/17/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "AllPhotosViewController.h"
#import "AssetGridViewCell.h"

@implementation NSIndexSet (Convenience)
- (NSArray *)aapl_indexPathsFromIndexesWithSection:(NSUInteger)section {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    return indexPaths;
}
@end


@implementation UICollectionView (Convenience)
- (NSArray *)aapl_indexPathsForElementsInRect:(CGRect)rect {
    NSArray *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) { return nil; }
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}
@end

@interface AllPhotosViewController () <PHPhotoLibraryChangeObserver>

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *topTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *topButton;
- (IBAction)topButtonAction:(id)sender;

@property (strong, nonatomic) PHCachingImageManager *imageManager;
@property (assign, nonatomic) CGRect previousPreheatRect;

@property (strong, nonatomic) AllAlbumsViewController *allAlbumsViewController;

- (void)setAlbumTitleString:(NSString *)titleString;

- (void)presentAllAlbums;
- (void)dismissAllAlbums;

@end

@implementation AllPhotosViewController

static NSString * const reuseIdentifier = @"Cell";
static CGSize AssetThumbnailSize;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageManager = [[PHCachingImageManager alloc] init];
    [self resetCachedAssets];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    // Register cell classes
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.allowsMultipleSelection = YES;
    self.collectionView.directionalLockEnabled = YES;
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerNib:[UINib nibWithNibName:@"AssetGridViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:reuseIdentifier];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO]];
    //options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    self.assetsFetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
    
    [self updateSelectedPhotos];
    [self setAlbumTitleString:NSLocalizedString(@"All Photos", nil)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    CGFloat viewWidth;
    CGSize cellSize;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    CGFloat thumbnailWidth;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if(self.view.frame.size.width < self.view.frame.size.height) {
            
            thumbnailWidth = ((self.view.frame.size.width - 6) / 4);
            viewWidth = self.view.frame.size.width - 6;
            
            cellSize = CGSizeMake(floor(viewWidth / 3), floor(viewWidth / 3));
            
            layout.minimumInteritemSpacing = 3;
            layout.minimumLineSpacing = 3;
            
        } else {
            
            thumbnailWidth = ((self.view.frame.size.width - 12) / 7);
            viewWidth = self.view.frame.size.width - 15;
            
            cellSize = CGSizeMake(floor(viewWidth / 6), floor(viewWidth / 6));
            
            layout.minimumInteritemSpacing = 3;
            layout.minimumLineSpacing = 3;
        }
    } else {
        if(self.view.frame.size.width < self.view.frame.size.height) {
            
            thumbnailWidth = ((self.view.frame.size.width - 9) / 4);
            viewWidth = self.view.frame.size.width - 9;
            
            cellSize = CGSizeMake(floor(viewWidth / 4), floor(viewWidth / 4));
            
            layout.minimumInteritemSpacing = 3;
            layout.minimumLineSpacing = 3;
        } else {
            thumbnailWidth = ((self.view.frame.size.width - 12) / 5);
            viewWidth = self.view.frame.size.width - 12;
            
            cellSize = CGSizeMake(floor(viewWidth / 5), floor(viewWidth / 5));
            
            layout.minimumInteritemSpacing = 3;
            layout.minimumLineSpacing = 3;
        }
        
    }
    
    layout.itemSize = cellSize;
    [self.collectionView setCollectionViewLayout:layout];
    
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    if(self.view.frame.size.width < self.view.frame.size.height) {
    } else {
        
    }
    AssetThumbnailSize = CGSizeMake(thumbnailWidth * scale, thumbnailWidth * scale);

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    [self resetCachedAssets];
    self.imageManager = nil;
    if(self.allAlbumsViewController) {
        [self.allAlbumsViewController.view removeFromSuperview];
        self.allAlbumsViewController = nil;
    }
}


- (IBAction)topButtonAction:(id)sender {
    if(!self.allAlbumsViewController) {
        [self presentAllAlbums];
    } else {
        [self dismissAllAlbums];
    }
}
- (void)setAlbumTitleString:(NSString *)titleString
{
    self.topTitleLabel.text = titleString;
    /*
    NSString *upperCaseString = [titleString uppercaseString];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:upperCaseString];
    [attrStr addAttribute:NSFontAttributeName value:self.topTitleLabel.font range:NSMakeRange(0, attrStr.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = self.topTitleLabel.textAlignment;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    [attrStr addAttribute:NSKernAttributeName value:[NSNumber numberWithInt:3] range:NSMakeRange(0, attrStr.length)];

    self.topTitleLabel.attributedText = attrStr;
     */
}

- (void)presentAllAlbums
{
    if(self.allAlbumsViewController) {
        return;
    }
    if([self.allPhotosDelegate respondsToSelector:@selector(allPhotosViewControllerNeedDisableCommon:)]) {
        [self.allPhotosDelegate allPhotosViewControllerNeedDisableCommon:YES];
    }
    
    AllAlbumsViewController *allAlbumsVC = [[AllAlbumsViewController alloc] init];
    allAlbumsVC.allAlbumsDelegate = self;
    allAlbumsVC.view.frame = self.view.bounds;
    
    
    UIEdgeInsets currentInsets = allAlbumsVC.albumTableView.contentInset;
    allAlbumsVC.albumTableView.contentInset = (UIEdgeInsets){
        .top = currentInsets.top,
        .bottom = self.collectionView.contentInset.bottom,
        .left = currentInsets.left,
        .right = currentInsets.right
    };
    
    [self.view addSubview:allAlbumsVC.view];
    [self.view bringSubviewToFront:self.topView];
    [allAlbumsVC presentViewControllerAnimated:YES completion:^{
        [allAlbumsVC selectCurrentAlbumTitle:self.topTitleLabel.text];
    }];
    
    self.allAlbumsViewController = allAlbumsVC;
}

- (void)dismissAllAlbums
{
    if(!self.allAlbumsViewController) {
        return;
    }
    if([self.allPhotosDelegate respondsToSelector:@selector(allPhotosViewControllerNeedDisableCommon:)]) {
        [self.allPhotosDelegate allPhotosViewControllerNeedDisableCommon:NO];
    }
    
    [self.allAlbumsViewController dismissViewControllerAnimated:YES
                                                     completion:^{
                                                         [self.allAlbumsViewController.view removeFromSuperview];
                                                         self.allAlbumsViewController = nil;
                                                     }];
}

- (void)updateSelectedPhotos
{
    NSInteger index = 0;
    for(PHAsset *asset in self.assetsFetchResults) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        if([self.projectResource addedPhotoAsset:asset]) {
            NSInteger assetIndex = [self.projectResource indexOfPhotoAsset:asset];
            AssetGridViewCell *cell = (AssetGridViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            cell.numberLabel.text = [NSString stringWithFormat:@"%i", (int)assetIndex + 1];
            [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        } else {
            [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
        }
        index++;
    }
}

#pragma mark - AllAlbumsViewControllerDelegate

- (void)allAlbumsViewControllerDidSelectAssetFetchResult:(PHFetchResult *)assetFetchResult albumTitle:(NSString *)albumTitle
{
    if(assetFetchResult) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.assetsFetchResults = assetFetchResult;
            
            [self resetCachedAssets];
            [self.collectionView reloadData];
            
            [self updateSelectedPhotos];
        });
        [self setAlbumTitleString:albumTitle];
        

    } else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO]];
            self.assetsFetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
            
            [self resetCachedAssets];
            [self.collectionView reloadData];
            
            [self updateSelectedPhotos];
        });
        [self setAlbumTitleString:NSLocalizedString(@"All Photos", nil)];
    }
    
    [self dismissAllAlbums];
}
- (void)allAlbumsViewControllerDidClose
{
    [self dismissAllAlbums];
}

- (void)deselectPhotoAtLocalIdentifier:(NSString *)localIdentifier
{
    NSInteger assetIndex = 0;
    
    if(self.projectResource.photoArray.count <= 1) {
        //doneButton.enabled = NO;
    }
    
    for(PHAsset *asset in self.assetsFetchResults) {
        if([asset.localIdentifier isEqualToString:localIdentifier]) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:assetIndex inSection:0];
            [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
        }
        
        assetIndex++;
    }
    
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    
    // check if there are changes to the assets (insertions, deletions, updates)
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assetsFetchResults];
    if (collectionChanges) {
        
        // get the new fetch result
        self.assetsFetchResults = [collectionChanges fetchResultAfterChanges];
        
        /*
         UICollectionView *collectionView = self.collectionView;
        if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
            // we need to reload all if the incremental diffs are not available
            [collectionView reloadData];
            
        } else {
            // if we have incremental diffs, tell the collection view to animate insertions and deletions
            [collectionView performBatchUpdates:^{
                NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                if ([removedIndexes count]) {
                    [collectionView deleteItemsAtIndexPaths:[removedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                }
                NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                if ([insertedIndexes count]) {
                    [collectionView insertItemsAtIndexPaths:[insertedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                }
                NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                if ([changedIndexes count]) {
                    [collectionView reloadItemsAtIndexPaths:[changedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                }
            } completion:NULL];
        }
         */
        
        [self resetCachedAssets];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }
    
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = self.assetsFetchResults.count;
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AssetGridViewCell *cell = (AssetGridViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Increment the cell's tag
    NSInteger currentTag = cell.tag + 1;
    cell.tag = currentTag;
    
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    
    [self.imageManager requestImageForAsset:asset
                                 targetSize:AssetThumbnailSize
                                contentMode:PHImageContentModeAspectFill
                                    options:nil
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  
                                  // Only update the thumbnail if the cell tag hasn't changed. Otherwise, the cell has been re-used.
                                  if (cell.tag == currentTag) {
                                      cell.thumbnailImage = result;
                                  }
                                  
                              }];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"didSelectItemAtIndexPath : %@", indexPath);
    AssetGridViewCell *cell = (AssetGridViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    UIImage *thumbnailImage = cell.thumbnailImage;
    
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    [self.allPhotosDelegate allPhotosViewControllerDidSelectPhotoAsset:asset thumbnailImage:thumbnailImage];
    
    //doneButton.enabled = YES;
    
    
    [self updateSelectedPhotos];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //MARK;
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    
    
    [self.allPhotosDelegate allPhotosViewControllerDidDeselectPhotoAsset:asset];
    
    if(self.projectResource.photoArray.count == 0) {
        //doneButton.enabled = NO;
    }
    
    [self updateSelectedPhotos];
}


// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}



// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.projectResource) {
        return [self.projectResource shouldAddPhotoAsset];
    }
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //MARK;
    return YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCachedAssets];
}


#pragma mark - Asset Caching

- (void)resetCachedAssets
{
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets
{
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    // If scrolled by a "reasonable" amount...
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:AssetThumbnailSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:AssetThumbnailSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler
{
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths
{
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = self.assetsFetchResults[indexPath.item];
        [assets addObject:asset];
    }
    return assets;
}



@end
