//
//  TextGroupEditViewController.m
//  Page
//
//  Created by CMR on 3/30/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "TextGroupEditViewController.h"
#import "NSString+SentenceCaps.h"

@interface TextGroupEditViewController ()
{
    BOOL layoutReady;
    id selectedItem;
    
    CGFloat TargetTextGroupViewAlpha;
    
    CGSize viewSize;
}

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIButton *backgroundButton;

@property (weak, nonatomic) IBOutlet UIButton *fontButton;
@property (weak, nonatomic) IBOutlet UIButton *colorButton;
@property (weak, nonatomic) IBOutlet UIButton *uppercaseButton;

@property (strong, nonatomic) IBOutlet UIView *accessoryView;
@property (weak, nonatomic) IBOutlet UIButton *accessoryPrevButton;
@property (weak, nonatomic) IBOutlet UIButton *accessoryNextButton;
@property (weak, nonatomic) IBOutlet UIButton *accessoryDoneButton;

@property (strong, nonatomic) NSArray *editingItemViewArray;
@property (strong, nonatomic) NSArray *editingItemFontArray;
@property (strong, nonatomic) NSArray *editingItemFrameArray;
@property (strong, nonatomic) NSArray *syncedItemViewArray;

@property (strong, nonatomic) FontToolboardView *fontToolView;
@property (strong, nonatomic) ColorToolboardView *colorToolView;

@property (strong, nonatomic) PTextGroupView *targetTextGroupView;
@property (strong, nonatomic) PTextGroupView *editingTextGroupView;

@property (strong, nonatomic) UIColor *templateColor;
@property (strong, nonatomic) UIColor *backgroundColor;

- (IBAction)backgroundButtonAction:(id)sender;
- (IBAction)clearButtonAction:(id)sender;
- (IBAction)accessoryButtonAction:(id)sender;

- (void)followTemplateAnimation;

- (void)orientationChanged:(NSNotification *)notification;

- (void)keyboardWillChange:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;

- (void)beginEditMode;
- (void)syncEditingData;

- (void)createEditingTextGroupView;
- (void)removeEditingTextGroupView;
- (void)sizeToFitTextItem:(UITextView *)textView;
- (void)updateTextItemWithFontName:(UITextView *)textView fontName:(NSString *)fontName;
- (void)uppercaseToggleTextItem:(UITextView *)textView;

- (void)previousTextView;
- (void)nextTextView;
- (void)selectTextView:(UITextView *)textView;
- (void)deselectTextView:(UITextView *)textView;

- (void)showFontToolboard;
- (void)showColorToolboard;
- (void)hideToolboard:(ToolboardView *)toolboardView;
- (void)hideToolboard:(ToolboardView *)toolboardView translationAnimation:(BOOL)translationAnimation;


@end

@implementation TextGroupEditViewController

static CGFloat textContentsWidth;
static CGFloat textContentsHeight;
static CGFloat keyboardDuration;
static CGRect keyboardFrame;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.clearButton.alpha = 0;
    self.clearButton.layer.cornerRadius = 18.5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
    [self removeEditingTextGroupView];
    
    self.templateColor = nil;
    self.backgroundColor = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if(layoutReady) {
        if(self.editingTextGroupView) {
            self.editingTextGroupView.center = CGPointMake(self.view.frame.size.width * 0.5, (self.view.frame.size.height - keyboardFrame.size.height) * 0.5);
        }
        
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    viewSize = self.view.frame.size;
    
    if(self.view.frame.size.width < self.view.frame.size.height) {
        textContentsWidth = self.view.frame.size.width - 30;
    } else {
        textContentsWidth = self.view.frame.size.height - 30;
    }
    
    if(keyboardFrame.size.height == 0) {
        if(self.view.frame.size.width < self.view.frame.size.height) {
            textContentsHeight = (self.view.frame.size.height / 2);
        } else {
            textContentsHeight = (self.view.frame.size.height / 3);
        }
    }
    
    [self createEditingTextGroupView];
    
}

- (void)orientationChanged:(NSNotification *)notification
{
    
    if(CGSizeEqualToSize(self.view.frame.size, viewSize) == NO) {
        if(selectedItem) {
            
            UITextView *textView = (UITextView *)selectedItem;
            [textView becomeFirstResponder];
        }
        
        viewSize = self.view.frame.size;
    }
    
    
}

