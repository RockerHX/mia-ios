//
//  HXHomePageContainerViewController.m
//  mia
//
//  Created by miaios on 16/2/17.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXHomePageContainerViewController.h"
#import "UIView+Frame.h"
#import "EBCardCollectionViewLayout.h"

@interface HXHomePageContainerViewController ()

@end

@implementation HXHomePageContainerViewController

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
    UIOffset anOffset = UIOffsetZero;
    anOffset = UIOffsetMake(40.0f, 0.0f);
    [(EBCardCollectionViewLayout *)self.collectionView.collectionViewLayout setOffset:anOffset];
    [(EBCardCollectionViewLayout *)self.collectionView.collectionViewLayout setLayoutType:EBCardCollectionLayoutHorizontal];
}

#pragma mark - Private Methods

#pragma mark - UICollectionView Data Source Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionView Delegate Methods
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ;
}

@end
