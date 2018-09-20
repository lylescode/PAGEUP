//
//  PhotoBrightnessSliderView.m
//  Page
//
//  Created by CMR on 6/9/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "PhotoBrightnessSliderView.h"
@interface PhotoBrightnessSliderView ()
{
    CGFloat _currentValue;
    NSInteger currentPointIndex;
    UITapGestureRecognizer *tapGesture;
    UIPanGestureRecognizer *panGesture;
    
    BOOL dragging;
}
@property (strong, nonatomic) NSArray *pointViewArray1;
@property (strong, nonatomic) NSArray *pointViewArray2;
@property (strong, nonatomic) UILabel *sliderLabel;
@property (strong, nonatomic) UIView *sliderLine;

- (void)panGesture:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer;

@end

static CGFloat sliderStartPositionX;
static CGFloat sliderWidth;
static CGFloat minimumValue = -0.5;
static CGFloat maximumValue = 0.5;
static NSInteger dotCount = 9;

@implementation PhotoBrightnessSliderView

- (id)init
{
    self = [super init];
    if (self) {
        NSLog(@"init");
    }
    return self;
}
- (void)dealloc
{
    [self removeGestureRecognizer:panGesture];
    [self removeGestureRecognizer:tapGesture];
    
    for(UIView *pointView2 in self.pointViewArray2) {
        [pointView2 removeFromSuperview];
    }
    for(UIView *pointView1 in self.pointViewArray1) {
        [pointView1 removeFromSuperview];
    }
    
    self.pointViewArray1 = nil;
    self.pointViewArray2 = nil;
    
    [self.sliderLine removeFromSuperview];
    self.sliderLine = nil;
    
    [self.sliderLabel removeFromSuperview];
    self.sliderLabel = nil;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSLog(@"awakeFromNib");
    
    _currentValue = 99;
    
    
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [self addGestureRecognizer:panGesture];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self addGestureRecognizer:tapGesture];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(sliderStartPositionX, 35, sliderWidth, 1)];
    lineView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    [self addSubview:lineView];
    self.sliderLine = lineView;
    
    UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    valueLabel.text = @"1";
    valueLabel.textColor = [UIColor whiteColor];
    valueLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
    [self addSubview:valueLabel];
    self.sliderLabel = valueLabel;
    self.sliderLabel.alpha = 0;
    
    
    NSMutableArray *pointViews1 = [NSMutableArray array];
    NSMutableArray *pointViews2 = [NSMutableArray array];
    
    CGSize pointSize1 = CGSizeMake(24, 24);
    CGSize pointSize2 = CGSizeMake(20, 20);
    
    CGFloat centerX = 0;
    CGFloat centerY = 35;
    
    sliderStartPositionX = 27;
    CGFloat dotSpacing = (self.bounds.size.width - (sliderStartPositionX * 2)) / dotCount;
    
    for(int i = 0 ; i < dotCount ; i++) {
        centerX += dotSpacing;
        
        UIView *pointView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pointSize1.width, pointSize1.height)];
        pointView1.center = CGPointMake(centerX, centerY);
        pointView1.backgroundColor = [UIColor whiteColor];
        pointView1.layer.cornerRadius = pointSize1.width / 2;
        [self addSubview:pointView1];
        
        UIView *pointView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pointSize2.width, pointSize2.height)];
        pointView2.center = CGPointMake(pointSize1.width / 2, pointSize1.height / 2);
        pointView2.backgroundColor = [UIColor blackColor];
        pointView2.layer.cornerRadius = pointSize2.width / 2;
        [pointView1 addSubview:pointView2];
        
        pointView1.transform = CGAffineTransformMakeScale(0.3, 0.3);
        pointView2.alpha = 0;
        
        [pointViews1 addObject:pointView1];
        [pointViews2 addObject:pointView2];
        
    }
    
    self.pointViewArray1 = [NSArray arrayWithArray:pointViews1];
    self.pointViewArray2 = [NSArray arrayWithArray:pointViews2];
    
}

