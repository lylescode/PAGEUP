//
//  TemplateViewController.m
//  Page
//
//  Created by CMR on 12/3/14.
//  Copyright (c) 2014 Page. All rights reserved.
//

#import "TemplateViewController.h"
#import <dispatch/dispatch.h>
#import "PTemplate.h"
#import "TemplateViewCell.h"
#import "CategoryViewCell.h"

@interface TemplateViewController ()
{
    TemplateData *templateData;
    dispatch_queue_t backgroundQueue;
    dispatch_semaphore_t backgroudQueueSignal;
    CGSize collectionViewSize;
    
    BOOL isHiddenGoTop;
}

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *squareButton;
@property (weak, nonatomic) IBOutlet UIButton *portraitButton;
@property (weak, nonatomic) IBOutlet UIButton *landscapeButton;
@property (weak, nonatomic) IBOutlet UIView *topButtonUnderlineView;
//@property (weak, nonatomic) IBOutlet UILabel *topTitleLabel;
//@property (weak, nonatomic) IBOutlet UIButton *topButton;
//@property (weak, nonatomic) IBOutlet UIButton *goTopButton;

@property (weak, nonatomic) IBOutlet UICollectionView *templateCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *templateCategoryCollectionView;
@property (weak, nonatomic) IBOutlet UIView *templateCategoryView;

- (IBAction)topButtonAction:(id)sender;
//- (IBAction)goTopButtonAction:(id)sender;
- (IBAction)randomButtonAction:(id)sender;

@property (strong, nonatomic) NSArray *templateArray;
@property (strong, nonatomic) NSString *templateSortKey;
@property (strong, nonatomic) NSString *templateCategoryKey;
//@property (strong, nonatomic) TemplateSortViewController *templateSortViewController;


@property (strong, nonatomic) NSArray *sortKeyArray;
@property (strong, nonatomic) NSArray *sortNameStringArray;


- (void)orientationChanged:(NSNotification *)notification;
- (void)hiddenTopSortBar:(BOOL)hidden;
- (void)hiddenTemplateCategoryView:(BOOL)hidden;
- (void)sortTemplateWithKey:(NSString *)sortKey;
- (void)setupVisibleTemplateWithPhotoCount:(NSInteger)photoCount;


//- (void)hiddenGoTop:(BOOL)hidden;

//- (void)presentHomeShareViewController:(BOOL)animated;
//- (void)dismissHomeShareViewController:(BOOL)animated;

@end


#define TEMPLATE_SORT_STRING_KEY @"templateSortKey"
#define TEMPLATE_CATEGORY_KEY @"templateCategoryKey"
#define TEMPLATE_SORT_TITLE_KEY @"TemplateSortTitle"

static NSString * const reuseIdentifier = @"TemplateCell";
static CGSize TemplateViewSize;

static NSString * const categoryCellReuseIdentifier = @"CategoryCell";
static CGSize CategoryViewSize;

@implementation TemplateViewController

