//
//  AboutTooltipView.h
//  Page
//
//  Created by CMR on 7/13/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AboutTooltipViewDelegate <NSObject>

- (void)aboutTooltipViewDidVideoAction:(id)sender;

@end

@interface AboutTooltipView : UIView
@property (assign, nonatomic) id<AboutTooltipViewDelegate> tooltipViewDelegate;

@property (strong, nonatomic) IBOutlet UIView *contentsView;
@property (weak, nonatomic) IBOutlet UIImageView *tutorialImageView;
@property (weak, nonatomic) IBOutlet UIImageView *borderLineView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UIButton *watchVideoButton;
@property (weak, nonatomic) IBOutlet UILabel *watchVideoLabel;
- (IBAction)buttonAction:(id)sender;
- (void)setupAboutContents;
@end
