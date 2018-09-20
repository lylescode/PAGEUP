//
//  ColorToolboardViewCell.h
//  Page
//
//  Created by CMR on 4/14/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorToolboardViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UIView *borderView;
@property (strong, nonatomic) NSString *colorString;

@end
