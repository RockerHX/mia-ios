//
//  SettingViewController.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "SettingViewController.h"
#import "MIAButton.h"
#import "MIALabel.h"
#import "MiaAPIHelper.h"
#import "UIImageView+WebCache.h"
#import "WebSocketMgr.h"
#import "MBProgressHUD.h"
#import "MBProgressHUDHelp.h"
#import "Masonry.h"
#import "UserSession.h"
#import "UserSetting.h"
#import "GenderPickerView.h"
#import "UIImage+Extrude.h"

@interface SettingViewController ()
<UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
GenderPickerViewDelegate>

@end

@implementation SettingViewController {
	UIScrollView	*_scrollView;
	UIView 			*_scrollContentView;

	UIView			*_userInfoView;
	UIView			*_playSettingView;
	UIView			*_versionView;
	UIView			*_logoutView;

	UIImageView 	*_avatarImageView;
	MIALabel 		*_nickNameLabel;
	MIALabel 		*_genderLabel;
	UISwitch 		*_autoPlaySwitch;
	UISwitch 		*_playWith3GSwitch;

	MBProgressHUD 	*_progressHUD;

	MIAGender		_gender;

	UIImage 		*_uploadingImage;
	long			_uploadTimeOutCount;
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidReceiveMessage object:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	[self initUI];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidReceiveMessage:) name:WebSocketMgrNotificationDidReceiveMessage object:nil];

	[MiaAPIHelper getUserInfoWithUID:[[UserSession standard] uid]];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	_scrollView.contentSize = _scrollContentView.frame.size;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
	return NO;
}

- (void)initUI {
	static NSString *kSettingTitle = @"设置";
	self.title = kSettingTitle;

	_scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
	_scrollView.backgroundColor = UIColorFromHex(@"f0eff5", 1.0);
	_scrollView.scrollEnabled = YES;
	_scrollView.pagingEnabled = NO;
	_scrollView.showsVerticalScrollIndicator = YES;
	_scrollView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_scrollView];

	_scrollContentView = [[UIView alloc] initWithFrame:_scrollView.bounds];
	[_scrollView addSubview:_scrollContentView];

	[self initBarButton];
	[self initUserInfoView];
	[self initPlaySettingView];
	[self initVersionView];
	[self initLogoutView];
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
}

- (void)initUserInfoView {
	_userInfoView = [[UIView alloc] init];
	_userInfoView.backgroundColor = [UIColor whiteColor];
	[_scrollContentView addSubview:_userInfoView];

	UIView *avatarView = [[UIView alloc] init];
	//avatarView.backgroundColor = [UIColor yellowColor];
	[avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTouchAction:)]];
	[_userInfoView addSubview:avatarView];

	UIView *nickNameView = [[UIView alloc] init];
	//avatarView.backgroundColor = [UIColor greenColor];
	[nickNameView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nickNameTouchAction:)]];
	[_userInfoView addSubview:nickNameView];

	UIView *genderView = [[UIView alloc] init];
	//genderView.backgroundColor = [UIColor yellowColor];
	[genderView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(genderTouchAction:)]];
	[_userInfoView addSubview:genderView];

	UIView *changePasswordView = [[UIView alloc] init];
	//changePasswordView.backgroundColor = [UIColor greenColor];
	[changePasswordView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changePasswordTouchAction:)]];
	[_userInfoView addSubview:changePasswordView];

	[_userInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@220);
		make.left.equalTo(_scrollContentView.mas_left);
		make.top.equalTo(_scrollContentView.mas_top).offset(15);
		make.right.equalTo(_scrollContentView.mas_right);
	}];

	[avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@70);
		make.left.equalTo(_userInfoView.mas_left);
		make.top.equalTo(_userInfoView.mas_top);
		make.right.equalTo(_userInfoView.mas_right);
	}];

	[nickNameView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@50);
		make.left.equalTo(_userInfoView.mas_left);
		make.top.equalTo(avatarView.mas_bottom);
		make.right.equalTo(_userInfoView.mas_right);
	}];

	[genderView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@50);
		make.left.equalTo(_userInfoView.mas_left);
		make.top.equalTo(nickNameView.mas_bottom);
		make.right.equalTo(_userInfoView.mas_right);
	}];

	[changePasswordView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@50);
		make.left.equalTo(_userInfoView.mas_left);
		make.top.equalTo(genderView.mas_bottom);
		make.right.equalTo(_userInfoView.mas_right);
	}];

	[self initAvatarView:avatarView];
	[self initNickNameView:nickNameView];
	[self initGenderView:genderView];
	[self initChangePasswordView:changePasswordView];
}

