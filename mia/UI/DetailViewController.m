//
//  DetailViewController.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "DetailViewController.h"
#import "MIAButton.h"


@interface DetailViewController ()

@end

@implementation DetailViewController {
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
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated;
{
	//[self.navigationController setNavigationBarHidden:YES animated:animated];
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	//[self.navigationController setNavigationBarHidden:NO animated:animated];
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
	[self.view setBackgroundColor:[UIColor redColor]];
}


#pragma mark - button Actions

- (void)backButtonAction:(id)sender {
	NSLog(@"back button clicked.");
}

- (void)moreButtonAction:(id)sender {
	NSLog(@"more button clicked.");
}


@end