- (void)followTemplateAnimation
{
    CGFloat animationDelay = 0;
    CGFloat duration = 0.55;
    CGFloat damping = 1;
    CGFloat velocity = 1;
    
    
    
    self.editingTextGroupView.transform = CGAffineTransformIdentity;
    // rotation 되는 TextGroupView 가 있기때문에 transform 처리 해줘야 함
    CGAffineTransform targetTextGroupViewTransform = self.targetTextGroupView.transform;
    self.targetTextGroupView.transform = CGAffineTransformIdentity;
    
    CGRect convertTargetTextGroupViewFrame = [self.contentScrollView convertRect:self.targetTextGroupView.frame fromView:[self.targetTextGroupView superview]];
    CGPoint convertTargetTextGroupViewCenter = [self.contentScrollView convertPoint:self.targetTextGroupView.center fromView:[self.targetTextGroupView superview]];
    
    self.targetTextGroupView.transform = targetTextGroupViewTransform;
    
    CGRect editingTextGroupViewFrame = self.editingTextGroupView.frame;
    CGPoint editingTextGroupViewCenter = self.editingTextGroupView.center;
    
    CGPoint translation = CGPointMake(convertTargetTextGroupViewCenter.x - editingTextGroupViewCenter.x, convertTargetTextGroupViewCenter.y - editingTextGroupViewCenter.y);
    CGFloat resizeScale = convertTargetTextGroupViewFrame.size.width / editingTextGroupViewFrame.size.width;
    
    
    //self.editingTextGroupView.transform = CGAffineTransformMakeScale(resizeScale, resizeScale);
    self.editingTextGroupView.transform = CGAffineTransformTranslate(self.editingTextGroupView.transform, translation.x, translation.y);
    
    self.editingTextGroupView.transform = CGAffineTransformRotate(self.editingTextGroupView.transform, self.targetTextGroupView.angle);
    
    self.editingTextGroupView.transform = CGAffineTransformScale(self.editingTextGroupView.transform, resizeScale, resizeScale);
    
    [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                     animations:^{
                         self.editingTextGroupView.transform = CGAffineTransformIdentity;
                         self.targetTextGroupView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         
                         layoutReady = YES;
                     }];
    
    CGPoint templateViewTranslation = CGPointMake(editingTextGroupViewCenter.x - convertTargetTextGroupViewCenter.x, editingTextGroupViewCenter.y - convertTargetTextGroupViewCenter.y);
    
    //TODO:템플릿뷰 위치 옮김
    [self.textGroupEditDelegate textGroupEditViewControllerNeedTemplateTranslation:templateViewTranslation];
    
}

- (void)presentViewControllerAnimated:(BOOL)animated completion:(void(^)(void))callback
{
    [presentDelegate presentWillFinish:self];
    self.view.hidden = NO;
    
    if(animated) {
        
        MARK;
        CGFloat animationDelay = 0;
        CGFloat duration = 0.55;
        CGFloat damping = 1;
        CGFloat velocity = 1;
        
        if(self.editingTextGroupView) {
            [self beginEditMode];
            [self followTemplateAnimation];
        }
        
        CGFloat r,g,b,a;
        [self.backgroundColor getRed:&r green:&g blue:&b alpha:&a];
        UIColor *opacityColor = [UIColor colorWithRed:r green:g blue:b alpha:0.85];
        
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                         animations:^{
                             self.view.backgroundColor = opacityColor;
                         }
                         completion:^(BOOL finished){
                             if(callback != nil) {
                                 callback();
                             }
                             [presentDelegate presentDidFinish:self];
                         }];
        
    } else {
        if(callback != nil) {
            callback();
        }
        [presentDelegate presentDidFinish:self];
    }
}
- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void(^)(void))callback
{
    [presentDelegate dismissWillFinish:self];
    
    if(animated) {
        
        CGFloat animationDelay = 0;
        CGFloat duration = 0.55;
        CGFloat damping = 1;
        CGFloat velocity = 1;
        
        
        if(self.editingTextGroupView) {
            
            UIScrollView *templateScrollView = [self.textGroupEditDelegate textGroupEditViewControllerNeedTemplateScrollView];
            CGAffineTransform templateScrollViewTransform = templateScrollView.transform;
            templateScrollView.transform = CGAffineTransformIdentity;
            
            CGAffineTransform targetTextGroupViewTransform = self.targetTextGroupView.transform;
            self.targetTextGroupView.transform = CGAffineTransformIdentity;
            
            CGRect convertTargetTextGroupViewFrame = [self.contentScrollView convertRect:self.targetTextGroupView.frame fromView:[self.targetTextGroupView superview]];
            CGPoint convertTargetTextGroupViewCenter = [self.contentScrollView convertPoint:self.targetTextGroupView.center fromView:[self.targetTextGroupView superview]];
            
            self.targetTextGroupView.transform = targetTextGroupViewTransform;
            templateScrollView.transform = templateScrollViewTransform;
            
            CGRect editingTextGroupViewFrame = self.editingTextGroupView.frame;
            CGPoint editingTextGroupViewCenter = self.editingTextGroupView.center;
            
            CGPoint translation = CGPointMake(convertTargetTextGroupViewCenter.x - editingTextGroupViewCenter.x, convertTargetTextGroupViewCenter.y - editingTextGroupViewCenter.y);
            CGFloat resizeScale = convertTargetTextGroupViewFrame.size.width / editingTextGroupViewFrame.size.width;
            
            //self.editingTextGroupView.transform = CGAffineTransformMakeScale(resizeScale, resizeScale);
            
            CGAffineTransform targetTransform = self.editingTextGroupView.transform;
            CGAffineTransform currentTransform = self.editingTextGroupView.transform;
            
            targetTransform = CGAffineTransformTranslate(targetTransform, translation.x, translation.y);
            targetTransform = CGAffineTransformRotate(targetTransform, self.targetTextGroupView.angle);
            targetTransform = CGAffineTransformScale(targetTransform, resizeScale, resizeScale);
            
            self.editingTextGroupView.transform = currentTransform;
            [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                             animations:^{
                                 self.editingTextGroupView.transform = targetTransform;
                                 self.editingTextGroupView.alpha = 0;
                                 self.targetTextGroupView.alpha = TargetTextGroupViewAlpha;
                             }
                             completion:^(BOOL finished){
                                 if(finished) {
                                 }
                             }];
            
            CGFloat fadeDelay = duration * 0.35;
            [UIView animateWithDuration:fadeDelay delay:duration - fadeDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                             animations:^{
                             }
                             completion:^(BOOL finished){
                             }];
            
        }
        
        //FIX:템플릿뷰 원래 위치로 이동
        [self.textGroupEditDelegate textGroupEditViewControllerNeedTemplateTranslation:CGPointZero];
        
        [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                         animations:^{
                             self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
                         }
                         completion:^(BOOL finished){
                             if(callback != nil) {
                                 callback();
                             }
                             [presentDelegate dismissDidFinish:self];
                         }];
    } else {
        if(callback != nil) {
            callback();
        }
        [presentDelegate dismissDidFinish:self];
    }
}


