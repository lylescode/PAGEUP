//
//  MainViewController.m
//  Page
//
//  Created by CMR on 11/17/14.
//  Copyright (c) 2014 Page. All rights reserved.
//

#import "MainViewController.h"
#import "DeviceUtils.h"
#import "AssetLibraryRootListViewController.h"
#import "DMActivityInstagram.h"

@interface MainViewController ()
{
    
}

@property (strong, nonatomic) UIView *launchScreenView;
@property (strong, nonatomic) UIViewController *currentViewController;
@property (strong, nonatomic) TooltipViewController *tooltipViewController;
@property (strong, nonatomic) ProjectResource *workingProject;

@property (strong, nonatomic) UIDocumentInteractionController *instagramDocumentInteractionController;

- (void)applicationDidEnterBackground;
- (void)saveCurrentProject;

- (void)emptyDocumentsDirectory;

- (void)launchHome;
- (void)goWorkRoot;
- (void)goHome;
- (void)goAbout;


- (void)showHomeTooltip;
- (void)showPhotosTooltip;
- (void)showLayoutTooltip;
- (void)showEditTooltip;
- (void)showTemplateEditTooltip;

@end

@implementation MainViewController
@synthesize launchScreenView;
@synthesize currentViewController;
@synthesize workingProject;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    NSLog(@"language : %@", language);
    
    self.view.backgroundColor = [UIColor blackColor];
    [self emptyDocumentsDirectory];
    
    for(NSString *familyName in[UIFont familyNames]) {
        NSLog(@"%@ : [ %@ ]",familyName, [[UIFont fontNamesForFamilyName:familyName] description]);
    }
    /*
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *displayName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    NSLog(@"iOS %@", [[NSProcessInfo processInfo] operatingSystemVersionString]);
    NSLog(@"Device Version : %@", [DeviceUtils platformString]);
    NSLog(@"App Version : %@ (Build %@)", version, build);
    NSLog(@"App Name : %@", displayName);
     */
    
    [self launchHome];
    /*
    */
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)applicationDidEnterBackground
{
    [self saveCurrentProject];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)saveCurrentProject
{
    if([currentViewController isKindOfClass:[WorkRootViewController class]]) {
        WorkRootViewController *workRootVC = (WorkRootViewController *)currentViewController;
        [workRootVC saveCurrentProject];
        
    }
}
- (void)emptyDocumentsDirectory
{
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    //NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *files = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
    if(files.count > 0) {
        NSLog(@"documentsDirectory files : %@", files);
        
        return;
        /*
        while (files.count > 0) {
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
            if (error == nil) {
                for (NSString *path in directoryContents) {
                    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];
                    NSLog(@"removed : %@", fullPath);
                    BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
                    files = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
                    if (!removeSuccess) {
                        // Error
                    }
                }
            } else {
                // Error
            }
        }
         */
    }
}


