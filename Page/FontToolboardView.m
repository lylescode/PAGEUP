//
//  FontToolboardView.m
//  Page
//
//  Created by CMR on 4/13/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "FontToolboardView.h"
#import "FontToolboardViewCell.h"
#import "FontData.h"

@interface FontToolboardView ()
@property (strong, nonatomic) NSArray *allFontNames;
@property (strong, nonatomic) UICollectionView *itemCollectionView;
@property (strong, nonatomic) NSString *selectedText;
@end


@implementation FontToolboardView


static NSString * const ReuseIdentifier = @"FontToolboardViewCell";
static CGSize CellSize;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        if(!self.allFontNames) {
            FontData *fontData = [[FontData alloc] init];
            self.allFontNames = fontData.fontDictionaryArray;
            
        }
        CellSize = CGSizeMake(floor(self.frame.size.width), 50);
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CellSize;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, self.frame.size.height - 44) collectionViewLayout:flowLayout];
        
        //collectionView.contentInset = UIEdgeInsetsMake(15, 0, 15, 0);
        collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.pagingEnabled = NO;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.backgroundColor = [UIColor colorWithRed:0.0546875 green:0.05859375 blue:0.06640625 alpha:1];
        
        [collectionView registerNib:[UINib nibWithNibName:@"FontToolboardViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:ReuseIdentifier];
        
        [self.interfaceView addSubview:collectionView];
        
        
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(collectionView);
        NSArray *collectionView_H = [NSLayoutConstraint
                                     constraintsWithVisualFormat:@"H:|[collectionView]|"
                                     options:0
                                     metrics:nil
                                     views:viewsDictionary];
        NSArray *collectionView_V = [NSLayoutConstraint
                                     constraintsWithVisualFormat:@"V:|-44-[collectionView]|"
                                     options:0
                                     metrics:nil
                                     views:viewsDictionary];
        
        [self addConstraints:collectionView_H];
        [self addConstraints:collectionView_V];
        
        self.itemCollectionView = collectionView;
        [self.closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [self.interfaceView bringSubviewToFront:self.closeButton];
        
    }
    return self;
}

- (void)dealloc
{
    [self.itemCollectionView removeFromSuperview];
    self.itemCollectionView = nil;
    self.allFontNames = nil;
}

- (void)setTargetTextView:(UITextView *)textView
{
    [super setTargetTextView:textView];
    
    NSString *newString = [self.selectedTextView.text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    newString = [[newString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
    
    self.selectedText = newString;
    NSLog(@"textView.font.fontName : %@", textView.font.fontName);
    
    for(NSDictionary *fontInfo in self.allFontNames) {
        
        NSString *fontName = fontInfo[@"fontName"];
        
        if([fontName isEqualToString:self.selectedTextView.font.fontName]) {
            NSInteger fontIndex = [self.allFontNames indexOfObject:fontInfo];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:fontIndex inSection:0];
            
            [self.itemCollectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
            return;
        }
    }

    /*
    for(FontToolboardViewCell *cell in [self.itemCollectionView visibleCells]) {
        cell.fontLabel.text = self.selectedText;
    }
     */
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.allFontNames.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *fontInfo = [self.allFontNames objectAtIndex:indexPath.item];
    NSString *fontName = fontInfo[@"fontName"];
    NSString *displayName = fontInfo[@"displayName"];
    
    FontToolboardViewCell *cell = (FontToolboardViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:ReuseIdentifier forIndexPath:indexPath];
    
    cell.fontLabel.font = [UIFont fontWithName:fontName size:cell.fontLabel.font.pointSize];
    cell.fontLabel.text = displayName;
    cell.fontName = fontName;
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     
     
     for (ImageItemCell *cell in collectionView.visibleCells) {
     [cell select:NO];
     }
     [currentCell select:YES];
     [self selectItem:currentCell];
     */
    FontToolboardViewCell *currentCell = (FontToolboardViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if(![currentCell.fontName isEqualToString:self.selectedTextView.font.fontName]) {
        [self.fontToolboardDelegate fontToolboardViewDidSelectFontName:currentCell.fontName];
    }
    //self.selectedTextView.font = [UIFont fontWithName:currentCell.fontName size:self.selectedTextView.font.pointSize];
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CellSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     FontItemCell *itemCell = (FontItemCell *)cell;
     if([itemCell.fontFamilyName isEqualToString:selectedFontFamilyName]) {
     [itemCell select:YES animation:NO];
     }
     */
}

@end
