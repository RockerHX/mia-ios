//
//  HXProfileCoverContainerViewController.m
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXProfileCoverContainerViewController.h"
#import "HXCoverContainerCell.h"

@interface HXProfileCoverContainerViewController () <
UICollectionViewDelegateFlowLayout
>
@end

@implementation HXProfileCoverContainerViewController

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

+ (NSString *)segueIdentifier {
    return @"HXProfileCoverContainerIdentifier";
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    ;
}

- (void)viewConfigure {
    ;
}

#pragma mark - Setter And Getter
- (void)setDataSource:(NSArray *)dataSource {
    NSMutableArray *mutableArray = dataSource.mutableCopy;
    [mutableArray addObjectsFromArray:dataSource];
    _dataSource = mutableArray.copy;
    
    [self.collectionView reloadData];
}

#pragma mark -

#pragma mark - Collection View Data Source Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HXCoverContainerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HXCoverContainerCell class]) forIndexPath:indexPath];
    cell.backgroundColor = UIColorFromRGB(arc4random() % 255, arc4random() % 255, arc4random() % 255);
    [cell displayWithURL:_dataSource[indexPath.row]];
    return cell;
}

#pragma mark - Collection View Delegate Methods
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemSize = SCREEN_WIDTH/4;
    CGSize size = CGSizeMake(itemSize, itemSize);
    NSInteger sizeInteger = itemSize;
    CGFloat diff = itemSize - sizeInteger;
    if (diff) {
        NSInteger row = indexPath.row;
        if (!(row%4) || ((row%4) == 3)) {
            CGFloat width = sizeInteger + diff*2;
            size = CGSizeMake(width, sizeInteger);
        } else {
            size = CGSizeMake(sizeInteger, sizeInteger);
        }
    }
    return size;
}

@end