- (IBAction)backgroundButtonAction:(id)sender {
    [self syncEditingData];
    if(selectedItem) {
        [self deselectTextView:selectedItem];
    }
    [self.textGroupEditDelegate textGroupEditViewControllerDidClose];
}

- (IBAction)clearButtonAction:(id)sender {
    if([selectedItem isFirstResponder]) {
        
        UITextView *textView = (UITextView *)selectedItem;
        textView.text = @"";
    }
}

- (IBAction)accessoryButtonAction:(id)sender
{
    if(sender == self.accessoryPrevButton) {
        
        [self previousTextView];
        
    } else if(sender == self.accessoryNextButton) {
        
        [self nextTextView];
        
    } else if(sender == self.fontButton) {
        [self showFontToolboard];
    } else if(sender == self.colorButton) {
        [self showColorToolboard];
    } else if(sender == self.uppercaseButton) {
        if(selectedItem) {
            [self uppercaseToggleTextItem:selectedItem];
        }
    } else if(sender == self.accessoryDoneButton) {
        [self syncEditingData];
        if(selectedItem) {
            [self deselectTextView:selectedItem];
        }
        [self.textGroupEditDelegate textGroupEditViewControllerDidClose];
    }
}

- (void)keyboardWillChange:(NSNotification *)notification
{
    //MARK;
    
    keyboardDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
    
    textContentsHeight = (self.view.frame.size.height - keyboardFrame.size.height) - 100;
    
    if(self.editingTextGroupView) {
        self.editingTextGroupView.center = CGPointMake(self.view.frame.size.width * 0.5, (self.view.frame.size.height - keyboardFrame.size.height) * 0.5);
    }
    /*
    NSLog(@"keyboardWillChange keyboardFrame : %@", NSStringFromCGRect(keyboardFrame));
    NSLog(@"self.containerView.frame : %@", NSStringFromCGRect(self.containerView.frame));
    CGRect toolboardFrame = (CGRect) {
        0,
        self.containerView.frame.size.height - keyboardFrame.size.height,
        keyboardFrame.size.width,
        keyboardFrame.size.height
    };
    
    
    if(self.fontToolView) {
        self.fontToolView.frame = toolboardFrame;
    }
    if(self.colorToolView) {
        self.colorToolView.frame = toolboardFrame;
    }
     */
    
    /*
    self.contentScrollView.contentInset = (UIEdgeInsets) {
        0,
        0,
        keyboardFrame.size.height,
        0
    };
     */
    
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    self.contentScrollView.contentInset = UIEdgeInsetsZero;
}


- (void)editTextGroupWithTextGroupView:(PTextGroupView *)textGroupView backgroundColor:(UIColor *)backgroundColor
{
    self.targetTextGroupView = textGroupView;
    
    //NSLog(@"r : %f, g : %f, b : %f, a : %f", r, g, b, a);
    self.templateColor = backgroundColor;
}

- (void)beginEditMode
{
    if(selectedItem) {
        [self selectTextView:selectedItem];
    }
    
}

