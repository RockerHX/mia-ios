//
//  HXProfileCoverContainerViewController.m
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXProfileCoverContainerViewController.h"

@interface HXProfileCoverContainerViewController ()
@end

@implementation HXProfileCoverContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

+ (NSString *)segueIdentifier {
    return @"HXProfileCoverContainerIdentifier";
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"" forIndexPath:indexPath];
    return cell;
}

@end
