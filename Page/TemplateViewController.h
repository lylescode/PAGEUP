//
//  TemplateViewController.h
//  Page
//
//  Created by CMR on 12/3/14.
//  Copyright (c) 2014 Page. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkStepViewController.h"
#import "PresentViewController.h"
#import "ProjectResource.h"
#import "TemplateData.h"
//#import "TemplateSortViewController.h"

@protocol TemplateViewControllerDelegate <NSObject>

- (void)templateViewControllerDidCancel;
- (void)templateViewControllerDidSelect:(NSDictionary *)templateDictionary;

@end

@interface TemplateViewController : WorkStepViewController <UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (assign, nonatomic) id<TemplateViewControllerDelegate> templateDelegate;
- (void)updateSelectedPhotos;
- (void)updateSort;

@end
