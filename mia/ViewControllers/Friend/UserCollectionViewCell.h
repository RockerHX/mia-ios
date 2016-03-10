//
//  UserCollectionViewCell.h
//  mia
//
//  Created by linyehui on 2015-09-20.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserItem;
@class UserCollectionViewCell;

typedef void(^UserCollectionViewCellCompletedBlock)(BOOL isSuccessed);

@protocol UserCollectionViewCellDelegate <NSObject>

@optional
- (void)userCollectionViewCellFollowUID:(NSString *)uID
							   isFollow:(BOOL)isFollow
								   completedBlock:(UserCollectionViewCellCompletedBlock)completedBlock;
@end

@interface UserCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UserItem *dataItem;
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (weak, nonatomic) id<UserCollectionViewCellDelegate> delegate;

@end