- (void)launchHome
{
    NSArray *viewArray = [[NSBundle mainBundle] loadNibNamed:@"LaunchScreen" owner:self options:nil];
    self.launchScreenView = [viewArray objectAtIndex:0];
    launchScreenView.translatesAutoresizingMaskIntoConstraints = NO;
    launchScreenView.frame = self.view.bounds;
    [self.view addSubview:launchScreenView];
    
    
    UIView *dimmedView = [[UIView alloc] initWithFrame:self.view.bounds];
    dimmedView.translatesAutoresizingMaskIntoConstraints = NO;
    dimmedView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:dimmedView];
    
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(launchScreenView, dimmedView);
    NSArray *launchScreenView_H = [NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:|[launchScreenView]|"
                                   options:0
                                   metrics:nil
                                   views:viewsDictionary];
    NSArray *launchScreenView_V = [NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:|[launchScreenView]|"
                                   options:0
                                   metrics:nil
                                   views:viewsDictionary];
    
    
    [self.view addConstraints:launchScreenView_H];
    [self.view addConstraints:launchScreenView_V];
    
    NSArray *dimmedView_H = [NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:|[dimmedView]|"
                                   options:0
                                   metrics:nil
                                   views:viewsDictionary];
    NSArray *dimmedView_V = [NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:|[dimmedView]|"
                                   options:0
                                   metrics:nil
                                   views:viewsDictionary];
    [self.view addConstraints:dimmedView_H];
    [self.view addConstraints:dimmedView_V];
    
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    homeVC.homeDelegate = self;
    homeVC.view.frame = self.view.bounds;
    [self.view addSubview:homeVC.view];
    
    self.currentViewController = homeVC;
    
    CGFloat animationDelay = 0.5;
    CGFloat duration = 0.75;
    CGFloat damping = 0.95;
    CGFloat velocity = 0;
    
    dimmedView.alpha = 0;
    homeVC.view.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
    
    [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         dimmedView.alpha = 0.85;
                         homeVC.view.transform = CGAffineTransformIdentity;
                         launchScreenView.transform = CGAffineTransformMakeScale(0.98, 0.98);
                     }
                     completion:^(BOOL finished){
                         if(finished) {
                             [launchScreenView removeFromSuperview];
                             self.launchScreenView = nil;
                             [dimmedView removeFromSuperview];
                         }
                     }];
    
}
- (void)goWorkRoot
{
    UIViewController *currentVC = (UIViewController *)currentViewController;
    
    UIView *dimmedView = [[UIView alloc] initWithFrame:self.view.bounds];
    dimmedView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:dimmedView];
    
    WorkRootViewController *workRootVC = [[WorkRootViewController alloc] init];
    workRootVC.workDelegate = self;
    workRootVC.view.frame = self.view.bounds;
    workRootVC.workingProjectResource = workingProject;
    [self.view addSubview:workRootVC.view];
    
    CGFloat animationDelay = 0;
    CGFloat duration = 0.65;
    CGFloat damping = 0.85;
    CGFloat velocity = 0;
    
    
    dimmedView.alpha = 0;
    /*
    workRootVC.view.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0);
    CGAffineTransform homeTransform = CGAffineTransformMakeTranslation(-(self.view.frame.size.width * 0.15), 0);
    homeTransform = CGAffineTransformScale(homeTransform, 0.96, 0.96);
    */
    
    workRootVC.view.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
    CGAffineTransform homeTransform = CGAffineTransformMakeTranslation(0, -(self.view.frame.size.height * 0.15));
    homeTransform = CGAffineTransformScale(homeTransform, 0.96, 0.96);
    
    
    [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         dimmedView.alpha = 0.85;
                         workRootVC.view.transform = CGAffineTransformIdentity;
                         //homeVC.view.transform = CGAffineTransformMakeTranslation(-(self.view.frame.size.width * 0.5), 0);
                         currentVC.view.transform = homeTransform;
                     }
                     completion:^(BOOL finished){
                         if(finished) {
                             [currentVC.view removeFromSuperview];
                             [dimmedView removeFromSuperview];
                             
                             self.currentViewController = workRootVC;
                         }
                     }];
}
- (void)goHome
{
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    homeVC.homeDelegate = self;
    homeVC.view.frame = self.view.bounds;
    [self.view addSubview:homeVC.view];
    
    UIView *dimmedView = [[UIView alloc] initWithFrame:self.view.bounds];
    dimmedView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:dimmedView];
    
    NSLog(@"currentViewController : %@" , currentViewController);
    UIViewController *currentVC = (UIViewController *)currentViewController;
    [self.view bringSubviewToFront:currentVC.view];
    
    
    CGFloat animationDelay = 0;
    CGFloat duration = 0.65;
    CGFloat damping = 0.85;
    CGFloat velocity = 0;
    
    
    dimmedView.alpha = 1;
    
    CGAffineTransform homeTransform;
    CGAffineTransform toTransform;
    if([currentViewController isKindOfClass:[WorkRootViewController class]]) {
        /*
        homeTransform = CGAffineTransformMakeTranslation(-(self.view.frame.size.width * 0.15), 0);
        homeTransform = CGAffineTransformScale(homeTransform, 0.96, 0.96);
        
        toTransform = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0);
        */
        
        homeTransform = CGAffineTransformMakeTranslation(0, -(self.view.frame.size.height * 0.15));
        homeTransform = CGAffineTransformScale(homeTransform, 0.96, 0.96);
        
        toTransform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
    } else {
        homeTransform = CGAffineTransformMakeTranslation(-(self.view.frame.size.width * 0.15), 0);
        homeTransform = CGAffineTransformScale(homeTransform, 0.96, 0.96);
        
        toTransform = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0);
    }
    
    homeVC.view.transform = homeTransform;
    
    [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         dimmedView.alpha = 0;
                         homeVC.view.transform = CGAffineTransformIdentity;
                         currentVC.view.transform = toTransform;
                     }
                     completion:^(BOOL finished){
                         if(finished) {
                             [currentVC.view removeFromSuperview];
                             [dimmedView removeFromSuperview];
                             
                             self.currentViewController = homeVC;
                         }
                     }];
}