- (id)init
{
    self = [super init];
    if (self) {
        templateData = [[TemplateData alloc] init];
        
        NSMutableArray *sortStrings = [NSMutableArray array];
        //[sortStrings addObject:@"All"];
        [sortStrings addObject:@"Square"];
        [sortStrings addObject:@"Portrait"];
        [sortStrings addObject:@"Landscape"];
        
        NSMutableArray *sortNames = [NSMutableArray array];
        //[sortNames addObject:NSLocalizedString(@"TemplateSortAll", nil)];
        [sortNames addObject:NSLocalizedString(@"TemplateSortSquare", nil)];
        [sortNames addObject:NSLocalizedString(@"TemplateSortPortrait", nil)];
        [sortNames addObject:NSLocalizedString(@"TemplateSortLandscape", nil)];
        
        /*
        for(NSString *categoryKey in templateData.categoryKeys) {
            [sortStrings addObject:categoryKey];
        }
        
        for(NSString *categoryKey in templateData.categoryKeys) {
            [sortNames addObject:NSLocalizedString(categoryKey, nil)];
        }
         */
        
        self.sortKeyArray = [NSArray arrayWithArray:sortStrings];
        self.sortNameStringArray = [NSArray arrayWithArray:sortNames];
        
        MARK;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.templateArray = nil;
    self.templateSortKey = nil;
    self.templateCategoryKey = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    backgroundQueue = dispatch_queue_create("com.template.list", NULL);
    // 동시진행되는 큐는 1개로 제한
    backgroudQueueSignal = dispatch_semaphore_create(1);
    
    
    [self.squareButton setTitle:self.sortNameStringArray[0] forState:UIControlStateNormal];
    [self.portraitButton setTitle:self.sortNameStringArray[1] forState:UIControlStateNormal];
    [self.landscapeButton setTitle:self.sortNameStringArray[2] forState:UIControlStateNormal];
    
    NSInteger sortIndex = 0;
    NSString *sortKey = self.sortKeyArray[0];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:TEMPLATE_SORT_STRING_KEY] == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:self.templateSortKey forKey:TEMPLATE_SORT_STRING_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        NSString *defaultSortKey = [[NSUserDefaults standardUserDefaults] objectForKey:TEMPLATE_SORT_STRING_KEY];
        for(NSString *key in self.sortKeyArray) {
            if([key isEqualToString:defaultSortKey]) {
                sortKey = self.sortKeyArray[sortIndex];
                break;
            }
            sortIndex++;
        }
    }
    self.templateSortKey = sortKey;
    
    
    NSString *categoryKey = templateData.categoryKeys[0];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:TEMPLATE_CATEGORY_KEY] == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:categoryKey forKey:TEMPLATE_CATEGORY_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        categoryKey = [[NSUserDefaults standardUserDefaults] objectForKey:TEMPLATE_CATEGORY_KEY];
    }
    self.templateCategoryKey = categoryKey;

    //self.topTitleLabel.attributedText = [self textKernString:[sortName uppercaseString] targetLabel:self.topTitleLabel];
    
    self.templateCollectionView.backgroundColor = [UIColor clearColor];
    self.templateCollectionView.alwaysBounceVertical = YES;
    self.templateCollectionView.showsVerticalScrollIndicator = NO;
    self.templateCollectionView.showsHorizontalScrollIndicator = NO;
    [self.templateCollectionView registerNib:[UINib nibWithNibName:@"TemplateViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:reuseIdentifier];
    
    self.templateCategoryCollectionView.backgroundColor = [UIColor clearColor];
    self.templateCategoryCollectionView.alwaysBounceHorizontal = YES;
    self.templateCategoryCollectionView.showsVerticalScrollIndicator = NO;
    self.templateCategoryCollectionView.showsHorizontalScrollIndicator = NO;
    [self.templateCategoryCollectionView registerNib:[UINib nibWithNibName:@"CategoryViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:categoryCellReuseIdentifier];
    
    
    NSInteger index = 0;
    for(NSString *categoryKey in templateData.categoryKeys) {
        if([categoryKey isEqualToString:self.templateCategoryKey]) {
            break;
        }
        index++;
    }
    NSIndexPath *categoryCellIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self.templateCategoryCollectionView selectItemAtIndexPath:categoryCellIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionLeft];

    
    self.templateCategoryView.transform = CGAffineTransformMakeTranslation(0, self.templateCategoryView.frame.size.height);
    self.topView.transform = CGAffineTransformMakeTranslation(0, -self.topView.frame.size.height);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGFloat viewWidth;
    CGSize cellSize;
    
    collectionViewSize = self.view.frame.size;
    
    if([self workInterfaceIsLandscape]) {
        viewWidth = self.view.frame.size.width - 30;
    } else {
        viewWidth = self.view.frame.size.width - 30;
    }
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        cellSize = CGSizeMake(floor(viewWidth / 2), floor(viewWidth / 2));
        
        layout.itemSize = cellSize;
        layout.minimumInteritemSpacing = 10;
        layout.minimumLineSpacing = 10;
        
    } else {
        if(self.view.frame.size.width < self.view.frame.size.height) {
            
            cellSize = CGSizeMake(floor(viewWidth / 2), floor(viewWidth / 2));
            
            layout.itemSize = cellSize;
            layout.minimumInteritemSpacing = 10;
            layout.minimumLineSpacing = 10;
            
        } else {
            
            cellSize = CGSizeMake(floor(viewWidth / 3), floor(viewWidth / 3));
            
            layout.itemSize = cellSize;
            layout.minimumInteritemSpacing = 10;
            layout.minimumLineSpacing = 10;
        }
        
    }
    [layout setSectionInset:UIEdgeInsetsMake(0, 10, 0, 10)];
    [self.templateCollectionView setCollectionViewLayout:layout];
    
    UIEdgeInsets currentInsets = self.templateCollectionView.contentInset;
    self.templateCollectionView.contentInset = (UIEdgeInsets){
        .top = 56,
        .bottom = 149,
        .left = currentInsets.left,
        .right = currentInsets.right
    };
    TemplateViewSize = CGSizeMake(cellSize.width, cellSize.height);
    
    
    
    cellSize = CGSizeMake(63, 79);
    
    layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = cellSize;
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    
    [layout setSectionInset:UIEdgeInsetsMake(11, 10, 0, 10)];
    [self.templateCategoryCollectionView setCollectionViewLayout:layout];
    
    currentInsets = self.templateCategoryCollectionView.contentInset;
    self.templateCategoryCollectionView.contentInset = (UIEdgeInsets){
        .top = 10,
        .bottom = 10,
        .left = currentInsets.left,
        .right = currentInsets.right
    };
    CategoryViewSize = cellSize;
    
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


- (IBAction)topButtonAction:(id)sender {
    /*
    if(!self.templateSortViewController) {
        [self presentHomeShareViewController:YES];
    } else {
        [self dismissHomeShareViewController:YES];
    }
    */
    
    if(sender == self.squareButton) {
        [self sortTemplateWithKey:self.sortKeyArray[0]];
    } else if(sender == self.portraitButton) {
        [self sortTemplateWithKey:self.sortKeyArray[1]];
    } else if(sender == self.landscapeButton) {
        [self sortTemplateWithKey:self.sortKeyArray[2]];
    }
}

/*
- (IBAction)goTopButtonAction:(id)sender {
    [self.templateCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}
*/
- (IBAction)randomButtonAction:(id)sender {
    NSInteger randomIndex = arc4random() % self.templateArray.count;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:randomIndex inSection:0];
    
    [self.templateCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    
    double delayInSeconds = 0.75;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        TemplateViewCell *cell = (TemplateViewCell *)[self.templateCollectionView cellForItemAtIndexPath:indexPath];
        
        [cell highlightAnimation];
        
    });
    
}

