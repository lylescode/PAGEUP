//
//  DeviceUtils.m
//  Page
//
//  Created by CMR on 7/27/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "DeviceUtils.h"
#include <sys/types.h>
#include <sys/sysctl.h>


@implementation DeviceUtils


+ (NSString *)platformString {
    // Gets a string with the device model
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch (1 Gen)";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch (2 Gen)";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch (3 Gen)";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch (4 Gen)";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    if ([platform isEqualToString:@"iPod7,1"])      return @"iPod Touch (6 Gen)";
    
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    
    return platform;
}

+ (BOOL)support60fpsVideo
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone4,1"])    return NO;
    if ([platform isEqualToString:@"iPhone5,1"])    return NO;
    if ([platform isEqualToString:@"iPhone5,2"])    return NO;
    if ([platform isEqualToString:@"iPhone5,3"])    return NO;
    if ([platform isEqualToString:@"iPhone5,4"])    return NO;
    
    if ([platform isEqualToString:@"iPod1,1"])      return NO;
    if ([platform isEqualToString:@"iPod2,1"])      return NO;
    if ([platform isEqualToString:@"iPod3,1"])      return NO;
    if ([platform isEqualToString:@"iPod4,1"])      return NO;
    if ([platform isEqualToString:@"iPod5,1"])      return NO;
    
    if ([platform isEqualToString:@"iPad1,1"])      return NO;
    if ([platform isEqualToString:@"iPad1,2"])      return NO;
    if ([platform isEqualToString:@"iPad2,1"])      return NO;
    if ([platform isEqualToString:@"iPad2,2"])      return NO;
    if ([platform isEqualToString:@"iPad2,3"])      return NO;
    if ([platform isEqualToString:@"iPad2,4"])      return NO;
    if ([platform isEqualToString:@"iPad3,1"])      return NO;
    if ([platform isEqualToString:@"iPad3,2"])      return NO;
    if ([platform isEqualToString:@"iPad3,3"])      return NO;
    if ([platform isEqualToString:@"iPad3,4"])      return NO;
    if ([platform isEqualToString:@"iPad3,5"])      return NO;
    if ([platform isEqualToString:@"iPad3,6"])      return NO;
    
    if ([platform isEqualToString:@"iPad2,5"])      return NO;
    if ([platform isEqualToString:@"iPad2,6"])      return NO;
    if ([platform isEqualToString:@"iPad2,7"])      return NO;
    if ([platform isEqualToString:@"iPad4,4"])      return NO;
    if ([platform isEqualToString:@"iPad4,5"])      return NO;
    if ([platform isEqualToString:@"iPad4,6"])      return NO;
    
    return YES;
    
}

@end
