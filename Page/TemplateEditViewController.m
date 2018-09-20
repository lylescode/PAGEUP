//
//  TemplateEditViewController.m
//  Page
//
//  Created by CMR on 12/12/14.
//  Copyright (c) 2014 Page. All rights reserved.
//

#import "TemplateEditViewController.h"
#import "NSString+SentenceCaps.h"
#import "Utils.h"

@interface TemplateEditViewController ()
{
    NSInteger targetItemTag;
    id initialTargetItem;
    
    UITapGestureRecognizer *tapGesture;
    UIPanGestureRecognizer *panGesture;
    
    UIView *itemsView;
    UIView *textBorderView;
    BOOL draggingPullDown;
    
    NSInteger selectedPhotoViewIndex;
    
}
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIScrollView *itemScrollView;

@property (weak, nonatomic) IBOutlet UIView *pullHandleBar;
@property (weak, nonatomic) IBOutlet UIView *pullHandleView;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *fontButton;
@property (weak, nonatomic) IBOutlet UIButton *colorButton;
@property (weak, nonatomic) IBOutlet UIButton *uppercaseButton;

@property (strong, nonatomic) IBOutlet UIView *accessoryView;
@property (weak, nonatomic) IBOutlet UIButton *accessoryPrevButton;
@property (weak, nonatomic) IBOutlet UIButton *accessoryNextButton;
@property (weak, nonatomic) IBOutlet UIButton *accessoryDoneButton;

@property (weak, nonatomic) IBOutlet UIView *bottomCloseView;
@property (weak, nonatomic) IBOutlet UIButton *bottomCloseButton;

- (IBAction)accessoryButtonAction:(id)sender;
- (IBAction)closeButtonAction:(id)sender;
- (IBAction)bottomCloseButtonAction:(id)sender;

@property (strong, nonatomic) NSArray *editingAllItemViewArray;
@property (strong, nonatomic) NSArray *editingTextItemViewArray;
@property (strong, nonatomic) NSArray *editingTextBackgroundViewArray;
@property (strong, nonatomic) NSArray *editingTextItemFontArray;
@property (strong, nonatomic) NSArray *editingTextItemFrameArray;
@property (strong, nonatomic) NSArray *syncedTextItemViewArray;

@property (strong, nonatomic) NSArray *editingPhotoItemViewArray;
@property (strong, nonatomic) NSArray *syncedPhotoItemViewArray;
@property (strong, nonatomic) NSArray *importButtonArray;

@property (strong, nonatomic) FontToolboardView *fontToolView;
@property (strong, nonatomic) ColorToolboardView *colorToolView;
@property (strong, nonatomic) AllPhotosViewController *allPhotosViewController;

@property (weak, nonatomic) UITextView *editingTextView;
@property (weak, nonatomic) PPhotoView *editingPhotoView;
@property (weak, nonatomic) id selectedSyncItem;

- (void)orientationChanged:(NSNotification *)notification;

- (void)keyboardWillChange:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)syncEditingData;
- (void)syncEditingTextViews;
- (void)syncEditingPhotoViews;
- (void)createEditingItemViews;

- (void)sizeToFitTextItem:(UITextView *)textView;
- (void)adjustTextItemSize:(UITextView *)textView;
- (void)updateTextItemWithFontName:(UITextView *)textView fontName:(NSString *)fontName;
- (void)uppercaseToggleTextItem:(UITextView *)textView;

- (void)photoImportButtonAction:(id)sender;

- (void)previousTextView;
- (void)nextTextView;
- (void)scrollToTargetItem:(id)item;
- (void)selectTextView:(UITextView *)textView;
- (void)deselectTextView:(UITextView *)textView;

- (id)itemAtContainsPoint:(CGPoint)point;
- (void)showFontToolboard;
- (void)showColorToolboard;
- (void)hideToolboard:(ToolboardView *)toolboardView;
- (void)hideToolboard:(ToolboardView *)toolboardView translationAnimation:(BOOL)translationAnimation;

- (void)presentAllPhotos;
- (void)dismissAllPhotos;

- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer;
- (void)panGesture:(UIPanGestureRecognizer *)gestureRecognizer;

- (void)photoViewDidBeginEditing:(PPhotoView *)photoView;
- (void)photoViewDidEndEditing:(PPhotoView *)photoView;

//- (CGSize)measureSize:(UITextView *)textView;

@end

@implementation TemplateEditViewController

static CGSize viewSize;
static CGFloat contentsWidth;
static CGFloat textContentsWidth;
static CGFloat photoContentsWidth;
static CGFloat photoContentsHeight;

static CGRect keyboardFrame;
static CGFloat keyboardDuration;
static UIViewAnimationCurve keyboardCurve;

static CGFloat ScrollPullOffset;

