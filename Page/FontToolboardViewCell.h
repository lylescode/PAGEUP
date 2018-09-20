//
//  FontToolboardViewCell.h
//  Page
//
//  Created by CMR on 4/14/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FontToolboardViewCell : UICollectionViewCell
@property (strong, nonatomic) NSString *fontName;
@property (weak, nonatomic) IBOutlet UIView *labelBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *fontLabel;

@end
