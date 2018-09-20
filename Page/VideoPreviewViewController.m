//
//  VideoPreviewViewController.m
//  Page
//
//  Created by CMR on 5/14/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "VideoPreviewViewController.h"
#import "DeviceUtils.h"
#import "UIImage+Resize.h"

@interface VideoPreviewViewController ()
{
    UITapGestureRecognizer *tapGesture;
    CGSize viewSize;
}
@property (weak, nonatomic) IBOutlet UIView *dimmedView;
@property (weak, nonatomic) IBOutlet UIView *previewAreaView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet UIView *progressBar;

- (IBAction)playButtonAction:(id)sender;

@property (strong, nonatomic) PTemplate *previewTemplate;
@property (strong, nonatomic) CALayer *previewTemplateLayer;
@property (strong, nonatomic) NSTimer *previewLoopTimer;

@property (strong, nonatomic) PTemplate *resultTemplate;
@property (strong, nonatomic) NSString *finishVideoFilePath;
@property (strong, nonatomic) NSURL *finishVideoURL;

@property (strong, nonatomic) NSTimer *exportProgressTimer;
@property (nonatomic, retain) AVAssetExportSession *session;
@property (nonatomic, readwrite, retain) AVComposition *composition;
@property (nonatomic, readwrite, retain) AVVideoComposition *videoComposition;
@property (nonatomic, readwrite, retain) AVPlayerItem *playerItem;
@property (nonatomic, readwrite, retain) AVSynchronizedLayer *synchronizedLayer;

- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer;
- (void)preparePreview;
- (void)playPreview;
- (void)prepareEncoding;

- (void)buildComposition;
- (void)startEncoding;
- (void)startProgress;
- (void)completeProgress;
- (void)updateProgress;
- (void)exportDidFinish:(AVAssetExportSession *)aSession;


- (void)playPreviewAnimationLayer;
- (CALayer *)buildSynchronizedLayerWithVideoSize:(CGSize)videoSize;

@end

@implementation VideoPreviewViewController

@synthesize composition = _composition;
@synthesize videoComposition =_videoComposition;
@synthesize playerItem = _playerItem;


static CGSize VideoSize;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
    
    self.previewAreaView.clipsToBounds = YES;
    self.previewAreaView.backgroundColor = [UIColor clearColor];
    
    self.playButton.alpha = 0;
    
    self.progressView.alpha = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    MARK;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.projectResource = nil;
    if(self.previewLoopTimer) {
        [self.previewLoopTimer invalidate];
        self.previewLoopTimer = nil;
    }
    if(self.previewTemplate) {
        [self.previewTemplate removeFromSuperview];
        self.previewTemplate = nil;
    }
    if(self.previewTemplateLayer) {
        [self.previewTemplateLayer removeFromSuperlayer];
        self.previewTemplateLayer = nil;
    }
    
    if(self.resultTemplate) {
        [self.resultTemplate removeFromSuperview];
        self.resultTemplate = nil;
    }
    if(self.exportProgressTimer) {
        [self.exportProgressTimer invalidate];
        self.exportProgressTimer = nil;
    }
    if(self.session) {
        [self.session cancelExport];
        self.session = nil;
    }
    self.composition = nil;
    self.videoComposition = nil;
    self.playerItem = nil;
    self.synchronizedLayer = nil;
    
    self.finishVideoFilePath = nil;
    self.finishVideoURL = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    viewSize = self.view.frame.size;
}

- (void)orientationChanged:(NSNotification *)notification
{
    if(CGSizeEqualToSize(self.view.frame.size, viewSize) == NO) {
        viewSize = self.view.frame.size;
        
        [self playPreview];
    }
}


- (void)presentViewControllerAnimated:(BOOL)animated completion:(void(^)(void))callback
{
    [presentDelegate presentWillFinish:self];
    self.view.hidden = NO;
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    if(animated) {
        
        CGFloat animationDelay = 0;
        CGFloat duration = animationDuration;
        CGFloat damping = 1;
        CGFloat velocity = 1;
        
        self.dimmedView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                         animations:^{
                             self.dimmedView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.95];
                         }
                         completion:^(BOOL finished){
                             
                             if(callback != nil) {
                                 callback();
                             }
                            
                             [self playPreview];
                             if(!TARGET_IPHONE_SIMULATOR) {
                                 [self startEncoding];
                             }
                             [presentDelegate presentDidFinish:self];
                         }];
        
        animationDelay += 0.35;
        //self.playButton.alpha = 0;
        //self.previewAreaView.transform = CGAffineTransformMakeScale(1, 0.01);
        //self.previewAreaView.backgroundColor = [UIColor colorWithRed:0.235 green:0.482 blue:0.992 alpha:1];
        [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                         animations:^{
                             //self.previewAreaView.transform = CGAffineTransformIdentity;
                             //self.previewAreaView.backgroundColor = [UIColor clearColor];
                             //self.playButton.alpha = 1;
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
    
    // 타이머가 살아있으면 dealloc 이 안됨
    if(self.previewLoopTimer) {
        [self.previewLoopTimer invalidate];
        self.previewLoopTimer = nil;
    }
    if(self.session) {
        [self.session cancelExport];
        self.session = nil;
    }
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    if(animated) {
        
        CGFloat animationDelay = 0;
        CGFloat duration = 0.55;
        CGFloat damping = 1;
        CGFloat velocity = 0;
        
        [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                         animations:^{
                             //self.previewAreaView.transform = CGAffineTransformMakeTranslation(0, -(self.previewAreaView.frame.origin.y + self.previewAreaView.frame.size.height));
                             self.previewAreaView.alpha = 0;
                             self.playButton.alpha = 0;
                         }
                         completion:^(BOOL finished){
                         }];
        
        [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                         animations:^{
                             self.dimmedView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
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

- (IBAction)playButtonAction:(id)sender {
    [self playPreview];
}

- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded)
    {
        if(self.session) {
            [self.session cancelExport];
        }
        [self.videoPreviewDelegate videoPreviewViewControllerDidClose];
    }
}

- (void)preparePreview
{
    if(self.previewTemplate) {
        [self.previewTemplate removeFromSuperview];
        self.previewTemplate = nil;
    }
    
    CGSize previewSize = self.previewAreaView.frame.size;
    
    PTemplate *templateView = [[PTemplate alloc] initWithFrame:CGRectMake(0, 0, previewSize.width, previewSize.height) templateDictionary:self.projectResource.templateDictionary];
    [templateView setupTemplate];
    templateView.userInteractionEnabled = NO;
    [templateView setPhotosWithPhotoArray:self.projectResource.photoArray];
    [templateView setupProjectDictionary:self.projectResource.projectDictionary];
    
    templateView.center = CGPointMake(self.previewAreaView.frame.size.width / 2, self.previewAreaView.frame.size.height / 2);
    [self.previewAreaView addSubview:templateView];
    self.previewTemplate = templateView;
    self.previewTemplate.hidden = YES;
    
    self.previewAreaView.backgroundColor = [UIColor clearColor];
}

- (void)playPreview
{
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.playButton.alpha = 0;
                     }
                     completion:^(BOOL finished){
                     }];
    
    if(self.previewLoopTimer) {
        [self.previewLoopTimer invalidate];
        self.previewLoopTimer = nil;
    }
    self.previewLoopTimer = [NSTimer scheduledTimerWithTimeInterval:15.0f
                                                  target:self
                                                selector:@selector(playPreview)
                                                userInfo:nil repeats:NO];
    
    [self preparePreview];
    //[self playPreviewAnimationLayer];
    //[self playPreviewAnimationLayer2];
    [self playPreviewAnimationLayer3];
}

- (void)prepareEncoding
{
    
    if(self.resultTemplate) {
        [self.resultTemplate removeFromSuperview];
        self.resultTemplate = nil;
    }
    
    NSString *templateRatio = [self.projectResource.templateDictionary objectForKey:@"Ratio"];
    
    CGSize previewSize = CGSizeMake(1080, 1080);
    
    if([templateRatio isEqualToString:@"Landscape"]) {
        previewSize = CGSizeMake(1920, 1080);
    } else if([templateRatio isEqualToString:@"Portrait"]) {
        previewSize = CGSizeMake(1080, 1920);
    } else {
        previewSize = CGSizeMake(1080, 1080);
    }
    
    PTemplate *templateView = [[PTemplate alloc] initWithFrame:CGRectMake(0, 0, previewSize.width, previewSize.height) templateDictionary:self.projectResource.templateDictionary];
    [templateView setupTemplate];
    templateView.userInteractionEnabled = NO;
    [templateView setPhotosWithPhotoArray:self.projectResource.photoArray];
    [templateView setupProjectDictionary:self.projectResource.projectDictionary];
    
    [self.previewAreaView addSubview:templateView];
    self.resultTemplate = templateView;
    self.resultTemplate.hidden = YES;
    
    VideoSize = CGSizeMake(ceil(self.resultTemplate.frame.size.width), ceil(self.resultTemplate.frame.size.height));
}


- (void)buildComposition
{
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    
    CMTimeRange *timeRanges                 = alloca(sizeof(CMTimeRange) * 1);
    UIInterfaceOrientation *orientations    = alloca(sizeof(UIInterfaceOrientation) * 1);
    
    
    NSURL *blankVideo = [[NSBundle mainBundle] URLForResource:@"blank" withExtension:@"mov"];
    AVURLAsset *blankAsset = [[AVURLAsset alloc] initWithURL:blankVideo options:nil];
    
    NSLog(@"blankVideo asset : %@", blankAsset);
    NSLog(@"duration : %f", CMTimeGetSeconds(blankAsset.duration));
    
    CMTime startTime = kCMTimeZero;
    CMTime duration = CMTimeMake(blankAsset.duration.timescale * 15, blankAsset.duration.timescale); //[asset duration];
    CMTimeRange timeRangeInAsset = CMTimeRangeMake(startTime, duration);
    
    AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [videoCompositionTrack insertTimeRange:timeRangeInAsset
                                   ofTrack:[[blankAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                                    atTime:kCMTimeZero error:nil];
    
    
    timeRanges[0] = CMTimeRangeMake(kCMTimeZero, timeRangeInAsset.duration);
    orientations[0] = [self orientationForTrack:videoCompositionTrack];
    
    NSMutableArray *instructions = [NSMutableArray array];
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = timeRanges[0];
    AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
    SLog(@"videoComposition videoSize", VideoSize);
    
    instruction.layerInstructions = [NSArray arrayWithObject:videoLayerInstruction];
    [instructions addObject:instruction];
    videoComposition.instructions = instructions;
    
    CALayer *animatedLayer = [self buildSynchronizedLayerWithVideoSize3:VideoSize];
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    
    parentLayer.frame   = CGRectMake(0, 0, VideoSize.width, VideoSize.height);
    videoLayer.frame    = parentLayer.frame;
    
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:animatedLayer];
    
    videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    if (videoComposition) {
        // TODO: 60프레임 지원하는 기기에서만 60프레임으로 가고 다른 기기에서는 30프레임으로 가기
        
        if([DeviceUtils support60fpsVideo]) {
            videoComposition.frameDuration = CMTimeMake(1, 60); // 60 fps
            NSLog(@"Video Frame rate : %f", 60.0);
        }
        else {
            videoComposition.frameDuration = CMTimeMake(1, 30); // 30 fps
            NSLog(@"Video Frame rate : %f", 30.0);
        }
        videoComposition.renderSize = VideoSize;
        videoComposition.renderScale = 1.;
    }
    
    self.composition = composition;
    self.videoComposition = videoComposition;
    
}

- (void)startEncoding
{
    [self startProgress];
    [self prepareEncoding];
    [self buildComposition];
    
    self.session = [AVAssetExportSession exportSessionWithAsset:self.composition presetName:AVAssetExportPresetHighestQuality];
    self.session.videoComposition = self.videoComposition;
    
    NSLog (@"created exporter. supportedFileTypes: %@", self.session.supportedFileTypes);
    
    NSString *videoFilename = [NSString stringWithFormat:@"%@.mov", @"PAGEUP_VIDEO"];
    self.finishVideoFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:videoFilename];
    NSLog(@"self.finishVideoFilename : %@", self.finishVideoFilePath);
    
    self.session.outputURL = [NSURL fileURLWithPath:self.finishVideoFilePath];
    self.session.outputFileType = AVFileTypeQuickTimeMovie;
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError *error = nil;
    BOOL isDir;
    if([fileManager fileExistsAtPath:self.finishVideoFilePath isDirectory:&isDir] == YES) {
        NSLog(@"이미 있음");
        BOOL removeSuccess = [fileManager removeItemAtPath:self.finishVideoFilePath error:&error];
        if(removeSuccess) {
            NSLog(@"기존 파일 삭제");
        }
    }
    
    
    [self.session exportAsynchronouslyWithCompletionHandler:^{
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        switch (self.session.status)
        {
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"Completed exporting!");
                [self exportDidFinish:self.session];
                break;
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Failed:%@", self.session.error.description);
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Canceled:%@", self.session.error);
                break;
            default:
                break;
        }
     }];
    
    
}

- (void)startProgress
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.exportProgressTimer) {
            [self.exportProgressTimer invalidate];
        }
        self.progressBar.transform = CGAffineTransformMakeTranslation(-(self.progressBar.frame.size.width * 1), 0);
        self.exportProgressTimer = [NSTimer scheduledTimerWithTimeInterval:.20 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
        [UIView animateWithDuration:0.45 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.progressView.alpha = 1;
                         }
                         completion:^(BOOL finished){
                             
                         }];
    });
}
- (void)completeProgress
{
    
    if(self.exportProgressTimer) {
        [self.exportProgressTimer invalidate];
    }
    [UIView animateWithDuration:0.45 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.progressView.alpha = 0;
                         self.progressBar.transform = CGAffineTransformMakeTranslation(0, 0);
                     }
                     completion:^(BOOL finished){
                         
                     }];
}



- (void)updateProgress
{
    CGFloat progress = self.session.progress;
    if (progress > .99) {
        [self.exportProgressTimer invalidate];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.progressBar.transform = CGAffineTransformMakeTranslation(-(self.progressBar.frame.size.width * (1-progress)), 0);
                         }
                         completion:^(BOOL finished){
                             
                         }];
    });
    //NSLog(@"progress %f", progress);
}



- (void)exportDidFinish:(AVAssetExportSession *)aSession
{
    MARK;
    
    dispatch_async(dispatch_get_main_queue(), ^{
    [self completeProgress];
    
    if (aSession.status == AVAssetExportSessionStatusCompleted) {
        NSLog(@"export complete");
        
        NSURL *outputURL = aSession.outputURL;
        self.finishVideoURL = outputURL;
        [self.videoPreviewDelegate videoPreviewViewControllerDidShareActivityWithVideoURL:outputURL];
        
    } else if (aSession.status == AVAssetExportSessionStatusFailed) {
        NSLog(@"export failed");
        NSLog(@"error:%@", aSession.error)
    }
    
        self.session = nil;
    });
}