- (id)initWithTemplateView:(PTemplate *)templateView targetItem:(id)item
{
    self = [super init];
    if (self) {
        if(item) {
            UIView *targetView = (UIView *)item;
            targetItemTag = targetView.tag;
        } else {
            targetItemTag = 0;
        }
        
        self.editingTemplateView = templateView;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    itemsView = [[UIView alloc] init];
    itemsView.clipsToBounds = YES;
    [self.itemScrollView addSubview:itemsView];
    
    textBorderView = [[UIView alloc] init];
    textBorderView.userInteractionEnabled = NO;
    [itemsView addSubview:textBorderView];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tapGesture.delegate = self;
    [self.itemScrollView addGestureRecognizer:tapGesture];
    
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    panGesture.delegate = self;
    [self.pullHandleView addGestureRecognizer:panGesture];
    
    self.pullHandleBar.layer.cornerRadius = self.pullHandleBar.frame.size.height * 0.5;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    self.bottomCloseView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(itemsView) {
        [itemsView removeFromSuperview];
    }
    
    if(self.allPhotosViewController) {
        [self.allPhotosViewController.view removeFromSuperview];
        self.allPhotosViewController = nil;
    }
    if(self.fontToolView) {
        [self.fontToolView removeFromSuperview];
        self.fontToolView = nil;
    }
    if(self.colorToolView) {
        [self.colorToolView removeFromSuperview];
        self.colorToolView = nil;
    }
    
    [self.itemScrollView removeGestureRecognizer:tapGesture];
    [self.itemScrollView removeGestureRecognizer:panGesture];
    if(self.editingTextItemViewArray) {
        for(UIView *item in self.editingTextItemViewArray) {
            [item removeFromSuperview];
        }
    }
    if(self.editingTextBackgroundViewArray) {
        for(UIView *item in self.editingTextBackgroundViewArray) {
            [item removeFromSuperview];
        }
    }
    if(self.editingPhotoItemViewArray) {
        for(UIView *item in self.editingPhotoItemViewArray) {
            [item removeFromSuperview];
        }
    }
    if(self.importButtonArray) {
        for(UIButton *button in self.importButtonArray) {
            [button removeFromSuperview];
        }
    }
    
    [self.itemScrollView removeGestureRecognizer:tapGesture];
    
    [self.pullHandleView removeGestureRecognizer:panGesture];
    
    self.editingAllItemViewArray = nil;
    self.editingTextItemViewArray = nil;
    self.editingTextBackgroundViewArray = nil;
    self.editingTextItemFontArray = nil;
    self.editingTextItemFrameArray = nil;
    self.syncedTextItemViewArray = nil;
    self.editingPhotoItemViewArray = nil;
    self.syncedPhotoItemViewArray = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    viewSize = self.view.frame.size;
    
    ScrollPullOffset = -(self.view.bounds.size.height / 8);
    
    if(self.view.frame.size.width < self.view.frame.size.height) {
        contentsWidth = self.view.frame.size.width;
        textContentsWidth = self.view.frame.size.width - 30;
        photoContentsWidth = self.view.frame.size.width;
        photoContentsHeight = self.view.frame.size.width;
    } else {
        contentsWidth = self.view.frame.size.height;
        textContentsWidth = self.view.frame.size.height - 30;
        photoContentsWidth = self.view.frame.size.height;
        photoContentsHeight = self.view.frame.size.height;
    }
    
    [self createEditingItemViews];
}

- (void)orientationChanged:(NSNotification *)notification
{
    if(CGSizeEqualToSize(self.view.frame.size, viewSize) == NO) {
        viewSize = self.view.frame.size;
        if(self.fontToolView) {
            [self hideToolboard:self.fontToolView];
        }
        if(self.colorToolView) {
            [self hideToolboard:self.colorToolView];
        }
        if(self.editingTextView) {
            [self.editingTextView becomeFirstResponder];
        }
        
        if(self.editingTemplateView) {
            itemsView.center = CGPointMake(self.view.frame.size.width * 0.5, itemsView.center.y);
            [self.itemScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.itemScrollView.contentSize.height)];
        }
        
        
    }
    
}



