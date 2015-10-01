//
//  SearchResultView.m
//  mia
//
//  Created by linyehui on 2015/09/29.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "SearchResultView.h"
#import "SearchResultCollectionViewCell.h"
#import "SearchResultModel.h"

static NSString * const kSearchResultCellReuseIdentifier 		= @"SearchResultCellId";

static const CGFloat kSearchResultItemMarginH 	= 10;
static const CGFloat kSearchResultItemMarginV 	= 10;
static const CGFloat kSearchResultItemHeight		= 50;

@interface SearchResultView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@end


@implementation SearchResultView {
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self initCollectionView];
	}

	return self;
}

- (void)initCollectionView {
	//1.初始化layout
	UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];

	//该方法也可以设置itemSize
	CGFloat itemWidth = self.frame.size.width - kSearchResultItemMarginH * 2;
	layout.itemSize =CGSizeMake(itemWidth, kSearchResultItemHeight);

	//2.初始化collectionView
	_collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
												 collectionViewLayout:layout];
	_collectionView.backgroundColor = [UIColor whiteColor];
	[self addSubview:_collectionView];

	//3.注册collectionViewCell
	//注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
	[_collectionView registerClass:[SearchResultCollectionViewCell class] forCellWithReuseIdentifier:kSearchResultCellReuseIdentifier];

	//4.设置代理
	_collectionView.delegate = self;
	_collectionView.dataSource = self;
}


#pragma mark collectionView代理方法

//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [_searchResultViewDelegate searchResultViewModel].dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	SearchResultCollectionViewCell *cell = (SearchResultCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kSearchResultCellReuseIdentifier
																											   forIndexPath:indexPath];
	cell.dataItem = [_searchResultViewDelegate searchResultViewModel].dataSource[indexPath.row];

	return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat itemWidth = self.frame.size.width - kSearchResultItemMarginH * 2;
	return CGSizeMake(itemWidth, kSearchResultItemHeight);
}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
	return UIEdgeInsetsMake(10, 10, 10, 10);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
	return kSearchResultItemMarginH;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
	return kSearchResultItemMarginV;
}

//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	SearchResultCollectionViewCell *cell = (SearchResultCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
	[_searchResultViewDelegate searchResultViewDidSelectedItem:cell.dataItem];
}

@end
