//
//  ImportViewController.m
//  Page
//
//  Created by CMR on 11/21/14.
//  Copyright (c) 2014 Page. All rights reserved.
//

#import "ImportViewController.h"

@interface ImportViewController ()
{
    //UINavigationController *navigationController;
    //AssetLibraryRootListViewController *libraryRootListViewController;
    AllPhotosViewController *allPhotosViewController;
    
    BOOL isPhotoItemDragging;
    NSInteger draggingPhotoItemFromIndex;
    
    NSTimer *draggingScrollTimer;
    NSTimer *draggingSortTimer;
    
    UITapGestureRecognizer *tapGesture;
    UIPanGestureRecognizer *panGesture;
    UILongPressGestureRecognizer *longPressGesture;
    
    id selectedThumbnailView;
    
    CGSize viewSize;
}

@property (weak, nonatomic) IBOutlet UIView *selectedPhotosView;
@property (weak, nonatomic) IBOutlet UIScrollView *selectedPhotosScrollView;
//@property (strong, nonatomic) UILabel *photoCountLabel;
@property (strong, nonatomic) NSMutableArray *backupPhotoArray;
@property (strong, nonatomic) NSMutableArray *thumbnailViewArray;

@property (weak, nonatomic) UIImageView *selectedPhotoView;

- (void)orientationChanged:(NSNotification *)notification;

- (void)createThumbnailViews;
- (void)removeThumbnailViews;
- (void)hiddenThumbnailViews:(BOOL)hidden;

- (void)addPhotoAsset:(PHAsset *)asset thumbnailImage:(UIImage *)thumbnailImage;
- (void)removePhotoAsset:(PHAsset *)asset;
- (void)removePhotoAssetWithIndex:(NSInteger)assetIndex;

- (id)photoViewAtContainsPoint:(CGPoint)point;
- (void)sortThumbnailViews;
- (void)sortThumbnailViewsForBeginDrag;
- (void)sortThumbnailViewsForDragging;
- (void)autoScrollAtBorderWithTimer:(NSTimer *)timer;

- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer;
- (void)panGesture:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)longPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer;

@end

@implementation ImportViewController

static CGSize ThumbnailViewSize;
static CGFloat ThumbnailTopMargin = 11;
static CGFloat ThumbnailLeftMargin = 0;
static CGFloat ThumbnailSpacing = 10;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    ThumbnailViewSize = CGSizeMake(63, 63);
    
    //self.selectedPhotosView.backgroundColor = [UIColor redColor];
    self.selectedPhotosView.transform = CGAffineTransformMakeTranslation(0, self.selectedPhotosView.frame.size.height);
    
    allPhotosViewController = [[AllPhotosViewController alloc] init];
    allPhotosViewController.allPhotosDelegate = self;
    allPhotosViewController.projectResource = self.projectResource;
    allPhotosViewController.view.frame = self.view.bounds;
    
    UIEdgeInsets currentInsets = allPhotosViewController.collectionView.contentInset;
    allPhotosViewController.collectionView.contentInset = (UIEdgeInsets){
        .top = 58,
        .bottom = 120,
        .left = currentInsets.left,
        .right = currentInsets.right
    };
    currentInsets = allPhotosViewController.collectionView.scrollIndicatorInsets;
    allPhotosViewController.collectionView.scrollIndicatorInsets  = (UIEdgeInsets){
        .top = 58,
        .bottom = 120,
        .left = currentInsets.left,
        .right = currentInsets.right
    };
    [self.view addSubview:allPhotosViewController.view];
    
    /*
    libraryRootListViewController = [[AssetLibraryRootListViewController alloc] init];
    libraryRootListViewController.projectResource = self.projectResource;
    libraryRootListViewController.assetLibraryRootDelegate = self;
    libraryRootListViewController.view.frame = self.view.bounds;
    
    navigationController = [[UINavigationController alloc] initWithRootViewController:libraryRootListViewController];
    navigationController.delegate = self;
    navigationController.view.frame = self.view.bounds;
    [self.view addSubview:navigationController.view];
    
    AssetGridViewController *assetGridViewController = [[AssetGridViewController alloc] initWithNibName:@"AssetGridViewController" bundle:[NSBundle mainBundle]];
    assetGridViewController.assetGridDelegate = self;
    assetGridViewController.projectResource = self.projectResource;
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO]];
    assetGridViewController.assetsFetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
    
    assetGridViewController.title = NSLocalizedString(@"All Photos", nil);
    self.currentAssetGridViewController = assetGridViewController;
    [navigationController pushViewController:assetGridViewController animated:NO];
     */
    
    //self.selectedPhotosView.backgroundColor = [UIColor blackColor];
    
    [self.view bringSubviewToFront:self.selectedPhotosView];
    
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    panGesture.delegate = self;
    longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    
    
    self.selectedPhotosScrollView.scrollEnabled = NO;
    [self.selectedPhotosScrollView addGestureRecognizer:tapGesture];
    [self.selectedPhotosScrollView addGestureRecognizer:panGesture];
    [self.selectedPhotosScrollView addGestureRecognizer:longPressGesture];
    
}
- (void)dealloc
{
    if(allPhotosViewController) {
        [allPhotosViewController.view removeFromSuperview];
    }
    if(self.backupPhotoArray) {
        [self.backupPhotoArray removeAllObjects];
        self.backupPhotoArray = nil;
    }
    
    [self.selectedPhotosScrollView removeGestureRecognizer:tapGesture];
    [self.selectedPhotosScrollView removeGestureRecognizer:panGesture];
    [self.selectedPhotosScrollView removeGestureRecognizer:longPressGesture];
    
    [self removeThumbnailViews];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    viewSize = self.view.frame.size;
}


