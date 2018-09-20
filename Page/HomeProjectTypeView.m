//
//  HomeProjectTypeView.m
//  Page
//
//  Created by CMR on 3/13/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "HomeProjectTypeView.h"

@interface HomeProjectTypeView ()
{
    UILabel *typeTitleLabel;
    UIButton *blankButton;
}

- (void)buttonAction;
@end

@implementation HomeProjectTypeView
@synthesize typeViewDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //NSLog(@"HomeProjectTypeView init");
        
        self.clipsToBounds = YES;
        //self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //NSLog(@"HomeProjectTypeView awakeFromNib : %@", NSStringFromCGRect(self.frame));
    blankButton = [UIButton buttonWithType:UIButtonTypeCustom];
    blankButton.translatesAutoresizingMaskIntoConstraints = NO;
    blankButton.frame = self.bounds;
    [blankButton setBackgroundColor:[UIColor clearColor]];
    [blankButton addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:blankButton];
    
    typeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, self.bounds.size.height - 18 - 30, self.bounds.size.width - 36, 30)];
    typeTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    typeTitleLabel.font = [UIFont fontWithName:@"DINAlternate-Bold" size:24];
    typeTitleLabel.backgroundColor = [UIColor clearColor];
    typeTitleLabel.textColor = [UIColor whiteColor];
    [self addSubview:typeTitleLabel];
    
    /*
    NSDictionary *viewsDictionary = @{
                                      @"typeTitleLabel":typeTitleLabel,
                                      @"blankButton":blankButton
                                      };
    */
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(typeTitleLabel, blankButton);
    
    NSArray *typeTitleLabel_Height = [NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:[typeTitleLabel(30)]"
                                      options:0
                                      metrics:nil
                                      views:viewsDictionary];
    
    NSArray *typeTitleLabel_H = [NSLayoutConstraint
                                 constraintsWithVisualFormat:@"H:|-18-[typeTitleLabel]-18-|"
                                 options:0
                                 metrics:nil
                                 views:viewsDictionary];
    NSArray *typeTitleLabel_V = [NSLayoutConstraint
                                 constraintsWithVisualFormat:@"V:[typeTitleLabel]-18-|"
                                 options:0
                                 metrics:nil
                                 views:viewsDictionary];
    
    NSArray *blankButton_H = [NSLayoutConstraint
                              constraintsWithVisualFormat:@"H:|[blankButton]|"
                              options:0
                              metrics:nil
                              views:viewsDictionary];
    NSArray *blankButton_V = [NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:|[blankButton]|"
                              options:0
                              metrics:nil
                              views:viewsDictionary];
    
    [typeTitleLabel addConstraints:typeTitleLabel_Height];
    [self addConstraints:typeTitleLabel_H];
    [self addConstraints:typeTitleLabel_V];
    [self addConstraints:blankButton_H];
    [self addConstraints:blankButton_V];
    
    self.clipsToBounds = YES;
    //self.backgroundColor = [UIColor clearColor];
}

- (void)updateViewConstraints
{
    [super updateConstraints];
    
    NSLog(@"updateConstraints");
}

- (void)dealloc
{
    [typeTitleLabel removeFromSuperview];
    [blankButton removeFromSuperview];
}

- (void)buttonAction
{
    [typeViewDelegate homeProjectTypeDidSelect:self];
}

- (void)setTypeTitle:(NSString *)typeTitle
{
    typeTitleLabel.text = typeTitle;
}

- (NSString *)typeTitle
{
    return typeTitleLabel.text;
}

- (void)setTypePreviewImages:(NSArray *)previewImages
{
    
}

@end
