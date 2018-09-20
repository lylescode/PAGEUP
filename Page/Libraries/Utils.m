//
//  Utils.m
//  CyworldCamera
//
//  Created by CMR on 10. 8. 4..
//  Copyright 2010 DustDay. All rights reserved.
//

#import "Utils.h"


@implementation Utils
+ (float)DegreesToRadians:(float)degrees
{
    return degrees * (M_PI / 180);
}

+ (float)RadiansToDegrees:(float)radians
{
    return radians * (180 / M_PI);
}

+ (NSString *)NSStringFromUIColor:(UIColor *)color
{
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    if (r < 0.0f) r = 0.0f;
    if (g < 0.0f) g = 0.0f;
    if (b < 0.0f) b = 0.0f;
    
    if (r > 1.0f) r = 1.0f;
    if (g > 1.0f) g = 1.0f;
    if (b > 1.0f) b = 1.0f;
    
    // Convert to hex string between 0x00 and 0xFF
    return [NSString stringWithFormat:@"0x%02lX%02lX%02lX",
            (long)(r * 255), (long)(g * 255), (long)(b * 255)];
}

+ (UIColor *)UIColorFromRGBString:(NSString *)rgbString
{
    if ([rgbString isEqualToString:0]) {
        return [UIColor clearColor];
    }
    
    if (NO == [rgbString hasPrefix:@"0x"]) {
        rgbString = [NSString stringWithFormat:@"0x%@", rgbString];
    }
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:rgbString];
    unsigned int rgbValue;
    if (![scanner scanHexInt:&rgbValue])
    {
        
        return [UIColor whiteColor];
    }
    
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0
                           green:((float)((rgbValue & 0xFF00) >> 8))/255.0
                            blue:((float)(rgbValue & 0xFF))/255.0
                           alpha:1.0];
}

+ (UIColor *)UIColorFromRGBString:(NSString *)rgbString alpha:(float)alpha
{
    if ([rgbString isEqualToString:0]) {
        return [UIColor clearColor];
    }
    
    if (NO == [rgbString hasPrefix:@"0x"]) {
        rgbString = [NSString stringWithFormat:@"0x%@", rgbString];
    }
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:rgbString];
    unsigned int rgbValue;
    if (![scanner scanHexInt:&rgbValue])
    {
        return [UIColor whiteColor];
    }
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0
                           green:((float)((rgbValue & 0xFF00) >> 8))/255.0
                            blue:((float)(rgbValue & 0xFF))/255.0
                           alpha:alpha];
}



+ (NSString *)secondToTimeString:(double)seconds
{
    if (isfinite(seconds)) {
        if (seconds < 0.0) {
            seconds = 0.0;
        }
        int secondsInt = round(seconds);
        int minutes = secondsInt / 60;
        secondsInt -= minutes * 60;
        int secondsOnes = secondsInt % 10;
        int secondsTens = secondsInt / 10;
        
        //        return [NSString stringWithFormat:@"%i:%i%i", minutes, secondsTens, secondsOnes];
        return [NSString stringWithFormat:@"%i:%i%i", minutes, secondsTens, secondsOnes];
    } else {
        return nil;
    }
}


+ (NSString *)secondToTimeFullString:(double)seconds
{
    if (isfinite(seconds)) {
        if (seconds < 0.0) {
            seconds = 0.0;
        }
        NSInteger secondsInt = round(seconds);
        NSInteger minutes = secondsInt / 60;
        secondsInt -= minutes * 60;
        NSInteger secondsOnes = secondsInt % 10;
        NSInteger secondsTens = secondsInt / 10;
        
        NSInteger hours = seconds / 3600;
        
        
        return [NSString stringWithFormat:@"%02ld:%02ld:%li%li",(long)hours, (long)minutes, (long)secondsTens, (long)secondsOnes];
    } else {
        return nil;
    }
}

+ (NSArray *)shuffleArray:(NSArray *)array
{
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:array];
    
    for(NSInteger i = [array count]; i > 1; i--) {
        NSInteger j = arc4random_uniform((uint32_t)i);
        [temp exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
    
    return [NSArray arrayWithArray:temp];
}




@end