- (void)initAvatarView:(UIView *)contentView {
	static const CGFloat avatarWidth = 45;

	MIALabel *avatarTitleLabel = [[MIALabel alloc] initWithFrame:CGRectZero
															text:@"头像"
															font:UIFontFromSize(15.0f)
													   textColor:[UIColor blackColor]
												   textAlignment:NSTextAlignmentLeft
													 numberLines:1];
	[contentView addSubview:avatarTitleLabel];

	_avatarImageView = [[UIImageView alloc] init];
	_avatarImageView.layer.cornerRadius = avatarWidth / 2;
	_avatarImageView.clipsToBounds = YES;
	_avatarImageView.layer.borderWidth = 1.0f;
	_avatarImageView.layer.borderColor = UIColorFromHex(@"a2a2a2", 1.0).CGColor;
	[_avatarImageView setImage:[UIImage imageNamed:@"default_avatar"]];
	[contentView addSubview:_avatarImageView];

	UIView *avatarLineView = [[UIView alloc] init];
	avatarLineView.backgroundColor = UIColorFromHex(@"eaeaea", 1.0);
	[contentView addSubview:avatarLineView];

	[avatarTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@200);
		make.height.equalTo(@20);
		make.left.equalTo(contentView.mas_left).offset(15);
		make.bottom.equalTo(contentView.mas_bottom).offset(-17);
	}];
	[_avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake(avatarWidth, avatarWidth));
		make.right.equalTo(contentView.mas_right).offset(-15);
		make.centerY.equalTo(contentView.mas_centerY);
	}];
	[avatarLineView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@1);
		make.left.equalTo(contentView.mas_left).offset(15);
		make.right.equalTo(contentView.mas_right);
		make.bottom.equalTo(contentView.mas_bottom);
	}];
}

- (void)initNickNameView:(UIView *)contentView {
	MIALabel *titleLabel = [[MIALabel alloc] initWithFrame:CGRectZero
															text:@"昵称"
															font:UIFontFromSize(15.0f)
													   textColor:[UIColor blackColor]
												   textAlignment:NSTextAlignmentLeft
													 numberLines:1];
	[contentView addSubview:titleLabel];

	_nickNameLabel = [[MIALabel alloc] initWithFrame:CGRectZero
															text:[[UserSession standard] nick]
															font:UIFontFromSize(15.0f)
													   textColor:[UIColor blackColor]
												   textAlignment:NSTextAlignmentRight
													 numberLines:1];
	[contentView addSubview:_nickNameLabel];

	UIView *lineView = [[UIView alloc] init];
	lineView.backgroundColor = UIColorFromHex(@"eaeaea", 1.0);
	[contentView addSubview:lineView];

	[titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@200);
		make.height.equalTo(@20);
		make.left.equalTo(contentView.mas_left).offset(15);
		make.bottom.equalTo(contentView.mas_bottom).offset(-17);
	}];
	[_nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(contentView.mas_top);
		make.bottom.equalTo(contentView.mas_bottom);
		make.width.equalTo(@200);
		make.right.equalTo(contentView.mas_right).offset(-15);
	}];
	[lineView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@1);
		make.left.equalTo(contentView.mas_left).offset(15);
		make.right.equalTo(contentView.mas_right);
		make.bottom.equalTo(contentView.mas_bottom);
	}];
}

