//
//  DetailViewController.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "DetailViewController.h"
#import "MIAButton.h"
#import "MBProgressHUD.h"
#import "UIImage+Extrude.h"
#import "DetailPlayerView.h"
#import "CommentTableView.h"
#import "MIAGrowingTextView.h"
#import "NSString+Emoji.h"
#import "NSString+IsNull.h"
#import "MiaAPIHelper.h"
#import "ShareItem.h"
#import "WebSocketMgr.h"

static const CGFloat kEditViewMarginLeft 		= 15;
static const CGFloat kEditViewMarginRight 		= 15;
static const CGFloat kEditViewMarginBottom 		= 15;
static const CGFloat kEditViewHeight			= 41;
static const CGFloat SUREORCANCLEVIEW_HEIGHT    = 50.0f;
static const long kCommentDefaultStart			= 0;
static const long kCommentPageItemCount			= 10;

@interface DetailViewController () <UIActionSheetDelegate, MIAGrowingTextViewDelegate>

@end

@implementation DetailViewController {
	UIScrollView *scrollView;
	DetailPlayerView *playerView;
	CommentTableView *commentTableView;
	UIView *editView;
    MIAGrowingTextView *_customBetTextView;
	MIAButton *commentButton;

	ShareItem *currentItem;

	UIView *sureOrCancleView;                               //【确定】/【取消】按钮所在视图
	CGSize keyboardSize;                                    //键盘高度
	CGFloat oldSureOrCancleViewToMove;                      //上一次的底部视图的【确定】/【取消】视图偏移高度
}

- (id)initWitShareItem:(ShareItem *)item {
	self = [super init];
	if (self) {
		currentItem = item;
		[self initUI];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidReceiveMessage:) name:WebSocketMgrNotificationDidReceiveMessage object:nil];

		[self requestCommentsFromStart:kCommentDefaultStart count:kCommentPageItemCount];
	}

	return self;
}


-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidReceiveMessage object:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

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
	return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
	return NO;
}

