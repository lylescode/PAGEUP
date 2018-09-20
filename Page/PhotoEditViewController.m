//
//  PhotoEditViewController.m
//  Page
//
//  Created by CMR on 3/25/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "PhotoEditViewController.h"

@interface PhotoEditViewController ()
{
    UIView *borderView;
    UITapGestureRecognizer *tapGesture;
    UIPanGestureRecognizer *panGesture;
    UIPinchGestureRecognizer *pinchGesture;
    NSInteger photoAssetIndex;
    
    BOOL hiddenBrightSlider;
}
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *brightnessButtonRound;
@property (weak, nonatomic) IBOutlet UIView *importButtonRound;
@property (weak, nonatomic) IBOutlet UIButton *importButton;
@property (weak, nonatomic) IBOutlet UIButton *brightnessButton;

@property (weak, nonatomic) IBOutlet UIView *bottomConfirmView;
@property (weak, nonatomic) IBOutlet UIView *bottomCloseView;

@property (weak, nonatomic) IBOutlet UIButton *bottomCloseButton;
@property (strong, nonatomic) IBOutlet PhotoBrightnessSliderView *brightnessSlider;

@property (weak, nonatomic) PPhotoView *targetPhotoView;
@property (strong, nonatomic) PPhotoView *editingPhotoView;
@property (strong, nonatomic) AllPhotosViewController *allPhotosViewController;

- (IBAction)brightnessButtonAction:(id)sender;
- (IBAction)importButtonAction:(id)sender;

- (IBAction)bottomCloseButtonAction:(id)sender;

- (void)presentAllPhotos;
- (void)dismissAllPhotos;

- (void)hiddenBrightnessSlider:(BOOL)hidden;

- (void)syncEditingData;
- (void)createEditingPhotoView;
- (void)beginCropMode;
- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer;
- (void)panGesture:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)pinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer;

@end

@implementation PhotoEditViewController

static CGFloat photoContentsWidth;
static CGFloat photoContentsHeight;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    borderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    borderView.userInteractionEnabled = NO;
    borderView.layer.borderColor = [UIColor colorWithRed:0.235 green:0.482 blue:0.992 alpha:1].CGColor;
    borderView.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    borderView.backgroundColor = [UIColor clearColor];
    borderView.hidden = YES;
    [self.containerView addSubview:borderView];
    
    self.brightnessButtonRound.layer.cornerRadius = self.importButtonRound.frame.size.width / 2;
    self.brightnessButtonRound.backgroundColor = [UIColor colorWithRed:0.11764706 green:0.11764706 blue:0.11764706 alpha:1];
    self.importButtonRound.layer.cornerRadius = self.importButtonRound.frame.size.width / 2;
    self.importButtonRound.backgroundColor = [UIColor colorWithRed:0.11764706 green:0.11764706 blue:0.11764706 alpha:1];
    
    self.brightnessButtonRound.hidden = YES;
    self.importButtonRound.hidden = YES;
    
    self.bottomConfirmView.hidden = YES;
    self.bottomCloseView.hidden = YES;
    
    hiddenBrightSlider = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if(self.editingPhotoView) {
        self.editingPhotoView.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.5);
        borderView.center = self.editingPhotoView.center;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.view.frame.size.width < self.view.frame.size.height) {
        photoContentsWidth = self.view.frame.size.width - 50;
        photoContentsHeight = self.view.frame.size.width - 50;
    } else {
        photoContentsWidth = self.view.frame.size.height - 50;
        photoContentsHeight = self.view.frame.size.height - 50;
    }
    
    [self createEditingPhotoView];
    
}

- (void)dealloc
{
    if(self.editingPhotoView) {
        [self.editingPhotoView removeFromSuperview];
        self.editingPhotoView = nil;
    }
    [self.containerView removeGestureRecognizer:tapGesture];
    [self.containerView removeGestureRecognizer:panGesture];
    self.targetPhotoView = nil;
    
    if(self.allPhotosViewController) {
        [self.allPhotosViewController.view removeFromSuperview];
        self.allPhotosViewController = nil;
    }
}



