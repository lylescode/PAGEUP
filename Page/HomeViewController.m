//
//  HomeViewController.m
//  Page
//
//  Created by CMR on 11/17/14.
//  Copyright (c) 2014 Page. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "Constants.h"

#import "ProjectCollectionViewCell.h"
#import "PProgressView.h"

#define kColumnsiPadLandscape 4
#define kColumnsiPadPortrait 3
#define kColumnsiPhoneLandscape 3
#define kColumnsiPhonePortrait 2

#define ALERT_TAG_DELETE 11

@interface HomeViewController ()
{
    dispatch_queue_t backgroundQueue;
    dispatch_semaphore_t backgroudQueueSignal;
    NSUInteger collectionViewNumberOfColumns;
    CGSize collectionViewSize;
    
    NSString *documentsDirectory;
    
    UITapGestureRecognizer *doubleTapGesture;
    UITapGestureRecognizer *singleTapGesture;
}
@property (weak, nonatomic) IBOutlet UIView *stageView;

@property (weak, nonatomic) IBOutlet UICollectionView *projectCollectionView;
@property (weak, nonatomic) IBOutlet UIView *plusBottomBar;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UIButton *dimmedButton;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *duplicateButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

- (IBAction)dimmedButtonAction:(id)sender;
- (IBAction)menuButtonAction:(id)sender;
- (IBAction)bottomNewButtonAction:(id)sender;
- (IBAction)bottomButtonAction:(id)sender;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSMutableArray *projectArray;
@property (strong, nonatomic) NSMutableArray *projectAnimatedArray;
@property (strong, nonatomic) Project *selectedProject;

@property (strong, nonatomic) UIImageView *selectedProjectView;
@property (assign, nonatomic) NSInteger selectedProjectCellIndex;

@property (strong, nonatomic) HomeMenuViewController *homeMenuViewController;
@property (strong, nonatomic) HomeShareViewController *homeShareViewController;
@property (strong, nonatomic) VideoPreviewViewController *videoPreviewViewController;

@property (strong, nonatomic) PProgressView *progressView;

- (void)orientationChanged:(NSNotification *)notification;

- (void)presentHomeMenuViewController:(BOOL)animated;
- (void)dismissHomeMenuViewController:(BOOL)animated;

- (void)presentHomeShareViewControllerWithProject:(Project *)project animated:(BOOL)animated;
- (void)dismissHomeShareViewController:(BOOL)animated;

- (void)presentVideoPreviewViewControllerWithProject:(Project *)project animated:(BOOL)animated;
- (void)dismissVideoPreviewViewController:(BOOL)animated;

- (void)presentProjectPreviewWithProjectCell:(ProjectCollectionViewCell *)projectCell animated:(BOOL)animated;
- (void)dismissProjectPreview:(BOOL)backAnimation;

- (void)loadProjects;
- (void)selectProject:(Project *)project;
- (void)deselectProject;

- (void)editProject:(Project *)project;
- (void)duplicateProject:(Project *)project;
- (void)deleteProject:(Project *)project;
- (void)shareProject:(Project *)project;

- (void)sharePhoto;
- (void)sharePDF;
- (void)shareVideo;
- (void)completeShareProject;

- (void)showProgress;
- (void)updateProgress:(CGFloat)progress;
- (void)completeProgress;

- (NSString *)duplicateFileAtFilename:(NSString *)filename toFilename:(NSString *)toFilename;
- (void)deleteFileAtFilename:(NSString *)filename;

- (void)doubleTapGesture:(UITapGestureRecognizer *)gestureRecognizer;
- (void)singleTapGesture:(UITapGestureRecognizer *)gestureRecognizer;

@end

static NSString * const reuseIdentifier = @"ProjectCell";