- (void)orientationChanged:(NSNotification *)notification
{
    
    if(CGSizeEqualToSize(self.view.frame.size, viewSize) == NO) {
        
        [self sortThumbnailViews];

        viewSize = self.view.frame.size;
    }
    
    
}


- (void)activateWork
{
    [super activateWork];
    
    allPhotosViewController.projectResource = self.projectResource;
    [allPhotosViewController updateSelectedPhotos];
    
    [self createThumbnailViews];
    
    if(self.projectResource.photoArray.count > 0) {
        if(self.backupPhotoArray) {
            [self.backupPhotoArray removeAllObjects];
        }
        self.backupPhotoArray = [NSMutableArray array];
        for(PPhotoAsset *photoAsset in self.projectResource.photoArray) {
            [self.backupPhotoArray addObject:photoAsset];
        }
    }
}
- (void)deactivateWork
{
    [super deactivateWork];
    [self removeThumbnailViews];
    [self hiddenThumbnailViews:YES];
}


- (void)prepareForSaveProject
{
    [self.projectResource updatePhotoAssetDictionary];
}


- (void)createThumbnailViews
{
    [self removeThumbnailViews];
    self.thumbnailViewArray = [NSMutableArray array];
    
    //NSLog(@"self.selectedPhotosScrollView.frame : %@", NSStringFromCGRect(self.selectedPhotosScrollView.frame));
    
    CGFloat originX = ThumbnailLeftMargin;
    //CGFloat scale = [UIScreen mainScreen].scale;
    
    for(PPhotoAsset *photoAsset in self.projectResource.photoArray) {
        UIImage *photoImage = photoAsset.photoImage;
        CGRect thumbnailFrame = (CGRect){
            originX,
            ThumbnailTopMargin,
            ThumbnailViewSize.width,
            ThumbnailViewSize.height
        };
        //NSLog(@"thumbnailFrame : %@", NSStringFromCGRect(thumbnailFrame));
        
        UIImageView *thumbnailView = [[UIImageView alloc] initWithFrame:thumbnailFrame];
        thumbnailView.image = photoImage;
        thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
        thumbnailView.clipsToBounds = YES;
        thumbnailView.backgroundColor = [UIColor darkGrayColor];
        
        originX += thumbnailView.frame.size.width + ThumbnailSpacing;
        
        [self.thumbnailViewArray addObject:thumbnailView];
        [self.selectedPhotosScrollView addSubview:thumbnailView];
    }
    
    [self sortThumbnailViews];
    
    if(self.thumbnailViewArray.count > 0) {
        [self hiddenThumbnailViews:NO];
    } else {
        [self hiddenThumbnailViews:YES];
    }
}

- (void)removeThumbnailViews
{
    if(self.thumbnailViewArray) {
        
        //NSLog(@"removeThumbnailViews");
        self.selectedPhotosScrollView.contentSize = self.selectedPhotosScrollView.frame.size;
        self.selectedPhotosScrollView.contentOffset = CGPointZero;
        for(UIImageView *thumbnailView in self.thumbnailViewArray) {
            [thumbnailView removeFromSuperview];
        }
        [self.thumbnailViewArray removeAllObjects];
        self.thumbnailViewArray = nil;
    }
}



