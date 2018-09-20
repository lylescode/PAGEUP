//
//  AssetLibraryRootListViewController.h
//  Page
//
//  Created by CMR on 11/20/14.
//  Copyright (c) 2014 Page. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "ProjectResource.h"
#import "Macro.h"

@protocol AssetLibraryRootListViewControllerDelegate <NSObject>

- (void)assetLibraryRootListViewControllerDidCancel;
- (void)assetLibraryRootListViewControllerDidDone;

@end

@interface AssetLibraryRootListViewController : UITableViewController

@property (assign, nonatomic) id<AssetLibraryRootListViewControllerDelegate> assetLibraryRootDelegate;

@property (weak, nonatomic) ProjectResource *projectResource;

@end