@implementation HomeViewController
@synthesize homeDelegate;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    backgroundQueue = dispatch_queue_create("com.project.list", NULL);
    // 동시진행되는 큐는 1개로 제한
    backgroudQueueSignal = dispatch_semaphore_create(1);
    
    ProjectCollectionViewLayout *projectCollectionViewLayout = (ProjectCollectionViewLayout *)self.projectCollectionView.collectionViewLayout;
    projectCollectionViewLayout.delegate = self;
    
    self.projectCollectionView.backgroundColor = [UIColor clearColor];
    self.projectCollectionView.alwaysBounceVertical = YES;
    self.projectCollectionView.showsVerticalScrollIndicator = NO;
    self.projectCollectionView.showsHorizontalScrollIndicator = NO;
    [self.projectCollectionView registerNib:[UINib nibWithNibName:@"ProjectCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:reuseIdentifier];
    
    
    self.editButton.alpha = 0;
    self.duplicateButton.alpha = 0;
    self.deleteButton.alpha = 0;
    self.shareButton.alpha = 0;
    
    self.dimmedButton.alpha = 0;
    self.closeButton.alpha = 0;
    /*
    doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGesture:)];
    
    doubleTapGesture.cancelsTouchesInView = YES;
    doubleTapGesture.delaysTouchesBegan = NO;
    
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.projectCollectionView addGestureRecognizer:doubleTapGesture];
    */
    
    singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGesture:)];
    
    singleTapGesture.cancelsTouchesInView = NO;
    singleTapGesture.delaysTouchesBegan = NO;
    
    singleTapGesture.numberOfTapsRequired = 1;
    [self.projectCollectionView addGestureRecognizer:singleTapGesture];
    
    //[singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    
    double delayInSeconds = 0.5;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self loadProjects];
    });
    
    CATransform3D perspectiveTransform = self.stageView.layer.transform;
    perspectiveTransform.m34 = -1.0 / 400.0;
    
    self.stageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    [self.stageView.layer setTransform:perspectiveTransform];

}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIEdgeInsets currentInsets = self.projectCollectionView.contentInset;
    self.projectCollectionView.contentInset = (UIEdgeInsets){
        .top = 56,
        .bottom = 60,
        .left = currentInsets.left,
        .right = currentInsets.right
    };
    
    collectionViewSize = self.view.frame.size;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    //MARK;
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //MARK;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if(doubleTapGesture) {
        [self.view removeGestureRecognizer:doubleTapGesture];
    }
    if(singleTapGesture) {
        [self.view removeGestureRecognizer:singleTapGesture];
    }
    if(self.selectedProjectView) {
        [self.selectedProjectView removeFromSuperview];
        self.selectedProjectView = nil;
    }
    
    self.managedObjectContext = nil;
    self.projectArray = nil;
    self.projectAnimatedArray = nil;
    self.selectedProject = nil;
    
    if(self.progressView) {
        [self.progressView removeFromSuperview];
        self.progressView = nil;
    }
}

- (void)orientationChanged:(NSNotification *)notification
{
    /*
     디바이스를 회전할때 collectionView 가 먹통이 됨. cell 에 template 생성하는 queue 의 영향 때문인거같아서 reload 해주니 해결되긴 함
     cellForItemAtIndexPath 에서 template 생성 말고 템플릿 리스트를 관리하는 객체를 만들어서 테스트해봐야겠음.
     */
    
    if(CGSizeEqualToSize(self.view.frame.size, collectionViewSize) == NO) {
        
        collectionViewSize = self.view.frame.size;
        
        NSMutableArray *animatedArray = [NSMutableArray array];
        for(NSInteger i = 0 ; i < self.projectAnimatedArray.count ; i++) {
            [animatedArray addObject:[NSNumber numberWithBool:NO]];
        }
        
        self.projectAnimatedArray = animatedArray;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.projectCollectionView reloadData];
        });
    }
}

- (void)presentHomeMenuViewController:(BOOL)animated
{
    if(self.homeMenuViewController) {
        return;
    }
    
    HomeMenuViewController *homeMenuVC = [[HomeMenuViewController alloc] init];
    homeMenuVC.homeMenuDelegate = self;
    homeMenuVC.view.frame = self.view.bounds;
    
    [self.view addSubview:homeMenuVC.view];
    self.homeMenuViewController = homeMenuVC;
    
    [self.homeMenuViewController presentViewControllerAnimated:animated
                                                     completion:nil];
    
    
    CAAnimationGroup *stageDimAnimation;
    CABasicAnimation *rotationAnimation;
    CABasicAnimation *translationAnimation;
    
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:radians(-2.5)];
    
    translationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.z"];
    translationAnimation.toValue = [NSNumber numberWithFloat:-25];
    
    stageDimAnimation = [CAAnimationGroup animation];
    [stageDimAnimation setAnimations:[NSArray arrayWithObjects:rotationAnimation, translationAnimation, nil]];
    stageDimAnimation.beginTime = 0;
    stageDimAnimation.duration = 0.45;
    
    stageDimAnimation.fillMode = kCAFillModeForwards;
    stageDimAnimation.removedOnCompletion = NO;
    
    stageDimAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.21 :.14 :.34 :1];
    [self.stageView.layer addAnimation:stageDimAnimation forKey:@"stageDimAnimation"];
    
    //[self.stageView.layer setValue:[NSNumber numberWithFloat:radians(-5)] forKeyPath:@"transform.rotation.x"];
    //[self.stageView.layer setValue:[NSNumber numberWithFloat:-50] forKeyPath:@"transform.translation.z"];
    
    [UIView animateWithDuration:0.45 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)dismissHomeMenuViewController:(BOOL)animated
{
    [self.homeMenuViewController dismissViewControllerAnimated:animated
                                                     completion:^{
                                                         [self.homeMenuViewController.view removeFromSuperview];
                                                         self.homeMenuViewController = nil;
                                                     }];
    CAAnimationGroup *stageDimAnimation;
    CABasicAnimation *rotationAnimation;
    CABasicAnimation *translationAnimation;
    
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:radians(-2.5)];
    
    translationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.z"];
    translationAnimation.fromValue = [NSNumber numberWithFloat:-25];
    
    stageDimAnimation = [CAAnimationGroup animation];
    [stageDimAnimation setAnimations:[NSArray arrayWithObjects:rotationAnimation, translationAnimation, nil]];
    stageDimAnimation.beginTime = 0;
    stageDimAnimation.duration = 0.35;
    stageDimAnimation.fillMode = kCAFillModeBackwards;
    
    stageDimAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.21 :.14 :.34 :1];
    [self.stageView.layer addAnimation:stageDimAnimation forKey:@"stageDimAnimation"];
    
    [UIView animateWithDuration:0.45 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                     }
                     completion:^(BOOL finished){
                     }];
}


