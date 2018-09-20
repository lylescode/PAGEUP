//
//  FontToolboardView.h
//  Page
//
//  Created by CMR on 4/13/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "ToolboardView.h"

@protocol FontToolboardViewDelegate <NSObject>

- (void)fontToolboardViewDidSelectFontName:(NSString *)fontName;
@end

@interface FontToolboardView : ToolboardView <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) id<FontToolboardViewDelegate> fontToolboardDelegate;
@end