- (void)orientationChanged:(NSNotification *)notification
{
    /*
     디바이스를 회전할때 collectionView 가 먹통이 됨. cell 에 template 생성하는 queue 의 영향 때문인거같아서 reload 해주니 해결되긴 함
     cellForItemAtIndexPath 에서 template 생성 말고 템플릿 리스트를 관리하는 객체를 만들어서 테스트해봐야겠음.
     */
    
    if(CGSizeEqualToSize(self.view.frame.size, collectionViewSize) == NO) {
        
        
        CGFloat viewWidth;
        CGSize cellSize;
        
        if([self workInterfaceIsLandscape]) {
            viewWidth = self.view.frame.size.width - 40;
        } else {
            viewWidth = self.view.frame.size.width - 40;
        }
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            
            cellSize = CGSizeMake(floor(viewWidth / 2), floor(viewWidth / 2));
            
            layout.itemSize = cellSize;
            layout.minimumInteritemSpacing = 20;
            layout.minimumLineSpacing = 20;
            
        } else {
            if(self.view.frame.size.width < self.view.frame.size.height) {
                
                cellSize = CGSizeMake(floor(viewWidth / 2), floor(viewWidth / 2));
                
                layout.itemSize = cellSize;
                layout.minimumInteritemSpacing = 20;
                layout.minimumLineSpacing = 20;
                
            } else {
                
                cellSize = CGSizeMake(floor(viewWidth / 3), floor(viewWidth / 3));
                
                layout.itemSize = cellSize;
                layout.minimumInteritemSpacing = 10;
                layout.minimumLineSpacing = 10;
            }
            
        }
        
        TemplateViewSize = CGSizeMake(cellSize.width, cellSize.height);
        collectionViewSize = self.view.frame.size;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.templateCollectionView setCollectionViewLayout:layout];
            [self.templateCollectionView reloadData];
        });
    }
}
- (void)willActivateWork
{
    [super willActivateWork];
    if(!self.templateArray) {
        [self updateSelectedPhotos];
    }
}
- (void)activateWork
{
    [super activateWork];
    [self hiddenTopSortBar:NO];
    [self hiddenTemplateCategoryView:NO];
}
- (void)deactivateWork
{
    [super deactivateWork];
    [self hiddenTopSortBar:YES];
    [self hiddenTemplateCategoryView:YES];
}
- (void)hiddenTopSortBar:(BOOL)hidden
{
    if(hidden) {
        
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.topView.transform = CGAffineTransformMakeTranslation(0, -self.topView.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             if(finished) {
                                 
                             }
                         }];
    } else {
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.topView.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished){
                             if(finished) {
                                 
                             }
                         }];
    }
}
- (void)hiddenTemplateCategoryView:(BOOL)hidden
{
    if(hidden) {
        
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.templateCategoryView.transform = CGAffineTransformMakeTranslation(0, self.templateCategoryView.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             if(finished) {
                                 
                             }
                         }];
    } else {
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.templateCategoryView.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished){
                             if(finished) {
                                 
                             }
                         }];
    }
}
- (void)updateSelectedPhotos
{
    [self updateSort];
}

