//
//  ToolboardView.h
//  Page
//
//  Created by CMR on 4/13/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ToolboardViewDelegate <NSObject>

- (void)toolboardViewDidPreviousTextView;
- (void)toolboardViewDidNextTextView;
- (void)toolboardViewDidSelectFont;
- (void)toolboardViewDidSelectColor;
- (void)toolboardViewDidSelectUppercase;
- (void)toolboardViewDidClose:(id)sender;
@end

@interface ToolboardView : UIView
@property (weak, nonatomic) id<ToolboardViewDelegate> toolboardDelegate;
@property (strong, nonatomic) UITextView *selectedTextView;

@property (strong, nonatomic) IBOutlet UIView *interfaceView;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *fontButton;
@property (weak, nonatomic) IBOutlet UIButton *colorButton;
@property (weak, nonatomic) IBOutlet UIButton *uppercaseButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;


- (IBAction)closeButtonAction:(id)sender;
- (IBAction)toolButtonAction:(id)sender;

- (void)setTargetTextView:(UITextView *)textView;

@end
