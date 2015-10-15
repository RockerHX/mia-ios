//
//  DetailViewController.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "DetailViewController.h"
#import "MIAButton.h"
#import "MIALabel.h"
#import "MBProgressHUD.h"
#import "MBProgressHUDHelp.h"
#import "UIScrollView+MIARefresh.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Extrude.h"
#import "CommentCollectionViewCell.h"
#import "DetailHeaderView.h"
#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"
#import "ProfileShareModel.h"
#import "DetailViewController.h"
#import "CommentModel.h"
#import "CommentItem.h"
#import "UserSession.h"
#import "LoginViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "CLLocation+YCLocation.h"
#import "ProfileViewController.h"

static NSString * const kDetailCellReuseIdentifier 		= @"DetailCellId";
static NSString * const kDetailHeaderReuseIdentifier 	= @"DetailHeaderId";
//static NSString * const kDetailFooterReuseIdentifier 	= @"DetailFooterId";

static const CGFloat kDetailItemMarginH 				= 15;
static const CGFloat kDetailItemMarginV 				= 20;

static const CGFloat kDetailHeaderHeight 				= 350;
static const CGFloat kDetailHeaderHeightWithInfectUsers	= 400;

static const CGFloat kDetailFooterViewHeight 			= 40;
static const CGFloat kDetailItemHeight 					= 40;

@interface DetailViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UIActionSheetDelegate,
UITextFieldDelegate,
CLLocationManagerDelegate,
DetailHeaderViewDelegate,
CommentCellDelegate>

@end

@implementation DetailViewController {
	ShareItem 				*_shareItem;
	CommentModel 			*_dataModel;

	UICollectionView 		*_collectionView;
	UITextField 			*_commentTextField;
	MIAButton 				*_commentButton;
	DetailHeaderView 		*_detailHeaderView;
	UIView 					*_footerView;
	MBProgressHUD 			*_progressHUD;
	NSTimer 				*_reportViewsTimer;

	CLLocationManager 		*_locationManager;
	CLLocationCoordinate2D 	_currentCoordinate;
	NSString				*_currentAddress;
}

- (id)initWitShareItem:(ShareItem *)item {
	self = [super init];
	if (self) {
		_shareItem = item;
		[self initLocationMgr];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidReceiveMessage:) name:WebSocketMgrNotificationDidReceiveMessage object:nil];

		//添加键盘监听
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	}

	return self;
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidReceiveMessage object:nil];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self initUI];
	[self initData];
	[_collectionView addFooterWithTarget:self action:@selector(requestComments)];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:animated];

	const NSTimeInterval kReportViewsTimeInterval = 15;
	_reportViewsTimer = [NSTimer scheduledTimerWithTimeInterval:kReportViewsTimeInterval
															  target:self
															selector:@selector(reportViewsTimerAction)
															userInfo:nil
															 repeats:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:animated];
	[_reportViewsTimer invalidate];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
	return NO;
}

- (void)initUI {
	static NSString *kDetailTitle = @"详情页";
	self.title = kDetailTitle;
	[self initBarButton];

	//1.初始化layout
	UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
	//设置collectionView滚动方向
	//    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];

	//设置headerView的尺寸大小
	layout.headerReferenceSize = [self headerViewSize];
	//layout.footerReferenceSize = CGSizeMake(self.view.frame.size.width, kDetailFooterViewHeight);

	//该方法也可以设置itemSize
	CGFloat itemWidth = self.view.frame.size.width - kDetailItemMarginH * 2;
	layout.itemSize = CGSizeMake(itemWidth, kDetailItemHeight);

	//2.初始化collectionView
	_collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,
																		 0,
																		 self.view.bounds.size.width,
																		 self.view.bounds.size.height - kDetailFooterViewHeight)
										 collectionViewLayout:layout];
	[self.view addSubview:_collectionView];

	_collectionView.backgroundColor = [UIColor whiteColor];

	//3.注册collectionViewCell
	//注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
	[_collectionView registerClass:[CommentCollectionViewCell class] forCellWithReuseIdentifier:kDetailCellReuseIdentifier];

	//注册headerView  此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致  均为reusableView
	[_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kDetailHeaderReuseIdentifier];
	//[mainCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kDetailFooterReuseIdentifier];

	//4.设置代理
	_collectionView.delegate = self;
	_collectionView.dataSource = self;

	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
	gesture.numberOfTapsRequired = 1;
	[_collectionView addGestureRecognizer:gesture];

	[self initHeaderView];
	[self initFooterView];
}

