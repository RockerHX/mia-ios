//
//  HXDiscoveryContainerViewController.m
//  mia
//
//  Created by miaios on 16/2/17.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXDiscoveryContainerViewController.h"
#import "EBCardCollectionViewLayout.h"
#import "HXDiscoveryCell.h"

@interface HXDiscoveryContainerViewController ()

@end

@implementation HXDiscoveryContainerViewController

#pragma mark - View Controller Lift Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    ;
}

- (void)viewConfigure {
    // CollectionView Configure
    [(EBCardCollectionViewLayout *)self.collectionView.collectionViewLayout setOffset:UIOffsetMake(30.0f, 0.0f)];
//    [(EBCardCollectionViewLayout *)self.collectionView.collectionViewLayout setInsets:UIEdgeInsetsMake(0.0f, 10.0f, 20.0f, 10.0f)];
}

#pragma mark - Private Methods

#pragma mark - UICollectionView Data Source Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HXDiscoveryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HXDiscoveryCell class]) forIndexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionView Delegate Methods
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ;
}

@end
