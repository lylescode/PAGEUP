//
//  SnapshotView.h
//  Page
//
//  Created by CMR on 3/30/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnapshotView : UIView
@property (strong, nonatomic) UIImageView *snapshotImageView;

- (void)setSnapshotImage:(UIImage *)snapshotImage;
@end
