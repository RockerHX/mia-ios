//
//  FavoriteViewController.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "FavoriteViewController.h"
#import "MIAButton.h"
#import "MIALabel.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+BlurredImage.h"
#import "FavoriteCollectionViewCell.h"
#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"
#import "MIALabel.h"
#import "FavoriteMgr.h"
#import "Masonry.h"
#import "MJRefresh.h"

static NSString * const kFavoriteCellReuseIdentifier 		= @"FavoriteCellId";
//static NSString * const kFavoriteHeaderReuseIdentifier 		= @"FavoriteHeaderId";

static const CGFloat kFavoriteCVMarginTop	= 200;
static const CGFloat kFavoriteItemMarginH 	= 15;
static const CGFloat kFavoriteItemMarginV 	= 14;
static const CGFloat kFavoriteHeaderHeight 	= 64;
static const CGFloat kFavoriteItemHeight	= 50;
const static CGFloat kBottomViewHeight 		= 40;
const static CGFloat kFavoriteAlpha 		= 0.9;

@interface FavoriteViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@end

@implementation FavoriteViewController {
	UIImageView	*_bgView;
	MIAButton 	*_closeButton;

	UIView 		*_favoriteHeaderView;
	MIALabel	*_titleLeftLabel;
	MIALabel	*_titleMiddleLabel;
	MIAButton 	*_playButton;
	MIALabel	*_titleRightLabel;

	BOOL 		_isEditing;
	BOOL		_isSelectAll;
}

- (id)initWitBackground:(UIImage *)backgroundImage {
	self = [super init];
	if (self) {
		[self initBackground:backgroundImage];
		[self initTopView];

		_favoriteHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, kFavoriteCVMarginTop, self.view.bounds.size.width, kFavoriteHeaderHeight)];
		_favoriteHeaderView.backgroundColor = [UIColor whiteColor];
		_favoriteHeaderView.alpha = kFavoriteAlpha;
		[self.view addSubview:_favoriteHeaderView];
		[self initHeaderView:_favoriteHeaderView];

		[self initCollectionView];
		[self initBottomView];
	}

	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:animated];
	[self updateFavoriteCount:[[FavoriteMgr standard] favoriteCount]];
	if ([[WebSocketMgr standard] isOpen]) {
		[_titleRightLabel setEnabled:YES];
	} else {
		[_titleRightLabel setEnabled:NO];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
	return NO;
}

- (void)initBackground:(UIImage *)backgroundImage {
//	self.view.backgroundColor = [UIColor redColor];
//	NSLog(@"bg: %f, %f %f", backgroundImage.size.width, backgroundImage.size.height, backgroundImage.scale);
//	NSLog(@"bounds: %@", NSStringFromCGRect(self.view.bounds));
	_bgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	if (backgroundImage) {
		[_bgView setImageToBlur:backgroundImage blurRadius:3.0 completionBlock:nil];
	}
	[self.view addSubview:_bgView];
}

- (void)setBackground:(UIImage *)backgroundImage {
	[_bgView setImageToBlur:backgroundImage blurRadius:3.0 completionBlock:nil];
}

- (void)initTopView {
	UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kFavoriteCVMarginTop)];
	[self.view addSubview:topView];

	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedTopView)];
	gesture.numberOfTapsRequired = 1;
	[topView addGestureRecognizer:gesture];
}

- (void)initBottomView {
	const static CGFloat kLineViewHeight = 1;

	UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - kBottomViewHeight, self.view.bounds.size.width, kBottomViewHeight)];
	bottomView.backgroundColor = [UIColor whiteColor];
	bottomView.alpha = kFavoriteAlpha;
	[self.view addSubview:bottomView];

	UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bottomView.bounds.size.width, kLineViewHeight)];
	lineView.backgroundColor = UIColorFromHex(@"d2d2d2", 1.0);
	[bottomView addSubview:lineView];

	_closeButton = [[MIAButton alloc] initWithFrame:CGRectMake(0,
																		kLineViewHeight,
																		bottomView.bounds.size.width,
																		bottomView.bounds.size.height - kLineViewHeight)
												 titleString:@"关闭"
												  titleColor:UIColorFromHex(@"ff300e", 1.0)
														font:UIFontFromSize(16)
													 logoImg:nil
											 backgroundImage:nil];
	[_closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[bottomView addSubview:_closeButton];
}

