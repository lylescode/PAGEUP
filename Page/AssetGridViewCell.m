//
//  AssetGridViewCell.m
//  Page
//
//  Created by CMR on 11/23/14.
//  Copyright (c) 2014 Page. All rights reserved.
//

#import "AssetGridViewCell.h"

@interface AssetGridViewCell ()
@end

@implementation AssetGridViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.numberView.layer.cornerRadius = 33 * 0.5;
    self.numberView.hidden = YES;
    self.numberView.alpha = 0;
    
    self.numberView.center = (CGPoint) {
        CGRectGetMidX(self.frame),
        CGRectGetMidY(self.frame)
    };
    
    // Initialization code
    self.dimmedView.layer.borderColor = self.dimmedView.backgroundColor.CGColor;
    self.dimmedView.layer.borderWidth = 8;
    self.dimmedView.backgroundColor = [UIColor clearColor];
    
    self.dimmedView.hidden = YES;
    self.dimmedView.alpha = 0;
    
    
}


- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        self.numberView.hidden = NO;
        self.dimmedView.hidden = NO;
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.numberView.alpha = 1;
                             self.dimmedView.alpha = 1;
                         }
                         completion:^(BOOL finished){
                         }];
    } else {
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.numberView.alpha = 0;
                             self.dimmedView.alpha = 0;
                         }
                         completion:^(BOOL finished){
                         }];
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    /*
    if (highlighted) {
        self.dimmedView.hidden = NO;
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:0.95 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.dimmedView.alpha = 1;
                         }
                         completion:^(BOOL finished){
                         }];
    } else {
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:0.95 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.dimmedView.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             if(finished) {
                                 self.dimmedView.hidden = YES;
                             }
                         }];
    }
     */
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    _thumbnailImage = thumbnailImage;
    self.imageView.image = thumbnailImage;
}

@end