- (UIInterfaceOrientation)orientationForTrack:(AVAssetTrack *)videoTrack
{
    
    CGSize size = [videoTrack naturalSize];
    //NSLog(@"orientationForTrack videoTrack naturalSize : %@", NSStringFromCGSize(size));
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    if (size.width == txf.tx && size.height == txf.ty) {
        return UIInterfaceOrientationLandscapeRight;
    } else if (txf.tx == 0 && txf.ty == 0) {
        return UIInterfaceOrientationLandscapeLeft;
    } else if (txf.tx == 0 && txf.ty == size.width) {
        return UIInterfaceOrientationPortraitUpsideDown;
    } else {
        return UIInterfaceOrientationPortrait;
    }
}

- (void)playPreviewAnimationLayer
{
    if(self.previewTemplateLayer) {
        [self.previewTemplateLayer removeFromSuperlayer];
        self.previewTemplateLayer = nil;
    }
    CALayer *synchronizedLayer = [CALayer layer];
    //synchronizedLayer.backgroundColor = [[UIColor colorWithRed:1 green:0 blue:0 alpha:0.3] CGColor];
    //synchronizedLayer.drawsAsynchronously = YES;
    synchronizedLayer.edgeAntialiasingMask = YES;
    synchronizedLayer.masksToBounds = YES;
    synchronizedLayer.frame = self.previewTemplate.frame;
    synchronizedLayer.backgroundColor = [UIColor blackColor].CGColor;
    
    NSArray *targetViews = [self.previewTemplate.loadedNibView subviews];
    
    for(UIView *subview in targetViews) {
        [synchronizedLayer addSublayer:subview.layer];
    }
    
    UIView *backgroundView = (UIView *)[targetViews firstObject];
    UIColor *backgroundColor = backgroundView.backgroundColor;
    //CALayer *backgroundLayer = backgroundView.layer;
    
    CALayer *titleBackgroundLayer;
    CALayer *titleGroupLayer;
    UIColor *titleColor;
    
    NSMutableArray *photoViewLayers = [NSMutableArray array];
    NSMutableArray *flatViewLayers = [NSMutableArray array];
    NSMutableArray *otherViewLayers = [NSMutableArray array];
    
    NSSortDescriptor *tagDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tag" ascending:YES];
    targetViews = [targetViews sortedArrayUsingDescriptors:[NSArray arrayWithObject:tagDescriptor]];
    
    for(int i = 1 ; i < targetViews.count ; i++) {
        UIView *targetView = (UIView *)[targetViews objectAtIndex:i];
        
        if(targetView.hidden == NO) {
            if([targetView isKindOfClass:[PTextGroupView class]]) {
                PTextGroupView *textGroupView = (PTextGroupView *)targetView;
                for(id subItem in [textGroupView subviews]) {
                    if([subItem isKindOfClass:[PUILabel class]]) {
                        PUILabel *label = (PUILabel *)subItem;
                        if([label.textType isEqualToString:@"title"]) {
                            titleGroupLayer = textGroupView.layer;
                            titleColor = label.textColor;
                            break;
                        } else if([label.textType isEqualToString:@"subtitle"]) {
                            if(titleGroupLayer == nil) {
                                titleGroupLayer = textGroupView.layer;
                                titleColor = label.textColor;
                            }
                            break;
                        }
                    }
                }
                if(titleGroupLayer != textGroupView.layer) {
                    
                    [otherViewLayers addObject:textGroupView.layer];
                }
                
            } else if([targetView isKindOfClass:[PPhotoView class]]) {
                
                [photoViewLayers addObject:targetView.layer];
                
            } else if([targetView isKindOfClass:[PFlatView class]]) {
                
                [flatViewLayers addObject:targetView.layer];
                
            } else {
                [otherViewLayers addObject:targetView.layer];
            }
        }
    }
    
    CABasicAnimation *in_opacityAnimation;
    CABasicAnimation *out_opacityAnimation;
    CABasicAnimation *in_opacityAnimation2;
    CABasicAnimation *out_opacityAnimation2;
    CABasicAnimation *positionAnimation;
    CABasicAnimation *scaleAnimation;
    CABasicAnimation *transformAnimation;
    
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithControlPoints:.25 :.0 :.0 :1];
    timingFunction = [CAMediaTimingFunction functionWithControlPoints:.5 :.0 :.0 :1];
    
    CAMediaTimingFunction *photoFadeTimingFunction = [CAMediaTimingFunction functionWithControlPoints:.0 :.0 :.5 :1];
    
    CGFloat fullDuration = 15;
    
    CGFloat fadeDuration = 0.75;
    CGFloat titleDuration = (titleGroupLayer) ? 2 : 0;
    CGFloat photoDuration = 4.5;
    //CGFloat otherDuration = 5;
    
    CGFloat inDuration = 0.75;
    CGFloat outDuration = 0.75;
    
    CGFloat photoAnimationBeginTime = CACurrentMediaTime() + fadeDuration + titleDuration;
    CGFloat photoItemDuration = photoDuration / photoViewLayers.count;
    CGFloat photoFadeDuration = 1;
    
    CGFloat inBeginTime = 0;
    CGFloat outBeginTime = 0;
    
    CGFloat positionBeginTime = CACurrentMediaTime() + (fadeDuration + titleDuration + photoDuration);
    CGFloat positionDuration = 0.85;
    
    CALayer *targetLayer;
    CGFloat targetOpacity = 1;
    
    CGPoint targetPosition;
    CGPoint layerCenterPosition = CGPointMake(synchronizedLayer.frame.size.width / 2, synchronizedLayer.frame.size.height / 2);
    
    if(titleGroupLayer) {
        if(CGColorEqualToColor(titleColor.CGColor, backgroundColor.CGColor)) {
            
            CGFloat r,g,b,a;
            [titleColor getRed:&r green:&g blue:&b alpha:&a];
            UIColor *titleBackgroundColor = [UIColor colorWithRed:1.-r green:1.-g blue:1.-b alpha:1];
            
            titleBackgroundLayer = [CALayer layer];
            titleBackgroundLayer.frame = synchronizedLayer.bounds;
            titleBackgroundLayer.backgroundColor = titleBackgroundColor.CGColor;
            
            [synchronizedLayer insertSublayer:titleBackgroundLayer below:titleGroupLayer];
            
            out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            out_opacityAnimation.fromValue = [NSNumber numberWithFloat:1];
            out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
            out_opacityAnimation.beginTime = photoAnimationBeginTime;
            out_opacityAnimation.duration = fadeDuration;
            out_opacityAnimation.fillMode = kCAFillModeForwards;
            out_opacityAnimation.removedOnCompletion = NO;
            out_opacityAnimation.timingFunction = timingFunction;
            
            [titleBackgroundLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        }
        
        targetLayer = titleGroupLayer;
        targetOpacity = targetLayer.opacity;
        targetPosition = targetLayer.position;
        
        CATransform3D targetTransform = targetLayer.transform;
        
        CGFloat zoomScale = 1;
        CGSize titleMaxSize = CGSizeMake((synchronizedLayer.frame.size.width / 2), (synchronizedLayer.frame.size.height / 2));
        if(targetLayer.frame.size.width < titleMaxSize.width) {
            zoomScale = titleMaxSize.width / targetLayer.frame.size.width;
            if(targetLayer.frame.size.height * zoomScale > titleMaxSize.height) {
                zoomScale = titleMaxSize.height / targetLayer.frame.size.height;
            }
            targetLayer.transform = CATransform3DMakeScale(zoomScale, zoomScale, 1);
        }
        
        targetLayer.position = layerCenterPosition;
        
        targetLayer.opacity = 0;
        inBeginTime = CACurrentMediaTime();
        outBeginTime = CACurrentMediaTime() + (fullDuration - outDuration);
        
        in_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation.beginTime = inBeginTime;
        in_opacityAnimation.duration = inDuration;
        in_opacityAnimation.fillMode = kCAFillModeForwards;
        in_opacityAnimation.removedOnCompletion = NO;
        in_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation forKey:@"in_opacityAnimation"];
        
        scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:zoomScale * 1.5];
        scaleAnimation.toValue = [NSNumber numberWithFloat:zoomScale];
        scaleAnimation.beginTime = inBeginTime;
        scaleAnimation.duration = inDuration;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.removedOnCompletion = NO;
        scaleAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:scaleAnimation forKey:@"in_scaleAnimation"];
        
        out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation.beginTime = photoAnimationBeginTime - fadeDuration;
        out_opacityAnimation.duration = fadeDuration;
        out_opacityAnimation.fillMode = kCAFillModeForwards;
        out_opacityAnimation.removedOnCompletion = NO;
        out_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        
        transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:targetLayer.transform];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:targetTransform];
        transformAnimation.beginTime = positionBeginTime + positionDuration;
        transformAnimation.duration = 0.001;
        transformAnimation.fillMode = kCAFillModeForwards;
        transformAnimation.removedOnCompletion = NO;
        transformAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:transformAnimation forKey:@"transformAnimation"];
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:layerCenterPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:targetPosition];
        positionAnimation.beginTime = positionBeginTime + positionDuration;
        positionAnimation.duration = 0.001;
        positionAnimation.fillMode = kCAFillModeForwards;
        positionAnimation.removedOnCompletion = NO;
        positionAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:positionAnimation forKey:@"positionAnimation"];
        
        
        in_opacityAnimation2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation2.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation2.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation2.beginTime = positionBeginTime + positionDuration;
        in_opacityAnimation2.duration = fadeDuration;
        in_opacityAnimation2.fillMode = kCAFillModeForwards;
        in_opacityAnimation2.removedOnCompletion = NO;
        in_opacityAnimation2.timingFunction = timingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation2 forKey:@"in_opacityAnimation2"];
        
        out_opacityAnimation2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation2.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation2.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation2.beginTime = outBeginTime;
        out_opacityAnimation2.duration = fadeDuration;
        out_opacityAnimation2.fillMode = kCAFillModeForwards;
        out_opacityAnimation2.removedOnCompletion = NO;
        out_opacityAnimation2.timingFunction = timingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation2 forKey:@"out_opacityAnimation2"];
    }
    CGFloat zoomScale = 1;
    CGFloat photoPositionDelay = 0.06 * photoViewLayers.count;
    for(CALayer *sublayer in photoViewLayers) {
        
        targetLayer = sublayer;
        targetOpacity = targetLayer.opacity;
        targetPosition = targetLayer.position;
        
        targetLayer.position = layerCenterPosition;
        
        CGPoint targetInPosition = layerCenterPosition;
        if(targetLayer.cornerRadius != 0) {
            if(ceil(targetLayer.frame.size.width / 2) == ceil(targetLayer.cornerRadius)) {
                NSLog(@"targetLayer.frame : %@", NSStringFromCGRect(targetLayer.frame));
                
                CGFloat radians = radians(-135);
                CGPoint centerPoint = CGPointMake(targetLayer.frame.size.width / 2, targetLayer.frame.size.height / 2);
                
                CGFloat distance = targetLayer.frame.size.width / 2;
                
                CGPoint innerRectOrigin = CGPointMake(centerPoint.x + distance * cos(radians), centerPoint.y + distance * sin(radians));
                //NSLog(@"innerRectOrigin : %@", NSStringFromCGPoint(innerRectOrigin));
                
                radians = radians(45);
                CGSize innerRectSize = CGSizeMake((centerPoint.x + distance * cos(radians)) - innerRectOrigin.x, (centerPoint.y + distance * sin(radians)) - innerRectOrigin.y);
                
                //NSLog(@"innerRectSize : %@", NSStringFromCGSize(innerRectSize));
                
                CGRect innerRect = CGRectMake(innerRectOrigin.x, innerRectOrigin.y, innerRectSize.width, innerRectSize.height);
                
                NSLog(@"innerRect : %@", NSStringFromCGRect(innerRect));
                
                
                zoomScale = synchronizedLayer.frame.size.width / innerRect.size.width;
                if(innerRect.size.height * zoomScale < synchronizedLayer.frame.size.height) {
                    zoomScale = synchronizedLayer.frame.size.height / innerRect.size.height;
                }
                
            } else {
                zoomScale = synchronizedLayer.frame.size.width / targetLayer.frame.size.width;
                if(targetLayer.frame.size.height * zoomScale < synchronizedLayer.frame.size.height) {
                    zoomScale = synchronizedLayer.frame.size.height / targetLayer.frame.size.height;
                }
            }
        } else {
            
            
            zoomScale = synchronizedLayer.frame.size.width / targetLayer.frame.size.width;
            if(targetLayer.frame.size.height * zoomScale < synchronizedLayer.frame.size.height) {
                zoomScale = synchronizedLayer.frame.size.height / targetLayer.frame.size.height;
            }
            
            NSInteger marginWidth = round((targetLayer.frame.size.width * zoomScale) - synchronizedLayer.frame.size.width);
            NSInteger marginHeight = round((targetLayer.frame.size.height * zoomScale) - synchronizedLayer.frame.size.height);
            
            if(marginWidth > 0) {
                CGFloat randomX = (CGFloat)(arc4random() % marginWidth) - (marginWidth / 2);
                targetInPosition.x += randomX;
            }
            
            if(marginHeight > 0) {
                CGFloat randomY = (CGFloat)(arc4random() % marginHeight) - (marginHeight / 2);
                targetInPosition.y += randomY;
            }
        }
        
        
        targetLayer.transform = CATransform3DMakeScale(zoomScale, zoomScale, 1);
        targetLayer.opacity = 0;
        
        inBeginTime = photoAnimationBeginTime;
        outBeginTime = CACurrentMediaTime() + (fullDuration - outDuration);
        
        in_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation.beginTime = inBeginTime;
        in_opacityAnimation.duration = photoFadeDuration;
        in_opacityAnimation.fillMode = kCAFillModeForwards;
        in_opacityAnimation.removedOnCompletion = NO;
        in_opacityAnimation.timingFunction = photoFadeTimingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation forKey:@"in_opacityAnimation"];
        
        scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:zoomScale * 1.25];
        scaleAnimation.toValue = [NSNumber numberWithFloat:zoomScale];
        scaleAnimation.beginTime = inBeginTime;
        scaleAnimation.duration = (positionBeginTime + photoPositionDelay) - inBeginTime;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.removedOnCompletion = NO;
        scaleAnimation.timingFunction = photoFadeTimingFunction;
        
        [targetLayer addAnimation:scaleAnimation forKey:@"in_scaleAnimation"];
        
        if(CGPointEqualToPoint(targetInPosition, layerCenterPosition) == NO) {
            positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
            positionAnimation.fromValue = [NSValue valueWithCGPoint:targetInPosition];
            positionAnimation.toValue = [NSValue valueWithCGPoint:layerCenterPosition];
            positionAnimation.beginTime = inBeginTime;
            positionAnimation.duration = (positionBeginTime + photoPositionDelay) - inBeginTime;
            positionAnimation.fillMode = kCAFillModeForwards;
            positionAnimation.removedOnCompletion = NO;
            positionAnimation.timingFunction = photoFadeTimingFunction;
            
            [targetLayer addAnimation:positionAnimation forKey:@"in_positionAnimation"];
        }
        
        out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation.beginTime = outBeginTime;
        out_opacityAnimation.duration = fadeDuration;
        out_opacityAnimation.fillMode = kCAFillModeForwards;
        out_opacityAnimation.removedOnCompletion = NO;
        out_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        
        scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:zoomScale];
        scaleAnimation.toValue = [NSNumber numberWithFloat:1];
        scaleAnimation.beginTime = positionBeginTime + photoPositionDelay;
        scaleAnimation.duration = positionDuration;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.removedOnCompletion = NO;
        scaleAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:layerCenterPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:targetPosition];
        positionAnimation.beginTime = positionBeginTime + photoPositionDelay;
        positionAnimation.duration = positionDuration;
        positionAnimation.fillMode = kCAFillModeForwards;
        positionAnimation.removedOnCompletion = NO;
        positionAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:positionAnimation forKey:@"positionAnimation"];
        
        
        photoAnimationBeginTime += photoItemDuration;
        photoPositionDelay -= 0.06;
    }
    
    
    CGFloat flatAnimationBeginTime = positionBeginTime + positionDuration;
    for(CALayer *sublayer in flatViewLayers) {
        
        targetLayer = sublayer;
        targetOpacity = targetLayer.opacity;
        
        targetLayer.opacity = 0;
        
        inBeginTime = flatAnimationBeginTime;
        outBeginTime = CACurrentMediaTime() + (fullDuration - outDuration);
        
        inDuration = fadeDuration;
        outDuration = fadeDuration;
        
        in_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation.beginTime = inBeginTime;
        in_opacityAnimation.duration = inDuration;
        in_opacityAnimation.fillMode = kCAFillModeForwards;
        in_opacityAnimation.removedOnCompletion = NO;
        in_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation forKey:@"in_opacityAnimation"];
        
        out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation.beginTime = outBeginTime;
        out_opacityAnimation.duration = outDuration;
        out_opacityAnimation.fillMode = kCAFillModeForwards;
        out_opacityAnimation.removedOnCompletion = NO;
        out_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        flatAnimationBeginTime += 0.2;
    }
    
    CGFloat otherAnimationBeginTime = positionBeginTime + positionDuration;
    for(CALayer *sublayer in otherViewLayers) {
        targetLayer = sublayer;
        targetOpacity = targetLayer.opacity;
        
        targetLayer.opacity = 0;
        
        inBeginTime = otherAnimationBeginTime;
        outBeginTime = CACurrentMediaTime() + (fullDuration - outDuration);
        
        inDuration = fadeDuration;
        outDuration = fadeDuration;
        
        in_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation.beginTime = inBeginTime;
        in_opacityAnimation.duration = inDuration;
        in_opacityAnimation.fillMode = kCAFillModeForwards;
        in_opacityAnimation.removedOnCompletion = NO;
        in_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation forKey:@"in_opacityAnimation"];
        
        out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation.beginTime = outBeginTime;
        out_opacityAnimation.duration = outDuration;
        out_opacityAnimation.fillMode = kCAFillModeForwards;
        out_opacityAnimation.removedOnCompletion = NO;
        out_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        otherAnimationBeginTime += 0.2;
    }
    
    self.previewTemplateLayer = synchronizedLayer;
    [self.previewAreaView.layer addSublayer:synchronizedLayer];
    
    
    
    
}

