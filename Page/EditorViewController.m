//
//  EditorViewController.m
//  Page
//
//  Created by CMR on 11/20/14.
//  Copyright (c) 2014 Page. All rights reserved.
//

#import "EditorViewController.h"
#import "Constants.h"
#import "SnapshotView.h"
#import "PProgressView.h"
#import "UIColor+Matching.h"
#import "GeniusFontData.h"

#define GRIP_SENSITIVITY 6.0f


@interface EditorViewController ()
{
    BOOL visibleTemplateList;
    
    NSInteger currentPhotoCount;
    NSString *currentTemplateNibName;
    
    UIView *borderView;
    UIView *gripVerticalView;
    UIView *gripHorizontalView;
    
    SnapshotView *snapshotView;
    
    UITapGestureRecognizer *doubleTapGesture;
    UITapGestureRecognizer *tapGesture;
    UILongPressGestureRecognizer *longPressGesture;
    UIPanGestureRecognizer *panGesture;
    
    CGFloat GripSensitivity;
    
    NSInteger geniusColorSchemeIndex;
    NSInteger geniusIndex;
}
@property (weak, nonatomic) IBOutlet UIScrollView *templateScrollView;
@property (weak, nonatomic) IBOutlet UIButton *geniusButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIView *editorToolBar;
- (IBAction)editorToolBarAction:(id)sender;

@property (strong, nonatomic) PTemplate *workingTemplateView;
@property (weak, nonatomic) id selectedTemplateItem;
@property (weak, nonatomic) id draggedTemplateItem;

@property (strong, nonatomic) NSArray *gripItemFrameArray;

@property (strong, nonatomic) GeniusFontData *geniusFontData;

@property (strong, nonatomic) TemplateEditViewController *templateEditViewController;
@property (strong, nonatomic) PhotoEditViewController *photoEditViewController;
@property (strong, nonatomic) TextGroupEditViewController *textGroupEditViewController;

@property (strong, nonatomic) HomeShareViewController *homeShareViewController;
@property (strong, nonatomic) VideoPreviewViewController *videoPreviewViewController;

@property (strong, nonatomic) PProgressView *progressView;



- (void)hiddenEditorToolBar:(BOOL)hidden;

- (void)presentTemplateEditViewControllerWithProject:(ProjectResource *)project animated:(BOOL)animated;
- (void)dismissTemplateEditViewController:(BOOL)animated;

- (void)presentPhotoEditViewControllerWithProject:(ProjectResource *)project animated:(BOOL)animated;
- (void)dismissPhotoEditViewController:(BOOL)animated;

- (void)presentTextGroupEditViewControllerWithProject:(ProjectResource *)project animated:(BOOL)animated;
- (void)dismissTextGroupEditViewController:(BOOL)animated;

- (void)presentHomeShareViewControllerWithProject:(ProjectResource *)project animated:(BOOL)animated;
- (void)dismissHomeShareViewController:(BOOL)animated;

- (void)presentVideoPreviewViewControllerWithProject:(ProjectResource *)project animated:(BOOL)animated;
- (void)dismissVideoPreviewViewController:(BOOL)animated;

- (void)sharePhoto;
- (void)sharePDF;
- (void)shareVideo;
- (void)completeShareProject;

- (void)showProgress;
- (void)updateProgress:(CGFloat)progress;
- (void)completeProgress;



- (void)changePhotos;
- (void)changeTemplate;

- (void)initTempalteZoom;
- (void)createTemplateView;
- (void)removeTemplateView;

- (void)selectItem:(id)targetItem;
- (void)selectItem:(id)targetItem withEditor:(BOOL)withEditor;
- (void)deselectItem;
- (void)hiddenBorder:(BOOL)hidden;

- (SnapshotView *)snapshotFromView:(UIView *)inputView;
- (BOOL)editableWithItem:(id)item;
- (BOOL)draggableWithItem:(id)item;

- (void)panGesture:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer;
- (void)doubleTapGesture:(UITapGestureRecognizer *)gestureRecognizer;
- (void)longPressGesture:(UIPanGestureRecognizer *)gestureRecognizer;

@end

@implementation EditorViewController
@synthesize editorDelegate;

static CGSize TemplateViewSize;