- (void)presentHomeShareViewControllerWithProject:(Project *)project animated:(BOOL)animated
{
    if(self.homeShareViewController) {
        return;
    }
    
    HomeShareViewController *homeShareVC = [[HomeShareViewController alloc] init];
    homeShareVC.homeShareDelegate = self;
    homeShareVC.view.frame = self.view.bounds;
    
    [self.view addSubview:homeShareVC.view];
    self.homeShareViewController = homeShareVC;
    
    [self.homeShareViewController presentViewControllerAnimated:animated
                                                        completion:nil];
    
    /*
    CAAnimationGroup *stageDimAnimation;
    CABasicAnimation *rotationAnimation;
    CABasicAnimation *translationAnimation;
    
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:radians(-2.5)];
    
    translationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.z"];
    translationAnimation.toValue = [NSNumber numberWithFloat:-25];
    
    stageDimAnimation = [CAAnimationGroup animation];
    [stageDimAnimation setAnimations:[NSArray arrayWithObjects:rotationAnimation, translationAnimation, nil]];
    stageDimAnimation.beginTime = 0;
    stageDimAnimation.duration = 0.45;
    
    stageDimAnimation.fillMode = kCAFillModeForwards;
    stageDimAnimation.removedOnCompletion = NO;

    stageDimAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.21 :.14 :.34 :1];
    [self.stageView.layer addAnimation:stageDimAnimation forKey:@"stageDimAnimation"];
    
    //[self.stageView.layer setValue:[NSNumber numberWithFloat:radians(-5)] forKeyPath:@"transform.rotation.x"];
    //[self.stageView.layer setValue:[NSNumber numberWithFloat:-50] forKeyPath:@"transform.translation.z"];
    
    [UIView animateWithDuration:0.45 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                     }
                     completion:^(BOOL finished){
                     }];
     */
}
- (void)dismissHomeShareViewController:(BOOL)animated
{
    [self completeProgress];
    
    [self.homeShareViewController dismissViewControllerAnimated:animated
                                                        completion:^{
                                                            [self.homeShareViewController.view removeFromSuperview];
                                                            self.homeShareViewController = nil;
                                                        }];
    /*
    CAAnimationGroup *stageDimAnimation;
    CABasicAnimation *rotationAnimation;
    CABasicAnimation *translationAnimation;
    
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:radians(-2.5)];
    
    translationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.z"];
    translationAnimation.fromValue = [NSNumber numberWithFloat:-25];
    
    stageDimAnimation = [CAAnimationGroup animation];
    [stageDimAnimation setAnimations:[NSArray arrayWithObjects:rotationAnimation, translationAnimation, nil]];
    stageDimAnimation.beginTime = 0;
    stageDimAnimation.duration = 0.35;
    stageDimAnimation.fillMode = kCAFillModeBackwards;
    
    stageDimAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.21 :.14 :.34 :1];
    [self.stageView.layer addAnimation:stageDimAnimation forKey:@"stageDimAnimation"];
    
    [UIView animateWithDuration:0.45 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                     }
                     completion:^(BOOL finished){
                     }];
     */
}


- (void)presentVideoPreviewViewControllerWithProject:(Project *)project animated:(BOOL)animated
{
    if(self.videoPreviewViewController) {
        return;
    }
    if(!project) {
        return;
    }
    
    ProjectResource *projectResource = [[ProjectResource alloc] init];
    projectResource.project = project;
    projectResource.templateDictionary          = project.templateDictionary;
    projectResource.templateTextDictionary      = project.templateTextDictionary;
    projectResource.projectDictionary           = project.projectDictionary;
    [projectResource setupPhotoAssetsWithPhotoAssetDictionaryArray:project.photoAssetDictionaryArray];
    
    VideoPreviewViewController *videoPreviewVC = [[VideoPreviewViewController alloc] init];
    videoPreviewVC.videoPreviewDelegate = self;
    videoPreviewVC.projectResource = projectResource;
    videoPreviewVC.view.frame = self.view.bounds;
    
    [self.view addSubview:videoPreviewVC.view];
    self.videoPreviewViewController = videoPreviewVC;
    
    [self.videoPreviewViewController presentViewControllerAnimated:animated completion:nil];
    
}
- (void)dismissVideoPreviewViewController:(BOOL)animated
{
    [self.videoPreviewViewController dismissViewControllerAnimated:animated
                                                     completion:^{
                                                         [self.videoPreviewViewController.view removeFromSuperview];
                                                         self.videoPreviewViewController = nil;
                                                     }];
}