- (void)goAbout
{
    UIViewController *currentVC = (UIViewController *)currentViewController;
    
    UIView *dimmedView = [[UIView alloc] initWithFrame:self.view.bounds];
    dimmedView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:dimmedView];
    
    AboutViewController *aboutVC;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        aboutVC = [[AboutViewController alloc] init];
    } else {
        aboutVC = [[AboutViewController alloc] initWithNibName:@"AboutViewController_iPad" bundle:nil];
    }
    aboutVC.aboutDelegate = self;
    aboutVC.view.frame = self.view.bounds;
    [self.view addSubview:aboutVC.view];
    
    CGFloat animationDelay = 0;
    CGFloat duration = 0.65;
    CGFloat damping = 0.85;
    CGFloat velocity = 0;
    
    
    dimmedView.alpha = 0;
    //workRootVC.view.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0);
    aboutVC.view.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0);
    
    
    CGAffineTransform homeTransform = CGAffineTransformMakeTranslation(-(self.view.frame.size.width * 0.15), 0);
    homeTransform = CGAffineTransformScale(homeTransform, 0.96, 0.96);
    
    [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         dimmedView.alpha = 0.85;
                         aboutVC.view.transform = CGAffineTransformIdentity;
                         //homeVC.view.transform = CGAffineTransformMakeTranslation(-(self.view.frame.size.width * 0.5), 0);
                         currentVC.view.transform = homeTransform;
                     }
                     completion:^(BOOL finished){
                         if(finished) {
                             [currentVC.view removeFromSuperview];
                             [dimmedView removeFromSuperview];
                             
                             self.currentViewController = aboutVC;
                         }
                     }];
}

- (void)showHomeTooltip
{
    TooltipViewController *tooltipVC = [[TooltipViewController alloc] init];
    tooltipVC.tooltipDelegate = self;
    tooltipVC.view.frame = self.view.bounds;
    [self.view addSubview:tooltipVC.view];
    self.tooltipViewController = tooltipVC;
    
    [tooltipVC showHomeTooltip];

}
- (void)showPhotosTooltip
{
    TooltipViewController *tooltipVC = [[TooltipViewController alloc] init];
    tooltipVC.tooltipDelegate = self;
    tooltipVC.view.frame = self.view.bounds;
    [self.view addSubview:tooltipVC.view];
    self.tooltipViewController = tooltipVC;
    
    [tooltipVC showPhotosTooltip];
    
}
- (void)showLayoutTooltip
{
    TooltipViewController *tooltipVC = [[TooltipViewController alloc] init];
    tooltipVC.tooltipDelegate = self;
    tooltipVC.view.frame = self.view.bounds;
    [self.view addSubview:tooltipVC.view];
    self.tooltipViewController = tooltipVC;
    
    [tooltipVC showLayoutTooltip];
}
- (void)showEditTooltip
{
    TooltipViewController *tooltipVC = [[TooltipViewController alloc] init];
    tooltipVC.tooltipDelegate = self;
    tooltipVC.view.frame = self.view.bounds;
    [self.view addSubview:tooltipVC.view];
    self.tooltipViewController = tooltipVC;
    
    [tooltipVC showEditTooltip];
}

