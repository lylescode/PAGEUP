//
//  AboutViewController.m
//  Page
//
//  Created by CMR on 7/13/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "AboutViewController.h"
#import "DeviceUtils.h"


@interface AboutViewController ()
{
    CGSize viewSize;
}
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIScrollView *contentsScrollView;
@property (strong, nonatomic) IBOutlet UIView *contentsView;

@property (weak, nonatomic) IBOutlet UIView *videoPreviewView;
@property (weak, nonatomic) IBOutlet UIButton *videoCloseButton;
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLabel;

@property (weak, nonatomic) IBOutlet AboutTopView *topView;
@property (weak, nonatomic) IBOutlet AboutTutorialSectionView *tutorialSectionView;
@property (weak, nonatomic) IBOutlet AboutTooltipView *tooltipView1;
@property (weak, nonatomic) IBOutlet AboutTooltipView *tooltipView2;
@property (weak, nonatomic) IBOutlet AboutTooltipView *tooltipView3;
@property (weak, nonatomic) IBOutlet AboutTooltipView *tooltipView4;
@property (weak, nonatomic) IBOutlet AboutFooterMenuView *footerMenuView;
@property (strong, nonatomic) UIView *footerBackgroundView;

- (void)orientationChanged:(NSNotification *)notification;
- (IBAction)backButtonAction:(id)sender;
- (IBAction)videoCloseButtonAction:(id)sender;
- (void)playTutorialVideoWithFilename:(NSString *)filename;
- (void)stopTutorialVideo;
@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    viewSize = self.view.frame.size;
    
    self.contentsScrollView.delegate = self;
    
    self.contentsView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.contentsView.frame.size.height);
    NSLog(@"self.contentsView.bounds : %@", NSStringFromCGRect(self.contentsView.bounds));;
    [self.contentsScrollView addSubview:self.contentsView];
    self.contentsScrollView.contentSize = CGSizeMake(self.contentsView.frame.size.width, self.contentsView.frame.size.height);
    
    self.tooltipView1.tooltipViewDelegate = self;
    self.tooltipView2.tooltipViewDelegate = self;
    self.tooltipView3.tooltipViewDelegate = self;
    self.tooltipView4.tooltipViewDelegate = self;
    self.footerMenuView.footerMenuDelegate = self;
    
    self.topView.aboutLabel.text = NSLocalizedString(@"ABOUT", nil);
    self.topView.descriptionLabel.text = NSLocalizedString(@"About Description", nil);
    
    self.tutorialSectionView.tutorialLabel.text = NSLocalizedString(@"TUTORIAL TIPS", nil);
    
    self.tooltipView1.titleLabel.text = NSLocalizedString(@"Gallery", nil);
    self.tooltipView2.titleLabel.text = NSLocalizedString(@"Select Photos", nil);
    self.tooltipView3.titleLabel.text = NSLocalizedString(@"Select Layout", nil);
    self.tooltipView4.titleLabel.text = NSLocalizedString(@"Edit Page", nil);
    
    self.tooltipView1.descriptionLabel.text = NSLocalizedString(@"Gallery Description", nil);
    self.tooltipView2.descriptionLabel.text = NSLocalizedString(@"Select Photos Description", nil);
    self.tooltipView3.descriptionLabel.text = NSLocalizedString(@"Select Layout Description", nil);
    self.tooltipView4.descriptionLabel.text = NSLocalizedString(@"Edit Page Description", nil);
    
    self.tooltipView1.tutorialImageView.image = [UIImage imageNamed:@"AboutTooltipGallery"];
    self.tooltipView2.tutorialImageView.image = [UIImage imageNamed:@"AboutTooltipSelectPhotos"];
    self.tooltipView3.tutorialImageView.image = [UIImage imageNamed:@"AboutTooltipSelectTemplate"];
    self.tooltipView4.tutorialImageView.image = [UIImage imageNamed:@"AboutTooltipEditPage"];
    
    self.tooltipView1.watchVideoLabel.text = NSLocalizedString(@"WATCH THE VIDEO", nil);
    self.tooltipView2.watchVideoLabel.text = NSLocalizedString(@"WATCH THE VIDEO", nil);
    self.tooltipView3.watchVideoLabel.text = NSLocalizedString(@"WATCH THE VIDEO", nil);
    self.tooltipView4.watchVideoLabel.text = NSLocalizedString(@"WATCH THE VIDEO", nil);
    
    self.footerMenuView.rateLabel.text = NSLocalizedString(@"RATE PAGE UP", nil);
    self.footerMenuView.recommendLabel.text = NSLocalizedString(@"RECOMMEND PAGE UP", nil);
    self.footerMenuView.feedbackLabel.text = NSLocalizedString(@"FEEDBACK", nil);
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    self.footerMenuView.footerLabel.text = [NSString stringWithFormat:@"PAGE UP %@ (Build %@)", version, build];
    
    [self.topView setupAboutContents];
    [self.tutorialSectionView setupAboutContents];
    [self.tooltipView1 setupAboutContents];
    [self.tooltipView2 setupAboutContents];
    [self.tooltipView3 setupAboutContents];
    [self.tooltipView4 setupAboutContents];
    [self.footerMenuView setupAboutContents];
}


