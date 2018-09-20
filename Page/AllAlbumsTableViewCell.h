//
//  AllAlbumsTableViewCell.h
//  Page
//
//  Created by CMR on 5/15/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllAlbumsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (void)setTitle:(NSString *)titleString countString:(NSString *)countString;
@end