- (void)syncEditingData
{
    NSInteger itemIndex = 0;
    
    for(id item in self.editingItemViewArray) {
        
        id targetItem = [self.syncedItemViewArray objectAtIndex:itemIndex];
        
        if([item isKindOfClass:[UITextView class]]) {
            if([targetItem isKindOfClass:[PUILabel class]]) {
                
                PUILabel *targetLabel = (PUILabel *)targetItem;
                UITextView *textView = (UITextView *)item;
                targetLabel.textColor = textView.textColor;
                
                if(![targetLabel.font.fontName isEqualToString:textView.font.fontName]) {
                    [targetLabel setFontName:textView.font.fontName];
                }
                
                NSString *newText = [NSString stringWithString:textView.text];
                if(![newText isEqualToString:targetLabel.text]) {
                    targetLabel.paragraphText = newText;
                    targetLabel.editedText = YES;
                    if(targetLabel.textType) {
                        if([targetLabel.textType isEqualToString:@"footer"]) {
                            [[NSUserDefaults standardUserDefaults] setObject:newText forKey:@"TextTypeFooterString"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                    }
                }
            }
        }
        
        itemIndex++;
    }

}

- (void)createEditingTextGroupView
{
    MARK;
    if(self.editingItemViewArray) {
        return;
    }
    if(self.editingTextGroupView) {
        return;
    }
    if(!self.targetTextGroupView) {
        return;
    }
    
    TargetTextGroupViewAlpha = self.targetTextGroupView.alpha;
    
    PTextGroupView *targetTextGroupView = self.targetTextGroupView;
    CGAffineTransform targetTextGroupViewTransform = self.targetTextGroupView.transform;
    self.targetTextGroupView.transform = CGAffineTransformIdentity;
    
    CGSize targetFrameSize = CGSizeMake(targetTextGroupView.frame.size.width, targetTextGroupView.frame.size.height);
    
    CGFloat scale = 1;
    
    CGSize convertTargetFrameSize;
    
    // 아이패드에서는 생성되는 텍스트 스케일을 원래 기본 스케일로
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        
        UIScrollView *templateScrollView = [self.textGroupEditDelegate textGroupEditViewControllerNeedTemplateScrollView];
        CGFloat templateZoomScale = templateScrollView.zoomScale;
        
        NSLog(@"createEditingTextGroupView templateZoomScale : %f", templateZoomScale);
        
        convertTargetFrameSize = CGSizeMake(targetFrameSize.width * templateZoomScale, targetFrameSize.height * templateZoomScale);
        
        if(convertTargetFrameSize.width > textContentsWidth || convertTargetFrameSize.height > textContentsHeight) {
            
            scale = textContentsWidth / targetFrameSize.width;
            if(targetFrameSize.height * scale > textContentsHeight) {
                scale = textContentsHeight / targetFrameSize.height;
            }
        } else {
            scale = templateZoomScale;
        }
    }
    else {
        if(targetFrameSize.width > textContentsWidth || targetFrameSize.height > textContentsHeight) {
            scale = textContentsWidth / targetFrameSize.width;
            if(targetFrameSize.height * scale > textContentsHeight) {
                scale = textContentsHeight / targetFrameSize.height;
            }
        }
        
    }
    
    //NSLog(@"textContentsWidth : %f , textContentsHeight : %f", textContentsWidth, textContentsHeight);
    NSLog(@"createEditingTextGroupView scale : %f", scale);
    
    
    self.targetTextGroupView.transform = targetTextGroupViewTransform;
    
    PTextGroupView *textGroupView = [[PTextGroupView alloc] initWithFrame:CGRectMake(0, 15, ceil(targetFrameSize.width * scale), ceil(targetFrameSize.height * scale))];
    textGroupView.backgroundColor = [UIColor clearColor];
    
    NSMutableArray *editingItemViews = [NSMutableArray array];
    NSMutableArray *editingItemFonts = [NSMutableArray array];
    NSMutableArray *editingItemFrames = [NSMutableArray array];
    NSMutableArray *syncedTargetItems = [NSMutableArray array];
    
    UIColor *templateBackgroundColor = self.templateColor;
    self.backgroundColor = self.templateColor;
    CGFloat r,g,b,a;
    [templateBackgroundColor getRed:&r green:&g blue:&b alpha:&a];
    //UIColor *borderColor = [UIColor colorWithRed:1.-r green:1.-g blue:1.-b alpha:0.4];
    UIColor *inverseBackgroundColor = [UIColor colorWithRed:1.-r green:1.-g blue:1.-b alpha:0.85];
    //UIColor *opacityColor = [UIColor colorWithRed:1.-r green:1.-g blue:1.-b alpha:0.95];
    
    CGRect textViewFrame = CGRectZero;
    CGRect previousTextViewFrame = CGRectZero;
    
    for(id subItem in [self.targetTextGroupView subviews]) {
        if([subItem isKindOfClass:[PUILabel class]]) {
        
            PUILabel *targetLabel = (PUILabel *)subItem;
            BOOL staticLabel = targetLabel.staticLabel;
            if(!staticLabel) {
                
                textViewFrame = CGRectMake(targetLabel.frame.origin.x * scale, targetLabel.frame.origin.y * scale, targetLabel.frame.size.width * scale, targetLabel.frame.size.height * scale);
                
                UITextView *textView = [[UITextView alloc] initWithFrame:textViewFrame];
                textView.delegate = self;
                textView.scrollEnabled = NO;
                textView.layer.borderColor = targetLabel.textColor.CGColor;
                textView.layer.borderWidth = 0;
                
                textView.backgroundColor = targetLabel.backgroundColor;
                textView.textAlignment = targetLabel.textAlignment;
                textView.textColor = targetLabel.textColor;
                
                if(CGColorEqualToColor(textView.textColor.CGColor, templateBackgroundColor.CGColor)) {
                    self.backgroundColor = inverseBackgroundColor;
                    [UIView animateWithDuration:0.35 animations:^{
                        self.view.backgroundColor = inverseBackgroundColor;
                    }];
                } else {
                    self.backgroundColor = self.templateColor;
                    
                    CGFloat r,g,b,a;
                    [self.backgroundColor getRed:&r green:&g blue:&b alpha:&a];
                    UIColor *opacityColor = [UIColor colorWithRed:r green:g blue:b alpha:0.85];
                    
                    [UIView animateWithDuration:0.35 animations:^{
                        self.view.backgroundColor = opacityColor;
                    }];
                }
                
                textView.text = targetLabel.originText;
                textView.text = targetLabel.text;
                textView.font = [UIFont fontWithName:targetLabel.font.fontName size:targetLabel.font.pointSize * scale];
                
                [self sizeToFitTextItem:textView];
                
                [textGroupView addSubview:textView];
                
                [syncedTargetItems addObject:subItem];
                [editingItemViews addObject:textView];
                [editingItemFonts addObject:[UIFont fontWithName:targetLabel.originFont.fontName size:targetLabel.originFont.pointSize * scale]];
                [editingItemFrames addObject:NSStringFromCGRect(textView.frame)];
                
                
                if(!selectedItem) {
                    selectedItem = textView;
                }
                // sizeToFit 되면서 frame 업데이트 되기 때문에 변수 값도 갱신해줌
                textViewFrame = textView.frame;
                
                if(CGRectIntersectsRect(previousTextViewFrame, textViewFrame)) {
                    if(previousTextViewFrame.origin.y < textViewFrame.origin.y) {
                        
                        CGFloat bottom = previousTextViewFrame.origin.y + previousTextViewFrame.size.height;
                        CGFloat top = textViewFrame.origin.y;
                        if(top < bottom) {
                            textViewFrame.origin.y = bottom;
                            NSLog(@"top < bottom");
                        }
                    }
                }
                
                if(previousTextViewFrame.origin.y < textViewFrame.origin.y) {
                    textGroupView.frame = CGRectMake(textGroupView.frame.origin.x, textGroupView.frame.origin.y, textGroupView.frame.size.width, textViewFrame.origin.y + textViewFrame.size.height);
                }
                textView.frame = textViewFrame;
                
                previousTextViewFrame = textViewFrame;
            }
        }
    }
    
    //[textGroupView resizeWithScale:scale];
    
    
    textGroupView.center = CGPointMake(self.view.frame.size.width * 0.5, (self.view.frame.size.height - keyboardFrame.size.height) * 0.5);
    
    self.editingTextGroupView = textGroupView;
    [self.contentScrollView addSubview:textGroupView];
    
    self.syncedItemViewArray = [NSArray arrayWithArray:syncedTargetItems];
    self.editingItemViewArray = [NSArray arrayWithArray:editingItemViews];
    self.editingItemFontArray = [NSArray arrayWithArray:editingItemFonts];
    self.editingItemFrameArray = [NSArray arrayWithArray:editingItemFrames];
    
}

- (void)removeEditingTextGroupView
{
    if(self.editingItemViewArray) {
        for(UIView *item in self.editingItemViewArray) {
            [item removeFromSuperview];
        }
    }
    
    self.editingItemViewArray = nil;
    self.syncedItemViewArray = nil;
    self.editingItemFontArray = nil;
    self.editingItemFrameArray = nil;
    
    selectedItem = nil;
    
    if(self.editingTextGroupView) {
        [self.editingTextGroupView removeFromSuperview];
        self.editingTextGroupView = nil;
    }
    
    self.targetTextGroupView.alpha = TargetTextGroupViewAlpha;
    self.targetTextGroupView = nil;
    
}
- (void)sizeToFitTextItem:(UITextView *)textView
{
    CGRect textViewFrame = textView.frame;

    textView.textContainer.lineFragmentPadding = 0;
    //textView.textContainerInset = UIEdgeInsetsZero;
    [textView sizeToFit];
    
    textView.frame = CGRectMake(textViewFrame.origin.x, textViewFrame.origin.y, textViewFrame.size.width, textView.frame.size.height);
}

- (void)updateTextItemWithFontName:(UITextView *)textView fontName:(NSString *)fontName
{
    NSInteger textViewIndex = [self.editingItemViewArray indexOfObject:textView];
    UIFont *originalFont = [self.editingItemFontArray objectAtIndex:textViewIndex];
    //PUILabel *targetLabel = [self.syncedItemViewArray objectAtIndex:textViewIndex];
    
    textView.frame = CGRectFromString([self.editingItemFrameArray objectAtIndex:textViewIndex]);
    
    UIFont *newFont = [UIFont fontWithName:fontName size:originalFont.pointSize];
    NSString *originalText = textView.text;
    
    CGSize fudgeFactor;
    fudgeFactor = CGSizeMake(0, 16.0);
    
    //CGFloat textWidth = textView.frame.size.width;
    CGFloat textHeight = textView.frame.size.height;
    
    CGRect frame = textView.frame;
    
    frame.size.height -= fudgeFactor.height;
    frame.size.width -= fudgeFactor.width;
    
    NSMutableAttributedString *attrStr;
    
    attrStr = [[NSMutableAttributedString alloc] initWithString:originalText];
    [attrStr addAttribute:NSFontAttributeName value:newFont range:NSMakeRange(0, attrStr.length)];
    
    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                        context:nil];
    
    CGSize measureSize = CGSizeMake(rect.size.width + fudgeFactor.width, rect.size.height + fudgeFactor.height);
    
    //NSLog(@"current : %@ : %@", NSStringFromCGSize(textView.frame.size), textView.font);
    
    while (textHeight < measureSize.height) {
        
        newFont = [UIFont fontWithName:fontName size:floor(newFont.pointSize * 0.95)];
        
        attrStr = [[NSMutableAttributedString alloc] initWithString:originalText];
        [attrStr addAttribute:NSFontAttributeName value:newFont range:NSMakeRange(0, attrStr.length)];
        
        rect = [attrStr boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                     context:nil];
        
        measureSize = CGSizeMake(rect.size.width + fudgeFactor.width, rect.size.height + fudgeFactor.height);
        
        //NSLog(@"revision : %@ : %@", NSStringFromCGSize(measureSize), newFont);
    }
    
    textView.font = newFont;
    [self sizeToFitTextItem:textView];
}

