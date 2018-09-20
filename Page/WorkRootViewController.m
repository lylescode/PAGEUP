//
//  WorkRootViewController.m
//  Page
//
//  Created by CMR on 3/17/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "WorkRootViewController.h"
#import "AppDelegate.h"
#import "Project.h"

@interface WorkRootViewController ()
{
    UIScrollView *workScrollView;
    UIView *workWrapView;
    
    NSInteger currentStepIndex;
    NSInteger availableStepIndex;
    BOOL availableNextStep;
    
    BOOL hiddenBackButton;
    BOOL hiddenBottomMenu;
    BOOL hiddenBottomEditorMenu;
    BOOL hiddenShopButton;
}

//@property (weak, nonatomic) IBOutlet UIView *topLineView;
@property (weak, nonatomic) IBOutlet UIButton *shopButton;
//@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIView *bottomMenuView;
@property (weak, nonatomic) IBOutlet UIButton *bottomCancelButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomConfirmButton;
@property (weak, nonatomic) IBOutlet UIView *bottomEditorMenuView;
@property (weak, nonatomic) IBOutlet UIButton *bottomEditorEditButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomEditorGeniusButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomEditorShareButton;
- (IBAction)shopButtonAction:(id)sender;
- (IBAction)bottomMenuButtonAction:(id)sender;
- (IBAction)bottomEditorMenuButtonAction:(id)sender;
//- (IBAction)forwardButtonAction:(id)sender;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) NSArray *workViewControllers;
@property (strong, nonatomic) NSArray *workWrapViews;
@property (strong, nonatomic) NSArray *workBackgroundColors;
@property (weak, nonatomic) WorkStepViewController *currentWorkViewController;
@property (strong, nonatomic) ImportViewController *importViewController;
@property (strong, nonatomic) TemplateViewController *templateViewController;
@property (strong, nonatomic) EditorViewController *editorViewController;
@property (strong, nonatomic) PaperViewController *paperViewController;
@property (strong, nonatomic) ExportViewController *exportViewController;

- (void)initWorkViewControllers;
- (void)updateAvailableStep;
- (void)hiddenBottomMenu:(BOOL)hidden;
- (void)hiddenBottomEditorMenu:(BOOL)hidden;
- (void)hiddenShopButton:(BOOL)hidden;

- (NSString *)writePreviewImageFileWithImage:(UIImage *)previewImage;
- (UIImage *)loadPreviewImageWithPreviewImageName:(NSString *)previewImageName;
- (void)removePreviewImageFileWithPreviewImageName:(NSString *)previewImageName;

@end
static CGSize PageSize;
static CGFloat ScrollPullOffset;

@implementation WorkRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.clipsToBounds = YES;
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    currentStepIndex = -1;
    availableStepIndex = -1;
    availableNextStep = NO;
    
    workScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    workScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    workScrollView.backgroundColor = [UIColor clearColor];
    workScrollView.delegate = self;
    workScrollView.pagingEnabled = NO;
    workScrollView.showsHorizontalScrollIndicator = NO;
    workScrollView.showsVerticalScrollIndicator = NO;
    workScrollView.clipsToBounds = YES;
    workScrollView.bounces = NO;
    workScrollView.directionalLockEnabled = YES;
    workScrollView.alwaysBounceHorizontal = YES;
    workScrollView.alwaysBounceVertical = NO;
    
    workScrollView.scrollEnabled = NO;
    
    [self.view addSubview:workScrollView];
    
    workWrapView = [[UIView alloc] initWithFrame:self.view.bounds];
    workWrapView.clipsToBounds = YES;
    workWrapView.backgroundColor = [UIColor clearColor];
    //workWrapView.backgroundColor = [UIColor colorWithRed:0.874 green:0.874 blue:0.874 alpha:1]; //UIColor colorWithRed:0.203 green:0.203 blue:0.203 alpha:1];
    [workScrollView addSubview:workWrapView];
    
    
    [self.view bringSubviewToFront:self.bottomMenuView];
    [self.view bringSubviewToFront:self.bottomEditorMenuView];
    
    hiddenBottomMenu = YES;
    self.bottomMenuView.userInteractionEnabled = NO;
    self.bottomMenuView.transform = CGAffineTransformMakeTranslation(0, self.bottomMenuView.frame.size.height);
    
    hiddenBottomEditorMenu = YES;
    self.bottomEditorMenuView.userInteractionEnabled = NO;
    self.bottomEditorMenuView.transform = CGAffineTransformMakeTranslation(0, self.bottomEditorMenuView.frame.size.height);
    
    hiddenShopButton = YES;
    self.shopButton.hidden = YES;
    
    
    //[self.view bringSubviewToFront:self.forwardButton];
    //[self.view bringSubviewToFront:self.topLineView];
    
    //self.forwardButton.hidden = YES;
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(workScrollView);
    
    NSArray *workScrollView_H = [NSLayoutConstraint
                                 constraintsWithVisualFormat:@"H:|[workScrollView]|"
                                 options:0
                                 metrics:nil
                                 views:viewsDictionary];
    NSArray *workScrollView_V = [NSLayoutConstraint
                                 constraintsWithVisualFormat:@"V:|[workScrollView]|"
                                 options:0
                                 metrics:nil
                                 views:viewsDictionary];
    
    
    [self.view addConstraints:workScrollView_H];
    [self.view addConstraints:workScrollView_V];
    
    
    CLLocationManager *LM = [[CLLocationManager alloc] init];
    self.locationManager = LM;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    
    //[self.locationManager requestLocationServiceAuthorization]; //Requests permission to use location services whenever the app is running.
    [self.locationManager requestWhenInUseAuthorization]; //Requests permission to use location services while the app is in the foreground.
    
    
    [self.locationManager startUpdatingLocation];
    [self requestLocationServiceAuthorization];
    
    NSLog(@"startUpdatingLocation : %@", self.locationManager);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    //MARK;
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self initWorkViewControllers];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupWorkingProject];
}

