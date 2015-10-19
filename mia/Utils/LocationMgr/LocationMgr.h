//
//  LocationMgr.h
//  mia
//
//  Created by linyehui on 2015/10/19.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface LocationMgr : NSObject

/**
 *  使用单例初始化
 *
 */
+ (id)standard;

//@property (assign, nonatomic) long currentModelID;
@property (assign, nonatomic) CLLocationCoordinate2D 	currentCoordinate;
@property (copy, nonatomic) NSString					*currentAddress;

- (void)initLocationMgr;
- (void)startUpdatingLocation;

@end