- (void)presentViewControllerAnimated:(BOOL)animated completion:(void(^)(void))callback
{
    [presentDelegate presentWillFinish:self];
    self.view.hidden = NO;
    
    if(animated) {
        
        CGFloat animationDelay = 0;
        CGFloat duration = 0.65;
        CGFloat damping = 0.85;
        CGFloat velocity = 0;
        
        self.containerView.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                         animations:^{
                             self.containerView.transform = CGAffineTransformIdentity;
                             self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
                         }
                         completion:^(BOOL finished){
                             if(callback != nil) {
                                 callback();
                             }
                             
                             if(initialTargetItem) {
                                 if([initialTargetItem isKindOfClass:[UITextView class]]) {
                                     [self selectTextView:(UITextView *)initialTargetItem];
                                 }
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
        CGFloat velocity = 0;
        
        [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                         animations:^{
                             self.containerView.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
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



- (void)keyboardWillChange:(NSNotification *)notification
{
    keyboardCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    keyboardDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
    
    if(keyboardFrame.origin.y < self.view.frame.size.height) {
        self.itemScrollView.contentInset = (UIEdgeInsets) {0, 0, keyboardFrame.size.height, 0};
    }
    
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    //self.itemScrollView.contentInset = UIEdgeInsetsZero;
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
        if(self.editingTextView) {
            [self uppercaseToggleTextItem:self.editingTextView];
        }
    } else if(sender == self.accessoryDoneButton) {
        [self deselectTextView:self.editingTextView];
        [self syncEditingData];
        //[self.templateEditDelegate templateEditViewControllerDidClose];
    }
}


- (IBAction)closeButtonAction:(id)sender
{
    [self deselectTextView:self.editingTextView];
    [self syncEditingData];
    [self.templateEditDelegate templateEditViewControllerDidClose];
}

- (IBAction)bottomCloseButtonAction:(id)sender {
    [self dismissAllPhotos];
}

- (void)syncEditingData
{
    [self syncEditingTextViews];
}


- (void)syncEditingTextViews
{
    NSInteger itemIndex = 0;
    for(id item in self.editingTextItemViewArray) {
        id targetItem = [self.syncedTextItemViewArray objectAtIndex:itemIndex];
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
- (void)syncEditingPhotoViews
{
    /*
    if([self.selectedSyncItem isKindOfClass:[PPhotoView class]]) {
        PPhotoView *targetPhotoView = (PPhotoView *)self.selectedSyncItem;
        CGFloat scale = targetPhotoView.frame.size.width / self.editingPhotoView.frame.size.width;
        
        targetPhotoView.photoScale = self.editingPhotoView.photoScale;
        targetPhotoView.photoTranslation = (CGPoint) {
            self.editingPhotoView.photoTranslation.x * scale,
            self.editingPhotoView.photoTranslation.y * scale
        };
    }
     
     */
}

- (void)createEditingItemViews
{
    MARK;
    if(self.editingAllItemViewArray) {
        return;
    }
    if(self.editingTemplateView) {
        CGFloat itemY = 60;
        CGFloat itemSpacing = 14;
        CGFloat labelSpacing = 6;
        
        CGFloat maxFontPointSize = 40;
        
        NSArray *templateSubviews = [self.editingTemplateView.loadedNibView subviews];
        
        UIView *templateBackgroundView = (UIView *)templateSubviews[0];
        UIColor *templateBackgroundColor = templateBackgroundView.backgroundColor;
        
        CGFloat r,g,b,a;
        [templateBackgroundColor getRed:&r green:&g blue:&b alpha:&a];
        UIColor *handleBarColor = [UIColor colorWithRed:1.-r green:1.-g blue:1.-b alpha:0.4];
        UIColor *inverseBackgroundColor = [UIColor colorWithRed:1.-r green:1.-g blue:1.-b alpha:1];
        self.pullHandleBar.backgroundColor = handleBarColor;
        
        itemsView.backgroundColor = templateBackgroundColor;
        itemsView.frame = CGRectMake(0, 0, contentsWidth, self.itemScrollView.frame.size.height);
        itemsView.center = CGPointMake(self.view.frame.size.width * 0.5, itemsView.center.y);
        
        NSMutableArray *targetItems = [NSMutableArray array];
        for(id item in templateSubviews) {
            if([item isKindOfClass:[PTextGroupView class]]) {
                //PTextGroupView *textGroupView = (PTextGroupView *)item;
                [targetItems addObject:item];
            } else if([item isKindOfClass:[PPhotoView class]]) {
                //PPhotoView *photoView = (PPhotoView *)item;
                [targetItems addObject:item];
            }
        }
        
        
        NSSortDescriptor *tagDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tag" ascending:YES];
        
        NSArray *sortedTargetItem = [targetItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:tagDescriptor]];
        NSMutableArray *editingAllItemViews = [NSMutableArray array];
        
        NSMutableArray *editingTextItemViews = [NSMutableArray array];
        NSMutableArray *editingTextBackgroundViews = [NSMutableArray array];
        NSMutableArray *editingTextItemFonts = [NSMutableArray array];
        NSMutableArray *editingTextItemFrames = [NSMutableArray array];
        NSMutableArray *syncedTextTargetItems = [NSMutableArray array];
        
        NSMutableArray *editingPhotoItemViews = [NSMutableArray array];
        NSMutableArray *syncedPhotoTargetItems = [NSMutableArray array];
        NSMutableArray *importButtons = [NSMutableArray array];
        
        UIImage *importButtonImage = [UIImage imageNamed:@"PhotoEditImportButton"];
        
        CGFloat initialOffsetY = 60;
        
        CGFloat textOffsetX = round((contentsWidth - textContentsWidth) * 0.5);
        for (id item in sortedTargetItem) {
            UIView *itemView = (UIView *)item;
            
            if(itemView.tag == targetItemTag) {
                initialOffsetY = itemY;
            }
            
            if([item isKindOfClass:[PTextGroupView class]]) {
                PTextGroupView *textGroupView = (PTextGroupView *)item;
                
                CGAffineTransform transform = textGroupView.transform;
                textGroupView.transform = CGAffineTransformIdentity;
                
                CGFloat scale = 1;
                if(textContentsWidth < textGroupView.frame.size.width) {
                    scale = textContentsWidth / textGroupView.frame.size.width;
                }
                
                textGroupView.transform = transform;
                //NSLog(@"item.tag : %li", textGroupView.tag);
                
                for(id subItem in [textGroupView subviews]) {
                    if([subItem isKindOfClass:[UILabel class]]) {
                        
                        PUILabel *targetLabel = (PUILabel *)subItem;
                        BOOL staticLabel = targetLabel.staticLabel;
                        if(!staticLabel) {
                            
                            NSLog(@"targetLabel.font : %@", targetLabel.font);
                            
                            CGFloat fontScale = 1;
                            if(targetLabel.font.pointSize > maxFontPointSize) {
                                fontScale = maxFontPointSize / targetLabel.font.pointSize;
                            }
                            CGFloat limitScale = scale * fontScale;
                            
                            CGRect targetFrame = CGRectMake(targetLabel.frame.origin.x * limitScale, targetLabel.frame.origin.y * limitScale, targetLabel.frame.size.width * limitScale, targetLabel.frame.size.height * limitScale);
                            
                            targetFrame.size = CGSizeMake(textContentsWidth, targetFrame.size.height);
                            
                            
                            UIView *backgroundView = [[UIView alloc] init];
                            backgroundView.backgroundColor = inverseBackgroundColor;
                            backgroundView.userInteractionEnabled = NO;
                            [itemsView addSubview:backgroundView];
                            
                            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, itemY, targetFrame.size.width, targetFrame.size.height)];
                            textView.delegate = self;
                            textView.returnKeyType = UIReturnKeyNext;
                            textView.scrollEnabled = NO;
                            textView.userInteractionEnabled = NO;
                            //textView.layer.borderColor = [UIColor clearColor].CGColor;
                            //textView.layer.borderWidth = 1;
                            
                            textView.backgroundColor = targetLabel.backgroundColor;
                            //textView.textAlignment = targetLabel.textAlignment;
                            textView.textColor = targetLabel.textColor;
                            
                            textView.text = targetLabel.originText;
                            textView.text = targetLabel.text;
                            textView.font = [UIFont fontWithName:targetLabel.font.fontName size:targetLabel.font.pointSize * limitScale];
                            
                            [self sizeToFitTextItem:textView];
                            
                            
                            textView.center = CGPointMake(textOffsetX + (textView.frame.size.width * 0.5), textView.center.y);
                            /*
                            if(textView.textAlignment == NSTextAlignmentLeft) {
                                textView.center = CGPointMake(textOffsetX + (textView.frame.size.width * 0.5), textView.center.y);
                            } else if(textView.textAlignment == NSTextAlignmentRight) {
                                textView.center = CGPointMake(contentsWidth - (textOffsetX + (textView.frame.size.width * 0.5)), textView.center.y);
                            } else {
                                textView.center = CGPointMake(contentsWidth * 0.5, textView.center.y);
                            }
                             */
                            
                            [itemsView addSubview:textView];
                            
                            [syncedTextTargetItems addObject:subItem];
                            [editingAllItemViews addObject:textView];
                            [editingTextItemViews addObject:textView];
                            [editingTextItemFonts addObject:[UIFont fontWithName:targetLabel.originFont.fontName size:targetLabel.originFont.pointSize * scale]];
                            [editingTextItemFrames addObject:NSStringFromCGRect(textView.frame)];
                            
                            
                            if(CGColorEqualToColor(textView.textColor.CGColor, itemsView.backgroundColor.CGColor)) {
                                backgroundView.alpha = 0.4;
                            } else {
                                backgroundView.alpha = 0;
                            }
                            [editingTextBackgroundViews addObject:backgroundView];
                            
                            backgroundView.frame = CGRectMake(0, ceil(textView.frame.origin.y - (labelSpacing / 2)), itemsView.frame.size.width, ceil(textView.frame.size.height + labelSpacing));
                            
                            itemY += ceil(textView.frame.size.height) + labelSpacing;
                            
                            if(!initialTargetItem) {
                                if(itemView.tag == targetItemTag) {
                                    initialTargetItem = textView;
                                }
                            }
                        }
                    }
                }
                NSInteger itemIndex = [sortedTargetItem indexOfObject:item];
                if(itemIndex < sortedTargetItem.count - 1) {
                    id nextItem = [sortedTargetItem objectAtIndex:itemIndex+1];
                    if(nextItem) {
                        if(![nextItem isKindOfClass:[PTextGroupView class]]) {
                            itemY += itemSpacing;
                        }
                    }
                }
                
            } else if([item isKindOfClass:[PPhotoView class]]) {
                PPhotoView *targetView = (PPhotoView *)item;
                
                CGRect targetFrame = targetView.frame;
                CGFloat scale = photoContentsWidth / targetFrame.size.width;
                
                if(photoContentsHeight < targetFrame.size.height * scale) {
                    scale = photoContentsHeight / targetFrame.size.height;
                }
                
                CGRect photoViewFrame;
                if(targetFrame.size.width > targetFrame.size.height) {
                    photoViewFrame = CGRectMake(0, itemY, photoContentsWidth, ceil(photoContentsWidth * 0.75));
                } else {
                    photoViewFrame = CGRectMake(0, itemY, photoContentsWidth, photoContentsWidth);
                }
                
                UIImage *targetPhoto = targetView.photoImage;
                UIImageView *photoView = [[UIImageView alloc] initWithFrame:photoViewFrame];
                photoView.clipsToBounds = YES;
                photoView.userInteractionEnabled = YES;
                photoView.contentMode = UIViewContentModeScaleAspectFill;
                photoView.image = targetPhoto;
                photoView.center = CGPointMake(contentsWidth * 0.5, photoView.center.y);
                
                /*
                PPhotoView *photoView = [[PPhotoView alloc] initWithFrame:CGRectMake(0, itemY, ceil(targetFrame.size.width * scale), ceil(targetFrame.size.height * scale))];
                photoView.photoImage = targetPhoto;
                photoView.photoScale = targetView.photoScale;
                photoView.photoTranslation = (CGPoint) {
                    targetView.photoTranslation.x * scale,
                    targetView.photoTranslation.y * scale
                };
                
                //UIImageView *photoView = [[UIImageView alloc] initWithFrame:CGRectMake(10, itemY, targetFrame.size.width * scale, targetFrame.size.height * scale)];
                //photoView.image = targetPhoto;
                
                
                photoView.center = CGPointMake(contentsWidth * 0.5, photoView.center.y);
                photoView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
                //photoView.backgroundColor = [UIColor colorWithHue:(float)(rand() % 100) / 100 saturation:1.0 brightness:1.0 alpha:1.0];
                */
                
                UIButton *importButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [importButton setImage:importButtonImage forState:UIControlStateNormal];
                [importButton addTarget:self action:@selector(photoImportButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                importButton.frame = CGRectMake(photoView.frame.size.width - 49, photoView.frame.size.height - 49, 44, 44);
                [importButtons addObject:importButton];
                [photoView addSubview:importButton];
                
                [itemsView addSubview:photoView];
                
                [syncedPhotoTargetItems addObject:item];
                [editingAllItemViews addObject:photoView];
                [editingPhotoItemViews addObject:photoView];
                
                if(itemView.tag == targetItemTag) {
                    initialTargetItem = photoView;
                }
                
                itemY += ceil(photoView.frame.size.height) + itemSpacing;
                //NSLog(@"item.tag : %li", photoView.tag);
            }
        }
        
        
        if(initialTargetItem == nil) {
            initialTargetItem = [editingTextItemViews firstObject];
        }
        
        itemsView.frame = CGRectMake(itemsView.frame.origin.x, itemsView.frame.origin.y, contentsWidth, itemY + self.view.frame.size.height);
        [self.itemScrollView setContentSize:CGSizeMake(self.view.frame.size.width, itemY)];
        [self.itemScrollView setContentOffset:CGPointMake(0, initialOffsetY - 60)];
        
        //NSLog(@"initialOffsetY : %f", initialOffsetY - 60);
        
        self.syncedTextItemViewArray = [NSArray arrayWithArray:syncedTextTargetItems];
        self.editingAllItemViewArray = [NSArray arrayWithArray:editingAllItemViews];
        self.editingTextItemViewArray = [NSArray arrayWithArray:editingTextItemViews];
        self.editingTextBackgroundViewArray = [NSArray arrayWithArray:editingTextBackgroundViews];
        self.editingTextItemFontArray = [NSArray arrayWithArray:editingTextItemFonts];
        
        self.editingTextItemFrameArray = [NSArray arrayWithArray:editingTextItemFrames];
        
        self.syncedPhotoItemViewArray = [NSArray arrayWithArray:syncedPhotoTargetItems];
        self.editingPhotoItemViewArray = [NSArray arrayWithArray:editingPhotoItemViews];
        
        self.importButtonArray = [NSArray arrayWithArray:importButtons];
    }
}


- (void)photoImportButtonAction:(id)sender
{
    selectedPhotoViewIndex = [self.importButtonArray indexOfObject:(UIButton *)sender];
    [self presentAllPhotos];
    if(self.editingTextView) {
        [self deselectTextView:self.editingTextView];
    }
    
}
- (void)previousTextView
{
    if(self.editingTextView) {
        NSInteger selectedIndex = [self.editingTextItemViewArray indexOfObject:self.editingTextView];
        NSInteger nextIndex = selectedIndex - 1;
        if(selectedIndex == 0) {
            nextIndex = self.editingTextItemViewArray.count - 1;
        }
        id nextItem = [self.editingTextItemViewArray objectAtIndex:nextIndex];
        [self selectTextView:(UITextView *)nextItem];
    }
}
- (void)nextTextView
{
    if(self.editingTextView) {
        NSInteger selectedIndex = [self.editingTextItemViewArray indexOfObject:self.editingTextView];
        NSInteger nextIndex = selectedIndex + 1;
        if(selectedIndex == self.editingTextItemViewArray.count - 1) {
            nextIndex = 0;
        }
        id nextItem = [self.editingTextItemViewArray objectAtIndex:nextIndex];
        [self selectTextView:(UITextView *)nextItem];
    }
}

- (void)scrollToTargetItem:(id)item
{
    UIView *itemView = (UIView *)item;
    //NSLog(@"itemView.frame.origin.y : %f", itemView.frame.origin.y);
    
    CGPoint targetOffset = CGPointMake(0, MAX(0, itemView.frame.origin.y - 80));
    
    CGPoint bottomOffset = CGPointMake(0, (self.itemScrollView.contentSize.height - self.itemScrollView.bounds.size.height) + self.itemScrollView.contentInset.bottom);
    
    if(targetOffset.y > bottomOffset.y) {
        targetOffset = bottomOffset;
    }
    
    //NSLog(@"bottomOffset : %@", NSStringFromCGPoint(bottomOffset));
    //NSLog(@"scrollToTargetItem : %@", NSStringFromCGPoint(targetOffset));
    
    CGFloat duration = animationDuration;
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.itemScrollView.contentOffset = targetOffset;
                     }
                     completion:^(BOOL finish){
                     }];
    
}

- (void)selectTextView:(UITextView *)textView
{
    self.itemScrollView.contentInset = (UIEdgeInsets) {0, 0, keyboardFrame.size.height, 0};
    
    if(self.editingTextView == textView) {
        return;
    }
    if(self.editingTextView) {
        self.editingTextView.inputAccessoryView = nil;
        
        UIView *oldBackgroundView = [self.editingTextBackgroundViewArray objectAtIndex:[self.editingTextItemViewArray indexOfObject:self.editingTextView]];
        if(CGColorEqualToColor(self.editingTextView.textColor.CGColor, itemsView.backgroundColor.CGColor)) {
            oldBackgroundView.alpha = 0.4;
        } else {
            oldBackgroundView.alpha = 0;
        }
        
        [self syncEditingData];
    }
    self.editingTextView = textView;
    self.selectedSyncItem = [self.syncedTextItemViewArray objectAtIndex:[self.editingTextItemViewArray indexOfObject:textView]];
    
    UIView *backgroundView = [self.editingTextBackgroundViewArray objectAtIndex:[self.editingTextItemViewArray indexOfObject:textView]];
    
    [UIView animateWithDuration:0.45 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if(CGColorEqualToColor(self.editingTextView.textColor.CGColor, itemsView.backgroundColor.CGColor)) {
                             backgroundView.alpha = 0.45;
                         } else {
                             backgroundView.alpha = 0.2;
                         }
                     }
                     completion:nil];
    
    textView.userInteractionEnabled = YES;
    //textView.layer.borderColor = self.pullHandleBar.backgroundColor.CGColor;
    
    if(self.fontToolView) {
        [self.fontToolView setTargetTextView:textView];
    } else if(self.colorToolView) {
        [self.colorToolView setTargetTextView:textView];
    } else {
        [textView becomeFirstResponder];
    }
    [self scrollToTargetItem:textView];
}

- (void)deselectTextView:(UITextView *)textView
{
    if(!self.editingTextView) {
        return;
    }
    textView.inputAccessoryView = nil;
    
    UIView *oldBackgroundView = [self.editingTextBackgroundViewArray objectAtIndex:[self.editingTextItemViewArray indexOfObject:self.editingTextView]];
    
    
    [UIView animateWithDuration:0.45 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if(CGColorEqualToColor(self.editingTextView.textColor.CGColor, itemsView.backgroundColor.CGColor)) {
                             oldBackgroundView.alpha = 0.4;
                         } else {
                             oldBackgroundView.alpha = 0;
                         }
                     }
                     completion:nil];
    
    if([textView isFirstResponder]) {
        [textView resignFirstResponder];
    }
    
    self.editingTextView = nil;
    self.selectedSyncItem = nil;
    
    if(self.fontToolView) {
        [self hideToolboard:self.fontToolView];
    } else if(self.colorToolView) {
        [self hideToolboard:self.colorToolView];
    }
}

- (void)updateTextItemWithFontName:(UITextView *)textView fontName:(NSString *)fontName
{
    /*
    NSInteger textViewIndex = [self.editingTextItemViewArray indexOfObject:textView];
    UIFont *originalFont = [self.editingTextItemFontArray objectAtIndex:textViewIndex];
    //PUILabel *targetLabel = [self.syncedTextItemViewArray objectAtIndex:textViewIndex];
    
    textView.frame = CGRectFromString([self.editingTextItemFrameArray objectAtIndex:textViewIndex]);
    
    UIFont *newFont = [UIFont fontWithName:fontName size:originalFont.pointSize];
    NSString *originalText = textView.text;
    
    CGSize fudgeFactor;
    fudgeFactor = CGSizeMake(0, 16.0);
    
    CGFloat textWidth = textContentsWidth;
    CGFloat textHeight = textView.frame.size.height;
    
    CGRect frame = textView.frame;
    
    frame.size.height -= fudgeFactor.height;
    frame.size.width -= fudgeFactor.width;
    
    NSMutableAttributedString *attrStr;
    
    attrStr = [[NSMutableAttributedString alloc] initWithString:originalText];
    [attrStr addAttribute:NSFontAttributeName value:newFont range:NSMakeRange(0, attrStr.length)];
    
    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                        context:nil];
    
    CGSize measureSize = CGSizeMake(rect.size.width + fudgeFactor.width, rect.size.height + fudgeFactor.height);
    
    textView.frame = (CGRect){
        textView.frame.origin.x,
        textView.frame.origin.y,
        measureSize.width,
        measureSize.height
    };
    */
    
    [self sizeToFitTextItem:textView];
}
- (void)adjustTextItemSize:(UITextView *)textView
{
    
    NSInteger textViewIndex = [self.editingTextItemViewArray indexOfObject:textView];
    
    CGSize measureSize = textView.frame.size;
    measureSize.height = ceilf([textView sizeThatFits:textView.frame.size].height);
    
    CGRect textViewFrame = (CGRect){
        textView.frame.origin.x,
        textView.frame.origin.y,
        measureSize.width,
        measureSize.height
    };
    
    CGFloat diffHeight = measureSize.height - CGRectGetHeight(textView.frame);
    
    NSLog(@"텍스트뷰 크기 변경 : %f", (float)diffHeight);
    
    textView.frame = textViewFrame;
    [self.itemScrollView setContentSize:CGSizeMake(self.itemScrollView.contentSize.width, self.itemScrollView.contentSize.height + diffHeight)];
    itemsView.frame = (CGRect) {
        itemsView.frame.origin.x,
        itemsView.frame.origin.y,
        itemsView.frame.size.width,
        itemsView.frame.size.height + diffHeight
    };
    
    NSMutableArray *editingTextItemFrames = [NSMutableArray arrayWithArray:self.editingTextItemFrameArray];
    UIView *backgroundView = [self.editingTextBackgroundViewArray objectAtIndex:textViewIndex];
    
    editingTextItemFrames[textViewIndex] = NSStringFromCGRect(textViewFrame);
    
    for(NSInteger i = textViewIndex + 1 ; i < self.editingTextBackgroundViewArray.count ; i++) {
        UIView *otherBackgroundView = [self.editingTextBackgroundViewArray objectAtIndex:i];
        CGRect otherBackgroundFrame = otherBackgroundView.frame;
        otherBackgroundFrame = (CGRect) {
            otherBackgroundFrame.origin.x,
            otherBackgroundFrame.origin.y + diffHeight,
            otherBackgroundFrame.size.width,
            otherBackgroundFrame.size.height
        };
        otherBackgroundView.frame = otherBackgroundFrame;
    }
    
    for(NSInteger i = textViewIndex + 1 ; i < editingTextItemFrames.count ; i++) {
        CGRect textItemFrame = CGRectFromString(editingTextItemFrames[i]);
        textItemFrame = (CGRect) {
            textItemFrame.origin.x,
            textItemFrame.origin.y + diffHeight,
            textItemFrame.size.width,
            textItemFrame.size.height
        };
        editingTextItemFrames[i] = NSStringFromCGRect(textItemFrame);
    }
    self.editingTextItemFrameArray = [NSArray arrayWithArray:editingTextItemFrames];
    
    CGFloat duration = animationDuration;
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         backgroundView.frame = (CGRect) {
                             backgroundView.frame.origin.x,
                             backgroundView.frame.origin.y,
                             backgroundView.frame.size.width,
                             backgroundView.frame.size.height + diffHeight
                         };
                     }
                     completion:^(BOOL finish){
                     }];
    
    
    
    NSInteger itemIndex = [self.editingAllItemViewArray indexOfObject:textView];
    
    for(NSInteger i = itemIndex + 1 ; i < self.editingAllItemViewArray.count ; i++) {
        UIView *otherItemView = self.editingAllItemViewArray[i];
        CGRect otherItemFrame = otherItemView.frame;
        otherItemFrame = (CGRect) {
            otherItemFrame.origin.x,
            otherItemFrame.origin.y + diffHeight,
            otherItemFrame.size.width,
            otherItemFrame.size.height
        };
        
        [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             otherItemView.frame = otherItemFrame;
                         }
                         completion:^(BOOL finish){
                         }];
    }
    
}

