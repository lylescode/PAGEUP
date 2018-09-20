//
//  AllAlbumsTableViewCell.m
//  Page
//
//  Created by CMR on 5/15/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "AllAlbumsTableViewCell.h"

@implementation AllAlbumsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.separatorInset = UIEdgeInsetsZero;
    self.backgroundColor = [UIColor whiteColor];//[UIColor colorWithRed:0.11764706 green:0.11764706 blue:0.11764706 alpha:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //[super setSelected:selected animated:animated];
    if (selected) {
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.contentView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
                         }
                         completion:^(BOOL finished){
                         }];
    } else {
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.contentView.backgroundColor = [UIColor whiteColor];
                         }
                         completion:^(BOOL finished){
                         }];
    }
    // Configure the view for the selected state
}

- (void)setTitle:(NSString *)titleString countString:(NSString *)countString
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", titleString, countString]];
    
    [attrStr addAttribute:NSForegroundColorAttributeName
                 value:[UIColor blackColor]
                    range:NSMakeRange(0, titleString.length + 1)];
    
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:[UIColor colorWithRed:0.22745098 green:0.42745098 blue:0.83529412 alpha:1]
                    range:NSMakeRange(titleString.length + 1, countString.length)];
    
    self.titleLabel.attributedText = attrStr;
}

@end
