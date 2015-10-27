//
//  SearchSuggestionView.m
//  mia
//
//  Created by linyehui on 2015/09/29.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "SearchSuggestionView.h"
#import "SearchSuggestionCollectionViewCell.h"
#import "SearchSuggestionModel.h"

static NSString * const kSuggestionCellReuseIdentifier 		= @"SuggestionCellId";

static const CGFloat kSuggestionItemMarginH 	= 10;
static const CGFloat kSuggestionItemMarginV 	= 0;
static const CGFloat kSuggestionItemHeight		= 50;

@interface SearchSuggestionView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@end


@implementation SearchSuggestionView {
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
	CGFloat itemWidth = self.frame.size.width - kSuggestionItemMarginH * 2;
	layout.itemSize =CGSizeMake(itemWidth, kSuggestionItemHeight);

	//2.初始化collectionView
	_collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
												 collectionViewLayout:layout];
	_collectionView.backgroundColor = [UIColor whiteColor];
	[self addSubview:_collectionView];

	//3.注册collectionViewCell
	//注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
	[_collectionView registerClass:[SearchSuggestionCollectionViewCell class] forCellWithReuseIdentifier:kSuggestionCellReuseIdentifier];

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
	return [_searchSuggestionViewDelegate searchSuggestionViewModel].dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	SearchSuggestionCollectionViewCell *cell = (SearchSuggestionCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kSuggestionCellReuseIdentifier
																											   forIndexPath:indexPath];
	cell.dataItem = [_searchSuggestionViewDelegate searchSuggestionViewModel].dataSource[indexPath.row];

	return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat itemWidth = self.frame.size.width - kSuggestionItemMarginH * 2;
	return CGSizeMake(itemWidth, kSuggestionItemHeight);
}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
	return UIEdgeInsetsMake(10, 10, 10, 10);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
	return kSuggestionItemMarginH;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
	return kSuggestionItemMarginV;
}

//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	SearchSuggestionCollectionViewCell *cell = (SearchSuggestionCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
	[_searchSuggestionViewDelegate searchSuggestionViewDidSelectedItem:cell.dataItem];
}

@end
