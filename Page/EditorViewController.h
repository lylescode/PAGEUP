//
//  EditorViewController.h
//  Page
//
//  Created by CMR on 11/20/14.
//  Copyright (c) 2014 Page. All rights reserved.
//

#import "WorkStepViewController.h"
#import "ProjectResource.h"
#import "PTemplate.h"
#import "TemplateEditViewController.h"
#import "PhotoEditViewController.h"
#import "TextGroupEditViewController.h"
#import "HomeShareViewController.h"
#import "VideoPreviewViewController.h"

@protocol EditorViewControllerDelegate <NSObject>

- (void)editorViewControllerNeedTemplateEditTooltip;
- (void)editorViewControllerDidEdit;
- (void)editorViewControllerDidSwapPhoto;
- (void)editorViewControllerDidReplacePhoto;
- (void)editorViewControllerDidSaveProject;
- (void)editorViewControllerDidShareActivityWithImage:(UIImage *)image completion:(void(^)(void))callback;
- (void)editorViewControllerDidShareActivityWithPDFURL:(NSURL *)PDFURL completion:(void(^)(void))callback;
- (void)editorViewControllerDidShareActivityWithVideoURL:(NSURL *)videoURL completion:(void(^)(void))callback;

@end

@interface EditorViewController : WorkStepViewController <TemplateEditViewControllerDelegate, PhotoEditViewControllerDelegate, TextGroupEditViewControllerDelegate, HomeShareViewControllerDelegate, VideoPreviewViewControllerDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (assign, nonatomic) id<EditorViewControllerDelegate> editorDelegate;

- (void)updateSelectedPhotos;
- (void)updateTemplate;
- (UIImage *)resultImage;
- (UIImage *)previewImage;

- (void)applyGeniusDesign;
- (void)applyGeniusDesign:(BOOL)animated;
- (void)presentTemplateEditViewController;
- (void)presentShareViewController;

@end
