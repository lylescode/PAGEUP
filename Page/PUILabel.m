
//
//  PUILabel.m
//  DPage
//
//  Created by CMR on 10/27/14.
//  Copyright (c) 2014 BucketLabs. All rights reserved.
//

#import "PUILabel.h"
#import "PTextGroupView.h"

@interface PUILabel ()

- (CGRect)boundingRectWithString:(NSString *)string;
- (NSString *)particularHeightString:(NSString *)string;
@end

@implementation PUILabel
@synthesize resizedScale;

- (id)init
{
    self = [super init];
    if (self) {
        resizedScale = 1;
        self.lineBreakMode = NSLineBreakByWordWrapping;
        self.numberOfLines = 0;
        if(!self.text) {
            self.text = @"";
        }
        self.originalTextColor = self.textColor;
        self.originFont = self.font;
        self.paragraphText = self.text;
        self.originText = self.text;
        self.originFrame = self.frame;
        
        if(self.textType) {
        }
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    resizedScale = 1;
    self.lineBreakMode = NSLineBreakByWordWrapping;
    self.numberOfLines = 0;
    self.originalTextColor = self.textColor;
    self.originFont = self.font;
    self.paragraphText = self.text;
    self.originText = self.text;
    self.originFrame = self.frame;
    
    if(self.textType) {
    }
}

- (void)dealloc
{
    for(id subItem in [self subviews]) {
        UIView *subView = (UIView *)subItem;
        [subView removeFromSuperview];
    }
}


- (void)resizeWithScale:(CGFloat)resizeScale
{
    if(resizedScale == resizeScale) {
        return;
    }
    
    resizedScale = resizeScale;
    if(self.textKern) {
        self.textKern = [NSNumber numberWithFloat:[self.textKern floatValue] * resizeScale];
    }
    /*
    if(self.lineHeight) {
        self.lineHeight = [NSNumber numberWithFloat:[self.lineHeight floatValue] * resizeScale];
    }*/
    
    self.frame = CGRectMake(self.frame.origin.x * resizeScale, self.frame.origin.y * resizeScale, self.frame.size.width * resizeScale, self.frame.size.height * resizeScale);
    self.originFrame = self.frame;
    
    self.font = [UIFont fontWithName:self.originFont.fontName size:self.originFont.pointSize * resizedScale];
    self.paragraphText = self.text;
    
}

- (void)setFontName:(NSString *)fontName
{
    UIFont *newFont = [UIFont fontWithName:fontName size:self.originFont.pointSize * resizedScale];
    
    //CGFloat textWidth = self.frame.size.width;
    CGFloat textHeight = self.frame.size.height;
    
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:self.originText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = self.textAlignment;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    [attrText addAttribute:NSFontAttributeName value:newFont range:NSMakeRange(0, attrText.length)];
    [attrText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attrText.length)];
    
    CGRect rect = [attrText boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.frame), MAXFLOAT)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                         context:nil];
    
    
    CGSize measureSize = rect.size;
    
    //BOOL reviseFontSize = NO;
    while (textHeight < measureSize.height) {
        //reviseFontSize = YES;
        newFont = [UIFont fontWithName:fontName size:newFont.pointSize * 0.95];
        
        attrText = [[NSMutableAttributedString alloc] initWithString:self.originText];
        paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = self.textAlignment;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
        [attrText addAttribute:NSFontAttributeName value:newFont range:NSMakeRange(0, attrText.length)];
        [attrText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attrText.length)];
        
        rect = [attrText boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.frame), MAXFLOAT)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                             context:nil];
        
        
        measureSize = rect.size;
    }
    
    self.font = newFont;
    
    self.paragraphText = self.text;
}

