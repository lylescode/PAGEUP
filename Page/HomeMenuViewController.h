//
//  HomeMenuViewController.h
//  Page
//
//  Created by CMR on 5/26/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "PresentViewController.h"

@protocol HomeMenuViewControllerDelegate <NSObject>

- (void)homeMenuViewControllerDidSelectAbout;
- (void)homeMenuViewControllerDidSelectShop;
- (void)homeMenuViewControllerDidClose;

@end

@interface HomeMenuViewController : PresentViewController <UITableViewDataSource, UITableViewDelegate>
{
    
}
@property (assign, nonatomic) id<HomeMenuViewControllerDelegate> homeMenuDelegate;

@end
