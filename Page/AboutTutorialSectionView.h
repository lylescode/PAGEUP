//
//  AboutTutorialSectionView.h
//  Page
//
//  Created by CMR on 7/13/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutTutorialSectionView : UIView

@property (strong, nonatomic) IBOutlet UIView *contentsView;
@property (weak, nonatomic) IBOutlet UILabel *tutorialLabel;

- (void)setupAboutContents;


@end