- (void)hiddenThumbnailViews:(BOOL)hidden
{
    if(hidden) {
        
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.selectedPhotosView.transform = CGAffineTransformMakeTranslation(0, self.selectedPhotosView.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             if(finished) {
                                 
                             }
                         }];
    } else {
        if(self.thumbnailViewArray.count > 0) {
            [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.selectedPhotosView.transform = CGAffineTransformIdentity;
                             }
                             completion:^(BOOL finished){
                                 if(finished) {
                                     
                                 }
                             }];
        }
    }
}

- (void)addPhotoAsset:(PHAsset *)asset thumbnailImage:(UIImage *)thumbnailImage
{
    [self.projectResource addPhotoAsset:asset thumbnailImage:thumbnailImage
                        completion:^{
                            
                            CGFloat thumbnailsWidth = (ThumbnailViewSize.width * self.thumbnailViewArray.count) + (ThumbnailSpacing * (self.thumbnailViewArray.count - 1));
                            CGFloat originX = ThumbnailLeftMargin;
                            
                            if(thumbnailsWidth < self.selectedPhotosScrollView.frame.size.width) {
                                
                                originX = ((self.selectedPhotosScrollView.frame.size.width - thumbnailsWidth) * 0.5) + ThumbnailLeftMargin;
                            }
                            
                            if(self.thumbnailViewArray.count > 0) {
                                UIImageView *lastThumbnailView = [self.thumbnailViewArray lastObject];
                                originX = lastThumbnailView.frame.origin.x + lastThumbnailView.frame.size.width + ThumbnailSpacing;
                            }
                            
                            PPhotoAsset *photoAsset = [self.projectResource.photoArray lastObject];
                            
                            UIImage *photoImage = photoAsset.thumbnailImage;
                            
                            CGRect thumbnailFrame = (CGRect){
                                originX,
                                ThumbnailTopMargin,
                                ThumbnailViewSize.width,
                                ThumbnailViewSize.height
                            };
                            
                            UIImageView *thumbnailView = [[UIImageView alloc] initWithFrame:thumbnailFrame];
                            thumbnailView.image = photoImage;
                            thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
                            thumbnailView.clipsToBounds = YES;
                            
                            [self.thumbnailViewArray addObject:thumbnailView];
                            [self.selectedPhotosScrollView addSubview:thumbnailView];
                            
                            
                            thumbnailView.alpha = 0;
                            [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                                             animations:^{
                                                 thumbnailView.alpha = 1;
                                             }
                                             completion:^(BOOL finished){
                                             }];
                            
                            [self sortThumbnailViews];
                            [self.projectResource updatePhotoAssetDictionary];
                            [self.importDelegate importViewControllerDidChangePhoto];
                            
                            [self hiddenThumbnailViews:NO];
                        }];
    
    //self.photoCountLabel.text = [NSString stringWithFormat:@"%li/%li", self.projectResource.photoArray.count, ProjectResourceMaxPhotoCount];
    
}


- (void)removePhotoAsset:(PHAsset *)asset
{
    NSInteger assetIndex = [self.projectResource indexOfPhotoAsset:asset];
    UIImageView *removeThumbnail = [self.thumbnailViewArray objectAtIndex:assetIndex];
    
    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         removeThumbnail.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         if(finished) {
                             [removeThumbnail removeFromSuperview];
                         }
                     }];
    
    [self.thumbnailViewArray removeObject:removeThumbnail];
    
    [self sortThumbnailViews];
    
    if(self.selectedPhotosScrollView.contentSize.width > self.selectedPhotosScrollView.frame.size.width) {
        [self.selectedPhotosScrollView setContentOffset:CGPointMake(self.selectedPhotosScrollView.contentSize.width - self.selectedPhotosScrollView.frame.size.width, 0) animated:YES];
    }
    
    [self.projectResource removePhotoAsset:asset];
    [self.projectResource updatePhotoAssetDictionary];
    
    if(self.thumbnailViewArray.count == 0) {
        [self hiddenThumbnailViews:YES];
    }
    
    [self.importDelegate importViewControllerDidChangePhoto];
}

