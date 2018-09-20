//
//  AboutTooltipView.m
//  Page
//
//  Created by CMR on 7/13/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "AboutTooltipView.h"

@implementation AboutTooltipView
@synthesize contentsView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;
        [[NSBundle mainBundle] loadNibNamed:@"AboutTooltipView" owner:self options:nil];
        contentsView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:contentsView];
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.clipsToBounds = YES;
    
    [[NSBundle mainBundle] loadNibNamed:@"AboutTooltipView" owner:self options:nil];
    contentsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:contentsView];
    
    NSLog(@"AboutTooltipView awakeFromNib");
}


- (IBAction)buttonAction:(id)sender {
    [self.tooltipViewDelegate aboutTooltipViewDidVideoAction:self];
}

- (void)setupAboutContents
{
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.borderLineView.hidden = YES;
    }
    else {
        self.borderLineView.hidden = NO;
    }
    
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
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:self.watchVideoLabel.text];
    [attrStr addAttribute:NSFontAttributeName value:self.watchVideoLabel.font range:NSMakeRange(0, attrStr.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = self.watchVideoLabel.textAlignment;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    [attrStr addAttribute:NSKernAttributeName value:[NSNumber numberWithInt:3] range:NSMakeRange(0, attrStr.length)];
    
    self.watchVideoLabel.attributedText = attrStr;
    
    attrStr = [[NSMutableAttributedString alloc] initWithString:self.descriptionLabel.text];
    [attrStr addAttribute:NSFontAttributeName value:self.descriptionLabel.font range:NSMakeRange(0, attrStr.length)];
    paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = self.descriptionLabel.textAlignment;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    paragraphStyle.minimumLineHeight = 24;
    paragraphStyle.maximumLineHeight = 24;
    
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attrStr.length)];
    
    self.descriptionLabel.attributedText = attrStr;
}

@end
