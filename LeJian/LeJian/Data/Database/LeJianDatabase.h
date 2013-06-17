/////////////////////////////////////////////////////
/// COPYRIGHT NOTICE
/// Copyright (c) 2012, 上海掌讯信息有限公司（版权声明）
/// All rights reserved.
///
/// @file (GMDatabase.h)
/// @brief (数据库控制对象)
///
/// (该对象封装了工程中所有的对数据库直接操作的方法，是一个单例，所有的数据库操作都需要调用到该对象对应的方法)
///
/// version 1.1(版本声明)
/// @author (作者eg：龚雪寒)
/// @date (2012年8月2日)
///
///
/// 修订说明：最初版本
/////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import "Kal.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface LeJianDatabase : NSObject <KalDataSource, EKEventViewDelegate>

+ (LeJianDatabase *) sharedDatabase;
- (NSString *)filePath;
/// 获取所有的约会卡片信息。
- (NSDictionary *)cardList:(BOOL)isFirst card_id:(SInt32)card_id;

- (void)appendCardInfo:(NSDictionary *)card_info;

- (BOOL)updateCard:(NSDictionary *)card_info;

- (NSDictionary *)loadItemsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;

- (SInt32)maxCardID;

- (BOOL)deleteCard:(NSDictionary *)card_info;

- (void)updateSystemCard:(NSDictionary *)dict;

- (void)appicationDidBecomActive;

- (void)synchronizationSystem:(BOOL)isSy;

@end
