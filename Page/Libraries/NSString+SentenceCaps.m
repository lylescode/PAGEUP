//
//  NSString+SentenceCaps.m
//  Page
//
//  Created by CMR on 7/6/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "NSString+SentenceCaps.h"

@implementation NSString (SentenceCaps)


- (NSString *)sentenceCapitalizedString {
    if (![self length]) {
        return [NSString string];
    }
    NSString *uppercase = [[self substringToIndex:1] uppercaseString];
    NSString *lowercase = [[self substringFromIndex:1] lowercaseString];
    return [uppercase stringByAppendingString:lowercase];
}

- (NSString *)realSentenceCapitalizedString {
    __block NSMutableString *mutableSelf = [NSMutableString stringWithString:self];
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
                             options:NSStringEnumerationBySentences
                          usingBlock:^(NSString *sentence, NSRange sentenceRange, NSRange enclosingRange, BOOL *stop) {
                              [mutableSelf replaceCharactersInRange:sentenceRange withString:[sentence sentenceCapitalizedString]];
                          }];
    return [NSString stringWithString:mutableSelf]; // or just return mutableSelf.
}

@end
