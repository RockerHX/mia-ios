//
//  XiamiHelper.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//
//

#import "XiamiHelper.h"
#import "SuggestionItem.h"
#import "SearchResultItem.h"


static NSString * const kSearchSuggestionParten 	= @"www.xiami.com/song/(\\d+).*?title=\"(.*?)\".*?span>(.*?)</strong>";
static NSString * const kSearchSuggestionURLFormat 	= @"http://www.xiami.com/ajax/search-index?key=%@";

static NSString * const kSearchResultParten 		= @"<td class=\"song_name\">[\\s\\S]*?<a target=\"_blank\" href=\"http://www.xiami.com/song/(\\d+)\".*?>(.*?)</a>[\\s\\S]*?<td class=\"song_artist\"><a.*?>(.*?)</a>[\\s\\S]*?<td class=\"song_album\"><a.*?>(.*?)</a>";
static NSString * const kSearchResultURLFormat 		= @"http://www.xiami.com/search/song/page/%lu?key=%@";

static NSString * const kSearchSongInfoURLFormat 	= @"http://www.xiami.com/song/playlist/id/%@/type/0/cat/json";

const static NSTimeInterval kSearchSyncTimeout		= 10;

@interface XiamiHelper()

@end

@implementation XiamiHelper{
}

/**
 *  请求导航栏场景
 *
 *  @param successBlock 请求成功的回调
 *  @param failedBlock  请求失败的回调
 */
+ (void)requestSearchSuggestionWithKey:(NSString *)key successBlock:(SuccessBlock)successBlock failedBlock:(FailedBlock)failedBlock {
	dispatch_queue_t queue = dispatch_queue_create("RequestSearchSuggestion", NULL);
	dispatch_async(queue, ^() {
		NSString *encodeKey = [key stringByAddingPercentEscapesUsingEncoding:
													  NSUTF8StringEncoding];
		NSString *requestUrl = [NSString stringWithFormat:kSearchSuggestionURLFormat, encodeKey];
		[AFNHttpClient requestHTMLWithURL:requestUrl
							  requestType:AFNHttpRequestGet
							   parameters:nil
								  timeOut:TIMEOUT
							 successBlock:^(id task, id responseObject) {
			NSString* responseText = [NSString stringWithUTF8String:[responseObject bytes]];

			NSError* error = NULL;
			NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:kSearchSuggestionParten options:0 error:&error];
			NSArray* match = [reg matchesInString:responseText options:NSMatchingReportCompletion range:NSMakeRange(0, [responseText length])];

			NSMutableArray *suggestionArray = [[NSMutableArray alloc] initWithCapacity:4];
			if (match.count != 0) {
				for (NSTextCheckingResult *matchItem in match) {
					//NSRange range = [matc range];
					//NSLog(@"%@", [responseText substringWithRange:range]);
					NSString* group1 = [responseText substringWithRange:[matchItem rangeAtIndex:1]];
					NSString* group2 = [responseText substringWithRange:[matchItem rangeAtIndex:2]];
					NSString* group3 = [responseText substringWithRange:[matchItem rangeAtIndex:3]];

					SuggestionItem *item = [[SuggestionItem alloc] init];
					item.songID = [self removeBoldTag:group1];
					item.title = [self removeBoldTag:group2];
					item.artist = [self removeBoldTag:group3];
					[suggestionArray addObject:item];
				}
			}

			if(successBlock){
				successBlock(suggestionArray);
			}
		} failBlock:^(id task, NSError *error) {
			if(failedBlock){
				failedBlock(error);
			}
		}];
	});
}