- (void)sizeToFitTextItem:(UITextView *)textView
{
    CGRect textViewFrame = textView.frame;
    
    textView.textContainer.lineFragmentPadding = 0;
    //textView.textContainerInset = UIEdgeInsetsZero;
    [textView sizeToFit];
    
    textView.frame = CGRectMake(textViewFrame.origin.x, textViewFrame.origin.y, textViewFrame.size.width, textView.frame.size.height);
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
    //[self updateTextItemWithFontName:textView fontName:textView.font.fontName];
    [self adjustTextItemSize:textView];
}

- (id)itemAtContainsPoint:(CGPoint)point
{
    for(id item in self.editingTextItemViewArray)
    {
        UIView *itemView = (UIView *)item;
        if(CGRectContainsPoint(itemView.frame, point)) {
            return item;
        }
    }
    return nil;
}



- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded)
    {
        CGPoint tapPoint = [gestureRecognizer locationInView:self.itemScrollView];
        if(!CGRectContainsPoint(itemsView.frame, tapPoint)) {
            [self syncEditingData];
            [self.templateEditDelegate templateEditViewControllerDidClose];
            return;
        }
        
        CGPoint convertPoint = [itemsView convertPoint:tapPoint fromView:self.itemScrollView];
        id item = [self itemAtContainsPoint:convertPoint];
        if([item isKindOfClass:[UITextView class]]) {
            if(item == self.editingTextView) {
                if(self.fontToolView) {
                    [self hideToolboard:self.fontToolView];
                } else if(self.colorToolView) {
                    [self hideToolboard:self.colorToolView];
                }
                return;
            }
            [self selectTextView:(UITextView *)item];
            return;
        }
        if(self.editingTextView) {
            [self deselectTextView:self.editingTextView];
        }
    }
    
}

