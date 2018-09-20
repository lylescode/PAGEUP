//
//  TemplateSortViewController.h
//  Page
//
//  Created by CMR on 5/14/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "PresentViewController.h"

@protocol TemplateSortViewControllerDelegate <NSObject>

- (void)templateSortViewControllerDidSelectSort:(NSString *)sortString;
- (void)templateSortViewControllerDidClose;

@end

@interface TemplateSortViewController : PresentViewController
@property (assign, nonatomic) id<TemplateSortViewControllerDelegate> templateSortDelegate;

- (void)currentTemplateSortString:(NSString *)sortString;

@end