- (void)removePhotoAssetWithIndex:(NSInteger)assetIndex
{
    PPhotoAsset *photoAsset = [self.projectResource.photoArray objectAtIndex:assetIndex];
    [allPhotosViewController deselectPhotoAtLocalIdentifier:photoAsset.localIdentifier];
    [self.projectResource removePhotoAssetWithIndex:assetIndex];
    [self.projectResource updatePhotoAssetDictionary];
    
    UIImageView *removeThumbnail = [self.thumbnailViewArray objectAtIndex:assetIndex];
    
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         removeThumbnail.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         if(finished) {
                             [removeThumbnail removeFromSuperview];
                             [self sortThumbnailViews];
                         }
                     }];
    
    [self.thumbnailViewArray removeObject:removeThumbnail];
    
    if(self.thumbnailViewArray.count == 0) {
        [self hiddenThumbnailViews:YES];
    }
    
    [self.importDelegate importViewControllerDidChangePhoto];
}
- (id)photoViewAtContainsPoint:(CGPoint)point
{
    for(UIImageView *thumbnailView in self.thumbnailViewArray) {
        if(CGRectContainsPoint(thumbnailView.frame, point)) {
            return thumbnailView;
        }
    }
    return nil;
}

- (void)sortThumbnailViews
{
    
    
    CGFloat thumbnailsWidth = (ThumbnailViewSize.width * self.thumbnailViewArray.count) + (ThumbnailSpacing * (self.thumbnailViewArray.count - 1));
    CGFloat originX = ThumbnailLeftMargin;
    
    BOOL positionCentered = NO;
    if(thumbnailsWidth < self.selectedPhotosScrollView.frame.size.width) {
        
        positionCentered = YES;
        originX = ((self.selectedPhotosScrollView.frame.size.width - thumbnailsWidth) * 0.5) + ThumbnailLeftMargin;
    }
    
    for(UIImageView *thumbnailView in self.thumbnailViewArray) {
        
        CGAffineTransform originalTransform = thumbnailView.transform;
        thumbnailView.transform = CGAffineTransformIdentity;;
        
        CGRect thumbnailFrame = (CGRect){
            originX,
            thumbnailView.frame.origin.y,
            thumbnailView.frame.size.width,
            thumbnailView.frame.size.height
        };
        
        thumbnailView.transform = originalTransform;
        
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             thumbnailView.transform = CGAffineTransformIdentity;
                             thumbnailView.frame = thumbnailFrame;
                             thumbnailView.alpha = 1;
                         }
                         completion:^(BOOL finished){
                         }];
        originX += thumbnailView.frame.size.width + ThumbnailSpacing;
    }
    if(positionCentered) {
        [self.selectedPhotosScrollView setContentSize:CGSizeMake(self.selectedPhotosScrollView.frame.size.width, self.selectedPhotosScrollView.frame.size.height)];
    } else {
        [self.selectedPhotosScrollView setContentSize:CGSizeMake(originX - ThumbnailViewSize.width, self.selectedPhotosScrollView.frame.size.height)];
    }
}
- (void)sortThumbnailViewsForBeginDrag
{
    CGFloat thumbnailsWidth = (ThumbnailViewSize.width * self.thumbnailViewArray.count) + (ThumbnailSpacing * (self.thumbnailViewArray.count - 1));
    CGFloat originX = ThumbnailLeftMargin;
    
    if(thumbnailsWidth < self.selectedPhotosScrollView.frame.size.width) {
        
        originX = ((self.selectedPhotosScrollView.frame.size.width - thumbnailsWidth) * 0.5) + ThumbnailLeftMargin;
    }
    
    NSInteger photoViewIndex = 0;
    for(UIImageView *thumbnailView in self.thumbnailViewArray) {
        
        if(draggingPhotoItemFromIndex != photoViewIndex) {
            
            CGAffineTransform originalTransform = thumbnailView.transform;
            thumbnailView.transform = CGAffineTransformIdentity;;
            
            CGRect thumbnailFrame = (CGRect){
                originX,
                thumbnailView.frame.origin.y,
                thumbnailView.frame.size.width,
                thumbnailView.frame.size.height
            };
            
            thumbnailView.transform = originalTransform;
            
            [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 thumbnailView.transform = CGAffineTransformIdentity;
                                 thumbnailView.frame = thumbnailFrame;
                                 thumbnailView.alpha = 1;
                             }
                             completion:^(BOOL finished){
                             }];
            
            originX += thumbnailView.frame.size.width + ThumbnailSpacing;
            
        } else {
            
            [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 thumbnailView.transform = CGAffineTransformMakeScale(1.25, 1.25);
                                 thumbnailView.alpha = 0.75;
                             }
                             completion:^(BOOL finished){
                             }];
        }
        photoViewIndex++;
    }
}
- (void)sortThumbnailViewsForDragging
{
    CGFloat thumbnailsWidth = (ThumbnailViewSize.width * self.thumbnailViewArray.count) + (ThumbnailSpacing * (self.thumbnailViewArray.count - 1));
    CGFloat originX = ThumbnailLeftMargin;
    
    if(thumbnailsWidth < self.selectedPhotosScrollView.frame.size.width) {
        
        originX = ((self.selectedPhotosScrollView.frame.size.width - thumbnailsWidth) * 0.5) + ThumbnailLeftMargin;
    }
    NSInteger photoViewIndex = 0;
    for(UIImageView *thumbnailView in self.thumbnailViewArray) {
        
        if(draggingPhotoItemFromIndex != photoViewIndex) {
            
            CGAffineTransform originalTransform = thumbnailView.transform;
            thumbnailView.transform = CGAffineTransformIdentity;;
            
            CGRect thumbnailFrame = (CGRect){
                originX,
                thumbnailView.frame.origin.y,
                thumbnailView.frame.size.width,
                thumbnailView.frame.size.height
            };
            
            if(CGRectGetMidX(thumbnailFrame) > self.selectedPhotoView.center.x) {
                thumbnailFrame.origin.x = thumbnailFrame.origin.x + 30;
            }
            
            
            thumbnailView.transform = originalTransform;
            
            [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 thumbnailView.transform = CGAffineTransformIdentity;
                                 thumbnailView.frame = thumbnailFrame;
                                 thumbnailView.alpha = 1;
                             }
                             completion:^(BOOL finished){
                             }];
            
            originX += thumbnailView.frame.size.width + ThumbnailSpacing;
        }
        photoViewIndex++;
    }
}

