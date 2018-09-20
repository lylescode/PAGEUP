//
//  SnapshotView.m
//  Page
//
//  Created by CMR on 3/30/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "SnapshotView.h"

@implementation SnapshotView

- (id)init
{
    self = [super init];
    if (self) {
        
        self.layer.cornerRadius = 0.0;
        self.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
        self.layer.shadowRadius = 5.0;
        self.layer.shadowOpacity = 0.4;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:imageView];
        self.snapshotImageView = imageView;
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        self.layer.cornerRadius = 0.0;
        self.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
        self.layer.shadowRadius = 5.0;
        self.layer.shadowOpacity = 0.4;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        //imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.frame = self.bounds;
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:imageView];
        self.snapshotImageView = imageView;
        
        /*
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(imageView);
        NSArray *imageView_H = [NSLayoutConstraint
                                     constraintsWithVisualFormat:@"H:|[imageView]|"
                                     options:0
                                     metrics:nil
                                     views:viewsDictionary];
        NSArray *imageView_V = [NSLayoutConstraint
                                     constraintsWithVisualFormat:@"V:|[imageView]|"
                                     options:0
                                     metrics:nil
                                     views:viewsDictionary];
        
        
        [self addConstraints:imageView_H];
        [self addConstraints:imageView_V];
         */
        
    }
    return self;
}


- (void)dealloc
{
    [self.snapshotImageView removeFromSuperview];
    self.snapshotImageView = nil;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.snapshotImageView.frame = self.bounds;
}


- (void)setSnapshotImage:(UIImage *)snapshotImage
{
    self.snapshotImageView.image = snapshotImage;
    self.snapshotImageView.frame = self.bounds;
}

@end
