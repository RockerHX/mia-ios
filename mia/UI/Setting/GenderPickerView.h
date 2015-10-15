//
//  GenderPickerView.h
//  mia
//
//  Created by linyehui on 2015/09/09.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSUInteger, MIAGender) {
	MIAGenderUnknown = 0,
	MIAGenderMale,
	MIAGenderFemale,
};

@protocol GenderPickerViewDelegate

- (void)genderPickerDidSelected:(MIAGender)gender;

@end

@interface GenderPickerView : UIView

@property (weak, nonatomic)id<GenderPickerViewDelegate> customDelegate;

@end