- (void)panGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:self.view];
        
        
        CGFloat scrollViewY = MAX(0, self.containerView.frame.origin.y + translation.y);
        
        if(scrollViewY < 50 || translation.x < 0) {
            draggingPullDown = NO;
        } else {
            draggingPullDown = YES;
        }
        
        self.containerView.transform = CGAffineTransformMakeTranslation(0, scrollViewY);
        
        [gestureRecognizer setTranslation:CGPointZero inView:self.view];
        
        CGFloat offsetScale = scrollViewY / self.view.frame.size.height;
        CGFloat alphaScale = 1 - offsetScale;
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7 * alphaScale];
        
    } else if([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        if(draggingPullDown) {
            [self syncEditingData];
            [self.templateEditDelegate templateEditViewControllerDidClose];
        } else {
            
            CGFloat delay = 0;
            CGFloat duration = 0.5;
            
            [UIView animateWithDuration:duration delay:delay usingSpringWithDamping:0.95 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.containerView.transform = CGAffineTransformIdentity;
                                 self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
                             }
                             completion:^(BOOL finished){
                                 if(finished) {
                                 }
                             }];
        }
    }
    
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    
    return YES;
}

- (void)photoViewDidBeginEditing:(PPhotoView *)photoView
{
    self.itemScrollView.scrollEnabled = NO;
    
    if(self.editingTextView) {
        [self.editingTextView resignFirstResponder];
    }
    if(self.editingPhotoView == photoView) {
        [self photoViewDidEndEditing:self.editingPhotoView];
        return;
    }
    if(self.editingPhotoView) {
        [self photoViewDidEndEditing:self.editingPhotoView];
    }
    
    photoView.layer.borderColor = [UIColor colorWithRed:0.947 green:0.277 blue:0.109 alpha:0.5].CGColor;
    photoView.layer.borderWidth = 2;
    
    [itemsView bringSubviewToFront:photoView];
    photoView.cropMode = YES;
    
    self.editingPhotoView = photoView;
    self.selectedSyncItem = [self.syncedPhotoItemViewArray objectAtIndex:[self.editingPhotoItemViewArray indexOfObject:photoView]];
    
    
    CGPoint targetOffset = CGPointMake(0, self.editingPhotoView.center.y - (self.itemScrollView.frame.size.height * 0.5));
    
    [self.itemScrollView setContentOffset:targetOffset animated:YES];
    
}
- (void)photoViewDidEndEditing:(PPhotoView *)photoView
{
    self.itemScrollView.scrollEnabled = YES;
    
    photoView.layer.borderColor = [UIColor clearColor].CGColor;
    photoView.layer.borderWidth = 0;
    
    photoView.cropMode = NO;
    [itemsView insertSubview:photoView atIndex:[self.editingPhotoItemViewArray indexOfObject:photoView]];
    
    [self syncEditingPhotoViews];
    
    self.editingPhotoView = nil;
    self.selectedSyncItem = nil;
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
        [fontView setTargetTextView:self.editingTextView];
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
    [self.editingTextView resignFirstResponder];
    
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
        [colorView setTargetTextView:self.editingTextView];
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
    [self.editingTextView resignFirstResponder];
    
}

