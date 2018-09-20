//
//  Macro.h
//  Editorial
//
//  Created by CMR on 10/1/15.
//  Copyright © 2015 Rawsmith Inc. All rights reserved.
//

#ifdef DEBUG
#define NSLog(fmt, ...) NSLog((fmt), ##__VA_ARGS__);

#else
#define NSLog(...)

#endif

/** MARK - method stamp macro, use to output class and method name. **/
#ifdef DEBUG
#define MARK     NSLog(@"--[ M.A.R.K : %@][line:%i]%s",[[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__ , __PRETTY_FUNCTION__);

#else
#define MARK  NSLog(...)

#endif

#define AND &&
#define OR ||

#ifdef DEBUG
#define OLog(msg, o)  NSLog(@"%@ : %@", msg,  o);
#define RLog(msg, rect) NSLog(@"%@ rect : %@", msg, NSStringFromCGRect(rect));
#define PLog(msg, point) NSLog(@"%@ point : %@", msg, NSStringFromCGPoint(point));
#define SLog(msg, size) NSLog(@"%@ size : %@", msg, NSStringFromCGSize(size));

#else
#define OLog(msg, o) NSLog(...)
#define RLog(msg, rect) NSLog(...)
#define PLog(msg, point) NSLog(...)
#define SLog(msg, size) NSLog(...)

#endif

#define USER_DEFAULT        [NSUserDefaults standardUserDefaults]
#define MAIN_BUNDLE          [NSBundle mainBundle]

#define CACHES_DIRECTORY    [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define DOCUMENTATION_DIRECTORY [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_SIMULATOR (TARGET_IPHONE_SIMULATOR)

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define SCREEN_SCALE ([[UIScreen mainScreen] scale])
#define SCREEN_WIDTH_PORTRAIT ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_WIDTH_LANDSCAPE ([[UIScreen mainScreen] bounds].size.height)

#define degreesToRadians(degrees) ((degrees) / 180.0 * M_PI)
#define radiansToDegrees(radians) ((radians) * ( 180.0 / M_PI))

#define radians(degrees) degrees * M_PI / 180

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]


