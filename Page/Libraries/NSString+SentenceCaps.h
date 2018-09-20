//
//  NSString+SentenceCaps.h
//  Page
//
//  Created by CMR on 7/6/15.
//  Copyright (c) 2015 Page. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface NSString (SentenceCaps)

- (NSString *)sentenceCapitalizedString; // sentence == entire string
- (NSString *)realSentenceCapitalizedString; // sentence == real sentences

@end
