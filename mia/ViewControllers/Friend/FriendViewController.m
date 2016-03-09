//
//  FriendViewController.m
//  mia
//
//  Created by linyehui on 2016/01/26.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "FriendViewController.h"
#import "MIAButton.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUDHelp.h"
#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"
#import "Masonry.h"
#import "NSString+IsNull.h"
#import "UserListView.h"
#import "UserListModel.h"
#import "UserItem.h"
#import "HXAlertBanner.h"
#import "YHSegmentedControl.h"
#import "HXProfileViewController.h"
#import "UIConstants.h"

static const long kUserListPageCount = 10;

@interface FriendViewController () <UITextFieldDelegate, YHSegmentedControlDelegate, UserListViewDelegate>
@end

@implementation FriendViewController {
    BOOL                    _pushed;
    
	UserListViewType		_initListViewType;
	NSString				*_currentUID;
	BOOL					_isHost;
	NSUInteger				_fansCount;
	NSUInteger				_followingCount;

	UserListModel 			*_fansModel;
	UserListModel 			*_followingModel;
	UserListModel 			*_searchResultModel;

	MIAButton 				*_backButton;
	UIView 					*_searchBox;
	UITextField 			*_searchTextField;
	MIAButton 				*_cancelButton;

	UIView					*_contentView;
	YHSegmentedControl 		*_segmentedControl;

	UserListView 			*_fansView;
	UserListView 			*_followingView;
	UserListView 			*_searchResultView;
}

- (instancetype)initWithType:(UserListViewType)type
                      isHost:(BOOL)isHost
                         uID:(NSString *)uID
                   fansCount:(NSUInteger)fansCount
              followingCount:(NSUInteger)followingCount {
	self = [super init];
	if (self) {
		_initListViewType = (NSInteger)type;
		_currentUID = uID;
		_isHost = isHost;
		_fansCount = fansCount;
        _followingCount = followingCount;
        
        self.hidesBottomBarWhenPushed = YES;
	}

	return self;
}

- (void)dealloc {
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
	[self initUI];
	[self initData];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:!_pushed];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	if (_delegate && [_delegate respondsToSelector:@selector(friendViewControllerActionDismiss)]) {
		[_delegate friendViewControllerActionDismiss];
	}
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
	return NO;
}

- (void)initUI {
	UIView *topView = [[UIView alloc] init];
	topView.backgroundColor = [UIColor blackColor];
	[self.view addSubview:topView];
	[self initTopView:topView];

	_contentView = [[UIView alloc] init];
	_contentView.backgroundColor = [UIColor redColor];
	[self.view addSubview:_contentView];
	[self initContentView:_contentView];
	

	_searchResultView = [[UserListView alloc] initWithType:UserListViewTypeSearch];
	_searchResultView.backgroundColor = [UIColor grayColor];
	_searchResultView.customDelegate = self;
	[self.view addSubview:_searchResultView];
	[_searchResultView setHidden:YES];

	[topView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(self.view.mas_top);
		make.left.equalTo(self.view.mas_left);
		make.right.equalTo(self.view.mas_right);
	}];

	[_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(topView.mas_bottom);
		make.left.equalTo(self.view.mas_left);
		make.right.equalTo(self.view.mas_right);
		make.bottom.equalTo(self.view.mas_bottom);
	}];

	[_searchResultView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(topView.mas_bottom);
		make.left.equalTo(self.view.mas_left);
		make.right.equalTo(self.view.mas_right);
		make.bottom.equalTo(self.view.mas_bottom);
	}];

	[self showSearchBox:_isHost];
}

- (void)initData {
	_fansModel = [[UserListModel alloc] init];
	_followingModel = [[UserListModel alloc] init];
	_searchResultModel = [[UserListModel alloc] init];

	// 页面切换
	[_segmentedControl switchToIndex:_initListViewType];
}

