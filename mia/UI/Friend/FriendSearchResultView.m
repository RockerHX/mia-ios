//
//  FriendSearchResultView.m
//  mia
//
//  Created by linyehui on 2015/09/29.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "FriendSearchResultView.h"
#import "FriendSearchResultCollectionViewCell.h"
#import "FriendModel.h"
#import "FriendItem.h"
#import "MJRefresh.h"
#import "Masonry.h"
#import "MIALabel.h"

static NSString * const kSearchResultCellReuseIdentifier 		= @"SearchResultCellId";

static const CGFloat kSearchResultItemMarginH 	= 10;
static const CGFloat kSearchResultItemMarginV 	= 0;
static const CGFloat kSearchResultItemHeight	= 100;

@interface FriendSearchResultView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FriendSearchResultCellDelegate>

@end


@implementation FriendSearchResultView {
	UIView		*_noDataView;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self initCollectionView];
		[self initNoDataView:self];
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
	_collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
	_collectionView.backgroundColor = [UIColor whiteColor];
	[self addSubview:_collectionView];
	[_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
	}];

	//3.注册collectionViewCell
	//注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
	[_collectionView registerClass:[FriendSearchResultCollectionViewCell class] forCellWithReuseIdentifier:kSearchResultCellReuseIdentifier];

	//4.设置代理
	_collectionView.delegate = self;
	_collectionView.dataSource = self;

	//[_collectionView addFooterWithTarget:self action:@selector(requestMoreItems)];
	MJRefreshAutoNormalFooter *aFooter = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(requestMoreItems)];
	[aFooter setTitle:@"上拉加载更多" forState:MJRefreshStateIdle];
	[aFooter setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
	_collectionView.mj_footer = aFooter;


}

- (void)initNoDataView:(UIView *)contentView {
	_noDataView = [[UIView alloc] init];
	[contentView addSubview:_noDataView];

	MIALabel *noDataLabel = [[MIALabel alloc] initWithFrame:CGRectZero
															text:@"暂没有找到相关歌曲"
															font:UIFontFromSize(16.0f)
													   textColor:UIColorFromHex(@"808080", 1.0)
												   textAlignment:NSTextAlignmentCenter
													 numberLines:1];
	[_noDataView addSubview:noDataLabel];

	[_noDataView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(contentView.mas_centerX);
		make.centerY.equalTo(contentView.mas_centerY).offset(-20);
	}];
	[noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
	}];
}

- (void)requestMoreItems {
	[_customDelegate friendSearchResultViewRequestMoreItems];
}

- (void)setNoDataTipsHidden:(BOOL)hidden {
	[_noDataView setHidden:hidden];
}

- (void)endRefreshing {
	[_collectionView.mj_footer endRefreshing];
}

#pragma mark collectionView代理方法

//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [_customDelegate friendSearchResultViewModel].dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	FriendSearchResultCollectionViewCell *cell = (FriendSearchResultCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kSearchResultCellReuseIdentifier
																											   forIndexPath:indexPath];
	cell.dataItem = [_customDelegate friendSearchResultViewModel].dataSource[indexPath.row];
	cell.indexPath = indexPath;
	cell.cellDelegate = self;

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
	FriendSearchResultCollectionViewCell *cell = (FriendSearchResultCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
	[_customDelegate friendSearchResultViewDidSelectedItem:cell.dataItem];
}

#pragma mark - delegate 

- (void)friendSearchResultCellClickedPlayButtonAtIndexPath:(NSIndexPath *)indexPath {
	if (!indexPath) {
		return;
	}

	NSLog(@"%ld", (long)indexPath.row);
}

@end
