//
//  AboutFooterMenuView.h
//  Page
//
//  Created by CMR on 7/13/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AboutFooterMenuViewDelegate <NSObject>

- (void)aboutFooterMenuViewDidRateAction;
- (void)aboutFooterMenuViewDidRecommendAction;
- (void)aboutFooterMenuViewDidFeedbackAction;
- (void)aboutFooterMenuViewDidFacebookAction;
- (void)aboutFooterMenuViewDidInstagramAction;
- (void)aboutFooterMenuViewDidEmailAction;

@end


@interface AboutFooterMenuView : UIView

@property (assign, nonatomic) id<AboutFooterMenuViewDelegate> footerMenuDelegate;
@property (strong, nonatomic) IBOutlet UIView *contentsView;
@property (weak, nonatomic) IBOutlet UIButton *rateButton;
@property (weak, nonatomic) IBOutlet UIButton *recommendButton;
@property (weak, nonatomic) IBOutlet UIButton *feedbackButton;

@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UILabel *recommendLabel;
@property (weak, nonatomic) IBOutlet UILabel *feedbackLabel;
@property (weak, nonatomic) IBOutlet UILabel *footerLabel;

@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *instagramButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;


- (IBAction)buttonAction:(id)sender;
- (void)setupAboutContents;
@end
