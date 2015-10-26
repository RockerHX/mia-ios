//
//  HXMusicDetailView.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareItem;
@class HXInfectUserView;
@class TTTAttributedLabel;

@class HXMusicDetailView;

@protocol HXMusicDetailViewDelegate <NSObject>

@optional
- (void)detailViewUserWouldStar:(HXMusicDetailView *)detailView;

@end

@interface HXMusicDetailView : UIView

@property (nonatomic, weak) IBOutlet                 id  <HXMusicDetailViewDelegate>delegate;




- (void)refreshWithItem:(ShareItem *)item;
- (void)updateStarState:(BOOL)star;

@end
