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

@interface FriendViewController () <UITextFieldDelegate, YHSegmentedControlDelegate, UserListViewDelegate>
@end

@implementation FriendViewController {
	UserListModel 			*_fansModel;
	UserListModel 			*_followingModel;
	UserListModel 			*_searchResultModel;

	MIAButton 				*_backButton;
	UITextField 			*_searchTextField;
	MIAButton 				*_cancelButton;

	UIView					*_contentView;
	YHSegmentedControl 		*_segmentedControl;

	UserListView 			*_fansView;
	UserListView 			*_followingView;
	UserListView 			*_searchResultView;

	MBProgressHUD 			*_searchProgressHUD;
}

- (void)dealloc {
	[_searchProgressHUD removeFromSuperview];
	_searchProgressHUD = nil;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	[self initUI];
	[self initData];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:animated];
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
	return YES;
}

- (void)initUI {
	UIView *topView = [[UIView alloc] init];
	topView.backgroundColor = [UIColor whiteColor];
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

	[self initProgressHud];
}

- (void)initData {
	_searchResultModel = [[UserListModel alloc] init];
}

- (void)initTopView:(UIView *)contentView {
	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
	gesture.numberOfTapsRequired = 1;
	[contentView addGestureRecognizer:gesture];

	UIView *editBgView = [[UIView alloc] init];
	editBgView.backgroundColor = UIColorFromHex(@"f4f4f4", 1.0);
	editBgView.layer.cornerRadius = 1;
	editBgView.layer.masksToBounds = YES;
	[contentView addSubview:editBgView];

	UIImageView *searchIconImageView = [[UIImageView alloc] init];
	[searchIconImageView setImage:[UIImage imageNamed:@"search_icon"]];
	[editBgView addSubview:searchIconImageView];

	_searchTextField = [[UITextField alloc] init];
	_searchTextField.borderStyle = UITextBorderStyleNone;
	_searchTextField.backgroundColor = [UIColor clearColor];
	_searchTextField.textColor = [UIColor blackColor];
	_searchTextField.placeholder = @"搜索好友昵称或者手机号";
	[_searchTextField setFont:UIFontFromSize(16)];
	_searchTextField.keyboardType = UIKeyboardTypeDefault;
	_searchTextField.returnKeyType = UIReturnKeySearch;
	_searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	_searchTextField.delegate = self;
	[_searchTextField setValue:UIColorFromHex(@"#808080", 1.0) forKeyPath:@"_placeholderLabel.textColor"];
	[_searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	[editBgView addSubview:_searchTextField];

	_cancelButton = [[MIAButton alloc] initWithFrame:CGRectZero
									  titleString:@"取消"
									   titleColor:[UIColor blackColor]
											 font:UIFontFromSize(16)
										  logoImg:nil
								  backgroundImage:nil];
	[_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[contentView addSubview:_cancelButton];

	UIView *lineView = [[UIView alloc] init];
	lineView.backgroundColor = UIColorFromHex(@"dcdcdc", 1.0);
	[contentView addSubview:lineView];

	[editBgView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@40);
		make.top.equalTo(contentView.mas_top).offset(15);
		make.left.equalTo(contentView.mas_left).offset(15);
		make.right.equalTo(_cancelButton.mas_left).offset(-6);
	}];

	[searchIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake(16, 16));
		make.centerY.equalTo(editBgView.mas_centerY);
		make.left.equalTo(editBgView.mas_left).with.offset(8);
	}];

	[_searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(editBgView.mas_top).with.offset(10);
		make.left.equalTo(searchIconImageView.mas_right).offset(6);
		make.bottom.equalTo(editBgView.mas_bottom).with.offset(-10);
		make.right.equalTo(editBgView.mas_right).with.offset(-2);
	}];

	[_cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake(40, 18));
		make.centerY.equalTo(editBgView.mas_centerY);
		make.right.equalTo(contentView.mas_right).offset(-5);
	}];

	[lineView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@0.5);
		make.top.equalTo(editBgView.mas_bottom).offset(5);
		make.left.equalTo(contentView.mas_left).offset(15);
		make.right.equalTo(contentView.mas_right);
		make.bottom.equalTo(contentView.mas_bottom);
	}];
}

- (void)initContentView:(UIView *)contentView {
	const CGFloat segmentedControlHeight = 55;
	_segmentedControl = [[YHSegmentedControl alloc] initWithHeight:segmentedControlHeight titles:@[@"粉丝", @"关注"] delegate:self];
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

- (void)initProgressHud {
	UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
	_searchProgressHUD = [[MBProgressHUD alloc] initWithView:window];
	[window addSubview:_searchProgressHUD];
	_searchProgressHUD.dimBackground = NO;
	_searchProgressHUD.labelText = @"正在搜索";
	_searchProgressHUD.mode = MBProgressHUDModeIndeterminate;
}

#pragma mark - Public Methods

#pragma mark - delegate

- (void)YHSegmentedControlSelected:(NSInteger)index {
	NSLog(@"%ld",index);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == _searchTextField) {
		[textField resignFirstResponder];

		if ([NSString isNull:_searchTextField.text]) {
			YES;
		}

		[_searchResultView setHidden:NO];
		[_searchResultView setNoDataTipsHidden:YES];
		[_searchResultModel reset];

		[_searchProgressHUD show:YES];
//		[XiamiHelper requestSearchResultWithKey:_searchTextField.text
//										   page:_resultModel.currentPage
//								   successBlock:
//		 ^(id responseObject) {
//			 [_resultModel addItemsWithArray:responseObject];
//			 [_resultView setNoDataTipsHidden:_resultModel.dataSource.count != 0];
//			 [_resultView.collectionView reloadData];
//			 [_searchProgressHUD hide:YES];
//		} failedBlock:^(NSError *error) {
//			[_searchProgressHUD hide:YES];
//			[HXAlertBanner showWithMessage:@"搜索失败，请稍后重试" tap:nil];
//		}];
	}

	return YES;
}

- (void)textFieldDidChange:(id) sender {
	[_searchResultView setHidden:YES];
	[_searchResultModel reset];

//	if ([NSString isNull:_searchTextField.text]) {
//		[_suggestView.collectionView reloadData];
//		return;
//	}
//
//	[XiamiHelper requestSearchSuggestionWithKey:_searchTextField.text
//								   successBlock:
//	 ^(id responseObject) {
//		[_suggestionModel addItemsWithArray:responseObject];
//		[_suggestView.collectionView reloadData];
//	} failedBlock:^(NSError *error) {
//		[HXAlertBanner showWithMessage:@"搜索失败，请稍后重试" tap:nil];
//	}];
}

- (UserListModel *)userListViewModelWithType:(UserListViewType)type {
	return _searchResultModel;
}

- (void)userListViewRequestMoreItemsWithType:(UserListViewType)type {
}

- (void)userListViewDidSelectedItem:(UserItem *)item {
}

- (void)userListViewDidClickFollow:(UserItem *)item {
}

#pragma mark - Notification


#pragma mark - button Actions

- (void)cancelButtonAction:(id)sender {
    [self hidenKeyboard];
    [self dismissViewControllerAnimated:YES completion:nil];
//	if (_delegate && [_delegate respondsToSelector:@selector(searchViewControllerWillDismiss)]) {
//		[_delegate searchViewControllerWillDismiss];
//	}
}


- (void)hidenKeyboard {
	[_searchTextField resignFirstResponder];
}



@end
