//
//  TextGroupEditViewController.h
//  Page
//
//  Created by CMR on 3/30/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PresentViewController.h"
#import "PTemplate.h"
#import "PTextGroupView.h"
#import "ProjectResource.h"
#import "FontToolboardView.h"
#import "ColorToolboardView.h"

@protocol TextGroupEditViewControllerDelegate <NSObject>

- (PTextGroupView *)textGroupEditViewControllerNeedPreviousTextGroup;
- (PTextGroupView *)textGroupEditViewControllerNeedNextTextGroup;
- (UIScrollView *)textGroupEditViewControllerNeedTemplateScrollView;
- (void)textGroupEditViewControllerNeedTemplateTranslation:(CGPoint)translation;
- (void)textGroupEditViewControllerDidClose;

@end

@interface TextGroupEditViewController : PresentViewController <UIGestureRecognizerDelegate, UIScrollViewDelegate, UITextViewDelegate, ToolboardViewDelegate, FontToolboardViewDelegate>
@property (assign, nonatomic) id<TextGroupEditViewControllerDelegate> textGroupEditDelegate;

- (void)editTextGroupWithTextGroupView:(PTextGroupView *)textGroupView backgroundColor:(UIColor *)backgroundColor;

@end