- (void)initUI {
	static NSString *kDetailTitle = @"详情页";
	self.title = kDetailTitle;
	[self.view setBackgroundColor:[UIColor redColor]];
	[self initBarButton];

	scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
	scrollView.delegate = self;
	scrollView.maximumZoomScale = 2.0f;
	scrollView.contentSize = self.view.bounds.size;
	scrollView.alwaysBounceHorizontal = NO;
	scrollView.alwaysBounceVertical = YES;
	scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	//scrollView.backgroundColor = [UIColor yellowColor];
	[self.view addSubview:scrollView];

	static const CGFloat kPlayerMarginTop			= 0;
	static const CGFloat kPlayerHeight				= 320;

	playerView = [[DetailPlayerView alloc] initWithFrame:CGRectMake(0, kPlayerMarginTop, scrollView.frame.size.width, kPlayerHeight)];
	playerView.shareItem = currentItem;
	[scrollView addSubview:playerView];

	commentTableView = [[CommentTableView alloc] initWithFrame:CGRectMake(0,
																		  kPlayerMarginTop + kPlayerHeight,
																		  scrollView.frame.size.width,
																		  scrollView.frame.size.height - kPlayerHeight - kPlayerMarginTop)
														 style:UITableViewStylePlain];
	//commentTableView.backgroundColor = [UIColor redColor];
	[scrollView addSubview:commentTableView];

	[self initEditView];
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

- (void)initEditView {
	editView = [[UIView alloc] initWithFrame:CGRectMake(kEditViewMarginLeft,
															   scrollView.bounds.size.height - kEditViewMarginBottom - kEditViewHeight,
															   scrollView.bounds.size.width - kEditViewMarginLeft - kEditViewMarginRight,
																kEditViewHeight)];
	//editView.backgroundColor = [UIColor redColor];
	[scrollView addSubview:editView];

	_customBetTextView = [[MIAGrowingTextView alloc] initWithFrame:editView.bounds textColor:[UIColor blackColor]];
	_customBetTextView.minNumberOfLines = 1;
	_customBetTextView.maxNumberOfLines = 3;
	_customBetTextView.returnKeyType = UIReturnKeyDone;
	_customBetTextView.font = [UIFont systemFontOfSize:15.0f];
	_customBetTextView.delegate = self;
	_customBetTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_customBetTextView.layer.cornerRadius = 5.0;
	_customBetTextView.layer.masksToBounds = YES;
	_customBetTextView.layer.borderWidth = 1.0f;
	_customBetTextView.layer.borderColor = [UIColor grayColor].CGColor;
	_customBetTextView.hidden = YES;
	[editView addSubview:_customBetTextView];


	CGRect commentButtonFrame = editView.bounds;
	commentButton = [[MIAButton alloc] initWithFrame:commentButtonFrame
										 titleString:@"此刻的想法"
										  titleColor:UIColorFromHex(@"#a2a2a2", 1.0)
												font:UIFontFromSize(15)
											 logoImg:[UIImage imageExtrude:[UIImage imageNamed:@"edit_logo"]]
									 backgroundImage:[UIImage imageExtrude:[UIImage imageNamed:@"edit_bg"]]];
	[commentButton addTarget:self action:@selector(commentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[editView addSubview:commentButton];

}

- (void)requestCommentsFromStart:(long)start count:(long)count {
	[MiaAPIHelper getMusicCommentWithShareID:[currentItem sID] start:start item:count];
}

#pragma mark - delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	const NSInteger kButtonIndex_Report = 0;
	if (kButtonIndex_Report == buttonIndex) {
		MBProgressHUD *progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
		[self.view addSubview:progressHUD];
		progressHUD.labelText = NSLocalizedString(@"举报成功", nil);
		progressHUD.mode = MBProgressHUDModeText;
		[progressHUD showAnimated:YES whileExecutingBlock:^{
			sleep(2);
		} completionBlock:^{
			[progressHUD removeFromSuperview];
		}];

	}
}

#pragma MIAGrowingTextView delegate
- (void)growingTextView:(MIAGrowingTextView *)growingTextView willChangeHeight:(float)height{

}

- (BOOL)growingTextView:(MIAGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
	if ([text isEqualToString:@"\n"]) {
		[self hideKeyBoard];
		return NO;
	}

	if (range.location >= 50 || [NSString isContainsEmoji:text])
		return NO;
	else
		return YES;
}


- (void)growingTextViewDidBeginEditing:(MIAGrowingTextView *)growingTextView{
	if(growingTextView == _customBetTextView){
		_customBetTextView.minNumberOfLines = 3;
		//[_betTipLabel setHidden:YES];
		[UIView animateWithDuration:0.4 animations:^{
//			allBetPunishsView.alpha = 0.0f;
//			sureBetButton.alpha = 0.0f;
			CGRect editViewFrame = editView.frame;
			// for test
			editViewFrame.origin.y -= 200;
			_customBetTextView.frame = editViewFrame;
		} completion:^(BOOL finished) {
			if(finished){
				CGRect textViewFrame = _customBetTextView.frame;
				textViewFrame.size.height += kEditViewHeight * 2;
				_customBetTextView.frame = textViewFrame;
			}
		}];
	}
}

- (void)growingTextViewDidEndEditing:(MIAGrowingTextView *)growingTextView{

}

//- (void)growingTextViewDidChange:(MIAGrowingTextView *)growingTextView{
//	NSString *text = [growingTextView text];
//	BOOL isHide = NO;
//	if([NSString isNull:text] && allBetPunishsView.alpha != 0){
//		isHide = NO;
//	}else{
//		isHide = YES;
//	}
//	[_betTipLabel setHidden:isHide];
//}

/*
 *   处理隐藏键盘
 */
-(void)hideKeyBoard{
	[_customBetTextView resignFirstResponder];
	_customBetTextView.minNumberOfLines = 1;
	[UIView animateWithDuration:0.4f animations:^{
//		CGRect frame = sureOrCancleView.frame;
//		frame.origin.y += keyboardSize.height + SUREORCANCLEVIEW_HEIGHT;
//		sureOrCancleView.frame = frame;
//
//		allBetPunishsView.alpha = 1.0;
//		sureBetButton.alpha = 1.0;
//
//		CGRect textFrame = _customBetTextView.frame;
//		if([NSString isNull:_customBetTextView.text]){
//			textFrame.origin.y += allBetPunishsView.frame.size.height + 10.0f;
//		}else{
//			textFrame.origin.y += allBetPunishsView.frame.size.height - BETBUTTON_SPAC;
//		}
//		textFrame.size.height -= TEXTVIEW_HEIGHT * 2;
//		_customBetTextView.frame = textFrame;

	} completion:^(BOOL finished) {
		//oldSureOrCancleViewToMove = 0;
	}];
}

/*
 *   即将显示键盘的处理
 */
-(void)keyBoardWillShow:(NSNotification *)notification{
	NSDictionary *info = [notification userInfo];
	//获取当前显示的键盘高度
	keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey ] CGRectValue].size;
	//获取当前键盘与上一次键盘的高度差
	CGFloat sureOrCancleViewToMove = keyboardSize.height - oldSureOrCancleViewToMove + SUREORCANCLEVIEW_HEIGHT;
	[self keyboardToMoveView:sureOrCancleViewToMove isUp:YES];
	oldSureOrCancleViewToMove = sureOrCancleViewToMove;

}