- (void)playPreviewAnimationLayer2
{
    BOOL isFirst = YES;
    if(self.previewTemplateLayer) {
        [self.previewTemplateLayer removeFromSuperlayer];
        self.previewTemplateLayer = nil;
        
        isFirst = NO;
    }
    CALayer *synchronizedLayer = [CALayer layer];
    //synchronizedLayer.backgroundColor = [[UIColor colorWithRed:1 green:0 blue:0 alpha:0.3] CGColor];
    //synchronizedLayer.drawsAsynchronously = YES;
    synchronizedLayer.edgeAntialiasingMask = YES;
    synchronizedLayer.masksToBounds = YES;
    synchronizedLayer.frame = self.previewTemplate.frame;
    synchronizedLayer.backgroundColor = [UIColor blackColor].CGColor;
    
    NSArray *targetViews = [self.previewTemplate.loadedNibView subviews];
    
    for(UIView *subview in targetViews) {
        [synchronizedLayer addSublayer:subview.layer];
    }
    
    //CALayer *backgroundLayer = backgroundView.layer;
    
    CALayer *titleGroupLayer;
    UIColor *titleColor;
    
    NSMutableArray *photoViewLayers = [NSMutableArray array];
    NSMutableArray *flatViewLayers = [NSMutableArray array];
    NSMutableArray *otherViewLayers = [NSMutableArray array];
    
    NSSortDescriptor *tagDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tag" ascending:YES];
    targetViews = [targetViews sortedArrayUsingDescriptors:[NSArray arrayWithObject:tagDescriptor]];
    
    for(int i = 1 ; i < targetViews.count ; i++) {
        UIView *targetView = (UIView *)[targetViews objectAtIndex:i];
        
        if(targetView.hidden == NO) {
            if([targetView isKindOfClass:[PTextGroupView class]]) {
                PTextGroupView *textGroupView = (PTextGroupView *)targetView;
                for(id subItem in [textGroupView subviews]) {
                    if([subItem isKindOfClass:[PUILabel class]]) {
                        PUILabel *label = (PUILabel *)subItem;
                        if([label.textType isEqualToString:@"title"]) {
                            titleGroupLayer = textGroupView.layer;
                            titleColor = label.textColor;
                            break;
                        } else if([label.textType isEqualToString:@"subtitle"]) {
                            if(titleGroupLayer == nil) {
                                titleGroupLayer = textGroupView.layer;
                                titleColor = label.textColor;
                            }
                            break;
                        }
                    }
                }
                [otherViewLayers addObject:textGroupView.layer];
                
                // 1차 오픈에서는 타이틀 애니메이션 제외
                /*
                if(titleGroupLayer != textGroupView.layer) {
                    
                    [otherViewLayers addObject:textGroupView.layer];
                }
                 */
                
            } else if([targetView isKindOfClass:[PPhotoView class]]) {
                
                [photoViewLayers addObject:targetView.layer];
                
            } else if([targetView isKindOfClass:[PFlatView class]]) {
                
                [flatViewLayers addObject:targetView.layer];
                
            } else {
                [otherViewLayers addObject:targetView.layer];
            }
        }
    }
    
    CABasicAnimation *in_opacityAnimation;
    CABasicAnimation *out_opacityAnimation;
    CABasicAnimation *in_opacityAnimation2;
    CABasicAnimation *positionAnimation;
    CABasicAnimation *scaleAnimation;
    
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithControlPoints:.25 :.0 :.0 :1];
    timingFunction = [CAMediaTimingFunction functionWithControlPoints:.5 :.0 :.0 :1];
    
    CAMediaTimingFunction *photoFadeTimingFunction = [CAMediaTimingFunction functionWithControlPoints:.0 :.0 :.5 :1];
    
    CGFloat fadeDuration = 0.75;
    CGFloat stayDuration = 1;
    CGFloat titleDuration = (titleGroupLayer) ? 2 : 0;
    // 1차 오픈에서는 타이틀 애니메이션 제외
    titleDuration = 0;
    
    CGFloat photoDuration = 4.5;
    photoDuration = 6;
    
    CGFloat inDuration = 0.75;
    
    CGFloat photoAnimationBeginTime = CACurrentMediaTime() + inDuration + stayDuration + titleDuration;
    CGFloat photoItemDuration = photoDuration / photoViewLayers.count;
    CGFloat photoFadeDuration = 1;
    
    CGFloat positionBeginTime = CACurrentMediaTime() + (inDuration + stayDuration + titleDuration + photoDuration);
    CGFloat positionDuration = 0.85;
    
    CGFloat inBeginTime = CACurrentMediaTime();
    
    CALayer *targetLayer;
    CGFloat targetOpacity = 1;
    
    CGPoint targetPosition;
    CGPoint layerCenterPosition = CGPointMake(synchronizedLayer.frame.size.width / 2, synchronizedLayer.frame.size.height / 2);

    
    CGFloat zoomScale = 1;
    CGFloat photoPositionDelay = 0.06 * photoViewLayers.count;
    CGFloat photoStayDurationDelay = 0;
    for(CALayer *sublayer in photoViewLayers) {
        
        targetLayer = sublayer;
        targetOpacity = targetLayer.opacity;
        targetPosition = targetLayer.position;
        
        //targetLayer.position = layerCenterPosition;
        
        CGPoint targetInPosition = layerCenterPosition;
        if(targetLayer.cornerRadius != 0) {
            if(ceil(targetLayer.frame.size.width / 2) == ceil(targetLayer.cornerRadius)) {
                CGFloat radians = radians(-135);
                CGPoint centerPoint = CGPointMake(targetLayer.frame.size.width / 2, targetLayer.frame.size.height / 2);
                
                CGFloat distance = targetLayer.frame.size.width / 2;
                
                CGPoint innerRectOrigin = CGPointMake(centerPoint.x + distance * cos(radians), centerPoint.y + distance * sin(radians));
                
                radians = radians(45);
                CGSize innerRectSize = CGSizeMake((centerPoint.x + distance * cos(radians)) - innerRectOrigin.x, (centerPoint.y + distance * sin(radians)) - innerRectOrigin.y);
                
                CGRect innerRect = CGRectMake(innerRectOrigin.x, innerRectOrigin.y, innerRectSize.width, innerRectSize.height);
                
                
                zoomScale = synchronizedLayer.frame.size.width / innerRect.size.width;
                if(innerRect.size.height * zoomScale < synchronizedLayer.frame.size.height) {
                    zoomScale = synchronizedLayer.frame.size.height / innerRect.size.height;
                }
                
            } else {
                zoomScale = synchronizedLayer.frame.size.width / targetLayer.frame.size.width;
                if(targetLayer.frame.size.height * zoomScale < synchronizedLayer.frame.size.height) {
                    zoomScale = synchronizedLayer.frame.size.height / targetLayer.frame.size.height;
                }
            }
        } else {
            
            
            zoomScale = synchronizedLayer.frame.size.width / targetLayer.frame.size.width;
            if(targetLayer.frame.size.height * zoomScale < synchronizedLayer.frame.size.height) {
                zoomScale = synchronizedLayer.frame.size.height / targetLayer.frame.size.height;
            }
            
            NSInteger marginWidth = round((targetLayer.frame.size.width * zoomScale) - synchronizedLayer.frame.size.width);
            NSInteger marginHeight = round((targetLayer.frame.size.height * zoomScale) - synchronizedLayer.frame.size.height);
            
            if(marginWidth > 0) {
                CGFloat randomX = (CGFloat)(arc4random() % marginWidth) - (marginWidth / 2);
                targetInPosition.x += randomX;
            }
            
            if(marginHeight > 0) {
                CGFloat randomY = (CGFloat)(arc4random() % marginHeight) - (marginHeight / 2);
                targetInPosition.y += randomY;
            }
        }
        
        
        out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation.beginTime = inBeginTime + stayDuration + photoStayDurationDelay;
        out_opacityAnimation.duration = fadeDuration;
        out_opacityAnimation.fillMode = kCAFillModeForwards;
        out_opacityAnimation.removedOnCompletion = NO;
        out_opacityAnimation.timingFunction = photoFadeTimingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        
        photoStayDurationDelay += 0.06;
        
        in_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation.beginTime = photoAnimationBeginTime;
        in_opacityAnimation.duration = photoFadeDuration;
        in_opacityAnimation.fillMode = kCAFillModeForwards;
        in_opacityAnimation.removedOnCompletion = NO;
        in_opacityAnimation.timingFunction = photoFadeTimingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation forKey:@"in_opacityAnimation2"];
        
        scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:zoomScale * 1.25];
        scaleAnimation.toValue = [NSNumber numberWithFloat:zoomScale];
        scaleAnimation.beginTime = photoAnimationBeginTime;
        scaleAnimation.duration = (positionBeginTime + photoPositionDelay) - photoAnimationBeginTime;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.removedOnCompletion = NO;
        scaleAnimation.timingFunction = photoFadeTimingFunction;
        
        [targetLayer addAnimation:scaleAnimation forKey:@"in_scaleAnimation"];
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:targetLayer.position];
        positionAnimation.toValue = [NSValue valueWithCGPoint:layerCenterPosition];
        positionAnimation.beginTime = photoAnimationBeginTime - 0.001;
        positionAnimation.duration = 0.001;
        positionAnimation.fillMode = kCAFillModeForwards;
        positionAnimation.removedOnCompletion = NO;
        positionAnimation.timingFunction = photoFadeTimingFunction;
        
        [targetLayer addAnimation:positionAnimation forKey:@"stay_positionAnimation"];
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:targetInPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:layerCenterPosition];
        positionAnimation.beginTime = photoAnimationBeginTime;
        positionAnimation.duration = (positionBeginTime + photoPositionDelay) - photoAnimationBeginTime;
        positionAnimation.fillMode = kCAFillModeForwards;
        positionAnimation.removedOnCompletion = NO;
        positionAnimation.timingFunction = photoFadeTimingFunction;
        
        [targetLayer addAnimation:positionAnimation forKey:@"in_positionAnimation"];
        
        scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:zoomScale];
        scaleAnimation.toValue = [NSNumber numberWithFloat:1];
        scaleAnimation.beginTime = positionBeginTime + photoPositionDelay;
        scaleAnimation.duration = positionDuration;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.removedOnCompletion = NO;
        scaleAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:layerCenterPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:targetPosition];
        positionAnimation.beginTime = positionBeginTime + photoPositionDelay;
        positionAnimation.duration = positionDuration;
        positionAnimation.fillMode = kCAFillModeForwards;
        positionAnimation.removedOnCompletion = NO;
        positionAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:positionAnimation forKey:@"positionAnimation"];
        
        
        photoAnimationBeginTime += photoItemDuration;
        photoPositionDelay -= 0.06;
    }
    
    CGFloat flatAnimationBeginTime = positionBeginTime + positionDuration;
    CGFloat flatAnimationDelay = 0;
    for(CALayer *sublayer in flatViewLayers) {
        
        targetLayer = sublayer;
        targetOpacity = targetLayer.opacity;
        
        out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation.beginTime = inBeginTime + stayDuration;
        out_opacityAnimation.duration = fadeDuration;
        out_opacityAnimation.fillMode = kCAFillModeForwards;
        out_opacityAnimation.removedOnCompletion = NO;
        out_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        
        flatAnimationDelay += 0.15;
        
        in_opacityAnimation2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation2.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation2.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation2.beginTime = flatAnimationBeginTime;
        in_opacityAnimation2.duration = fadeDuration;
        in_opacityAnimation2.fillMode = kCAFillModeForwards;
        in_opacityAnimation2.removedOnCompletion = NO;
        in_opacityAnimation2.timingFunction = timingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation2 forKey:@"in_opacityAnimation2"];
        
        flatAnimationBeginTime += 0.2;
    }
    
    CGFloat otherAnimationBeginTime = positionBeginTime + positionDuration;
    CGFloat otherAnimationDelay = 0;
    for(CALayer *sublayer in otherViewLayers) {
        targetLayer = sublayer;
        targetOpacity = targetLayer.opacity;
        
        out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation.beginTime = inBeginTime + stayDuration;
        out_opacityAnimation.duration = fadeDuration;
        out_opacityAnimation.fillMode = kCAFillModeForwards;
        out_opacityAnimation.removedOnCompletion = NO;
        out_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        
        otherAnimationDelay += 0.15;
        
        in_opacityAnimation2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation2.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation2.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation2.beginTime = otherAnimationBeginTime;
        in_opacityAnimation2.duration = fadeDuration;
        in_opacityAnimation2.fillMode = kCAFillModeForwards;
        in_opacityAnimation2.removedOnCompletion = NO;
        in_opacityAnimation2.timingFunction = timingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation2 forKey:@"in_opacityAnimation2"];
        
        otherAnimationBeginTime += 0.2;
    }
    
    self.previewTemplateLayer = synchronizedLayer;
    [self.previewAreaView.layer addSublayer:synchronizedLayer];
    
    if(isFirst) {
        in_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation.toValue = [NSNumber numberWithFloat:1];
        in_opacityAnimation.beginTime = 0;
        in_opacityAnimation.duration = fadeDuration;
        in_opacityAnimation.fillMode = kCAFillModeForwards;
        in_opacityAnimation.removedOnCompletion = NO;
        in_opacityAnimation.timingFunction = timingFunction;
        
        [self.previewTemplateLayer addAnimation:in_opacityAnimation forKey:@"in_opacityAnimation"];
    }
}


