//
//  CategoryViewCell.h
//  Page
//
//  Created by CMR on 3/31/16.
//  Copyright © 2016 Page. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *highlightView;

@end