-(void)keyboardToMoveView:(int)sureOrCancleViewToMove isUp:(BOOL)isUp{
	[UIView animateWithDuration:0.3f animations:^{
		CGRect sureOrCancleViewFrame = [sureOrCancleView frame];
		if(isUp){
			sureOrCancleViewFrame.origin.y -= sureOrCancleViewToMove;
		}else{
			sureOrCancleViewFrame.origin.y += sureOrCancleViewToMove;
		}
		[sureOrCancleView setFrame:sureOrCancleViewFrame];
	} completion:^(BOOL finished) {

	}];
}

-(void)keyBoardWillHide:(NSNotification *)notification{
	//    [self resumnView:NO];
}


/*
 *   还原输入框的位置
 */
-(void)resumnView:(BOOL)isReloadTable{
	CGFloat sureOrCancleViewToMove = keyboardSize.height + SUREORCANCLEVIEW_HEIGHT;
	[self keyboardToMoveView:sureOrCancleViewToMove isUp:NO];
	oldSureOrCancleViewToMove = 0;
}

#pragma mark - Notification

-(void)notificationWebSocketDidReceiveMessage:(NSNotification *)notification {
	NSString *command = [notification userInfo][MiaAPIKey_ServerCommand];
	id ret = [notification userInfo][MiaAPIKey_Values][MiaAPIKey_Return];

//	NSLog(@"command:%@, ret:%d", command, [ret intValue]);

	if ([command isEqualToString:MiaAPICommand_Music_GetMcomm]) {
		[self handleGetMusicCommentWitRet:[ret intValue] userInfo:[notification userInfo]];
	}
}

- (void)handleGetMusicCommentWitRet:(int)ret userInfo:(NSDictionary *) userInfo {
	if (0 != ret)
		return;

	NSArray *commentArray = userInfo[@"v"][@"info"];
	if (!commentArray || [commentArray count] <= 0)
		return;

	// TODO 一直没有获取到真实的评论数据，等数据有了再修改下字段
	[commentTableView addComments:commentArray];
}


#pragma mark - button Actions

- (void)backButtonAction:(id)sender {
	NSLog(@"back button clicked.");
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)moreButtonAction:(id)sender {
	NSLog(@"more button clicked.");
	UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:@"更多操作"
													 delegate:self
											cancelButtonTitle:@"取消"
									   destructiveButtonTitle:@"举报"
											otherButtonTitles: nil];
	[sheet showInView:self.view];
}

- (void)commentButtonAction:(id)sender {
	NSLog(@"comment button clicked.");
	[commentButton setHidden:YES];
	[_customBetTextView setHidden:NO];
	[_customBetTextView becomeFirstResponder];
}

@end