- (void)playPreviewAnimationLayer3
{
    BOOL isFirst = YES;
    if(self.previewTemplateLayer) {
        [self.previewTemplateLayer removeFromSuperlayer];
        self.previewTemplateLayer = nil;
        
        isFirst = NO;
    }
    CALayer *synchronizedLayer = [CALayer layer];
    //synchronizedLayer.backgroundColor = [[UIColor colorWithRed:1 green:0 blue:0 alpha:0.3] CGColor];
    //synchronizedLayer.drawsAsynchronously = YES;
    synchronizedLayer.edgeAntialiasingMask = YES;
    synchronizedLayer.masksToBounds = YES;
    synchronizedLayer.frame = self.previewTemplate.frame;
    synchronizedLayer.backgroundColor = [UIColor blackColor].CGColor;
    
    NSArray *targetViews = [self.previewTemplate.loadedNibView subviews];
    
    for(UIView *subview in targetViews) {
        [synchronizedLayer addSublayer:subview.layer];
    }
    
    CALayer *titleGroupLayer;
    CALayer *coverImageLayer;
    UIColor *titleColor;
    
    NSMutableArray *photoViewLayers = [NSMutableArray array];
    NSMutableArray *flatViewLayers = [NSMutableArray array];
    NSMutableArray *otherViewLayers = [NSMutableArray array];
    
    NSSortDescriptor *tagDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tag" ascending:YES];
    targetViews = [targetViews sortedArrayUsingDescriptors:[NSArray arrayWithObject:tagDescriptor]];
    
    for(int i = 1 ; i < targetViews.count ; i++) {
        UIView *targetView = (UIView *)[targetViews objectAtIndex:i];
        
        if(targetView.hidden == NO) {
            if([targetView isKindOfClass:[PTextGroupView class]]) {
                PTextGroupView *textGroupView = (PTextGroupView *)targetView;
                for(id subItem in [textGroupView subviews]) {
                    if([subItem isKindOfClass:[PUILabel class]]) {
                        PUILabel *label = (PUILabel *)subItem;
                        if([label.textType isEqualToString:@"title"]) {
                            titleGroupLayer = textGroupView.layer;
                            titleColor = label.textColor;
                            break;
                        } else if([label.textType isEqualToString:@"subtitle"]) {
                            if(titleGroupLayer == nil) {
                                titleGroupLayer = textGroupView.layer;
                                titleColor = label.textColor;
                            }
                            break;
                        }
                    }
                }
                if(titleGroupLayer != textGroupView.layer) {
                    
                    [otherViewLayers addObject:textGroupView.layer];
                }
                
            } else if([targetView isKindOfClass:[PCoverImageView class]]) {
                NSLog(@"coverImageLayer");
                coverImageLayer = targetView.layer;
                
            } else if([targetView isKindOfClass:[PPhotoView class]]) {
                
                [photoViewLayers addObject:targetView.layer];
                
            } else if([targetView isKindOfClass:[PFlatView class]]) {
                
                [flatViewLayers addObject:targetView.layer];
                
            } else {
                [otherViewLayers addObject:targetView.layer];
            }
        }
    }
    
    CABasicAnimation *in_opacityAnimation;
    CABasicAnimation *out_opacityAnimation;
    CABasicAnimation *positionAnimation;
    CABasicAnimation *scaleAnimation;
    CABasicAnimation *transformAnimation;

    CAMediaTimingFunction *inTimingFunction = [CAMediaTimingFunction functionWithControlPoints:.8 :.0 :.7 :.7];
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithControlPoints:.45 :.0 :.1 :1.0];
    CAMediaTimingFunction *positionTimingFunction = [CAMediaTimingFunction functionWithControlPoints:.45 :0 :.2 :1.0];
    CAMediaTimingFunction *photoFadeTimingFunction = [CAMediaTimingFunction functionWithControlPoints:.0 :.0 :.5 :1.0];
    
    CGFloat fadeDuration = 0.75;
    
    CGFloat stayDuration = 2;
    CGFloat stayOutDuration = 0.9;
    CGFloat titleDuration = 0;
    
    CGFloat photoDuration = 4.5;
    photoDuration = 7.5;
    
    CGFloat photoAnimationBeginTime = CACurrentMediaTime() + stayDuration + stayOutDuration + (0.25) + titleDuration;
    CGFloat photoItemDuration = photoDuration / photoViewLayers.count;
    CGFloat photoFadeDuration = 1;
    
    CGFloat positionBeginTime = CACurrentMediaTime() + (stayDuration + stayOutDuration + (0.25) + titleDuration + photoDuration);
    CGFloat positionDuration = 0.9;
    
    CGFloat inBeginTime = CACurrentMediaTime();
    
    CALayer *targetLayer;
    CGFloat targetOpacity = 1;
    
    CGPoint targetPosition;
    CGPoint layerCenterPosition = CGPointMake(synchronizedLayer.frame.size.width / 2, synchronizedLayer.frame.size.height / 2);
    
    
    if(titleGroupLayer) {
        
        targetLayer = titleGroupLayer;
        targetOpacity = targetLayer.opacity;
        targetPosition = targetLayer.position;
        
        CATransform3D targetTransform = targetLayer.transform;
        
        CGFloat translationScale = targetLayer.frame.size.width / 5;
        CGFloat translationX = (CGFloat)(arc4random() % (NSInteger)translationScale) - (translationScale/2);
        CATransform3D outTransform;
        if(arc4random() % 2 == 1) {
            outTransform = CATransform3DTranslate(targetTransform, 0, translationX, 0);
        } else {
            outTransform = CATransform3DTranslate(targetTransform, translationX, 0, 0);
        }
        
        CGFloat scaleValue = (CGFloat)((arc4random() % 15) + 85) * 0.01;
        CATransform3D inTransform = CATransform3DScale(targetLayer.transform, scaleValue, scaleValue, 1);
        
        transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:targetLayer.transform];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:inTransform];
        transformAnimation.beginTime = inBeginTime + stayDuration;
        transformAnimation.duration = stayOutDuration + 0.25;
        transformAnimation.fillMode = kCAFillModeForwards;
        transformAnimation.removedOnCompletion = NO;
        transformAnimation.timingFunction = inTimingFunction;
        
        [targetLayer addAnimation:transformAnimation forKey:@"out_transformAnimation"];
        
        
        out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation.beginTime = inBeginTime + stayDuration;
        out_opacityAnimation.duration = stayOutDuration + 0.25;
        out_opacityAnimation.fillMode = kCAFillModeForwards;
        out_opacityAnimation.removedOnCompletion = NO;
        out_opacityAnimation.timingFunction = inTimingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        
        transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:outTransform];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:targetLayer.transform];
        transformAnimation.beginTime = positionBeginTime + positionDuration;
        transformAnimation.duration = fadeDuration;
        transformAnimation.fillMode = kCAFillModeForwards;
        transformAnimation.removedOnCompletion = NO;
        transformAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:transformAnimation forKey:@"in_transformAnimation"];
        
        in_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation.beginTime = positionBeginTime + positionDuration;
        in_opacityAnimation.duration = fadeDuration;
        in_opacityAnimation.fillMode = kCAFillModeForwards;
        in_opacityAnimation.removedOnCompletion = NO;
        in_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation forKey:@"in_opacityAnimation"];
        
    }
    
    if(coverImageLayer) {
        
        targetLayer = coverImageLayer;
        targetOpacity = targetLayer.opacity;
        targetPosition = targetLayer.position;
        
        out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation.beginTime = inBeginTime + stayDuration + (stayOutDuration / 2);
        out_opacityAnimation.duration = stayOutDuration;
        out_opacityAnimation.fillMode = kCAFillModeForwards;
        out_opacityAnimation.removedOnCompletion = NO;
        out_opacityAnimation.timingFunction = inTimingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        
        in_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation.beginTime = positionBeginTime - fadeDuration;
        in_opacityAnimation.duration = fadeDuration;
        in_opacityAnimation.fillMode = kCAFillModeForwards;
        in_opacityAnimation.removedOnCompletion = NO;
        in_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation forKey:@"in_opacityAnimation"];
    }
    
    CGFloat zoomScale = 1;
    CGFloat photoPositionDelay = 0.06 * photoViewLayers.count;
    CGFloat photoStayDurationDelay = 0;
    for(CALayer *sublayer in photoViewLayers) {
        
        targetLayer = sublayer;
        targetOpacity = targetLayer.opacity;
        targetPosition = targetLayer.position;
        
        CGPoint targetInPosition = layerCenterPosition;
        if(targetLayer.cornerRadius != 0) {
            // 원형 사진
            if(ceil(targetLayer.frame.size.width / 2) == ceil(targetLayer.cornerRadius)) {
                
                CGFloat radians = radians(-135);
                CGPoint centerPoint = CGPointMake(targetLayer.frame.size.width / 2, targetLayer.frame.size.height / 2);
                
                CGFloat distance = targetLayer.frame.size.width / 2;
                
                CGPoint innerRectOrigin = CGPointMake(centerPoint.x + distance * cos(radians), centerPoint.y + distance * sin(radians));
                
                radians = radians(45);
                CGSize innerRectSize = CGSizeMake((centerPoint.x + distance * cos(radians)) - innerRectOrigin.x, (centerPoint.y + distance * sin(radians)) - innerRectOrigin.y);
                
                CGRect innerRect = CGRectMake(innerRectOrigin.x, innerRectOrigin.y, innerRectSize.width, innerRectSize.height);
                
                zoomScale = synchronizedLayer.frame.size.width / innerRect.size.width;
                if(innerRect.size.height * zoomScale < synchronizedLayer.frame.size.height) {
                    zoomScale = synchronizedLayer.frame.size.height / innerRect.size.height;
                }
                
            } else {
                zoomScale = synchronizedLayer.frame.size.width / targetLayer.frame.size.width;
                if(targetLayer.frame.size.height * zoomScale < synchronizedLayer.frame.size.height) {
                    zoomScale = synchronizedLayer.frame.size.height / targetLayer.frame.size.height;
                }
            }
            
        } else {
            // 일반 사진
            
            zoomScale = synchronizedLayer.frame.size.width / targetLayer.frame.size.width;
            if(targetLayer.frame.size.height * zoomScale < synchronizedLayer.frame.size.height) {
                zoomScale = synchronizedLayer.frame.size.height / targetLayer.frame.size.height;
            }
            
            NSInteger marginWidth = round((targetLayer.frame.size.width * zoomScale) - synchronizedLayer.frame.size.width);
            NSInteger marginHeight = round((targetLayer.frame.size.height * zoomScale) - synchronizedLayer.frame.size.height);
            
            if(marginWidth > 0) {
                CGFloat randomX = (CGFloat)(arc4random() % marginWidth) - (marginWidth / 2);
                targetInPosition.x += randomX;
            }
            
            if(marginHeight > 0) {
                CGFloat randomY = (CGFloat)(arc4random() % marginHeight) - (marginHeight / 2);
                targetInPosition.y += randomY;
            }
        }
        
        
        photoStayDurationDelay = (CGFloat)(arc4random() % 100) * 0.0025;
        
        out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation.beginTime = inBeginTime + stayDuration + photoStayDurationDelay;
        out_opacityAnimation.duration = stayOutDuration;
        out_opacityAnimation.fillMode = kCAFillModeForwards;
        out_opacityAnimation.removedOnCompletion = NO;
        out_opacityAnimation.timingFunction = inTimingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        
        in_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation.beginTime = photoAnimationBeginTime;
        in_opacityAnimation.duration = photoFadeDuration;
        in_opacityAnimation.fillMode = kCAFillModeForwards;
        in_opacityAnimation.removedOnCompletion = NO;
        in_opacityAnimation.timingFunction = photoFadeTimingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation forKey:@"in_opacityAnimation2"];
        
        scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:zoomScale * 1.25];
        scaleAnimation.toValue = [NSNumber numberWithFloat:zoomScale];
        scaleAnimation.beginTime = photoAnimationBeginTime;
        scaleAnimation.duration = (positionBeginTime + photoPositionDelay) - photoAnimationBeginTime;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.removedOnCompletion = NO;
        scaleAnimation.timingFunction = photoFadeTimingFunction;
        
        [targetLayer addAnimation:scaleAnimation forKey:@"in_scaleAnimation"];
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:targetLayer.position];
        positionAnimation.toValue = [NSValue valueWithCGPoint:layerCenterPosition];
        positionAnimation.beginTime = photoAnimationBeginTime - 0.001;
        positionAnimation.duration = 0.001;
        positionAnimation.fillMode = kCAFillModeForwards;
        positionAnimation.removedOnCompletion = NO;
        positionAnimation.timingFunction = photoFadeTimingFunction;
        
        [targetLayer addAnimation:positionAnimation forKey:@"stay_positionAnimation"];
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:targetInPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:layerCenterPosition];
        positionAnimation.beginTime = photoAnimationBeginTime;
        positionAnimation.duration = (positionBeginTime + photoPositionDelay) - photoAnimationBeginTime;
        positionAnimation.fillMode = kCAFillModeForwards;
        positionAnimation.removedOnCompletion = NO;
        positionAnimation.timingFunction = photoFadeTimingFunction;
        
        [targetLayer addAnimation:positionAnimation forKey:@"in_positionAnimation"];
        
        scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:zoomScale];
        scaleAnimation.toValue = [NSNumber numberWithFloat:1];
        scaleAnimation.beginTime = positionBeginTime + photoPositionDelay;
        scaleAnimation.duration = positionDuration;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.removedOnCompletion = NO;
        scaleAnimation.timingFunction = positionTimingFunction;
        
        [targetLayer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:layerCenterPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:targetPosition];
        positionAnimation.beginTime = positionBeginTime + photoPositionDelay;
        positionAnimation.duration = positionDuration;
        positionAnimation.fillMode = kCAFillModeForwards;
        positionAnimation.removedOnCompletion = NO;
        positionAnimation.timingFunction = positionTimingFunction;
        
        [targetLayer addAnimation:positionAnimation forKey:@"positionAnimation"];
        
        
        photoAnimationBeginTime += photoItemDuration;
        photoPositionDelay -= 0.06;
    }
    
    CGFloat flatAnimationBeginTime = positionBeginTime + positionDuration;
    CGFloat flatAnimationDelay = -0.05;
    for(CALayer *sublayer in flatViewLayers) {
        targetLayer = sublayer;
        targetOpacity = targetLayer.opacity;
        targetPosition = targetLayer.position;
        
        CATransform3D targetTransform = targetLayer.transform;
        CATransform3D outTransform = CATransform3DTranslate(targetTransform, 0, 0, 0);
        CGFloat scaleValue;
        
        if(targetLayer.frame.size.width > targetLayer.frame.size.height * 2 || targetLayer.frame.size.width * 2 < targetLayer.frame.size.height) {
            // Line 인 경우
            scaleValue = (CGFloat)((arc4random() % 60) + 90) * 0.01;
            if(arc4random() % 2 == 1) {
                outTransform = CATransform3DScale(outTransform, scaleValue, 1, 1);
            } else {
                outTransform = CATransform3DScale(outTransform, 1, scaleValue, 1);
            }
        } else {
            scaleValue = (CGFloat)((arc4random() % 15) + 85) * 0.01;
            // Shape 인 경우
            outTransform = CATransform3DScale(outTransform, scaleValue, scaleValue, 1);
        }
        
        scaleValue = (CGFloat)((arc4random() % 15) + 85) * 0.01;
        CATransform3D inTransform = CATransform3DScale(targetLayer.transform, scaleValue, scaleValue, 1);
        
        flatAnimationDelay = (CGFloat)(arc4random() % 100) * 0.0025;
        
        transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:targetLayer.transform];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:inTransform];
        transformAnimation.beginTime = inBeginTime + stayDuration + flatAnimationDelay;
        transformAnimation.duration = stayOutDuration;
        transformAnimation.fillMode = kCAFillModeForwards;
        transformAnimation.removedOnCompletion = NO;
        transformAnimation.timingFunction = inTimingFunction;
        
        [targetLayer addAnimation:transformAnimation forKey:@"out_transformAnimation"];
        
        out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation.beginTime = inBeginTime + stayDuration + flatAnimationDelay;
        out_opacityAnimation.duration = stayOutDuration;
        out_opacityAnimation.fillMode = kCAFillModeForwards;
        out_opacityAnimation.removedOnCompletion = NO;
        out_opacityAnimation.timingFunction = inTimingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        
        transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:outTransform];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:targetLayer.transform];
        transformAnimation.beginTime = flatAnimationBeginTime;
        transformAnimation.duration = fadeDuration;
        transformAnimation.fillMode = kCAFillModeForwards;
        transformAnimation.removedOnCompletion = NO;
        transformAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:transformAnimation forKey:@"in_transformAnimation"];
        
        in_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation.beginTime = flatAnimationBeginTime;
        in_opacityAnimation.duration = fadeDuration;
        in_opacityAnimation.fillMode = kCAFillModeForwards;
        in_opacityAnimation.removedOnCompletion = NO;
        in_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation forKey:@"in_opacityAnimation"];
        
        flatAnimationBeginTime += 0.1;
    }
    
    CGFloat otherAnimationBeginTime = positionBeginTime + positionDuration;
    CGFloat otherAnimationDelay = 0;
    for(CALayer *sublayer in otherViewLayers) {
        targetLayer = sublayer;
        targetOpacity = targetLayer.opacity;
        targetPosition = targetLayer.position;
        
        CATransform3D targetTransform = targetLayer.transform;
        CGFloat translationScale = targetLayer.frame.size.width / 7;
        CGFloat translationX = (CGFloat)(arc4random() % (NSInteger)translationScale) - (translationScale/2);
        
        CATransform3D outTransform;
        if(arc4random() % 2 == 1) {
            outTransform = CATransform3DTranslate(targetTransform, 0, translationX, 0);
        } else {
            outTransform = CATransform3DTranslate(targetTransform, translationX, 0, 0);
        }
        
        CGFloat scaleValue = (CGFloat)((arc4random() % 15) + 85) * 0.01;
        CATransform3D inTransform = CATransform3DScale(targetLayer.transform, scaleValue, scaleValue, 1);
        
        transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:targetLayer.transform];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:inTransform];
        transformAnimation.beginTime = inBeginTime + stayDuration + otherAnimationDelay;
        transformAnimation.duration = stayOutDuration;
        transformAnimation.fillMode = kCAFillModeForwards;
        transformAnimation.removedOnCompletion = NO;
        transformAnimation.timingFunction = inTimingFunction;
        
        [targetLayer addAnimation:transformAnimation forKey:@"out_transformAnimation"];
        
        
        out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation.beginTime = inBeginTime + stayDuration + otherAnimationDelay;
        out_opacityAnimation.duration = stayOutDuration;
        out_opacityAnimation.fillMode = kCAFillModeForwards;
        out_opacityAnimation.removedOnCompletion = NO;
        out_opacityAnimation.timingFunction = inTimingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        
        otherAnimationDelay -= 0.05;
        
        transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:outTransform];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:targetLayer.transform];
        transformAnimation.beginTime = otherAnimationBeginTime;
        transformAnimation.duration = fadeDuration;
        transformAnimation.fillMode = kCAFillModeForwards;
        transformAnimation.removedOnCompletion = NO;
        transformAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:transformAnimation forKey:@"in_transformAnimation"];
        
        in_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation.beginTime = otherAnimationBeginTime;
        in_opacityAnimation.duration = fadeDuration;
        in_opacityAnimation.fillMode = kCAFillModeForwards;
        in_opacityAnimation.removedOnCompletion = NO;
        in_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation forKey:@"in_opacityAnimation"];
        
        otherAnimationBeginTime += 0.1;
    }
    
    self.previewTemplateLayer = synchronizedLayer;
    [self.previewAreaView.layer addSublayer:synchronizedLayer];
    
    if(isFirst) {
        in_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation.toValue = [NSNumber numberWithFloat:1];
        in_opacityAnimation.beginTime = 0;
        in_opacityAnimation.duration = fadeDuration;
        in_opacityAnimation.fillMode = kCAFillModeForwards;
        in_opacityAnimation.removedOnCompletion = NO;
        in_opacityAnimation.timingFunction = timingFunction;
        
        [self.previewTemplateLayer addAnimation:in_opacityAnimation forKey:@"in_opacityAnimation"];
    }
}