- (void)autoScrollAtBorderWithTimer:(NSTimer *)timer
{
    if(self.selectedPhotoView.frame.origin.x < self.selectedPhotosScrollView.contentOffset.x) {
        
        
        if(self.selectedPhotosScrollView.contentOffset.x <= 0) {
            return;
        }
        
        CGFloat speed = ABS(self.selectedPhotoView.frame.origin.x - self.selectedPhotosScrollView.contentOffset.x) * 0.1;
        
        self.selectedPhotoView.center = CGPointMake(self.selectedPhotoView.center.x - speed, self.selectedPhotoView.center.y);
        self.selectedPhotosScrollView.contentOffset = CGPointMake(self.selectedPhotosScrollView.contentOffset.x - speed, self.selectedPhotosScrollView.contentOffset.y);
        
        
    } else if(self.selectedPhotoView.frame.origin.x + self.selectedPhotoView.frame.size.width > self.selectedPhotosScrollView.contentOffset.x + self.selectedPhotosScrollView.frame.size.width) {
        
        
        CGFloat maxOffsetX = self.selectedPhotosScrollView.contentSize.width - self.selectedPhotosScrollView.frame.size.width;
        
        if(self.selectedPhotosScrollView.contentOffset.x >= maxOffsetX) {
            return;
        }
        
        CGFloat speed = ABS((self.selectedPhotoView.frame.origin.x + self.selectedPhotoView.frame.size.width) - (self.selectedPhotosScrollView.contentOffset.x + self.selectedPhotosScrollView.frame.size.width)) * 0.1;
        
        self.selectedPhotoView.center = CGPointMake(self.selectedPhotoView.center.x + speed, self.selectedPhotoView.center.y);
        self.selectedPhotosScrollView.contentOffset = CGPointMake(self.selectedPhotosScrollView.contentOffset.x + speed, self.selectedPhotosScrollView.contentOffset.y);
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        CGPoint tapPoint = [gestureRecognizer locationInView:self.selectedPhotosScrollView];
        UIImageView *tapPhotoView = (UIImageView *)[self photoViewAtContainsPoint:tapPoint];
        
        if(tapPhotoView) {
            NSInteger tapPhotoIndex = [self.thumbnailViewArray indexOfObject:tapPhotoView];
            [self removePhotoAssetWithIndex:tapPhotoIndex];
        }
        
    }
}

