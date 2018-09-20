//
//  PaperViewController.m
//  Page
//
//  Created by CMR on 4/10/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "PaperViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "AssetLibraryRootListViewController.h"

@interface PaperViewController ()
{
    //UIScrollView *resultScrollView;
    //UIImageView *resultImageView;
    
    UIImageView *previewImageView;
    BOOL updatedPreviewImage;
    
}

@property (weak, nonatomic) IBOutlet UIView *toolView;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet UIView *dimmedView;
- (IBAction)shareButtonAction:(id)sender;

@property (strong, nonatomic) UIImage *resultImage;
@property (strong, nonatomic) UIImage *previewImage;
- (void)initPreviewImageView;
- (void)requestPreviewImage;
- (void)removePreviewImage;
- (void)requestResultImage;
- (void)removeResultImage;
- (void)shareToActivityController;
- (void)shareComplete;
@end


@implementation PaperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    previewImageView = [[UIImageView alloc] init];
    previewImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:previewImageView];
    
    self.dimmedView.alpha = 0;
    [self.view bringSubviewToFront:self.dimmedView];
    self.indicatorView.alpha = 0;
    [self.view bringSubviewToFront:self.indicatorView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGSize viewSize = self.view.frame.size;
    
    //SLog(@"viewSize", viewSize);
    CGFloat top = 70;
    CGFloat bottom = 64;
    CGFloat widthMargin = 0;
    
    if([self workInterfaceIsLandscape]) {
        top = 0;
        bottom = 0;
        widthMargin = 64 + 64;
    }
    
    
    /*
     resultScrollView.frame = CGRectMake(0, 0, viewSize.width - 20, viewSize.height - top - bottom);
     resultScrollView.center = CGPointMake(viewSize.width * 0.5, (viewSize.height * 0.5));
     
     resultImageView.frame = CGRectMake(0, 0, resultScrollView.frame.size.width * 2, resultScrollView.frame.size.height * 2);
     resultScrollView.contentSize = resultScrollView.frame.size;
     */
    previewImageView.transform = CGAffineTransformIdentity;
    previewImageView.frame = CGRectMake(0, 0, viewSize.width - widthMargin, viewSize.height - top - bottom);
    previewImageView.center = CGPointMake(viewSize.width * 0.5, viewSize.height * 0.5);
    
    if(!activated) {
        
        if([self workInterfaceIsLandscape]) {
            self.toolView.transform = CGAffineTransformMakeTranslation(self.toolView.frame.size.width, 0);
        } else {
            self.toolView.transform = CGAffineTransformMakeTranslation(0, self.toolView.frame.size.height);
        }
        self.toolView.alpha = 0;
    }
    //MARK;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)dealloc
{
    self.resultImage = nil;
    self.previewImage = nil;
    [previewImageView removeFromSuperview];
}

- (void)activateWork
{
    [super activateWork];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!self.previewImage) {
            [self requestPreviewImage];
        }
        
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.toolView.transform = CGAffineTransformIdentity;
                             self.toolView.alpha = 1;
                         }
                         completion:^(BOOL finished){
                             if(finished) {
                                 
                             }
                         }];
        [UIView animateWithDuration:0.75 delay:0.25 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             previewImageView.transform = CGAffineTransformIdentity;
                             previewImageView.alpha = 1;
                         }
                         completion:^(BOOL finished){
                             if(finished) {
                                 
                             }
                         }];
    });
}

- (void)deactivateWork
{
    [super deactivateWork];
    
    [self.indicatorView stopAnimating];
    [UIView animateWithDuration:0.75 delay:0.25 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.indicatorView.alpha = 0;
                         self.dimmedView.alpha =0;
                     }
                     completion:nil];
    
    /*
     [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
     animations:^{
     self.toolView.transform = CGAffineTransformMakeTranslation(0, self.toolView.frame.size.height);
     self.shareButton.alpha = 0;
     }
     completion:^(BOOL finished){
     if(finished) {
     
     }
     }];
     */
}

- (IBAction)shareButtonAction:(id)sender
{
    [self shareToActivityController];
    
    
    /*
     ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
     [library saveImage:self.resultImage toAlbum:@"PAGE UP" withCompletionBlock:^(NSError *error) {
     if (error!=nil) {
     NSLog(@"error: %@", [error description]);
     } else {
     
     UIAlertView *alert = [[UIAlertView alloc ] initWithTitle:@"Image Saved."
     message:nil
     delegate:self
     cancelButtonTitle:nil
     otherButtonTitles:nil];
     [alert show];
     
     double delayInSeconds = 1.0;
     
     dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
     dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
     [alert dismissWithClickedButtonIndex:0 animated:YES];
     
     });
     }
     }];
     */
}

- (void)updateSelectedPhotos
{
    [self removePreviewImage];
    [self removeResultImage];
}

- (void)updateTemplate
{
    [self removePreviewImage];
    [self removeResultImage];
}

- (void)initPreviewImageView
{
    CGFloat degrees = (CGFloat)(arc4random() % 60) - 30;
    previewImageView.transform = CGAffineTransformIdentity;
    previewImageView.transform = CGAffineTransformMakeRotation((M_PI * (degrees) / 180.0));
    previewImageView.transform = CGAffineTransformScale(previewImageView.transform, 1.5, 1.5);
    previewImageView.alpha = 0;
}

- (void)requestPreviewImage
{
    updatedPreviewImage = YES;
    
    self.previewImage = [self.paperDelegate paperViewControllerNeedPreviewImage];
    NSLog(@"previewImage size : %@", NSStringFromCGSize(self.previewImage.size));
    previewImageView.image = self.previewImage;
    
    [self initPreviewImageView];
}

- (void)removePreviewImage
{
    updatedPreviewImage = NO;
    
    self.previewImage = nil;
    [self initPreviewImageView];
}

- (void)requestResultImage
{
    self.resultImage = [self.paperDelegate paperViewControllerNeedResultImage];
}

- (void)removeResultImage
{
    self.resultImage = nil;
}

- (void)shareToActivityController
{
    if(self.resultImage == nil) {
        [self.indicatorView startAnimating];
        self.indicatorView.hidden = NO;
        
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.indicatorView.alpha = 1;
                             self.dimmedView.alpha = 1;
                         }
                         completion:^(BOOL finished){
                             if(finished) {
                                 [self requestResultImage];
                                 [self shareToActivityController];
                             }
                         }];
        return;
    }
    
    [self.indicatorView stopAnimating];
    [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.indicatorView.alpha = 0;
                         self.dimmedView.alpha = 0;
                     } completion:nil];
    NSLog(@"Export size : %@", NSStringFromCGSize(self.resultImage.size));
    
    [self.paperDelegate paperViewControllerDidShareActivityWithImage:self.resultImage
                                                            completion:^{
                                                                [self shareComplete];
                                                            }];
}

- (void)shareComplete
{
}

@end
