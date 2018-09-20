//
//  PUILabel.h
//  DPage
//
//  Created by CMR on 10/27/14.
//  Copyright (c) 2014 BucketLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PUILabel : UILabel
{
    CGFloat resizedScale;
}

@property (assign, nonatomic) CGFloat resizedScale;
@property (assign, nonatomic) BOOL staticLabel;

@property (strong, nonatomic) NSNumber *textKern;
@property (strong, nonatomic) NSNumber *lineHeight;
@property (strong, nonatomic) NSString *textType;

@property (assign, nonatomic) BOOL editedText;
@property (strong, nonatomic) UIColor *originalTextColor;
@property (assign, nonatomic) CGRect originFrame;
@property (strong, nonatomic) NSString *originText;
@property (strong, nonatomic) UIFont *originFont;
@property (weak, nonatomic) NSString *paragraphText;

- (void)resizeWithScale:(CGFloat)resizeScale;
- (void)setFontName:(NSString *)fontName;

@end
