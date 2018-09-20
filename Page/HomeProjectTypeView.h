//
//  HomeProjectTypeView.h
//  Page
//
//  Created by CMR on 3/13/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HomeProjectTypeViewDelegate <NSObject>

- (void)homeProjectTypeDidSelect:(id)projectTypeView;

@end

@interface HomeProjectTypeView : UIView

@property (assign, nonatomic) id<HomeProjectTypeViewDelegate> typeViewDelegate;

- (void)setTypeTitle:(NSString *)typeTitle;
- (NSString *)typeTitle;

- (void)setTypePreviewImages:(NSArray *)previewImages;

@end
