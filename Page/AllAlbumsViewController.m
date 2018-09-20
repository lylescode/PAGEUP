//
//  AllAlbumsViewController.m
//  Page
//
//  Created by CMR on 5/15/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "AllAlbumsViewController.h"
#import "AllAlbumsTableViewCell.h"

@interface AllAlbumsViewController () <PHPhotoLibraryChangeObserver>
{
    UITapGestureRecognizer *tapGesture;
    
}
@property (weak, nonatomic) IBOutlet UIView *dimmedView;

@property (strong, nonatomic) PHCachingImageManager *imageManager;
@property (strong, nonatomic) NSArray *albumCollectionArray;
@property (strong, nonatomic) NSArray *albumTitleArray;

- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer;
- (NSArray *)filteredCollections:(PHFetchResult *)collections;
@end

static NSString * const reuseIdentifier = @"AlbumCell";
static CGSize AssetThumbnailSize;

@implementation AllAlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.albumTableView.backgroundColor = [UIColor whiteColor];
    self.albumTableView.separatorColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    //self.albumTableView.separatorColor = [UIColor blackColor];
    [self.albumTableView registerNib:[UINib nibWithNibName:@"AllAlbumsTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:reuseIdentifier];
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    NSArray *filterdSmartAlbums = [self filteredCollections:smartAlbums];
    
    PHFetchResult *userCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    NSArray *filterdUserCollections = [self filteredCollections:userCollections];
    
    self.albumCollectionArray = @[filterdSmartAlbums, filterdUserCollections];
    
    NSMutableArray *titleArray = [NSMutableArray array];
    [titleArray addObject:NSLocalizedString(@"All Photos", nil)];
    for(PHFetchResult *fetchResult in self.albumCollectionArray) {
        for(PHCollection *collection in fetchResult) {
            
            if ([collection isKindOfClass:[PHAssetCollection class]]) {
                NSString *localizedTitle = collection.localizedTitle;
                [titleArray addObject:localizedTitle];
            }
        }
    }
    self.albumTitleArray = [NSArray arrayWithArray:titleArray];
    NSLog(@"self.albumTitleArray : %@", self.albumTitleArray);
    
    //self.collectionsFetchResults = @[];
    //self.collectionsLocalizedTitles = @[];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.dimmedView addGestureRecognizer:tapGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewWillLayoutSubviews
{
    CGFloat thumbnailWidth;
    if(self.view.frame.size.width < self.view.frame.size.height) {
        thumbnailWidth = ((self.view.frame.size.width - 6) / 4);
        
    } else {
        thumbnailWidth = ((self.view.frame.size.width - 12) / 7);
    }
    
    CGFloat scale = [UIScreen mainScreen].scale;
    AssetThumbnailSize = CGSizeMake(thumbnailWidth * scale, thumbnailWidth * scale);
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    [self.dimmedView removeGestureRecognizer:tapGesture];
    self.albumCollectionArray = nil;
    self.albumTitleArray = nil;
}
- (void)selectCurrentAlbumTitle:(NSString *)title
{
    NSLog(@"selectCurrentAlbumTitle : %@", title);
    if([title isEqualToString:NSLocalizedString(@"All Photos", nil)]) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        NSLog(@"indexPath : %@" , indexPath);
        [self.albumTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
        
    } else if([self.albumTitleArray indexOfObject:title]) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.albumTitleArray indexOfObject:title] - 1 inSection:0];
        NSLog(@"indexPath : %@" , indexPath);
        [self.albumTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
    }
}
- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded)
    {
        [self.allAlbumsDelegate allAlbumsViewControllerDidClose];
    }
}
- (NSArray *)filteredCollections:(PHFetchResult *)collections
{
    
    NSMutableArray *filteredCollections = [NSMutableArray array];
    for(PHCollection *collection in collections) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
            
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
            if(assetsFetchResult.count > 0) {
                [filteredCollections addObject:collection];
            }
        }
    }
    return [NSArray arrayWithArray:filteredCollections];
}
- (void)presentViewControllerAnimated:(BOOL)animated completion:(void(^)(void))callback
{
    [presentDelegate presentWillFinish:self];
    self.view.hidden = NO;
    
    if(animated) {
        
        CGFloat animationDelay = 0;
        CGFloat duration = 0.65;
        CGFloat damping = 1;
        CGFloat velocity = 0;
        
        self.dimmedView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                         animations:^{
                             self.dimmedView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
                         }
                         completion:^(BOOL finished){
                             
                             if(callback != nil) {
                                 callback();
                             }
                             [presentDelegate presentDidFinish:self];
                         }];
        
        self.albumTableView.transform = CGAffineTransformMakeTranslation(0, -(self.albumTableView.frame.origin.y + self.albumTableView.frame.size.height));
        [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                         animations:^{
                             self.albumTableView.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished){
                         }];
        
    } else {
        if(callback != nil) {
            callback();
        }
        [presentDelegate presentDidFinish:self];
    }
}
- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void(^)(void))callback
{
    [presentDelegate dismissWillFinish:self];
    
    if(animated) {
        
        CGFloat animationDelay = 0;
        CGFloat duration = 0.65;
        CGFloat damping = 1;
        CGFloat velocity = 0;
        
        [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                         animations:^{
                             self.albumTableView.transform = CGAffineTransformMakeTranslation(0, -(self.albumTableView.frame.origin.y + self.albumTableView.frame.size.height));
                         }
                         completion:^(BOOL finished){
                         }];
        
        [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                         animations:^{
                             self.dimmedView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
                         }
                         completion:^(BOOL finished){
                             if(callback != nil) {
                                 callback();
                             }
                             [presentDelegate dismissDidFinish:self];
                         }];
    } else {
        if(callback != nil) {
            callback();
        }
        [presentDelegate dismissDidFinish:self];
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    for(PHFetchResult *fetchResult in self.albumCollectionArray) {
        //NSLog(@"fetchResult : %@", fetchResult);
        
        numberOfRows += fetchResult.count;
    }
    NSLog(@"numberOfRows : %li", (long)numberOfRows);
    return numberOfRows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AllAlbumsTableViewCell *albumCell = (AllAlbumsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSInteger currentTag = albumCell.tag + 1;
    albumCell.tag = currentTag;
    
    NSString *localizedTitle = nil;
    NSInteger collectionCount = 0;
    if(indexPath.row == 0) {
        localizedTitle = NSLocalizedString(@"All Photos", nil);
        
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO]];
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
        collectionCount = assetsFetchResult.count;
        /*
        PHAsset *lastAsset = [assetsFetchResult firstObject];
        [[PHImageManager defaultManager] requestImageForAsset:lastAsset
                                                   targetSize:AssetThumbnailSize
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:PHImageRequestOptionsVersionCurrent
                                                resultHandler:^(UIImage *result, NSDictionary *info) {
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        
                                                        if (albumCell.tag == currentTag) {
                                                            albumCell.iconImageView.image = result;
                                                        }
                                                        
                                                    });
                                                }];
        */
    } else {
        NSInteger cellIndex = indexPath.row;
        PHCollection *collection;
        
        for(PHFetchResult *fetchResult in self.albumCollectionArray) {
            if(cellIndex < fetchResult.count) {
                collection = fetchResult[cellIndex];
                break;
            } else {
                cellIndex -= fetchResult.count;
            }
        }
        if(collection) {
            localizedTitle = collection.localizedTitle;
            
            if ([collection isKindOfClass:[PHAssetCollection class]]) {
                
                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO]];
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
                
                PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
                /*
                PHAsset *lastAsset = [assetsFetchResult firstObject];
                [[PHImageManager defaultManager] requestImageForAsset:lastAsset
                                                           targetSize:AssetThumbnailSize
                                                          contentMode:PHImageContentModeAspectFill
                                                              options:PHImageRequestOptionsVersionCurrent
                                                        resultHandler:^(UIImage *result, NSDictionary *info) {
                                                            
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                
                                                                if (albumCell.tag == currentTag) {
                                                                    albumCell.iconImageView.image = result;
                                                                }
                                                                
                                                            });
                                                        }];
                */
                collectionCount = assetsFetchResult.count;
            }
        }
    }
    
    [albumCell setTitle:localizedTitle countString:[NSString stringWithFormat:@"%li", (long)collectionCount]];
    /*
    albumCell.titleLabel.attributedText = [self textKernString:[localizedTitle uppercaseString] targetLabel:albumCell.titleLabel];
     */
    //NSLog(@"cellForRowAtIndexPath : %@", localizedTitle);
    return albumCell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath : %@", indexPath);
    
    NSString *localizedTitle = nil;
    
    if(indexPath.row == 0) {
        localizedTitle = NSLocalizedString(@"All Photos", nil);
        [self.allAlbumsDelegate allAlbumsViewControllerDidSelectAssetFetchResult:nil albumTitle:localizedTitle];
        
    } else {
        NSInteger cellIndex = indexPath.row;
        PHCollection *collection;
        
        for(PHFetchResult *fetchResult in self.albumCollectionArray) {
            if(cellIndex < fetchResult.count) {
                collection = fetchResult[cellIndex];
                break;
            } else {
                cellIndex -= fetchResult.count;
            }
        }
        if(collection) {
            localizedTitle = collection.localizedTitle;
            
            if ([collection isKindOfClass:[PHAssetCollection class]]) {
                
                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO]];
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
                
                PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
                
                [self.allAlbumsDelegate allAlbumsViewControllerDidSelectAssetFetchResult:assetsFetchResult albumTitle:localizedTitle];
            }
            
        }
    }
    
}


- (NSMutableAttributedString *)textKernString:(NSString *)string targetLabel:(UILabel *)label
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:string];
    [attrStr addAttribute:NSFontAttributeName value:label.font range:NSMakeRange(0, attrStr.length)];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = label.textAlignment;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    [attrStr addAttribute:NSKernAttributeName value:[NSNumber numberWithFloat:3] range:NSMakeRange(0, attrStr.length)];
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attrStr.length)];
    
    return attrStr;
}



#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    /*
    NSMutableArray *updatedCollectionsFetchResults = nil;
    
    for (PHFetchResult *collectionsFetchResult in self.albumCollectionArray) {
        PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:collectionsFetchResult];
        if (changeDetails) {
            if (!updatedCollectionsFetchResults) {
                updatedCollectionsFetchResults = [self.albumCollectionArray mutableCopy];
            }
            [updatedCollectionsFetchResults replaceObjectAtIndex:[self.albumCollectionArray indexOfObject:collectionsFetchResult] withObject:[changeDetails fetchResultAfterChanges]];
        }
    }
    
    if (updatedCollectionsFetchResults) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.albumCollectionArray = updatedCollectionsFetchResults;
            [self.albumTableView reloadData];
        });
    }
    */
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    
}




@end