- (void)orientationChanged:(NSNotification *)notification
{
    
    if(CGSizeEqualToSize(self.view.frame.size, viewSize) == NO) {
        
        viewSize = self.view.frame.size;
        self.contentsView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.contentsView.frame.size.height);
        self.contentsScrollView.contentSize = CGSizeMake(self.contentsView.frame.size.width, self.contentsView.frame.size.height);
        
        if(self.videoPlayerView) {
            self.videoPlayerView.frame = self.view.bounds;
            [self.videoPlayerView updateFrame];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.contentsView removeFromSuperview];
}

- (IBAction)backButtonAction:(id)sender
{
    [self.aboutDelegate aboutViewControllerDidClose];
}

- (IBAction)videoCloseButtonAction:(id)sender {
    [self stopTutorialVideo];
}

- (void)playTutorialVideoWithFilename:(NSString *)filename
{
    if(!self.videoPlayerView) {
        VideoPlayerView *vpView = [[VideoPlayerView alloc] initWithFrame:self.view.bounds];
        vpView.videoPlayerDelegate = self;
        vpView.userInteractionEnabled = NO;
        [self.view addSubview:vpView];
        self.videoPlayerView = vpView;
        
        [self.videoPlayerView playVideoWithVideoFilename:filename];
        
        self.videoPreviewView.hidden = NO;
        self.videoPreviewView.alpha = 0;
        
        CGFloat animationDelay = 0;
        CGFloat duration = 0.55;
        CGFloat damping = 0.9;
        CGFloat velocity = 1;
        
        [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.videoPreviewView.alpha = 1;
                         }
                         completion:^(BOOL finished){
                             if(finished) {
                                 [self.videoPlayerView playVideo];
                             }
                         }];
    }
}

- (void)stopTutorialVideo
{
    if(self.videoPlayerView) {
        
        [self.videoPlayerView pauseVideo];
        
        CGFloat animationDelay = 0;
        CGFloat duration = 0.55;
        CGFloat damping = 1;
        CGFloat velocity = 0;
        [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.videoPlayerView.alpha = 0;
                             self.videoPlayerView.transform = CGAffineTransformMakeScale(0.96, 0.96);
                             self.videoPreviewView.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             if(finished) {
                                 [self.videoPlayerView stopVideo];
                             }
                         }];
    }
}

#pragma mark - VideoPlayerViewDelegate;
- (void)videoPlayerViewDidPlay
{
    
}
- (void)videoPlayerViewDidStop
{
    if(self.videoPlayerView) {
        [self.videoPlayerView removeFromSuperview];
        self.videoPlayerView = nil;
    }
}

#pragma mark - AboutTooltipViewDelegate
- (void)aboutTooltipViewDidVideoAction:(id)sender
{
    if(sender == self.tooltipView1) {
        [self playTutorialVideoWithFilename:@"Gallery_EX.m4v"];
        self.videoTitleLabel.text = NSLocalizedString(@"Gallery", nil);
    }
    else if(sender == self.tooltipView2) {
        [self playTutorialVideoWithFilename:@"Photos_EX.m4v"];
        self.videoTitleLabel.text = NSLocalizedString(@"Select Photos", nil);
    }
    else if(sender == self.tooltipView3) {
        [self playTutorialVideoWithFilename:@"Template_EX.m4v"];
        self.videoTitleLabel.text = NSLocalizedString(@"Select Layout", nil);
    }
    else if(sender == self.tooltipView4) {
        [self playTutorialVideoWithFilename:@"Edit_EX.m4v"];
        self.videoTitleLabel.text = NSLocalizedString(@"Edit Page", nil);
    }
}

