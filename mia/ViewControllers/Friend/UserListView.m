//
//  UserListView.m
//  mia
//
//  Created by linyehui on 2015/09/29.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "UserListView.h"
#import "UserCollectionViewCell.h"
#import "UserListModel.h"
#import "UserItem.h"
#import "MJRefresh.h"
#import "Masonry.h"
#import "MIALabel.h"
#import "UIConstants.h"

static NSString * const kUserListViewCellReuseIdentifier 		= @"UserListViewCellId";

static const CGFloat kUserListViewItemMarginH 	= 10;
static const CGFloat kUserListViewItemMarginV 	= 0;
static const CGFloat kUserListViewItemHeight	= 68;

@interface UserListView () <
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UserCollectionViewCellDelegate
>

@end


@implementation UserListView {
	UserListViewType	_type;
	UIView				*_noDataView;
}

- (id)initWithType:(UserListViewType)type {
	self = [super init];
	if (self) {
		_type = type;
		[self initCollectionView];
		[self initNoDataView:self];
	}

	return self;
}

- (void)initCollectionView {
	//1.初始化layout
	UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];

	//该方法也可以设置itemSize
	CGFloat itemWidth = self.frame.size.width - kUserListViewItemMarginH * 2;
	layout.itemSize =CGSizeMake(itemWidth, kUserListViewItemHeight);

	//2.初始化collectionView
	_collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
	_collectionView.backgroundColor = [UIColor whiteColor];
	[self addSubview:_collectionView];
	[_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
	}];

	//3.注册collectionViewCell
	//注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
	[_collectionView registerClass:[UserCollectionViewCell class] forCellWithReuseIdentifier:kUserListViewCellReuseIdentifier];

	//4.设置代理
	_collectionView.delegate = self;
	_collectionView.dataSource = self;

	MJRefreshNormalHeader *aHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestNewItems)];
	[aHeader setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
	[aHeader setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
	_collectionView.mj_header = aHeader;

	MJRefreshAutoNormalFooter *aFooter = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(requestMoreItems)];
	[aFooter setTitle:@"" forState:MJRefreshStateIdle];
	[aFooter setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
	[aFooter setAutomaticallyHidden:YES];
	_collectionView.mj_footer = aFooter;

}

- (void)initNoDataView:(UIView *)contentView {
	_noDataView = [[UIView alloc] init];
	[contentView addSubview:_noDataView];

	NSString *tips = @"";
	switch (_type) {
		case UserListViewTypeFans:
			tips = @"还没有粉丝";
			break;
		case UserListViewTypeFollowing:
			tips = @"没关注任何人";
			break;
		case UserListViewTypeSearch:
			tips = @"没有找到相关用户";
			break;
		default:
			break;
	}

	MIALabel *noDataLabel = [[MIALabel alloc] initWithFrame:CGRectZero
															text:tips
															font:[UIFont systemFontOfSize:16.0f]
													   textColor:UIColorByHex(0x808080)
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

- (void)requestNewItems {
	[_customDelegate userListViewRequesNewItemsWithType:_type];
}

- (void)requestMoreItems {
	[_customDelegate userListViewRequestMoreItemsWithType:_type];
}

- (void)setNoDataTipsHidden:(BOOL)hidden {
	[_noDataView setHidden:hidden];
}

- (void)checkNoDataTipsStatus {
	if ([_customDelegate userListViewModelWithType:_type].dataSource.count > 0) {
		[self setNoDataTipsHidden:YES];
	} else {
		[self setNoDataTipsHidden:NO];
	}
}

- (void)beginHeaderRefreshing {
	[_collectionView.mj_header beginRefreshing];
}

- (void)endAllRefreshing {
	[_collectionView.mj_header endRefreshing];
	[_collectionView.mj_footer endRefreshing];
}

#pragma mark collectionView代理方法

//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [_customDelegate userListViewModelWithType:_type].dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	UserCollectionViewCell *cell = (UserCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kUserListViewCellReuseIdentifier
																											   forIndexPath:indexPath];

	if ([_customDelegate userListViewModelWithType:_type].dataSource.count) {
		cell.dataItem = [_customDelegate userListViewModelWithType:_type].dataSource[indexPath.row];
		cell.indexPath = indexPath;
		cell.delegate = self;
	} else {
		NSLog(@"UserListView data sync error");
	}

	return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat itemWidth = self.frame.size.width - kUserListViewItemMarginH * 2;
	return CGSizeMake(itemWidth, kUserListViewItemHeight);
}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
	return UIEdgeInsetsMake(10, 10, 10, 10);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
	return kUserListViewItemMarginH;
}

//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
	return kUserListViewItemMarginV;
}

//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	UserCollectionViewCell *cell = (UserCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
	if (_customDelegate && [_customDelegate respondsToSelector:@selector(userListViewDidSelectedItem:)]) {
		[_customDelegate userListViewDidSelectedItem:cell.dataItem];
	}
}

#pragma mark - UserCollectionViewCellDelegate Methods
- (void)userCollectionViewCellFollowUID:(NSString *)uID
							   isFollow:(BOOL)isFollow
						 completedBlock:(UserCollectionViewCellCompletedBlock)completedBlock {
	if (_customDelegate && [_customDelegate respondsToSelector:@selector(userListViewFollowUID:isFollow:completedBlock:)]) {
		[_customDelegate userListViewFollowUID:uID isFollow:isFollow completedBlock:completedBlock];
	}
}

@end
