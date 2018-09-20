//
//  DeviceUtils.h
//  Page
//
//  Created by CMR on 7/27/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceUtils : NSObject

+ (NSString *)platformString;
+ (BOOL)support60fpsVideo;

@end