+ (void)requestSearchResultWithKey:(NSString *)key page:(NSUInteger)page successBlock:(SuccessBlock)successBlock failedBlock:(FailedBlock)failedBlock {
	dispatch_queue_t queue = dispatch_queue_create("RequestSearchResult", NULL);
	dispatch_async(queue, ^() {
		NSString *encodeKey = [key stringByAddingPercentEscapesUsingEncoding:
							   NSUTF8StringEncoding];
		NSString *requestUrl = [NSString stringWithFormat:kSearchResultURLFormat, page, encodeKey];
		[AFNHttpClient requestHTMLWithURL:requestUrl requestType:AFNHttpRequestGet parameters:nil timeOut:TIMEOUT successBlock:^(id task, id responseObject) {
			NSString* responseText = [NSString stringWithUTF8String:[responseObject bytes]];

			NSError* error = NULL;
			NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:kSearchResultParten options:0 error:&error];
			NSArray* match = [reg matchesInString:responseText options:NSMatchingReportCompletion range:NSMakeRange(0, [responseText length])];

			NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:4];
			if (match.count != 0) {
				for (NSTextCheckingResult *matchItem in match) {
					//NSRange range = [matc range];
					//NSLog(@"%@", [responseText substringWithRange:range]);
					NSString* group1 = [responseText substringWithRange:[matchItem rangeAtIndex:1]];
					NSString* group2 = [responseText substringWithRange:[matchItem rangeAtIndex:2]];
					NSString* group3 = [responseText substringWithRange:[matchItem rangeAtIndex:3]];
					NSString* group4 = [responseText substringWithRange:[matchItem rangeAtIndex:4]];

					SearchResultItem *item = [[SearchResultItem alloc] init];
					item.songID = [self removeBoldTag:group1];
					item.title = [self removeBoldTag:group2];
					item.artist = [self removeBoldTag:group3];
					item.albumName = [self removeBoldTag:group4];

					NSString *requestInfoUrl = [NSString stringWithFormat:kSearchSongInfoURLFormat, item.songID];
					NSDictionary *songInfo = [AFNHttpClient requestWaitUntilFinishedWithURL:requestInfoUrl
																				requestType:AFNHttpRequestGet
																				 parameters:nil
																					timeOut:kSearchSyncTimeout];
					if (nil != songInfo) {
						item.songUrl = [self decodeXiamiUrl:songInfo[@"data"][@"trackList"][0][@"location"]];
						item.albumPic = songInfo[@"data"][@"trackList"][0][@"pic"];
						[resultArray addObject:item];
					}

				}
			}

			if(successBlock){
				successBlock(resultArray);
			}
		} failBlock:^(id task, NSError *error) {
			if(failedBlock){
				failedBlock(error);
			}
		}];
	});
}

+ (NSString *)removeBoldTag:(NSString *)html {
	if (nil == html || html.length == 0) {
		return html;
	}

	NSString *parten = @"</?b.*?>";
	NSError* error = NULL;
	NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:parten options:0 error:&error];

	NSString *result = [reg stringByReplacingMatchesInString:html options:0 range:NSMakeRange(0, html.length) withTemplate:@""];
	return result;
}

+ (NSString *)decodeXiamiUrl:(NSString *)encodedUrl {
	if (nil == encodedUrl || encodedUrl.length == 0) {
		return nil;
	}

//	encodedUrl = @"8h2fmF16225%k%8bcd45EtFii33532E3e5af3f4E-t%l.22654_FyEb%e33%np2ec44568la%%a52e65u%F.o%%%4%.u355E%45El3mxm22265mtDEd9547-lA5i%FFF_Ephef88E-6%%.a21712%3_8d67a1%5";

	int sectionCount = [[encodedUrl substringToIndex:1] intValue];
	NSString *code = [encodedUrl substringFromIndex:1];
	int length = floor(code.length / sectionCount) + 1;
	int remainder = code.length % sectionCount;
	NSMutableArray *sections = [[NSMutableArray alloc] init];
	NSMutableString *url_with_escape = [[NSMutableString alloc] init];

	// split to a few sections
	for (int i = 0; i < sectionCount; i++) {
		if (i < remainder) {
			[sections addObject:[code substringWithRange:NSMakeRange(length * i, length)]];
		} else {
			[sections addObject:[code substringWithRange:NSMakeRange((length - 1) * i + remainder, length - 1)]];
		}
	}

	// rebuild url
	for (int j = 0; j < [sections[0] length]; j++) {
		for (int k = 0; k < [sections count]; k++) {
			NSString *curSession = sections[k];
			if (j < curSession.length) {
				[url_with_escape appendFormat:@"%C", [curSession characterAtIndex:j]];
			}
		}
	}

	NSString * url_without_escape = [[url_with_escape
					   stringByReplacingOccurrencesOfString:@"+" withString:@" "]
					  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	NSString *result_url = [url_without_escape stringByReplacingOccurrencesOfString:@"^" withString:@"0"];

	return result_url;
}

@end