- (void)initCollectionView {
	//1.初始化layout
	UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
	//设置collectionView滚动方向
	//    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
	//设置headerView的尺寸大小
	//layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, kFavoriteHeaderHeight);

	//该方法也可以设置itemSize
	CGFloat itemWidth = self.view.frame.size.width - kFavoriteItemMarginH * 2;
	layout.itemSize =CGSizeMake(itemWidth, kFavoriteItemHeight);

	//2.初始化collectionView
	_favoriteCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,
																			kFavoriteCVMarginTop + kFavoriteHeaderHeight,
																			self.view.bounds.size.width,
																			self.view.bounds.size.height - kFavoriteCVMarginTop - kBottomViewHeight - kFavoriteHeaderHeight)
											collectionViewLayout:layout];
	[self.view addSubview:_favoriteCollectionView];
	_favoriteCollectionView.backgroundColor = [UIColor whiteColor];
	_favoriteCollectionView.alpha = kFavoriteAlpha;

	//3.注册collectionViewCell
	//注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
	[_favoriteCollectionView registerClass:[FavoriteCollectionViewCell class] forCellWithReuseIdentifier:kFavoriteCellReuseIdentifier];

	//注册headerView  此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致  均为reusableView
//	[_favoriteCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kFavoriteHeaderReuseIdentifier];

	//4.设置代理
	_favoriteCollectionView.delegate = self;
	_favoriteCollectionView.dataSource = self;
}

- (void)initHeaderView:(UIView *)contentView {
	_titleLeftLabel = [[MIALabel alloc] initWithFrame:CGRectZero
										  text:@"收藏"
										  font:UIFontFromSize(16.0f)
										   textColor:[UIColor blackColor]
									   textAlignment:NSTextAlignmentLeft
								   numberLines:1];
	[_titleLeftLabel setUserInteractionEnabled:YES];
	[_titleLeftLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleLeftLabelTouchAction:)]];
//	_titleLeftLabel.backgroundColor = [UIColor greenColor];
	[_favoriteHeaderView addSubview:_titleLeftLabel];
	[_titleLeftLabel setHidden:YES];

	_playButton = [[MIAButton alloc] initWithFrame:CGRectZero
									  titleString:nil
									   titleColor:nil
											 font:nil
										  logoImg:[UIImage imageNamed:@"play_black"]
								  backgroundImage:nil];
	[_playButton setContentMode:UIViewContentModeCenter];
	[_playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//	_playButton.backgroundColor = [UIColor yellowColor];
	[_favoriteHeaderView addSubview:_playButton];

	_titleMiddleLabel = [[MIALabel alloc] initWithFrame:CGRectZero
												 text:@"收藏(0首)"
												 font:UIFontFromSize(16.0f)
											textColor:[UIColor blackColor]
										textAlignment:NSTextAlignmentCenter
										  numberLines:1];
//	_titleMiddleLabel.backgroundColor = [UIColor orangeColor];
	[_favoriteHeaderView addSubview:_titleMiddleLabel];

	_titleRightLabel = [[MIALabel alloc] initWithFrame:CGRectZero
												 text:@"编辑"
												 font:UIFontFromSize(16.0f)
											textColor:[UIColor blackColor]
										textAlignment:NSTextAlignmentRight
										  numberLines:1];
	[_titleRightLabel setUserInteractionEnabled:YES];
	[_titleRightLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleRightLabelTouchAction:)]];
//	_titleRightLabel.backgroundColor = [UIColor greenColor];
	[_favoriteHeaderView addSubview:_titleRightLabel];


	[_titleLeftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(contentView.mas_centerY);
		make.left.equalTo(contentView.mas_left).offset(15);
		make.width.mas_greaterThanOrEqualTo(@50);
		make.height.mas_greaterThanOrEqualTo(@70);
	}];
	[_titleLeftLabel setContentHuggingPriority:UILayoutPriorityRequired
							   forAxis:UILayoutConstraintAxisHorizontal];

	[_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(contentView.mas_centerY);
		make.size.mas_equalTo(CGSizeMake(40, 40));
		make.left.equalTo(contentView.mas_left).offset(6);
	}];


	[_titleMiddleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(contentView.mas_centerY);
		make.left.equalTo(contentView.mas_left).offset(50);
		make.right.equalTo(contentView.mas_right).offset(-50);
	}];

	[_titleRightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(contentView.mas_centerY);
		make.right.equalTo(contentView.mas_right).offset(-15);
		make.width.mas_greaterThanOrEqualTo(@50);
		make.height.mas_greaterThanOrEqualTo(@70);
	}];
	[_titleRightLabel setContentHuggingPriority:UILayoutPriorityRequired
									   forAxis:UILayoutConstraintAxisHorizontal];

}

- (void)setIsPlaying:(BOOL)isPlaying {
	_isPlaying = isPlaying;
	if (isPlaying) {
		[_playButton setImage:[UIImage imageNamed:@"pause_black"] forState:UIControlStateNormal];
	} else {
		[_playButton setImage:[UIImage imageNamed:@"play_black"] forState:UIControlStateNormal];
	}
}

- (void)updateSelectedCount {
	if (_favoriteViewControllerDelegate) {
		int selectedCount = [_favoriteViewControllerDelegate favoriteViewControllerSelectedCount];
		[_titleMiddleLabel setText:[NSString stringWithFormat:@"已选择%d首", selectedCount]];
		[_titleMiddleLabel setTextColor:selectedCount == 0 ? UIColorFromHex(@"808080", 1.0) : [UIColor blackColor]];
	}
}