//static CGPoint TemplateViewCenter;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    borderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    borderView.userInteractionEnabled = NO;
    borderView.layer.borderColor = [UIColor colorWithRed:0.947 green:0.277 blue:0.109 alpha:1].CGColor;
    borderView.layer.borderWidth = 2;
    borderView.backgroundColor = [UIColor clearColor];
    borderView.hidden = YES;
    [self.view addSubview:borderView];
    
    gripVerticalView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    gripVerticalView.userInteractionEnabled = NO;
    gripVerticalView.backgroundColor = [UIColor colorWithRed:0.947 green:0.277 blue:0.109 alpha:1];
    gripVerticalView.hidden = YES;
    [self.view addSubview:gripVerticalView];
    
    gripHorizontalView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    gripHorizontalView.userInteractionEnabled = NO;
    gripHorizontalView.backgroundColor = [UIColor colorWithRed:0.947 green:0.277 blue:0.109 alpha:1];
    gripHorizontalView.hidden = YES;
    [self.view addSubview:gripHorizontalView];
    
    self.templateScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    //self.templateScrollView.scrollEnabled = NO;
    
}
- (void)dealloc
{
    [self removeTemplateView];
    [borderView removeFromSuperview];
    self.gripItemFrameArray = nil;
    self.geniusFontData = nil;
    
    if(self.templateEditViewController) {
        [self.templateEditViewController.view removeFromSuperview];
        self.templateEditViewController = nil;
    }
    if(self.photoEditViewController) {
        [self.photoEditViewController.view removeFromSuperview];
        self.photoEditViewController = nil;
    }
    if(self.textGroupEditViewController) {
        [self.textGroupEditViewController.view removeFromSuperview];
        self.textGroupEditViewController = nil;
    }
    if(self.homeShareViewController) {
        [self.homeShareViewController.view removeFromSuperview];
        self.homeShareViewController = nil;
    }
    if(self.videoPreviewViewController) {
        [self.videoPreviewViewController.view removeFromSuperview];
        self.videoPreviewViewController = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    //CGRect screenBounds = [[UIScreen mainScreen] bounds];
    //NSLog(@"screenBounds : %@", NSStringFromCGRect(screenBounds));
    
    CGSize newTemplateViewSize = CGSizeMake(ceil(self.templateScrollView.frame.size.width * 2), ceil(self.templateScrollView.frame.size.height * 2));
    if(CGSizeEqualToSize(newTemplateViewSize, TemplateViewSize) == NO) {
        TemplateViewSize = newTemplateViewSize;
        [self initTempalteZoom];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    TemplateViewSize = CGSizeMake(ceil(self.templateScrollView.frame.size.width * 2), ceil(self.templateScrollView.frame.size.height * 2));
}



- (void)willActivateWork
{
    [super willActivateWork];
    
}

- (void)activateWork
{
    [super activateWork];
    
    if(self.projectResource.templateDictionary && !self.workingTemplateView) {
        [self createTemplateView];
    }
    [self hiddenEditorToolBar:NO];
}




- (IBAction)editorToolBarAction:(id)sender
{
    if(sender == self.geniusButton) {
        [self applyGeniusDesign];
    } else if(sender == self.editButton) {
        [self presentTemplateEditViewController];
    } else if(sender == self.shareButton) {
        [self presentShareViewController];
    }
}

- (void)deactivateWork
{
    [super deactivateWork];
    
    [self hiddenBorder:YES];
    
    self.selectedTemplateItem = nil;
    self.draggedTemplateItem = nil;
    [self.templateScrollView setZoomScale:self.templateScrollView.minimumZoomScale animated:YES];
    
    [self hiddenEditorToolBar:YES];
    /*
    [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.toolView.transform = CGAffineTransformMakeTranslation(0, self.toolView.frame.size.height);
                         self.toolView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         if(finished) {
                             
                         }
                     }];
     */
}

- (void)prepareForSaveProject
{
    self.projectResource.projectDictionary = [self.workingTemplateView updateProjectDictionary];
    self.projectResource.templateTextDictionary = [self.workingTemplateView templateTextDictionary];
}

- (void)updateSelectedPhotos
{
    if(self.projectResource.templateDictionary) {
        
        if(self.projectResource.photoArray.count != currentPhotoCount) {
            
            // 사진수가 달라지더라도 기존 템플릿 유지하도록 수정
            //self.projectResource.templateDictionary = nil;
            
            NSLog(@"현재 템플릿 삭제하기");
            [self removeTemplateView];
            
        } else if(self.projectResource.updatedPhotos) {
            
            NSLog(@"사진만 업데이트");
            if(self.workingTemplateView) {
                [self.workingTemplateView setPhotosWithPhotoArray:self.projectResource.photoArray];
            } else {
                [self createTemplateView];
            }
        } else {
            
            NSLog(@"변경 없음");
        }
        
        self.projectResource.updatedPhotos = NO;
    }
}
- (void)updateTemplate
{
    if([self.projectResource.templateDictionary[@"NibName"] isEqualToString:currentTemplateNibName] == NO) {
        self.projectResource.projectDictionary = nil;
        [self createTemplateView];
    }
    
}

- (UIImage *)resultImage
{
    if(self.projectResource.photoArray.count == 0) {
        return nil;
    }
    
    if(self.projectResource.templateDictionary == nil) {
        return nil;
    }
    self.projectResource.projectDictionary = [self.workingTemplateView updateProjectDictionary];
    
    return self.projectResource.resultImage;
}


- (UIImage *)previewImage
{
    if(self.projectResource.photoArray.count == 0) {
        return nil;
    }
    
    if(self.projectResource.templateDictionary == nil) {
        return nil;
    }
    
    CGFloat currentZoomScale = self.templateScrollView.zoomScale;
    [self.templateScrollView setZoomScale:1 animated:NO];
    
    UIGraphicsBeginImageContextWithOptions(self.workingTemplateView.frame.size, YES, [[UIScreen mainScreen] scale]);
    [self.workingTemplateView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *previewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.templateScrollView setZoomScale:currentZoomScale animated:NO];
    return previewImage;
}


- (NSString *)languageForString:(NSString *)text
{
    if (text.length < 100) {
        
        return (NSString *)CFBridgingRelease(CFStringTokenizerCopyBestStringLanguage((CFStringRef)text, CFRangeMake(0, text.length)));
    } else {
        
        return (NSString *)CFBridgingRelease(CFStringTokenizerCopyBestStringLanguage((CFStringRef)text, CFRangeMake(0, 100)));
    }
}

- (void)applyGeniusDesign
{
    [self applyGeniusDesign:YES];
}
- (void)applyGeniusDesign:(BOOL)animated
{
    if(!self.geniusFontData) {
        GeniusFontData *fontData = [[GeniusFontData alloc] init];
        self.geniusFontData = fontData;
    }
    
    NSArray *colorSchemes = [self.projectResource photoColorSchemes];
    if(geniusColorSchemeIndex > colorSchemes.count - 1) {
        geniusColorSchemeIndex = 0;
        geniusIndex = 0;
    }
    NSDictionary *colorScheme = [colorSchemes objectAtIndex:geniusColorSchemeIndex];
    
    //NSLog(@"colorScheme : %@" , colorScheme);
    
    UIColor *backgroundColor;
    UIColor *primaryTextColor, *secondaryTextColor;
    
    NSMutableArray *backgroundViews = [NSMutableArray array];
    [backgroundViews addObject:self.workingTemplateView.backgroundView];
    
    NSMutableArray *defaultLabels = [NSMutableArray array];
    NSMutableArray *defaultViews = [NSMutableArray array];
    
    NSMutableArray *primaryLabels = [NSMutableArray array];
    NSMutableArray *secondaryLabels = [NSMutableArray array];
    
    NSMutableArray *primaryViews = [NSMutableArray array];
    NSMutableArray *secondaryViews = [NSMutableArray array];
    
    UIColor *titleLabelColor = nil;
    UIFont *titleOriginFont = [UIFont systemFontOfSize:12];
    UIColor *originalBackgroundColor = self.workingTemplateView.originalBackgroundColor;
    
    PUILabel *titleLabel = nil;
    
    NSMutableArray *photoFrameValues = [NSMutableArray array];
    for(PPhotoView *photoView in self.workingTemplateView.photoViewArray) {
        [photoFrameValues addObject:[NSValue valueWithCGRect:photoView.frame]];
    }
    NSMutableArray *flatFrameValues = [NSMutableArray array];
    for(PFlatView *flatView in self.workingTemplateView.flatViewArray) {
        if(!flatView.viewBorderWidth) {
            [flatFrameValues addObject:[NSValue valueWithCGRect:flatView.frame]];
        }
    }
    
    for(PTextGroupView *textGroupView in self.workingTemplateView.textGroupViewArray) {
        
        for(id subItem in [textGroupView subviews]) {
            if([subItem isKindOfClass:[PUILabel class]]) {
                PUILabel *label = (PUILabel *)subItem;
                
                if([label.textType isEqualToString:@"title"]) {
                    titleLabelColor = label.originalTextColor;
                    titleLabel = label;
                    titleOriginFont = titleLabel.originFont;
                } else if([label.textType isEqualToString:@"subtitle"] && titleLabelColor == nil) {
                    titleLabelColor = label.originalTextColor;
                }
                
            }
        }
    }
    
    
    NSLog(@"%li / %li 스키마 셋", (long)geniusColorSchemeIndex, (long)colorSchemes.count - 1);
    NSLog(@"colorScheme : %@", colorScheme);
    NSLog(@" %li 스타일 ", (long)geniusIndex);
    switch (geniusIndex) {
        case 0:
            backgroundColor = colorScheme[@"backgroundColor"];
            primaryTextColor = colorScheme[@"primaryTextColor"];
            secondaryTextColor = colorScheme[@"primaryTextColor"];
            break;
        case 1:
            backgroundColor = colorScheme[@"secondaryTextColor"];
            primaryTextColor = colorScheme[@"primaryTextColor"];
            secondaryTextColor = colorScheme[@"primaryTextColor"];
            break;
        case 2:
            backgroundColor = colorScheme[@"primaryTextColor"];
            primaryTextColor = colorScheme[@"backgroundColor"];
            secondaryTextColor = colorScheme[@"backgroundColor"];
            break;
        case 3:
            backgroundColor = colorScheme[@"backgroundColor"];
            primaryTextColor = colorScheme[@"secondaryTextColor"];
            secondaryTextColor = colorScheme[@"secondaryTextColor"];
            break;
        case 4:
            backgroundColor = originalBackgroundColor;
            primaryTextColor = colorScheme[@"primaryTextColor"];
            secondaryTextColor = colorScheme[@"primaryTextColor"];
            break;
            
        default:
            backgroundColor = originalBackgroundColor;
            primaryTextColor = titleLabelColor;
            secondaryTextColor = nil;
            break;
    }
    
    
    CGFloat r,g,b,a;
    UIColor *inverseColor;
    
    [backgroundColor getRed:&r green:&g blue:&b alpha:&a];
    inverseColor = [UIColor colorWithRed:1.-r green:1.-g blue:1.-b alpha:1];
    NSError *error;
    
    if([primaryTextColor matchesColor:backgroundColor error:&error]) {
        NSLog(@"primary color inverse");
        primaryTextColor = inverseColor;
    }
    if(secondaryTextColor && [secondaryTextColor matchesColor:backgroundColor error:&error]) {
        NSLog(@"secondary color inverse");
        secondaryTextColor = inverseColor;
    }
    
    NSLog(@"backgroundColor : %@", backgroundColor.CGColor);
    NSLog(@"primaryTextColor : %@", primaryTextColor.CGColor);
    NSLog(@"secondaryTextColor : %@", secondaryTextColor.CGColor);
    
    geniusIndex++;
    
    NSInteger maxIndex = (geniusColorSchemeIndex == colorSchemes.count - 1) ? 5 : 4;
    if(geniusIndex > maxIndex) {
        geniusColorSchemeIndex++;
        geniusIndex = 0;
    }
    
    NSArray *targetViews = [self.workingTemplateView.loadedNibView subviews];
    
    NSString *titleFontName = [self.geniusFontData.defaultTitleFonts objectAtIndex:(arc4random() % self.geniusFontData.defaultTitleFonts.count)];
    NSString *titleDateFontName = [self.geniusFontData.defaultTitleFonts objectAtIndex:(arc4random() % self.geniusFontData.defaultTitleFonts.count)];
    NSString *fontName = [self.geniusFontData.defaultContentFonts objectAtIndex:(arc4random() % self.geniusFontData.defaultContentFonts.count)];
    /*
     NSString *photoTitleFontName = [self.geniusFontData.defaultContentFonts objectAtIndex:(arc4random() % self.geniusFontData.defaultContentFonts.count)];
     NSString *photoDesciptionFontName = [self.geniusFontData.defaultContentFonts objectAtIndex:(arc4random() % self.geniusFontData.defaultContentFonts.count)];
     
     NSString *footerFontName = [self.geniusFontData.defaultContentFonts objectAtIndex:(arc4random() % self.geniusFontData.defaultContentFonts.count)];
     NSString *dateFontName = [self.geniusFontData.defaultContentFonts objectAtIndex:(arc4random() % self.geniusFontData.defaultContentFonts.count)];
     */
    NSString *koTitleFontName = [self.geniusFontData.koreanTitleFonts objectAtIndex:(arc4random() % self.geniusFontData.koreanTitleFonts.count)];
    NSString *koTitleDateFontName = [self.geniusFontData.koreanTitleFonts objectAtIndex:(arc4random() % self.geniusFontData.koreanTitleFonts.count)];
    NSString *koFontName = [self.geniusFontData.koreanContentFonts objectAtIndex:(arc4random() % self.geniusFontData.koreanContentFonts.count)];
    /*
     NSString *koPhotoTitleFontName = [self.geniusFontData.koreanContentFonts objectAtIndex:(arc4random() % self.geniusFontData.koreanContentFonts.count)];
     NSString *koPhotoDesciptionFontName = [self.geniusFontData.koreanContentFonts objectAtIndex:(arc4random() % self.geniusFontData.koreanContentFonts.count)];
     NSString *koFooterFontName = [self.geniusFontData.koreanContentFonts objectAtIndex:(arc4random() % self.geniusFontData.koreanContentFonts.count)];
     NSString *koDateFontName = [self.geniusFontData.koreanContentFonts objectAtIndex:(arc4random() % self.geniusFontData.koreanContentFonts.count)];
     */
    
    NSLog(@"titleOriginFont : %@", titleOriginFont);
    for(UIView *targetView in targetViews) {
        
        if(targetView.hidden == NO) {
            if([targetView isKindOfClass:[PTextGroupView class]]) {
                PTextGroupView *textGroupView = (PTextGroupView *)targetView;
                
                BOOL inFlatView = NO;
                BOOL useDefaultColor = NO;
                
                for(NSValue *flatFrameValue in flatFrameValues) {
                    CGRect flatFrame = flatFrameValue.CGRectValue;
                    if(CGRectContainsPoint(flatFrame, textGroupView.center)) {
                        inFlatView = YES;
                        break;
                    }
                }
                if(!inFlatView) {
                    for(NSValue *photoFrameValue in photoFrameValues) {
                        CGRect photoFrame = photoFrameValue.CGRectValue;
                        if(CGRectContainsPoint(photoFrame, textGroupView.center)) {
                            useDefaultColor = YES;
                            break;
                        }
                    }
                }
                
                for(id subItem in [textGroupView subviews]) {
                    if([subItem isKindOfClass:[PUILabel class]]) {
                        PUILabel *label = (PUILabel *)subItem;
                        
                        if(useDefaultColor) {
                            [defaultLabels addObject:label];
                        } else if([label.textType isEqualToString:@"title"]) {
                            [primaryLabels addObject:label];
                        } else {
                            if([label.originalTextColor matchesColor:titleLabelColor error:&error]) {
                                [primaryLabels addObject:label];
                            }
                            else {
                                [secondaryLabels addObject:label];
                            }
                            
                        }
                        if([[self languageForString:label.text] isEqualToString:@"ko"]) {
                            //koFontName = [self.geniusFontData.koreanContentFonts objectAtIndex:(arc4random() % self.geniusFontData.koreanContentFonts.count)];
                            if([label.textType isEqualToString:@"title"]) {
                                [label setFontName:koTitleFontName];
                            } else if([label.originFont.fontName isEqualToString:titleOriginFont.fontName] && label.originFont.pointSize == titleOriginFont.pointSize) {
                                [label setFontName:koTitleFontName];
                            } else if([label.textType isEqualToString:@"subtitle"] && !titleLabel) {
                                [label setFontName:koTitleFontName];
                            } else if([label.textType isEqualToString:@"footer"]) {
                                [label setFontName:koFontName];
                            } else if([label.textType isEqualToString:@"photoTitle"]) {
                                [label setFontName:koFontName];
                            } else if([label.textType isEqualToString:@"photoDescription"]) {
                                [label setFontName:koFontName];
                            } else if([label.textType isEqualToString:@"date"] || [label.textType isEqualToString:@"datetodate"]) {
                                [label setFontName:koFontName];
                            } else if([label.textType isEqualToString:@"MM"] || [label.textType isEqualToString:@"dd"]) {
                                [label setFontName:koTitleDateFontName];
                            } else {
                                [label setFontName:koFontName];
                            }
                        }
                        else {
                            //fontName = [self.geniusFontData.defaultContentFonts objectAtIndex:(arc4random() % self.geniusFontData.defaultContentFonts.count)];
                            
                            if([label.textType isEqualToString:@"title"]) {
                                [label setFontName:titleFontName];
                            } else if([label.originFont.fontName isEqualToString:titleOriginFont.fontName] && label.originFont.pointSize == titleOriginFont.pointSize) {
                                [label setFontName:titleFontName];
                            } else if([label.textType isEqualToString:@"subtitle"] && !titleLabel) {
                                [label setFontName:titleFontName];
                            } else if([label.textType isEqualToString:@"footer"]) {
                                [label setFontName:fontName];
                            } else if([label.textType isEqualToString:@"photoTitle"]) {
                                [label setFontName:fontName];
                            } else if([label.textType isEqualToString:@"photoDescription"]) {
                                [label setFontName:fontName];
                            } else if([label.textType isEqualToString:@"date"] || [label.textType isEqualToString:@"datetodate"]) {
                                [label setFontName:fontName];
                            } else if([label.textType isEqualToString:@"MM"] || [label.textType isEqualToString:@"dd"]) {
                                [label setFontName:titleDateFontName];
                            } else {
                                [label setFontName:fontName];
                            }
                        }
                    }
                }
                
            } else if([targetView isKindOfClass:[PImageView class]]) {
                PImageView *imageView = (PImageView *)targetView;
                
                BOOL useDefaultColor = NO;
                
                if(imageView.relationBackground) {
                    [backgroundViews addObject:imageView];
                }
                
            } else if([targetView isKindOfClass:[PFlatView class]]) {
                PFlatView *flatView = (PFlatView *)targetView;
                
                BOOL flatIsLine = [flatView isLine];
                BOOL useDefaultColor = NO;
                
                if(flatIsLine) {
                    for(NSValue *photoFrameValue in photoFrameValues) {
                        CGRect photoFrame = photoFrameValue.CGRectValue;
                        if(CGRectContainsPoint(photoFrame, flatView.center)) {
                            useDefaultColor = YES;
                            break;
                        }
                    }
                }
                
                
                
                if(useDefaultColor) {
                    NSLog(@"FlatView defaultViews 에 추가");
                    [defaultViews addObject:flatView];
                }
                else if(flatView.relationBackground) {
                    [backgroundViews addObject:flatView];
                }
                else if([targetView isKindOfClass:[PCubeView class]]) {
                    [backgroundViews addObject:flatView];
                }
                else if([flatView.originalColor matchesColor:titleLabelColor error:&error]) {
                    [primaryViews addObject:flatView];
                }
                else {
                    [secondaryViews addObject:flatView];
                }
                
            } else {
            }
        }
    }
    
    CGFloat delayDuration = 0;
    
    
    for(PUILabel *defaultLabel in defaultLabels) {
        
        if(animated) {
            CGFloat opacity = defaultLabel.alpha;
            defaultLabel.alpha = 0;
            [UIView animateWithDuration:0.45
                                  delay:delayDuration
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 defaultLabel.alpha = opacity;
                             }
                             completion:^(BOOL finished) {
                             }];
        }
        delayDuration += 0.06;
    }
    
    delayDuration = 0;
    for(PUILabel *primaryLabel in primaryLabels) {
        primaryLabel.textColor = primaryTextColor;
        
        if(animated) {
            CGFloat opacity = primaryLabel.alpha;
            primaryLabel.alpha = 0;
            [UIView animateWithDuration:0.45
                                  delay:delayDuration
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 primaryLabel.alpha = opacity;
                             }
                             completion:^(BOOL finished) {
                             }];
        }
        delayDuration += 0.06;
    }
    
    
    
    delayDuration = 0;
    for(PUILabel *secondaryLabel in secondaryLabels) {
        if(!secondaryTextColor) {
            
            secondaryLabel.textColor = secondaryLabel.originalTextColor;
            
            if(animated) {
                CGFloat opacity = secondaryLabel.alpha;
                secondaryLabel.alpha = 0;
                [UIView animateWithDuration:0.45
                                      delay:delayDuration
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     secondaryLabel.alpha = opacity;
                                 }
                                 completion:^(BOOL finished) {
                                 }];
            }
        } else {
            secondaryLabel.textColor = secondaryTextColor;
            
            if(animated) {
                CGFloat opacity = secondaryLabel.alpha;
                secondaryLabel.alpha = 0;
                [UIView animateWithDuration:0.45
                                      delay:delayDuration
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     secondaryLabel.alpha = opacity;
                                 }
                                 completion:^(BOOL finished) {
                                 }];
            }
        }
        delayDuration += 0.06;
    }
    
    if(titleLabel) {
        for(UIView *defaultView in defaultViews) {
            
            if([defaultView isKindOfClass:[PFlatView class]]) {
                PFlatView *flatView = (PFlatView *)defaultView;
                if(flatView.viewBorderWidth > 0) {
                    flatView.viewBorderColor = titleLabel.textColor;
                    
                    if(animated) {
                        [UIView animateWithDuration:0.35
                                              delay:delayDuration
                                            options:UIViewAnimationOptionCurveEaseInOut
                                         animations:^{
                                             flatView.layer.borderColor = titleLabel.textColor.CGColor;
                                         }
                                         completion:^(BOOL finished) {
                                         }];
                    } else {
                        flatView.layer.borderColor = titleLabel.textColor.CGColor;
                    }
                } else {
                    if(animated) {
                        [UIView animateWithDuration:0.35
                                              delay:delayDuration
                                            options:UIViewAnimationOptionCurveEaseInOut
                                         animations:^{
                                             defaultView.backgroundColor = titleLabel.textColor;
                                         }
                                         completion:^(BOOL finished) {
                                         }];
                    } else {
                        defaultView.backgroundColor = titleLabel.textColor;
                    }
                }
            }
        }
    }
    delayDuration = 0;
    for(UIView *backgroundView in backgroundViews) {
        
        if([backgroundView isKindOfClass:[PImageView class]]) {
            PImageView *imageView = (PImageView *)backgroundView;
            
            if(animated) {
                [UIView transitionWithView:imageView duration:0.35 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    imageView.imageColor = backgroundColor;
                } completion:^(BOOL finished) {
                }];
            } else {
                imageView.imageColor = backgroundColor;
            }
        } else if([backgroundView isKindOfClass:[PCubeView class]]) {
            PCubeView *cubeView = (PCubeView *)backgroundView;
            
            if(animated) {
                [UIView transitionWithView:cubeView duration:0.35 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    cubeView.shapeColor = backgroundColor;
                    [cubeView setNeedsDisplay];
                } completion:^(BOOL finished) {
                }];
            } else {
                cubeView.shapeColor = backgroundColor;
                [cubeView setNeedsDisplay];
            }
            
        } else {
            if(animated) {
                [UIView animateWithDuration:0.35
                                      delay:delayDuration
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     backgroundView.backgroundColor = backgroundColor;
                                 }
                                 completion:^(BOOL finished) {
                                 }];
            } else {
                backgroundView.backgroundColor = backgroundColor;
            }
        }
    }
    for(UIView *primaryView in primaryViews) {
        
        if([primaryView isKindOfClass:[PFlatView class]]) {
            PFlatView *flatView = (PFlatView *)primaryView;
            if(flatView.viewBorderWidth > 0) {
                flatView.viewBorderColor = primaryTextColor;
                
                if(animated) {
                    [UIView animateWithDuration:0.35
                                          delay:delayDuration
                                        options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         flatView.layer.borderColor = primaryTextColor.CGColor;
                                     }
                                     completion:^(BOOL finished) {
                                     }];
                } else {
                    flatView.layer.borderColor = primaryTextColor.CGColor;
                }
            } else {
                if(animated) {
                    [UIView animateWithDuration:0.35
                                          delay:delayDuration
                                        options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         primaryView.backgroundColor = primaryTextColor;
                                     }
                                     completion:^(BOOL finished) {
                                     }];
                } else {
                    primaryView.backgroundColor = primaryTextColor;
                }
            }
        } else {
            if(animated) {
                [UIView animateWithDuration:0.35
                                      delay:delayDuration
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     primaryView.backgroundColor = primaryTextColor;
                                 }
                                 completion:^(BOOL finished) {
                                 }];
            } else {
                primaryView.backgroundColor = primaryTextColor;
            }
        }
        delayDuration += 0.06;
        
    }
    for(UIView *secondaryView in secondaryViews) {
        
        if(!secondaryTextColor) {
            if([secondaryView isKindOfClass:[PFlatView class]]) {
                PFlatView *flatView = (PFlatView *)secondaryView;
                if(flatView.viewBorderWidth > 0) {
                    flatView.viewBorderColor = flatView.originalColor;
                    
                    if(animated) {
                        [UIView animateWithDuration:0.35
                                              delay:delayDuration
                                            options:UIViewAnimationOptionCurveEaseInOut
                                         animations:^{
                                             flatView.layer.borderColor = flatView.originalColor.CGColor;
                                         }
                                         completion:^(BOOL finished) {
                                         }];
                    } else {
                        flatView.layer.borderColor = flatView.originalColor.CGColor;
                    }
                } else {
                    if(animated) {
                        [UIView animateWithDuration:0.35
                                              delay:delayDuration
                                            options:UIViewAnimationOptionCurveEaseInOut
                                         animations:^{
                                             flatView.backgroundColor = flatView.originalColor;
                                         }
                                         completion:^(BOOL finished) {
                                         }];
                    } else {
                        flatView.backgroundColor = flatView.originalColor;
                    }
                }
            }
        } else {
            
            if([secondaryView isKindOfClass:[PFlatView class]]) {
                PFlatView *flatView = (PFlatView *)secondaryView;
                if(flatView.viewBorderWidth > 0) {
                    flatView.viewBorderColor = secondaryTextColor;
                    
                    if(animated) {
                        [UIView animateWithDuration:0.35
                                              delay:delayDuration
                                            options:UIViewAnimationOptionCurveEaseInOut
                                         animations:^{
                                             flatView.layer.borderColor = secondaryTextColor.CGColor;
                                         }
                                         completion:^(BOOL finished) {
                                         }];
                    } else {
                        flatView.layer.borderColor = secondaryTextColor.CGColor;
                    }
                } else {
                    
                    if(animated) {
                        [UIView animateWithDuration:0.35
                                              delay:delayDuration
                                            options:UIViewAnimationOptionCurveEaseInOut
                                         animations:^{
                                             flatView.backgroundColor = secondaryTextColor;
                                         }
                                         completion:^(BOOL finished) {
                                         }];
                    } else {
                        flatView.backgroundColor = secondaryTextColor;
                    }
                }
            } else {
                if(animated) {
                    [UIView animateWithDuration:0.35
                                          delay:delayDuration
                                        options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         secondaryView.backgroundColor = secondaryTextColor;
                                     }
                                     completion:^(BOOL finished) {
                                     }];
                } else {
                    secondaryView.backgroundColor = secondaryTextColor;
                }
            }
        }
        delayDuration += 0.06;
    }
    
    
    
}


