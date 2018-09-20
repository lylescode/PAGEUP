//
//  AllAlbumsViewController.h
//  Page
//
//  Created by CMR on 5/15/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "PresentViewController.h"
#import <Photos/Photos.h>

@protocol AllAlbumsViewControllerDelegate <NSObject>

- (void)allAlbumsViewControllerDidSelectAssetFetchResult:(PHFetchResult *)assetFetchResult albumTitle:(NSString *)albumTitle;
- (void)allAlbumsViewControllerDidClose;

@end
@interface AllAlbumsViewController : PresentViewController <UITableViewDataSource, UITableViewDelegate>

- (void)selectCurrentAlbumTitle:(NSString *)title;

@property (assign, nonatomic) id<AllAlbumsViewControllerDelegate> allAlbumsDelegate;
@property (weak, nonatomic) IBOutlet UITableView *albumTableView;
@end
