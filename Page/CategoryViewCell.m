//
//  CategoryViewCell.m
//  Page
//
//  Created by CMR on 3/31/16.
//  Copyright © 2016 Page. All rights reserved.
//

#import "CategoryViewCell.h"

@implementation CategoryViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.highlightView.alpha = 0;
    // Initialization code
}
- (void)prepareForReuse
{
    self.highlightView.alpha = 0;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.highlightView.alpha = 0.8;
                         }
                         completion:^(BOOL finished){
                         }];
    } else {
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.highlightView.alpha = 0;
                         }
                         completion:^(BOOL finished){
                         }];
    }
}


@end