- (void)layoutSubviews
{
    CGFloat centerX = 0;
    CGFloat centerY = 35;
    
    sliderStartPositionX = 27;
    CGFloat dotSpacing = (self.bounds.size.width - (sliderStartPositionX * 2)) / dotCount;
    
    for(UIView *pointView in self.pointViewArray1) {
        centerX += dotSpacing;
        pointView.center = CGPointMake(centerX, centerY);
        
    }
    sliderWidth = centerX - sliderStartPositionX;

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGFloat)currentValue
{
    return _currentValue;
}

- (void)setCurrentValue:(CGFloat)value
{
    NSLog(@"currentValue : %f", value);
    //NSLog(@"currentValue : %f", maximumValue - minimumValue);
    [self changeSlideValue:(value - minimumValue) * (1 / (maximumValue - minimumValue))];
}


- (void)changeSlideValue:(CGFloat)value
{
    NSInteger pointIndex = round((self.pointViewArray1.count - 1) * value);
    
    currentPointIndex = pointIndex;
    
    NSLog(@"changeSlideValue pointIndex : %li", (long)pointIndex);
    UIView *selectPointView = [self.pointViewArray1 objectAtIndex:pointIndex];
    
    CGFloat pointValue = (selectPointView.center.x - sliderStartPositionX) / sliderWidth;
    CGFloat newValue = minimumValue + ((maximumValue - minimumValue) * pointValue);
    NSLog(@"changeSlideValue : %f", minimumValue + ((maximumValue - minimumValue) * pointValue));
    
    newValue = (ABS(newValue) < 0.1) ? 0.0 : newValue;
    
    if(_currentValue == newValue) {
        return;
    }
    _currentValue = newValue;
    
    self.sliderLabel.text = [NSString stringWithFormat:@"%.1f", _currentValue];
    [self.sliderLabel sizeToFit];
    self.sliderLabel.center = CGPointMake(selectPointView.center.x, selectPointView.center.y - 23);
    
    NSInteger pointViewIndex = 0;
    for(UIView *pointView in self.pointViewArray1) {
        
        UIView *pointView2 = [self.pointViewArray2 objectAtIndex:pointViewIndex];
        pointViewIndex++;
        if(selectPointView == pointView) {
            self.sliderLabel.alpha = 0;
            self.sliderLabel.transform = CGAffineTransformMakeTranslation(0, 5);
            [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 pointView.transform = CGAffineTransformIdentity;
                                 pointView2.alpha = 1;
                                 
                                 self.sliderLabel.transform = CGAffineTransformIdentity;
                                 self.sliderLabel.alpha = 1;
                                 
                             }
                             completion:^(BOOL finished){
                             }];
        } else {
            [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 pointView.transform = CGAffineTransformMakeScale(0.3, 0.3);
                                 pointView2.alpha = 0;
                             }
                             completion:^(BOOL finished){
                             }];
        }
        
    }
    
    
    
    
    
    [self.sliderDelegate photoBrightnessSliderChangeValue:minimumValue + ((maximumValue - minimumValue) * pointValue)];
}


- (void)panGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        //CGPoint position = [gestureRecognizer locationInView:self];

    } else if ([gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        
        CGPoint position = [gestureRecognizer locationInView:self];
        //NSLog(@"position : %@", NSStringFromCGPoint(position));
        
        if(position.x < sliderStartPositionX) {
            [self changeSlideValue:0];
        } else if(position.x > sliderStartPositionX + sliderWidth) {
            [self changeSlideValue:1];
        } else {
            CGFloat positionX = position.x - sliderStartPositionX;
            CGFloat value = positionX / sliderWidth;
            
            [self changeSlideValue:value];
        }
        
        [gestureRecognizer setTranslation:CGPointZero inView:self];
        
    } else if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        
        CGPoint position = [gestureRecognizer locationInView:self];
        
        if(position.x < sliderStartPositionX) {
            [self changeSlideValue:0];
        } else if(position.x > sliderStartPositionX + sliderWidth) {
            [self changeSlideValue:1];
        } else {
            CGFloat positionX = position.x - sliderStartPositionX;
            CGFloat value = positionX / sliderWidth;
            
            [self changeSlideValue:value];
        }
        
    }
}


@end
