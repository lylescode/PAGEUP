//
//  UIColor+Matching.m
//  Page
//
//  Created by CMR on 9/11/15.
//  Copyright © 2015 Page. All rights reserved.
//

#import "UIColor+Matching.h"

@implementation UIColor (Matching)


-(BOOL)matchesColor:(UIColor *)color error:(NSError *__autoreleasing *)error
{
    UIColor *lhs = self;
    UIColor *rhs = color;
    
    if([lhs isEqual:rhs]){ // color model and values are the same
        return YES;
    }
    
    CGFloat red1, red2, green1, alpha1, green2, blue1, blue2, alpha2;
    BOOL lhsSuccess = [lhs getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
    BOOL rhsSuccess = [rhs getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];
    if((!lhsSuccess && rhsSuccess) || (lhsSuccess && !rhsSuccess)){ // one is RGBA, one color not.
        CGFloat r,g,b,a;
        if(!lhsSuccess){ // lhs color could be a monochrome
            const CGFloat *components = CGColorGetComponents(lhs.CGColor);
            
            if(components) {
                if([lhs _colorSpaceModel] == kCGColorSpaceModelMonochrome){
                    r = g = b = components[0];
                    a = components[1];
                    
                    return r == red2 && g == green2 && b == blue2 && a == alpha2;
                }
            }
        } else {  // rhs color could be a monochrome
            const CGFloat *components = CGColorGetComponents(rhs.CGColor);
            
            if(components) {
                if([rhs _colorSpaceModel] == kCGColorSpaceModelMonochrome){
                    r = g = b = components[0];
                    a = components[1];
                    return r == red1 && g == green1 && b == blue1 && a == alpha1;
                }
            }
        }
        
        
        //NSError *aError = [[NSError alloc] initWithDomain:@"UIColorComparision" code:-11111 userInfo:[self _colorComparisionErrorUserInfo]];
        return  NO;
    } else if (!lhsSuccess && !rhsSuccess){ // both not RGBA, lets try HSBA
        CGFloat hue1,saturation1,brightness1;
        CGFloat hue2,saturation2,brightness2;
        
        lhsSuccess = [lhs getHue:&hue1 saturation:&saturation1 brightness:&brightness1 alpha:&alpha1];
        rhsSuccess = [lhs getHue:&hue2 saturation:&saturation2 brightness:&brightness2 alpha:&alpha2];
        if((!lhsSuccess && rhsSuccess) || (lhsSuccess && !rhsSuccess)){
            //NSError *aError = [[NSError alloc] initWithDomain:@"UIColorComparision" code:-11111 userInfo:[self _colorComparisionErrorUserInfo]];
            return  NO;
        } else if(!lhsSuccess && !rhsSuccess){ // both not HSBA, lets try monochrome
            CGFloat white1, white2;
            
            lhsSuccess = [lhs getWhite:&white1 alpha:&alpha1];
            rhsSuccess = [rhs getWhite:&white2 alpha:&alpha2];
            if((!lhsSuccess && rhsSuccess) || (lhsSuccess && !rhsSuccess)){
                //NSError *aError = [[NSError alloc] initWithDomain:@"UIColorComparision" code:-11111 userInfo:[self _colorComparisionErrorUserInfo]];
                return  NO;
            } else {
                return white1 == white2 && alpha1 == alpha2;
            }
            
        } else {
            return hue1 == hue2 && saturation1 == saturation2 && brightness1 == brightness2 && alpha1 == alpha2;
        }
        
    } else {
        return (red1 == red2 && green1 == green2 && blue1 == blue2 && alpha1 == alpha2);
        
    }
}

-(NSDictionary *)_colorComparisionErrorUserInfo{
    
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"Comparision failed.", nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The colors models are incompatible. Or the color is a pattern.", nil),
                               
                               };
    return userInfo;
}

- (CGColorSpaceModel)_colorSpaceModel {
    return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

@end
