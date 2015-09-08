//
//  NSObject+PropertyAndMethods.h
//
//  Created by linyehui on 14-8-22.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (PropertyAndMethods)

/**
 *  获取对象的所有属性和属性内容
 *
 */
- (NSDictionary *)getAllPropertiesAndVaules;

/**
 *  获取对象的所有属性
 *
 */
- (NSArray *)getAllProperties;

/**
 *  获取对象的所有方法
 */
-(void)getAllMethods;
@end