- (void)presentProjectPreviewWithProjectCell:(ProjectCollectionViewCell *)projectCell animated:(BOOL)animated
{
    if(self.selectedProjectView) {
        [self.selectedProjectView removeFromSuperview];
        self.selectedProjectView = nil;
    }
    self.selectedProjectCellIndex = [self.projectCollectionView indexPathForCell:projectCell].row;
    
    CGFloat viewWidth = self.stageView.frame.size.width - 10;
    CGFloat viewHeight = self.stageView.frame.size.height - 132;
    
    UIImage *previewImage = projectCell.previewImageView.image;
    /*
    CGSize previewImageSize = (previewImage != nil) ? previewImage.size : CGSizeMake(self.stageView.frame.size.width - 10, self.stageView.frame.size.width - 10);
    
    
    CGFloat viewScale = (viewWidth) / previewImageSize.width;
    if(viewHeight < previewImageSize.height * viewScale) {
        viewScale = viewHeight / previewImageSize.height;
        viewWidth = round(previewImageSize.width * viewScale);
    } else {
        viewHeight = round(previewImageSize.height * viewScale);
    }
    */
    
    UIImageView *projectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 66, viewWidth, viewHeight)];
    projectImageView.contentMode = UIViewContentModeScaleAspectFit;
    projectImageView.image = previewImage;
    if(previewImage == nil) {
        projectImageView.backgroundColor = [UIColor darkGrayColor];
    }
    projectImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.stageView addSubview:projectImageView];
    [self.stageView bringSubviewToFront:self.bottomBarView];
    [self.stageView bringSubviewToFront:self.menuButton];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(projectImageView);
    NSArray *contentsView_H = [NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-5-[projectImageView]-5-|"
                               options:0
                               metrics:nil
                               views:viewsDictionary];
    NSArray *contentsView_V = [NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|-66-[projectImageView]-66-|"
                               options:0
                               metrics:nil
                               views:viewsDictionary];
    
    [self.stageView addConstraints:contentsView_H];
    [self.stageView addConstraints:contentsView_V];

    self.selectedProjectView = projectImageView;
    
    if(animated) {
        CGPoint toCenter = self.selectedProjectView.center;
        CGPoint fromCenter = [self.stageView convertPoint:projectCell.center fromView:self.projectCollectionView];
        
        CGFloat fromScale = 1;
        if(self.selectedProjectView.frame.size.width / self.selectedProjectView.image.size.width < self.selectedProjectView.frame.size.height / self.selectedProjectView.image.size.height) {
            fromScale = projectCell.frame.size.width / self.selectedProjectView.frame.size.width;
        }
        else {
            fromScale = projectCell.frame.size.height / self.selectedProjectView.frame.size.height;
        }
        
        CGAffineTransform fromTransform = CGAffineTransformMakeTranslation(fromCenter.x - toCenter.x, fromCenter.y - toCenter.y);
        fromTransform = CGAffineTransformScale(fromTransform, fromScale, fromScale);
        
        projectCell.previewImageView.alpha = 0;
        self.selectedProjectView.transform = fromTransform;
        self.dimmedButton.alpha = 0;
        self.closeButton.alpha = 0;
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:0.85 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             self.selectedProjectView.transform = CGAffineTransformIdentity;
                             self.dimmedButton.alpha = 0.95;
                             self.closeButton.alpha = 1;
                             self.menuButton.alpha = 0;
                         }
                         completion:^(BOOL finished){
                         }];
    } else {
        self.dimmedButton.alpha = 0.95;
        self.closeButton.alpha = 1;
    }
}
- (void)dismissProjectPreview:(BOOL)backAnimation
{
    if(backAnimation) {
        if(self.selectedProjectCellIndex > -1) {
            ProjectCollectionViewCell *projectCell = (ProjectCollectionViewCell *)[self.projectCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedProjectCellIndex inSection:0]];
            
            CGPoint fromCenter = self.selectedProjectView.center;
            CGPoint toCenter = [self.stageView convertPoint:projectCell.center fromView:self.projectCollectionView];
            
            CGFloat toScale = 1;
            if(self.selectedProjectView.frame.size.width / self.selectedProjectView.image.size.width < self.selectedProjectView.frame.size.height / self.selectedProjectView.image.size.height) {
                toScale = projectCell.frame.size.width / self.selectedProjectView.frame.size.width;
            }
            else {
                toScale = projectCell.frame.size.height / self.selectedProjectView.frame.size.height;
            }
            
            CGAffineTransform toTransform = CGAffineTransformMakeTranslation(toCenter.x- fromCenter.x, toCenter.y - fromCenter.y);
            toTransform = CGAffineTransformScale(toTransform, toScale, toScale);
            
            projectCell.previewImageView.alpha = 0;
            [UIView animateWithDuration:0.45 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 
                                 self.selectedProjectView.transform = toTransform;
                                 self.dimmedButton.alpha = 0;
                                 self.closeButton.alpha = 0;
                                 self.menuButton.alpha = 1;
                             }
                             completion:^(BOOL finished){
                                 if(finished) {
                                     [self.selectedProjectView removeFromSuperview];
                                     self.selectedProjectView = nil;
                                     
                                     projectCell.previewImageView.alpha = 1;
                                 }
                             }];
            
        } else {
            
            [UIView animateWithDuration:0.45 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.selectedProjectView.alpha = 0;
                                 self.selectedProjectView.transform = CGAffineTransformMakeScale(0.5, 0.5);
                                 self.dimmedButton.alpha = 0;
                                 self.closeButton.alpha = 0;
                                 self.menuButton.alpha = 1;
                             }
                             completion:^(BOOL finished){
                                 if(finished) {
                                     [self.selectedProjectView removeFromSuperview];
                                     self.selectedProjectView = nil;
                                 }
                             }];
        }
    } else {
        if(self.selectedProjectCellIndex) {
            ProjectCollectionViewCell *projectCell = (ProjectCollectionViewCell *)[self.projectCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedProjectCellIndex inSection:0]];
            
            projectCell.previewImageView.alpha = 1;
        }
        [UIView animateWithDuration:0.45 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.selectedProjectView.alpha = 0;
                             self.selectedProjectView.transform = CGAffineTransformMakeScale(0.5, 0.5);
                             self.dimmedButton.alpha = 0;
                             self.closeButton.alpha = 0;
                             self.menuButton.alpha = 1;
                         }
                         completion:^(BOOL finished){
                             if(finished) {
                                 [self.selectedProjectView removeFromSuperview];
                                 self.selectedProjectView = nil;
                             }
                         }];
    }
    
    self.selectedProjectCellIndex = -1;
}


