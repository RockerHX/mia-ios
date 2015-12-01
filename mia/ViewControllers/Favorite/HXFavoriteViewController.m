//
//  HXFavoriteViewController.m
//  mia
//
//  Created by miaios on 15/11/27.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXFavoriteViewController.h"
#import "HXFavoriteCell.h"
#import "FavoriteMgr.h"
#import "HXFavoriteHeader.h"
#import "HXPlayerViewController.h"
#import "SongListPlayer.h"
#import "MusicMgr.h"
#import "WebSocketMgr.h"
#import "UserSetting.h"
#import "PathHelper.h"
#import "HXFavoriteEditViewController.h"

@interface HXFavoriteViewController () <HXFavoriteHeaderDelegate, FavoriteMgrDelegate, SongListPlayerDataSource, SongListPlayerDelegate, HXFavoriteEditViewControllerDelegate>
@end

@implementation HXFavoriteViewController {
    FavoriteMgr *_favoriteMgr;
    SongListPlayer *_songListPlayer;
}

#pragma mark - View Controller Life Cycle
- (void)viewWillAppear:(BOOL)animated {
    [self updateFavoriteHeader];
    [_favoriteMgr syncFavoriteList];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initConfig];
    [self viewConfig];
}

- (void)dealloc {
    _songListPlayer.dataSource = nil;
    _songListPlayer.delegate = nil;
}

#pragma mark - Config Methods
- (void)initConfig {
    _favoriteMgr = [FavoriteMgr standard];
    _favoriteMgr.delegate = self;
    
    // 播放器
    _songListPlayer = [[SongListPlayer alloc] initWithModelID:(long)(__bridge void *)self name:[NSString stringWithFormat:@"%@%@", NSStringFromClass([self class]), @"Song List"]];
    _songListPlayer.dataSource = self;
    _songListPlayer.delegate = self;
}

- (void)viewConfig {
    [self updateFavoriteHeader];
}

#pragma mark - Event Response
- (IBAction)playerButtonPressed {
    [self presentViewController:[HXPlayerViewController navigationControllerInstance] animated:YES completion:nil];
}

#pragma mark - Private Methods
- (void)updateFavoriteHeader {
    _header.countLabel.text = @(_favoriteMgr.dataSource.count).stringValue;
}

- (void)playFavoriteMusic {
    if (!_favoriteMgr.dataSource.count) {
        return;
    }
    
    FavoriteItem *itemForPlay = _favoriteMgr.dataSource[_favoriteMgr.playingIndex];
    
    // Wifi环境或者歌曲已经缓存，直接播放
    if ([[WebSocketMgr standard] isWifiNetwork] || [_favoriteMgr isItemCached:itemForPlay]) {
        [self playFavoriteMusicWithoutCheckNetwork:itemForPlay];
        return;
    }
    
    // 用户允许3G环境下播放歌曲
    if ([UserSetting isAllowedToPlayNowWithURL:itemForPlay.music.url]) {
        [self playFavoriteMusicWithoutCheckNetwork:itemForPlay];
        return;
    }
    
    // 寻找下一首已经缓存了的歌曲
    itemForPlay = nil;
    for (unsigned long i = 0; i < _favoriteMgr.dataSource.count; i++) {
        FavoriteItem* item = _favoriteMgr.dataSource[i];
        if ([_favoriteMgr isItemCached:item]) {
            itemForPlay = item;
            _favoriteMgr.playingIndex = i;
            break;
        }
    }
    
    if (nil == itemForPlay) {
        NSLog(@"没有可以播放的离线歌曲");
        return;
    }
    
    [self playFavoriteMusicWithoutCheckNetwork:itemForPlay];
}

- (void)playPreviosFavoriteMusic {
    if (!_favoriteMgr.dataSource.count) {
        return;
    }
    if ((_favoriteMgr.playingIndex - 1) < 0) {
        return;
    }
    
    _favoriteMgr.playingIndex--;
    
    FavoriteItem *itemForPlay = _favoriteMgr.dataSource[_favoriteMgr.playingIndex];
    
    // Wifi环境或者歌曲已经缓存，直接播放
    if ([[WebSocketMgr standard] isWifiNetwork] || [_favoriteMgr isItemCached:itemForPlay]) {
        [self playFavoriteMusicWithoutCheckNetwork:itemForPlay];
        return;
    }
    
    // 用户允许3G环境下播放歌曲
    if ([UserSetting isAllowedToPlayNowWithURL:itemForPlay.music.url]) {
        [self playFavoriteMusicWithoutCheckNetwork:itemForPlay];
        return;
    }
    
    // 寻找上一首已经缓存了的歌曲
    itemForPlay = nil;
    for (long i = _favoriteMgr.dataSource.count - 1; i >= 0; i--) {
        FavoriteItem* item = _favoriteMgr.dataSource[i];
        if ([_favoriteMgr isItemCached:item]) {
            itemForPlay = item;
            _favoriteMgr.playingIndex = i;
            break;
        }
    }
    
    if (nil == itemForPlay) {
        NSLog(@"没有可以播放的离线歌曲");
        return;
    }
    
    [self playFavoriteMusicWithoutCheckNetwork:itemForPlay];
}