- (void)initTopView:(UIView *)contentView {
	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
	gesture.numberOfTapsRequired = 1;
	[contentView addGestureRecognizer:gesture];

	_backButton = [[MIAButton alloc] initWithFrame:CGRectZero
										 titleString:nil
										  titleColor:nil
												font:nil
											 logoImg:nil
									 backgroundImage:nil];
	[_backButton setBackgroundImage:[UIImage imageNamed:@"C-BackIcon-Gray"] forState:UIControlStateNormal];
	[_backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[contentView addSubview:_backButton];

	const CGFloat kEditBgHeight = 30;
	_searchBox = [[UIView alloc] init];
	_searchBox.backgroundColor = UIColorByHex(0xf4f4f4);
	_searchBox.layer.cornerRadius = kEditBgHeight / 2;
	_searchBox.layer.masksToBounds = YES;
	[contentView addSubview:_searchBox];

	UIImageView *searchIconImageView = [[UIImageView alloc] init];
	[searchIconImageView setImage:[UIImage imageNamed:@"search_icon"]];
	[_searchBox addSubview:searchIconImageView];

	_searchTextField = [[UITextField alloc] init];
	_searchTextField.borderStyle = UITextBorderStyleNone;
	_searchTextField.backgroundColor = [UIColor clearColor];
	_searchTextField.textColor = [UIColor blackColor];
	_searchTextField.placeholder = @"搜索好友昵称或者手机号";
	[_searchTextField setFont:[UIFont systemFontOfSize:14.0f]];
	_searchTextField.keyboardType = UIKeyboardTypeDefault;
	_searchTextField.returnKeyType = UIReturnKeySearch;
	_searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	_searchTextField.delegate = self;
	[_searchTextField setValue:UIColorByHex(0x808080) forKeyPath:@"_placeholderLabel.textColor"];
	[_searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	[_searchBox addSubview:_searchTextField];

	_cancelButton = [[MIAButton alloc] initWithFrame:CGRectZero
									  titleString:@"取消"
									   titleColor:[UIColor whiteColor]
											 font:[UIFont systemFontOfSize:16.0f]
										  logoImg:nil
								  backgroundImage:nil];
	[_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[contentView addSubview:_cancelButton];
	[_cancelButton setHidden:YES];

	[_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake(35, 35));
		make.left.mas_equalTo(contentView.mas_left).offset(15);
		make.centerY.mas_equalTo(_searchBox.mas_centerY);
	}];

	[_searchBox mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.mas_equalTo(kEditBgHeight);
		make.top.equalTo(contentView.mas_top).offset(28);
		make.left.equalTo(_backButton.mas_right).offset(15);
		make.right.equalTo(_cancelButton.mas_left).offset(-6);
		make.bottom.equalTo(contentView.mas_bottom).offset(-8);
	}];

	[searchIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake(16, 16));
		make.centerY.equalTo(_searchBox.mas_centerY);
		make.left.equalTo(_searchBox.mas_left).with.offset(12);
	}];

	[_searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_searchBox.mas_top).with.offset(5);
		make.bottom.equalTo(_searchBox.mas_bottom).with.offset(-3);
		make.left.equalTo(searchIconImageView.mas_right).offset(6);
		make.right.equalTo(_searchBox.mas_right).with.offset(-2);
	}];

	[_cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake(40, 18));
		make.centerY.equalTo(_searchBox.mas_centerY);
		make.right.equalTo(contentView.mas_right).offset(-5);
	}];
}

- (void)initContentView:(UIView *)contentView {
	const CGFloat segmentedControlHeight = 55;
	NSString *fansTitle = [NSString stringWithFormat:@"粉丝 %ld", _fansCount];
	NSString *followingTitle = [NSString stringWithFormat:@"关注 %ld", _followingCount];

	_segmentedControl = [[YHSegmentedControl alloc] initWithHeight:segmentedControlHeight titles:@[fansTitle, followingTitle] delegate:self];
	[contentView addSubview:_segmentedControl];

	_fansView = [[UserListView alloc] initWithType:UserListViewTypeFans];
	_fansView.backgroundColor = [UIColor yellowColor];
	_fansView.customDelegate = self;
	[self.view addSubview:_fansView];

	_followingView = [[UserListView alloc] initWithType:UserListViewTypeFollowing];
	_followingView.backgroundColor = [UIColor whiteColor];
	_followingView.customDelegate = self;
	[self.view addSubview:_followingView];

	[_segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(contentView.mas_top);
		make.left.equalTo(contentView.mas_left);
		make.right.equalTo(contentView.mas_right);
		make.height.mas_equalTo(segmentedControlHeight);
	}];

	[_fansView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_segmentedControl.mas_bottom);
		make.left.equalTo(self.view.mas_left);
		make.right.equalTo(self.view.mas_right);
		make.bottom.equalTo(self.view.mas_bottom);
	}];

	[_followingView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_segmentedControl.mas_bottom);
		make.left.equalTo(self.view.mas_left);
		make.right.equalTo(self.view.mas_right);
		make.bottom.equalTo(self.view.mas_bottom);
	}];
}

