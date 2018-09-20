//
//  HomeMenuViewController.m
//  Page
//
//  Created by CMR on 5/26/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "HomeMenuViewController.h"
#import "HomeMenuTableViewCell.h"

@interface HomeMenuViewController ()
{
    UITapGestureRecognizer *tapGesture;
}
@property (weak, nonatomic) IBOutlet UIView *dimmedView;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;

@property (strong, nonatomic) NSArray *itemStringArray;
@property (strong, nonatomic) NSArray *itemIconImageArray;

- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer;

@end


@implementation HomeMenuViewController

static NSString * const reuseIdentifier = @"MenuCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [super viewDidLoad];
    
    self.itemStringArray = @[
                             @"A B O U T",
                             @"S H O P",
                             @"R A T E  U S",
                             @"T E L L  A  F R I E N D"
                             ];
    
    
    self.itemIconImageArray = @[
                                [UIImage imageNamed:@"HomeSharePhotoIcon"],
                                [UIImage imageNamed:@"HomeSharePhotoIcon"],
                                [UIImage imageNamed:@"HomeSharePhotoIcon"],
                                [UIImage imageNamed:@"HomeSharePhotoIcon"]];
    
    
    self.menuTableView.backgroundColor = [UIColor blackColor];
    self.menuTableView.separatorColor = [UIColor colorWithRed:0.11764706 green:0.11764706 blue:0.11764706 alpha:1];
    self.menuTableView.scrollEnabled = NO;
    [self.menuTableView registerNib:[UINib nibWithNibName:@"HomeMenuTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:reuseIdentifier];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.dimmedView addGestureRecognizer:tapGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.itemStringArray = nil;
    self.itemIconImageArray = nil;
    [self.dimmedView removeGestureRecognizer:tapGesture];
}


- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded)
    {
        [self.homeMenuDelegate homeMenuViewControllerDidClose];
    }
}

- (void)presentViewControllerAnimated:(BOOL)animated completion:(void(^)(void))callback
{
    [presentDelegate presentWillFinish:self];
    self.view.hidden = NO;
    
    if(animated) {
        
        CGFloat animationDelay = 0;
        CGFloat duration = animationDuration;
        CGFloat damping = 1;
        CGFloat velocity = 1;
        
        self.dimmedView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                         animations:^{
                             self.dimmedView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
                         }
                         completion:^(BOOL finished){
                             
                             if(callback != nil) {
                                 callback();
                             }
                             [presentDelegate presentDidFinish:self];
                         }];
        
        self.menuTableView.transform = CGAffineTransformMakeTranslation(-self.menuTableView.frame.size.width, 0);
        [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                         animations:^{
                             self.menuTableView.transform = CGAffineTransformIdentity;
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
        CGFloat duration = animationDuration;
        CGFloat damping = 1;
        CGFloat velocity = 1;
        
        [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.menuTableView.transform = CGAffineTransformMakeTranslation(-self.menuTableView.frame.size.width, 0);
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return self.itemStringArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    HomeMenuTableViewCell *menuCell = (HomeMenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    NSLog(@"titleText : %@", self.itemStringArray[indexPath.row]);
    menuCell.titleLabel.text = self.itemStringArray[indexPath.row];
    menuCell.iconImageView.image = self.itemIconImageArray[indexPath.row];
    return menuCell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0) {
        [self.homeMenuDelegate homeMenuViewControllerDidSelectAbout];
    } else if(indexPath.row == 1) {
        [self.homeMenuDelegate homeMenuViewControllerDidSelectShop];
    } else if(indexPath.row == 2) {
        //
    } else if(indexPath.row == 3) {
        //
    }
}



@end
