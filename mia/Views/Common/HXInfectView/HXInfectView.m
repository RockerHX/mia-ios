//
//  HXInfectView.m
//  mia
//
//  Created by miaios on 16/2/25.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXInfectView.h"
#import "HXXib.h"

@implementation HXInfectView

HXXibImplementation

#pragma mark - Load Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    [_collectionView registerNib:[HXInfectCell nib] forCellWithReuseIdentifier:[HXInfectCell className]];
}

- (void)viewConfigure {
    ;
}

#pragma mark - Property
- (void)setInfecters:(NSArray<InfectUserItem *> *)infecters {
    _infecters = infecters;
    [_collectionView reloadData];
}

#pragma mark - Collection View Data Source Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _infecters.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HXInfectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[HXInfectCell className] forIndexPath:indexPath];
    return cell;
}

#pragma mark - Collection View Delegate Methods
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    HXInfectCell *infectCell = (HXInfectCell *)cell;
    if (indexPath.row) {
        [infectCell displayWithInfecter:_infecters[indexPath.row - 1]];
    } else {
        [infectCell displayInfected:_infected];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