- (void)updateSort
{
    MARK;
    [self setupVisibleTemplateWithPhotoCount:self.projectResource.photoArray.count];
    self.templateCollectionView.contentOffset = (CGPoint){0, -70};
    [self.templateCollectionView reloadData];
    
    
    NSInteger sortIndex = 0;
    for(NSString *key in self.sortKeyArray) {
        if([key isEqualToString:self.templateSortKey]) {
            break;
        }
        sortIndex++;
    }
    [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if(sortIndex == 0) {
                             self.topButtonUnderlineView.center = (CGPoint) {
                                 self.squareButton.center.x,
                                 self.topButtonUnderlineView.center.y
                             };
                         } else if(sortIndex == 1) {
                             self.topButtonUnderlineView.center = (CGPoint) {
                                 self.portraitButton.center.x,
                                 self.topButtonUnderlineView.center.y
                             };
                         } else if(sortIndex == 2) {
                             self.topButtonUnderlineView.center = (CGPoint) {
                                 self.landscapeButton.center.x,
                                 self.topButtonUnderlineView.center.y
                             };
                         }
                         self.topButtonUnderlineView.alpha = 1;
                     }
                     completion:^(BOOL finished){
                     }];
    //[self hiddenGoTop:YES];
}

- (void)sortTemplateWithKey:(NSString *)sortKey
{
    self.templateSortKey = [sortKey copy];
    [[NSUserDefaults standardUserDefaults] setObject:sortKey forKey:TEMPLATE_SORT_STRING_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateSort];
}

- (void)setupVisibleTemplateWithPhotoCount:(NSInteger)photoCount
{
    NSMutableArray *allTemplates = [NSMutableArray array];
    /*
    for(NSString *categoryKey in templateData.categoryKeys) {
        NSArray *templates = [NSArray arrayWithArray:[templateData.datas objectForKey:categoryKey]];
        for(NSDictionary *template in templates) {
            if([[template objectForKey:@"PhotoViewCount"] integerValue] == photoCount) {
                [allTemplates addObject:[NSDictionary dictionaryWithDictionary:[template copy]]];
            }
        }
    }
    */
    NSLog(@"setupVisibleTemplateWithPhotoCount");
    
    BOOL isCategorySort = NO;
    
    for(NSString *categoryKey in templateData.categoryKeys) {
        if([categoryKey isEqualToString:self.templateCategoryKey]) {
            isCategorySort = YES;
            break;
        }
    }
    
    if(isCategorySort) {
        NSLog(@"self.templateCategoryKey : %@", self.templateCategoryKey);
        NSArray *templates = [NSArray arrayWithArray:[templateData.datas objectForKey:self.templateCategoryKey]];
        
        for(NSDictionary *template in templates) {
            if([[template objectForKey:@"PhotoViewCount"] integerValue] == photoCount) {
                [allTemplates addObject:[NSDictionary dictionaryWithDictionary:[template copy]]];
            }
        }
        
    } else {
        
        NSMutableArray *visibleCategoryTemplates = [NSMutableArray array];
        NSInteger templateMaxCount = 0;
        
        for(NSString *categoryKey in templateData.categoryKeys) {
            NSArray *templates = [NSArray arrayWithArray:[templateData.datas objectForKey:categoryKey]];
            NSMutableArray *visibleTemplates = [NSMutableArray array];
            
            for(NSDictionary *template in templates) {
                if([[template objectForKey:@"PhotoViewCount"] integerValue] == photoCount) {
                    [visibleTemplates addObject:[NSDictionary dictionaryWithDictionary:[template copy]]];
                }
            }
            
            templateMaxCount = MAX(templateMaxCount, visibleTemplates.count);
            [visibleCategoryTemplates addObject:[NSArray arrayWithArray:visibleTemplates]];
        }
        
        
        // 템플릿 카테고리를 a1 b1 c1 순으로 섞어주는 코드
        NSInteger templateIndex = 0;
        while (templateIndex < templateMaxCount) {
            
            for(NSArray *templates in visibleCategoryTemplates) {
                if(templateIndex < templates.count) {
                    [allTemplates addObject:templates[templateIndex]];
                }
                if(templateIndex + 1 < templates.count) {
                    [allTemplates addObject:templates[templateIndex + 1]];
                }
                if(templateIndex + 2 < templates.count) {
                    [allTemplates addObject:templates[templateIndex + 2]];
                }
            }
            templateIndex += 3;
        }
    }
    
    // Ratio Sort
    NSMutableArray *visibleTemplates = [NSMutableArray array];
    
    if([self.templateSortKey isEqualToString:@"Landscape"] ||
       [self.templateSortKey isEqualToString:@"Square"] ||
       [self.templateSortKey isEqualToString:@"Portrait"] ) {
        for(NSDictionary *template in allTemplates) {
            if([self.templateSortKey isEqualToString:[template objectForKey:@"Ratio"]]) {
                [visibleTemplates addObject:template];
            }
        }
    } else {
        visibleTemplates = allTemplates;
    }
    
    
    // RANDOM Sort
    /*
    NSUInteger count = [visibleTemplates count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSUInteger nElements = count - i;
        NSUInteger n = (arc4random() % nElements) + i;
        [visibleTemplates exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    */
    self.templateArray = [NSArray arrayWithArray:visibleTemplates];
    //[self.templateCollectionView reloadData];
}

