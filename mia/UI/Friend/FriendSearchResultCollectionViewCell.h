//
//  FriendSearchResultCollectionViewCell.h
//  mia
//
//  Created by linyehui on 2015-09-20.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FriendItem;

@protocol FriendSearchResultCellDelegate
- (void)friendSearchResultCellClickedPlayButtonAtIndexPath:(NSIndexPath *)indexPath;
@end
	
@interface FriendSearchResultCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) FriendItem *dataItem;
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (weak, nonatomic)id<FriendSearchResultCellDelegate> cellDelegate;

@end