- (void)hiddenEditorToolBar:(BOOL)hidden
{
    if(hidden) {
        
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.editorToolBar.transform = CGAffineTransformMakeTranslation(0, self.editorToolBar.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             if(finished) {
                                 
                             }
                         }];
    } else {
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.editorToolBar.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished){
                             if(finished) {
                                 
                             }
                         }];
    }
}

- (void)presentTemplateEditViewController
{
    [self presentTemplateEditViewControllerWithProject:self.projectResource animated:YES];
}

- (void)presentShareViewController
{
    [self presentHomeShareViewControllerWithProject:self.projectResource animated:YES];
}


- (void)presentTemplateEditViewControllerWithProject:(ProjectResource *)project animated:(BOOL)animated
{
    if(self.templateEditViewController) {
        return;
    }
    [self.workStepDelegate workStepViewControllerNeedDisableCommon:YES];
    
    TemplateEditViewController *templateEditVC = [[TemplateEditViewController alloc] initWithTemplateView:self.workingTemplateView targetItem:self.selectedTemplateItem];
    templateEditVC.templateEditDelegate = self;
    templateEditVC.projectResource = project;
    templateEditVC.view.frame = self.view.bounds;
    
    [self.view addSubview:templateEditVC.view];
    self.templateEditViewController = templateEditVC;
    
    [self.templateEditViewController presentViewControllerAnimated:animated
                                                        completion:nil];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL shown = [[defaults objectForKey:TOOLTIP_TEMPLATEEDIT_KEY] boolValue];
    
    if(!shown) {
        double delayInSeconds = 1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.editorDelegate editorViewControllerNeedTemplateEditTooltip];
        });
    }
    
}
- (void)dismissTemplateEditViewController:(BOOL)animated
{
    [self.workStepDelegate workStepViewControllerNeedDisableCommon:NO];
    
    [self.templateEditViewController dismissViewControllerAnimated:animated
                                                        completion:^{
                                                            [self.templateEditViewController.view removeFromSuperview];
                                                            self.templateEditViewController = nil;
                                                        }];
}


