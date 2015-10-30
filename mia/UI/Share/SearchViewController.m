//
//  SearchViewController.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "SearchViewController.h"
#import "MIAButton.h"
#import "MIALabel.h"
#import "UIScrollView+MIARefresh.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUDHelp.h"
#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"
#import "MIALabel.h"
#import "SearchSuggestionView.h"
#import "Masonry.h"
#import "SearchSuggestionModel.h"
#import "XiamiHelper.h"
#import "NSString+IsNull.h"
#import "SuggestionItem.h"
#import "SearchResultView.h"
#import "SearchResultModel.h"
#import "SearchResultItem.h"
#import "HXAlertBanner.h"

@interface SearchViewController () <UITextFieldDelegate, SearchSuggestionViewDelegate, SearchResultViewDelegate>
@end

@implementation SearchViewController {
	SearchSuggestionModel	*_suggestionModel;
	SearchResultModel 		*_resultModel;

	MIAButton 				*_cancelButton;
	SearchSuggestionView 	*_suggestView;
	SearchResultView 		*_resultView;

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

	_suggestView = [[SearchSuggestionView alloc] init];
	_suggestView.backgroundColor = [UIColor yellowColor];
	_suggestView.searchSuggestionViewDelegate = self;
	[self.view addSubview:_suggestView];

	_resultView = [[SearchResultView alloc] init];
	_resultView.backgroundColor = [UIColor grayColor];
	_resultView.searchResultViewDelegate = self;
	[self.view addSubview:_resultView];
	[_resultView setHidden:YES];

	[topView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(self.view.mas_top);
		make.left.equalTo(self.view.mas_left);
		make.right.equalTo(self.view.mas_right);
	}];

	[_suggestView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(topView.mas_bottom);
		make.left.equalTo(self.view.mas_left);
		make.right.equalTo(self.view.mas_right);
		make.bottom.equalTo(self.view.mas_bottom);
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
	_suggestionModel = [[SearchSuggestionModel alloc] init];
	_resultModel = [[SearchResultModel alloc] init];
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

#pragma mark - delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == _searchTextField) {
		[textField resignFirstResponder];

		if ([NSString isNull:_searchTextField.text]) {
			YES;
		}

		[_suggestView setHidden:YES];
		[_resultView setHidden:NO];
		[_suggestionModel.dataSource removeAllObjects];
		[_resultModel reset];

		[_searchProgressHUD show:YES];
		[XiamiHelper requestSearchResultWithKey:_searchTextField.text
										   page:_resultModel.currentPage
								   successBlock:
		 ^(id responseObject) {
			[_resultModel addItemsWithArray:responseObject];
			[_resultView.collectionView reloadData];

			[_searchProgressHUD hide:YES];
		} failedBlock:^(NSError *error) {
			[_searchProgressHUD hide:YES];
			[HXAlertBanner showWithMessage:@"搜索失败，请稍后重试" tap:nil];
		}];
	}

	return YES;
}

- (void)textFieldDidChange:(id) sender {
	[_suggestView setHidden:NO];
	[_resultView setHidden:YES];
	[_suggestionModel.dataSource removeAllObjects];
	[_resultModel reset];

	if ([NSString isNull:_searchTextField.text]) {
		[_suggestView.collectionView reloadData];
		return;
	}

	[XiamiHelper requestSearchSuggestionWithKey:_searchTextField.text
								   successBlock:
	 ^(id responseObject) {
		[_suggestionModel addItemsWithArray:responseObject];
		[_suggestView.collectionView reloadData];
	} failedBlock:^(NSError *error) {
		[HXAlertBanner showWithMessage:@"搜索失败，请稍后重试" tap:nil];
	}];
}

- (SearchSuggestionModel *)searchSuggestionViewModel {
	return _suggestionModel;
}

- (void)searchSuggestionViewDidSelectedItem:(SuggestionItem *)item {
	NSLog(@"%@ %@", item.title, item.artist);

	[_suggestView setHidden:YES];
	[_resultView setHidden:NO];
	[_suggestionModel.dataSource removeAllObjects];
	[_resultModel reset];

	NSString *key = [NSString stringWithFormat:@"%@ %@", item.title, item.artist];
	_searchTextField.text = key;

	[_searchProgressHUD show:YES];
	[XiamiHelper requestSearchResultWithKey:key page:_resultModel.currentPage successBlock:^(id responseObject) {
		[_resultModel addItemsWithArray:responseObject];
		[_resultView.collectionView reloadData];
		[_searchProgressHUD hide:YES];
	} failedBlock:^(NSError *error) {
		NSLog(@"%@", error);
		[_searchProgressHUD hide:YES];
	}];
}

- (SearchResultModel *)searchResultViewModel {
	return _resultModel;
}

- (void)searchResultViewDidSelectedItem:(SearchResultItem *)item {
    [self hidenKeyboard];
    if (_delegate && [_delegate respondsToSelector:@selector(searchViewControllerDidSelectedItem:)]) {
        [_delegate searchViewControllerDidSelectedItem:item];
    }
    __weak __typeof__(self)weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(searchViewControllerDismissFinished)]) {
            [strongSelf.delegate searchViewControllerDismissFinished];
        }
    }];
}

- (void)searchResultViewRequestMoreItems {
	_resultModel.currentPage++;
	[XiamiHelper requestSearchResultWithKey:_searchTextField.text page:_resultModel.currentPage successBlock:^(id responseObject) {
		[_resultModel addItemsWithArray:responseObject];
		[_resultView.collectionView reloadData];
		[_resultView endRefreshing];
	} failedBlock:^(NSError *error) {
		NSLog(@"%@", error);
		[_resultView endRefreshing];
	}];

}

- (void)searchResultViewDidPlayItem:(SearchResultItem *)item {
    if (_delegate && [_delegate respondsToSelector:@selector(searchViewControllerClickedPlayButtonAtItem:)]) {
        [_delegate searchViewControllerClickedPlayButtonAtItem:item];
    }
}

#pragma mark - Notification


#pragma mark - button Actions

- (void)cancelButtonAction:(id)sender {
    [self hidenKeyboard];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)settingButtonAction:(id)sender {
	NSLog(@"setting button clicked.");
}

- (void)hidenKeyboard {
	[_searchTextField resignFirstResponder];
}



@end
