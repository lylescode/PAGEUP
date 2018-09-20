//
//  PBloggerSansLight.m
//  Page
//
//  Created by CMR on 12/8/15.
//  Copyright © 2015 Page. All rights reserved.
//

#import "PBloggerSansLight.h"

@implementation PBloggerSansLight


- (void)awakeFromNib {
    [super awakeFromNib];
    self.font = [UIFont fontWithName:@"BloggerSans-Light" size:self.font.pointSize];
    
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
