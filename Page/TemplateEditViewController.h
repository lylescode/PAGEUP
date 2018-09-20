//
//  TemplateEditViewController.h
//  Page
//
//  Created by CMR on 12/12/14.
//  Copyright (c) 2014 Page. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PresentViewController.h"
#import "PTemplate.h"
#import "PUILabel.h"
#import "PPhotoView.h"
#import "ProjectResource.h"
#import "FontToolboardView.h"
#import "ColorToolboardView.h"
#import "AllPhotosViewController.h"

@protocol TemplateEditViewControllerDelegate <NSObject>

- (void)templateEditViewControllerDidClose;
- (void)templateEditViewControllerDidReplacePhoto:(PPhotoView *)photoView photoIndex:(NSInteger)photoIndex;

@end

@interface TemplateEditViewController : PresentViewController <UIGestureRecognizerDelegate, UIScrollViewDelegate, UITextViewDelegate, ToolboardViewDelegate, FontToolboardViewDelegate, AllPhotosViewControllerDelegate>

@property (assign, nonatomic) id<TemplateEditViewControllerDelegate> templateEditDelegate;

@property (weak, nonatomic) PTemplate *editingTemplateView;
@property (weak, nonatomic) ProjectResource *projectResource;

- (id)initWithTemplateView:(PTemplate *)templateView targetItem:(id)item;

@end