- (void)dealloc
{
    self.managedObjectContext = nil;
    
    for(UIViewController *workVC in self.workViewControllers) {
        [workVC.view removeFromSuperview];
    }
    for(UIView *workView in self.workWrapViews) {
        [workView removeFromSuperview];
    }
    self.workViewControllers = nil;
    self.workWrapViews = nil;
    self.workBackgroundColors = nil;
    
    [workWrapView removeFromSuperview];
    [workScrollView removeFromSuperview];
}

/*
- (IBAction)backButtonAction:(id)sender {

     if(currentStepIndex == 0) {
        [self saveCurrentProject];
        [self.workDelegate workRootViewControllerDidBack];
    } else {
        
        [self willActivateWorkAtStep:currentStepIndex - 1];
        [self activateWorkAtStep:currentStepIndex - 1 useScroll:YES];
    }
}

- (IBAction)homeButtonAction:(id)sender {
    MARK;
    [self saveCurrentProject];
    [self.workDelegate workRootViewControllerDidBack];
}
*/
- (IBAction)shopButtonAction:(id)sender {
    MARK;
}

- (IBAction)bottomMenuButtonAction:(id)sender {
    if(sender == self.bottomCancelButton) {
        if(currentStepIndex == 0) {
            [self saveCurrentProject];
            [self.workDelegate workRootViewControllerDidBack];
        } else {
            
            [self willActivateWorkAtStep:currentStepIndex - 1];
            [self activateWorkAtStep:currentStepIndex - 1 useScroll:YES];
        }
    } else if(sender == self.bottomConfirmButton) {
        
        if(currentStepIndex == self.workViewControllers.count - 1) {
            [self saveCurrentProject];
            [self.workDelegate workRootViewControllerDidBack];
        } else if(availableNextStep) {
            [self willActivateWorkAtStep:currentStepIndex + 1];
            [self activateWorkAtStep:currentStepIndex + 1 useScroll:YES];
        }
    }
}

- (IBAction)bottomEditorMenuButtonAction:(id)sender {
    
    if(self.editorViewController) {
        if(sender == self.bottomEditorGeniusButton) {
            [self.editorViewController applyGeniusDesign];
        }
        else if(sender == self.bottomEditorEditButton) {
            [self.editorViewController presentTemplateEditViewController];
        }
        else if(sender == self.bottomEditorShareButton) {
            [self.editorViewController presentShareViewController];
        }
    }
}

/*
- (IBAction)forwardButtonAction:(id)sender {
    
    [self willActivateWorkAtStep:currentStepIndex + 1];
    [self activateWorkAtStep:currentStepIndex + 1 useScroll:YES];
}
*/


- (void)requestLocationServiceAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusDenied) {
        NSString *title = @"Location services are off";
        NSString *message = @"You must turn on in the Location Services Settings";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        alertView.tag = 88;
        [alertView show];
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        //[self.locationManager requestLocationServiceAuthorization];
        [self.locationManager requestWhenInUseAuthorization];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 88) {
        if (buttonIndex == 1) {
            // Send the user to the Settings for this app
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:settingsURL];
        }
    }
}

