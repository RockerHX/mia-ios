//
//  LocationMgr.m
//  mia
//
//  Created by linyehui on 2015/10/19.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//
//

#import "LocationMgr.h"
#import "CLLocation+YCLocation.h"

@interface LocationMgr() <CLLocationManagerDelegate>

@end

@implementation LocationMgr {
	CLLocationManager 		*_locationManager;
}

/**
 *  使用单例初始化
 *
 */
+ (id)standard{
    static LocationMgr *aLocationMgr = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        aLocationMgr = [[self alloc] init];
    });
    return aLocationMgr;
}

- (id)init {
	self = [super init];
	if (self) {
	}

	return self;
}

- (void)dealloc {
}

#pragma mark - Public Methods

- (void)initLocationMgr {
	if (nil == _locationManager) {
		_locationManager = [[CLLocationManager alloc] init];
	}

	_locationManager.delegate = self;

	//设置定位的精度
	_locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;

	//设置定位服务更新频率
	_locationManager.distanceFilter = 500;

	if ([[[UIDevice currentDevice] systemVersion] doubleValue]>=8.0) {

		[_locationManager requestWhenInUseAuthorization];	// 前台定位
		//[mylocationManager requestAlwaysAuthorization];	// 前后台同时定位
	}

	[_locationManager startUpdatingLocation];
}

- (void)startUpdatingLocation {
	[_locationManager startUpdatingLocation];
}

#pragma mark -private method

#pragma mark - delegate method

// 获取地理位置变化的起始点和终点,didUpdateToLocation：
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

	CLLocation * location = [[CLLocation alloc]initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
	CLLocation * marsLoction =   [location locationMarsFromEarth];
	NSLog(@"didUpdateToLocation 当前位置的纬度:%.2f--经度%.2f", marsLoction.coordinate.latitude, marsLoction.coordinate.longitude);

	CLGeocoder *geocoder=[[CLGeocoder alloc]init];
	[geocoder reverseGeocodeLocation:marsLoction completionHandler:^(NSArray *placemarks,NSError *error) {
		if (placemarks.count > 0) {
			CLPlacemark *placemark = [placemarks objectAtIndex:0];
			NSLog(@"______%@", placemark.locality);
			NSLog(@"______%@", placemark.subLocality);
			NSLog(@"______%@", placemark.name);

			_currentCoordinate = marsLoction.coordinate;
			_currentAddress = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.subLocality];
		}
	}];

	[manager stopUpdatingLocation];
}

@end















