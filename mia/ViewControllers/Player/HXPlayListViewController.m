//
//  HXPlayListViewController.m
//  mia
//
//  Created by miaios on 15/12/1.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXPlayListViewController.h"
#import "HXPlayListCell.h"
#import "SongListPlayer.h"
#import "MusicMgr.h"

@interface HXPlayListViewController ()
@end

@implementation HXPlayListViewController {
    SongListPlayer *_soglistPlayer;
}

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initConfig];
    [self viewConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
    _soglistPlayer = [MusicMgr standard].currentPlayer;
}

- (void)viewConfig {
}

#pragma mark - Event Response
- (IBAction)backButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _soglistPlayer.musicItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HXPlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXPlayListCell class]) forIndexPath:indexPath];
    return cell;
}

#pragma mark - Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
