//
//  AboutTutorialSectionView.m
//  Page
//
//  Created by CMR on 7/13/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "AboutTutorialSectionView.h"

@implementation AboutTutorialSectionView
@synthesize contentsView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
                
        self.clipsToBounds = YES;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [[NSBundle mainBundle] loadNibNamed:@"AboutTutorialSectionView" owner:self options:nil];
        }
        else {
            [[NSBundle mainBundle] loadNibNamed:@"AboutTutorialSectionView_iPad" owner:self options:nil];
        }
        contentsView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:contentsView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.clipsToBounds = YES;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[NSBundle mainBundle] loadNibNamed:@"AboutTutorialSectionView" owner:self options:nil];
    }
    else {
        [[NSBundle mainBundle] loadNibNamed:@"AboutTutorialSectionView_iPad" owner:self options:nil];
    }
    contentsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:contentsView];
    
    NSLog(@"AboutTutorialSectionView awakeFromNib");
}

- (void)setupAboutContents
{
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(contentsView);
    NSArray *contentsView_H = [NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|[contentsView]|"
                               options:0
                               metrics:nil
                               views:viewsDictionary];
    NSArray *contentsView_V = [NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|[contentsView]|"
                               options:0
                               metrics:nil
                               views:viewsDictionary];
    
    [self addConstraints:contentsView_H];
    [self addConstraints:contentsView_V];
    
    //NSLog(@"contentsView : %@", NSStringFromCGRect(contentsView.frame));
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:self.tutorialLabel.text];
    [attrStr addAttribute:NSFontAttributeName value:self.tutorialLabel.font range:NSMakeRange(0, attrStr.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = self.tutorialLabel.textAlignment;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    [attrStr addAttribute:NSKernAttributeName value:[NSNumber numberWithInt:3] range:NSMakeRange(0, attrStr.length)];
    
    self.tutorialLabel.attributedText = attrStr;
    
}

@end