- (void)panGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        
        if(isPhotoItemDragging) {
            CGPoint translationPoint = [gestureRecognizer translationInView:self.selectedPhotosScrollView];
            CGPoint dragPoint = CGPointMake(self.selectedPhotoView.center.x + translationPoint.x, self.selectedPhotoView.center.y);
            self.selectedPhotoView.center = dragPoint;
            self.selectedPhotoView.transform = CGAffineTransformTranslate(self.selectedPhotoView.transform, 0, translationPoint.y);
            
            [gestureRecognizer setTranslation:CGPointZero inView:self.selectedPhotosScrollView];
            return;
        }
    }
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan){
        
        self.selectedPhotosScrollView.scrollEnabled = NO;
        
        CGPoint pressPoint = [gestureRecognizer locationInView:self.selectedPhotosScrollView];
        self.selectedPhotoView = (UIImageView *)[self photoViewAtContainsPoint:pressPoint];
        [self.selectedPhotosScrollView bringSubviewToFront:self.selectedPhotoView];
        draggingPhotoItemFromIndex = [self.thumbnailViewArray indexOfObject:self.selectedPhotoView];
        isPhotoItemDragging = YES;
        
        [self sortThumbnailViewsForBeginDrag];
        
        draggingScrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                               target:self
                                                             selector:@selector(autoScrollAtBorderWithTimer:)
                                                             userInfo:nil
                                                              repeats:YES];
        
        draggingSortTimer = [NSTimer scheduledTimerWithTimeInterval:0.25
                                                             target:self
                                                           selector:@selector(sortThumbnailViewsForDragging)
                                                           userInfo:nil
                                                            repeats:YES];
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        [draggingScrollTimer invalidate];
        [draggingSortTimer invalidate];
        
        CGPoint endedPoint = [gestureRecognizer locationInView:self.selectedPhotosScrollView];
        
        if(endedPoint.y < -30) {
            
            //TODO: 사진 내려놓는 영역이 스크롤뷰를 크게 벗어나면 사진 삭제
            [self removePhotoAssetWithIndex:draggingPhotoItemFromIndex];
            
        } else {
            
            
            NSInteger indexOfCurrentPoint = 0;
            for(UIImageView *photoView in self.thumbnailViewArray) {
                if(photoView != self.selectedPhotoView) {
                    if(photoView.center.x < endedPoint.x) {
                        indexOfCurrentPoint++;
                    }
                }
            }
            
            if(indexOfCurrentPoint != draggingPhotoItemFromIndex) {
                
                [self.thumbnailViewArray removeObjectAtIndex:draggingPhotoItemFromIndex];
                [self.thumbnailViewArray insertObject:self.selectedPhotoView atIndex:indexOfCurrentPoint];
                
                [self.projectResource movePhotoAssetAtIndex:draggingPhotoItemFromIndex toIndex:indexOfCurrentPoint];
                
                [self.importDelegate importViewControllerDidChangePhoto];
                
                [allPhotosViewController updateSelectedPhotos];
                
                NSLog(@"from : %li -> to : %li", (long)draggingPhotoItemFromIndex, (long)indexOfCurrentPoint);
            }
            
            //TODO: 사진 내려놓는 영역에 맞게 순서변경
            [self sortThumbnailViews];
            
        }
        
        self.selectedPhotosScrollView.scrollEnabled = YES;
        self.selectedPhotoView = nil;
        
        draggingPhotoItemFromIndex = -1;
        isPhotoItemDragging = NO;
        
        
    }
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - AllPhotosViewControllerDelegate

- (void)allPhotosViewControllerDidDone
{
    [self.importDelegate importViewControllerDidChangePhoto];
}

- (void)allPhotosViewControllerDidSelectPhotoAsset:(PHAsset *)asset thumbnailImage:(UIImage *)thumbnailImage
{
    [self addPhotoAsset:asset thumbnailImage:thumbnailImage];
}

- (void)allPhotosViewControllerDidDeselectPhotoAsset:(PHAsset *)asset
{
    [self removePhotoAsset:asset];
}

- (void)allPhotosViewControllerNeedDisableCommon:(BOOL)disableCommon
{
    [self.workStepDelegate workStepViewControllerNeedDisableCommon:disableCommon];
    [self hiddenThumbnailViews:disableCommon];
}


@end