- (void)initBarButton {
	UIImage *backButtonImage = [UIImage imageNamed:@"back"];
	MIAButton *backButton = [[MIAButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, backButtonImage.size.width, backButtonImage.size.height)
												 titleString:nil
												  titleColor:nil
														font:nil
													 logoImg:nil
											 backgroundImage:backButtonImage];
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	self.navigationItem.leftBarButtonItem = leftButton;
	[backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];

	UIImage *moreButtonImage = [UIImage imageNamed:@"more"];
	MIAButton *moreButton = [[MIAButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, moreButtonImage.size.width, moreButtonImage.size.height)
												 titleString:nil
												  titleColor:nil
														font:nil
													 logoImg:nil
											 backgroundImage:moreButtonImage];
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
	self.navigationItem.rightBarButtonItem = rightButton;
	[moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (CGSize)headerViewSize {
	if ([_shareItem.infectUsers count] > 0) {
		return CGSizeMake(self.view.frame.size.width, kDetailHeaderHeightWithInfectUsers);
	}

	return CGSizeMake(self.view.frame.size.width, kDetailHeaderHeight);
}

- (void)initHeaderView {
	_detailHeaderView = [[DetailHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kDetailHeaderHeight)];
	_detailHeaderView.customDelegate = self;
	_detailHeaderView.shareItem = _shareItem;

	//NSLog(@"initHeaderView: %f, %f, %f, %f", contentView.bounds.origin.x, contentView.bounds.origin.y, contentView.bounds.size.width, contentView.bounds.size.height);
	//[contentView addSubview:detailHeaderView];
}

- (void)initFooterView {
	//footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kDetailFooterViewHeight)];
	_footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - kDetailFooterViewHeight, self.view.bounds.size.width, kDetailFooterViewHeight)];
	_footerView.backgroundColor = UIColorFromHex(@"d2d0d0", 1.0);
	[self.view addSubview:_footerView];

	UIView *textBGView = [[UIView alloc] initWithFrame:CGRectInset(_footerView.bounds, 1, 1)];
	textBGView.backgroundColor = UIColorFromHex(@"f2f2f2", 1.0);
	[_footerView addSubview:textBGView];

	static const CGFloat kEditViewMarginLeft 		= 28;
	static const CGFloat kEditViewMarginRight 		= 70;
	static const CGFloat kEditViewMarginTop 		= 5;
	static const CGFloat kEditViewHeight			= 30;

	static const CGFloat kCommentButtonMarginRight 	= 15;
	static const CGFloat kCommentButtonMarginTop	= 10;
	static const CGFloat kCommentButtonWidth		= 50;
	static const CGFloat kCommentButtonHeight		= 20;

	_commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(kEditViewMarginLeft,
																				   kEditViewMarginTop,
																				   _footerView.bounds.size.width - kEditViewMarginLeft - kEditViewMarginRight,
																				   kEditViewHeight)];
	_commentTextField.borderStyle = UITextBorderStyleNone;
	_commentTextField.backgroundColor = [UIColor clearColor];
	_commentTextField.textColor = UIColorFromHex(@"#a2a2a2", 1.0);
	_commentTextField.placeholder = @"此刻的想法";
	[_commentTextField setFont:UIFontFromSize(16)];
	_commentTextField.keyboardType = UIKeyboardTypeDefault;
	_commentTextField.returnKeyType = UIReturnKeySend;
	_commentTextField.delegate = self;
	//commentTextField.backgroundColor = [UIColor yellowColor];
	[_commentTextField setValue:UIColorFromHex(@"#949494", 1.0) forKeyPath:@"_placeholderLabel.textColor"];
	[_commentTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

	[_footerView addSubview:_commentTextField];


	_commentButton = [[MIAButton alloc] initWithFrame:CGRectMake(_footerView.frame.size.width - kCommentButtonMarginRight - kCommentButtonWidth,
																		   kCommentButtonMarginTop,
																		   kCommentButtonWidth,
																		   kCommentButtonHeight)
										 titleString:@"发送"
										  titleColor:UIColorFromHex(@"#ff300f", 1.0)
												font:UIFontFromSize(15)
											 logoImg:nil
									 backgroundImage:nil];
	[_commentButton addTarget:self action:@selector(commentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[_commentButton setTitleColor:UIColorFromHex(@"#a2a2a2", 1.0) forState:UIControlStateDisabled];
	[_commentButton setEnabled:NO];
	//commentButton.backgroundColor = [UIColor redColor];
	[_footerView addSubview:_commentButton];
}

- (void)initData {
	[MiaAPIHelper getShareById:[_shareItem sID]];

	_dataModel = [[CommentModel alloc] init];
	[self requestComments];
}

- (void)initLocationMgr {
	if (nil == _locationManager) {
		_locationManager = [[CLLocationManager alloc] init];
	}

	_locationManager.delegate = self;

	//设置定位的精度
	_locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;

	//设置定位服务更新频率
	_locationManager.distanceFilter = 500;

	if ([[[UIDevice currentDevice] systemVersion] doubleValue]>=8.0) {

		[_locationManager requestWhenInUseAuthorization];	// 前台定位
		//[mylocationManager requestAlwaysAuthorization];	// 前后台同时定位
	}

	[_locationManager startUpdatingLocation];
}

- (void)requestComments {
	static const long kCommentPageItemCount	= 10;
	[MiaAPIHelper getMusicCommentWithShareID:_shareItem.sID start:_dataModel.lastCommentID item:kCommentPageItemCount];
	//[MiaAPIHelper getMusicCommentWithShareID:@"244" start:commentModel.lastCommentID item:kCommentPageItemCount];
}

- (void)requestLatestComments {
	[MiaAPIHelper getMusicCommentWithShareID:_shareItem.sID start:_dataModel.latestCommentID item:1];
}

- (void)checkCommentButtonStatus {
	if ([_commentTextField.text length] <= 0) {
		[_commentButton setEnabled:NO];
	} else {
		[_commentButton setEnabled:YES];
	}
}

- (void)showMBProgressHUD{
	if(!_progressHUD){
		UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
		_progressHUD = [[MBProgressHUD alloc] initWithView:window];
		[window addSubview:_progressHUD];
		_progressHUD.dimBackground = YES;
		_progressHUD.labelText = @"正在提交评论";
		[_progressHUD show:YES];
	}
}

- (void)removeMBProgressHUD:(BOOL)isSuccess removeMBProgressHUDBlock:(RemoveMBProgressHUDBlock)removeMBProgressHUDBlock{
	if(_progressHUD){
		if(isSuccess){
			_progressHUD.labelText = @"评论成功";
		}else{
			_progressHUD.labelText = @"评论失败，请稍后再试";
		}
		_progressHUD.mode = MBProgressHUDModeText;
		[_progressHUD showAnimated:YES whileExecutingBlock:^{
			sleep(1);
		} completionBlock:^{
			[_progressHUD removeFromSuperview];
			_progressHUD = nil;
			if(removeMBProgressHUDBlock)
				removeMBProgressHUDBlock();
		}];
	}
}

#pragma mark - delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	const NSInteger kButtonIndex_Report = 0;
	if (kButtonIndex_Report == buttonIndex) {
		if (!_progressHUD) {
			_progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
			[self.view addSubview:_progressHUD];
			_progressHUD.labelText = NSLocalizedString(@"举报成功", nil);
			_progressHUD.mode = MBProgressHUDModeText;
			[_progressHUD showAnimated:YES whileExecutingBlock:^{
				sleep(2);
			} completionBlock:^{
				[_progressHUD removeFromSuperview];
				_progressHUD = nil;
			}];
		}
	}
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	if ([[UserSession standard] isLogined]) {
		return YES;
	} else {
		LoginViewController *vc = [[LoginViewController alloc] init];
		//vc.loginViewControllerDelegate = self;
		[self.navigationController pushViewController:vc animated:YES];

		return NO;
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == _commentTextField) {
		[textField resignFirstResponder];
	}

	return true;
}

- (void) textFieldDidChange:(id) sender {
	[self checkCommentButtonStatus];
}

// 获取地理位置变化的起始点和终点,didUpdateToLocation：
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

	CLLocation * location = [[CLLocation alloc]initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
	CLLocation * marsLoction =   [location locationMarsFromEarth];
	NSLog(@"didUpdateToLocation 当前位置的纬度:%.2f--经度%.2f", marsLoction.coordinate.latitude, marsLoction.coordinate.longitude);

	CLGeocoder *geocoder=[[CLGeocoder alloc]init];
	[geocoder reverseGeocodeLocation:marsLoction completionHandler:^(NSArray *placemarks,NSError *error) {
		if (placemarks.count > 0) {
			CLPlacemark *placemark = [placemarks objectAtIndex:0];
			NSLog(@"______%@", placemark.locality);
			NSLog(@"______%@", placemark.subLocality);
			NSLog(@"______%@", placemark.name);

			_currentCoordinate = marsLoction.coordinate;
			_currentAddress = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.subLocality];
		}
	}];

	[manager stopUpdatingLocation];
}

