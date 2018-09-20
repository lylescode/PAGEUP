//
//  TemplateViewCell.h
//  Page
//
//  Created by CMR on 12/3/14.
//  Copyright (c) 2014 Page. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TemplateViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *borderView;
@property (strong, nonatomic) UIView *templateView;
@property (strong, nonatomic) UIView *shadowView;

- (void)fadeAnimation;
- (void)highlightAnimation;

@end
