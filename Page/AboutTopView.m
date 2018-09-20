//
//  AboutTopView.m
//  Page
//
//  Created by CMR on 7/13/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "AboutTopView.h"

@implementation AboutTopView
@synthesize contentsView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [[NSBundle mainBundle] loadNibNamed:@"AboutTopView" owner:self options:nil];
        }
        else {
            [[NSBundle mainBundle] loadNibNamed:@"AboutTopView_iPad" owner:self options:nil];
        }
        contentsView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:contentsView];
        
        NSLog(@"AboutTopView init");
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.clipsToBounds = YES;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[NSBundle mainBundle] loadNibNamed:@"AboutTopView" owner:self options:nil];
    }
    else {
        [[NSBundle mainBundle] loadNibNamed:@"AboutTopView_iPad" owner:self options:nil];
    }
    contentsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:contentsView];
    
    NSLog(@"AboutTopView awakeFromNib");
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
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:self.aboutLabel.text];
    [attrStr addAttribute:NSFontAttributeName value:self.aboutLabel.font range:NSMakeRange(0, attrStr.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = self.aboutLabel.textAlignment;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    [attrStr addAttribute:NSKernAttributeName value:[NSNumber numberWithInt:3] range:NSMakeRange(0, attrStr.length)];
    
    self.aboutLabel.attributedText = attrStr;
    
    attrStr = [[NSMutableAttributedString alloc] initWithString:self.descriptionLabel.text];
    [attrStr addAttribute:NSFontAttributeName value:self.descriptionLabel.font range:NSMakeRange(0, attrStr.length)];
    paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = self.descriptionLabel.textAlignment;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        paragraphStyle.minimumLineHeight = 24;
        paragraphStyle.maximumLineHeight = 24;
    }
    else {
        paragraphStyle.minimumLineHeight = 30;
        paragraphStyle.maximumLineHeight = 30;
    }
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attrStr.length)];
    
    self.descriptionLabel.attributedText = attrStr;
}
@end