- (void)detailHeaderViewClickedFavoritor {
	if ([[UserSession standard] isLogined]) {
		NSLog(@"favorite to profile page.");

		[MiaAPIHelper favoriteMusicWithShareID:_shareItem.sID isFavorite:!_shareItem.favorite];
	} else {
		LoginViewController *vc = [[LoginViewController alloc] init];
		//vc.loginViewControllerDelegate = self;
		[self.navigationController pushViewController:vc animated:YES];
	}
}

- (void)detailHeaderViewClickedSharer {
	ProfileViewController *vc = [[ProfileViewController alloc] initWitUID:_shareItem.uID
																 nickName:_shareItem.sNick
															  isMyProfile:NO];
	[self.navigationController pushViewController:vc animated:YES];
}

- (void)commentCellAvatarTouched:(CommentItem *)item {
	ProfileViewController *vc = [[ProfileViewController alloc] initWitUID:item.uid
																 nickName:item.unick
															  isMyProfile:NO];
	[self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - collectionView代理方法

//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return _dataModel.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	CommentCollectionViewCell *cell = (CommentCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kDetailCellReuseIdentifier
																											 forIndexPath:indexPath];
	[cell setDelegate:self];
	[cell setDataItem:_dataModel.dataSource[indexPath.row]];
	return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat itemWidth = self.view.frame.size.width - kDetailItemMarginH * 2;
	return CGSizeMake(itemWidth, kDetailItemHeight);
}

