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
#import "UIImageView+BlurredImage.h"
#import "FavoriteCollectionViewCell.h"
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

const static CGFloat kSearchVCHeight = 60;

@interface SearchViewController () <UITextFieldDelegate, SearchSuggestionViewDelegate, SearchResultViewDelegate>

@end

@implementation SearchViewController {
	SearchSuggestionModel *suggestionModel;
	SearchResultModel *resultModel;

	MIAButton *cancelButton;
	SearchSuggestionView *suggestView;
	SearchResultView *resultView;

	UITextField *searchTextField;
}

- (id)init {
	self = [super init];
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidReceiveMessage:) name:WebSocketMgrNotificationDidReceiveMessage object:nil];
	}

	return self;
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidReceiveMessage object:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self initTopView];
	[self initCollectionView];
	[searchTextField becomeFirstResponder];
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

- (void)viewDidAppear:(BOOL)animated;
{
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
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

	searchTextField = [[UITextField alloc] init];
	searchTextField.borderStyle = UITextBorderStyleNone;
	searchTextField.backgroundColor = [UIColor clearColor];
	searchTextField.textColor = UIColorFromHex(@"#a2a2a2", 1.0);
	searchTextField.placeholder = @"搜索你感兴趣的歌曲名或歌手名";
	[searchTextField setFont:UIFontFromSize(13)];
	searchTextField.keyboardType = UIKeyboardTypeDefault;
	searchTextField.returnKeyType = UIReturnKeySearch;
	searchTextField.delegate = self;
	[searchTextField setValue:UIColorFromHex(@"#949494", 1.0) forKeyPath:@"_placeholderLabel.textColor"];
	[searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	[editBgView addSubview:searchTextField];

	cancelButton = [[MIAButton alloc] initWithFrame:CGRectZero
									  titleString:@"取消"
									   titleColor:[UIColor redColor]
											 font:UIFontFromSize(15)
										  logoImg:nil
								  backgroundImage:nil];
	[cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[topView addSubview:cancelButton];

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

	[searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(editBgView.mas_top).with.offset(5);
		make.left.equalTo(editBgView.mas_left).with.offset(25);
		make.bottom.equalTo(editBgView.mas_bottom).with.offset(-5);
		make.right.equalTo(editBgView.mas_right).with.offset(-5);
	}];

	[cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake(40, 18));
		make.top.equalTo(topView.mas_top).offset(25);
		make.right.equalTo(topView.mas_right).offset(-15);
	}];
}

- (void)initCollectionView {
	suggestionModel = [[SearchSuggestionModel alloc] init];
	CGRect collectionViewFrame = CGRectMake(0,
											kSearchVCHeight,
											self.view.bounds.size.width,
											self.view.bounds.size.height - kSearchVCHeight);
	suggestView = [[SearchSuggestionView alloc] initWithFrame:collectionViewFrame];
	suggestView.searchSuggestionViewDelegate = self;
	[self.view addSubview:suggestView];

	resultModel = [[SearchResultModel alloc] init];
	resultView = [[SearchResultView alloc] initWithFrame:collectionViewFrame];
	resultView.searchResultViewDelegate = self;
	[self.view addSubview:resultView];
	[resultView setHidden:YES];
}

#pragma mark - delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == searchTextField) {
		[textField resignFirstResponder];
		// TODO hide and show
	}

	return true;
}

- (void)textFieldDidChange:(id) sender {
	// TODO hide and show
	[suggestionModel.dataSource removeAllObjects];
	if ([NSString isNull:searchTextField.text]) {
		[suggestView.suggestionCollectionView reloadData];
		return;
	}

	[XiamiHelper requestSearchSuggestionWithKey:searchTextField.text successBlock:^(id responseObject) {
		[suggestionModel addItemsWithArray:responseObject];
		[suggestView.suggestionCollectionView reloadData];
	} failedBlock:^(NSError *error) {
		NSLog(@"%@", error);
	}];

}

- (SearchSuggestionModel *)searchSuggestionViewModel {
	return suggestionModel;
}

- (void)searchSuggestionViewDidSelectedItem:(SuggestionItem *)item {
	NSLog(@"%@ %@", item.title, item.artist);
}

- (SearchResultModel *)searchResultViewModel {
	return resultModel;
}

- (void)searchResultViewDidSelectedItem:(SearchResultItem *)item {
	NSLog(@"%@ %@", item.title, item.artist);
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
//	[[_favoriteViewControllerDelegate favoriteViewControllerModel] addItemsWithArray:items];
//	[_favoriteCollectionView reloadData];
//}


#pragma mark - button Actions

- (void)cancelButtonAction:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)settingButtonAction:(id)sender {
	NSLog(@"setting button clicked.");
}

- (void)hidenKeyboard {
	[searchTextField resignFirstResponder];
}



@end
