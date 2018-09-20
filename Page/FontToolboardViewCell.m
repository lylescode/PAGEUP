//
//  FontToolboardViewCell.m
//  Page
//
//  Created by CMR on 4/14/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "FontToolboardViewCell.h"

@implementation FontToolboardViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)prepareForReuse
{
    self.selected = NO;
    self.labelBackgroundView.backgroundColor = [UIColor blackColor];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.labelBackgroundView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1];
                         }
                         completion:^(BOOL finished){
                         }];
    } else {
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.labelBackgroundView.backgroundColor = [UIColor blackColor];
                         }
                         completion:^(BOOL finished){
                         }];
    }
}

@end
