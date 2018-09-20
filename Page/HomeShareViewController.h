//
//  HomeShareViewController.h
//  Page
//
//  Created by CMR on 5/13/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "PresentViewController.h"

@protocol HomeShareViewControllerDelegate <NSObject>

- (void)homeShareViewControllerDidSelectSharePhoto;
- (void)homeShareViewControllerDidSelectShareVideo;
- (void)homeShareViewControllerDidSelectSharePDF;
- (void)homeShareViewControllerDidClose;

@end

@interface HomeShareViewController : PresentViewController
{
    
}
@property (assign, nonatomic) id<HomeShareViewControllerDelegate> homeShareDelegate;

- (void)completeShare;
@end