- (void)presentViewControllerAnimated:(BOOL)animated completion:(void(^)(void))callback
{
    [presentDelegate presentWillFinish:self];
    self.view.hidden = NO;
    
    if(animated) {
        
        CGFloat animationDelay = 0;
        CGFloat duration = 0.55;
        CGFloat damping = 1;
        CGFloat velocity = 1;
        
        if(self.editingPhotoView) {
            
            self.editingPhotoView.transform = CGAffineTransformIdentity;
            
            CGRect convertTargetPhotoViewFrame = [self.containerView convertRect:self.targetPhotoView.frame fromView:[self.targetPhotoView superview]];
            CGPoint convertTargetPhotoViewCenter = [self.containerView convertPoint:self.targetPhotoView.center fromView:[self.targetPhotoView superview]];
            
            CGRect editingPhotoViewFrame = self.editingPhotoView.frame;
            CGPoint editingPhotoViewCenter = self.editingPhotoView.center;
            
            CGPoint translation = CGPointMake(convertTargetPhotoViewCenter.x - editingPhotoViewCenter.x, convertTargetPhotoViewCenter.y - editingPhotoViewCenter.y);
            CGFloat resizeScale = convertTargetPhotoViewFrame.size.width / editingPhotoViewFrame.size.width;
            
            //self.editingPhotoView.transform = CGAffineTransformMakeScale(resizeScale, resizeScale);
            
            self.editingPhotoView.transform = CGAffineTransformTranslate(self.editingPhotoView.transform, translation.x, translation.y);
            self.editingPhotoView.transform = CGAffineTransformScale(self.editingPhotoView.transform, resizeScale, resizeScale);
            
            [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                             animations:^{
                                 self.editingPhotoView.transform = CGAffineTransformIdentity;
                             }
                             completion:^(BOOL finished){
                                 [self beginCropMode];
                             }];
            
        }
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                         animations:^{
                             self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
                         }
                         completion:^(BOOL finished){
                             
                             if(callback != nil) {
                                 callback();
                             }
                             [presentDelegate presentDidFinish:self];
                         }];
        
        self.brightnessButtonRound.hidden = NO;
        self.brightnessButtonRound.alpha = 0;
        self.brightnessButtonRound.transform = CGAffineTransformMakeTranslation(0, 50);
        self.importButtonRound.hidden = NO;
        self.importButtonRound.alpha = 0;
        self.importButtonRound.transform = CGAffineTransformMakeTranslation(0, 50);
        [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                         animations:^{
                             self.brightnessButtonRound.alpha = 1;
                             self.brightnessButtonRound.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished){
                         }];
        animationDelay += 0.05;
        [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                         animations:^{
                             self.importButtonRound.alpha = 1;
                             self.importButtonRound.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished){
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
        
        [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             borderView.alpha = 0;
                             self.brightnessButtonRound.alpha = 0;
                             self.importButtonRound.alpha = 0;
                             self.brightnessButtonRound.transform = CGAffineTransformMakeTranslation(0, 25);
                             self.importButtonRound.transform = CGAffineTransformMakeTranslation(0, 25);
                             
                             self.brightnessSlider.alpha = 0;
                             self.brightnessSlider.transform = CGAffineTransformMakeTranslation(0, 25);
                         }
                         completion:^(BOOL finished){
                         }];
        
        if(self.editingPhotoView) {
            
            self.editingPhotoView.cropMode = NO;
            
            CGRect convertTargetPhotoViewFrame = [self.containerView convertRect:self.targetPhotoView.frame fromView:[self.targetPhotoView superview]];
            CGPoint convertTargetPhotoViewCenter = [self.containerView convertPoint:self.targetPhotoView.center fromView:[self.targetPhotoView superview]];
            
            CGRect editingPhotoViewFrame = self.editingPhotoView.frame;
            CGPoint editingPhotoViewCenter = self.editingPhotoView.center;
            
            CGPoint translation = CGPointMake(convertTargetPhotoViewCenter.x - editingPhotoViewCenter.x, convertTargetPhotoViewCenter.y - editingPhotoViewCenter.y);
            CGFloat resizeScale = convertTargetPhotoViewFrame.size.width / editingPhotoViewFrame.size.width;
            
            //self.editingPhotoView.transform = CGAffineTransformMakeScale(resizeScale, resizeScale);
            
            CGAffineTransform targetTransform = self.editingPhotoView.transform;
            CGAffineTransform currentTransform = self.editingPhotoView.transform;
            
            targetTransform = CGAffineTransformTranslate(targetTransform, translation.x, translation.y);
            targetTransform = CGAffineTransformScale(targetTransform, resizeScale, resizeScale);
            
            self.editingPhotoView.transform = currentTransform;
            [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                             animations:^{
                                 self.editingPhotoView.transform = targetTransform;
                             }
                             completion:^(BOOL finished){
                             }];
            
            CGFloat fadeDelay = duration * 0.35;
            [UIView animateWithDuration:fadeDelay delay:duration - fadeDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                             animations:^{
                                 self.editingPhotoView.alpha = 0;
                             }
                             completion:^(BOOL finished){
                             }];
            
        }
        
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

- (void)editPhotoWithPhotoView:(PPhotoView *)photoView photoIndex:(NSInteger)photoIndex
{
    MARK;
    self.targetPhotoView = photoView;
    photoAssetIndex = photoIndex;
}

- (IBAction)brightnessButtonAction:(id)sender {
    [self hiddenBrightnessSlider:!hiddenBrightSlider];
}

- (IBAction)importButtonAction:(id)sender
{
    [self presentAllPhotos];
}

- (IBAction)bottomCloseButtonAction:(id)sender {
    if(sender == self.bottomCloseButton) {
        [self dismissAllPhotos];
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

- (void)hiddenBrightnessSlider:(BOOL)hidden
{
    hiddenBrightSlider = hidden;
    
    if(hidden) {
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.brightnessButtonRound.transform = CGAffineTransformIdentity;
                             self.importButtonRound.transform = CGAffineTransformIdentity;
                             self.importButtonRound.alpha = 1;
                             
                             self.brightnessSlider.transform = CGAffineTransformMakeTranslation(-60, 0);
                             self.brightnessSlider.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             if(finished) {
                                 
                                 self.brightnessSlider.userInteractionEnabled = NO;
                                 [self.brightnessSlider removeFromSuperview];
                             }
                         }];
    } else {
        if(![self.brightnessSlider superview]) {
            
            self.brightnessSlider.frame = CGRectMake(0, 0, MIN(324, self.view.frame.size.width - 60), 65);
            
            self.brightnessSlider.sliderDelegate = self;
            [self.containerView addSubview:self.brightnessSlider];
            [self.containerView bringSubviewToFront:self.brightnessButtonRound];
            
            self.brightnessSlider.userInteractionEnabled = YES;
            self.brightnessSlider.translatesAutoresizingMaskIntoConstraints = NO;
            NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_brightnessButtonRound, _brightnessSlider);
            
            NSString *visualFormat;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                
                visualFormat = [NSString stringWithFormat:@"H:[_brightnessSlider(==%f)]|", self.brightnessSlider.frame.size.width];
                
            } else {
                
                visualFormat = [NSString stringWithFormat:@"H:[_brightnessButtonRound][_brightnessSlider(==%f)]", self.brightnessSlider.frame.size.width];
                
            }
            
            [self.view addConstraints:[NSLayoutConstraint
                                       constraintsWithVisualFormat:visualFormat
                                       options:0
                                       metrics:nil
                                       views:viewsDictionary]];
            [self.view addConstraints:[NSLayoutConstraint
                                       constraintsWithVisualFormat:@"V:[_brightnessSlider(==65)]-22-|"
                                       options:0
                                       metrics:nil
                                       views:viewsDictionary]];
        }
        
        self.brightnessSlider.transform = CGAffineTransformMakeTranslation(-60, 0);
        self.brightnessSlider.alpha = 0;
        
        CGFloat translationX = (self.brightnessButtonRound.frame.origin.x - 102 < 10) ? self.brightnessButtonRound.frame.origin.x - 10 : 102;
        
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.brightnessButtonRound.transform = CGAffineTransformMakeTranslation(-translationX, 0);
                             self.importButtonRound.transform = CGAffineTransformMakeTranslation(translationX, 0);
                             self.importButtonRound.alpha = 0;
                             
                             self.brightnessSlider.transform = CGAffineTransformIdentity;
                             self.brightnessSlider.alpha = 1;
                         }
                         completion:^(BOOL finished){
                             if(finished) {
                                 self.brightnessSlider.currentValue = self.editingPhotoView.photoBrightness;
                             }
                         }];
    }
}

