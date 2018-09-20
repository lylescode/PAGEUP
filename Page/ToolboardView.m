//
//  ToolboardView.m
//  Page
//
//  Created by CMR on 4/13/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "ToolboardView.h"

@implementation ToolboardView
@synthesize interfaceView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;
        
        self.backgroundColor = [UIColor whiteColor];
        [[NSBundle mainBundle] loadNibNamed:@"ToolboardView" owner:self options:nil];
        
        interfaceView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:interfaceView];
        
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(interfaceView);
        NSArray *interfaceView_H = [NSLayoutConstraint
                                  constraintsWithVisualFormat:@"H:|[interfaceView]|"
                                  options:0
                                  metrics:nil
                                  views:viewsDictionary];
        NSArray *interfaceView_V = [NSLayoutConstraint
                                  constraintsWithVisualFormat:@"V:|[interfaceView]|"
                                  options:0
                                  metrics:nil
                                  views:viewsDictionary];
        
        [self addConstraints:interfaceView_H];
        [self addConstraints:interfaceView_V];
    }
    return self;
}

- (void)dealloc
{
    self.selectedTextView = nil;
}

- (IBAction)closeButtonAction:(id)sender {
    [self.toolboardDelegate toolboardViewDidClose:self];
}

- (IBAction)toolButtonAction:(id)sender {
    if(sender == self.previousButton) {
        [self.toolboardDelegate toolboardViewDidPreviousTextView];
    } else if(sender == self.nextButton) {
        [self.toolboardDelegate toolboardViewDidNextTextView];
    } else if(sender == self.fontButton) {
        [self.toolboardDelegate toolboardViewDidSelectFont];
    } else if(sender == self.colorButton) {
        [self.toolboardDelegate toolboardViewDidSelectColor];
    } else if(sender == self.uppercaseButton) {
        [self.toolboardDelegate toolboardViewDidSelectUppercase];
    }
}


- (void)setTargetTextView:(UITextView *)textView
{
    self.selectedTextView = textView;
}


@end
