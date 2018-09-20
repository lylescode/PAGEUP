//
//  PLoveloLineBold.m
//  Page
//
//  Created by CMR on 12/3/15.
//  Copyright © 2015 Page. All rights reserved.
//

#import "PLoveloLineBold.h"

@implementation PLoveloLineBold


- (void)awakeFromNib {
    [super awakeFromNib];
    self.font = [UIFont fontWithName:@"LoveloLineBold" size:self.font.pointSize];
    
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

@end
