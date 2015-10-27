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
#import "DetailViewController.h"
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

const static CGFloat kSearchVCHeight = 60;

@interface SearchViewController () <UITextFieldDelegate, SearchSuggestionViewDelegate, SearchResultViewDelegate>

@end

@implementation SearchViewController {
	SearchSuggestionModel	*_suggestionModel;
	SearchResultModel 		*_resultModel;

	MIAButton 				*_cancelButton;
	SearchSuggestionView 	*_suggestView;
	SearchResultView 		*_resultView;

	UITextField 			*_searchTextField;
	MBProgressHUD 			*_progressHUD;
}

- (id)init {
	self = [super init];
	if (self) {
	}

	return self;
}

-(void)dealloc {
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self initTopView];
	[self initCollectionView];
	[_searchTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
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

- (void)initTopView {
	UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kSearchVCHeight)];
	topView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:topView];

	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
	gesture.numberOfTapsRequired = 1;
	[topView addGestureRecognizer:gesture];

	UIView *editBgView = [[UIView alloc] init];
	editBgView.backgroundColor = UIColorFromHex(@"f4f4f4", 1.0);
	editBgView.layer.cornerRadius = 1;
	editBgView.layer.masksToBounds = YES;
	[topView addSubview:editBgView];

	UIImageView *searchIconImageView = [[UIImageView alloc] init];
	[searchIconImageView setImage:[UIImage imageNamed:@"search_icon"]];
	[editBgView addSubview:searchIconImageView];

	_searchTextField = [[UITextField alloc] init];
	_searchTextField.borderStyle = UITextBorderStyleNone;
	_searchTextField.backgroundColor = [UIColor clearColor];
	_searchTextField.textColor = UIColorFromHex(@"#a2a2a2", 1.0);
	_searchTextField.placeholder = @"搜索你感兴趣的歌曲名或歌手名";
	[_searchTextField setFont:UIFontFromSize(13)];
	_searchTextField.keyboardType = UIKeyboardTypeDefault;
	_searchTextField.returnKeyType = UIReturnKeySearch;
	_searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	_searchTextField.delegate = self;
	[_searchTextField setValue:UIColorFromHex(@"#949494", 1.0) forKeyPath:@"_placeholderLabel.textColor"];
	[_searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	[editBgView addSubview:_searchTextField];

	_cancelButton = [[MIAButton alloc] initWithFrame:CGRectZero
									  titleString:@"取消"
									   titleColor:[UIColor redColor]
											 font:UIFontFromSize(15)
										  logoImg:nil
								  backgroundImage:nil];
	[_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[topView addSubview:_cancelButton];

	[editBgView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@30);
		make.top.equalTo(topView.mas_top).offset(20);
		make.left.equalTo(topView.mas_left).offset(15);
		make.right.equalTo(topView.mas_right).offset(-60);
	}];

	[searchIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake(16, 16));
		make.centerY.equalTo(editBgView.mas_centerY);
		make.left.equalTo(editBgView.mas_left).with.offset(5);
	}];

	[_searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(editBgView.mas_top).with.offset(5);
		make.left.equalTo(editBgView.mas_left).with.offset(25);
		make.bottom.equalTo(editBgView.mas_bottom).with.offset(-5);
		make.right.equalTo(editBgView.mas_right).with.offset(-5);
	}];

	[_cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake(40, 18));
		make.top.equalTo(topView.mas_top).offset(25);
		make.right.equalTo(topView.mas_right).offset(-15);
	}];
}

- (void)initCollectionView {
	_suggestionModel = [[SearchSuggestionModel alloc] init];
	CGRect collectionViewFrame = CGRectMake(0,
											kSearchVCHeight,
											self.view.bounds.size.width,
											self.view.bounds.size.height - kSearchVCHeight);
	_suggestView = [[SearchSuggestionView alloc] initWithFrame:collectionViewFrame];
	_suggestView.searchSuggestionViewDelegate = self;
	[self.view addSubview:_suggestView];

	_resultModel = [[SearchResultModel alloc] init];
	_resultView = [[SearchResultView alloc] initWithFrame:collectionViewFrame];
	_resultView.searchResultViewDelegate = self;
	[self.view addSubview:_resultView];
	[_resultView setHidden:YES];
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

		MBProgressHUD *aMBProgressHUD = [MBProgressHUDHelp showLoadingWithText:@"正在搜索"];
		[XiamiHelper requestSearchResultWithKey:_searchTextField.text
										   page:_resultModel.currentPage
								   successBlock:
		 ^(id responseObject) {
			[_resultModel addItemsWithArray:responseObject];
			[_resultView.collectionView reloadData];

			[aMBProgressHUD removeFromSuperview];
		} failedBlock:^(NSError *error) {
			[aMBProgressHUD removeFromSuperview];
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

	MBProgressHUD * aMBProgressHUD = [MBProgressHUDHelp showLoadingWithText:@"正在搜索"];
	[XiamiHelper requestSearchResultWithKey:key page:_resultModel.currentPage successBlock:^(id responseObject) {
		[_resultModel addItemsWithArray:responseObject];
		[_resultView.collectionView reloadData];
		[aMBProgressHUD removeFromSuperview];
	} failedBlock:^(NSError *error) {
		NSLog(@"%@", error);
		[aMBProgressHUD removeFromSuperview];
	}];
}

- (SearchResultModel *)searchResultViewModel {
	return _resultModel;
}

- (void)searchResultViewDidSelectedItem:(SearchResultItem *)item {
	[_searchViewControllerDelegate searchViewControllerDidSelectedItem:item];
	[self.navigationController popViewControllerAnimated:YES];
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
	[_searchViewControllerDelegate searchViewControllerClickedPlayButtonAtItem:item];
}

#pragma mark - Notification


#pragma mark - button Actions

- (void)cancelButtonAction:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)settingButtonAction:(id)sender {
	NSLog(@"setting button clicked.");
}

- (void)hidenKeyboard {
	[_searchTextField resignFirstResponder];
}



@end