- (void)initGenderView:(UIView *)contentView {
	MIALabel *titleLabel = [[MIALabel alloc] initWithFrame:CGRectZero
															text:@"性别"
															font:UIFontFromSize(15.0f)
												 textColor:[UIColor blackColor]
											 textAlignment:NSTextAlignmentLeft
													 numberLines:1];
	[contentView addSubview:titleLabel];

	_genderLabel = [[MIALabel alloc] initWithFrame:CGRectZero
															text:@"请选择"
															font:UIFontFromSize(15.0f)
													textColor:UIColorFromHex(@"a2a2a2", 1.0)
												textAlignment:NSTextAlignmentRight
													 numberLines:1];
	[contentView addSubview:_genderLabel];

	UIView *lineView = [[UIView alloc] init];
	lineView.backgroundColor = UIColorFromHex(@"eaeaea", 1.0);
	[contentView addSubview:lineView];

	[titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@200);
		make.height.equalTo(@20);
		make.left.equalTo(contentView.mas_left).offset(15);
		make.bottom.equalTo(contentView.mas_bottom).offset(-17);
	}];
	[_genderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(contentView.mas_top);
		make.bottom.equalTo(contentView.mas_bottom);
		make.width.equalTo(@200);
		make.right.equalTo(contentView.mas_right).offset(-15);
	}];
	[lineView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@1);
		make.left.equalTo(contentView.mas_left).offset(15);
		make.right.equalTo(contentView.mas_right);
		make.bottom.equalTo(contentView.mas_bottom);
	}];
}
- (void)initChangePasswordView:(UIView *)contentView {
	MIALabel *titleLabel = [[MIALabel alloc] initWithFrame:CGRectZero
															text:@"密码"
															font:UIFontFromSize(15.0f)
												 textColor:[UIColor blackColor]
											 textAlignment:NSTextAlignmentLeft
													 numberLines:1];
	[contentView addSubview:titleLabel];

	MIALabel *changePasswordNameLabel = [[MIALabel alloc] initWithFrame:CGRectZero
															text:@"修改密码"
															font:UIFontFromSize(15.0f)
													textColor:UIColorFromHex(@"a2a2a2", 1.0)
												textAlignment:NSTextAlignmentRight
													 numberLines:1];
	[contentView addSubview:changePasswordNameLabel];

	[titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@200);
		make.height.equalTo(@20);
		make.left.equalTo(contentView.mas_left).offset(15);
		make.bottom.equalTo(contentView.mas_bottom).offset(-17);
	}];
	[changePasswordNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(contentView.mas_top);
		make.bottom.equalTo(contentView.mas_bottom);
		make.width.equalTo(@200);
		make.right.equalTo(contentView.mas_right).offset(-15);
	}];
}

- (void)initPlaySettingView {
	_playSettingView = [[UIView alloc] init];
	_playSettingView.backgroundColor = [UIColor whiteColor];
	[_scrollContentView addSubview:_playSettingView];

	UIView *autoPlayView = [[UIView alloc] init];
	//autoPlayView.backgroundColor = [UIColor orangeColor];
	[_playSettingView addSubview:autoPlayView];

	UIView *playWith3GView = [[UIView alloc] init];
	//playWith3GView.backgroundColor = [UIColor greenColor];
	[_playSettingView addSubview:playWith3GView];

	UIView *cleanCacheView = [[UIView alloc] init];
	//cleanCacheView.backgroundColor = [UIColor yellowColor];
	[cleanCacheView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cleanCacheTouchAction:)]];
	[_playSettingView addSubview:cleanCacheView];

	[_playSettingView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@150);
		make.left.equalTo(_scrollContentView.mas_left);
		make.top.equalTo(_userInfoView.mas_bottom).offset(15);
		make.right.equalTo(_scrollContentView.mas_right);
	}];

	[autoPlayView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@50);
		make.left.equalTo(_playSettingView.mas_left);
		make.top.equalTo(_playSettingView.mas_top);
		make.right.equalTo(_playSettingView.mas_right);
	}];
	[playWith3GView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@50);
		make.left.equalTo(_playSettingView.mas_left);
		make.top.equalTo(autoPlayView.mas_bottom);
		make.right.equalTo(_playSettingView.mas_right);
	}];
	[cleanCacheView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@50);
		make.left.equalTo(_playSettingView.mas_left);
		make.top.equalTo(playWith3GView.mas_bottom);
		make.right.equalTo(_playSettingView.mas_right);
	}];

	[self initAutoPlayView:autoPlayView];
	[self initPlayWith3GView:playWith3GView];
	[self initCleanCache:cleanCacheView];
}

