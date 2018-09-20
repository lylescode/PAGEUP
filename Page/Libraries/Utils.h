//
//  Utils.h
//  CyworldCamera
//
//  Created by CMR on 10. 8. 4..
//  Copyright 2010 DustDay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface Utils : NSObject {

}
+ (float)DegreesToRadians:(float)degrees;
+ (float)RadiansToDegrees:(float)radians;

+ (NSString *)NSStringFromUIColor:(UIColor *)color;
+ (UIColor *)UIColorFromRGBString:(NSString *)rgbString;
+ (UIColor *)UIColorFromRGBString:(NSString *)rgbString alpha:(float)alpha;

+ (NSString *)secondToTimeString:(double)seconds;
+ (NSString *)secondToTimeFullString:(double)seconds;

+ (NSArray *)shuffleArray:(NSArray *)array;
@end
