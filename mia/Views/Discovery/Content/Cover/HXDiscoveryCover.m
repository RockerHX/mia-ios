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

@implementation HXDiscoveryCover

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
    ;
}

#pragma mark - Public Methods
- (void)displayWithItem:(ShareItem *)item {
    BOOL isShare = [item.shareUser.uid isEqualToString:item.spaceUser.uid];
    UserItem *userItem = isShare ? item.shareUser : item.spaceUser;
    NSString *userPrompt = [NSString stringWithFormat:@"%@%@", userItem.nick, (isShare ? @"分享" : @"秒推")];
    _cardUserLabel.text = userPrompt;
    [self showImageAnimationOnImageView:_cardUserAvatar url:userItem.userpic];
    
    MusicItem *musicItem = item.music;
    [self showImageAnimationOnImageView:_cover url:musicItem.purl];
    _songNameLabel.text = musicItem.name;
    _singerNameLabel.text = musicItem.singerName;
}

#pragma mark - Private Methods
- (void)showImageAnimationOnImageView:(UIImageView *)imageView url:(NSString *)url{
    [UIView transitionWithView:imageView duration:0.3f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil];
    } completion:nil];
}

@end
