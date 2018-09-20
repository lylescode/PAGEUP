//
//  HomeShareViewController.m
//  Page
//
//  Created by CMR on 5/13/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "HomeShareViewController.h"
#import "HomeShareTableViewCell.h"

@interface HomeShareViewController ()
{
    UITapGestureRecognizer *tapGesture;
}
@property (weak, nonatomic) IBOutlet UIView *dimmedView;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;

//@property (strong, nonatomic) NSArray *itemStringArray;
//@property (strong, nonatomic) NSArray *itemIconImageArray;

- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer;

@end

static NSString * const reuseIdentifier = @"ShareCell";

@implementation HomeShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
    self.itemStringArray = @[
                             NSLocalizedString(@"Share Photo", nil),
                             NSLocalizedString(@"Share Video", nil),
                             NSLocalizedString(@"Share PDF", nil)
                             ];
    
    self.itemIconImageArray = @[
                                [UIImage imageNamed:@"SharePhotoButton"],
                                [UIImage imageNamed:@"ShareVideoButton"],
                                [UIImage imageNamed:@"SharePDFButton"]
                                ];
    
    
    self.shareTableView.backgroundColor = [UIColor blackColor];
    self.shareTableView.separatorColor = [UIColor colorWithRed:0.11764706 green:0.11764706 blue:0.11764706 alpha:1];
    self.shareTableView.scrollEnabled = NO;
    [self.shareTableView registerNib:[UINib nibWithNibName:@"HomeShareTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:reuseIdentifier];
    */
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.dimmedView addGestureRecognizer:tapGesture];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    /*
    self.itemStringArray = nil;
    self.itemIconImageArray = nil;
     */
    [self.dimmedView removeGestureRecognizer:tapGesture];
}

- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded)
    {
        [self.homeShareDelegate homeShareViewControllerDidClose];
    }
}

- (void)completeShare
{
    //[self.shareTableView deselectRowAtIndexPath:[self.shareTableView indexPathForSelectedRow] animated:YES];
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
                             self.dimmedView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.85];
                         }
                         completion:^(BOOL finished){
                             
                             if(callback != nil) {
                                 callback();
                             }
                             [presentDelegate presentDidFinish:self];
                         }];
        
        self.bottomBar.transform = CGAffineTransformMakeTranslation(0, self.bottomBar.frame.size.height);
        [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                         animations:^{
                             self.bottomBar.transform = CGAffineTransformIdentity;
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
                             self.bottomBar.transform = CGAffineTransformMakeTranslation(0, self.bottomBar.frame.size.height);
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
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return self.itemStringArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    HomeShareTableViewCell *shareCell = (HomeShareTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    [shareCell setTitleString:self.itemStringArray[indexPath.row]];
    shareCell.iconImageView.image = self.itemIconImageArray[indexPath.row];
    return shareCell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0) {
        [self.homeShareDelegate homeShareViewControllerDidSelectSharePhoto];
    } else if(indexPath.row == 1) {
        [self.homeShareDelegate homeShareViewControllerDidSelectShareVideo];
        [self.shareTableView deselectRowAtIndexPath:[self.shareTableView indexPathForSelectedRow] animated:YES];
    } else if(indexPath.row == 2) {
        [self.homeShareDelegate homeShareViewControllerDidSelectSharePDF];
    }
    
    
}
*/


@end
