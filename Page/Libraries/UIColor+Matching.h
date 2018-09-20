//
//  UIColor+Matching.h
//  Page
//
//  Created by CMR on 9/11/15.
//  Copyright © 2015 Page. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Matching)

- (BOOL)matchesColor:(UIColor *)color error:(NSError *__autoreleasing *)error;

@end