- (void)presentPhotoEditViewControllerWithProject:(ProjectResource *)project animated:(BOOL)animated
{
    if([self.selectedTemplateItem isKindOfClass:[PPhotoView class]] == NO) {
        return;
    }
    if(self.photoEditViewController) {
        return;
    }
    
    [self.workStepDelegate workStepViewControllerNeedDisableCommon:YES];

    PhotoEditViewController *photoEditVC = [[PhotoEditViewController alloc] init];
    photoEditVC.projectResource = self.projectResource;
    photoEditVC.photoEditDelegate = self;
    photoEditVC.view.frame = self.view.bounds;
    [photoEditVC editPhotoWithPhotoView:(PPhotoView *)self.selectedTemplateItem photoIndex:[self.workingTemplateView.photoViewArray indexOfObject:self.selectedTemplateItem]];
    
    [self.view addSubview:photoEditVC.view];
    self.photoEditViewController = photoEditVC;
    
    [self.photoEditViewController presentViewControllerAnimated:animated
                                                     completion:nil];
}
- (void)dismissPhotoEditViewController:(BOOL)animated
{
    [self.workStepDelegate workStepViewControllerNeedDisableCommon:NO];
    
    [self.photoEditViewController dismissViewControllerAnimated:animated
                                                     completion:^{
                                                         [self.photoEditViewController.view removeFromSuperview];
                                                         self.photoEditViewController = nil;
                                                     }];
}