/*
- (void)hiddenGoTop:(BOOL)hidden
{
    isHiddenGoTop = hidden;
    if(hidden) {
        
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.topView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
                             self.goTopButton.alpha = 0;
                         }
                         completion:^(BOOL finished){
                         }];
    } else {
        self.goTopButton.hidden = NO;
        
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.topView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
                             self.goTopButton.alpha = 1;
                         }
                         completion:^(BOOL finished){
                         }];
    }
    
}

- (void)presentHomeShareViewController:(BOOL)animated
{
    if(self.templateSortViewController) {
        return;
    }
    
    TemplateSortViewController *templateSortVC = [[TemplateSortViewController alloc] init];
    templateSortVC.templateSortDelegate = self;
    templateSortVC.view.frame = self.view.bounds;
    
    [self.view addSubview:templateSortVC.view];
    self.templateSortViewController = templateSortVC;
    [self.templateSortViewController currenttemplateSortKey:self.templateSortKey];
    
    [self.templateSortViewController presentViewControllerAnimated:animated
                                                     completion:nil];
    
    [self.workStepDelegate workStepViewControllerNeedDisableCommon:YES];
    
 
    [self.view bringSubviewToFront:self.topView];
    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.topView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
                     }
                     completion:^(BOOL finished){
                     }];
 
}
- (void)dismissHomeShareViewController:(BOOL)animated
{
    [self.templateSortViewController dismissViewControllerAnimated:animated
                                                     completion:^{
                                                         [self.templateSortViewController.view removeFromSuperview];
                                                         self.templateSortViewController = nil;
                                                     }];
    
    [self.workStepDelegate workStepViewControllerNeedDisableCommon:NO];
 
    if(isHiddenGoTop) {
    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.topView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
                     }
                     completion:^(BOOL finished){
                     }];
    }
 
}

*/