- (void)hideToolboard:(ToolboardView *)toolboardView
{
    [self hideToolboard:toolboardView translationAnimation:NO];
}
- (void)hideToolboard:(ToolboardView *)toolboardView translationAnimation:(BOOL)translationAnimation
{
    if(translationAnimation || !self.editingTextView) {
        
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
        [self.editingTextView becomeFirstResponder];
        
    }
}
- (void)presentAllPhotos
{
    if(self.allPhotosViewController) {
        return;
    }
    
    CGFloat animationDelay = 0;
    CGFloat duration = 0.65;
    CGFloat damping = 0.85;
    CGFloat velocity = 0;
    
    UIView *dimmedView = [[UIView alloc] initWithFrame:self.view.bounds];
    dimmedView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:dimmedView];
    
    AllPhotosViewController *allPhotosVC = [[AllPhotosViewController alloc] init];
    allPhotosVC.allPhotosDelegate = self;
    allPhotosVC.view.frame = self.view.bounds;
    allPhotosVC.view.backgroundColor = [UIColor blackColor];
    
    UIEdgeInsets currentInsets = allPhotosVC.collectionView.contentInset;
    allPhotosVC.collectionView.contentInset = (UIEdgeInsets){
        .top = 58,
        .bottom = 47,
        .left = currentInsets.left,
        .right = currentInsets.right
    };
    
    currentInsets = allPhotosVC.collectionView.scrollIndicatorInsets;
    allPhotosVC.collectionView.scrollIndicatorInsets  = (UIEdgeInsets){
        .top = 58,
        .bottom = 47,
        .left = currentInsets.left,
        .right = currentInsets.right
    };
    
    
    [self.view addSubview:allPhotosVC.view];
    [self.view bringSubviewToFront:self.bottomCloseView];
    self.bottomCloseView.hidden = NO;
    
    self.allPhotosViewController = allPhotosVC;
    
    dimmedView.alpha = 0;
    
    UIView *allPhotosView = self.allPhotosViewController.view;
    CGAffineTransform fromTransform = CGAffineTransformMakeScale(1, 1);
    fromTransform = CGAffineTransformTranslate(fromTransform, 0, self.view.frame.size.height);
    
    allPhotosView.transform = fromTransform;
    self.bottomCloseView.transform = CGAffineTransformMakeTranslation(0, self.bottomCloseView.frame.size.height);
    
    [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         dimmedView.alpha = 0.85;
                         allPhotosView.transform = CGAffineTransformIdentity;
                         self.bottomCloseView.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished){
                         if(finished) {
                             [dimmedView removeFromSuperview];
                         }
                     }];
}

