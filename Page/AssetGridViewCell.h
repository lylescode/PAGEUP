//
//  AssetGridViewCell.h
//  Page
//
//  Created by CMR on 11/23/14.
//  Copyright (c) 2014 Page. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AssetGridViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *dimmedView;

@property (weak, nonatomic) IBOutlet UIView *numberView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@property (strong, nonatomic) UIImage *thumbnailImage;
@end