#pragma mark - Public Methods

#pragma mark - Private Methods
- (void)showSearchBox:(BOOL)show {
	if (show) {
		[_searchBox setHidden:NO];
	} else {
		[_searchBox setHidden:YES];
	}
}

- (void)switchContentViewWithType:(NSInteger)index {
	if (0 == index) {
		[_fansView setHidden:NO];
		[_followingView setHidden:YES];
	} else {
		[_fansView setHidden:YES];
		[_followingView setHidden:NO];
	}
}

- (void)requestFansListWithReload:(BOOL)isReload {
	if (isReload) {
		[_fansModel reset];
	}

	[MiaAPIHelper getFansListWithUID:_currentUID
								start:_fansModel.currentPage
								 item:kUserListPageCount
						completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
							[_fansView endAllRefreshing];
							if (success) {
								NSArray *items = userInfo[@"v"][@"info"];
								if ([items count] <= 0) {
									[_fansView checkNoDataTipsStatus];
									return;
								}

								[_fansModel addItemsWithArray:items];
								[_fansView.collectionView reloadData];
								[_fansView setNoDataTipsHidden:YES];
								++_fansModel.currentPage;
							} else {
								[_fansView checkNoDataTipsStatus];
								id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
								[HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
							}

						} timeoutBlock:^(MiaRequestItem *requestItem) {
							[_fansView checkNoDataTipsStatus];
							[_fansView endAllRefreshing];
						}];
}

- (void)requestFollowingListWithReload:(BOOL)isReload {
	if (isReload) {
		[_followingModel reset];
	}

	[MiaAPIHelper getFollowingListWithUID:_currentUID
							   start:_followingModel.currentPage
								item:kUserListPageCount
					   completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
						   [_followingView endAllRefreshing];
						   if (success) {
							   NSArray *items = userInfo[@"v"][@"info"];
							   if ([items count] <= 0) {
								   [_followingView checkNoDataTipsStatus];
								   return;
							   }

							   [_followingModel addItemsWithArray:items];
							   [_followingView.collectionView reloadData];
							   [_followingView setNoDataTipsHidden:YES];
							   ++_followingModel.currentPage;
						   } else {
							   [_followingView checkNoDataTipsStatus];
							   id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
							   [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
						   }

					   } timeoutBlock:^(MiaRequestItem *requestItem) {
						   [_followingView checkNoDataTipsStatus];
						   [_followingView endAllRefreshing];
					   }];
}

- (void)requestSearchUserWithKey:(NSString *)key isReload:(BOOL)isReload{
	if (isReload) {
		[_searchResultModel reset];
	}

	[MiaAPIHelper searchUserWithKey:key
									start:_searchResultModel.currentPage
									 item:kUserListPageCount
							completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
								[_searchResultView endAllRefreshing];
								if (success) {
									NSArray *items = userInfo[@"v"][@"info"];
									if ([items count] <= 0) {
										[_searchResultView checkNoDataTipsStatus];
										return;
									}

									[_searchResultModel addItemsWithArray:items];
									[_searchResultView.collectionView reloadData];
									[_searchResultView setNoDataTipsHidden:YES];
									++_searchResultModel.currentPage;
								} else {
									[_searchResultView checkNoDataTipsStatus];
									id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
									[HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
								}

							} timeoutBlock:^(MiaRequestItem *requestItem) {
								[_searchResultView checkNoDataTipsStatus];
								[_searchResultView endAllRefreshing];
							}];
}