- (IBAction)dimmedButtonAction:(id)sender {
    [self dismissProjectPreview:YES];
    if(self.selectedProject) {
        NSInteger projectIndex = [self.projectArray indexOfObject:self.selectedProject];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:projectIndex inSection:0];
        
        [self deselectProject];
        [self.projectCollectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
}

- (IBAction)menuButtonAction:(id)sender {
    //[self presentHomeMenuViewController:YES];
    [self.homeDelegate homeViewControllerDidAbout];
}

- (IBAction)bottomNewButtonAction:(id)sender {
    [homeDelegate homeViewControllerDidNewProject];
}

- (IBAction)bottomButtonAction:(id)sender {
    if(sender == self.editButton) {
        [self editProject:self.selectedProject];
    } else if(sender == self.duplicateButton) {
        [self duplicateProject:self.selectedProject];
    } else if(sender == self.deleteButton) {
        
        
        UIAlertView *alert = [[UIAlertView alloc] init];
        alert.message = NSLocalizedString(@"Delete Message", nil);
        alert.delegate = self;
        alert.tag = ALERT_TAG_DELETE;
        [alert addButtonWithTitle:NSLocalizedString(@"No", nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"Yes", nil)];
        [alert show];
        
    } else if(sender == self.shareButton) {
        [self shareProject:self.selectedProject];
    }
}

- (void)loadProjects
{
    self.selectedProject = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Project" inManagedObjectContext:self.managedObjectContext]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modificationDate" ascending:NO];
    //        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor count:1];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSError *error = nil;
    NSArray *entities = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    /*
    for(Project *project in entities) {
        NSLog(@"project.templateDictionary : %@", project.previewImageName);
    }
    */
    
    self.projectArray = [NSMutableArray arrayWithArray:entities];
    
    NSMutableArray *animatedArray = [NSMutableArray array];
    for(NSInteger i = 0 ; i < entities.count ; i++) {
        [animatedArray addObject:[NSNumber numberWithBool:NO]];
    }
    
    self.projectAnimatedArray = animatedArray;
    
    //NSLog(@"loadProjects : %li", self.projectArray.count);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.projectCollectionView reloadData];
    });
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL shown = [[defaults objectForKey:TOOLTIP_HOME_KEY] boolValue];
    
    if(!shown) {
        double delayInSeconds = 1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [self.homeDelegate homeViewControllerNeedTooltip];
        });
    }
}


- (void)selectProject:(Project *)project
{
    self.selectedProject = project;
    
    
    CGAffineTransform hiddenTransform = CGAffineTransformMakeTranslation(0, 22);
    
    self.editButton.transform = hiddenTransform;
    self.duplicateButton.transform = hiddenTransform;
    self.deleteButton.transform = hiddenTransform;
    self.shareButton.transform = hiddenTransform;
    
    [UIView animateWithDuration:0.45 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.bottomBarView.backgroundColor = [UIColor blackColor];
                         
                         self.editButton.alpha = 1;
                         self.duplicateButton.alpha = 1;
                         self.deleteButton.alpha = 1;
                         self.shareButton.alpha = 1;
                         
                         self.editButton.transform = CGAffineTransformIdentity;
                         self.duplicateButton.transform = CGAffineTransformIdentity;
                         self.deleteButton.transform = CGAffineTransformIdentity;
                         self.shareButton.transform = CGAffineTransformIdentity;
                         
                         self.plusBottomBar.transform = CGAffineTransformMakeTranslation(0, 44);
                         //self.plusButton.alpha = 0;
                     }
                     completion:^(BOOL finished){
                     }];
}
- (void)deselectProject
{
    self.selectedProject = nil;
    
    
    CGAffineTransform hiddenTransform = CGAffineTransformMakeTranslation(0, 22);
    
    [UIView animateWithDuration:0.45 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.bottomBarView.backgroundColor = [UIColor clearColor];
                         
                         self.editButton.alpha = 0;
                         self.duplicateButton.alpha = 0;
                         self.deleteButton.alpha = 0;
                         self.shareButton.alpha = 0;
                         
                         self.editButton.transform = hiddenTransform;
                         self.duplicateButton.transform = hiddenTransform;
                         self.deleteButton.transform = hiddenTransform;
                         self.shareButton.transform = hiddenTransform;
                         
                         self.plusBottomBar.transform = CGAffineTransformIdentity;
                         //self.plusButton.alpha = 1;
                     }
                     completion:^(BOOL finished){
                     }];
}