- (CALayer *)buildSynchronizedLayerWithVideoSize:(CGSize)videoSize
{
    CALayer *synchronizedLayer = [CALayer layer];
    synchronizedLayer.backgroundColor = [[UIColor clearColor] CGColor];
    synchronizedLayer.drawsAsynchronously = YES;
    synchronizedLayer.edgeAntialiasingMask = YES;
    synchronizedLayer.geometryFlipped = YES;
    synchronizedLayer.masksToBounds = YES;
    synchronizedLayer.frame = self.resultTemplate.frame;
    synchronizedLayer.backgroundColor = [UIColor blackColor].CGColor;
    
    NSArray *targetViews = [self.resultTemplate.loadedNibView subviews];
    
    for(UIView *subview in targetViews) {
        [synchronizedLayer addSublayer:subview.layer];
    }
    
    UIView *backgroundView = (UIView *)[targetViews firstObject];
    UIColor *backgroundColor = backgroundView.backgroundColor;
    //CALayer *backgroundLayer = backgroundView.layer;
    //synchronizedLayer.backgroundColor = backgroundView.backgroundColor.CGColor;
    
    CALayer *titleBackgroundLayer;
    CALayer *titleGroupLayer;
    UIColor *titleColor;
    
    NSMutableArray *photoViewLayers = [NSMutableArray array];
    NSMutableArray *flatViewLayers = [NSMutableArray array];
    NSMutableArray *otherViewLayers = [NSMutableArray array];
    
    NSSortDescriptor *tagDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tag" ascending:YES];
    targetViews = [targetViews sortedArrayUsingDescriptors:[NSArray arrayWithObject:tagDescriptor]];
    
    for(int i = 1 ; i < targetViews.count ; i++) {
        UIView *targetView = (UIView *)[targetViews objectAtIndex:i];
        
        if(targetView.hidden == NO) {
            if([targetView isKindOfClass:[PTextGroupView class]]) {
                PTextGroupView *textGroupView = (PTextGroupView *)targetView;
                for(id subItem in [textGroupView subviews]) {
                    UIView *subView = (UIView *)subItem;
                    subView.layer.geometryFlipped = YES;
                    
                    if([subItem isKindOfClass:[PUILabel class]]) {
                        PUILabel *label = (PUILabel *)subItem;
                        
                        if([label.textType isEqualToString:@"title"]) {
                            titleGroupLayer = textGroupView.layer;
                            titleColor = label.textColor;
                            break;
                        } else if([label.textType isEqualToString:@"subtitle"]) {
                            if(titleGroupLayer == nil) {
                                titleGroupLayer = textGroupView.layer;
                                titleColor = label.textColor;
                            }
                            break;
                        }
                    }
                }
                if(titleGroupLayer != textGroupView.layer) {
                    
                    [otherViewLayers addObject:textGroupView.layer];
                }
                
                //targetView.layer.geometryFlipped = YES;
                
            } else if([targetView isKindOfClass:[PPhotoView class]]) {
                
                [photoViewLayers addObject:targetView.layer];
                
            } else if([targetView isKindOfClass:[PFlatView class]]) {
                
                [flatViewLayers addObject:targetView.layer];
                
            } else {
                [otherViewLayers addObject:targetView.layer];
            }
        }
        
    }
    
    CABasicAnimation *in_opacityAnimation;
    CABasicAnimation *out_opacityAnimation;
    CABasicAnimation *in_opacityAnimation2;
    CABasicAnimation *out_opacityAnimation2;
    CABasicAnimation *positionAnimation;
    CABasicAnimation *scaleAnimation;
    CABasicAnimation *transformAnimation;
    
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithControlPoints:.25 :.0 :.0 :1];
    timingFunction = [CAMediaTimingFunction functionWithControlPoints:.5 :.0 :.0 :1];
    
    CAMediaTimingFunction *photoFadeTimingFunction = [CAMediaTimingFunction functionWithControlPoints:.0 :.0 :.5 :1];
    
    CGFloat fullDuration = 15;
    
    CGFloat fadeDuration = 0.75;
    CGFloat titleDuration = (titleGroupLayer) ? 2 : 0;
    CGFloat photoDuration = 4.5;
    //CGFloat otherDuration = 5;
    
    CGFloat inDuration = 0.75;
    CGFloat outDuration = 0.75;
    
    CGFloat photoAnimationBeginTime = fadeDuration + titleDuration;
    CGFloat photoItemDuration = photoDuration / photoViewLayers.count;
    CGFloat photoFadeDuration = 1;
    
    // 비디오 생성할때 0 부터 시작하면 애니메이션 적용 안됨
    CGFloat inBeginTime = 0.05; //0;
    CGFloat outBeginTime = 0;
    
    CGFloat positionBeginTime = (fadeDuration + titleDuration + photoDuration);
    CGFloat positionDuration = 0.85;
    
    CALayer *targetLayer;
    CGFloat targetOpacity = 1;
    
    CGPoint targetPosition;
    CGPoint layerCenterPosition = CGPointMake(synchronizedLayer.frame.size.width / 2, synchronizedLayer.frame.size.height / 2);
    
    if(titleGroupLayer) {
        if(CGColorEqualToColor(titleColor.CGColor, backgroundColor.CGColor)) {
            
            CGFloat r,g,b,a;
            [titleColor getRed:&r green:&g blue:&b alpha:&a];
            UIColor *titleBackgroundColor = [UIColor colorWithRed:1.-r green:1.-g blue:1.-b alpha:1];
            
            titleBackgroundLayer = [CALayer layer];
            titleBackgroundLayer.frame = synchronizedLayer.bounds;
            titleBackgroundLayer.backgroundColor = titleBackgroundColor.CGColor;
            
            [synchronizedLayer insertSublayer:titleBackgroundLayer below:titleGroupLayer];
            
            out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            out_opacityAnimation.fromValue = [NSNumber numberWithFloat:1];
            out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
            out_opacityAnimation.beginTime = photoAnimationBeginTime;
            out_opacityAnimation.duration = fadeDuration;
            out_opacityAnimation.fillMode = kCAFillModeForwards;
            out_opacityAnimation.removedOnCompletion = NO;
            out_opacityAnimation.timingFunction = timingFunction;
            
            [titleBackgroundLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        }

        
        CGFloat r,g,b,a;
        [titleColor getRed:&r green:&g blue:&b alpha:&a];
        UIColor *titleBackgroundColor = [UIColor colorWithRed:1.-r green:1.-g blue:1.-b alpha:1];
        
        titleBackgroundLayer = [CALayer layer];
        titleBackgroundLayer.frame = synchronizedLayer.bounds;
        titleBackgroundLayer.backgroundColor = titleBackgroundColor.CGColor;
        
        [synchronizedLayer insertSublayer:titleBackgroundLayer below:titleGroupLayer];
        
        out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation.fromValue = [NSNumber numberWithFloat:1];
        out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation.beginTime = photoAnimationBeginTime;
        out_opacityAnimation.duration = fadeDuration;
        out_opacityAnimation.fillMode = kCAFillModeForwards;
        out_opacityAnimation.removedOnCompletion = NO;
        out_opacityAnimation.timingFunction = timingFunction;
        
        [titleBackgroundLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        
        
        targetLayer = titleGroupLayer;
        targetOpacity = targetLayer.opacity;
        targetPosition = targetLayer.position;
        
        CATransform3D targetTransform = targetLayer.transform;
        
        CGFloat zoomScale = 1;
        CGSize titleMaxSize = CGSizeMake((synchronizedLayer.frame.size.width / 2), (synchronizedLayer.frame.size.height / 2));
        if(targetLayer.frame.size.width < titleMaxSize.width) {
            zoomScale = titleMaxSize.width / targetLayer.frame.size.width;
            if(targetLayer.frame.size.height * zoomScale > titleMaxSize.height) {
                zoomScale = titleMaxSize.height / targetLayer.frame.size.height;
            }
            targetLayer.transform = CATransform3DMakeScale(zoomScale, zoomScale, 1);
        }
        
        targetLayer.position = layerCenterPosition;
        
        targetLayer.opacity = 0;
        inBeginTime = 0.05;
        outBeginTime = fullDuration - outDuration;
        
        in_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation.beginTime = inBeginTime;
        in_opacityAnimation.duration = inDuration;
        in_opacityAnimation.fillMode = kCAFillModeForwards;
        in_opacityAnimation.removedOnCompletion = NO;
        in_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation forKey:@"in_opacityAnimation"];
        
        scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:zoomScale * 1.5];
        scaleAnimation.toValue = [NSNumber numberWithFloat:zoomScale];
        scaleAnimation.beginTime = inBeginTime;
        scaleAnimation.duration = inDuration;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.removedOnCompletion = NO;
        scaleAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:scaleAnimation forKey:@"in_scaleAnimation"];
        
        out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation.beginTime = photoAnimationBeginTime - fadeDuration;
        out_opacityAnimation.duration = fadeDuration;
        out_opacityAnimation.fillMode = kCAFillModeForwards;
        out_opacityAnimation.removedOnCompletion = NO;
        out_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        
        /*
        scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:zoomScale];
        scaleAnimation.toValue = [NSNumber numberWithFloat:1];
        scaleAnimation.beginTime = positionBeginTime + positionDuration;
        scaleAnimation.duration = 0.001;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.removedOnCompletion = NO;
        scaleAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
        */
        transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:targetLayer.transform];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:targetTransform];
        transformAnimation.beginTime = positionBeginTime + positionDuration;
        transformAnimation.duration = 0.001;
        transformAnimation.fillMode = kCAFillModeForwards;
        transformAnimation.removedOnCompletion = NO;
        transformAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:transformAnimation forKey:@"transformAnimation"];
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:layerCenterPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:targetPosition];
        positionAnimation.beginTime = positionBeginTime + positionDuration;
        positionAnimation.duration = 0.001;
        positionAnimation.fillMode = kCAFillModeForwards;
        positionAnimation.removedOnCompletion = NO;
        positionAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:positionAnimation forKey:@"positionAnimation"];
        
        
        in_opacityAnimation2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation2.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation2.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation2.beginTime = positionBeginTime + positionDuration;
        in_opacityAnimation2.duration = fadeDuration;
        in_opacityAnimation2.fillMode = kCAFillModeForwards;
        in_opacityAnimation2.removedOnCompletion = NO;
        in_opacityAnimation2.timingFunction = timingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation2 forKey:@"in_opacityAnimation2"];
        
        out_opacityAnimation2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation2.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation2.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation2.beginTime = outBeginTime;
        out_opacityAnimation2.duration = fadeDuration;
        out_opacityAnimation2.fillMode = kCAFillModeForwards;
        out_opacityAnimation2.removedOnCompletion = NO;
        out_opacityAnimation2.timingFunction = timingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation2 forKey:@"out_opacityAnimation2"];
    }
    CGFloat zoomScale = 1;
    CGFloat photoPositionDelay = 0.06 * photoViewLayers.count;
    for(CALayer *sublayer in photoViewLayers) {
        
        targetLayer = sublayer;
        targetOpacity = targetLayer.opacity;
        targetPosition = targetLayer.position;
        
        targetLayer.position = layerCenterPosition;
        
        CGPoint targetInPosition = layerCenterPosition;
        if(targetLayer.cornerRadius != 0) {
            if(ceil(targetLayer.frame.size.width / 2) == ceil(targetLayer.cornerRadius)) {
                NSLog(@"targetLayer.frame : %@", NSStringFromCGRect(targetLayer.frame));
                
                CGFloat radians = radians(-135);
                CGPoint centerPoint = CGPointMake(targetLayer.frame.size.width / 2, targetLayer.frame.size.height / 2);
                
                CGFloat distance = targetLayer.frame.size.width / 2;
                
                CGPoint innerRectOrigin = CGPointMake(centerPoint.x + distance * cos(radians), centerPoint.y + distance * sin(radians));
                //NSLog(@"innerRectOrigin : %@", NSStringFromCGPoint(innerRectOrigin));
                
                radians = radians(45);
                CGSize innerRectSize = CGSizeMake((centerPoint.x + distance * cos(radians)) - innerRectOrigin.x, (centerPoint.y + distance * sin(radians)) - innerRectOrigin.y);
                
                //NSLog(@"innerRectSize : %@", NSStringFromCGSize(innerRectSize));
                
                CGRect innerRect = CGRectMake(innerRectOrigin.x, innerRectOrigin.y, innerRectSize.width, innerRectSize.height);
                
                NSLog(@"innerRect : %@", NSStringFromCGRect(innerRect));
                
                
                zoomScale = synchronizedLayer.frame.size.width / innerRect.size.width;
                if(innerRect.size.height * zoomScale < synchronizedLayer.frame.size.height) {
                    zoomScale = synchronizedLayer.frame.size.height / innerRect.size.height;
                }
                
            } else {
                zoomScale = synchronizedLayer.frame.size.width / targetLayer.frame.size.width;
                if(targetLayer.frame.size.height * zoomScale < synchronizedLayer.frame.size.height) {
                    zoomScale = synchronizedLayer.frame.size.height / targetLayer.frame.size.height;
                }
            }
        } else {
            
            zoomScale = synchronizedLayer.frame.size.width / targetLayer.frame.size.width;
            if(targetLayer.frame.size.height * zoomScale < synchronizedLayer.frame.size.height) {
                zoomScale = synchronizedLayer.frame.size.height / targetLayer.frame.size.height;
            }
            
            NSInteger marginWidth = round((targetLayer.frame.size.width * zoomScale) - synchronizedLayer.frame.size.width);
            NSInteger marginHeight = round((targetLayer.frame.size.height * zoomScale) - synchronizedLayer.frame.size.height);
            
            if(marginWidth > 0) {
                CGFloat randomX = (CGFloat)(arc4random() % marginWidth) - (marginWidth / 2);
                targetInPosition.x += randomX;
            }
            
            if(marginHeight > 0) {
                CGFloat randomY = (CGFloat)(arc4random() % marginHeight) - (marginHeight / 2);
                targetInPosition.y += randomY;
            }
        }
        
        
        targetLayer.transform = CATransform3DMakeScale(zoomScale, zoomScale, 1);
        targetLayer.opacity = 0;
        
        inBeginTime = photoAnimationBeginTime;
        outBeginTime = fullDuration - outDuration;
        
        in_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation.beginTime = inBeginTime;
        in_opacityAnimation.duration = photoFadeDuration;
        in_opacityAnimation.fillMode = kCAFillModeForwards;
        in_opacityAnimation.removedOnCompletion = NO;
        in_opacityAnimation.timingFunction = photoFadeTimingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation forKey:@"in_opacityAnimation"];
        
        scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:zoomScale * 1.25];
        scaleAnimation.toValue = [NSNumber numberWithFloat:zoomScale];
        scaleAnimation.beginTime = inBeginTime;
        scaleAnimation.duration = (positionBeginTime + photoPositionDelay) - inBeginTime;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.removedOnCompletion = NO;
        scaleAnimation.timingFunction = photoFadeTimingFunction;
        
        [targetLayer addAnimation:scaleAnimation forKey:@"in_scaleAnimation"];
        
        if(CGPointEqualToPoint(targetInPosition, layerCenterPosition) == NO) {
            positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
            positionAnimation.fromValue = [NSValue valueWithCGPoint:targetInPosition];
            positionAnimation.toValue = [NSValue valueWithCGPoint:layerCenterPosition];
            positionAnimation.beginTime = inBeginTime;
            positionAnimation.duration = (positionBeginTime + photoPositionDelay) - inBeginTime;
            positionAnimation.fillMode = kCAFillModeForwards;
            positionAnimation.removedOnCompletion = NO;
            positionAnimation.timingFunction = photoFadeTimingFunction;
            
            [targetLayer addAnimation:positionAnimation forKey:@"in_positionAnimation"];
        }
        
        out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation.beginTime = outBeginTime;
        out_opacityAnimation.duration = fadeDuration;
        out_opacityAnimation.fillMode = kCAFillModeForwards;
        out_opacityAnimation.removedOnCompletion = NO;
        out_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        
        scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:zoomScale];
        scaleAnimation.toValue = [NSNumber numberWithFloat:1];
        scaleAnimation.beginTime = positionBeginTime + photoPositionDelay;
        scaleAnimation.duration = positionDuration;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.removedOnCompletion = NO;
        scaleAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:layerCenterPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:targetPosition];
        positionAnimation.beginTime = positionBeginTime + photoPositionDelay;
        positionAnimation.duration = positionDuration;
        positionAnimation.fillMode = kCAFillModeForwards;
        positionAnimation.removedOnCompletion = NO;
        positionAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:positionAnimation forKey:@"positionAnimation"];
        
        
        photoAnimationBeginTime += photoItemDuration;
        photoPositionDelay -= 0.06;
    }
    
    
    CGFloat flatAnimationBeginTime = positionBeginTime + positionDuration;
    for(CALayer *sublayer in flatViewLayers) {
        
        targetLayer = sublayer;
        targetOpacity = targetLayer.opacity;
        
        targetLayer.opacity = 0;
        
        inBeginTime = flatAnimationBeginTime;
        outBeginTime = fullDuration - outDuration;
        
        inDuration = fadeDuration;
        outDuration = fadeDuration;
        
        in_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation.beginTime = inBeginTime;
        in_opacityAnimation.duration = inDuration;
        in_opacityAnimation.fillMode = kCAFillModeForwards;
        in_opacityAnimation.removedOnCompletion = NO;
        in_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation forKey:@"in_opacityAnimation"];
        
        out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation.beginTime = outBeginTime;
        out_opacityAnimation.duration = outDuration;
        out_opacityAnimation.fillMode = kCAFillModeForwards;
        out_opacityAnimation.removedOnCompletion = NO;
        out_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        flatAnimationBeginTime += 0.2;
    }
    
    CGFloat otherAnimationBeginTime = positionBeginTime + positionDuration;
    for(CALayer *sublayer in otherViewLayers) {
        targetLayer = sublayer;
        targetOpacity = targetLayer.opacity;
        
        targetLayer.opacity = 0;
        
        inBeginTime = otherAnimationBeginTime;
        outBeginTime = fullDuration - outDuration;
        
        inDuration = fadeDuration;
        outDuration = fadeDuration;
        
        in_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation.beginTime = inBeginTime;
        in_opacityAnimation.duration = inDuration;
        in_opacityAnimation.fillMode = kCAFillModeForwards;
        in_opacityAnimation.removedOnCompletion = NO;
        in_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation forKey:@"in_opacityAnimation"];
        
        out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation.beginTime = outBeginTime;
        out_opacityAnimation.duration = outDuration;
        out_opacityAnimation.fillMode = kCAFillModeForwards;
        out_opacityAnimation.removedOnCompletion = NO;
        out_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        otherAnimationBeginTime += 0.2;
    }
    
    return synchronizedLayer;

}