- (void)setupWorkingProject
{
    [self initWorkViewControllers];
    NSInteger initialStepIndex = 0;
    if(self.workingProjectResource.templateDictionary) {
        initialStepIndex = 2;
        
        workScrollView.hidden = YES;
        
        double delayInSeconds = 0.05;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            workScrollView.hidden = NO;
            workScrollView.contentOffset = CGPointMake(PageSize.width * initialStepIndex, 0);
            
            [self willActivateWorkAtStep:initialStepIndex];
            [self activateWorkAtStep:initialStepIndex useScroll:YES];
        });
        
        
    } else {
        [self willActivateWorkAtStep:initialStepIndex];
        [self activateWorkAtStep:initialStepIndex];
    }
}
- (void)willActivateWorkAtStep:(NSInteger)stepIndex
{
    if(!self.workingProjectResource || stepIndex > self.workViewControllers.count) {
        return;
    }
    if(currentStepIndex == stepIndex) {
        return;
    }
    
    //Import
    if(stepIndex == 0) {
        [self hiddenBottomMenu:NO];
        [self hiddenBottomEditorMenu:YES];
    }
    //Templates
    else if(stepIndex == 1) {
        [self hiddenBottomMenu:NO];
        [self hiddenBottomEditorMenu:YES];
    }
    //Editor
    else if(stepIndex == 2) {
        //[self hiddenBottomMenu:YES];
        //[self hiddenBottomEditorMenu:NO];
        
        [self hiddenBottomMenu:NO];
        [self hiddenBottomEditorMenu:YES];
    }
    else {
        [self hiddenBottomMenu:YES];
        [self hiddenBottomEditorMenu:YES];
    }
    
    if(stepIndex != 1) {
        [self hiddenShopButton:YES];
    }
    
    [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         workWrapView.backgroundColor = self.workBackgroundColors[stepIndex];
                     }
                     completion:nil];
    
    WorkStepViewController *toWorkVC = (WorkStepViewController *)self.workViewControllers[stepIndex];
    [toWorkVC willActivateWork];
}
- (void)activateWorkAtStep:(NSInteger)stepIndex
{
    [self activateWorkAtStep:stepIndex useScroll:NO];
}
- (void)activateWorkAtStep:(NSInteger)stepIndex useScroll:(BOOL)useScroll;
{
    
    if(!self.workingProjectResource || stepIndex > self.workViewControllers.count) {
        return;
    }
    if(currentStepIndex == stepIndex) {
        return;
    }
    
    if(stepIndex == 1) {
        [self hiddenShopButton:NO];
    }
    
    currentStepIndex = stepIndex;
    [self willActivateWorkAtStep:stepIndex];
    [self updateAvailableStep];
    
    WorkStepViewController *toWorkVC = (WorkStepViewController *)self.workViewControllers[stepIndex];
    self.currentWorkViewController = toWorkVC;
    
    NSLog(@"activateWorkAtStep : %li", (long)stepIndex);
    
    if(useScroll) {
        CGFloat animationDelay = 0;
        CGFloat duration = 0.55;
        CGFloat damping = 0.95;
        CGFloat velocity = 0;
        self.view.userInteractionEnabled = NO;
        [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             workScrollView.contentOffset = CGPointMake(PageSize.width * stepIndex, 0);
                         }
                         completion:^(BOOL finished){
                             if(finished) {
                                 NSInteger index = 0;
                                 for(UIViewController *vc in self.workViewControllers) {
                                     WorkStepViewController *workVC = (WorkStepViewController *)vc;
                                     if(index == currentStepIndex) {
                                         [workVC activateWork];
                                     } else {
                                         [workVC deactivateWork];
                                     }
                                     index++;
                                 }
                                 self.view.userInteractionEnabled = YES;
                             }
                         }];
    } else {
        NSInteger index = 0;
        for(UIViewController *vc in self.workViewControllers) {
            WorkStepViewController *workVC = (WorkStepViewController *)vc;
            if(index == currentStepIndex) {
                [workVC activateWork];
            } else {
                [workVC deactivateWork];
            }
            index++;
        }
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    
    if(stepIndex == 0) {
        BOOL shown = [[defaults objectForKey:TOOLTIP_PHOTOS_KEY] boolValue];
        
        if(!shown) {
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self.workDelegate workRootViewControllerNeedPhotosTooltip];
            });
        }
    }
    else if(stepIndex == 1) {
        BOOL shown = [[defaults objectForKey:TOOLTIP_LAYOUTS_KEY] boolValue];
        
        if(!shown) {
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self.workDelegate workRootViewControllerNeedLayoutsTooltip];
            });
        }
    }
    else if(stepIndex == 2) {
        BOOL shown = [[defaults objectForKey:TOOLTIP_EDIT_KEY] boolValue];
        
        if(!shown) {
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self.workDelegate workRootViewControllerNeedEditTooltip];
            });
        }
    }
    
    
    /*
    CGRect originFrame = workWrapView.frame;
    CGRect newFrame = originFrame;
    
    CGFloat targetPageX = 0;
    
    UIView *workView = workVC.view;
    targetPageX = -workView.frame.origin.x;
    
    newFrame = CGRectMake(targetPageX, originFrame.origin.y, originFrame.size.width, originFrame.size.height);
    
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.45 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         workWrapView.frame = newFrame;
                     }
                     completion:^(BOOL finished){
                         if(finished) {
                             self.view.userInteractionEnabled = YES;
                             // TODO: 애니메이션 끝난 이후 해당 스텝 활성화 하는 코드는 여기에
                         }
                     }];
     */
}


