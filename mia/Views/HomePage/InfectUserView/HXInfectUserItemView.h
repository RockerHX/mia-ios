//
//  HXInfectUserItemView.h
//  mia
//
//  Created by miaios on 15/10/20.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXInfectUserItemView : UIView

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthContraint;
@property (weak, nonatomic) IBOutlet        UIImageView *header;

+ (instancetype)instance;

- (void)reduce;
- (void)displayWithURL:(NSURL *)url;
- (void)displayWithImageName:(NSString *)imageName;

@end