- (void)uppercaseToggleTextItem:(UITextView *)textView
{
    NSString *sentenceCapsString = [textView.text realSentenceCapitalizedString];
    NSString *uppercaseString = [textView.text uppercaseString];
    NSString *lowercaseString = [textView.text lowercaseString];
    
    if([textView.text isEqualToString:sentenceCapsString]) {
        textView.text = uppercaseString;
    } else if([textView.text isEqualToString:uppercaseString]) {
        textView.text = lowercaseString;
    } else {
        textView.text = sentenceCapsString;
    }
    
    // 텍스트 크기가 달라지면 폰트 변경때와 마찬가지로 텍스트 크기 조절이 필요함
    [self updateTextItemWithFontName:textView fontName:textView.font.fontName];
}

- (void)previousTextView
{
    if(selectedItem) {
        NSInteger selectedIndex = [self.editingItemViewArray indexOfObject:selectedItem];
        NSInteger nextIndex = selectedIndex - 1;
        if(nextIndex < 0) {
            //nextIndex = self.editingItemViewArray.count - 1;
            [self syncEditingData];
            
            PTextGroupView *textGroup = [self.textGroupEditDelegate textGroupEditViewControllerNeedPreviousTextGroup];
            if(textGroup) {
                
                [self removeEditingTextGroupView];
                self.targetTextGroupView = textGroup;
                [self createEditingTextGroupView];
                
                selectedItem = [self.editingItemViewArray lastObject];
                [self selectTextView:selectedItem];
                
                [self followTemplateAnimation];
            }
        }
        else {
            id nextItem = [self.editingItemViewArray objectAtIndex:nextIndex];
            [self selectTextView:nextItem];
        }
    }
}

