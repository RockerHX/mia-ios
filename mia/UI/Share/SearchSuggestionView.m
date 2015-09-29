//
//  SearchSuggestionView.m
//  mia
//
//  Created by linyehui on 2015/09/29.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "SearchSuggestionView.h"
#import "WebSocketMgr.h"
#import "MiaAPIHelper.h"
#import "SearchSuggestionCollectionViewCell.h"
#import "SearchSuggestionModel.h"

static NSString * const kFavoriteCellReuseIdentifier 		= @"FavoriteCellId";

static const CGFloat kFavoriteItemMarginH 	= 10;
static const CGFloat kFavoriteItemMarginV 	= 10;
static const CGFloat kFavoriteItemHeight	= 50;
const static CGFloat kFavoriteAlpha 		= 0.9;

@interface SearchSuggestionView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@end


@implementation SearchSuggestionView {
	SearchSuggestionModel *model;
	UICollectionView *_favoriteCollectionView;
}

- (id)init {
	self = [super init];
	if (self) {
		[self initCollectionView];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidReceiveMessage:) name:WebSocketMgrNotificationDidReceiveMessage object:nil];
	}

	return self;
}

- (void)initCollectionView {
	//1.初始化layout
	UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];

	//该方法也可以设置itemSize
	CGFloat itemWidth = self.frame.size.width - kFavoriteItemMarginH * 2;
	layout.itemSize =CGSizeMake(itemWidth, kFavoriteItemHeight);

	//2.初始化collectionView
	_favoriteCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds
												 collectionViewLayout:layout];
	[self addSubview:_favoriteCollectionView];
	_favoriteCollectionView.backgroundColor = [UIColor whiteColor];
	_favoriteCollectionView.alpha = kFavoriteAlpha;

	//3.注册collectionViewCell
	//注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
	[_favoriteCollectionView registerClass:[SearchSuggestionCollectionViewCell class] forCellWithReuseIdentifier:kFavoriteCellReuseIdentifier];

	//4.设置代理
	_favoriteCollectionView.delegate = self;
	_favoriteCollectionView.dataSource = self;
}


#pragma mark collectionView代理方法

//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return model.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	SearchSuggestionCollectionViewCell *cell = (SearchSuggestionCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kFavoriteCellReuseIdentifier
																											   forIndexPath:indexPath];
	cell.rowIndex = indexPath.row;
	cell.favoriteItem = model.dataSource[indexPath.row];

	return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat itemWidth = self.frame.size.width - kFavoriteItemMarginH * 2;
	return CGSizeMake(itemWidth, kFavoriteItemHeight);
}

//footer的size
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
//{
//    return CGSizeMake(10, 10);
//}

//header的size
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
//{
//    return CGSizeMake(10, 10);
//}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
	return UIEdgeInsetsMake(10, 10, 10, 10);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
	return kFavoriteItemMarginH;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
	return kFavoriteItemMarginV;
}


//通过设置SupplementaryViewOfKind 来设置头部或者底部的view，其中 ReuseIdentifier 的值必须和 注册是填写的一致，本例都为 “reusableView”
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	//	if ([kind isEqual:UICollectionElementKindSectionHeader]) {
	//		UICollectionReusableView *contentView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kFavoriteHeaderReuseIdentifier forIndexPath:indexPath];
	//		if (contentView.subviews.count == 0) {
	//			[contentView addSubview:favoriteHeaderView];
	//		}
	//		return contentView;
	//	} else {
	NSLog(@"It's maybe a bug.");
	return nil;
	//	}
}

//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - Notification

- (void)notificationWebSocketDidReceiveMessage:(NSNotification *)notification {
	//	NSString *command = [notification userInfo][MiaAPIKey_ServerCommand];
	//	id ret = [notification userInfo][MiaAPIKey_Values][MiaAPIKey_Return];
	//NSLog(@"%@", command);
}

//- (void)handleGetFavoriteListWitRet:(int)ret userInfo:(NSDictionary *) userInfo {
//	[_favoriteCollectionView footerEndRefreshing];
//
//	NSArray *items = userInfo[@"v"][@"data"];
//	if (!items)
//		return;
//
//	[model addItemsWithArray:items];
//	[_favoriteCollectionView reloadData];
//}


@end
