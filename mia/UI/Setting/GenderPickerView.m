//
//  GenderPickerView.m
//  mia
//
//  Created by linyehui on 2015/09/09.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "GenderPickerView.h"
#import "Masonry.h"

const static NSInteger kGenderPickerComponentCount = 1;

@interface GenderPickerView () <UIPickerViewDataSource, UIPickerViewDelegate>

@end

@implementation GenderPickerView {
	UIPickerView 	*_genderPicker;
	NSInteger 		_selectedIndex;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self){
		self.userInteractionEnabled = YES;
//		self.backgroundColor = [UIColor redColor];

		[self initUI];
}

	return self;
}

- (void)dealloc {
}

- (void)initUI {
	self.backgroundColor = UIColorFromHex(@"a2a2a2", 0.8);
	[self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blankTouchAction:)]];

	_genderPicker = [[UIPickerView alloc]init];
	_genderPicker.backgroundColor = [UIColor whiteColor];
	_genderPicker.showsSelectionIndicator=YES;
	_genderPicker.delegate=self;
	_genderPicker.dataSource=self;
	[self addSubview:_genderPicker];

	[_genderPicker mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.mas_left);
		make.bottom.equalTo(self.mas_bottom);
		make.right.equalTo(self.mas_right);
	}];

	_selectedIndex = 0;
}

#pragma mark - delegate 

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return kGenderPickerComponentCount;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	if(0 == row) {
		return @"男";
	} else {
		return @"女";
	}
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	_selectedIndex = row;
}

#pragma mark - action

- (void)blankTouchAction:(id)sender {
	MIAGender result = MIAGenderUnknown;
	if (0 == _selectedIndex) {
		result = MIAGenderMale;
	} else {
		result = MIAGenderFemale;
	}

	if (_customDelegate) {
		[_customDelegate genderPickerDidSelected:result];
	}
	[self removeFromSuperview];
}

@end
