//
//  ColorToolboardView.m
//  Page
//
//  Created by CMR on 4/13/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "ColorToolboardView.h"
#import "Utils.h"
#import "NSString+Color.h"
#import "ColorToolboardViewCell.h"

@interface ColorToolboardView ()
@property (strong, nonatomic) NSArray *colorStrings;
@property (nonatomic, retain) UICollectionView *itemCollectionView;
@end

@implementation ColorToolboardView


static NSString * const ReuseIdentifier = @"ColorToolboardViewCell";
static CGSize CellSize;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        if(!self.colorStrings) {
            self.colorStrings = @[
                                  @"ffffff",
                                  @"aaaaaa",
                                  @"555555",
                                  @"232323",
                                  @"000000",
                                  
                                  @"96adc9",
                                  @"5e7fa8",
                                  @"193857",
                                  @"0e1f2d",
                                  @"0f1217",
                                  
                                  @"acc7ff",
                                  @"6f9eff",
                                  @"3c7bfd",
                                  @"284e9a",
                                  @"162b56",
                                  
                                  @"98f2f8",
                                  @"35cdd7",
                                  @"008997",
                                  @"004854",
                                  @"03262d",
                                  
                                  @"71cd9d",
                                  @"3cab72",
                                  @"008444",
                                  @"004c27",
                                  @"012c17",
                                  
                                  @"e4e596",
                                  @"cfd54c",
                                  @"a9b301",
                                  @"888701",
                                  @"444400",
                                  
                                  @"fcdd81",
                                  @"ffcb50",
                                  @"ffb610",
                                  @"ef8201",
                                  @"502c00",
                                  
                                  @"ff647f",
                                  @"fb405a",
                                  @"f32938",
                                  @"ba1920",
                                  @"881219",
                                  
                                  @"f9a5d4",
                                  @"f777c5",
                                  @"e52c9b",
                                  @"831559",
                                  @"560a3b",
                                  
                                  @"8e6cd0",
                                  @"673ab7",
                                  @"582cde",
                                  @"361787",
                                  @"290f66"
                                  ];
        }
        CGFloat viewWidth = self.frame.size.width - 20;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            CellSize = CGSizeMake(floor(viewWidth / 5), floor(viewWidth / 5));
        } else {
            if(self.frame.size.width < 1024) {
                viewWidth = self.frame.size.width - 40;
                CellSize = CGSizeMake(floor(viewWidth / 10), floor(viewWidth / 10));
            } else {
                viewWidth = self.frame.size.width - 40;
                CellSize = CGSizeMake(floor(viewWidth / 10) - 1, floor(viewWidth / 10) - 1);
            }
        }
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CellSize;
        flowLayout.minimumInteritemSpacing = 5;
        flowLayout.minimumLineSpacing = 5;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, self.frame.size.height - 44) collectionViewLayout:flowLayout];
        
        collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.pagingEnabled = NO;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.backgroundColor = [UIColor clearColor];
        [collectionView registerNib:[UINib nibWithNibName:@"ColorToolboardViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:ReuseIdentifier];
        
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
        [self.interfaceView bringSubviewToFront:self.closeButton];
    }
    return self;
}

- (void)dealloc
{
    [self.itemCollectionView removeFromSuperview];
    self.itemCollectionView = nil;
    self.colorStrings = nil;
}

- (void)refreshCollectionViewLayout
{
}

- (void)setTargetTextView:(UITextView *)textView
{
    [super setTargetTextView:textView];
    //NSLog(@"textView.textColor : %@", [Utils NSStringFromUIColor:textView.textColor]);
    
    for(NSString *colorString in self.colorStrings) {
        UIColor *presetColor = [colorString colorFromRGBcode];
        
        if(CGColorEqualToColor(textView.textColor.CGColor, presetColor.CGColor)) {
            NSInteger colorIndex = [self.colorStrings indexOfObject:colorString];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:colorIndex inSection:0];
            
            [self.itemCollectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
            return;
        }
    }
}


#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.colorStrings.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *colorString = [self.colorStrings objectAtIndex:indexPath.item];
    
    ColorToolboardViewCell *cell = (ColorToolboardViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:ReuseIdentifier forIndexPath:indexPath];
    
    cell.colorView.backgroundColor = [colorString colorFromRGBcode];
    cell.colorString = colorString;
    
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
    ColorToolboardViewCell *currentCell = (ColorToolboardViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    UIColor *newColor = [currentCell.colorString colorFromRGBcode];
    
    //self.selectedTextView.textColor = [currentCell.colorString colorFromRGBcode];
    
    [UIView transitionWithView:self.selectedTextView duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.selectedTextView.textColor = newColor;
    } completion:^(BOOL finished) {
    }];
    
    if(self.selectedTextView.layer.borderWidth > 0) {
        
        [UIView transitionWithView:self.selectedTextView duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.selectedTextView.layer.borderColor = newColor.CGColor;
        } completion:^(BOOL finished) {
        }];
    }
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