- (void)initAutoPlayView:(UIView *)contentView {
	MIALabel *autoPlayLabel = [[MIALabel alloc] initWithFrame:CGRectZero
														 text:@"启动后自动播放"
														 font:UIFontFromSize(15.0f)
													textColor:[UIColor blackColor]
												textAlignment:NSTextAlignmentLeft
												  numberLines:1];
	[contentView addSubview:autoPlayLabel];

	_autoPlaySwitch = [[UISwitch alloc] init];
	[_autoPlaySwitch setOn:[UserSetting autoPlay]];
	[_autoPlaySwitch addTarget:self action:@selector(autoPlaySwitchAction:) forControlEvents:UIControlEventValueChanged];
	[contentView addSubview:_autoPlaySwitch];

	UIView *lineView = [[UIView alloc] init];
	lineView.backgroundColor = UIColorFromHex(@"eaeaea", 1.0);
	[contentView addSubview:lineView];

	[autoPlayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@200);
		make.left.equalTo(contentView.mas_left).offset(15);
		make.top.equalTo(contentView.mas_top);
		make.bottom.equalTo(contentView.mas_bottom);
	}];
	[_autoPlaySwitch mas_makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@50);
		make.right.equalTo(contentView.mas_right).offset(-15);
		make.top.equalTo(contentView.mas_top).offset(10);
		make.bottom.equalTo(contentView.mas_bottom).offset(-10);
	}];
	[lineView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@1);
		make.left.equalTo(contentView.mas_left).offset(15);
		make.right.equalTo(contentView.mas_right);
		make.bottom.equalTo(contentView.mas_bottom);
	}];
}
- (void)initPlayWith3GView:(UIView *)contentView {
	MIALabel *playWith3GLabel = [[MIALabel alloc] initWithFrame:CGRectZero
														   text:@"在2G/3G/4G网络下播放"
														   font:UIFontFromSize(15.0f)
													  textColor:[UIColor blackColor]
												  textAlignment:NSTextAlignmentLeft
													numberLines:1];
	[contentView addSubview:playWith3GLabel];

	_playWith3GSwitch = [[UISwitch alloc] init];
	[_playWith3GSwitch setOn:[UserSetting playWith3G]];
	[_playWith3GSwitch addTarget:self action:@selector(playWith3GSwitchAction:) forControlEvents:UIControlEventValueChanged];
	[contentView addSubview:_playWith3GSwitch];

	UIView *lineView = [[UIView alloc] init];
	lineView.backgroundColor = UIColorFromHex(@"eaeaea", 1.0);
	[contentView addSubview:lineView];

	[playWith3GLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@200);
		make.left.equalTo(contentView.mas_left).offset(15);
		make.top.equalTo(contentView.mas_top);
		make.bottom.equalTo(contentView.mas_bottom);
	}];
	[_playWith3GSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@50);
		make.right.equalTo(contentView.mas_right).offset(-15);
		make.top.equalTo(contentView.mas_top).offset(10);
		make.bottom.equalTo(contentView.mas_bottom).offset(-10);
	}];
	[lineView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@1);
		make.left.equalTo(contentView.mas_left).offset(15);
		make.right.equalTo(contentView.mas_right);
		make.bottom.equalTo(contentView.mas_bottom);
	}];
}

- (void)initCleanCache:(UIView *)contentView {
	MIALabel *titleLabel = [[MIALabel alloc] initWithFrame:CGRectZero
															text:@"清除缓存"
															font:UIFontFromSize(15.0f)
												 textColor:[UIColor blackColor]
											 textAlignment:NSTextAlignmentLeft
													 numberLines:1];
	[contentView addSubview:titleLabel];

	[titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(contentView).insets(UIEdgeInsetsMake(15, 15, 15, 15));
	}];
}