- (void)presentTextGroupEditViewControllerWithProject:(ProjectResource *)project animated:(BOOL)animated
{
    if([self.selectedTemplateItem isKindOfClass:[PTextGroupView class]] == NO) {
        return;
    }
    if(self.textGroupEditViewController) {
        return;
    }
    
    [self.workStepDelegate workStepViewControllerNeedDisableCommon:YES];
    
    TextGroupEditViewController *textGroupEditVC = [[TextGroupEditViewController alloc] init];
    textGroupEditVC.textGroupEditDelegate = self;
    textGroupEditVC.view.frame = self.view.bounds;
    [textGroupEditVC editTextGroupWithTextGroupView:(PTextGroupView *)self.selectedTemplateItem backgroundColor:self.workingTemplateView.backgroundView.backgroundColor];
    
    [self.view addSubview:textGroupEditVC.view];
    self.textGroupEditViewController = textGroupEditVC;
    
    [self.textGroupEditViewController presentViewControllerAnimated:animated
                                                     completion:nil];
}
- (void)dismissTextGroupEditViewController:(BOOL)animated
{
    [self.workStepDelegate workStepViewControllerNeedDisableCommon:NO];
    
    [self.textGroupEditViewController dismissViewControllerAnimated:animated
                                                     completion:^{
                                                         [self.textGroupEditViewController.view removeFromSuperview];
                                                         self.textGroupEditViewController = nil;
                                                     }];
}


- (void)presentHomeShareViewControllerWithProject:(ProjectResource *)project animated:(BOOL)animated
{
    if(self.homeShareViewController) {
        return;
    }
    
    [self prepareForSaveProject];
    //[self.editorDelegate editorViewControllerDidSaveProject];
    
    [self.workStepDelegate workStepViewControllerNeedDisableCommon:YES];
    
    HomeShareViewController *homeShareVC = [[HomeShareViewController alloc] init];
    homeShareVC.homeShareDelegate = self;
    homeShareVC.view.frame = self.view.bounds;
    
    [self.view addSubview:homeShareVC.view];
    self.homeShareViewController = homeShareVC;
    
    [self.homeShareViewController presentViewControllerAnimated:animated
                                                     completion:nil];
}
- (void)dismissHomeShareViewController:(BOOL)animated
{
    [self.workStepDelegate workStepViewControllerNeedDisableCommon:NO];
    [self.homeShareViewController dismissViewControllerAnimated:animated
                                                     completion:^{
                                                         [self.homeShareViewController.view removeFromSuperview];
                                                         self.homeShareViewController = nil;
                                                     }];
}
- (void)presentVideoPreviewViewControllerWithProject:(ProjectResource *)project animated:(BOOL)animated
{
    if(self.videoPreviewViewController) {
        return;
    }
    if(!project) {
        return;
    }
    [self.workStepDelegate workStepViewControllerNeedDisableCommon:YES];
    
    VideoPreviewViewController *videoPreviewVC = [[VideoPreviewViewController alloc] init];
    videoPreviewVC.videoPreviewDelegate = self;
    videoPreviewVC.projectResource = project;
    videoPreviewVC.view.frame = self.view.bounds;
    
    [self.view addSubview:videoPreviewVC.view];
    self.videoPreviewViewController = videoPreviewVC;
    
    [self.videoPreviewViewController presentViewControllerAnimated:animated completion:nil];
    
}
- (void)dismissVideoPreviewViewController:(BOOL)animated
{
    
    if(!self.homeShareViewController) {
        [self.workStepDelegate workStepViewControllerNeedDisableCommon:NO];
    }
    
    [self.videoPreviewViewController dismissViewControllerAnimated:animated
                                                        completion:^{
                                                            [self.videoPreviewViewController.view removeFromSuperview];
                                                            self.videoPreviewViewController = nil;
                                                        }];
}

- (void)sharePhoto
{
    
    self.view.userInteractionEnabled = NO;
    [self showProgress];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self updateProgress:.65];
        });
        
        UIImage *resultImage = self.projectResource.resultImage;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self updateProgress:1];
        });
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.view.userInteractionEnabled = YES;
            
            [self completeProgress];
            [self.editorDelegate editorViewControllerDidShareActivityWithImage:resultImage
                                                                completion:^{
                                                                    [self completeShareProject];
                                                                }];
        });
        
    });
}
- (void)sharePDF
{
    self.view.userInteractionEnabled = NO;
    [self showProgress];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self updateProgress:.65];
        });
        
        NSURL *resultPDF = self.projectResource.resultPDF;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self updateProgress:1];
        });
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.view.userInteractionEnabled = YES;
            [self completeProgress];
            [self.editorDelegate editorViewControllerDidShareActivityWithPDFURL:resultPDF
                                                                     completion:^{
                                                                         [self completeShareProject];
                                                                     }];
        });
        
    });
}
- (void)shareVideo
{
    [self presentVideoPreviewViewControllerWithProject:self.projectResource animated:YES];
    //[self dismissHomeShareViewController:YES];
}

- (void)completeShareProject
{
    if(self.videoPreviewViewController) {
        [self dismissVideoPreviewViewController:YES];
        return;
    }
    if(self.homeShareViewController) {
        [self.homeShareViewController completeShare];
    }
}

- (void)showProgress
{
    if(self.progressView) {
        [self.progressView removeFromSuperview];
        self.progressView = nil;
    }
    PProgressView *pView = [[PProgressView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 7)];
    pView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:pView];
    self.progressView = pView;
    
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(pView);
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|[pView]|"
                               options:0
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|[pView(7)]"
                               options:0
                               metrics:nil
                               views:viewsDictionary]];
    
    
    [self.progressView prepareProgress];
}
- (void)updateProgress:(CGFloat)progress
{
    if(self.progressView) {
        [self.progressView updateProgress:progress];
    }
}
- (void)completeProgress
{
    if(self.progressView) {
        [self.progressView completeProgress];
        self.progressView = nil;
    }
}


- (void)changePhotos
{
    /*
    for(PPhotoAsset *photoAsset in projectResource.photoArray) {
        NSLog(@"PPhotoAsset.localIdentifier : %@", photoAsset.localIdentifier);
    }
     */
    /*
     for(id photo in projectResource.photoArray) {
     if([photo isKindOfClass:[PHAsset class]]) {
            PHAsset *pAsset = (PHAsset *)photo;
            NSLog(@"PHAsset.localIdentifier : %@", pAsset.localIdentifier);
        } else if([photo isKindOfClass:[PPhotoAsset class]]) {
            PPhotoAsset *photoAsset = (PPhotoAsset *)photo;
            NSLog(@"PPhotoAsset.localIdentifier : %@", photoAsset.localIdentifier);
        }
    }
     */

    
}
- (void)changeTemplate
{
    
}
- (void)initTempalteZoom
{
    if(self.workingTemplateView) {
        
        CGFloat currentZoomScale = self.templateScrollView.zoomScale;
        CGFloat currentZoomRatio = currentZoomScale / self.templateScrollView.minimumZoomScale;
        
        [self.templateScrollView setZoomScale:1 animated:NO];
        
        CGSize scrollViewSize = CGSizeMake(self.templateScrollView.frame.size.width, self.templateScrollView.frame.size.height);
        
        CGFloat zoomScale = scrollViewSize.width / self.workingTemplateView.frame.size.width;
        if(self.workingTemplateView.frame.size.height * zoomScale > scrollViewSize.height) {
            zoomScale = scrollViewSize.height / self.workingTemplateView.frame.size.height;
        }
        
        //NSLog(@"self.templateScrollView.frame : %@", NSStringFromCGRect(self.templateScrollView.frame));
        //NSLog(@"self.workingTemplateView.frame : %@", NSStringFromCGRect(self.workingTemplateView.frame));
        
        
        self.templateScrollView.maximumZoomScale = 1.0;
        self.templateScrollView.minimumZoomScale = zoomScale;
        /*
        CGFloat offsetX = MAX((self.templateScrollView.bounds.size.width - self.templateScrollView.contentSize.width) * 0.5, 0.0);
        CGFloat offsetY = MAX((self.templateScrollView.bounds.size.height - self.templateScrollView.contentSize.height) * 0.5, 0.0);
        
        self.workingTemplateView.center = CGPointMake(self.templateScrollView.contentSize.width * 0.5 + offsetX,
                                     self.templateScrollView.contentSize.height * 0.5 + offsetY);
        */
        
        
        NSLog(@"initTempalteZoom zoomScale : %f", self.templateScrollView.minimumZoomScale * currentZoomRatio);
        [self.templateScrollView setZoomScale:self.templateScrollView.minimumZoomScale * currentZoomRatio animated:NO];

    }
}

