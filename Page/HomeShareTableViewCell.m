//
//  HomeShareTableViewCell.m
//  Page
//
//  Created by CMR on 5/13/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "HomeShareTableViewCell.h"

@implementation HomeShareTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.separatorInset = UIEdgeInsetsZero;
    self.backgroundColor = [UIColor colorWithRed:0.11764706 green:0.11764706 blue:0.11764706 alpha:1];
}

- (void)setTitleString:(NSString *)titleString
{
    NSString *upperCaseString = [titleString uppercaseString];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:upperCaseString];
    [attrStr addAttribute:NSFontAttributeName value:self.titleLabel.font range:NSMakeRange(0, attrStr.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = self.titleLabel.textAlignment;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    [attrStr addAttribute:NSKernAttributeName value:[NSNumber numberWithInt:3] range:NSMakeRange(0, attrStr.length)];
    
    self.titleLabel.attributedText = attrStr;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //[super setSelected:selected animated:animated];
    if (selected) {
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.contentView.backgroundColor = [UIColor colorWithRed:0.11764706 green:0.11764706 blue:0.11764706 alpha:1];
                         }
                         completion:^(BOOL finished){
                         }];
    } else {
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.contentView.backgroundColor = [UIColor blackColor];
                         }
                         completion:^(BOOL finished){
                         }];
    }
    // Configure the view for the selected state
}

@end