- (CALayer *)buildSynchronizedLayerWithVideoSize2:(CGSize)videoSize
{
    CALayer *synchronizedLayer = [CALayer layer];
    synchronizedLayer.backgroundColor = [[UIColor clearColor] CGColor];
    synchronizedLayer.drawsAsynchronously = YES;
    synchronizedLayer.edgeAntialiasingMask = YES;
    synchronizedLayer.geometryFlipped = YES;
    synchronizedLayer.masksToBounds = YES;
    synchronizedLayer.frame = self.resultTemplate.frame;
    synchronizedLayer.backgroundColor = [UIColor blackColor].CGColor;
    
    NSArray *targetViews = [self.resultTemplate.loadedNibView subviews];
    
    for(UIView *subview in targetViews) {
        [synchronizedLayer addSublayer:subview.layer];
    }
    
    CALayer *titleGroupLayer;
    UIColor *titleColor;
    
    NSMutableArray *photoViewLayers = [NSMutableArray array];
    NSMutableArray *flatViewLayers = [NSMutableArray array];
    NSMutableArray *otherViewLayers = [NSMutableArray array];
    
    NSSortDescriptor *tagDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tag" ascending:YES];
    targetViews = [targetViews sortedArrayUsingDescriptors:[NSArray arrayWithObject:tagDescriptor]];
    
    for(int i = 1 ; i < targetViews.count ; i++) {
        UIView *targetView = (UIView *)[targetViews objectAtIndex:i];
        
        if(targetView.hidden == NO) {
            if([targetView isKindOfClass:[PTextGroupView class]]) {
                PTextGroupView *textGroupView = (PTextGroupView *)targetView;
                for(id subItem in [textGroupView subviews]) {
                    UIView *subView = (UIView *)subItem;
                    subView.layer.geometryFlipped = YES;
                    
                    if([subItem isKindOfClass:[PUILabel class]]) {
                        PUILabel *label = (PUILabel *)subItem;
                        
                        if([label.textType isEqualToString:@"title"]) {
                            titleGroupLayer = textGroupView.layer;
                            titleColor = label.textColor;
                        } else if([label.textType isEqualToString:@"subtitle"]) {
                            if(titleGroupLayer == nil) {
                                titleGroupLayer = textGroupView.layer;
                                titleColor = label.textColor;
                            }
                        }
                    }
                }
                [otherViewLayers addObject:textGroupView.layer];
                // 1차에서는 타이틀 애니메이션 제외
                /*
                if(titleGroupLayer != textGroupView.layer) {
                    
                    [otherViewLayers addObject:textGroupView.layer];
                }
                */
                //targetView.layer.geometryFlipped = YES;
                
            } else if([targetView isKindOfClass:[PPhotoView class]]) {
                
                [photoViewLayers addObject:targetView.layer];
                
            } else if([targetView isKindOfClass:[PFlatView class]]) {
                
                [flatViewLayers addObject:targetView.layer];
                
            } else {
                [otherViewLayers addObject:targetView.layer];
            }
        }
        
    }
    
    CABasicAnimation *in_opacityAnimation;
    CABasicAnimation *out_opacityAnimation;
    CABasicAnimation *in_opacityAnimation2;
    CABasicAnimation *positionAnimation;
    CABasicAnimation *scaleAnimation;
    
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithControlPoints:.25 :.0 :.0 :1];
    timingFunction = [CAMediaTimingFunction functionWithControlPoints:.5 :.0 :.0 :1];
    
    CAMediaTimingFunction *photoFadeTimingFunction = [CAMediaTimingFunction functionWithControlPoints:.0 :.0 :.5 :1];
    
    CGFloat fadeDuration = 0.75;
    CGFloat stayDuration = 1;
    CGFloat titleDuration = (titleGroupLayer) ? 2 : 0;
    // 1차에서는 타이틀 애니메이션 제외
    titleDuration = 0;
    
    CGFloat photoDuration = 4.5;
    photoDuration = 6;
    
    CGFloat inDuration = 0.75;
    
    CGFloat photoAnimationBeginTime = inDuration + stayDuration + titleDuration;
    CGFloat photoItemDuration = photoDuration / photoViewLayers.count;
    CGFloat photoFadeDuration = 1;
    
    CGFloat positionBeginTime = (inDuration + stayDuration + titleDuration + photoDuration);
    CGFloat positionDuration = 0.85;
    
    CGFloat inBeginTime = 0.05;
    
    CALayer *targetLayer;
    CGFloat targetOpacity = 1;
    
    CGPoint targetPosition;
    CGPoint layerCenterPosition = CGPointMake(synchronizedLayer.frame.size.width / 2, synchronizedLayer.frame.size.height / 2);
  
    CGFloat zoomScale = 1;
    CGFloat photoPositionDelay = 0.06 * photoViewLayers.count;
    CGFloat photoStayDurationDelay = 0;
    for(CALayer *sublayer in photoViewLayers) {
        
        targetLayer = sublayer;
        targetOpacity = targetLayer.opacity;
        targetPosition = targetLayer.position;
        
        //targetLayer.position = layerCenterPosition;
        
        CGPoint targetInPosition = layerCenterPosition;
        if(targetLayer.cornerRadius != 0) {
            if(ceil(targetLayer.frame.size.width / 2) == ceil(targetLayer.cornerRadius)) {
                NSLog(@"targetLayer.frame : %@", NSStringFromCGRect(targetLayer.frame));
                
                CGFloat radians = radians(-135);
                CGPoint centerPoint = CGPointMake(targetLayer.frame.size.width / 2, targetLayer.frame.size.height / 2);
                
                CGFloat distance = targetLayer.frame.size.width / 2;
                
                CGPoint innerRectOrigin = CGPointMake(centerPoint.x + distance * cos(radians), centerPoint.y + distance * sin(radians));
                //NSLog(@"innerRectOrigin : %@", NSStringFromCGPoint(innerRectOrigin));
                
                radians = radians(45);
                CGSize innerRectSize = CGSizeMake((centerPoint.x + distance * cos(radians)) - innerRectOrigin.x, (centerPoint.y + distance * sin(radians)) - innerRectOrigin.y);
                
                //NSLog(@"innerRectSize : %@", NSStringFromCGSize(innerRectSize));
                
                CGRect innerRect = CGRectMake(innerRectOrigin.x, innerRectOrigin.y, innerRectSize.width, innerRectSize.height);
                
                NSLog(@"innerRect : %@", NSStringFromCGRect(innerRect));
                
                
                zoomScale = synchronizedLayer.frame.size.width / innerRect.size.width;
                if(innerRect.size.height * zoomScale < synchronizedLayer.frame.size.height) {
                    zoomScale = synchronizedLayer.frame.size.height / innerRect.size.height;
                }
                
            } else {
                zoomScale = synchronizedLayer.frame.size.width / targetLayer.frame.size.width;
                if(targetLayer.frame.size.height * zoomScale < synchronizedLayer.frame.size.height) {
                    zoomScale = synchronizedLayer.frame.size.height / targetLayer.frame.size.height;
                }
            }
        } else {
            
            
            zoomScale = synchronizedLayer.frame.size.width / targetLayer.frame.size.width;
            if(targetLayer.frame.size.height * zoomScale < synchronizedLayer.frame.size.height) {
                zoomScale = synchronizedLayer.frame.size.height / targetLayer.frame.size.height;
            }
            
            NSInteger marginWidth = round((targetLayer.frame.size.width * zoomScale) - synchronizedLayer.frame.size.width);
            NSInteger marginHeight = round((targetLayer.frame.size.height * zoomScale) - synchronizedLayer.frame.size.height);
            
            if(marginWidth > 0) {
                CGFloat randomX = (CGFloat)(arc4random() % marginWidth) - (marginWidth / 2);
                targetInPosition.x += randomX;
            }
            
            if(marginHeight > 0) {
                CGFloat randomY = (CGFloat)(arc4random() % marginHeight) - (marginHeight / 2);
                targetInPosition.y += randomY;
            }
        }
        
        out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation.beginTime = inBeginTime + stayDuration + photoStayDurationDelay;
        out_opacityAnimation.duration = fadeDuration;
        out_opacityAnimation.fillMode = kCAFillModeForwards;
        out_opacityAnimation.removedOnCompletion = NO;
        out_opacityAnimation.timingFunction = photoFadeTimingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        
        photoStayDurationDelay += 0.06;
        
        in_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation.beginTime = photoAnimationBeginTime;
        in_opacityAnimation.duration = photoFadeDuration;
        in_opacityAnimation.fillMode = kCAFillModeForwards;
        in_opacityAnimation.removedOnCompletion = NO;
        in_opacityAnimation.timingFunction = photoFadeTimingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation forKey:@"in_opacityAnimation2"];
        
        scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:zoomScale * 1.25];
        scaleAnimation.toValue = [NSNumber numberWithFloat:zoomScale];
        scaleAnimation.beginTime = photoAnimationBeginTime;
        scaleAnimation.duration = (positionBeginTime + photoPositionDelay) - photoAnimationBeginTime;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.removedOnCompletion = NO;
        scaleAnimation.timingFunction = photoFadeTimingFunction;
        
        [targetLayer addAnimation:scaleAnimation forKey:@"in_scaleAnimation"];
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:targetLayer.position];
        positionAnimation.toValue = [NSValue valueWithCGPoint:layerCenterPosition];
        positionAnimation.beginTime = photoAnimationBeginTime - 0.001;
        positionAnimation.duration = 0.001;
        positionAnimation.fillMode = kCAFillModeForwards;
        positionAnimation.removedOnCompletion = NO;
        positionAnimation.timingFunction = photoFadeTimingFunction;
        
        [targetLayer addAnimation:positionAnimation forKey:@"stay_positionAnimation"];
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:targetInPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:layerCenterPosition];
        positionAnimation.beginTime = photoAnimationBeginTime;
        positionAnimation.duration = (positionBeginTime + photoPositionDelay) - photoAnimationBeginTime;
        positionAnimation.fillMode = kCAFillModeForwards;
        positionAnimation.removedOnCompletion = NO;
        positionAnimation.timingFunction = photoFadeTimingFunction;
        
        [targetLayer addAnimation:positionAnimation forKey:@"in_positionAnimation"];
        
        scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:zoomScale];
        scaleAnimation.toValue = [NSNumber numberWithFloat:1];
        scaleAnimation.beginTime = positionBeginTime + photoPositionDelay;
        scaleAnimation.duration = positionDuration;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.removedOnCompletion = NO;
        scaleAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:layerCenterPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:targetPosition];
        positionAnimation.beginTime = positionBeginTime + photoPositionDelay;
        positionAnimation.duration = positionDuration;
        positionAnimation.fillMode = kCAFillModeForwards;
        positionAnimation.removedOnCompletion = NO;
        positionAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:positionAnimation forKey:@"positionAnimation"];
        
        
        photoAnimationBeginTime += photoItemDuration;
        photoPositionDelay -= 0.06;
    }
    
    CGFloat flatAnimationBeginTime = positionBeginTime + positionDuration;
    CGFloat flatAnimationDelay = 0;
    for(CALayer *sublayer in flatViewLayers) {
        
        targetLayer = sublayer;
        targetOpacity = targetLayer.opacity;
        
        out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation.beginTime = inBeginTime + stayDuration;
        out_opacityAnimation.duration = fadeDuration;
        out_opacityAnimation.fillMode = kCAFillModeForwards;
        out_opacityAnimation.removedOnCompletion = NO;
        out_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        
        flatAnimationDelay += 0.15;
        
        in_opacityAnimation2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation2.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation2.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation2.beginTime = flatAnimationBeginTime;
        in_opacityAnimation2.duration = fadeDuration;
        in_opacityAnimation2.fillMode = kCAFillModeForwards;
        in_opacityAnimation2.removedOnCompletion = NO;
        in_opacityAnimation2.timingFunction = timingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation2 forKey:@"in_opacityAnimation2"];
        
        flatAnimationBeginTime += 0.2;
    }
    
    CGFloat otherAnimationBeginTime = positionBeginTime + positionDuration;
    CGFloat otherAnimationDelay = 0;
    for(CALayer *sublayer in otherViewLayers) {
        targetLayer = sublayer;
        targetOpacity = targetLayer.opacity;
        
        out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation.beginTime = inBeginTime + stayDuration;
        out_opacityAnimation.duration = fadeDuration;
        out_opacityAnimation.fillMode = kCAFillModeForwards;
        out_opacityAnimation.removedOnCompletion = NO;
        out_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        
        otherAnimationDelay += 0.15;
        
        in_opacityAnimation2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation2.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation2.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation2.beginTime = otherAnimationBeginTime;
        in_opacityAnimation2.duration = fadeDuration;
        in_opacityAnimation2.fillMode = kCAFillModeForwards;
        in_opacityAnimation2.removedOnCompletion = NO;
        in_opacityAnimation2.timingFunction = timingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation2 forKey:@"in_opacityAnimation2"];
        
        otherAnimationBeginTime += 0.2;
    }
    
    return synchronizedLayer;
    
}