- (void)initVersionView {
	_versionView = [[UIView alloc] init];
	_versionView.backgroundColor = [UIColor whiteColor];
	[_scrollContentView addSubview:_versionView];

	MIALabel *versionTitleLabel = [[MIALabel alloc] initWithFrame:CGRectZero
														 text:@"当前版本"
														 font:UIFontFromSize(15.0f)
													textColor:[UIColor blackColor]
												textAlignment:NSTextAlignmentLeft
												  numberLines:1];
	[_versionView addSubview:versionTitleLabel];

	NSString *buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	NSString *shortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	NSString *version = [NSString stringWithFormat:@"V%@.%@", shortVersion, buildVersion];

	MIALabel *versionLabel = [[MIALabel alloc] initWithFrame:CGRectZero
															 text:version
															 font:UIFontFromSize(15.0f)
														textColor:UIColorFromHex(@"a2a2a2", 1.0)
													textAlignment:NSTextAlignmentRight
													  numberLines:1];
	[_versionView addSubview:versionLabel];

	[_versionView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_scrollContentView.mas_left);
		make.right.equalTo(_scrollContentView.mas_right);
		make.height.equalTo(@50);
		make.top.equalTo(_playSettingView.mas_bottom).offset(15);
	}];

	[versionTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@200);
		make.height.equalTo(@20);
		make.left.equalTo(_versionView.mas_left).offset(15);
		make.bottom.equalTo(_versionView.mas_bottom).offset(-17);
	}];
	[versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_versionView.mas_top);
		make.bottom.equalTo(_versionView.mas_bottom);
		make.width.equalTo(@200);
		make.right.equalTo(_versionView.mas_right).offset(-15);
	}];

}

- (void)initLogoutView {
	_logoutView = [[UIView alloc] init];
	_logoutView.backgroundColor = [UIColor whiteColor];
	[_scrollContentView addSubview:_logoutView];

	[_logoutView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoutTouchAction:)]];

	MIALabel *logoutTitleLabel = [[MIALabel alloc] initWithFrame:CGRectZero
															 text:@"退出登录"
															 font:UIFontFromSize(15.0f)
														textColor:[UIColor blackColor]
													textAlignment:NSTextAlignmentLeft
													  numberLines:1];
	[_logoutView addSubview:logoutTitleLabel];

	[_logoutView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_scrollContentView.mas_left);
		make.right.equalTo(_scrollContentView.mas_right);
		make.height.equalTo(@50);
		make.top.equalTo(_versionView.mas_bottom).offset(15);
	}];
	[logoutTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(_logoutView.mas_centerY);
		make.left.equalTo(_logoutView.mas_left).offset(15);
		make.width.equalTo(@200);
	}];
}

- (void)updateGenderLabel:(MIAGender)gender {
	if (1 == gender) {
		[_genderLabel setText:@"男"];
	} else if (2 == gender) {
		[_genderLabel setText:@"女"];
	} else {
		[_genderLabel setText:@"请选择"];
	}
}


- (void)showMBProgressHUD{
	if(!_progressHUD){
		UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
		_progressHUD = [[MBProgressHUD alloc] initWithView:window];
		[window addSubview:_progressHUD];
		_progressHUD.dimBackground = YES;
		_progressHUD.labelText = @"退出登录中...";
		[_progressHUD show:YES];
	}
}

