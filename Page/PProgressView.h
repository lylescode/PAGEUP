//
//  PProgressView.h
//  Page
//
//  Created by CMR on 6/8/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PProgressView : UIView
@property (strong, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet UIView *progressBar;

- (void)prepareProgress;
- (void)updateProgress:(CGFloat)progress;
- (void)completeProgress;

@end
