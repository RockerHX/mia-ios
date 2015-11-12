//
//  HXAppConstants.h
//
//  Created by RockerHX
//  Copyright (c) Andy Shaw. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Third SDK Key
FOUNDATION_EXPORT NSString *const UMengAPPKEY;              // 友盟SDK对应的APPKEY
FOUNDATION_EXPORT NSString *const BugHDGeneralKey;          // BugHD对应的GeneralKey
FOUNDATION_EXPORT NSString *const BaiDuMapKEY;              // 百度地图SDK对应的APPKEY
FOUNDATION_EXPORT NSString *const WeiXinKEY;                // 微信SDK对应的APPKEY

#pragma mark - Notification Name
FOUNDATION_EXPORT NSString *const HXWeiXinPaySuccessNotification;                   // 微信支付成功的通知
FOUNDATION_EXPORT NSString *const HXWeiXinPayFailureNotification;                   // 微信支付失败的通知

FOUNDATION_EXPORT NSString *const HXApplicationDidBecomeActiveNotification;         // 程序从后台被唤起到前台的通知
FOUNDATION_EXPORT NSString *const HXMusicPlayerMgrDidPlayNotification;              // 通知专辑卡片改变播放状态的通知
FOUNDATION_EXPORT NSString *const HXMusicPlayerMgrDidPauseNotification;             // 通知专辑卡片改变暂停状态的通知

#pragma mark - App Constants
FOUNDATION_EXPORT NSString *const AppstoreChannel;          // 苹果官方发布渠道
FOUNDATION_EXPORT NSString *const FirimChannel;             // Fir.im发布渠道
