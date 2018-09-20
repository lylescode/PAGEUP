//
//  TemplateSortViewController.m
//  Page
//
//  Created by CMR on 5/14/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "TemplateSortViewController.h"
#import "TemplateSortTableViewCell.h"
#import "TemplateData.h"

@interface TemplateSortViewController ()
{
    UITapGestureRecognizer *tapGesture;
}
@property (weak, nonatomic) IBOutlet UIView *dimmedView;
@property (weak, nonatomic) IBOutlet UITableView *sortTableView;

@property (strong, nonatomic) NSArray *sortNameStringArray;
@property (strong, nonatomic) NSArray *sortIconImageArray;

@property (strong, nonatomic) NSArray *sortStringArray;
- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer;

@end

static NSString * const reuseIdentifier = @"SortCell";

@implementation TemplateSortViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TemplateData *templateData = [[TemplateData alloc] init];
    
    NSMutableArray *sortStrings = [NSMutableArray array];
    [sortStrings addObject:@"All"];
    [sortStrings addObject:@"Landscape"];
    [sortStrings addObject:@"Square"];
    [sortStrings addObject:@"Portrait"];
    
    NSMutableArray *sortNames = [NSMutableArray array];
    [sortNames addObject:NSLocalizedString(@"TemplateSortAll", nil)];
    [sortNames addObject:NSLocalizedString(@"TemplateSortLandscape", nil)];
    [sortNames addObject:NSLocalizedString(@"TemplateSortSquare", nil)];
    [sortNames addObject:NSLocalizedString(@"TemplateSortPortrait", nil)];
    
    NSMutableArray *iconImages = [NSMutableArray array];
    [iconImages addObject:[UIImage imageNamed:@"TemplateSortAllButton"]];
    [iconImages addObject:[UIImage imageNamed:@"TemplateSortLandscapeButton"]];
    [iconImages addObject:[UIImage imageNamed:@"TemplateSortSquareButton"]];
    [iconImages addObject:[UIImage imageNamed:@"TemplateSortPortraitButton"]];
    
    for(NSString *categoryKey in templateData.categoryKeys) {
        [sortStrings addObject:categoryKey];
    }
    
    for(NSString *categoryKey in templateData.categoryKeys) {
        [sortNames addObject:NSLocalizedString(categoryKey, nil)];
    }
    
    for(NSString *categoryImageName in templateData.categoryImageNames) {
        [iconImages addObject:[UIImage imageNamed:categoryImageName]];
    }
    
    
    /*
    self.sortStringArray = @[@"All", @"Landscape", @"Square", @"Portrait"];
    
    self.sortNameStringArray = @[
                             NSLocalizedString(@"TemplateSortAll", nil),
                             NSLocalizedString(@"TemplateSortLandscape", nil),
                             NSLocalizedString(@"TemplateSortSquare", nil),
                             NSLocalizedString(@"TemplateSortPortrait", nil)
                             ];
    
    self.sortIconImageArray = @[
                                [UIImage imageNamed:@"TemplateSortAllButton"],
                                [UIImage imageNamed:@"TemplateSortLandscapeButton"],
                                [UIImage imageNamed:@"TemplateSortSquareButton"],
                                [UIImage imageNamed:@"TemplateSortPortraitButton"]];
    */
    
    self.sortStringArray = [NSArray arrayWithArray:sortStrings];
    self.sortNameStringArray = [NSArray arrayWithArray:sortNames];
    self.sortIconImageArray = [NSArray arrayWithArray:iconImages];
    
    self.sortTableView.backgroundColor = [UIColor blackColor];
    self.sortTableView.separatorColor = [UIColor colorWithRed:0.11764706 green:0.11764706 blue:0.11764706 alpha:1];
    self.sortTableView.scrollEnabled = YES;
    [self.sortTableView registerNib:[UINib nibWithNibName:@"TemplateSortTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:reuseIdentifier];
    
    [self.sortTableView sizeToFit];
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.dimmedView addGestureRecognizer:tapGesture];}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.sortStringArray = nil;
    self.sortNameStringArray = nil;
    self.sortIconImageArray = nil;
    [self.dimmedView removeGestureRecognizer:tapGesture];
}

- (void)currentTemplateSortString:(NSString *)sortString
{
    NSInteger sortStringIndex = -1;
    for(NSString *string in self.sortStringArray) {
        sortStringIndex++;
        if([string isEqualToString:sortString]) {
            break;
        }
    }
    
    NSLog(@"currentTemplateSortString : %li", (long)sortStringIndex);
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sortStringIndex inSection:0];
    [self.sortTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
}

- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded)
    {
        [self.templateSortDelegate templateSortViewControllerDidClose];
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
        
        self.sortTableView.transform = CGAffineTransformMakeTranslation(0, -(self.sortTableView.frame.origin.y + self.sortTableView.frame.size.height));
        [UIView animateWithDuration:duration delay:animationDelay usingSpringWithDamping:damping initialSpringVelocity:velocity options:animationOptions
                         animations:^{
                             self.sortTableView.transform = CGAffineTransformIdentity;
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
                             self.sortTableView.transform = CGAffineTransformMakeTranslation(0, -(self.sortTableView.frame.origin.y + self.sortTableView.frame.size.height));
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
    return self.sortNameStringArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    TemplateSortTableViewCell *sortCell = (TemplateSortTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    sortCell.titleLabel.attributedText = [self textKernString:[self.sortNameStringArray[indexPath.row] uppercaseString] targetLabel:sortCell.titleLabel];
    
    sortCell.iconImageView.image = self.sortIconImageArray[indexPath.row];
    return sortCell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *sortString = self.sortStringArray[indexPath.row];
    [self.templateSortDelegate templateSortViewControllerDidSelectSort:sortString];
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