- (void)createTemplateView
{
    MARK;
    if(self.workingTemplateView) {
        [self removeTemplateView];
    }
    currentPhotoCount = self.projectResource.photoArray.count;
    currentTemplateNibName = self.projectResource.templateDictionary[@"NibName"];
    NSLog(@"currentPhotoCount : %li", (long)currentPhotoCount);
    NSLog(@"currentTemplateNibName : %@", currentTemplateNibName);
    if(!currentTemplateNibName) {
        return;
    }
    PTemplate *templateView = [[PTemplate alloc] initWithFrame:CGRectMake(0, 0, TemplateViewSize.width, TemplateViewSize.height) templateDictionary:self.projectResource.templateDictionary];
    
    if(self.projectResource.locationString) {
        templateView.locationString = self.projectResource.locationString;
    }
    
    [templateView setupTemplate];
    templateView.userInteractionEnabled = YES;
    //templateView.center = TemplateViewCenter;
    [templateView setPhotosWithPhotoArray:self.projectResource.photoArray];
    
    
    NSString *footerString = [[NSUserDefaults standardUserDefaults] objectForKey:@"TextTypeFooterString"];
    if(footerString) {
        [templateView setTemplateTextWithFooterString:footerString];
    }
    
    if(self.projectResource.templateTextDictionary) {
        [templateView setTemplateTextWithDictionary:self.projectResource.templateTextDictionary];
    }
    
    if(self.projectResource.projectDictionary) {
        [templateView setupProjectDictionary:self.projectResource.projectDictionary];
    }
    
    
    self.workingTemplateView = templateView;
    
    [self.templateScrollView addSubview:self.workingTemplateView];
    self.templateScrollView.contentSize = self.workingTemplateView.frame.size;
    
    
    NSLog(@"createTemplateView self.workingTemplateView.frame : %@", NSStringFromCGRect(self.workingTemplateView.frame));

    // 템플릿 처음 로드했을땐 줌아웃되어 있어야 해서 0 으로 지정
    self.templateScrollView.zoomScale = 0;
    [self initTempalteZoom];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [templateView showCreatingAnimation];
    });
    //[self.view sendSubviewToBack:templateView];
    
    [self.view bringSubviewToFront:borderView];
    
    
    
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    panGesture.delegate = self;
    [self.templateScrollView addGestureRecognizer:panGesture];
    
    doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGesture:)];
    doubleTapGesture.delegate = self;
    doubleTapGesture.numberOfTapsRequired = 2;
    doubleTapGesture.numberOfTouchesRequired = 1;
    [self.templateScrollView addGestureRecognizer:doubleTapGesture];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self.templateScrollView addGestureRecognizer:tapGesture];
    
    [tapGesture requireGestureRecognizerToFail:doubleTapGesture];
    
    if(self.projectResource.photoArray.count > 1) {
        longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
        
        longPressGesture.cancelsTouchesInView = YES;
        [self.templateScrollView addGestureRecognizer:longPressGesture];
    }
}


- (void)removeTemplateView
{
    MARK;
    if(self.workingTemplateView) {
        currentTemplateNibName = nil;
        
        self.projectResource.templateTextDictionary = [self.workingTemplateView templateTextDictionary];
        
        [self.workingTemplateView removeFromSuperview];
        self.workingTemplateView = nil;
        
        [self deselectItem];
        
        if(doubleTapGesture) {
            [self.templateScrollView removeGestureRecognizer:doubleTapGesture];
        }
        if(tapGesture) {
            [self.templateScrollView removeGestureRecognizer:tapGesture];
        }
        if(longPressGesture) {
            [self.templateScrollView removeGestureRecognizer:longPressGesture];
        }
        if(panGesture) {
            [self.templateScrollView removeGestureRecognizer:panGesture];
        }
    }
}
- (void)selectItem:(id)targetItem
{
    [self selectItem:targetItem withEditor:YES];
}
- (void)selectItem:(id)targetItem withEditor:(BOOL)withEditor
{

    UIView *itemView = (UIView *)targetItem;
    CGRect convertFrame = [self.view convertRect:itemView.frame fromView:self.workingTemplateView];
    CGRect borderFrame = (CGRect) {
        convertFrame.origin.x - 2,
        convertFrame.origin.y - 2,
        convertFrame.size.width + 4,
        convertFrame.size.height + 4
    };
    
    self.selectedTemplateItem = targetItem;
    [self hiddenBorder:NO];
    borderView.frame = borderFrame;
    
    if(withEditor) {
        if([targetItem isKindOfClass:[PPhotoView class]]) {
            [self presentPhotoEditViewControllerWithProject:self.projectResource animated:YES];
        } else if([targetItem isKindOfClass:[PTextGroupView class]]) {
            //[self presentTextGroupEditViewControllerWithProject:self.projectResource animated:YES];
            [self presentTemplateEditViewControllerWithProject:self.projectResource animated:YES];
        }
    }
}
- (void)deselectItem
{
    if(self.selectedTemplateItem) {
        self.selectedTemplateItem = nil;
        [self hiddenBorder:YES];
    }
}

