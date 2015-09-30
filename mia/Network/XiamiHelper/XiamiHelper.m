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
+ (void)requestSearchSuggestion:(SuccessBlock)successBlock failedBlock:(FailedBlock)failedBlock{
	dispatch_queue_t queue = dispatch_queue_create("RequestSearchSuggestion", NULL);
	dispatch_async(queue, ^(){
		NSString *requestUrl = @"http://www.xiami.com/ajax/search-index?key=w";
		[AFNHttpClient requestHTMLWithURL:requestUrl requestType:AFNHttpRequestGet parameters:nil timeOut:TIMEOUT successBlock:^(id task, id responseObject) {
			NSString* responseText = [NSString stringWithUTF8String:[responseObject bytes]];
			NSString *parten = @"www.xiami.com/song/(\\d+).*?title=\"(.*?)\".*?span>(.*?)</strong>";

			NSError* error = NULL;
			NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:parten options:0 error:&error];
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

+ (void)requestSearchResult:(SuccessBlock)successBlock failedBlock:(FailedBlock)failedBlock{
	dispatch_queue_t queue = dispatch_queue_create("RequestSearchResult", NULL);
	dispatch_async(queue, ^(){
		NSString *requestUrl = @"http://www.xiami.com/search/song/page/1?key=wangfei";
		[AFNHttpClient requestHTMLWithURL:requestUrl requestType:AFNHttpRequestGet parameters:nil timeOut:TIMEOUT successBlock:^(id task, id responseObject) {
			NSString* responseText = [NSString stringWithUTF8String:[responseObject bytes]];
			NSString *parten = @"<td class=\"song_name\">[\\s\\S]*?<a target=\"_blank\" href=\"http://www.xiami.com/song/(\\d+)\".*?>(.*?)</a>[\\s\\S]*?<td class=\"song_artist\"><a.*?>(.*?)</a>[\\s\\S]*?<td class=\"song_album\"><a.*?>(.*?)</a>";

			NSError* error = NULL;
			NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:parten options:0 error:&error];
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
					item.songID = group1;
					item.title = group2;
					item.artist = group3;
					item.albumName = group4;

					// TODO
					[self requestSongInfoWithResultItem:item successBlock:nil failedBlock:nil];
					[resultArray addObject:item];
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

+ (void)requestSongInfoWithResultItem:(SearchResultItem *)item successBlock:(SuccessBlock)successBlock failedBlock:(FailedBlock)failedBlock{
	dispatch_queue_t queue = dispatch_queue_create("RequestSongInfo", NULL);
	dispatch_async(queue, ^(){
		NSString *requestUrl = [NSString stringWithFormat:@"http://www.xiami.com/song/playlist/id/%@/type/0/cat/json", item.songID];
		[AFNHttpClient requestWithURL:requestUrl requestType:AFNHttpRequestGet parameters:nil timeOut:TIMEOUT successBlock:^(id task, NSDictionary *jsonServerConfig) {
			NSLog(@"%@", jsonServerConfig);
			item.songUrl = jsonServerConfig[@"data"][@"trackList"][0][@"location"];
			item.albumPic = jsonServerConfig[@"data"][@"trackList"][0][@"pic"];

			if(successBlock){
				successBlock(jsonServerConfig);
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

+ (NSString *)decodeXiamiUrl:(NSString *)encodeUrl {
	NSString* mess = @"8h2fmF16225%k%8bcd45EtFii33532E3e5af3f4E-t%l.22654_FyEb%e33%np2ec44568la%%a52e65u%F.o%%%4%.u355E%45El3mxm22265mtDEd9547-lA5i%FFF_Ephef88E-6%%.a21712%3_8d67a1%5";

	int rows = [[mess substringToIndex:1] intValue];
	NSString *url = [mess substringFromIndex:1];
	int len_url = url.length;
	int cols = len_url / rows;
	int re_col = len_url % rows;
	NSMutableArray *l = [[NSMutableArray alloc] init];
	for (int row = 0; row < rows; row++) {
		int ln;
		if (row < re_col) {
			ln = cols;
		} else {
			ln = cols + 1;
		}

		[l addObject:[url substringToIndex:ln]];
		url = [url substringFromIndex:ln];
	}

	NSMutableString *durl = [NSMutableString stringWithString:@""];
	for (int i = 0; i < len_url; i++) {
		NSString *item = [l[i%rows] substringWithRange:NSMakeRange(i/rows, 1)];
		[durl appendString:item];
	}



/*
	rows = int(mess[0])
	url = mess[1:]
	len_url = len(url)
	cols = len_url / rows
	re_col = len_url % rows

	l = []
	for row in xrange(rows):
		ln = cols + 1 if row < re_col else cols
			l.append(url[:ln])
			url = url[ln:]

			durl = ''
			for i in xrange(len_url):
    durl += l[i%rows][i/rows]
*/

	return nil;
}
@end

