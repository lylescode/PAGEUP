//
//  ColorToolboardView.h
//  Page
//
//  Created by CMR on 4/13/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "ToolboardView.h"

@interface ColorToolboardView : ToolboardView <UICollectionViewDataSource, UICollectionViewDelegate>

- (void)refreshCollectionViewLayout;
@end