- (void)initWorkViewControllers
{
    //NSLog(@"self.view.bounds %@", NSStringFromCGRect(self.view.bounds));
    //NSLog(@"workScrollView.frame %@", NSStringFromCGRect(workScrollView.frame));
    //NSLog(@"workWrapView.frame %@", NSStringFromCGRect(workWrapView.frame));
    
    if(!self.workingProjectResource) {
        return;
    }
    ScrollPullOffset = -(self.view.bounds.size.width / 4);
    PageSize = self.view.bounds.size;
    
    //NSLog(@"PageSize : %@", NSStringFromCGSize(PageSize));
    if(!self.workViewControllers) {
        
        // UIViewController 의 view 에 auto layout 이 적용된 경우는 addSubview 대상 뷰의 크기에 따라 크기가 늘어나기 떄문에 감싸는 뷰를 따로 만들어 줘야 함.
        UIView *importView = [[UIView alloc] initWithFrame:self.view.bounds];
        [workWrapView addSubview:importView];
        
        UIView *templateView = [[UIView alloc] initWithFrame:self.view.bounds];
        [workWrapView addSubview:templateView];
        
        UIView *editorView = [[UIView alloc] initWithFrame:self.view.bounds];
        [workWrapView addSubview:editorView];
        /*
        UIView *paperView = [[UIView alloc] initWithFrame:self.view.bounds];
        [workWrapView addSubview:paperView];
        */
        /*
        UIView *exportView = [[UIView alloc] initWithFrame:self.view.bounds];
        [workWrapView addSubview:exportView];
        */
        ImportViewController *importVC = [[ImportViewController alloc] init];
        importVC.workStepDelegate = self;
        importVC.importDelegate = self;
        importVC.projectResource = self.workingProjectResource;
        importVC.view.frame = self.view.bounds;
        importVC.view.backgroundColor = [UIColor clearColor];
        
        [importView addSubview:importVC.view];
        
        TemplateViewController *templateVC = [[TemplateViewController alloc] init];
        templateVC.workStepDelegate = self;
        templateVC.templateDelegate = self;
        templateVC.projectResource = self.workingProjectResource;
        templateVC.view.frame = self.view.bounds;
        templateVC.view.backgroundColor = [UIColor clearColor];
        
        [templateView addSubview:templateVC.view];
        
        EditorViewController *editorVC = [[EditorViewController alloc] init];
        editorVC.workStepDelegate = self;
        editorVC.editorDelegate = self;
        editorVC.projectResource = self.workingProjectResource;
        editorVC.view.frame = self.view.bounds;
        editorVC.view.backgroundColor = [UIColor clearColor];
        
        [editorView addSubview:editorVC.view];
        /*
        PaperViewController *paperVC = [[PaperViewController alloc] init];
        paperVC.workStepDelegate = self;
        paperVC.paperDelegate = self;
        paperVC.projectResource = self.workingProjectResource;
        paperVC.view.frame = self.view.bounds;
        paperVC.view.backgroundColor = [UIColor clearColor];
        
        [paperView addSubview:paperVC.view];
        */
        /*
        ExportViewController *exportVC = [[ExportViewController alloc] init];
        exportVC.workStepDelegate = self;
        exportVC.exportDelegate = self;
        exportVC.projectResource = self.workingProjectResource;
        exportVC.view.frame = self.view.bounds;
        editorVC.view.backgroundColor = [UIColor clearColor];
        
        [exportView addSubview:exportVC.view];
         */
        self.importViewController = importVC;
        self.templateViewController = templateVC;
        self.editorViewController = editorVC;
        //self.paperViewController = paperVC;
        //self.exportViewController = exportVC;
        
        //self.workViewControllers = @[importVC, templateVC, editorVC, paperVC, exportVC];
        //self.workWrapViews = @[importView, templateView, editorView, paperView, exportView];
        //self.workViewControllers = @[importVC, templateVC, editorVC, exportVC];
        //self.workWrapViews = @[importView, templateView, editorView, exportView];;
        self.workViewControllers = @[importVC, templateVC, editorVC];
        self.workWrapViews = @[importView, templateView, editorView];
        
        /*
        self.workBackgroundColors = @[
                                      [UIColor colorWithRed:0.105 green:0.113 blue:0.137 alpha:1],
                                      [UIColor colorWithRed:0.105 green:0.113 blue:0.137 alpha:1],
                                      [UIColor colorWithRed:0.874 green:0.874 blue:0.874 alpha:1],
                                      [UIColor colorWithRed:0.105 green:0.113 blue:0.137 alpha:1],
                                      [UIColor colorWithRed:0.105 green:0.113 blue:0.137 alpha:1]
                                      ];
         */
        self.workBackgroundColors = @[
                                      [UIColor colorWithRed:1 green:1 blue:1 alpha:1],
                                      [UIColor colorWithRed:1 green:1 blue:1 alpha:1],
                                      [UIColor colorWithRed:0 green:0 blue:0 alpha:0],
                                      [UIColor colorWithRed:0 green:0 blue:0 alpha:0],
                                      [UIColor colorWithRed:0 green:0 blue:0 alpha:0]
                                      ];
    }
    
    CGFloat viewOriginX = 0;
    for(UIView *workView in self.workWrapViews) {
        workView.frame = CGRectMake(viewOriginX, workView.frame.origin.y, PageSize.width, PageSize.height);
        viewOriginX += PageSize.width;
    }
    
    workWrapView.frame = CGRectMake(0, 0, viewOriginX, PageSize.height);
    if(currentStepIndex != -1) {
        workScrollView.contentOffset = CGPointMake(PageSize.width * currentStepIndex, 0);
    }
    
    [self updateAvailableStep];
}
- (void)updateAvailableStep
{
    availableStepIndex = 0;
    if(self.workingProjectResource.photoArray.count > 0) {
        availableStepIndex = 1;
        
        if(self.workingProjectResource.templateDictionary) {
            availableStepIndex = 2;
        }
    }
    
    availableNextStep = (currentStepIndex < availableStepIndex);
    
    NSLog(@"availableStepIndex : %li", (long)availableStepIndex);
    workScrollView.contentSize = CGSizeMake(PageSize.width * (availableStepIndex + 1), workScrollView.frame.size.height);
    
    
    /*
     if(availableNextStep) {
     
     [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
     animations:^{
     self.forwardButton.transform = CGAffineTransformIdentity;
     }
     completion:^(BOOL finished){
     }];
     } else {
     
     [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
     animations:^{
     self.forwardButton.transform = CGAffineTransformMakeTranslation(self.forwardButton.frame.size.width, 0);
     }
     completion:^(BOOL finished){
     }];
     }
     */
}
- (void)hiddenBackButton:(BOOL)hidden
{
    /*
    hiddenBackButton = hidden;
    if(hidden) {
        self.backButton.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.backButton.alpha = 0;
                         }
                         completion:^(BOOL finished){
                         }];
    } else {
        self.backButton.userInteractionEnabled = YES;
        self.backButton.hidden = NO;
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.backButton.alpha = 1;
                         }
                         completion:^(BOOL finished){
                         }];
    }
     */
}
- (void)hiddenBottomMenu:(BOOL)hidden
{
    hiddenBottomMenu = hidden;
    if(hidden) {
        self.bottomMenuView.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.bottomMenuView.transform = CGAffineTransformMakeTranslation(0, self.bottomMenuView.frame.size.height);
                         }
                         completion:^(BOOL finished){
                         }];
    } else {
        self.bottomMenuView.userInteractionEnabled = YES;
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.bottomMenuView.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished){
                         }];
    }
}