- (void)playFavoriteMusicWithoutCheckNetwork:(FavoriteItem *)aFavoriteItem {
    if (!aFavoriteItem) {
        NSLog(@"FavoriteItem is nil, play was ignored.");
        return;
    }
    
    MusicItem *musicItem = [aFavoriteItem.music copy];
    if (!musicItem.url || !musicItem.name || !musicItem.singerName) {
        NSLog(@"Music is nil, stop play it.");
        return;
    }
    
    if (aFavoriteItem.isCached && [_favoriteMgr isItemCached:aFavoriteItem]) {
        musicItem.url = [NSString stringWithFormat:@"file://%@", [PathHelper genMusicFilenameWithUrl:musicItem.url]];
    } else {
        NSLog(@"收藏中播放还未下载的歌曲");
    }
    [[MusicMgr standard] setCurrentPlayer:_songListPlayer];
    [_songListPlayer playWithMusicItem:musicItem];
}

- (void)playMusicWithIndex:(NSInteger)index {
    if (!_favoriteMgr.dataSource.count) {
        return;
    }
    FavoriteItem *aFavoriteItem = _favoriteMgr.dataSource[index];
    [self playFavoriteMusicWithoutCheckNetwork:aFavoriteItem];
}

- (void)pauseMusic {
    [_songListPlayer pause];
    _header.playState = HXFavoriteHeaderStatePause;
}

#pragma mark - Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_favoriteMgr favoriteCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HXFavoriteCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXFavoriteCell class]) forIndexPath:indexPath];
    [cell displayWithItem:(_favoriteMgr.dataSource.count > indexPath.row) ? _favoriteMgr.dataSource[indexPath.row] : nil];
    return cell;
}

#pragma mark - Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self playMusicWithIndex:indexPath.row];
}

#pragma mark - HXFavoriteHeaderDelegate Methods
- (void)favoriteHeader:(HXFavoriteHeader *)header action:(HXFavoriteHeaderAction)action {
    switch (action) {
        case HXFavoriteHeaderActionPlay: {
            if ([_songListPlayer isPlaying]) {
                [self pauseMusic];
            } else {
                [self playFavoriteMusic];
            }
            break;
        }
        case HXFavoriteHeaderActionEdit: {
            HXFavoriteEditViewController *favoriteEditViewController = [HXFavoriteEditViewController instance];
            favoriteEditViewController.delegate = self;
            [self presentViewController:favoriteEditViewController animated:YES completion:nil];
            break;
        }
    }
}

#pragma mark - FavoriteMgrDelegate Methods
- (void)favoriteMgrDidFinishSync {
    [self.tableView reloadData];
}

- (void)favoriteMgrDidFinishDownload {
    [self.tableView reloadData];
}

#pragma mark - SongListPlayerDataSource Methods
- (NSInteger)songListPlayerCurrentItemIndex {
    return _favoriteMgr.playingIndex;
}

- (NSInteger)songListPlayerNextItemIndex {
    NSInteger nextIndex = _favoriteMgr.playingIndex + 1;
    if (nextIndex >= _favoriteMgr.dataSource.count) {
        nextIndex = 0;
    }
    return nextIndex;
}

- (MusicItem *)songListPlayerItemAtIndex:(NSInteger)index {
    FavoriteItem *aFavoriteItem = _favoriteMgr.dataSource[index];
    return [aFavoriteItem.music copy];
}

#pragma mark - SongListPlayerDelegate Methods
- (void)songListPlayerDidPlay {
    _header.playState = HXFavoriteHeaderStatePlay;
}

- (void)songListPlayerDidPause {
    _header.playState = HXFavoriteHeaderStatePause;
}

- (void)songListPlayerDidCompletion {
    _favoriteMgr.playingIndex++;
    [self playFavoriteMusic];
}

- (void)songListPlayerShouldPlayNext {
    _favoriteMgr.playingIndex++;
    [self playFavoriteMusic];
}

- (void)songListPlayerShouldPlayPrevios {
    [self playPreviosFavoriteMusic];
}

#pragma mark - HXFavoriteEditViewControllerDelegate Methods
- (void)favoriteEditViewControllerEdited:(HXFavoriteEditViewController *)favoriteEditViewController {
    [self.tableView reloadData];
}

@end
