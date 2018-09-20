//
//  HomeShareTableViewCell.h
//  Page
//
//  Created by CMR on 5/13/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeShareTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

- (void)setTitleString:(NSString *)titleString;

@end