- (void)dismissAllPhotos
{
    if(!self.allPhotosViewController) {
        return;
    }
    
    CGFloat animationDelay = 0;
    CGFloat duration = 0.55;
    CGFloat damping = 1;
    CGFloat velocity = 0;
    
    UIView *dimmedView = [[UIView alloc] initWithFrame:self.view.bounds];
    dimmedView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:dimmedView];
    
    UIView *allPhotosView = self.allPhotosViewController.view;
    [self.view bringSubviewToFront:allPhotosView];
    [self.view bringSubviewToFront:self.bottomCloseView];
    
    dimmedView.alpha = 0.85;
    
    CGAffineTransform toTransform = CGAffineTransformMakeScale(1, 1);
    toTransform = CGAffineTransformTranslate(toTransform, 0, self.view.frame.size.height);
    
    [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         dimmedView.alpha = 0;
                         allPhotosView.transform = toTransform;
                         
                         self.bottomCloseView.transform = CGAffineTransformMakeTranslation(0, self.bottomCloseView.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         if(finished) {
                             [dimmedView removeFromSuperview];
                             
                             [self.allPhotosViewController.view removeFromSuperview];
                             self.allPhotosViewController = nil;
                         }
                     }];
}
#pragma mark FontToolboardViewDelegate
- (void)fontToolboardViewDidSelectFontName:(NSString *)fontName
{
    UIFont *newFont = [UIFont fontWithName:fontName size:self.editingTextView.font.pointSize];
    self.editingTextView.font = newFont;
    //[self updateTextItemWithFontName:self.editingTextView fontName:fontName];
    [self adjustTextItemSize:self.editingTextView];
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
    if(!self.fontToolView) {
        [self showFontToolboard];
    }
}
- (void)toolboardViewDidSelectColor
{
    if(!self.colorToolView) {
        [self showColorToolboard];
    }
}