- (void)nextTextView
{
    if(selectedItem) {
        NSInteger selectedIndex = [self.editingItemViewArray indexOfObject:selectedItem];
        NSInteger nextIndex = selectedIndex + 1;
        if(nextIndex > self.editingItemViewArray.count - 1) {
            //nextIndex = 0;
            [self syncEditingData];
            
            PTextGroupView *textGroup = [self.textGroupEditDelegate textGroupEditViewControllerNeedNextTextGroup];
            if(textGroup) {
                
                [self removeEditingTextGroupView];
                self.targetTextGroupView = textGroup;
                [self createEditingTextGroupView];
                
                [self selectTextView:selectedItem];
                
                [self followTemplateAnimation];
            }
            return;
        }
        else {
            id nextItem = [self.editingItemViewArray objectAtIndex:nextIndex];
            [self selectTextView:nextItem];
        }
    }
}


- (void)selectTextView:(UITextView *)textView
{
    if(selectedItem) {
        UITextView *previousTextView = (UITextView *)selectedItem;
        previousTextView.layer.borderWidth = 0;
        [self syncEditingData];
    }
    selectedItem = textView;
    textView.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    if(self.fontToolView) {
        [self.fontToolView setTargetTextView:textView];
    } else if(self.colorToolView) {
        [self.colorToolView setTargetTextView:textView];
    } else {
        [textView becomeFirstResponder];
    }
}
- (void)deselectTextView:(UITextView *)textView
{
    textView.layer.borderWidth = 0;
    selectedItem = nil;
    
    if([textView isFirstResponder]) {
        [textView resignFirstResponder];
    }
    if(self.fontToolView) {
        [self hideToolboard:self.fontToolView];
    } else if(self.colorToolView) {
        [self hideToolboard:self.colorToolView];
    }
}
- (void)showFontToolboard
{
    if(self.colorToolView) {
        [UIView animateWithDuration:0.25 delay:keyboardDuration options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.colorToolView.alpha = 0;
                         }
                         completion:^(BOOL finish){
                             if(finish) {
                                 [self.colorToolView removeFromSuperview];
                                 self.colorToolView = nil;
                             }
                         }];
    }
    if(!self.fontToolView) {
        CGRect toolboardFrame = (CGRect) {
            0,
            self.containerView.frame.size.height - keyboardFrame.size.height,
            keyboardFrame.size.width,
            keyboardFrame.size.height
        };
        
        FontToolboardView *fontView = [[FontToolboardView alloc] initWithFrame:toolboardFrame];
        fontView.translatesAutoresizingMaskIntoConstraints = NO;
        fontView.toolboardDelegate = self;
        fontView.fontToolboardDelegate = self;
        [fontView setTargetTextView:selectedItem];
        [self.containerView addSubview:fontView];
        self.fontToolView = fontView;
        
        
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(fontView);
        NSString *formatString_V = [NSString stringWithFormat:@"V:|-%li-[fontView]|", (long)toolboardFrame.origin.y];
        NSArray *toolboardView_H = [NSLayoutConstraint
                                    constraintsWithVisualFormat:@"H:|[fontView]|"
                                    options:0
                                    metrics:nil
                                    views:viewsDictionary];
        NSArray *toolboardView_V = [NSLayoutConstraint
                                    constraintsWithVisualFormat:formatString_V
                                    options:0
                                    metrics:nil
                                    views:viewsDictionary];
        
        [self.containerView addConstraints:toolboardView_H];
        [self.containerView addConstraints:toolboardView_V];
    }
    [selectedItem resignFirstResponder];
    
}