- (void)hiddenBottomEditorMenu:(BOOL)hidden
{
    hiddenBottomEditorMenu = hidden;
    if(hidden) {
        self.bottomEditorMenuView.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.bottomEditorMenuView.transform = CGAffineTransformMakeTranslation(0, self.bottomEditorMenuView.frame.size.height);
                         }
                         completion:^(BOOL finished){
                         }];
    } else {
        self.bottomEditorMenuView.userInteractionEnabled = YES;
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.bottomEditorMenuView.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished){
                         }];
    }
}

- (void)hiddenShopButton:(BOOL)hidden
{
    /*
    hiddenShopButton = hidden;
    if(hidden) {
        self.shopButton.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.shopButton.alpha = 0;
                         }
                         completion:^(BOOL finished){
                         }];
    } else {
        self.shopButton.userInteractionEnabled = YES;
        self.shopButton.hidden = NO;
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.shopButton.alpha = 1;
                         }
                         completion:^(BOOL finished){
                         }];
    }
     */
}


- (void)saveCurrentProject
{
    [self saveCurrentProjectWithPreviewImage:YES];
}


- (void)saveCurrentProjectWithPreviewImage:(BOOL)updatePreview
{
    MARK;
    if(self.workingProjectResource.photoArray.count == 0) {
        return;
    }
    if(!self.workingProjectResource.templateDictionary) {
        [self.workingProjectResource removeAllPhotoAssetCachedImageFiles];
        return;
    }
    Project *currentProject;
    if(self.workingProjectResource.project) {
        currentProject = self.workingProjectResource.project;
    } else {
        currentProject = [NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:self.managedObjectContext];
    }
    
    
    UIImage *previewImage = nil;
    if(self.editorViewController) {
        [self.editorViewController prepareForSaveProject];
        if(updatePreview) {
            previewImage = [self.editorViewController previewImage];
        }
    }
    
    if(self.importViewController) {
        [self.importViewController prepareForSaveProject];
    }
    
    [self.workingProjectResource prepareForSaveProject];
    
    if (currentProject.creationDate == nil) {
        currentProject.creationDate = [NSDate date];
    }
    
    //TODO: 불러온 프로젝트인 경우 변경된 내용이 있을때만 새롭게 저장해줘야 함
    
    if(previewImage) {
        if(currentProject.previewImageName) {
            [self removePreviewImageFileWithPreviewImageName:currentProject.previewImageName];
        }
        currentProject.previewImageName = [self writePreviewImageFileWithImage:previewImage];
        currentProject.previewImageSize = NSStringFromCGSize(previewImage.size);
    }
    
    currentProject.modificationDate = [NSDate date];
    [currentProject setTemplateDictionary:self.workingProjectResource.templateDictionary];
    [currentProject setTemplateTextDictionary:self.workingProjectResource.templateTextDictionary];
    [currentProject setProjectDictionary:self.workingProjectResource.projectDictionary];
    [currentProject setPhotoAssetDictionary:self.workingProjectResource.photoAssetDictionaryArray];
    
    self.workingProjectResource.project = currentProject;
    NSError *error;
    
    if ([self.managedObjectContext hasChanges] && [[self managedObjectContext] save:&error]) {
        NSLog(@"Project Saved.....");
    } else {
        NSLog(@"Project Managed Object Saving Error has occurred");
    }
}