- (void)editProject:(Project *)project
{
    if(project) {
        [self.homeDelegate homeViewControllerDidLoadProject:project];
    }
}
- (void)duplicateProject:(Project *)project
{
    if(project) {
        
        NSInteger projectIndex = [self.projectArray indexOfObject:project];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:projectIndex inSection:0];
        ProjectCollectionViewCell *projectCell = (ProjectCollectionViewCell *)[self.projectCollectionView cellForItemAtIndexPath:indexPath];
        
        projectCell.previewImageView.alpha = 1;
        
        
        [self dismissProjectPreview:NO];
        [self.projectCollectionView deselectItemAtIndexPath:indexPath animated:NO];
        
        [self deselectProject];
        [self.projectCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        
        
        Project *newProject = [NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:self.managedObjectContext];
        
        NSString *previewImageName = project.previewImageName;
        
        newProject.previewImageName = [self duplicateFileAtFilename:previewImageName toFilename:@"pageup_project_preview"];
        
        newProject.previewImageSize = project.previewImageSize;
        
        newProject.creationDate = [NSDate date];
        newProject.modificationDate = [NSDate date];
        [newProject setTemplateDictionary:project.templateDictionary];
        [newProject setTemplateTextDictionary:project.templateTextDictionary];
        [newProject setProjectDictionary:project.projectDictionary];
        
        NSMutableArray *newPhotoAssetDictionaryArray = [NSMutableArray array];
        NSArray *photoAssetDictionaryArray = project.photoAssetDictionaryArray;
        
        for(NSDictionary *photoAssetDictionary in photoAssetDictionaryArray) {
            NSString *cacheImageName = photoAssetDictionary[@"cacheImageName"];
            NSString *cacheThumbnailName = photoAssetDictionary[@"cacheThumbnailName"];
            NSString *localIdentifier = photoAssetDictionary[@"localIdentifier"];
            
            NSString *newCacheImageName = [self duplicateFileAtFilename:cacheImageName toFilename:@"pageup_cached"];
            NSString *newCacheThumbnailName = [self duplicateFileAtFilename:cacheThumbnailName toFilename:@"pageup_cached_thumbnail"];
            NSString *newLocalIdentifier = [localIdentifier copy];
            
            NSMutableDictionary *newPhotoAssetDictionary = [NSMutableDictionary dictionary];
            newPhotoAssetDictionary[@"cacheImageName"] = newCacheImageName;
            newPhotoAssetDictionary[@"cacheThumbnailName"] = newCacheThumbnailName;
            newPhotoAssetDictionary[@"localIdentifier"] = newLocalIdentifier;
            
            [newPhotoAssetDictionaryArray addObject:newPhotoAssetDictionary];
            NSLog(@"photoAssetDictionary : %@", photoAssetDictionary);
            NSLog(@"newPhotoAssetDictionary : %@", newPhotoAssetDictionary);
        }
        
        [newProject setPhotoAssetDictionary:[NSArray arrayWithArray:newPhotoAssetDictionaryArray]];
        
        NSError *error;
        if ([self.managedObjectContext hasChanges] && [[self managedObjectContext] save:&error]) {
            NSLog(@"Project Duplicated.....");
            
            [self.projectCollectionView performBatchUpdates:^{
                
                [self.projectAnimatedArray insertObject:[NSNumber numberWithBool:NO] atIndex:0];
                [self.projectArray insertObject:newProject atIndex:0];
                
                NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];
                [arrayWithIndexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
                
                [self.projectCollectionView insertItemsAtIndexPaths:arrayWithIndexPaths];
            } completion:^(BOOL finished) {
                
                
                /*
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                [self.projectCollectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionTop];
                */
                /*
                [self selectProject:newProject];
                ProjectCollectionViewCell *projectCell = (ProjectCollectionViewCell *)[self.projectCollectionView cellForItemAtIndexPath:indexPath];
                [self presentProjectPreviewWithProjectCell:projectCell animated:YES];
                 */
                
            }];
        } else {
            NSLog(@"Project Managed Object Saving Error has occurred");
        }
    }
}
- (void)deleteProject:(Project *)project
{
    if(project) {
        [self dismissProjectPreview:NO];
        
        [self deleteFileAtFilename:project.previewImageName];
        NSArray *photoAssetDictionaryArray = project.photoAssetDictionaryArray;
        
        for(NSDictionary *photoAssetDictionary in photoAssetDictionaryArray) {
            NSString *cacheImageName = photoAssetDictionary[@"cacheImageName"];
            NSString *cacheThumbnailName = photoAssetDictionary[@"cacheThumbnailName"];
            [self deleteFileAtFilename:cacheImageName];
            [self deleteFileAtFilename:cacheThumbnailName];
        }
        
        
        NSInteger projectIndex = [self.projectArray indexOfObject:project];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:projectIndex inSection:0];
        
        [self deselectProject];
        [self.projectCollectionView deselectItemAtIndexPath:indexPath animated:NO];
        
        [self.projectCollectionView performBatchUpdates:^{
            [self.projectArray removeObjectAtIndex:projectIndex];
            [self.projectAnimatedArray removeObjectAtIndex:projectIndex];
            [self.projectCollectionView deleteItemsAtIndexPaths:@[indexPath]];
            
        } completion:^(BOOL finished) {
            
            [self.managedObjectContext deleteObject:project];
            
            NSError *error;
            if ([self.managedObjectContext hasChanges] && [[self managedObjectContext] save:&error]) {
                NSLog(@"Project Deleted.....");
            } else {
                NSLog(@"Project Managed Object Saving Error has occurred");
            }
        }];
    }
    
}
- (void)shareProject:(Project *)project
{
    [self presentHomeShareViewControllerWithProject:self.selectedProject animated:YES];
}

