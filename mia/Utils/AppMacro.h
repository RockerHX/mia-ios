//
//  AppMacro.h
//
//  Created by linyehui on 14-8-3.
//
//

#ifndef MiaMusicAppMacro_h
#define MiaMusicAppMacro_h

#pragma 枚举（）


#pragma Test(用于测试)


#pragma Web

#define NSWebFromURL(url)                                    [@"http://miamusic.com/" stringByAppendingString:url];
#define TIMEOUT                                              30
#define TIMEOUT_ERRORCODE                                    -1001
#define OFFLINE_ERRORCODE                                    -1009
#define TIMEOUT_COUNT                                        3
#define STATUS_NORMAL                                        200

#pragma system attribute

#define SCREEN_WIDTH                                         [[UIScreen mainScreen]bounds].size.width
#define SCREEN_HEIGHT                                        [[UIScreen mainScreen]bounds].size.height
#define SYSTEM_VERSION                                       [[UIDevice currentDevice].systemVersion floatValue]
#define TABBAR_HEIGHT                                        52.0f


#pragma colour

#define UIColorFromRGB(r,g,b)                                [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define UIColorFromHex(hexColorString,a)                     [UIColor colorWithHexColorString:hexColorString alpha:a]
#define NSNumberFromInt(number)                              [NSNumber numberWithInt:(number)]
#define COLOUR_GRAY                                          [UIColor colorWithRed:34.0f/255.0 green:36.0f/255.0 blue:44.0f/255.0 alpha:1]
#define FONT_COLOUR_DEFAULT                                  [UIColor colorWithRed:206.0f/255.0 green:211.0f/255.0 blue:226.0f/255.0 alpha:1]
#define DADU_DEFAULT_COLOR                                   [UIColor colorWithRed:246.0f/255.0 green:26.0f/255.0 blue:88.0f/255.0 alpha:1]
#define LIGHT_GRAY                                           [UIColor colorWithRed:205.0f/255.0 green:205.0f/255.0 blue:205.0f/255.0 alpha:1]
#define ColorHex(rgbValue) 									 [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:255.0]

#pragma code

#define NSStringFromInt(intValue)                            [NSString stringWithFormat:@"%d",intValue]
#define UIFontFromSize(size)                                 [UIFont systemFontOfSize:size]
#define UIBoldFontFromSize(size)                             [UIFont boldSystemFontOfSize:size]
#define UIImageWithName(name)                                [UIImage imageNamed:name]

#define StatusBarHeight                                      (([[[UIDevice currentDevice] systemVersion] floatValue]) >= (7.0) ? (20.0f):(0.0f))
#define DOCUMENT_PATH                                        [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

#endif