- (void)updateCurrentProject
{
    if(self.workingProjectResource.photoArray.count == 0) {
        return;
    }
    if(!self.workingProjectResource.templateDictionary) {
        return;
    }
    if(!self.workingProjectResource.project) {
        return;
    }
    Project *currentProject = self.workingProjectResource.project;
    
    if(self.importViewController) {
        [self.importViewController prepareForSaveProject];
    }
    
    if(self.editorViewController) {
        [self.editorViewController prepareForSaveProject];
    }
    
    [currentProject setTemplateDictionary:self.workingProjectResource.templateDictionary];
    [currentProject setTemplateTextDictionary:self.workingProjectResource.templateTextDictionary];
    [currentProject setProjectDictionary:self.workingProjectResource.projectDictionary];
    [currentProject setPhotoAssetDictionary:self.workingProjectResource.photoAssetDictionaryArray];
    
    self.workingProjectResource.project = currentProject;
    NSError *error;
    
    if ([self.managedObjectContext hasChanges] && [[self managedObjectContext] save:&error]) {
        NSLog(@"Project Updated.....");
    } else {
        NSLog(@"Project Managed Object Saving Error has occurred");
    }
}

- (NSString *)writePreviewImageFileWithImage:(UIImage *)previewImage
{
    NSData *imageData = UIImageJPEGRepresentation(previewImage, 0.75);
    
    NSString *imageName = @"pageup_project_preview";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSInteger r = arc4random() % 100000000;
    NSString *imageFullname = [NSString stringWithFormat:@"%@_%li.JPG",imageName, (long)r];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:imageFullname];
    
    BOOL isDir;
    while ([fileManager fileExistsAtPath:imagePath isDirectory:&isDir] == YES) {
        r = arc4random() % 100000000;
        
        imageFullname = [NSString stringWithFormat:@"%@_%li.JPG",imageName, (long)r];
        imagePath = [documentsDirectory stringByAppendingPathComponent:imageFullname];
    }
    if (![imageData writeToFile:imagePath atomically:YES]) {
        NSLog(@"Failed to preview image data to disk");
    } else {
        NSLog(@"preview image path %@", imagePath);
    }
    return imageFullname;
}
- (UIImage *)loadPreviewImageWithPreviewImageName:(NSString *)previewImageName
{
    if(!previewImageName) {
        return nil;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:previewImageName];
    
    UIImage *loadedImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
    return loadedImage;
}
- (void)removePreviewImageFileWithPreviewImageName:(NSString *)previewImageName
{
    if(!previewImageName) {
        return;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:previewImageName];
    
    NSError *error = nil;
    if(![fileManager removeItemAtPath:imagePath error:&error]) {
        NSLog(@"Failed to preview image remove from disk : %@", error);
    } else {
        NSLog(@"cached preview removed : %@", previewImageName);
    }
    
    //NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    //NSLog(@"directoryContents : %@", directoryContents);
}

