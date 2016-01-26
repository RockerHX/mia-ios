//
//  FriendViewController.m
//  mia
//
//  Created by linyehui on 2016/01/26.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "FriendViewController.h"
#import "MIAButton.h"
#import "UIScrollView+MIARefresh.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUDHelp.h"
#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"
#import "Masonry.h"
#import "SearchSuggestionModel.h"
#import "NSString+IsNull.h"
#import "FriendSearchResultView.h"
#import "FriendModel.h"
#import "FriendItem.h"
#import "HXAlertBanner.h"

@interface FriendViewController () <UITextFieldDelegate, FriendSearchResultViewDelegate>
@end

@implementation FriendViewController {
	FriendModel 			*_resultModel;

	MIAButton 				*_cancelButton;
	FriendSearchResultView 	*_resultView;

	UITextField 			*_searchTextField;
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

	_resultView = [[FriendSearchResultView alloc] init];
	_resultView.backgroundColor = [UIColor grayColor];
	_resultView.customDelegate = self;
	[self.view addSubview:_resultView];
	[_resultView setHidden:YES];

	[topView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(self.view.mas_top);
		make.left.equalTo(self.view.mas_left);
		make.right.equalTo(self.view.mas_right);
	}];

	[_resultView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(topView.mas_bottom);
		make.left.equalTo(self.view.mas_left);
		make.right.equalTo(self.view.mas_right);
		make.bottom.equalTo(self.view.mas_bottom);
	}];

	[self initProgressHud];
	[_searchTextField becomeFirstResponder];
}

- (void)initData {
	_resultModel = [[FriendModel alloc] init];
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
	_searchTextField.placeholder = @"搜索你感兴趣的歌曲名或歌手名";
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == _searchTextField) {
		[textField resignFirstResponder];

		if ([NSString isNull:_searchTextField.text]) {
			YES;
		}

		[_resultView setHidden:NO];
		[_resultView setNoDataTipsHidden:YES];
		[_resultModel reset];

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
	[_resultView setHidden:YES];
	[_resultModel reset];

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

- (FriendModel *)friendSearchResultViewModel {
	return _resultModel;
}

- (void)friendSearchResultViewDidSelectedItem:(FriendItem *)item {
    [self hidenKeyboard];
}

- (void)friendSearchResultViewRequestMoreItems {
//	_resultModel.currentPage++;
//	[XiamiHelper requestSearchResultWithKey:_searchTextField.text page:_resultModel.currentPage successBlock:^(id responseObject) {
//		[_resultModel addItemsWithArray:responseObject];
//		[_resultView.collectionView reloadData];
//		[_resultView endRefreshing];
//	} failedBlock:^(NSError *error) {
//		NSLog(@"%@", error);
//		[_resultView endRefreshing];
//	}];

}

- (void)friendSearchResultViewDidClickFollow:(FriendItem *)item {
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