- (void)sharePhoto
{
    if(self.selectedProject) {
        self.view.userInteractionEnabled = NO;
        [self showProgress];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self updateProgress:.35];
            });
            ProjectResource *projectResource = [[ProjectResource alloc] init];
            projectResource.project = self.selectedProject;
            projectResource.templateDictionary          = self.selectedProject.templateDictionary;
            projectResource.templateTextDictionary      = self.selectedProject.templateTextDictionary;
            projectResource.projectDictionary           = self.selectedProject.projectDictionary;
            [projectResource setupPhotoAssetsWithPhotoAssetDictionaryArray:self.selectedProject.photoAssetDictionaryArray];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self updateProgress:.65];
            });
            
            UIImage *resultImage = projectResource.resultImage;
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self updateProgress:1];
            });
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.view.userInteractionEnabled = YES;
                
                [self completeProgress];
                if(self.selectedProject) {
                    [self.homeDelegate homeViewControllerDidShareActivityWithImage:resultImage
                                                                        completion:^{
                                                                            [self completeShareProject];
                                                                        }];
                }
            });
            
        });
        
    }
}
- (void)sharePDF
{
    if(self.selectedProject) {
        self.view.userInteractionEnabled = NO;
        [self showProgress];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self updateProgress:.35];
            });
            ProjectResource *projectResource = [[ProjectResource alloc] init];
            projectResource.project = self.selectedProject;
            projectResource.templateDictionary          = self.selectedProject.templateDictionary;
            projectResource.templateTextDictionary      = self.selectedProject.templateTextDictionary;
            projectResource.projectDictionary           = self.selectedProject.projectDictionary;
            [projectResource setupPhotoAssetsWithPhotoAssetDictionaryArray:self.selectedProject.photoAssetDictionaryArray];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self updateProgress:.65];
            });
            
            NSURL *resultPDF = projectResource.resultPDF;
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self updateProgress:1];
            });
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.view.userInteractionEnabled = YES;
                
                [self completeProgress];
                if(self.selectedProject) {
                    [self.homeDelegate homeViewControllerDidShareActivityWithPDF:resultPDF
                                                                      completion:^{
                                                                          [self completeShareProject];
                                                                      }];
                }
            });
            
        });
    }
}
- (void)shareVideo
{
    [self presentVideoPreviewViewControllerWithProject:self.selectedProject animated:YES];
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
- (NSString *)duplicateFileAtFilename:(NSString *)filename toFilename:(NSString *)toFilename
{
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:filePath] == YES) {
        
        NSInteger r = arc4random() % 100000000;
        NSString *toFullname = [NSString stringWithFormat:@"%@_%li.JPG",toFilename, (long)r];
        NSString *toFilePath = [documentsDirectory stringByAppendingPathComponent:toFullname];
        
        BOOL isDir;
        while ([fileManager fileExistsAtPath:toFilePath isDirectory:&isDir] == YES) {
            r = arc4random() % 100000000;
            
            toFullname = [NSString stringWithFormat:@"%@_%li.JPG",toFilename, (long)r];
            toFilePath = [documentsDirectory stringByAppendingPathComponent:toFullname];
        }
        NSError *error = nil;
        if (![fileManager copyItemAtPath:filePath toPath:toFilePath error:&error]) {
            NSLog(@"Failed to preview image data to disk");
        } else {
            NSLog(@"duplicated path %@", toFilePath);
        }
        return toFullname;
    }
    return nil;
}

- (void)deleteFileAtFilename:(NSString *)filename
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];
    
    NSError *error = nil;
    if(![fileManager removeItemAtPath:filePath error:&error]) {
        NSLog(@"Failed to remove from disk : %@", error);
    } else {
        NSLog(@"removed : %@", filename);
    }
}
- (void)doubleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded)
    {
        //CGPoint location = [gestureRecognizer locationInView:self.projectCollectionView];
        MARK;
        /*
        for(ProjectCollectionViewCell *projectCell in [self.projectCollectionView visibleCells]) {
            if(CGRectContainsPoint(projectCell.frame, location)) {
                NSIndexPath *indexPath = [self.projectCollectionView indexPathForCell:projectCell];
                Project *project = self.projectArray[indexPath.item];
                if(self.selectedProject == project) {
                    [self editProject:project];
                }
            }
        }
         */
    }
}