- (void)syncEditingData
{
    CGFloat scale = self.targetPhotoView.frame.size.width / self.editingPhotoView.frame.size.width;
    self.targetPhotoView.photoBrightness = self.editingPhotoView.photoBrightness;
    self.targetPhotoView.photoScale = self.editingPhotoView.photoScale;
    self.targetPhotoView.photoTranslation = (CGPoint) {
        self.editingPhotoView.photoTranslation.x * scale,
        self.editingPhotoView.photoTranslation.y * scale
    };
}

- (void)createEditingPhotoView
{
    if(self.editingPhotoView) {
        return;
    }
    if(!self.targetPhotoView) {
        return;
    }
    
    PPhotoView *targetPhotoView = self.targetPhotoView;
    UIImage *targetPhoto = targetPhotoView.photoImage;
    
    CGRect targetFrame = targetPhotoView.frame;
    CGFloat scale = photoContentsWidth / targetFrame.size.width;
    
    if(photoContentsHeight < targetFrame.size.height * scale) {
        scale = photoContentsHeight / targetFrame.size.height;
    }
    
    PPhotoView *photoView = [[PPhotoView alloc] initWithFrame:CGRectMake(0, 0, ceil(targetFrame.size.width * scale), ceil(targetFrame.size.height * scale))];
    
    photoView.photoImage = targetPhoto;
    photoView.photoBrightness = targetPhotoView.photoBrightness;
    photoView.photoScale = targetPhotoView.photoScale;
    photoView.photoTranslation = (CGPoint) {
        targetPhotoView.photoTranslation.x * scale,
        targetPhotoView.photoTranslation.y * scale
    };
    
    
    photoView.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.5);
    photoView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    self.editingPhotoView = photoView;
    [self.containerView addSubview:photoView];
    [self.containerView bringSubviewToFront:self.brightnessButtonRound];
    [self.containerView bringSubviewToFront:self.importButtonRound];
    
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tapGesture.delegate = self;
    
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    panGesture.delegate = self;
    
    pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    pinchGesture.delegate = self;
    
    [self.containerView addGestureRecognizer:tapGesture];
    [self.containerView addGestureRecognizer:panGesture];
    [self.containerView addGestureRecognizer:pinchGesture];
}

