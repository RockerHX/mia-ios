//
//  HXSettingViewController.m
//  mia
//
//  Created by miaios on 15/11/20.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXSettingViewController.h"

typedef NS_ENUM(NSUInteger, HXSettingSection) {
    HXSettingSectionUser,
    HXSettingSectionAction,
    HXSettingSectionApp,
    HXSettingSectionLogout
};

typedef NS_ENUM(NSUInteger, HXUserSectionRow) {
    HXUserSectionRowAvatar,
    HXUserSectionRowNickName,
    HXUserSectionRowGender,
    HXUserSectionRowPassWord,
    HXUserSectionRowMessageCenter
};

typedef NS_ENUM(NSUInteger, HXActionSectionRow) {
    HXActionSectionRowNetwork,
    HXActionSectionRowCache
};

typedef NS_ENUM(NSUInteger, HXAppSectionRow) {
    HXAppSectionRowFeedBack,
    HXAppSectionRowVersion
};

@interface HXSettingViewController ()
@end

@implementation HXSettingViewController

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

- (NSString *)navigationControllerIdentifier {
    return @"HXSettingNavigationController";
}

- (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNameSetting;
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    ;
}

- (void)viewConfigure {
    ;
}

#pragma mark - Table View Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HXSettingSection section = indexPath.section;
    switch (section) {
        case HXSettingSectionUser: {
            HXUserSectionRow row = indexPath.row;
            switch (row) {
                case HXUserSectionRowAvatar: {
                    ;
                    break;
                }
                case HXUserSectionRowNickName: {
                    ;
                    break;
                }
                case HXUserSectionRowGender: {
                    ;
                    break;
                }
                case HXUserSectionRowPassWord: {
                    ;
                    break;
                }
                case HXUserSectionRowMessageCenter: {
                    ;
                    break;
                }
            }
            break;
        }
        case HXSettingSectionAction: {
            HXActionSectionRow row = indexPath.row;
            switch (row) {
                case HXActionSectionRowNetwork: {
                    ;
                    break;
                }
                case HXActionSectionRowCache: {
                    ;
                    break;
                }
            }
            break;
        }
        case HXSettingSectionApp: {
            HXAppSectionRow row = indexPath.row;
            switch (row) {
                case HXAppSectionRowFeedBack: {
                    ;
                    break;
                }
                case HXAppSectionRowVersion: {
                    ;
                    break;
                }
            }
            break;
        }
        case HXSettingSectionLogout: {
            ;
            break;
        }
    }
}

@end