- (CALayer *)buildSynchronizedLayerWithVideoSize3:(CGSize)videoSize
{
    CALayer *synchronizedLayer = [CALayer layer];
    synchronizedLayer.backgroundColor = [[UIColor clearColor] CGColor];
    synchronizedLayer.drawsAsynchronously = YES;
    synchronizedLayer.edgeAntialiasingMask = YES;
    synchronizedLayer.geometryFlipped = YES;
    synchronizedLayer.masksToBounds = YES;
    synchronizedLayer.frame = CGRectMake(0 , 0, CGRectGetWidth(self.resultTemplate.frame), CGRectGetHeight(self.resultTemplate.frame));
    synchronizedLayer.backgroundColor = [UIColor blackColor].CGColor;
    
    NSArray *targetViews = [self.resultTemplate.loadedNibView subviews];
    
    for(UIView *subview in targetViews) {
        [synchronizedLayer addSublayer:subview.layer];
    }
    
    CALayer *titleGroupLayer;
    CALayer *coverImageLayer;
    UIColor *titleColor;
    
    NSMutableArray *photoViewLayers = [NSMutableArray array];
    NSMutableArray *flatViewLayers = [NSMutableArray array];
    NSMutableArray *otherViewLayers = [NSMutableArray array];
    
    NSSortDescriptor *tagDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tag" ascending:YES];
    targetViews = [targetViews sortedArrayUsingDescriptors:[NSArray arrayWithObject:tagDescriptor]];
    
    for(int i = 1 ; i < targetViews.count ; i++) {
        UIView *targetView = (UIView *)[targetViews objectAtIndex:i];
        
        if(targetView.hidden == NO) {
            if([targetView isKindOfClass:[PTextGroupView class]]) {
                PTextGroupView *textGroupView = (PTextGroupView *)targetView;
                for(id subItem in [textGroupView subviews]) {
                    UIView *subView = (UIView *)subItem;
                    subView.layer.geometryFlipped = YES;
                    
                    if([subItem isKindOfClass:[PUILabel class]]) {
                        PUILabel *label = (PUILabel *)subItem;
                        
                        if([label.textType isEqualToString:@"title"]) {
                            titleGroupLayer = textGroupView.layer;
                            titleColor = label.textColor;
                        } else if([label.textType isEqualToString:@"subtitle"]) {
                            if(titleGroupLayer == nil) {
                                titleGroupLayer = textGroupView.layer;
                                titleColor = label.textColor;
                            }
                        }
                    }
                }
                [otherViewLayers addObject:textGroupView.layer];
                
                if(titleGroupLayer != textGroupView.layer) {
                    [otherViewLayers addObject:textGroupView.layer];
                }
                
            } else if([targetView isKindOfClass:[PCoverImageView class]]) {
                NSLog(@"coverImageLayer");
                coverImageLayer = targetView.layer;
                
            } else if([targetView isKindOfClass:[PPhotoView class]]) {
                
                PPhotoView *photoView = (PPhotoView *)targetView;
                if(photoView.photoImage.size.width > 2048 || photoView.photoImage.size.height > 2048) {
                    UIImage *scaleImage = [photoView.photoImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(2048, 2048) interpolationQuality:1];
                    
                    [photoView replacePhotoImage:scaleImage];
                    NSLog(@"scaleImage : %@", NSStringFromCGSize(scaleImage.size));
                }
                
                
                [photoViewLayers addObject:targetView.layer];
                
            } else if([targetView isKindOfClass:[PFlatView class]]) {
                
                [flatViewLayers addObject:targetView.layer];
                
            } else {
                [otherViewLayers addObject:targetView.layer];
            }
        }
        
    }
    
    CABasicAnimation *in_opacityAnimation;
    CABasicAnimation *out_opacityAnimation;
    CABasicAnimation *positionAnimation;
    CABasicAnimation *scaleAnimation;
    CABasicAnimation *transformAnimation;
    
    CAMediaTimingFunction *inTimingFunction = [CAMediaTimingFunction functionWithControlPoints:.8 :.0 :.7 :.7];
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithControlPoints:.45 :.0 :.1 :1.0];
    CAMediaTimingFunction *positionTimingFunction = [CAMediaTimingFunction functionWithControlPoints:.45 :0 :.2 :1.0];
    CAMediaTimingFunction *photoFadeTimingFunction = [CAMediaTimingFunction functionWithControlPoints:.0 :.0 :.5 :1.0];
    
    CGFloat fadeDuration = 0.75;
    
    CGFloat stayDuration = 2;
    CGFloat stayOutDuration = 0.9;
    CGFloat titleDuration = 0;
    
    CGFloat photoDuration = 4.5;
    photoDuration = 7.5;
    
    CGFloat photoAnimationBeginTime = stayDuration + stayOutDuration + (0.25) + titleDuration;
    CGFloat photoItemDuration = photoDuration / photoViewLayers.count;
    CGFloat photoFadeDuration = 1;
    
    CGFloat positionBeginTime = (stayDuration + stayOutDuration + (0.25) + titleDuration + photoDuration);
    CGFloat positionDuration = 0.9;
    
    CGFloat inBeginTime = 0.05;
    
    CALayer *targetLayer;
    CGFloat targetOpacity = 1;
    
    CGPoint targetPosition;
    CGPoint layerCenterPosition = CGPointMake(synchronizedLayer.frame.size.width / 2, synchronizedLayer.frame.size.height / 2);
    
    
    if(titleGroupLayer) {
        
        targetLayer = titleGroupLayer;
        targetOpacity = targetLayer.opacity;
        targetPosition = targetLayer.position;
        
        CATransform3D targetTransform = targetLayer.transform;
        
        CGFloat translationScale = targetLayer.frame.size.width / 5;
        CGFloat translationX = (CGFloat)(arc4random() % (NSInteger)translationScale) - (translationScale/2);
        CATransform3D outTransform;
        if(arc4random() % 2 == 1) {
            outTransform = CATransform3DTranslate(targetTransform, 0, translationX, 0);
        } else {
            outTransform = CATransform3DTranslate(targetTransform, translationX, 0, 0);
        }
        
        CGFloat scaleValue = (CGFloat)((arc4random() % 15) + 85) * 0.01;
        CATransform3D inTransform = CATransform3DScale(targetLayer.transform, scaleValue, scaleValue, 1);
        
        transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:targetLayer.transform];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:inTransform];
        transformAnimation.beginTime = inBeginTime + stayDuration;
        transformAnimation.duration = stayOutDuration + 0.25;
        transformAnimation.fillMode = kCAFillModeForwards;
        transformAnimation.removedOnCompletion = NO;
        transformAnimation.timingFunction = inTimingFunction;
        
        [targetLayer addAnimation:transformAnimation forKey:@"out_transformAnimation"];
        
        out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation.beginTime = inBeginTime + stayDuration;
        out_opacityAnimation.duration = stayOutDuration + 0.25;
        out_opacityAnimation.fillMode = kCAFillModeForwards;
        out_opacityAnimation.removedOnCompletion = NO;
        out_opacityAnimation.timingFunction = inTimingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        
        transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:outTransform];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:targetLayer.transform];
        transformAnimation.beginTime = positionBeginTime + positionDuration;
        transformAnimation.duration = fadeDuration;
        transformAnimation.fillMode = kCAFillModeForwards;
        transformAnimation.removedOnCompletion = NO;
        transformAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:transformAnimation forKey:@"in_transformAnimation"];
        
        in_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation.beginTime = positionBeginTime + positionDuration;
        in_opacityAnimation.duration = fadeDuration;
        in_opacityAnimation.fillMode = kCAFillModeForwards;
        in_opacityAnimation.removedOnCompletion = NO;
        in_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation forKey:@"in_opacityAnimation"];
        
    }
    
    if(coverImageLayer) {
        
        targetLayer = coverImageLayer;
        targetOpacity = targetLayer.opacity;
        targetPosition = targetLayer.position;
        
        out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation.beginTime = inBeginTime + stayDuration + (stayOutDuration / 2);
        out_opacityAnimation.duration = stayOutDuration;
        out_opacityAnimation.fillMode = kCAFillModeForwards;
        out_opacityAnimation.removedOnCompletion = NO;
        out_opacityAnimation.timingFunction = inTimingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        
        in_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation.beginTime = positionBeginTime - fadeDuration;
        in_opacityAnimation.duration = fadeDuration;
        in_opacityAnimation.fillMode = kCAFillModeForwards;
        in_opacityAnimation.removedOnCompletion = NO;
        in_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation forKey:@"in_opacityAnimation"];
    }
    
    CGFloat zoomScale = 1;
    CGFloat photoPositionDelay = 0.06 * photoViewLayers.count;
    CGFloat photoStayDurationDelay = 0;
    for(CALayer *sublayer in photoViewLayers) {
        
        targetLayer = sublayer;
        targetOpacity = targetLayer.opacity;
        targetPosition = targetLayer.position;
        
        CGPoint targetInPosition = layerCenterPosition;
        if(targetLayer.cornerRadius != 0) {
            if(ceil(targetLayer.frame.size.width / 2) == ceil(targetLayer.cornerRadius)) {
                
                CGFloat radians = radians(-135);
                CGPoint centerPoint = CGPointMake(targetLayer.frame.size.width / 2, targetLayer.frame.size.height / 2);
                
                CGFloat distance = targetLayer.frame.size.width / 2;
                
                CGPoint innerRectOrigin = CGPointMake(centerPoint.x + distance * cos(radians), centerPoint.y + distance * sin(radians));
                
                radians = radians(45);
                CGSize innerRectSize = CGSizeMake((centerPoint.x + distance * cos(radians)) - innerRectOrigin.x, (centerPoint.y + distance * sin(radians)) - innerRectOrigin.y);
                
                CGRect innerRect = CGRectMake(innerRectOrigin.x, innerRectOrigin.y, innerRectSize.width, innerRectSize.height);
                
                zoomScale = synchronizedLayer.frame.size.width / innerRect.size.width;
                if(innerRect.size.height * zoomScale < synchronizedLayer.frame.size.height) {
                    zoomScale = synchronizedLayer.frame.size.height / innerRect.size.height;
                }
                
            } else {
                zoomScale = synchronizedLayer.frame.size.width / targetLayer.frame.size.width;
                if(targetLayer.frame.size.height * zoomScale < synchronizedLayer.frame.size.height) {
                    zoomScale = synchronizedLayer.frame.size.height / targetLayer.frame.size.height;
                }
            }
        } else {
            
            
            zoomScale = synchronizedLayer.frame.size.width / targetLayer.frame.size.width;
            if(targetLayer.frame.size.height * zoomScale < synchronizedLayer.frame.size.height) {
                zoomScale = synchronizedLayer.frame.size.height / targetLayer.frame.size.height;
            }
            
            NSInteger marginWidth = round((targetLayer.frame.size.width * zoomScale) - synchronizedLayer.frame.size.width);
            NSInteger marginHeight = round((targetLayer.frame.size.height * zoomScale) - synchronizedLayer.frame.size.height);
            
            if(marginWidth > 0) {
                CGFloat randomX = (CGFloat)(arc4random() % marginWidth) - (marginWidth / 2);
                targetInPosition.x += randomX;
            }
            
            if(marginHeight > 0) {
                CGFloat randomY = (CGFloat)(arc4random() % marginHeight) - (marginHeight / 2);
                targetInPosition.y += randomY;
            }
        }
        
        
        photoStayDurationDelay = (CGFloat)(arc4random() % 100) * 0.0025;
        
        out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation.beginTime = inBeginTime + stayDuration + photoStayDurationDelay;
        out_opacityAnimation.duration = stayOutDuration;
        out_opacityAnimation.fillMode = kCAFillModeForwards;
        out_opacityAnimation.removedOnCompletion = NO;
        out_opacityAnimation.timingFunction = inTimingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        
        in_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation.beginTime = photoAnimationBeginTime;
        in_opacityAnimation.duration = photoFadeDuration;
        in_opacityAnimation.fillMode = kCAFillModeForwards;
        in_opacityAnimation.removedOnCompletion = NO;
        in_opacityAnimation.timingFunction = photoFadeTimingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation forKey:@"in_opacityAnimation2"];
        
        scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:zoomScale * 1.25];
        scaleAnimation.toValue = [NSNumber numberWithFloat:zoomScale];
        scaleAnimation.beginTime = photoAnimationBeginTime;
        scaleAnimation.duration = (positionBeginTime + photoPositionDelay) - photoAnimationBeginTime;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.removedOnCompletion = NO;
        scaleAnimation.timingFunction = photoFadeTimingFunction;
        
        [targetLayer addAnimation:scaleAnimation forKey:@"in_scaleAnimation"];
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:targetLayer.position];
        positionAnimation.toValue = [NSValue valueWithCGPoint:layerCenterPosition];
        positionAnimation.beginTime = photoAnimationBeginTime - 0.001;
        positionAnimation.duration = 0.001;
        positionAnimation.fillMode = kCAFillModeForwards;
        positionAnimation.removedOnCompletion = NO;
        positionAnimation.timingFunction = photoFadeTimingFunction;
        
        [targetLayer addAnimation:positionAnimation forKey:@"stay_positionAnimation"];
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:targetInPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:layerCenterPosition];
        positionAnimation.beginTime = photoAnimationBeginTime;
        positionAnimation.duration = (positionBeginTime + photoPositionDelay) - photoAnimationBeginTime;
        positionAnimation.fillMode = kCAFillModeForwards;
        positionAnimation.removedOnCompletion = NO;
        positionAnimation.timingFunction = photoFadeTimingFunction;
        
        [targetLayer addAnimation:positionAnimation forKey:@"in_positionAnimation"];
        
        scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:zoomScale];
        scaleAnimation.toValue = [NSNumber numberWithFloat:1];
        scaleAnimation.beginTime = positionBeginTime + photoPositionDelay;
        scaleAnimation.duration = positionDuration;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.removedOnCompletion = NO;
        scaleAnimation.timingFunction = positionTimingFunction;
        
        [targetLayer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:layerCenterPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:targetPosition];
        positionAnimation.beginTime = positionBeginTime + photoPositionDelay;
        positionAnimation.duration = positionDuration;
        positionAnimation.fillMode = kCAFillModeForwards;
        positionAnimation.removedOnCompletion = NO;
        positionAnimation.timingFunction = positionTimingFunction;
        
        [targetLayer addAnimation:positionAnimation forKey:@"positionAnimation"];
        
        
        photoAnimationBeginTime += photoItemDuration;
        photoPositionDelay -= 0.06;
    }
    
    CGFloat flatAnimationBeginTime = positionBeginTime + positionDuration;
    CGFloat flatAnimationDelay = -0.05;
    for(CALayer *sublayer in flatViewLayers) {
        targetLayer = sublayer;
        targetOpacity = targetLayer.opacity;
        targetPosition = targetLayer.position;
        
        CATransform3D targetTransform = targetLayer.transform;
        CATransform3D outTransform = CATransform3DTranslate(targetTransform, 0, 0, 0);
        CGFloat scaleValue;
        
        if(targetLayer.frame.size.width > targetLayer.frame.size.height * 2 || targetLayer.frame.size.width * 2 < targetLayer.frame.size.height) {
            // Line 인 경우
            scaleValue = (CGFloat)((arc4random() % 60) + 90) * 0.01;
            if(arc4random() % 2 == 1) {
                outTransform = CATransform3DScale(outTransform, scaleValue, 1, 1);
            } else {
                outTransform = CATransform3DScale(outTransform, 1, scaleValue, 1);
            }
        } else {
            scaleValue = (CGFloat)((arc4random() % 15) + 85) * 0.01;
            // Shape 인 경우
            outTransform = CATransform3DScale(outTransform, scaleValue, scaleValue, 1);
        }
        
        scaleValue = (CGFloat)((arc4random() % 15) + 85) * 0.01;
        CATransform3D inTransform = CATransform3DScale(targetLayer.transform, scaleValue, scaleValue, 1);
        
        flatAnimationDelay = (CGFloat)(arc4random() % 100) * 0.0025;
        
        transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:targetLayer.transform];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:inTransform];
        transformAnimation.beginTime = inBeginTime + stayDuration + flatAnimationDelay;
        transformAnimation.duration = stayOutDuration;
        transformAnimation.fillMode = kCAFillModeForwards;
        transformAnimation.removedOnCompletion = NO;
        transformAnimation.timingFunction = inTimingFunction;
        
        [targetLayer addAnimation:transformAnimation forKey:@"out_transformAnimation"];
        
        out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation.beginTime = inBeginTime + stayDuration + flatAnimationDelay;
        out_opacityAnimation.duration = stayOutDuration;
        out_opacityAnimation.fillMode = kCAFillModeForwards;
        out_opacityAnimation.removedOnCompletion = NO;
        out_opacityAnimation.timingFunction = inTimingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        
        transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:outTransform];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:targetLayer.transform];
        transformAnimation.beginTime = flatAnimationBeginTime;
        transformAnimation.duration = fadeDuration;
        transformAnimation.fillMode = kCAFillModeForwards;
        transformAnimation.removedOnCompletion = NO;
        transformAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:transformAnimation forKey:@"in_transformAnimation"];
        
        in_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation.beginTime = flatAnimationBeginTime;
        in_opacityAnimation.duration = fadeDuration;
        in_opacityAnimation.fillMode = kCAFillModeForwards;
        in_opacityAnimation.removedOnCompletion = NO;
        in_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation forKey:@"in_opacityAnimation"];
        
        flatAnimationBeginTime += 0.1;
    }
    
    CGFloat otherAnimationBeginTime = positionBeginTime + positionDuration;
    CGFloat otherAnimationDelay = 0;
    for(CALayer *sublayer in otherViewLayers) {
        targetLayer = sublayer;
        targetOpacity = targetLayer.opacity;
        targetPosition = targetLayer.position;
        
        CATransform3D targetTransform = targetLayer.transform;
        CGFloat translationScale = targetLayer.frame.size.width / 7;
        CGFloat translationX = (CGFloat)(arc4random() % (NSInteger)translationScale) - (translationScale/2);
        
        CATransform3D outTransform;
        if(arc4random() % 2 == 1) {
            outTransform = CATransform3DTranslate(targetTransform, 0, translationX, 0);
        } else {
            outTransform = CATransform3DTranslate(targetTransform, translationX, 0, 0);
        }
        
        CGFloat scaleValue = (CGFloat)((arc4random() % 15) + 85) * 0.01;
        CATransform3D inTransform = CATransform3DScale(targetLayer.transform, scaleValue, scaleValue, 1);
        
        transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:targetLayer.transform];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:inTransform];
        transformAnimation.beginTime = inBeginTime + stayDuration + otherAnimationDelay;
        transformAnimation.duration = stayOutDuration;
        transformAnimation.fillMode = kCAFillModeForwards;
        transformAnimation.removedOnCompletion = NO;
        transformAnimation.timingFunction = inTimingFunction;
        
        [targetLayer addAnimation:transformAnimation forKey:@"out_transformAnimation"];
        
        out_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        out_opacityAnimation.fromValue = [NSNumber numberWithFloat:targetOpacity];
        out_opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        out_opacityAnimation.beginTime = inBeginTime + stayDuration + otherAnimationDelay;
        out_opacityAnimation.duration = stayOutDuration;
        out_opacityAnimation.fillMode = kCAFillModeForwards;
        out_opacityAnimation.removedOnCompletion = NO;
        out_opacityAnimation.timingFunction = inTimingFunction;
        
        [targetLayer addAnimation:out_opacityAnimation forKey:@"out_opacityAnimation"];
        
        otherAnimationDelay -= 0.05;
        
        transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:outTransform];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:targetLayer.transform];
        transformAnimation.beginTime = otherAnimationBeginTime;
        transformAnimation.duration = fadeDuration;
        transformAnimation.fillMode = kCAFillModeForwards;
        transformAnimation.removedOnCompletion = NO;
        transformAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:transformAnimation forKey:@"in_transformAnimation"];
        
        in_opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        in_opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
        in_opacityAnimation.toValue = [NSNumber numberWithFloat:targetOpacity];
        in_opacityAnimation.beginTime = otherAnimationBeginTime;
        in_opacityAnimation.duration = fadeDuration;
        in_opacityAnimation.fillMode = kCAFillModeForwards;
        in_opacityAnimation.removedOnCompletion = NO;
        in_opacityAnimation.timingFunction = timingFunction;
        
        [targetLayer addAnimation:in_opacityAnimation forKey:@"in_opacityAnimation"];
        
        otherAnimationBeginTime += 0.1;
    }
    
    return synchronizedLayer;
    
}
@end