/*
#pragma mark TemplateSortViewControllerDelegate

- (void)templateSortViewControllerDidSelectSort:(NSString *)sortString
{
    self.templateSortKey = [sortString copy];
    
    NSInteger sortIndex = 0;
    for(NSString *sortString in self.sortKeyArray) {
        if([sortString isEqualToString:self.templateSortKey]) {
            break;
        }
        sortIndex++;
    }
    NSString *sortName = self.sortNameStringArray[sortIndex];
    
    self.topTitleLabel.attributedText = [self textKernString:[sortName uppercaseString] targetLabel:self.topTitleLabel];
    
    [[NSUserDefaults standardUserDefaults] setObject:sortString forKey:TEMPLATE_SORT_STRING_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateSort];
    
    
    double delayInSeconds = 0.35;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self dismissHomeShareViewController:YES];
    });
     
}
- (void)templateSortViewControllerDidClose
{
    [self dismissHomeShareViewController:YES];
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(collectionView == self.templateCollectionView) {
        NSInteger count = self.templateArray.count;
        return count;
    } else if(collectionView == self.templateCategoryCollectionView) {
        NSLog(@"numberOfItemsInSection : %i", (int)templateData.categoryKeys.count);
        return templateData.categoryKeys.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(collectionView == self.templateCollectionView) {
        TemplateViewCell *cell = (TemplateViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        
        //cell.layer.shouldRasterize = YES;
        //cell.layer.rasterizationScale = [UIScreen mainScreen].scale;;
        
        // Increment the cell's tag
        NSInteger currentTag = cell.tag + 1;
        cell.tag = currentTag;
        
        NSDictionary *templateDictionary = self.templateArray[indexPath.item];
        
        if(!cell.templateView) {
            /*
             BOOL isSquareTemplate = [templateDictionary[@"Ratio"] isEqualToString:@"Square"];
             CGSize specificationSize = (isSquareTemplate) ? CGSizeMake(TemplateViewSize.width * 0.8, TemplateViewSize.height * 0.8) : TemplateViewSize;
             */
            
            CGSize specificationSize = TemplateViewSize;
            /*
             PTemplate *templateView = [[PTemplate alloc] initWithFrame:CGRectMake(0, 0, specificationSize.width, specificationSize.height) templateDictionary:templateDictionary];
             templateView.userInteractionEnabled = NO;
             
             if (cell.tag == currentTag) {
             [templateView setupTemplate];
             [templateView setPhotosWithPhotoArray:self.projectResource.photoArray useThumbnail:YES];
             templateView.center = CGPointMake(TemplateViewSize.width * 0.5, TemplateViewSize.height * 0.5);
             [cell setTemplateView:templateView];
             [cell fadeAnimation];
             }
             */
            
            dispatch_async(backgroundQueue, ^(void) {
                dispatch_semaphore_wait(backgroudQueueSignal, DISPATCH_TIME_FOREVER);
                
                
                if (cell.tag == currentTag) {
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        
                        PTemplate *templateView = [[PTemplate alloc] initWithFrame:CGRectMake(0, 0, specificationSize.width, specificationSize.height) templateDictionary:templateDictionary];
                        templateView.userInteractionEnabled = NO;
                        
                        [templateView setupTemplate];
                        [templateView setPhotosWithPhotoArray:self.projectResource.photoArray useThumbnail:YES];
                        templateView.center = CGPointMake(TemplateViewSize.width * 0.5, TemplateViewSize.height * 0.5);
                        [cell setTemplateView:templateView];
                        
                        NSLog(@"templateView frame : %@", NSStringFromCGRect(templateView.frame));
                        [cell fadeAnimation];
                    });
                }
                /*
                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                 
                 });
                 */
                dispatch_semaphore_signal(backgroudQueueSignal);
                
            });
        }
        return cell;
    } else if(collectionView == self.templateCategoryCollectionView) {
        
        CategoryViewCell *cell = (CategoryViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:categoryCellReuseIdentifier forIndexPath:indexPath];
        cell.thumbnailView.image = [UIImage imageNamed:templateData.categoryImageNames[indexPath.item]];
        cell.titleLabel.text = templateData.categoryKeys[indexPath.item];
        return cell;
    }
    return nil;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == self.templateCollectionView) {
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        NSDictionary *templateDictionary = self.templateArray[indexPath.item];
        [self.templateDelegate templateViewControllerDidSelect:templateDictionary];
    } else if(collectionView == self.templateCategoryCollectionView) {
        
        CategoryViewCell *cell = (CategoryViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:categoryCellReuseIdentifier forIndexPath:indexPath];
        self.templateCategoryKey = templateData.categoryKeys[indexPath.item];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.templateCategoryKey forKey:TEMPLATE_CATEGORY_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self updateSort];
    }
    
}

#pragma mark <UIScrollViewDelegate>

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    MARK;
    [self.workStepDelegate workStepViewControllerNeedDisableScroll:YES];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    MARK;
    [self.workStepDelegate workStepViewControllerNeedDisableScroll:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /*
    if(scrollView.contentOffset.y + scrollView.contentInset.top <= 0) {
        [self hiddenGoTop:YES];
    } else {
        [self hiddenGoTop:NO];
    }
     */
}



- (NSMutableAttributedString *)textKernString:(NSString *)string targetLabel:(UILabel *)label
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:string];
    [attrStr addAttribute:NSFontAttributeName value:label.font range:NSMakeRange(0, attrStr.length)];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = label.textAlignment;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    [attrStr addAttribute:NSKernAttributeName value:[NSNumber numberWithFloat:3] range:NSMakeRange(0, attrStr.length)];
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attrStr.length)];
    
    return attrStr;
}

@end