#pragma mark - AboutFooterMenuViewDelegate

- (void)aboutFooterMenuViewDidRateAction
{
    NSString *appId = @"1027703909";
    //NSString *appUrl = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appId];
    NSString *appRateUrl = [NSString  stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software",appId];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appRateUrl]];
    
}

- (void)aboutFooterMenuViewDidRecommendAction
{
    NSString *appId = @"1027703909";
    NSString *appUrl = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@",appId];
    
    NSMutableArray *sharingItems = [NSMutableArray new];
    [sharingItems addObject:appUrl];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    
    activityController.modalPresentationStyle = UIModalPresentationPageSheet;
    activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact];
    activityController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
    };
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityController animated:YES completion:nil];
    } else {
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityController];
        [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
}
- (void)aboutFooterMenuViewDidFeedbackAction
{
    if ([MFMailComposeViewController canSendMail]) {
    
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *displayName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];
        
        NSString *iosVersion = [NSString stringWithFormat:@"iOS %@", [[NSProcessInfo processInfo] operatingSystemVersionString]];
        NSString *deviceVersion = [NSString stringWithFormat:@"Device Version : %@", [DeviceUtils platformString]];
        NSString *appVersion = [NSString stringWithFormat:@"App Version : %@ (Build %@)", version, build];
        NSString *appName = [NSString stringWithFormat:@"App Name : %@", displayName];
        
        
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        mailer.mailComposeDelegate = self;
        mailer.modalPresentationStyle = UIModalPresentationPageSheet;
        
        [mailer setSubject:@"About PAGE UP"];
        
        NSArray *toRecipients = [NSArray arrayWithObjects:@"hello@rawsmith.co", nil];
        [mailer setToRecipients:toRecipients];
        
        NSString *emailBody = [NSString stringWithFormat:@"\n\n\n%@ \n%@ \n%@ \n%@", iosVersion, deviceVersion, appVersion, appName];
        
        [mailer setMessageBody:emailBody isHTML:NO];
        
        [self presentViewController:mailer animated:YES completion:^{}];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your device doesn't support to send an email."
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}
- (void)aboutFooterMenuViewDidFacebookAction
{
    
    NSURL *facebookWebURL = [NSURL URLWithString:@"http://www.facebook.com/815908871858089"];
    [[UIApplication sharedApplication] openURL:facebookWebURL];
    /*
    NSURL *facebookUrl = [NSURL URLWithString:@"fb://page/815908871858089"];
    
    if ([[UIApplication sharedApplication] canOpenURL:facebookUrl]){
        [[UIApplication sharedApplication] openURL:facebookUrl];
    }
    else {
        NSURL *facebookWebURL = [NSURL URLWithString:@"https://www.facebook.com/pageup"];
        [[UIApplication sharedApplication] openURL:facebookWebURL];
    }*/
}
- (void)aboutFooterMenuViewDidInstagramAction
{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://user?username=pageup.cc"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    } else {
        NSURL *instagramWebURL = [NSURL URLWithString:@"http://instagram.com/pageup.cc"];
        [[UIApplication sharedApplication] openURL:instagramWebURL];
    }
}
- (void)aboutFooterMenuViewDidEmailAction
{
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        mailer.mailComposeDelegate = self;
        mailer.modalPresentationStyle = UIModalPresentationPageSheet;
        
        NSArray *toRecipients = [NSArray arrayWithObjects:@"hello@rawsmith.co", nil];
        [mailer setToRecipients:toRecipients];
        
        [self presentViewController:mailer animated:YES completion:^{}];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your device doesn't support to send an email."
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}



#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.y < 0) {
        CGFloat translationY = -300;
        translationY -= (scrollView.contentOffset.y / 3);
        
        self.backgroundView.transform = CGAffineTransformMakeTranslation(0, translationY);
    }
}

@end