- (void)hiddenBorder:(BOOL)hidden
{
    /*
    if(hidden) {
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             borderView.alpha = 0;
                         }
                         completion:^(BOOL finished){
                         }];
    } else {
        //[self.view bringSubviewToFront:borderView];
        borderView.hidden = NO;
        borderView.alpha = 0;
        
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             borderView.alpha = 1;
                         }
                         completion:^(BOOL finished){
                         }];
    }
    */
}
- (SnapshotView *)snapshotFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.frame.size, NO, [[UIScreen mainScreen] scale]);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    SnapshotView *snapshot = [[SnapshotView alloc] initWithFrame:inputView.frame];
    [snapshot setSnapshotImage:image];
    
    return snapshot;
}
- (BOOL)editableWithItem:(id)item
{
    if([item isKindOfClass:[PTextGroupView class]] || [item isKindOfClass:[PPhotoView class]]) {
        return YES;
    }
    else {
        return NO;
    }

}
- (BOOL)draggableWithItem:(id)item
{
    //if([item isKindOfClass:[PPhotoView class]] || [item isKindOfClass:[PTextGroupView class]] || [item isKindOfClass:[PFlatView class]]) {
    if([item isKindOfClass:[PTextGroupView class]] || [item isKindOfClass:[PFlatView class]]) {
        return YES;
    }
    else {
        return NO;
    }
}
- (void)panGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    if(!self.workingTemplateView) {
        return;
    }
    
    if([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        NSLog(@"Pan Gesture Began");
        
        CGPoint location = [gestureRecognizer locationInView:self.workingTemplateView];
        id item = [self.workingTemplateView draggableItemAtContainsPoint:location fromView:self.workingTemplateView];
        
        if([self draggableWithItem:item]) {
            
            GripSensitivity = CGRectGetWidth([self.view convertRect:CGRectMake(0, 0, GRIP_SENSITIVITY, 0) toView:self.workingTemplateView]);
            NSLog(@"GripSensitivity : %f", GripSensitivity);
            
            self.draggedTemplateItem = item;
            UIView *itemView = (UIView *)item;
            
            NSMutableArray *gripFrameArray = [NSMutableArray array];
            /*
            for(UIView *otherView in self.workingTemplateView.photoViewArray) {
                if(otherView != itemView) {
                    [gripFrameArray addObject:[NSValue valueWithCGRect:otherView.frame]];
                }
            }
             */
            for(UIView *otherView in self.workingTemplateView.textGroupViewArray) {
                
                PTextGroupView *textGroupView = (PTextGroupView *)otherView;
                if(!textGroupView.fixedPosition) {
                    if(otherView != itemView) {
                        [gripFrameArray addObject:[NSValue valueWithCGRect:otherView.frame]];
                    }
                }
            }
            for(UIView *otherView in self.workingTemplateView.flatViewArray) {
                
                PFlatView *flatView = (PFlatView *)otherView;
                if(!flatView.fixedPosition) {
                    if(otherView != itemView) {
                        [gripFrameArray addObject:[NSValue valueWithCGRect:otherView.frame]];
                    }
                }
            }
            
            [gripFrameArray addObject:[NSValue valueWithCGRect:self.workingTemplateView.loadedNibView.frame]];
            
            self.gripItemFrameArray = [NSArray arrayWithArray:gripFrameArray];
            //NSLog(@"gripItemFrameArray : %@", self.gripItemFrameArray);
            
            
            borderView.layer.borderColor = [UIColor colorWithRed:0.235 green:0.482 blue:0.992 alpha:1].CGColor;
            borderView.layer.borderWidth = 1;
            borderView.hidden = NO;
            
            CGRect convertFrame = [self.view convertRect:itemView.frame fromView:self.workingTemplateView];
            
            borderView.frame = convertFrame;
        }
    }
    else if([gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        if(self.draggedTemplateItem) {
            
            CGPoint translation = [gestureRecognizer translationInView:self.workingTemplateView];
            UIView *itemView = (UIView *)self.draggedTemplateItem;
            CGRect itemFrame = itemView.frame; //CGRectMake(CGRectGetMinX(itemView.frame) + translation.x, CGRectGetMinY(itemView.frame) + translation.y, CGRectGetWidth(itemView.frame), CGRectGetHeight(itemView.frame));
            
            CGPoint itemCenter = CGPointMake(itemView.center.x + translation.x, itemView.center.y + translation.y);
            CGPoint gripCenter = itemCenter;
            
            
            gripHorizontalView.hidden = YES;
            gripVerticalView.hidden = YES;
            BOOL gripped = NO;
            
            for(NSValue *otherValue in self.gripItemFrameArray) {
                CGRect otherFrame = otherValue.CGRectValue;
                CGPoint otherCenter = CGPointMake(CGRectGetMidX(otherFrame), CGRectGetMidY(otherFrame));
                
                    if(ABS(otherCenter.x - itemCenter.x) < GripSensitivity) {
                        //NSLog(@"grip position X : %@", NSStringFromCGPoint(otherCenter));
                        gripCenter = CGPointMake(otherCenter.x, gripCenter.y);
                        
                        
                        CGFloat guideHeight = MAX(CGRectGetMinY(itemFrame) + CGRectGetHeight(itemFrame), CGRectGetMinY(otherFrame) + CGRectGetHeight(otherFrame)) - MIN(CGRectGetMinY(itemFrame), CGRectGetMinY(otherFrame));
                        CGRect guideFrame = CGRectMake(CGRectGetMidX(otherFrame), MIN(CGRectGetMinY(itemFrame), CGRectGetMinY(otherFrame)), 1, guideHeight);
                        
                        gripVerticalView.hidden = NO;
                        gripVerticalView.frame = [self.view convertRect:guideFrame fromView:self.workingTemplateView];
                        
                        gripped = YES;
                    }
                    
                    if(ABS(otherCenter.y - itemCenter.y) < GripSensitivity) {
                        //NSLog(@"grip position Y : %@", NSStringFromCGPoint(otherCenter));
                        gripCenter = CGPointMake(gripCenter.x, otherCenter.y);
                        
                        CGFloat guideWidth = MAX(CGRectGetMinX(itemFrame) + CGRectGetWidth(itemFrame), CGRectGetMinX(otherFrame) + CGRectGetWidth(otherFrame)) - MIN(CGRectGetMinX(itemFrame), CGRectGetMinX(otherFrame));
                        CGRect guideFrame = CGRectMake(MIN(CGRectGetMinX(itemFrame), CGRectGetMinX(otherFrame)), CGRectGetMidY(otherFrame), guideWidth, 1);
                        
                        gripHorizontalView.hidden = NO;
                        gripHorizontalView.frame = [self.view convertRect:guideFrame fromView:self.workingTemplateView];
                        
                        gripped = YES;
                    }
            }
            CGFloat duration = 0.2;
            CGFloat damping = 1;
            
            
            if(gripped) {
                duration = 0.35;
                damping = 0.6;
            }
            
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                              animations:^{
                                  itemView.center = gripCenter;
                              }
                              completion:^(BOOL finished){
                              }];
            
            
            CGRect convertFrame = [self.view convertRect:itemView.frame fromView:self.workingTemplateView];
            
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 borderView.frame = convertFrame;
                             }
                             completion:^(BOOL finished){
                             }];

            
            
            CGPoint resetTranslation = translation;
            if(itemCenter.x == gripCenter.x) {
                resetTranslation.x = 0;
            }
            if(itemCenter.y == gripCenter.y) {
                resetTranslation.y = 0;
            }
            
            [gestureRecognizer setTranslation:resetTranslation inView:self.workingTemplateView];
            
            
            
        }
    }
    else if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        NSLog(@"Pan Gesture Ended");
        if(self.draggedTemplateItem) {
            
            gripHorizontalView.hidden = YES;
            gripVerticalView.hidden = YES;
            
            borderView.hidden = YES;
            self.draggedTemplateItem = nil;
            self.gripItemFrameArray = nil;
        }
        [gestureRecognizer setTranslation:CGPointZero inView:self.workingTemplateView];
        
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        if(!self.workingTemplateView) {
            return;
        }
        CGPoint location = [gestureRecognizer locationInView:self.workingTemplateView];
        id item = [self.workingTemplateView editableItemAtContainsPoint:location fromView:self.workingTemplateView];
        if([self editableWithItem:item]) {
            
            if(self.selectedTemplateItem == item) {
                [self deselectItem];
            } else {
                [self selectItem:item];
            }
            
        }
        
    }
}
- (void)doubleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        if(!self.workingTemplateView) {
            return;
        }
        /*
        if(self.templateScrollView.minimumZoomScale == self.templateScrollView.zoomScale) {
            [self.templateScrollView setZoomScale:1 animated:YES];
        } else {
            [self.templateScrollView setZoomScale:self.templateScrollView.minimumZoomScale animated:YES];
        }
        */
        if (self.templateScrollView.zoomScale > self.templateScrollView.minimumZoomScale) {
            [self.templateScrollView setZoomScale:self.templateScrollView.minimumZoomScale animated:YES];
        } else {
            
            CGFloat zoomScale = self.templateScrollView.maximumZoomScale;
            CGPoint location = [gestureRecognizer locationInView:self.templateScrollView];
            
            CGRect zoomRect;
            
            zoomRect.size.height = self.templateScrollView.frame.size.height / zoomScale;
            zoomRect.size.width  = self.templateScrollView.frame.size.width / zoomScale;
            
            zoomRect.origin.x    = (location.x / self.templateScrollView.zoomScale) - (zoomRect.size.width  / 2.0);
            zoomRect.origin.y    = (location.y / self.templateScrollView.zoomScale) - (zoomRect.size.height / 2.0);
            
            [self.templateScrollView zoomToRect:zoomRect animated:YES];
        }
        
        MARK;
        /*
        CGPoint location = [gestureRecognizer locationInView:self.workingTemplateView];
        id item = [self.workingTemplateView itemAtContainsPoint:location fromView:self.workingTemplateView];
        if(item) {
            
            [self selectItem:item];
            
            [self presentTemplateEditViewControllerWithProject:self.projectResource animated:YES];
        }
        */
    }
}


- (void)longPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer
{
    UIGestureRecognizerState state = gestureRecognizer.state;
    CGPoint location = [gestureRecognizer locationInView:self.templateScrollView];
    
    static CGPoint originalCenter;
    static CGPoint locationOffset;
    static PPhotoView *snapPhotoView;
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            
            __block id item = [self.workingTemplateView editableItemAtContainsPoint:location fromView:self.templateScrollView];
            if([item isKindOfClass:[PPhotoView class]] == NO) {
                return;
            }
            snapPhotoView = (PPhotoView *)item;
            
            if(snapshotView) {
                [snapshotView removeFromSuperview];
            }
            snapshotView = [self snapshotFromView:snapPhotoView];
            
            // Add the snapshot as subview, centered at cell's center...
            __block CGPoint center = [self.templateScrollView convertPoint:snapPhotoView.center fromView:self.workingTemplateView];
            
            __block CGRect frame = [self.templateScrollView convertRect:snapPhotoView.frame fromView:self.workingTemplateView];
            
            
            snapshotView.frame = frame;
            snapshotView.center = center;
            snapshotView.alpha = 0.0;
            [self.templateScrollView addSubview:snapshotView];
            
            originalCenter = center;
            
            locationOffset = CGPointMake(snapshotView.center.x - location.x, snapshotView.center.y - location.y);
            /*
            [UIView animateWithDuration:0.45 delay:0 usingSpringWithDamping:0.85 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 snapshotView.transform = CGAffineTransformMakeScale(1.05, 1.05);
                             }
                             completion:^(BOOL finished){
                             }];
            */
            
            [UIView animateWithDuration:0.45 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 snapshotView.transform = CGAffineTransformMakeScale(1.05, 1.05);
                                 snapshotView.center = CGPointMake(location.x + locationOffset.x, location.y + locationOffset.y);
                                 snapshotView.alpha = 0.98;
                                 
                                 snapPhotoView.alpha = 0.35;
                                 
                             } completion:^(BOOL finished) {
                                 [UIView animateWithDuration:0.45 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                                                  animations:^{
                                                      snapshotView.transform = CGAffineTransformIdentity;
                                                  } completion:^(BOOL finished) {
                                                      
                                                  }];
                                 
                             }];
            
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if(snapshotView) {
                [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     snapshotView.center = CGPointMake(location.x + locationOffset.x, location.y + locationOffset.y);
                                 }
                                 completion:^(BOOL finished){
                                     if(finished) {
                                         
                                     }
                                 }];
            }
            break;
        }
        default: {
            if(snapshotView) {
                __block id item = [self.workingTemplateView editableItemAtContainsPoint:location fromView:self.templateScrollView];
                if([item isKindOfClass:[PPhotoView class]]) {
                    
                    __block PPhotoView *targetPhotoView = (PPhotoView *)item;
                    __block CGRect targetFrame = [self.templateScrollView convertRect:targetPhotoView.frame fromView:self.workingTemplateView];
                    
                    
                    [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         
                                         snapshotView.frame = targetFrame;
                                         snapshotView.snapshotImageView.frame = CGRectMake(snapshotView.snapshotImageView.frame.origin.x, snapshotView.snapshotImageView.frame.origin.y, targetFrame.size.width, targetFrame.size.height);
                                         snapshotView.alpha = 0.0;
                                         
                                         snapPhotoView.alpha = 1;
                                         
                                     } completion:^(BOOL finished) {
                                         originalCenter = CGPointZero;
                                         locationOffset = CGPointZero;
                                         [snapshotView removeFromSuperview];
                                         snapshotView = nil;
                                         snapPhotoView = nil;
                                     }];
                    
                    
                    if(targetPhotoView == snapPhotoView) {
                        NSLog(@"사진 순서 변경 필요 없음");
                    } else {
                        NSInteger snapPhotoIndex = [self.workingTemplateView.photoViewArray indexOfObject:snapPhotoView];
                        NSInteger targetPhotoIndex = [self.workingTemplateView.photoViewArray indexOfObject:targetPhotoView];
                        
                        
                        
                        PPhotoAsset *snapPhotoAsset = [self.projectResource.photoArray objectAtIndex:snapPhotoIndex];
                        PPhotoAsset *targetPhotoAsset = [self.projectResource.photoArray objectAtIndex:targetPhotoIndex];
                        
                        
                        [snapPhotoView setPhotoImage:targetPhotoAsset.photoImage];
                        [targetPhotoView setPhotoImage:snapPhotoAsset.photoImage];
                        
                        [self.projectResource swapPhotoAssetsAtIndex:snapPhotoIndex bIndex:targetPhotoIndex];
                        [self.projectResource updatePhotoAssetDictionary];
                        [self.editorDelegate editorViewControllerDidSwapPhoto];
                    }
                    
                } else {
                    [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         snapshotView.center = originalCenter;
                                         snapshotView.alpha = 0.0;
                                         
                                         snapPhotoView.alpha = 1;
                                         
                                     } completion:^(BOOL finished) {
                                         originalCenter = CGPointZero;
                                         locationOffset = CGPointZero;
                                         [snapshotView removeFromSuperview];
                                         snapshotView = nil;
                                         snapPhotoView = nil;
                                     }];
                }
            }
            break;
        }
    }
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    
    CGPoint location = [gestureRecognizer locationInView:self.workingTemplateView];
    id item = [self.workingTemplateView draggableItemAtContainsPoint:location fromView:self.workingTemplateView];
    
    if([self draggableWithItem:item]) {
        return NO;
    }
    else {
        return YES;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.workStepDelegate workStepViewControllerNeedDisableScroll:YES];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.workStepDelegate workStepViewControllerNeedDisableScroll:NO];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.workingTemplateView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self deselectItem];
    
    // 특정 템플릿에서 줌을 안했는데도 스크롤이 무시되는 경우가 있었음. 떄문에 줌 안했을때는 스크롤뷰 scrollEnabled 를 비활성화 처리 함
    scrollView.scrollEnabled = (scrollView.zoomScale > scrollView.minimumZoomScale);
    [self.workStepDelegate workStepViewControllerNeedDisableScroll:(scrollView.zoomScale > scrollView.minimumZoomScale)];
    
    //NSLog(@"scrollView.zoomScale : %f", scrollView.zoomScale);
    UIView *subView = self.workingTemplateView;
    
    CGFloat offsetX = MAX((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0);
    CGFloat offsetY = MAX((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0);
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self deselectItem];
}

