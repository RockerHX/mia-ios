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

#pragma mark - Configure Methods
- (void)loadConfigure {
    _cover.layer.drawsAsynchronously = YES;
    _cardUserAvatar.layer.drawsAsynchronously = YES;
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
    if (_delegate && [_delegate respondsToSelector:@selector(cover:takeAcion:)]) {
        [_delegate cover:self takeAcion:HXDiscoveryCoverActionPlay];
    }
}

- (IBAction)showProfileAction {
    if (_delegate && [_delegate respondsToSelector:@selector(cover:takeAcion:)]) {
        [_delegate cover:self takeAcion:([self isSharer] ? HXDiscoveryCoverActionShowSharer : HXDiscoveryCoverActionShowInfecter)];
    }
}

#pragma mark - Public Methods
- (void)displayWithItem:(ShareItem *)item {
    _shareItem = item;
    
    BOOL isShare = [self isSharer];
    UserItem *userItem = isShare ? item.shareUser : item.spaceUser;
    NSString *userPrompt = [NSString stringWithFormat:@"%@%@", userItem.nick, (isShare ? @"分享" : @"妙推")];
    _cardUserLabel.text = userPrompt;
    [_cardUserAvatar sd_setImageWithURL:[NSURL URLWithString:userItem.userpic] placeholderImage:nil];
    
    MusicItem *musicItem = item.music;
    [_cover sd_setImageWithURL:[NSURL URLWithString:musicItem.purl] placeholderImage:nil];
    _songNameLabel.text = musicItem.name;
    _singerNameLabel.text = musicItem.singerName;
}

#pragma mark - Private Methods
- (BOOL)isSharer {
    return [_shareItem.shareUser.uid isEqualToString:_shareItem.spaceUser.uid];
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
