//
//  MosaicCollectionViewLayout.h
//  Page
//
//  Created by CMR on 5/7/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kHeightModule 40
#define kLeftMargin 10
#define kItemSpacing 10
#define kItemLineSpacing 10

@protocol MosaicCollectionViewLayoutDelegate <NSObject>

/*  Returns the relative height of a particular cell at an index path.
 *
 *  Relative height means how tall the cell will be in comparisson with its width.
 *  i.e. if the relative height is 1, the cell is square.
 *  If the relative height is 2, the cell has twice the height than its width. */
- (CGFloat)collectionView:(UICollectionView *)collectionView relativeHeightForItemAtIndexPath:(NSIndexPath *)indexPath;

/*  Returns if the cell at a particular index path can be shown as "double column"
 *
 *  That doesn't mean it WILL be displayed as "double column" because it needs 2 consecutive
 *  columns with the same size */
- (BOOL)collectionView:(UICollectionView *)collectionView isDoubleColumnAtIndexPath:(NSIndexPath *)indexPath;

//  Returns the amount of columns that have to display at that moment
- (NSUInteger)numberOfColumnsInCollectionView:(UICollectionView *)collectionView;

@end


@interface MosaicCollectionViewLayout : UICollectionViewLayout
{
    NSMutableArray *_columns;
    NSMutableArray *_itemsAttributes;
    
}

@property (weak) id <MosaicCollectionViewLayoutDelegate> delegate;
@property (readonly) NSUInteger columnsQuantity;

- (NSUInteger)shortestColumnIndex;
- (NSUInteger)longestColumnIndex;
- (BOOL)canUseDoubleColumnOnIndex:(NSUInteger)columnIndex;
- (CGFloat)columnWidth;

@end