- (void)singleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [gestureRecognizer locationInView:self.projectCollectionView];
        MARK;
        BOOL isBlank = YES;
        for(ProjectCollectionViewCell *projectCell in [self.projectCollectionView visibleCells]) {
            if(CGRectContainsPoint(projectCell.frame, location)) {
                isBlank = NO;
            }
        }
        
        if(isBlank) {

            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.projectArray indexOfObject:self.selectedProject] inSection:0];
            [self deselectProject];
            [self.projectCollectionView deselectItemAtIndexPath:indexPath animated:YES];
        }
    }
}
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}


#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ALERT_TAG_DELETE) {
        if (buttonIndex == 0) {
        } else if (buttonIndex == 1) {
            [self deleteProject:self.selectedProject];
        }
    }
}
#pragma mark - HomeMenuViewController
- (void)homeMenuViewControllerDidSelectAbout
{
    [self dismissHomeMenuViewController:YES];
}
- (void)homeMenuViewControllerDidSelectShop
{
    [self dismissHomeMenuViewController:YES];
}
- (void)homeMenuViewControllerDidClose
{
    [self dismissHomeMenuViewController:YES];
}


#pragma mark - HomeShareViewControllerDelegate

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
    [self.homeDelegate homeViewControllerDidShareActivityWithVideoURL:videoURL
                                                           completion:^{
                                                               [self completeShareProject];
                                                           }];
}


#pragma mark UIScrollViewDelegate


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if(self.selectedProject) {
        
        if(ABS(velocity.y) > 1.5) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.projectArray indexOfObject:self.selectedProject] inSection:0];
            [self deselectProject];
            [self.projectCollectionView deselectItemAtIndexPath:indexPath animated:YES];
        }
    }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = self.projectArray.count;
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ProjectCollectionViewCell *cell = (ProjectCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSInteger currentTag = cell.tag + 1;
    cell.tag = currentTag;
    
    Project *project = self.projectArray[indexPath.item];
    NSString *previewImageName = project.previewImageName;
    
    if(previewImageName) {
        
        //NSLog(@"previewImageName : %@", previewImageName);
        
        BOOL animated = [self.projectAnimatedArray[indexPath.item] boolValue];
        if(!animated) {
            self.projectAnimatedArray[indexPath.item] = [NSNumber numberWithBool:YES];
        }
        
        NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:previewImageName];
        dispatch_async(backgroundQueue, ^(void) {
            dispatch_semaphore_wait(backgroudQueueSignal, DISPATCH_TIME_FOREVER);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                UIImage *previewImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
                
                if (cell.tag == currentTag) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        if(!animated) {
                            [cell fadeAnimation];
                        } else {
                            cell.previewImageView.alpha = 1;
                        }
                        cell.previewImageView.backgroundColor = [UIColor clearColor];
                        cell.previewImageView.image = previewImage;
                    });
                }
                dispatch_semaphore_signal(backgroudQueueSignal);
            });
            
        });
    } else {
        
        NSLog(@"NO preview");
        
        self.projectAnimatedArray[indexPath.item] = [NSNumber numberWithBool:YES];
        cell.previewImageView.image = nil;
        cell.previewImageView.backgroundColor = [UIColor darkGrayColor];
        [cell fadeAnimation];
    }
    cell.layer.masksToBounds = NO;
    cell.layer.shadowOpacity = 0.15f;
    cell.layer.shadowRadius = 4.0f;
    cell.layer.shadowOffset = CGSizeZero;
    cell.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.bounds].CGPath;
    return cell;
}



#pragma mark <UICollectionViewDelegate>
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Project *project = self.projectArray[indexPath.item];
                                                                    
    if(self.selectedProject == project) {
        [self deselectProject];
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        return NO;
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Project *project = self.projectArray[indexPath.item];
    ProjectCollectionViewCell *projectCell = (ProjectCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self presentProjectPreviewWithProjectCell:projectCell animated:YES];
    [self selectProject:project];
}


#pragma mark - MosaicLayoutDelegate

- (CGFloat)collectionView:(UICollectionView *)collectionView relativeHeightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Project *project = self.projectArray[indexPath.item];
    CGFloat relativeHeight = 1;
    if(project.previewImageSize) {
        CGSize previewImageSize = CGSizeFromString(project.previewImageSize);
        relativeHeight = previewImageSize.height / previewImageSize.width;
    }
    
    return relativeHeight;
}

- (BOOL)collectionView:(UICollectionView *)collectionView isDoubleColumnAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSUInteger)numberOfColumnsInCollectionView:(UICollectionView *)collectionView
{
    //  Set the quantity of columns according of the device and interface orientation
    //if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])){
    if (self.view.frame.size.width > self.view.frame.size.height){
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
            collectionViewNumberOfColumns = kColumnsiPadLandscape;
        }else{
            collectionViewNumberOfColumns = kColumnsiPhoneLandscape;
        }
        
    }else{
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
            collectionViewNumberOfColumns = kColumnsiPadPortrait;
        }else{
            collectionViewNumberOfColumns = kColumnsiPhonePortrait;
        }
    }
    NSUInteger retVal = collectionViewNumberOfColumns;
    //NSLog(@"numberOfColumnsInCollectionView : %li", retVal);
    
    return retVal;
}


@end
