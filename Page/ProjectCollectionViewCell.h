//
//  ProjectCollectionViewCell.h
//  Page
//
//  Created by CMR on 5/6/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet UIView *borderView;

- (void)fadeAnimation;
@end