- (void)showTemplateEditTooltip
{
    TooltipViewController *tooltipVC = [[TooltipViewController alloc] init];
    tooltipVC.tooltipDelegate = self;
    tooltipVC.view.frame = self.view.bounds;
    [self.view addSubview:tooltipVC.view];
    self.tooltipViewController = tooltipVC;
    
    [tooltipVC showTemplateEditTooltip];
}



#pragma mark - AboutViewControllerDelegate
- (void)aboutViewControllerDidClose
{
    [self goHome];
}

#pragma mark - HomeViewControllerDelegate

- (void)homeViewControllerNeedTooltip
{
    [self showHomeTooltip];
}

- (void)homeViewControllerDidNewProject
{
    ProjectResource *projectResource = [[ProjectResource alloc] init];
    self.workingProject = projectResource;
    [self goWorkRoot];
}
- (void)homeViewControllerDidNewWithProjectType:(NSString *)projectType
{
    ProjectResource *projectResource = [[ProjectResource alloc] init];
    projectResource.projectType = [NSString stringWithFormat:@"%@", projectType];
    self.workingProject = projectResource;
    [self goWorkRoot];
    
}
- (void)homeViewControllerDidLoadProject:(Project *)project
{
    ProjectResource *projectResource = [[ProjectResource alloc] init];
    projectResource.project = project;
    projectResource.templateDictionary          = project.templateDictionary;
    projectResource.templateTextDictionary      = project.templateTextDictionary;
    projectResource.projectDictionary           = project.projectDictionary;
    [projectResource setupPhotoAssetsWithPhotoAssetDictionaryArray:project.photoAssetDictionaryArray];
    
    self.workingProject = projectResource;
    [self goWorkRoot];
}

- (void)homeViewControllerDidAbout
{
    [self goAbout];
}

- (void)homeViewControllerDidShareActivityWithImage:(UIImage *)image completion:(void(^)(void))callback
{
    
    DMActivityInstagram *instagramActivity = [[DMActivityInstagram alloc] init];
    instagramActivity.targetView = self.view;
    
    
    
    NSArray *activityItems = @[image];
    NSArray *applicationActivities = @[instagramActivity];
    NSArray *excludeActivities = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
    activityController.excludedActivityTypes = excludeActivities;
    
    activityController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        // When completed flag is YES, user performed specific activity
        if(callback) {
            callback();
        }
    };
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityController animated:YES completion:nil];
    } else {
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityController];
        [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }

    
    /*
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyMMdd_A"];
    NSDate *date = [NSDate date];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    
    
    NSData *imageData = UIImagePNGRepresentation(image);
    
    NSString *imageFullname = [NSString stringWithFormat:@"PAGEUP_%@.igo", formattedDateString];
    NSString *imagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:imageFullname];
    NSURL *imageURL = [NSURL fileURLWithPath:imagePath];
    if (![imageData writeToFile:imagePath atomically:YES]) {
        NSLog(@"Failed to preview image data to disk");
    } else {
        NSLog(@"preview image URL %@", imageURL);
    }
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        
        self.instagramDocumentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:imageURL];
        self.instagramDocumentInteractionController.UTI = @"com.instagram.exclusivegram";
        self.instagramDocumentInteractionController.delegate = self;
        [self.instagramDocumentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
        
    } else {
        UIAlertView *errorToShare = [[UIAlertView alloc] initWithTitle:@"Instagram unavailable " message:@"You need to install Instagram in your device in order to share this image" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        errorToShare.tag=3010;
        [errorToShare show];
    }
    */
    
    /*
    NSMutableArray *sharingItems = [NSMutableArray new];
    [sharingItems addObject:imagePath];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    
    activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact];
    activityController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        // When completed flag is YES, user performed specific activity
        if(callback) {
            callback();
        }
    };
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityController animated:YES completion:nil];
    } else {
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityController];
        [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
     */
}
- (void)homeViewControllerDidShareActivityWithPDF:(NSURL *)PDFURL completion:(void (^)(void))callback
{
    NSMutableArray *sharingItems = [NSMutableArray new];
    [sharingItems addObject:PDFURL];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact];
    activityController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        // When completed flag is YES, user performed specific activity
        if(callback) {
            callback();
        }
    };
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityController animated:YES completion:nil];
    } else {
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityController];
        [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}
