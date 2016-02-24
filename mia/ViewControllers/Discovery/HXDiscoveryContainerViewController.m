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
    [(EBCardCollectionViewLayout *)self.collectionView.collectionViewLayout setOffset:UIOffsetMake(30.0f, 20.0f)];
}

#pragma mark - Property
- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    [self.collectionView reloadData];
}

- (void)setShareList:(NSArray *)shareList {
    _shareList = shareList;
    
    [self.collectionView reloadData];
}

#pragma mark - Private Methods

#pragma mark - UICollectionView Data Source Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _shareList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HXDiscoveryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HXDiscoveryCell class]) forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    HXDiscoveryCell *discoveryCell = (HXDiscoveryCell *)cell;
    [discoveryCell displayWithItem:_shareList[indexPath.row]];
}

#pragma mark - UICollectionView Delegate Methods
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ;
}

#pragma mark - UIScrollView Delegate Methods
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSInteger page = ((EBCardCollectionViewLayout *)self.collectionView.collectionViewLayout).currentPage;
    if (page < _currentPage) {
        if (_delegate && [_delegate respondsToSelector:@selector(containerViewController:takeAction:)]) {
            [_delegate containerViewController:self takeAction:HXDiscoveryCardActionSlidePrevious];
        }
    } else if (page > _currentPage) {
        if (_delegate && [_delegate respondsToSelector:@selector(containerViewController:takeAction:)]) {
            [_delegate containerViewController:self takeAction:HXDiscoveryCardActionSlideNext];
        }
    }
    _currentPage = page;
}

@end