#pragma mark - TemplateEditViewControllerDelegate

- (void)templateEditViewControllerDidClose
{
    [self deselectItem];
    [self dismissTemplateEditViewController:YES];
    [self.editorDelegate editorViewControllerDidEdit];
}
- (void)templateEditViewControllerDidReplacePhoto:(PPhotoView *)photoView photoIndex:(NSInteger)photoIndex
{
    PPhotoAsset *photoAsset = [self.projectResource.photoArray objectAtIndex:photoIndex];
    photoView.photoImage = photoAsset.photoImage;
    [self.projectResource updatePhotoAssetDictionary];
    [self.editorDelegate editorViewControllerDidReplacePhoto];
}


#pragma mark - PhotoEditViewControllerDelegate

- (void)photoEditViewControllerDidClose
{
    [self deselectItem];
    [self dismissPhotoEditViewController:YES];
    [self.editorDelegate editorViewControllerDidEdit];
}

- (void)photoEditViewControllerDidReplacePhoto:(PPhotoView *)photoView photoIndex:(NSInteger)photoIndex
{
    PPhotoAsset *photoAsset = [self.projectResource.photoArray objectAtIndex:photoIndex];
    photoView.photoImage = photoAsset.photoImage;
    [self.projectResource updatePhotoAssetDictionary];
    [self.editorDelegate editorViewControllerDidReplacePhoto];
}

#pragma mark - TextGroupEditViewControllerDelegate

- (PTextGroupView *)textGroupEditViewControllerNeedPreviousTextGroup
{
    NSMutableArray *yPositionOrderItems = [NSMutableArray array];
    for(PTextGroupView *textGroupView in self.workingTemplateView.textGroupViewArray) {
        
        BOOL orderd = NO;
        for(PTextGroupView *orderdTextGroupView in yPositionOrderItems) {
            if(CGRectGetMinY(orderdTextGroupView.frame) > CGRectGetMinY(textGroupView.frame)) {
                NSInteger index = [yPositionOrderItems indexOfObject:orderdTextGroupView];
                [yPositionOrderItems insertObject:textGroupView atIndex:index];
                orderd = YES;
                break;
            }
        }
        
        if(!orderd) {
            [yPositionOrderItems addObject:textGroupView];
        }
    }
    
    NSArray *sortedTextGroupViews = [NSArray arrayWithArray:yPositionOrderItems];
    
    NSInteger selectedIndex = [sortedTextGroupViews indexOfObject:self.selectedTemplateItem];
    NSInteger nextIndex = selectedIndex - 1;
    if(nextIndex < 0) {
        [self selectItem:[sortedTextGroupViews lastObject] withEditor:NO];
    } else {
        [self selectItem:[sortedTextGroupViews objectAtIndex:nextIndex] withEditor:NO];
    }
    
    return (PTextGroupView *)self.selectedTemplateItem;
}
- (PTextGroupView *)textGroupEditViewControllerNeedNextTextGroup
{
    NSMutableArray *yPositionOrderItems = [NSMutableArray array];
    for(PTextGroupView *textGroupView in self.workingTemplateView.textGroupViewArray) {
        
        BOOL orderd = NO;
        for(PTextGroupView *orderdTextGroupView in yPositionOrderItems) {
            if(CGRectGetMinY(orderdTextGroupView.frame) > CGRectGetMinY(textGroupView.frame)) {
                NSInteger index = [yPositionOrderItems indexOfObject:orderdTextGroupView];
                [yPositionOrderItems insertObject:textGroupView atIndex:index];
                orderd = YES;
                break;
            }
        }
        
        if(!orderd) {
            [yPositionOrderItems addObject:textGroupView];
        }
    }
    
    NSArray *sortedTextGroupViews = [NSArray arrayWithArray:yPositionOrderItems];
    
    NSInteger selectedIndex = [sortedTextGroupViews indexOfObject:self.selectedTemplateItem];
    NSInteger nextIndex = selectedIndex + 1;
    if(selectedIndex == sortedTextGroupViews.count - 1) {
        [self selectItem:[sortedTextGroupViews firstObject] withEditor:NO];
    } else {
        [self selectItem:[sortedTextGroupViews objectAtIndex:nextIndex] withEditor:NO];
    }
    
    return (PTextGroupView *)self.selectedTemplateItem;
}

- (UIScrollView *)textGroupEditViewControllerNeedTemplateScrollView
{
    return self.templateScrollView;
}

- (void)textGroupEditViewControllerNeedTemplateTranslation:(CGPoint)translation
{
    CGFloat animationDelay = 0;
    CGFloat duration = 0.55;
    CGFloat damping = 1;
    CGFloat velocity = 1;
    [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if(CGPointEqualToPoint(translation, CGPointZero)) {
                             self.templateScrollView.transform = CGAffineTransformIdentity;
                         } else {
                             self.templateScrollView.transform = CGAffineTransformTranslate(self.templateScrollView.transform, translation.x, translation.y);
                         }
                     }
                     completion:^(BOOL finished){
                     }];
    
}

- (void)textGroupEditViewControllerDidClose
{
    [self deselectItem];
    [self dismissTextGroupEditViewController:YES];
    [self.editorDelegate editorViewControllerDidEdit];
}



#pragma mark HomeShareViewControllerDelegate

- (void)homeShareViewControllerDidSelectSharePhoto
{
    [self sharePhoto];
}
- (void)homeShareViewControllerDidSelectShareVideo
{
    [self shareVideo];
}
- (void)homeShareViewControllerDidSelectSharePDF
{
    [self sharePDF];
}
- (void)homeShareViewControllerDidClose
{
    [self dismissHomeShareViewController:YES];
}

#pragma mark - VideoPreviewViewControllerDelegate
- (void)videoPreviewViewControllerDidClose
{
    [self dismissVideoPreviewViewController:YES];
}


- (void)videoPreviewViewControllerDidShareActivityWithVideoURL:(NSURL *)videoURL
{
    [self.editorDelegate editorViewControllerDidShareActivityWithVideoURL:videoURL
                                                           completion:^{
                                                               [self completeShareProject];
                                                           }];
}
@end