#pragma mark - WorkStepViewControllerDelegate
- (void)workStepViewControllerNeedDisableScroll:(BOOL)disableScroll
{
    //workScrollView.scrollEnabled = !disableScroll;
}
- (void)workStepViewControllerNeedDisableCommon:(BOOL)disableCommon
{
    if(disableCommon) {
        //workScrollView.scrollEnabled = NO;
        
        /*
        CGAffineTransform buttonTransform = CGAffineTransformMakeTranslation(0, -53);
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.backButton.alpha = 0;
                             self.homeButton.alpha = 0;
                             
                             self.backButton.transform = buttonTransform;
                             self.homeButton.transform = buttonTransform;
                         }
                         completion:^(BOOL finished){
                         }];
         */
        if(!hiddenShopButton) {
            [UIView animateWithDuration:0.45
                             animations:^{
                                 self.shopButton.alpha = 0;
                             }];
        }
        if(!hiddenBottomMenu) {
            self.bottomMenuView.userInteractionEnabled = NO;
            [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.bottomMenuView.transform = CGAffineTransformMakeTranslation(0, self.bottomMenuView.frame.size.height);
                             }
                             completion:^(BOOL finished){
                             }];
        }
        if(!hiddenBottomEditorMenu) {
            self.bottomEditorMenuView.userInteractionEnabled = NO;
            [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.bottomEditorMenuView.transform = CGAffineTransformMakeTranslation(0, self.bottomEditorMenuView.frame.size.height);
                             }
                             completion:^(BOOL finished){
                             }];
        }
        if(availableNextStep) {
            [UIView animateWithDuration:0.45
                             animations:^{
                                 //self.forwardButton.alpha = 0;
                                 //self.forwardButton.userInteractionEnabled = NO;
                             }];
        }
        
    } else {
        //workScrollView.scrollEnabled = YES;
        
        /*
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.backButton.alpha = 1;
                             self.homeButton.alpha = 1;
                             
                             self.backButton.transform = CGAffineTransformIdentity;
                             self.homeButton.transform = CGAffineTransformIdentity;
                             //self.topLineView.alpha = 1;
                         }
                         completion:^(BOOL finished){
                         }];
         */
        if(!hiddenShopButton) {
            [UIView animateWithDuration:0.45
                             animations:^{
                                 self.shopButton.alpha = 1;
                             }];
        }
        
        
        if(!hiddenBottomMenu) {
            self.bottomMenuView.userInteractionEnabled = YES;
            [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.bottomMenuView.transform = CGAffineTransformIdentity;
                             }
                             completion:^(BOOL finished){
                             }];
        }
        
        if(!hiddenBottomEditorMenu) {
            self.bottomEditorMenuView.userInteractionEnabled = YES;
            [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.bottomEditorMenuView.transform = CGAffineTransformIdentity;
                             }
                             completion:^(BOOL finished){
                             }];
        }
        if(availableNextStep) {
            /*
            self.forwardButton.userInteractionEnabled = YES;
            [UIView animateWithDuration:0.45
                         animations:^{
                             self.forwardButton.alpha = 1;
             }];
             */
        }
    }
}
- (void)workStepViewControllerShouldNext
{
    
}
- (void)workStepViewControllerShouldBack
{
    
}

#pragma mark - ImportViewControllerDelegate
- (void)importViewControllerDidChangePhoto
{
    if(self.templateViewController) {
        [self.templateViewController updateSelectedPhotos];
    }
    if(self.editorViewController) {
        [self.editorViewController updateSelectedPhotos];
        [self updateCurrentProject];
    }
    
    [self updateAvailableStep];
}

#pragma mark - TemplateViewControllerDelegate

- (void)templateViewControllerDidCancel
{
}
- (void)templateViewControllerDidSelect:(NSDictionary *)templateDictionary
{
    self.workingProjectResource.templateDictionary = [templateDictionary copy];
    
    if(self.editorViewController) {
        [self.editorViewController updateTemplate];
    }
    
    if(self.paperViewController) {
        [self.paperViewController updateTemplate];
    }
    if(self.exportViewController) {
        [self.exportViewController updateTemplate];
    }
    [self willActivateWorkAtStep:2];
    [self activateWorkAtStep:2 useScroll:YES];
}

