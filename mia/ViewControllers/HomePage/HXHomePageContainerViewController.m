//
//  HXHomePageContainerViewController.m
//  mia
//
//  Created by miaios on 16/2/17.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXHomePageContainerViewController.h"
#import "UIView+Frame.h"

@interface HXHomePageContainerViewController ()

@end

@implementation HXHomePageContainerViewController

#pragma mark - View Controller Lift Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - UICollectionView Data Source Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionView Delegate Methods
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = self.view.width - 40.0f;
    CGFloat itemHeight = self.view.height - 20.0f;
    return CGSizeMake(itemWidth, itemHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ;
}

@end