- (void)homeViewControllerDidShareActivityWithVideoURL:(NSURL *)videoURL completion:(void(^)(void))callback
{
    
    NSMutableArray *sharingItems = [NSMutableArray new];
    [sharingItems addObject:videoURL];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact];
    activityController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        // When completed flag is YES, user performed specific activity
        if(callback) {
            callback();
        }
    };
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityController animated:YES completion:nil];
    } else {
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityController];
        [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}



#pragma mark - WorkRootViewControllerDelegate

- (void)workRootViewControllerNeedPhotosTooltip
{
    [self showPhotosTooltip];
}
- (void)workRootViewControllerNeedLayoutsTooltip
{
    [self showLayoutTooltip];
}
- (void)workRootViewControllerNeedEditTooltip
{
    [self showEditTooltip];
}
- (void)workRootViewControllerNeedTemplateEditTooltip
{
    [self showTemplateEditTooltip];
}

- (void)workRootViewControllerDidBack
{
    [self goHome];
}

- (void)workRootViewControllerDidShareActivityWithImage:(UIImage *)image completion:(void(^)(void))callback
{
    DMActivityInstagram *instagramActivity = [[DMActivityInstagram alloc] init];
    instagramActivity.targetView = self.view;
    
    
    
    NSArray *activityItems = @[image];
    NSArray *applicationActivities = @[instagramActivity];
    NSArray *excludeActivities = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
    activityController.excludedActivityTypes = excludeActivities;
    
    activityController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        // When completed flag is YES, user performed specific activity
        if(callback) {
            callback();
        }
    };
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityController animated:YES completion:nil];
    } else {
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityController];
        [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }

}
- (void)workRootViewControllerDidShareActivityWithPDFURL:(NSURL *)PDFURL completion:(void(^)(void))callback
{
    NSMutableArray *sharingItems = [NSMutableArray new];
    [sharingItems addObject:PDFURL];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    
    activityController.modalPresentationStyle = UIModalPresentationPageSheet;
    activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact];
    activityController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        // When completed flag is YES, user performed specific activity
        if(callback) {
            callback();
        }
    };
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityController animated:YES completion:nil];
    } else {
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityController];
        [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
}
- (void)workRootViewControllerDidShareActivityWithVideoURL:(NSURL *)videoURL completion:(void(^)(void))callback
{
    NSMutableArray *sharingItems = [NSMutableArray new];
    [sharingItems addObject:videoURL];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    
    activityController.modalPresentationStyle = UIModalPresentationPageSheet;
    activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact];
    activityController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        // When completed flag is YES, user performed specific activity
        if(callback) {
            callback();
        }
    };
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityController animated:YES completion:nil];
    } else {
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityController];
        [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
}


#pragma mark - TooltipViewControllerDelegate

- (void)tooltipViewControllerDidClose
{
    if(self.tooltipViewController) {
        [self.tooltipViewController.view removeFromSuperview];
        self.tooltipViewController = nil;
    }
}

@end
