//
//  HXDiscoveryCover.m
//  mia
//
//  Created by miaios on 16/2/22.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXDiscoveryCover.h"
#import "HXXib.h"
#import "ShareItem.h"
#import "UIImageView+WebCache.h"
#import "UIView+Frame.h"
#import "MusicMgr.h"

@implementation HXDiscoveryCover {
    __weak ShareItem *_shareItem;
}

HXXibImplementation

#pragma mark - Load Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self loadConfigure];
    [self viewConfigure];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MusicMgrNotificationPlayerEvent object:nil];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    _cover.layer.drawsAsynchronously = YES;
    _cardUserAvatar.layer.drawsAsynchronously = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationPlayerEvent:) name:MusicMgrNotificationPlayerEvent object:nil];
}

- (void)viewConfigure {
    _cardUserView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    _cardUserView.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    _cardUserView.layer.shadowRadius = 3.0f;
    _cardUserView.layer.shadowOpacity = 1.0f;
    
    _songNameLabel.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    _songNameLabel.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    _songNameLabel.layer.shadowRadius = 3.0f;
    _songNameLabel.layer.shadowOpacity = 1.0f;
    
    _singerNameLabel.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    _singerNameLabel.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    _singerNameLabel.layer.shadowRadius = 3.0f;
    _singerNameLabel.layer.shadowOpacity = 1.0f;
}

#pragma mark - Event Response
- (IBAction)playAction {
    MusicMgr *musicMgr = [MusicMgr standard];
    if ([musicMgr.currentItem.music.murl isEqualToString:_shareItem.music.murl]) {
        if (musicMgr.isPlaying) {
            _playButton.selected = YES;
            [musicMgr pause];
        } else {
            _playButton.selected = NO;
            [[MusicMgr standard] playCurrent];
        }
    } else {
        _playButton.selected = NO;
        if (_delegate && [_delegate respondsToSelector:@selector(cover:takeAcion:)]) {
            [_delegate cover:self takeAcion:HXDiscoveryCoverActionPlay];
        }
    }
}

- (IBAction)showProfileAction {
    if (_delegate && [_delegate respondsToSelector:@selector(cover:takeAcion:)]) {
        [_delegate cover:self takeAcion:([self isSharer] ? HXDiscoveryCoverActionShowSharer : HXDiscoveryCoverActionShowInfecter)];
    }
}

- (IBAction)showDetailAction {
    if (_delegate && [_delegate respondsToSelector:@selector(cover:takeAcion:)]) {
        [_delegate cover:self takeAcion:HXDiscoveryCoverActionShowDetail];
    }
}

#pragma mark - Notification Methods
- (void)notificationPlayerEvent:(NSNotification *)notification {
    NSString *sID = notification.userInfo[MusicMgrNotificationKey_sID];
    MiaPlayerEvent event = [notification.userInfo[MusicMgrNotificationKey_PlayerEvent] unsignedIntegerValue];
    
    if ([_shareItem.sID isEqualToString:sID]) {
        switch (event) {
            case MiaPlayerEventDidPlay:
                _playButton.selected = YES;
                break;
            case MiaPlayerEventDidPause:
            case MiaPlayerEventDidCompletion:
                _playButton.selected = NO;
                break;
            default:
                NSLog(@"It's a bug, sID: %@, PlayerEvent: %lu", sID, (unsigned long)event);
                break;
        }
    }
}

#pragma mark - Public Methods
- (void)displayWithItem:(ShareItem *)item {
    _shareItem = item;
    [self updatePlayState];
    
    BOOL isShare = [self isSharer];
    UserItem *userItem = isShare ? item.shareUser : item.spaceUser;
    NSString *userPrompt = [NSString stringWithFormat:@"%@%@", userItem.nick, (isShare ? @"分享" : @"妙推")];
    _cardUserLabel.text = userPrompt;
    [_cardUserAvatar sd_setImageWithURL:[NSURL URLWithString:userItem.userpic] placeholderImage:nil];
    
    MusicItem *musicItem = item.music;
    [_cover sd_setImageWithURL:[NSURL URLWithString:musicItem.purl] placeholderImage:[UIImage imageNamed:@"C-AvatarDefaultIcon"]];
    _songNameLabel.text = musicItem.name;
    _singerNameLabel.text = musicItem.singerName;
}

#pragma mark - Private Methods
- (BOOL)isSharer {
    return [_shareItem.shareUser.uid isEqualToString:_shareItem.spaceUser.uid];
}

- (void)updatePlayState {
    MusicMgr *musicMgr = [MusicMgr standard];
    if ([musicMgr isPlayingWithUrl:_shareItem.music.murl]) {
        _playButton.selected = YES;
    } else {
        _playButton.selected = NO;
    }
}

//#pragma mark - Public Methods
//- (void)displayWithItem:(ShareItem *)item {
//    __weak __typeof__(self)weakSelf = self;
//    
//    BOOL isShare = [item.shareUser.uid isEqualToString:item.spaceUser.uid];
//    UserItem *userItem = isShare ? item.shareUser : item.spaceUser;
//    NSString *userPrompt = [NSString stringWithFormat:@"%@%@", userItem.nick, (isShare ? @"分享" : @"秒推")];
//    _cardUserLabel.text = userPrompt;
//    [_cardUserAvatar sd_setImageWithURL:[NSURL URLWithString:userItem.userpic] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        __strong __typeof__(self)strongSelf = weakSelf;
//        [self showImageAnimationOnImageView:strongSelf.cardUserAvatar image:image];
//    }];
//    
//    MusicItem *musicItem = item.music;
//    [_cover sd_setImageWithURL:[NSURL URLWithString:musicItem.purl] placeholderImage:nil options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        __strong __typeof__(self)strongSelf = weakSelf;
//        [self showImageAnimationOnImageView:strongSelf.cover image:image];
//    }];
//    
//    _songNameLabel.text = musicItem.name;
//    _singerNameLabel.text = musicItem.singerName;
//}
//
//#pragma mark - Private Methods
//- (void)showImageAnimationOnImageView:(UIImageView *)imageView image:(UIImage *)image {
//    [UIView transitionWithView:imageView
//                      duration:0.3f
//                       options:UIViewAnimationOptionTransitionCrossDissolve
//                    animations:^{
//                        imageView.image = image;
//                    } completion:nil];
//}

@end
