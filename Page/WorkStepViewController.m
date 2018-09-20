//
//  WorkStepViewController.m
//  Page
//
//  Created by CMR on 3/18/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "WorkStepViewController.h"

@interface WorkStepViewController ()

@end

@implementation WorkStepViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    activated = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)willActivateWork
{
    if(activated) {
        return;
    }
}
- (void)activateWork
{
    if(activated) {
        return;
    }
    activated = YES;
    //MARK;
}
- (void)deactivateWork
{
    if(!activated) {
        return;
    }
    activated = NO;
    //MARK;
}


- (BOOL)workInterfaceIsLandscape
{
    if(UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
    {
        return YES;
    }
    return NO;
}

- (void)prepareForSaveProject
{
    
}

@end
