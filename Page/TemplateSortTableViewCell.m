//
//  TemplateSortTableViewCell.m
//  Page
//
//  Created by CMR on 5/14/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "TemplateSortTableViewCell.h"

@implementation TemplateSortTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.separatorInset = UIEdgeInsetsZero;
    self.backgroundColor = [UIColor colorWithRed:0.11764706 green:0.11764706 blue:0.11764706 alpha:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //[super setSelected:selected animated:animated];
    if (selected) {
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.contentView.backgroundColor = [UIColor colorWithRed:0.235 green:0.482 blue:0.992 alpha:1];
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