- (void)toolboardViewDidSelectUppercase
{
    if(self.editingTextView) {
        [self uppercaseToggleTextItem:self.editingTextView];
    }
}

- (void)toolboardViewDidClose:(id)sender
{
    [self hideToolboard:(ToolboardView *)sender];
}


#pragma mark - AllPhotosViewControllerDelegate

- (void)allPhotosViewControllerDidDone
{
    [self dismissAllPhotos];
}

- (void)allPhotosViewControllerDidSelectPhotoAsset:(PHAsset *)asset thumbnailImage:(UIImage *)thumbnailImage
{
    
    [self.projectResource replaceAssetAtIndex:selectedPhotoViewIndex withAsset:asset thumbnailImage:thumbnailImage
                                   completion:^{
                                       UIImageView *photoView = [self.editingPhotoItemViewArray objectAtIndex:selectedPhotoViewIndex];
                                       photoView.image = thumbnailImage;
                                       PPhotoView *targetPhotoView = [self.syncedPhotoItemViewArray objectAtIndex:selectedPhotoViewIndex];
                                       [self.templateEditDelegate templateEditViewControllerDidReplacePhoto:targetPhotoView photoIndex:selectedPhotoViewIndex];
                                       
                                       [self dismissAllPhotos];
                                   }];
    //[self addPhotoAsset:asset thumbnailImage:thumbnailImage];
}

- (void)allPhotosViewControllerDidDeselectPhotoAsset:(PHAsset *)asset
{
    [self dismissAllPhotos];
    //[self removePhotoAsset:asset];
}


#pragma mark UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
        
        if(self.colorToolView || self.fontToolView) {
            return NO;
        }
 
    if (textView.inputAccessoryView == nil) {
        textView.inputAccessoryView = self.accessoryView;
    }
    
    textView.userInteractionEnabled = YES;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    textView.userInteractionEnabled = NO;
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    //SLog(@"contentSize", self.itemScrollView.contentSize);
    //PLog(@"targetOffset", targetOffset);
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
}

- (void)textViewDidChange:(UITextView *)textView
{
    /*
    if(self.selectedSyncItem) {
        UILabel *targetLabel = (UILabel *)self.selectedSyncItem;
        targetLabel.text = textView.text;
    }
     */
    [self adjustTextItemSize:textView];

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if([text isEqualToString:@"\n"]) {
        /*
        if(self.editingTextView == [self.editingTextItemViewArray lastObject]) {
            [self deselectTextView:self.editingTextView];
            return NO;
        }
        
        [self nextTextView];
        return NO;
         */
    }
    if([newText isEqualToString:@""]) {
        return YES;
    }
    
    /*
     if ([textToMeasure.string hasSuffix:@"\n"])
     {
     [textToMeasure appendAttributedString:[[NSAttributedString alloc] initWithString:@"-" attributes:@{NSFontAttributeName: textView.font}]];
     }
     */
    
    /*
    NSInteger textViewIndex = [self.editingTextItemViewArray indexOfObject:textView];
    UIFont *originalFont = [self.editingTextItemFontArray objectAtIndex:textViewIndex];
    UIFont *measureFont = textView.font; //[UIFont fontWithName:textView.font.fontName size:originalFont.pointSize];
    
    CGFloat textWidth = textContentsWidth;
    CGFloat textHeight = textView.frame.size.height;
    
    CGRect frame = textView.bounds;
    //CGSize fudgeFactor = CGSizeMake(0, 16.0);
    
    NSMutableAttributedString *blankMeasure = [[NSMutableAttributedString alloc] initWithString:@" "];
    [blankMeasure addAttribute:NSFontAttributeName value:measureFont range:NSMakeRange(0, blankMeasure.length)];
    CGRect blankRect = [blankMeasure boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                  context:nil];
    NSLog(@"blank Rect : %@", NSStringFromCGRect(blankRect));
    
    CGSize fudgeFactor = CGSizeMake(20.0, 20.0);
    
    frame.size.width -= fudgeFactor.width;
    frame.size.height -= fudgeFactor.height;
    
    NSMutableAttributedString *textToMeasure = [[NSMutableAttributedString alloc] initWithString:newText];
    [textToMeasure addAttribute:NSFontAttributeName value:measureFont range:NSMakeRange(0, textToMeasure.length)];
    CGRect rect = [textToMeasure boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                              context:nil];
    
    
    
    
    CGSize measureSize = CGSizeMake(ceilf(rect.size.width) + fudgeFactor.width, ceilf(rect.size.height) + fudgeFactor.height);
    
    CGRect textViewFrame = (CGRect){
        textView.frame.origin.x,
        textView.frame.origin.y,
        measureSize.width,
        measureSize.height
    };
    */
    
    
    // 텍스트뷰 크기보다 커지면 폰트사이즈를 줄여주는 코드
    /*
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
    */
    
    return YES;
    /*
    if(textHeight < measureSize.height) {
        return NO;
    }
    return YES;
     */
}




#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.y < 0) {
    }
    
    self.pullHandleBar.transform = CGAffineTransformMakeTranslation(0, MAX(0, scrollView.contentOffset.y * -1));
    
    /*
    if(self.editingTextView) {
        
        CGRect convertFrame = [self.view convertRect:self.editingTextView.frame fromView:[self.editingTextView superview]];
        if(CGRectContainsRect(self.view.bounds, convertFrame) == NO) {
            [self deselectTextView:self.editingTextView];
        }
    }
     */
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if (offsetY < ScrollPullOffset) {
        scrollView.scrollEnabled = NO;
        [scrollView setContentOffset:CGPointMake(0, offsetY)];
        
        [self syncEditingData];
        [self.templateEditDelegate templateEditViewControllerDidClose];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if(self.editingTextView) {
        if(ABS(velocity.y) > 1.15) {
            [self deselectTextView:self.editingTextView];
        }
        
    }
}

@end
