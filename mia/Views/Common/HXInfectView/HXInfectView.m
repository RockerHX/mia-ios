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
- (void)setInfected:(BOOL)infected {
    _infected = infected;
    
    [_infectButton setImage:[UIImage imageNamed:(infected ? @"D-InfectedIcon": @"D-InfectIcon")] forState:UIControlStateNormal];
}

- (void)setInfecters:(NSArray<InfectUserItem *> *)infecters {
    _infecters = infecters;
    NSInteger count = infecters.count;
    CGFloat constant = ((count * 32.0f) + (count * 5.0f));
    _controlToSpace = 60.0f + constant;
    _collectionViewWidthConstraint.constant = constant;
    [_collectionView reloadData];
    
    if (_delegate && [_delegate respondsToSelector:@selector(infectView:takeAction:)]) {
        [_delegate infectView:self takeAction:HXInfectViewActionLayout];
    }
}

#pragma mark - Event Response
- (IBAction)infectButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(infectView:takeAction:)]) {
        [_delegate infectView:self takeAction:HXInfectViewActionInfect];
    }
}

#pragma mark - Collection View Data Source Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _infecters.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HXInfectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[HXInfectCell className] forIndexPath:indexPath];
    return cell;
}

#pragma mark - Collection View Delegate Methods
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    HXInfectCell *infectCell = (HXInfectCell *)cell;
    [infectCell displayWithInfecter:_infecters[indexPath.row]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_delegate && [_delegate respondsToSelector:@selector(infectViewInfecterTaped:atIndex:)]) {
        [_delegate infectViewInfecterTaped:self atIndex:(indexPath.row - 1)];
    }
}

@end
