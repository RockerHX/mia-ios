//
//  HXFavoriteHeader.h
//  mia
//
//  Created by miaios on 16/2/22.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HXFavoriteHeaderAction) {
    HXFavoriteHeaderActionShuffle,
    HXFavoriteHeaderActionEdit
};


@class HXFavoriteHeader;

@protocol HXFavoriteHeaderDelegate <NSObject>

@required
- (void)favoriteHeader:(HXFavoriteHeader *)header takeAction:(HXFavoriteHeaderAction)action;

@end


@interface HXFavoriteHeader : UIView

@property (nonatomic, weak) IBOutlet id <HXFavoriteHeaderDelegate>delegate;

- (IBAction)shufflePlayViewTaped;
- (IBAction)multipleSelectedViewTaped;

@end