#pragma mark - delegate
- (void)YHSegmentedControlSelected:(NSInteger)index {
	[self switchContentViewWithType:index];

	UserListViewType type = (UserListViewType)index;
	if (type == UserListViewTypeFans) {
		if (_fansModel.dataSource.count <= 0) {
			[_fansView beginHeaderRefreshing];
		}
	} else {
		if (_followingModel.dataSource.count <= 0) {
			[_followingView beginHeaderRefreshing];
		}
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == _searchTextField) {
		[textField resignFirstResponder];

		if ([NSString isNull:_searchTextField.text]) {
			YES;
		}

		[_searchResultView beginHeaderRefreshing];
	}

	return YES;
}

- (void)textFieldDidChange:(id) sender {
	[_searchResultView setHidden:NO];
	[_searchResultView setNoDataTipsHidden:YES];
	[_cancelButton setHidden:NO];
	[_contentView setHidden:YES];
}

- (UserListModel *)userListViewModelWithType:(UserListViewType)type {
	switch (type) {
		case UserListViewTypeFans:
			return _fansModel;
		case UserListViewTypeFollowing:
			return _followingModel;
		case UserListViewTypeSearch:
			return _searchResultModel;
		default:
			NSLog(@"userListViewModelWithType: it's a bug.");
			return nil;
	};
}

- (void)userListViewRequesNewItemsWithType:(UserListViewType)type  {
	switch (type) {
		case UserListViewTypeFans:
			[self requestFansListWithReload:YES];
			return;
		case UserListViewTypeFollowing:
			[self requestFollowingListWithReload:YES];
			return;
		case UserListViewTypeSearch:
			[self requestSearchUserWithKey:_searchTextField.text isReload:YES];
			return;
		default:
			NSLog(@"userListViewModelWithType: it's a bug.");
			return;
	};
}

- (void)userListViewRequestMoreItemsWithType:(UserListViewType)type {
	switch (type) {
		case UserListViewTypeFans:
			[self requestFansListWithReload:NO];
			return;
		case UserListViewTypeFollowing:
			[self requestFollowingListWithReload:NO];
			return;
		case UserListViewTypeSearch:
			[self requestSearchUserWithKey:_searchTextField.text isReload:NO];
			return;
		default:
			NSLog(@"userListViewModelWithType: it's a bug.");
			return;
	};
}

- (void)userListViewDidSelectedItem:(UserItem *)item {
	NSLog(@"select %@", item.nick);
    _pushed = YES;
	HXProfileViewController *profileViewController = [HXProfileViewController instance];
	profileViewController.uid = item.uid;
	[self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)userListViewFollowUID:(NSString *)uID
					 isFollow:(BOOL)isFollow
			   completedBlock:(UserCollectionViewCellCompletedBlock)completedBlock {
	[MiaAPIHelper followWithUID:uID
					   isFollow:isFollow
				  completeBlock:
	 ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
		 if (!success) {
			 [HXAlertBanner showWithMessage:(isFollow ? @"添加关注失败" : @"取消关注失败") tap:nil];
		 } else {
			 if (_isHost) {
				 if (isFollow) {
					 _followingCount++;
				 } else {
					 _followingCount--;
				 }

				 [_segmentedControl setTitle:[NSString stringWithFormat:@"关注 %ld", _followingCount] forIndex:UserListViewTypeFollowing];
			 }
		 }

		 if (completedBlock) {
			 completedBlock(success);
		 }
	 } timeoutBlock:^(MiaRequestItem *requestItem) {
		 if (completedBlock) {
			 completedBlock(NO);
		 }
		 [HXAlertBanner showWithMessage:@"请求超时，请重试" tap:nil];
	 }];
	
}

#pragma mark - Notification


#pragma mark - button Actions

- (void)backButtonAction:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelButtonAction:(id)sender {
    [self hidenKeyboard];
	[_searchResultView setHidden:YES];
	[_searchResultModel reset];
	[_searchResultView.collectionView reloadData];

	[_cancelButton setHidden:YES];
	[_contentView setHidden:NO];
	[_searchTextField setText:@""];


}


- (void)hidenKeyboard {
	[_searchTextField resignFirstResponder];
}



@end