- (void)setParagraphText:(NSString *)paragraphText
{
    //NSLog(@"setParagraphText resizedScale : %f", resizedScale);
    //NSString *particularText = [self particularHeightString:paragraphText];
    
    //TODO: 텍스트 내용이 길면 텍스트 뷰를 늘려주기
    
    //TODO: 텍스트뷰를 감싸고있는 PTextGroupView 사이즈도 늘려주기
    
    NSString *particularText = paragraphText;
    UIFont *resizedFont = [UIFont fontWithName:self.font.fontName size:self.originFont.pointSize * resizedScale];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:particularText];
    [attrStr addAttribute:NSFontAttributeName value:resizedFont range:NSMakeRange(0, attrStr.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = self.textAlignment;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    if(self.textKern) {
        [attrStr addAttribute:NSKernAttributeName value:self.textKern range:NSMakeRange(0, attrStr.length)];
    }
    /*
    //NSLog(@"self.lineHeight : %@", self.lineHeight);
    if(self.lineHeight) {
        paragraphStyle.minimumLineHeight = [self.lineHeight floatValue];
        paragraphStyle.maximumLineHeight = [self.lineHeight floatValue];
    }
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attrStr.length)];
    */
    /*
    if([paragraphText isEqualToString:@""] == NO) {
        
        CGFloat textHeight = self.frame.size.height;
        CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.frame), MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                            context:nil];
        CGSize measureSize = rect.size;
        while (textHeight < measureSize.height) {
            
            resizedFont = [UIFont fontWithName:resizedFont.fontName size:resizedFont.pointSize * 0.95];
            
            attrStr = [[NSMutableAttributedString alloc] initWithString:particularText];
            [attrStr addAttribute:NSFontAttributeName value:resizedFont range:NSMakeRange(0, attrStr.length)];
            
            rect = [attrStr boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.frame), MAXFLOAT)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                         context:nil];
            
            
            measureSize = rect.size;
        }
    }
     */
    
    self.font = resizedFont;
    self.attributedText = attrStr;
    BOOL changeSize = NO;
    
    if([paragraphText isEqualToString:@""] == NO) {
        CGSize measureSize = self.frame.size;
        measureSize.height = ceilf([self sizeThatFits:self.frame.size].height);
        //NSLog(@"current frame : %@", NSStringFromCGRect(self.frame));
        
        CGRect measureFrame = (CGRect){
            self.frame.origin.x,
            self.frame.origin.y,
            measureSize.width,
            measureSize.height
        };
        
        changeSize = !CGRectEqualToRect(measureFrame, self.frame);
        self.frame = measureFrame;
        
        //NSLog(@"measure frame : %@", NSStringFromCGRect(self.frame));
    } else {
        
        changeSize = !CGRectEqualToRect(self.originFrame, self.frame);
        self.frame = self.originFrame;
    }
    if(changeSize) {
        if([[self superview] isKindOfClass:[PTextGroupView class]]) {
            PTextGroupView *parentTextGroupView = (PTextGroupView *)[self superview];
            [parentTextGroupView adjustTextGroupSize];
        }
    }
    
    //[self adjustFontSizeToFit];
}

- (NSString *)paragraphText
{
    return self.text;
}
- (CGRect)boundingRectWithString:(NSString *)string
{
    
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = self.textAlignment;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    [attrText addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, attrText.length)];
    [attrText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attrText.length)];
    
    CGRect rect = [attrText boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.frame), MAXFLOAT)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                         context:nil];
    return rect;
}
- (NSString *)particularHeightString:(NSString *)string
{
    CGRect rect = [self boundingRectWithString:string];
    if(rect.size.height < CGRectGetHeight(self.frame)) {
        return string;
    }
    
    NSString *particularString = string;
    // 줄내림 모두 삭제
    
    //NSLog(@"particularString : %@", particularString);
    particularString = [particularString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    NSLog(@"줄내림 삭제 particularString : %@", particularString);
    rect = [self boundingRectWithString:particularString];
    
    while (rect.size.height > ceil(CGRectGetHeight(self.frame))) {
        NSRange lastPaticularRange = [particularString rangeOfString:@" " options:NSBackwardsSearch];
        if(lastPaticularRange.location != NSNotFound) {
            particularString = [particularString substringToIndex:lastPaticularRange.location];
        } else {
            particularString = [particularString substringToIndex:particularString.length - 1];
        }
        if(particularString.length == 0)
            break;
        
        //NSLog(@"particularString : %@", particularString);
        rect = [self boundingRectWithString:particularString];
    }
    
    return particularString;
}


@end