- (void)showColorToolboard
{
    if(self.fontToolView) {
        [UIView animateWithDuration:0.25 delay:keyboardDuration options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.fontToolView.alpha = 0;
                         }
                         completion:^(BOOL finish){
                             if(finish) {
                                 [self.fontToolView removeFromSuperview];
                                 self.fontToolView = nil;
                             }
                         }];
    }
    if(!self.colorToolView) {
        CGRect toolboardFrame = (CGRect) {
            0,
            self.containerView.frame.size.height - keyboardFrame.size.height,
            keyboardFrame.size.width,
            keyboardFrame.size.height
        };
        ColorToolboardView *colorView = [[ColorToolboardView alloc] initWithFrame:toolboardFrame];
        colorView.translatesAutoresizingMaskIntoConstraints = NO;
        
        colorView.toolboardDelegate = self;
        [colorView setTargetTextView:selectedItem];
        [self.containerView addSubview:colorView];
        self.colorToolView = colorView;
        
        
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(colorView);
        NSString *formatString_V = [NSString stringWithFormat:@"V:|-%li-[colorView]|", (long)toolboardFrame.origin.y];
        NSArray *toolboardView_H = [NSLayoutConstraint
                                    constraintsWithVisualFormat:@"H:|[colorView]|"
                                    options:0
                                    metrics:nil
                                    views:viewsDictionary];
        NSArray *toolboardView_V = [NSLayoutConstraint
                                    constraintsWithVisualFormat:formatString_V
                                    options:0
                                    metrics:nil
                                    views:viewsDictionary];
        
        [self.containerView addConstraints:toolboardView_H];
        [self.containerView addConstraints:toolboardView_V];
    }
    [selectedItem resignFirstResponder];
    
}