- (void)removeMBProgressHUD:(BOOL)isSuccess removeMBProgressHUDBlock:(RemoveMBProgressHUDBlock)removeMBProgressHUDBlock{
	if(_progressHUD){
		if(isSuccess){
			_progressHUD.labelText = @"成功退出登录，请重新登录";
		}else{
			_progressHUD.labelText = @"退出登录失败，请稍后再试";
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

- (void)uploadAvatarWithUrl:(NSString *)url
					   auth:(NSString *)auth
				contentType:(NSString *)contentType
				   filename:(NSString *)filename
					  image:(UIImage *)image
{
	// 压缩图片，放线程中进行
	dispatch_queue_t queue = dispatch_queue_create("RequestUploadPhoto", NULL);
	dispatch_async(queue, ^(){
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url ]];
		request.HTTPMethod = @"PUT";
		[request setValue:auth forHTTPHeaderField:@"Authorization"];
		[request setValue:contentType forHTTPHeaderField:@"Content-Type"];

		float compressionQuality = 0.9f;
		NSData *imageData;

		const static CGFloat kUploadAvatarMaxSize = 200;
		UIImage *squareImage = [UIImage imageWithCutImage:image moduleSize:CGSizeMake(kUploadAvatarMaxSize, kUploadAvatarMaxSize)];
		imageData = UIImageJPEGRepresentation(squareImage, compressionQuality);
		[request setValue:[NSString stringWithFormat:@"%ld", imageData.length] forHTTPHeaderField:@"Content-Length"];

		NSURLSession *session = [NSURLSession sharedSession];
		[[session uploadTaskWithRequest:request
							   fromData:imageData
					  completionHandler:
		  ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
			  BOOL isSuccessed = (!error && [data length] == 0);
			  dispatch_async(dispatch_get_main_queue(), ^{
				  [self updateAvatarWith:squareImage isSuccessed:isSuccessed];
			  });
		  }] resume];
	});
}

- (void)updateAvatarWith:(UIImage *)avatarImage isSuccessed:(BOOL)isSuccessed {
	if (!isSuccessed) {
		static NSString * kErrorInfo = @"上传头像失败，请稍后重试";
		[[MBProgressHUDHelp standarMBProgressHUDHelp] showHUDWithModeText:kErrorInfo];
		return;
	}

	[_avatarImageView setImage:avatarImage];
}

#pragma mark - delegate

- (void)imagePickerController:(UIImagePickerController *)picker
		didFinishPickingImage:(UIImage *)image
				  editingInfo:(NSDictionary *)editingInfo {
	[picker dismissViewControllerAnimated:YES completion:nil];
	_uploadingImage = image;
	[MiaAPIHelper getUploadAvatarAuth];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)genderPickerDidSelected:(MIAGender)gender {
	_gender = gender;
	[self updateGenderLabel:gender];
	[MiaAPIHelper changeGender:gender];
}

#pragma mark - Notification

- (void)notificationWebSocketDidReceiveMessage:(NSNotification *)notification {
	NSString *command = [notification userInfo][MiaAPIKey_ServerCommand];
	id ret = [notification userInfo][MiaAPIKey_Values][MiaAPIKey_Return];

//	NSLog(@"command:%@, ret:%d", command, [ret intValue]);

	if ([command isEqualToString:MiaAPICommand_User_PostLogout]) {
		[self handleLogoutWithRet:[ret intValue] userInfo:[notification userInfo]];
	} else if ([command isEqualToString:MiaAPICommand_User_GetUinfo]) {
		[self handleGetUserInfoWithRet:[ret intValue] userInfo:[notification userInfo]];
	} else if ([command isEqualToString:MiaAPICommand_User_GetClogo]) {
		[self handleGetUploadAvatarAuthWithRet:[ret intValue] userInfo:[notification userInfo]];
	} else if ([command isEqualToString:MiaAPICommand_User_PostCnick]) {
		[self handleChangeNickNameWithRet:[ret intValue] userInfo:[notification userInfo]];
	}  else if ([command isEqualToString:MiaAPICommand_User_PostGender]) {
		[self handleChangeGenderWithRet:[ret intValue] userInfo:[notification userInfo]];
	}
}

- (void)handleLogoutWithRet:(int)ret userInfo:(NSDictionary *) userInfo {
	BOOL isSuccess = (0 == ret);
	[self removeMBProgressHUD:isSuccess removeMBProgressHUDBlock:nil];
	if (isSuccess) {
		[[UserSession standard] logout];
		[self.navigationController popToRootViewControllerAnimated:YES];
	}
}