#pragma mark - EditorViewControllerDelegate
- (void)editorViewControllerNeedTemplateEditTooltip
{
    [self.workDelegate workRootViewControllerNeedTemplateEditTooltip];
}
- (void)editorViewControllerDidEdit
{
    if(self.paperViewController) {
        [self.paperViewController updateTemplate];
    }
    if(self.exportViewController) {
        [self.exportViewController updateTemplate];
    }
}
- (void)editorViewControllerDidSwapPhoto
{
    if(self.templateViewController) {
        [self.templateViewController updateSelectedPhotos];
    }
    if(self.paperViewController) {
        [self.paperViewController updateTemplate];
    }
    
    if(self.exportViewController) {
        [self.exportViewController updateTemplate];
    }
    [self updateCurrentProject];
}

- (void)editorViewControllerDidReplacePhoto
{
    if(self.templateViewController) {
        [self.templateViewController updateSelectedPhotos];
    }
    if(self.paperViewController) {
        [self.paperViewController updateTemplate];
    }
    if(self.exportViewController) {
        [self.exportViewController updateTemplate];
    }
    [self updateCurrentProject];
}
- (void)editorViewControllerDidSaveProject
{
    [self saveCurrentProjectWithPreviewImage:NO];
}
- (void)editorViewControllerDidShareActivityWithImage:(UIImage *)image completion:(void(^)(void))callback
{
    [self.workDelegate workRootViewControllerDidShareActivityWithImage:image completion:callback];
}
- (void)editorViewControllerDidShareActivityWithPDFURL:(NSURL *)PDFURL completion:(void(^)(void))callback
{
    [self.workDelegate workRootViewControllerDidShareActivityWithPDFURL:PDFURL completion:callback];
}
- (void)editorViewControllerDidShareActivityWithVideoURL:(NSURL *)videoURL completion:(void(^)(void))callback
{
    [self.workDelegate workRootViewControllerDidShareActivityWithVideoURL:videoURL completion:callback];
}

#pragma mark - PaperViewControllerDelegate
- (UIImage *)paperViewControllerNeedResultImage
{
    UIImage *resultIamge = nil;
    if(self.editorViewController) {
        resultIamge = [self.editorViewController resultImage];
    }
    
    return resultIamge;
}

- (UIImage *)paperViewControllerNeedPreviewImage
{
    UIImage *previewImage = nil;
    if(self.editorViewController) {
        previewImage = [self.editorViewController previewImage];
    }
    return previewImage;
}

- (void)paperViewControllerDidShareActivityWithImage:(UIImage *)image completion:(void(^)(void))callback
{
    [self.workDelegate workRootViewControllerDidShareActivityWithImage:image completion:callback];
}


#pragma mark - ExportViewControllerDelegate
- (UIImage *)exportViewControllerNeedResultImage
{
    UIImage *resultIamge = nil;
    if(self.editorViewController) {
        resultIamge = [self.editorViewController resultImage];
    }
    
    return resultIamge;
}

- (UIImage *)exportViewControllerNeedPreviewImage
{
    UIImage *previewImage = nil;
    if(self.editorViewController) {
        previewImage = [self.editorViewController previewImage];
    }
    return previewImage;
}

- (void)exportViewControllerDidShareActivityWithImage:(UIImage *)image completion:(void(^)(void))callback
{
    [self.workDelegate workRootViewControllerDidShareActivityWithImage:image completion:callback];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    //NSLog(@"scrollViewWillEndDragging");
    
    
    CGFloat x = (targetContentOffset->x);
    x = (roundf(x / PageSize.width) * PageSize.width);
    targetContentOffset->x = x;
    
    NSInteger stepIndex = x / PageSize.width;
    [self willActivateWorkAtStep:stepIndex];
    
    //NSLog(@"x : %f", x);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger stepIndex = scrollView.contentOffset.x / PageSize.width;
    [self activateWorkAtStep:stepIndex];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat offsetX = scrollView.contentOffset.x;
    
    if (offsetX < ScrollPullOffset) {
        scrollView.scrollEnabled = NO;
        [scrollView setContentOffset:CGPointMake(offsetX, 0)];
        [self.workDelegate workRootViewControllerDidBack];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    
    return YES;
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}


#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [self.locationManager stopUpdatingLocation];
    // Reverse Geocoding
    //NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        //NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            CLPlacemark *placemark = [placemarks lastObject];
            
            /*
            NSString *placemarkStriung = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                                          placemark.subThoroughfare, placemark.thoroughfare,
                                          placemark.postalCode, placemark.locality,
                                          placemark.administrativeArea,
                                          placemark.country];
            NSLog(@"placemarkStriung : %@", placemarkStriung);
             */
            
            self.workingProjectResource.locationString = [placemark.administrativeArea copy];
            
            //NSLog(@"self.workingProjectResource.locationString : %@", self.workingProjectResource.locationString);
        } else {
            NSLog(@"%@", error.debugDescription);
        }
        //NSLog(@"didUpdateToLocation");
    }];
    
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
    /*
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
     
     */
}

@end