- (void)hideToolboard:(ToolboardView *)toolboardView
{
    [self hideToolboard:toolboardView translationAnimation:NO];
}
- (void)hideToolboard:(ToolboardView *)toolboardView translationAnimation:(BOOL)translationAnimation
{
    if(translationAnimation || !selectedItem) {
        
        CGFloat duration = animationDuration;
        [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             toolboardView.transform = CGAffineTransformMakeTranslation(0, toolboardView.frame.size.height);
                         }
                         completion:^(BOOL finish){
                             if(finish) {
                                 [toolboardView removeFromSuperview];
                             }
                         }];
        
        self.fontToolView = nil;
        self.colorToolView = nil;
    } else {
        
        [UIView animateWithDuration:0.25 delay:keyboardDuration options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             toolboardView.alpha = 0;
                         }
                         completion:^(BOOL finish){
                             if(finish) {
                                 [toolboardView removeFromSuperview];
                             }
                         }];
        
        self.fontToolView = nil;
        self.colorToolView = nil;
        [selectedItem becomeFirstResponder];
        
    }
}

#pragma mark FontToolboardViewDelegate
- (void)fontToolboardViewDidSelectFontName:(NSString *)fontName
{
    [self updateTextItemWithFontName:selectedItem fontName:fontName];
}

#pragma mark ToolboardViewDelegate
- (void)toolboardViewDidPreviousTextView
{
    [self previousTextView];
}
- (void)toolboardViewDidNextTextView
{
    [self nextTextView];
}


- (void)toolboardViewDidSelectFont
{
    MARK;
    if(!self.fontToolView) {
        [self showFontToolboard];
    }
}
- (void)toolboardViewDidSelectColor
{
    MARK;
    if(!self.colorToolView) {
        [self showColorToolboard];
    }
}


- (void)toolboardViewDidSelectUppercase
{
    if(selectedItem) {
        [self uppercaseToggleTextItem:selectedItem];
    }
}

- (void)toolboardViewDidClose:(id)sender
{
    [self hideToolboard:(ToolboardView *)sender];
}


#pragma mark UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if(selectedItem != textView) {
        [self selectTextView:textView];
        
        if(self.colorToolView || self.fontToolView) {
            return NO;
        }
    } else {
        if(self.fontToolView) {
            [self hideToolboard:self.fontToolView];
        } else if(self.colorToolView) {
            [self hideToolboard:self.colorToolView];
        }
    }
    [UIView animateWithDuration:0.35
                     animations:^{
                         self.clearButton.alpha = 1;
                     }];
    if (textView.inputAccessoryView == nil) {
        textView.inputAccessoryView = self.accessoryView;
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self syncEditingData];
    [UIView animateWithDuration:0.35
                     animations:^{
                         self.clearButton.alpha = 0;
                     }];
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self syncEditingData];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if([newText isEqualToString:@""]) {
        return YES;
    }
    
    NSInteger textViewIndex = [self.editingItemViewArray indexOfObject:textView];
    UIFont *originalFont = [self.editingItemFontArray objectAtIndex:textViewIndex];
    UIFont *measureFont = [UIFont fontWithName:textView.font.fontName size:originalFont.pointSize];
    
    CGFloat textHeight = textView.frame.size.height;
    
    CGRect frame = textView.bounds;
    CGSize fudgeFactor = CGSizeMake(0, 16.0);
    
    frame.size.height -= fudgeFactor.height;
    frame.size.width -= fudgeFactor.width;
    
    NSMutableAttributedString *textToMeasure = [[NSMutableAttributedString alloc] initWithString:newText];
    [textToMeasure addAttribute:NSFontAttributeName value:measureFont range:NSMakeRange(0, textToMeasure.length)];
    
    if ([textToMeasure.string hasSuffix:@"\n"])
    {
        [textToMeasure appendAttributedString:[[NSAttributedString alloc] initWithString:@"-" attributes:@{NSFontAttributeName: textView.font}]];
    }
    
    CGRect rect = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                              context:nil];
    
    
    
    
    CGSize measureSize = CGSizeMake(rect.size.width + fudgeFactor.width, rect.size.height + fudgeFactor.height);
    while (textHeight < measureSize.height) {
        
        measureFont = [UIFont fontWithName:measureFont.fontName size:floor(measureFont.pointSize * 0.95)];
        
        textToMeasure = [[NSMutableAttributedString alloc] initWithString:newText];
        [textToMeasure addAttribute:NSFontAttributeName value:measureFont range:NSMakeRange(0, textToMeasure.length)];
        
        rect = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                     context:nil];
        
        measureSize = CGSizeMake(rect.size.width + fudgeFactor.width, rect.size.height + fudgeFactor.height);
    }
    
    textView.font = measureFont;
    
    
    return YES;
    /*
    if(textHeight < measureSize.height) {
        return NO;
    }
    return YES;
    */
}




@end
