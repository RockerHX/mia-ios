//
//  HXHomePageWaveView.h
//  mia
//
//  Created by miaios on 15/10/24.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXWaveView.h"

@interface HXHomePageWaveView : UIView

@property (strong, nonatomic) HXWaveView *waveView;

- (void)waveMoveDownAnimation:(void(^)(void))completion;
- (void)waveMoveUpAnimation:(void(^)(void))completion;

- (void)reset;

@end