//footer的size
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
//{
//    return CGSizeMake(10, 10);
//}

//header的size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return [self headerViewSize];
}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
	return UIEdgeInsetsMake(10, 10, 10, 10);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
	return kDetailItemMarginH;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
	return kDetailItemMarginV;
}

//通过设置SupplementaryViewOfKind 来设置头部或者底部的view，其中 ReuseIdentifier 的值必须和 注册是填写的一致，本例都为 “reusableView”
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	if ([kind isEqual:UICollectionElementKindSectionHeader]) {
		UICollectionReusableView *contentView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kDetailHeaderReuseIdentifier forIndexPath:indexPath];
		if (contentView.subviews.count == 0) {
			[contentView addSubview:_detailHeaderView];
		}
		return contentView;
//	} else if ([kind isEqual:UICollectionElementKindSectionFooter]) {
//		UICollectionReusableView *contentView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kDetailFooterReuseIdentifier forIndexPath:indexPath];
//		if (contentView.subviews.count == 0) {
//			[contentView addSubview:footerView];
//		}
//		return contentView;
	} else {
		NSLog(@"It's maybe a bug.");
		return nil;
	}
}

//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//	ProfileCollectionViewCell *cell = (ProfileCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
}

#pragma mark - Notification

- (void)notificationWebSocketDidReceiveMessage:(NSNotification *)notification {
	NSString *command = [notification userInfo][MiaAPIKey_ServerCommand];
	id ret = [notification userInfo][MiaAPIKey_Values][MiaAPIKey_Return];
	//NSLog(@"%@", command);

	if ([command isEqualToString:MiaAPICommand_Music_GetMcomm]) {
		[self handleGetMusicCommentWitRet:[ret intValue] userInfo:[notification userInfo]];
	} else if ([command isEqualToString:MiaAPICommand_User_PostComment]) {
		[self handlePostCommentWitRet:[ret intValue] userInfo:[notification userInfo]];
	} else if ([command isEqualToString:MiaAPICommand_User_PostViewm]) {
		[self handlePostViewmWitRet:[ret intValue] userInfo:[notification userInfo]];
	} else if ([command isEqualToString:MiaAPICommand_Music_GetSharem]) {
		[self handleGetSharemWitRet:[ret intValue] userInfo:[notification userInfo]];
	} else if ([command isEqualToString:MiaAPICommand_User_PostFavorite]) {
		[self handleFavoriteWitRet:[ret intValue] userInfo:[notification userInfo]];
	}
}

- (void)handleGetMusicCommentWitRet:(int)ret userInfo:(NSDictionary *) userInfo {
	[_collectionView footerEndRefreshing];

	if (0 != ret)
		return;
	NSArray *commentArray = userInfo[@"v"][@"info"];
	if (!commentArray || [commentArray count] <= 0)
		return;

	[_dataModel addComments:commentArray];
	[_collectionView reloadData];
}

- (void)handlePostCommentWitRet:(int)ret userInfo:(NSDictionary *) userInfo {
	BOOL isSuccess = (0 == ret);

	if (isSuccess) {
		_commentTextField.text = @"";
		[self requestLatestComments];
	}

	[_commentTextField resignFirstResponder];
	[self removeMBProgressHUD:isSuccess removeMBProgressHUDBlock:nil];
}

