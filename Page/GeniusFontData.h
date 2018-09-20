//
//  GeniusFontData.h
//  Page
//
//  Created by CMR on 9/11/15.
//  Copyright © 2015 Page. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeniusFontData : NSObject

@property (strong, nonatomic) NSArray *fontDictionaryArray;
@property (strong, nonatomic) NSArray *koFontDictionaryArray;

@property (strong, nonatomic) NSArray *defaultTitleFonts;
@property (strong, nonatomic) NSArray *defaultContentFonts;
@property (strong, nonatomic) NSArray *koreanTitleFonts;
@property (strong, nonatomic) NSArray *koreanContentFonts;

@end