- (void)beginCropMode
{
    if(self.editingPhotoView) {
        self.editingPhotoView.cropMode = YES;
        [self.editingPhotoView panGestureEnabled:NO];
        [self.editingPhotoView pinchGestureEnabled:NO];
        
        [self.containerView bringSubviewToFront:borderView];
        [self.containerView bringSubviewToFront:self.brightnessButtonRound];
        [self.containerView bringSubviewToFront:self.importButtonRound];
        borderView.frame = self.editingPhotoView.frame;
        borderView.hidden = NO;
        borderView.alpha = 0;
        
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             borderView.alpha = 1;
                         }
                         completion:^(BOOL finished){
                         }];
    }
}


- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded)
    {
        [self syncEditingData];
        [self.photoEditDelegate photoEditViewControllerDidClose];
    }
    
}

- (void)panGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    [self.editingPhotoView panGesture:gestureRecognizer];
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer
{
    [self.editingPhotoView pinchGesture:gestureRecognizer];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}



#pragma mark - PhotoBrightnessSliderDelegate
- (void)photoBrightnessSliderChangeValue:(CGFloat)value
{
    [self.editingPhotoView setPhotoBrightness:value animated:YES];
}
#pragma mark - AllPhotosViewControllerDelegate

- (void)allPhotosViewControllerDidDone
{
    [self dismissAllPhotos];
}

- (void)allPhotosViewControllerDidSelectPhotoAsset:(PHAsset *)asset thumbnailImage:(UIImage *)thumbnailImage
{
    
    [self.projectResource replaceAssetAtIndex:photoAssetIndex withAsset:asset thumbnailImage:thumbnailImage
                                   completion:^{
                                       PPhotoAsset *photoAsset = [self.projectResource.photoArray objectAtIndex:photoAssetIndex];
                                       self.editingPhotoView.cropMode = NO;
                                       self.editingPhotoView.photoImage = photoAsset.photoImage;
                                       [self beginCropMode];
                                       
                                       [self.photoEditDelegate photoEditViewControllerDidReplacePhoto:self.targetPhotoView photoIndex:photoAssetIndex];
                                       
                                       [self dismissAllPhotos];
                                   }];
    //[self addPhotoAsset:asset thumbnailImage:thumbnailImage];
}

- (void)allPhotosViewControllerDidDeselectPhotoAsset:(PHAsset *)asset
{
    [self dismissAllPhotos];
    //[self removePhotoAsset:asset];
}


@end
