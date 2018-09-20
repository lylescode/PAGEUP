//
//  PhotoBrightnessSliderView.h
//  Page
//
//  Created by CMR on 6/9/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PhotoBrightnessSliderDelegate <NSObject>

- (void)photoBrightnessSliderChangeValue:(CGFloat)value;

@end

@interface PhotoBrightnessSliderView : UIView

@property (assign, nonatomic) id<PhotoBrightnessSliderDelegate> sliderDelegate;
@property (assign, nonatomic) CGFloat currentValue;

@end