- (void)updateFavoriteCount:(long)count {
	[_titleMiddleLabel setText:[NSString stringWithFormat:@"收藏(%ld首)", count]];
	[_titleMiddleLabel setTextColor:count == 0 ? UIColorFromHex(@"808080", 1.0) : [UIColor blackColor]];
}

#pragma mark - delegate

#pragma mark collectionView代理方法

//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [FavoriteMgr standard].dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	FavoriteCollectionViewCell *cell = (FavoriteCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kFavoriteCellReuseIdentifier
																												 forIndexPath:indexPath];
	cell.rowIndex = indexPath.row;
	cell.isEditing = _isEditing;
	if (_favoriteViewControllerDelegate) {
		FavoriteItem *item = [FavoriteMgr standard].dataSource[indexPath.row];
		item.isPlaying = ([FavoriteMgr standard].playingIndex == indexPath.row);
		cell.dataItem = item;
	}

	return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat itemWidth = self.view.frame.size.width - kFavoriteItemMarginH * 2;
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
	NSInteger lastPlayingRow = [FavoriteMgr standard].playingIndex;
	if (_isEditing) {
		FavoriteCollectionViewCell *playingIndexCell = (FavoriteCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
		playingIndexCell.dataItem.isSelected = !playingIndexCell.dataItem.isSelected;
		[playingIndexCell updateSelectedState];
		[_favoriteCollectionView reloadItemsAtIndexPaths:[[NSArray alloc] initWithObjects:indexPath, nil]];
		[self updateSelectedCount];
	} else {
		if (lastPlayingRow == indexPath.row)
			return;

		NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastPlayingRow inSection:0];
		FavoriteCollectionViewCell *lastPlayingCell = (FavoriteCollectionViewCell *)[collectionView cellForItemAtIndexPath:lastIndexPath];
		lastPlayingCell.dataItem.isPlaying = NO;
		[lastPlayingCell updatePlayingState];

		FavoriteCollectionViewCell *playingIndexCell = (FavoriteCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
		playingIndexCell.dataItem.isPlaying = YES;
		[playingIndexCell updatePlayingState];

		[FavoriteMgr standard].playingIndex = indexPath.row;
		[_favoriteViewControllerDelegate favoriteViewControllerPlayMusic:[FavoriteMgr standard].playingIndex];

		[_favoriteCollectionView reloadItemsAtIndexPaths:[[NSArray alloc] initWithObjects:lastIndexPath, indexPath, nil]];
	}
}

#pragma mark - Notification

#pragma mark - button Actions

- (void)backButtonAction:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)settingButtonAction:(id)sender {
	NSLog(@"setting button clicked.");
}

- (void)touchedTopView {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)playButtonAction:(id)sender {
	if (_isPlaying) {
		[_favoriteViewControllerDelegate favoriteViewControllerPauseMusic];
	} else {
		[_favoriteViewControllerDelegate favoriteViewControllerPlayMusic:[FavoriteMgr standard].playingIndex];
	}
}

- (void)titleLeftLabelTouchAction:(id)sender {
	if (!_isEditing) {
		return;
	}
	if (!_favoriteViewControllerDelegate) {
		return;
	}

	_isSelectAll = !_isSelectAll;
	[_titleLeftLabel setText:_isSelectAll ? @"取消选择" : @"全选"];
	[_favoriteViewControllerDelegate favoriteViewControllerSelectAll:_isSelectAll];
	[self updateSelectedCount];
	[_favoriteCollectionView reloadData];
}

- (void)titleRightLabelTouchAction:(id)sender {
	if (![_titleRightLabel isEnabled]) {
		return;
	}

	_isEditing = !_isEditing;
	[_favoriteCollectionView reloadData];
	if (_isEditing) {
		[_titleLeftLabel setHidden:NO];
		[_playButton setHidden:YES];

		[_titleLeftLabel setText:_isSelectAll ? @"取消选择" : @"全选"];
		[_titleRightLabel setText:@"完成"];
		[_closeButton setTitle:@"删除" forState:UIControlStateNormal];
		[self updateSelectedCount];
	} else {
		[_titleLeftLabel setHidden:YES];
		[_playButton setHidden:NO];

		[_titleRightLabel setText:@"编辑"];
		[_closeButton setTitle:@"关闭" forState:UIControlStateNormal];
		[self updateFavoriteCount:[[FavoriteMgr standard] favoriteCount]];
	}
}

- (void)closeButtonAction:(id)sender {
	if (_isEditing) {
		if (_favoriteViewControllerDelegate) {
			if ([_favoriteViewControllerDelegate favoriteViewControllerDeleteMusics]) {
				[_favoriteCollectionView reloadData];
				[self updateFavoriteCount:[[FavoriteMgr standard] favoriteCount]];
			}
		}
	} else {
		[self.navigationController popViewControllerAnimated:YES];
	}

}

@end