- (void)handleGetUserInfoWithRet:(int)ret userInfo:(NSDictionary *) userInfo {
	if (0 != ret) {
		id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
		NSLog(@"get user info failed! error:%@", error);
	}

	NSString *avatarUrl = userInfo[MiaAPIKey_Values][@"info"][0][@"uimg"];
	NSString *nickName = userInfo[MiaAPIKey_Values][@"info"][0][@"nick"];
	long gender = [userInfo[MiaAPIKey_Values][@"info"][0][@"gender"] intValue];

	[_nickNameLabel setText:nickName];

	NSString *avatarUrlWithTime = [NSString stringWithFormat:@"%@?t=%ld", avatarUrl, (long)[[NSDate date] timeIntervalSince1970]];
	[_avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrlWithTime]
								placeholderImage:[UIImage imageNamed:@"default_avatar"]];
	[self updateGenderLabel:gender];
}

- (void)handleGetUploadAvatarAuthWithRet:(int)ret userInfo:(NSDictionary *) userInfo {
	if (0 != ret) {
		static NSString * kGetUserInfoError = @"上传头像失败，请稍后重试";
		[[MBProgressHUDHelp standarMBProgressHUDHelp] showHUDWithModeText:kGetUserInfoError];

		id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
		NSLog(@"handleGetUploadAvatarAuthWithRet failed! error:%@", error);
	}

	NSString *uploadUrl = userInfo[MiaAPIKey_Values][@"info"][@"url"];
	NSString *auth = userInfo[MiaAPIKey_Values][@"info"][@"auth"];
	NSString *contentType = userInfo[MiaAPIKey_Values][@"info"][@"ctype"];
	NSString *filename = userInfo[MiaAPIKey_Values][@"info"][@"fname"];

	[self uploadAvatarWithUrl:uploadUrl auth:auth contentType:contentType filename:filename image:_uploadingImage];
}

- (void)handleChangeNickNameWithRet:(int)ret userInfo:(NSDictionary *) userInfo {
	if (0 != ret) {
		static NSString * kErrorInfo = @"修改昵称失败，请稍后重试";
		[[MBProgressHUDHelp standarMBProgressHUDHelp] showHUDWithModeText:kErrorInfo];

		id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
		NSLog(@"handleChangeNickNameWithRet failed! error:%@", error);
	}
}

- (void)handleChangeGenderWithRet:(int)ret userInfo:(NSDictionary *) userInfo {
	if (0 != ret) {
		static NSString * kErrorInfo = @"修改性别失败，请稍后重试";
		[[MBProgressHUDHelp standarMBProgressHUDHelp] showHUDWithModeText:kErrorInfo];

		id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
		NSLog(@"handleChangeGenderWithRet failed! error:%@", error);
	}
}

#pragma mark - button Actions

- (void)backButtonAction:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)autoPlaySwitchAction:(id)sender {
	[UserSetting setAutoPlay:_autoPlaySwitch.isOn];
}

- (void)playWith3GSwitchAction:(id)sender {
	[UserSetting setPlayWith3G:_playWith3GSwitch.isOn];
}

- (void)logoutTouchAction:(id)sender {
	[self showMBProgressHUD];
	[MiaAPIHelper logout];
}

- (void)avatarTouchAction:(id)sender {
	UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
		ipc.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
		ipc.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:ipc.sourceType];
	}
	ipc.delegate = self;
	ipc.allowsEditing = NO;
	[self presentViewController:ipc animated:YES completion:nil];
}

- (void)nickNameTouchAction:(id)sender {
	NSLog(@"nickNameTouchAction");
	//[MiaAPIHelper changeNickName:@"教授"];
}

- (void)genderTouchAction:(id)sender {
	GenderPickerView *pickerView = [[GenderPickerView alloc] initWithFrame:self.view.bounds];
	pickerView.customDelegate = self;
	[self.view addSubview:pickerView];
}

- (void)changePasswordTouchAction:(id)sender {
	NSLog(@"changePasswordTouchAction");
}

- (void)cleanCacheTouchAction:(id)sender {
	NSLog(@"cleanCacheTouchAction");
}

@end
