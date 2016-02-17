//
//  HXHomePageCollectionViewFlowLayout.m
//  mia
//
//  Created by miaios on 16/2/17.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXHomePageCollectionViewFlowLayout.h"
#import "UIView+Frame.h"

@implementation HXHomePageCollectionViewFlowLayout

#pragma mark - Awake Methods
- (void)awakeFromNib {
    self.minimumLineSpacing = 10.0f;
    self.sectionInset = UIEdgeInsetsMake(0.0f, 20.0f, 20.0f, 20.0f);
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalOffset = proposedContentOffset.x + 5;
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0, self.collectionView.width, self.collectionView.height);
    
    NSArray *array = [super layoutAttributesForElementsInRect:targetRect];
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in array) {
        CGFloat itemOffset = layoutAttributes.frame.origin.x;
        if (ABS(itemOffset - horizontalOffset) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemOffset - horizontalOffset;
        }
    }
    
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}

@end
