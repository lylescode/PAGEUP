//
//  ColorToolboardViewCell.m
//  Page
//
//  Created by CMR on 4/14/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "ColorToolboardViewCell.h"

@implementation ColorToolboardViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.borderView.layer.borderColor = self.borderView.backgroundColor.CGColor;
    self.borderView.layer.borderWidth = 5;
    self.borderView.backgroundColor = [UIColor clearColor];
    
    self.borderView.hidden = YES;
    self.borderView.alpha = 0;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        self.borderView.hidden = NO;
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.borderView.alpha = 1;
                         }
                         completion:^(BOOL finished){
                         }];
    } else {
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.borderView.alpha = 0;
                         }
                         completion:^(BOOL finished){
                         }];
    }
}

@end
