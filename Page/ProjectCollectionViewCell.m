//
//  ProjectCollectionViewCell.m
//  Page
//
//  Created by CMR on 5/6/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "ProjectCollectionViewCell.h"

@implementation ProjectCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.clipsToBounds = YES;
    
    self.borderView.hidden = YES;
    self.borderView.alpha = 0;
    
    self.borderView.layer.borderColor = self.borderView.backgroundColor.CGColor;
    //self.borderView.layer.borderWidth = 4;
    self.borderView.backgroundColor = [UIColor clearColor];
}

- (void)dealloc {
    
}

- (void)prepareForReuse
{
    self.selected = NO;
    self.previewImageView.alpha = 0;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        self.borderView.hidden = NO;
        self.borderView.transform = CGAffineTransformMakeScale(1.02, 1.02);
        [UIView animateWithDuration:0.45 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.borderView.transform = CGAffineTransformIdentity;
                             self.borderView.alpha = 1;
                         }
                         completion:^(BOOL finished){
                         }];
    } else {
        [UIView animateWithDuration:0.45 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.borderView.transform = CGAffineTransformMakeScale(1.02, 1.02);
                             self.borderView.alpha = 0;
                         }
                         completion:^(BOOL finished){
                         }];
    }
}


- (void)fadeAnimation
{
    self.previewImageView.alpha = 0;
    self.previewImageView.transform = CGAffineTransformMakeScale(1.025, 1.025);
    [UIView animateWithDuration:0.35
                     animations:^{
                         self.previewImageView.alpha = 1;
                         self.previewImageView.transform = CGAffineTransformIdentity;
                     }];
}


@end
