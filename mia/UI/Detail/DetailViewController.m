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

@interface DetailViewController ()

@end

@implementation DetailViewController {
	UIScrollView *scrollView;
	DetailPlayerView *playerView;
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
	scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
	scrollView.delegate = self;
	scrollView.maximumZoomScale = 2.0f;
	scrollView.contentSize = self.view.bounds.size;
	scrollView.alwaysBounceHorizontal = NO;
	scrollView.alwaysBounceVertical = YES;
	scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	scrollView.backgroundColor = [UIColor yellowColor];
	[self.view addSubview:scrollView];

	static const CGFloat kPlayerMarginTop			= 0;
	static const CGFloat kPlayerHeight				= 375;

	playerView = [[DetailPlayerView alloc] initWithFrame:CGRectMake(0, kPlayerMarginTop, scrollView.frame.size.width, kPlayerHeight)];
	[scrollView addSubview:playerView];

}

- (void)initPlayerUI {

}

#pragma mark - button Actions

- (void)backButtonAction:(id)sender {
	NSLog(@"back button clicked.");
}

- (void)moreButtonAction:(id)sender {
	NSLog(@"more button clicked.");
}


@end
