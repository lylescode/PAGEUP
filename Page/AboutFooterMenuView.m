//
//  AboutFooterMenuView.m
//  Page
//
//  Created by CMR on 7/13/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "AboutFooterMenuView.h"
#import <MessageUI/MessageUI.h>

@implementation AboutFooterMenuView
@synthesize contentsView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [[NSBundle mainBundle] loadNibNamed:@"AboutFooterMenuView" owner:self options:nil];
        }
        else {
            [[NSBundle mainBundle] loadNibNamed:@"AboutFooterMenuView_iPad" owner:self options:nil];
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
        [[NSBundle mainBundle] loadNibNamed:@"AboutFooterMenuView" owner:self options:nil];
    }
    else {
        [[NSBundle mainBundle] loadNibNamed:@"AboutFooterMenuView_iPad" owner:self options:nil];
    }
    contentsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:contentsView];
    
    NSLog(@"AboutFooterMenuView awakeFromNib");
}


- (IBAction)buttonAction:(id)sender {
    if(sender == self.feedbackButton) {
        [self.footerMenuDelegate aboutFooterMenuViewDidFeedbackAction];
    }
    else if(sender == self.recommendButton) {
        [self.footerMenuDelegate aboutFooterMenuViewDidRecommendAction];
    }
    else if(sender == self.rateButton) {
        [self.footerMenuDelegate aboutFooterMenuViewDidRateAction];
    }
    else if(sender == self.facebookButton) {
        NSLog(@"facebook");
        [self.footerMenuDelegate aboutFooterMenuViewDidFacebookAction];
    }
    else if(sender == self.instagramButton) {
        NSLog(@"instagram");
        [self.footerMenuDelegate aboutFooterMenuViewDidInstagramAction];
    }
    else if(sender == self.emailButton) {
        NSLog(@"email");
        [self.footerMenuDelegate aboutFooterMenuViewDidEmailAction];
    }
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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.rateButton.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
        self.rateButton.layer.borderColor = [UIColor colorWithRed:0.8745098 green:0.8745098 blue:0.8745098 alpha:1].CGColor;
        
        self.recommendButton.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
        self.recommendButton.layer.borderColor = [UIColor colorWithRed:0.8745098 green:0.8745098 blue:0.8745098 alpha:1].CGColor;
        
        self.feedbackButton.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
        self.feedbackButton.layer.borderColor = [UIColor colorWithRed:0.8745098 green:0.8745098 blue:0.8745098 alpha:1].CGColor;
    }
    [self letterSpacingStringWithLabel:self.rateLabel];
    [self letterSpacingStringWithLabel:self.recommendLabel];
    [self letterSpacingStringWithLabel:self.feedbackLabel];
}

- (void)letterSpacingStringWithLabel:(UILabel *)label
{
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:label.text];
    [attrStr addAttribute:NSFontAttributeName value:label.font range:NSMakeRange(0, attrStr.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = label.textAlignment;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    [attrStr addAttribute:NSKernAttributeName value:[NSNumber numberWithInt:3] range:NSMakeRange(0, attrStr.length)];
    
    label.attributedText = attrStr;
}

@end