- (void)handlePostViewmWitRet:(int)ret userInfo:(NSDictionary *) userInfo {
	if (0 == ret) {
		[MiaAPIHelper getShareById:[_shareItem sID]];
	} else {
		NSLog(@"handlePostViewmWitRet failed.");
	}
}

- (void)handleGetSharemWitRet:(int)ret userInfo:(NSDictionary *) userInfo {
	if (0 == ret) {
		//"v":{"ret":0, "data":{"sID", "star": 1, "cComm":2, "cView": 2}}}
		NSString *sID = userInfo[MiaAPIKey_Values][@"data"][@"sID"];
		long start = [userInfo[MiaAPIKey_Values][@"data"][@"star"] intValue];
		id cComm = userInfo[MiaAPIKey_Values][@"data"][@"cComm"];
		id cView = userInfo[MiaAPIKey_Values][@"data"][@"cView"];
		NSArray *infectArray = userInfo[MiaAPIKey_Values][@"data"][@"infectList"];

		if ([sID isEqualToString:_shareItem.sID]) {
			_shareItem.cComm = [cComm intValue];
			_shareItem.cView = [cView intValue];
			_shareItem.favorite = start;
			[_shareItem parseInfectUsersFromJsonArray:infectArray];
			
			_detailHeaderView.shareItem = _shareItem;
		}

		//NSLog(@"%@, %ld, %@, %@", sID, start, cComm, cView);
	} else {
		NSLog(@"handleGetSharemWitRet failed.");
	}
}

- (void)handleFavoriteWitRet:(int)ret userInfo:(NSDictionary *) userInfo {
	if (0 == ret) {
		id act = userInfo[MiaAPIKey_Values][@"act"];
		id sID = userInfo[MiaAPIKey_Values][@"id"];
		if ([_shareItem.sID integerValue] == [sID intValue]) {
			_shareItem.favorite = [act intValue];
			[_detailHeaderView updateShareButtonWithIsFavorite:_shareItem.favorite];
		}
	} else {
		NSLog(@"favorite music failed.");
	}
}

/*
 *   即将显示键盘的处理
 */
- (void)keyBoardWillShow:(NSNotification *)notification{
	NSDictionary *info = [notification userInfo];
	//获取当前显示的键盘高度
	CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey ] CGRectValue].size;
	[self moveUpViewForKeyboard:keyboardSize];
}

- (void)keyBoardWillHide:(NSNotification *)notification{
	[self resumeView];
}

#pragma mark - keyboard

- (void)moveUpViewForKeyboard:(CGSize)keyboardSize {
	NSTimeInterval animationDuration = 0.30f;
	[UIView beginAnimations:@"ResizeForKeyboard" context:nil];
	[UIView setAnimationDuration:animationDuration];
//	float width = footerView.frame.size.width;
//	float height = footerView.frame.size.height;
//
//	CGRect rect = CGRectMake(0.0f, -keyboardSize.height, width,height);
	CGRect rect = CGRectMake(0, self.view.bounds.size.height - kDetailFooterViewHeight - keyboardSize.height, self.view.bounds.size.width, kDetailFooterViewHeight);
	_footerView.frame = rect;
	[UIView commitAnimations];
}

- (void)resumeView {
	NSTimeInterval animationDuration = 0.30f;
	[UIView beginAnimations:@"ResizeForKeyboard" context:nil];
	[UIView setAnimationDuration:animationDuration];
//	float width = self.view.frame.size.width;
//	float height = self.view.frame.size.height;
	CGRect rect = CGRectMake(0, self.view.bounds.size.height - kDetailFooterViewHeight, self.view.bounds.size.width, kDetailFooterViewHeight);
	_footerView.frame = rect;
	[UIView commitAnimations];
}

- (void)hidenKeyboard {
	[_commentTextField resignFirstResponder];
	[self checkCommentButtonStatus];
}

#pragma mark - button Actions

- (void)backButtonAction:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)moreButtonAction:(id)sender {
	UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:@"更多操作"
													 delegate:self
											cancelButtonTitle:@"取消"
									   destructiveButtonTitle:@"举报"
											otherButtonTitles: nil];
	[sheet showInView:self.view];
}

- (void)commentButtonAction:(id)sender {
	NSLog(@"comment button clicked.");
	[self showMBProgressHUD];
	[MiaAPIHelper postCommentWithShareID:_shareItem.sID comment:_commentTextField.text];

}

- (void)reportViewsTimerAction {
	[MiaAPIHelper viewShareWithLatitude:_currentCoordinate.latitude
							  longitude:_currentCoordinate.longitude
								address:_currentAddress
								   spID:_shareItem.spID];
}

@end
