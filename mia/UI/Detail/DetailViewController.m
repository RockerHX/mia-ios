//
//  DetailViewController.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "DetailViewController.h"
#import "MIAButton.h"
#import "DetailPlayerView.h"
#import "MBProgressHUD.h"
#import "CommentTableView.h"

@interface DetailViewController () <UIActionSheetDelegate>

@end

@implementation DetailViewController {
	UIScrollView *scrollView;
	DetailPlayerView *playerView;
	CommentTableView *commentTableView;

	ShareItem *currentItem;
}

- (id)initWitShareItem:(ShareItem *)item {
	self = [super init];
	if (self) {
		currentItem = item;
	}

	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self initUI];
}

-(void)dealloc {
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

#pragma mark - delegate

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
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


@end
