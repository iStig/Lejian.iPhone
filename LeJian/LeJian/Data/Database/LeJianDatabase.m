//
//  LeJianDatabase.m
//  LeJian
//
//  Created by gongxuehan on 8/13/12.
//  Copyright (c) 2012 smilingmobile. All rights reserved.
//

#import "LeJianDatabase.h"
#import "PublicMethod.h"
#import "ClockManager.h"
#import <sqlite3.h>

#define MISC_DIRECTORY_NAME @"Misc"
#define DOC_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define LIB_PATH [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]
NSString *const kDatabasePath = @"LeJian.sqlite";

#define DEFAULT_CREAT_TEXT @"乐见 新建事件"
#define DEFAULT_LEJIAN_TEXT @"编辑添加约会描述"

static BOOL IsDateBetweenInclusive(NSString *date, NSString *begin, NSString *end)
{
    return (([date doubleValue] >= [begin doubleValue]) && ([date doubleValue] <= [end doubleValue]));
}

@interface LeJianDatabase()
{
    sqlite3 *_database;
    NSMutableDictionary *_mdictMonthLog;
    EKEventStore *_eventStore;
    EKCalendar   *_calendar;
}

@property (nonatomic, retain) NSMutableDictionary *mdictMonthLog;
- (void)loadDataFrom:(NSDate *)fromDate to:(NSDate *)toDate;

- (void)modifyEvent:(NSDictionary *)card_info;
- (void)removeEvent:(NSDictionary *)card_info;
-(NSString *)createEvent:(NSDictionary *)card_info;

@end

@implementation LeJianDatabase
@synthesize mdictMonthLog = _mdictMonthLog;

static LeJianDatabase *sharedDatabase = nil;

+ (LeJianDatabase *) sharedDatabase
{
    @synchronized(self) {
        if (sharedDatabase == nil) {
            [[self alloc] init];
        }
    }
    
    return sharedDatabase;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if(sharedDatabase == nil) { 
            sharedDatabase = [super allocWithZone:zone];
            return sharedDatabase;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (oneway void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

- (NSString *)filePath
{
    NSString *libInfoPath = LIB_PATH;
    return [libInfoPath stringByAppendingFormat:@"/%@", MISC_DIRECTORY_NAME];
}

- (NSString *)writePath
{
    NSString *libInfoPath = LIB_PATH;
    return [libInfoPath stringByAppendingFormat:@"/%@/%@", MISC_DIRECTORY_NAME, @"GM.sqlite"];
}

- (NSString *)dataFilePath
{
    return [[NSBundle mainBundle] pathForResource:kDatabasePath ofType:nil];
}

- (void)dealloc
{
    [super dealloc];
    [_mdictMonthLog release];
    [_eventStore release];
    [_calendar release];
    if (_database == NULL) return;
    
    if (sqlite3_close(_database) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(_database));
    }
    _database = NULL;

}

- (id)init
{
    self = [super init];
    if (self) 
    {
        _eventStore = [[EKEventStore alloc] init];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
        {
            [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            // handle access here
                
                NSLog(@"111");
            }];
        }
        _calendar = [_eventStore defaultCalendarForNewEvents];
        
        _mdictMonthLog = [[NSMutableDictionary alloc] init];
        NSString *docPath = DOC_PATH;
        NSString *libPath = LIB_PATH;
        NSString *docConfigPath = [docPath stringByAppendingFormat:@"/%@", kDatabasePath];
        NSString *libMiscPath = [libPath stringByAppendingFormat:@"/%@", MISC_DIRECTORY_NAME];
        NSString *libConfigPath = [libMiscPath stringByAppendingFormat:@"/%@", kDatabasePath];
        
        BOOL result = YES;
        if (![[NSFileManager defaultManager] fileExistsAtPath:libMiscPath]) {
            NSError *error = nil;
            result = [[NSFileManager defaultManager] createDirectoryAtPath:libMiscPath 
                                               withIntermediateDirectories:NO 
                                                                attributes:nil error:&error];
            if  (NO == result) {
                if (error) {
                    NSLog(@">>><<< Create misc directory in library failed for: %d: %@", 
                          [error code], [error localizedDescription]);
                }
            } else {
                if ([[NSFileManager defaultManager] fileExistsAtPath:docConfigPath]) {
                    NSError *error = nil;
                    result = [[NSFileManager defaultManager] copyItemAtPath:docConfigPath 
                                                                     toPath:libConfigPath 
                                                                      error:&error];
                    if  (NO == result) {
                        if (error) {
                            NSLog(@">>><<< Move configurtion plist to misc directory in library failed for: %d: %@", 
                                  [error code], [error localizedDescription]);
                        }
                    }
                    error = nil;
                    if (NO == [[NSFileManager defaultManager] removeItemAtPath:docConfigPath error:&error]) {
                        NSLog(@">>><<< Remove old charge log database failed for: %d: %@", 
                              [error code], [error localizedDescription]);
                    }
                }
            }
        }
        
        NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
        
        BOOL success;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        if ([fileManager fileExistsAtPath:[self writePath]] == NO) {
            // The writable database does not exist, so copy the default to the appropriate location.
            NSString *defaultDBPath = [self dataFilePath];
            success = [fileManager copyItemAtPath:defaultDBPath toPath:[self writePath] error:&error];
            if (!success) {
                NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
            }
        }
        if (sqlite3_open([[self writePath] UTF8String], &_database) != SQLITE_OK) {
            // Even though the open failed, call close to properly clean up resources.
            sqlite3_close(_database);
            _database = NULL;
            NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(_database));
            // Additional error handling, as appropriate...
        }
        NSLog(@"-----sqlite3_open([writableDBPath UTF8String], &_database) = %d", sqlite3_open([[self writePath] UTF8String], &_database));
    }
    return self;
}

#pragma mark - Database process Method -
- (void)deleteNotExistForSystem:(NSArray *)cards
{
    NSInteger intResult;
    sqlite3_stmt *stmt;
    for (NSDictionary *card in cards)
    {
        NSString *strSql = [NSString stringWithFormat:@"delete from card_list where card_identifier='%@'", [card objectForKey:kCardIdentifierKey]];
        intResult = sqlite3_exec(_database, [strSql UTF8String],nil, &stmt, nil);
        if (SQLITE_OK == intResult) 
        {
        }
    }
}

- (void)updateSystemCard:(NSDictionary *)dict
{
    NSString *strSql = [NSString stringWithFormat:@"select * from card_list where card_identifier='%@'", [dict objectForKey:kCardIdentifierKey]];
    const char *sql = [strSql UTF8String];
    sqlite3_stmt *stmt;

    ///get title text

    BOOL isExists = NO;
    if(sqlite3_prepare_v2(_database, sql, -1, &stmt, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW) 
        {
            isExists = YES;
        }
    }
    sqlite3_reset(stmt);
    sqlite3_finalize(stmt);
    
    if (isExists)
    {
        SInt32 intResult = 0;
        NSString *strSQL = [[NSMutableString alloc] initWithFormat:@"update card_list set date='%@' , contact_text='%@' , remind_time='%@' where card_identifier='%@'", [dict objectForKey:kDateKey], [dict objectForKey:kContactTextKey], [dict objectForKey:kRemindTimeKey], [dict objectForKey:kCardIdentifierKey]];
        
        intResult = sqlite3_exec(_database, [strSQL UTF8String],nil, &stmt, nil);
        if (SQLITE_OK == intResult) 
        {
            [[ClockManager shardeScheduleData] modifyLocalNotification:dict];
        }
        [strSQL release];
    }
    else
    {
        [dict setValue:[NSString stringWithFormat:@"%d", [self maxCardID] + 1] forKey:kCardIDKey];
        NSString *strSQL = @"insert into card_list (contact_name, contact_text, contact_phone, remind_time, map_x, map_y, date, ABRecordID, map_path, map_name, card_type, card_identifier)values(?2,?3,?4,?5,?6,?7,?8,?9, ?10, ?11, ?12, ?13)";
        
        if(sqlite3_prepare_v2(_database, [strSQL UTF8String], -1, &stmt, NULL) == SQLITE_OK) 
        {
            sqlite3_bind_text(stmt, 2, [[dict objectForKey:kContactNameKey] UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_text(stmt, 3, [[dict objectForKey:kContactTextKey] UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_text(stmt, 4, [[dict objectForKey:kContactPhoneKey] UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_text(stmt, 5, [[dict objectForKey:kRemindTimeKey] UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_text(stmt, 6, [[dict objectForKey:kMapXKey] UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_text(stmt, 7, [[dict objectForKey:kMapYKey] UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_text(stmt, 8, [[dict objectForKey:kDateKey] UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_text(stmt, 9, [[dict objectForKey:kABRecordIDKey] UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_text(stmt, 10, [[dict objectForKey:kImagePathKey] UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_text(stmt, 11, [[dict objectForKey:kMapNameKey] UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_text(stmt, 12, [[dict objectForKey:kCardTypeKey] UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_text(stmt, 13, [[dict objectForKey:kCardIdentifierKey] UTF8String], -1, SQLITE_STATIC);
            if(sqlite3_step(stmt) == SQLITE_ROW)
            {
                [[ClockManager shardeScheduleData] addNewLocalNotification:dict];
            }
        }
        sqlite3_reset(stmt);
        sqlite3_finalize(stmt);
    }
}

- (void)appendCardInfo:(NSDictionary *)card_info
{
    
    ///add to system 
    NSString *identifier =  [self createEvent:card_info];
    sqlite3_stmt *stmt;
    NSString *strSQL = @"insert into card_list (contact_name, contact_text, contact_phone, remind_time, map_x, map_y, date, ABRecordID, map_path, map_name, card_type, card_identifier)values(?2,?3,?4,?5,?6,?7,?8,?9, ?10, ?11, ?12, ?13)";
    
    if(sqlite3_prepare_v2(_database, [strSQL UTF8String], -1, &stmt, NULL) == SQLITE_OK) 
    {
        sqlite3_bind_text(stmt, 2, [[card_info objectForKey:kContactNameKey] UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_text(stmt, 3, [[card_info objectForKey:kContactTextKey] UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_text(stmt, 4, [[card_info objectForKey:kContactPhoneKey] UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_text(stmt, 5, [[card_info objectForKey:kRemindTimeKey] UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_text(stmt, 6, [[card_info objectForKey:kMapXKey] UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_text(stmt, 7, [[card_info objectForKey:kMapYKey] UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_text(stmt, 8, [[card_info objectForKey:kDateKey] UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_text(stmt, 9, [[card_info objectForKey:kABRecordIDKey] UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_text(stmt, 10, [[card_info objectForKey:kImagePathKey] UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_text(stmt, 11, [[card_info objectForKey:kMapNameKey] UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_text(stmt, 12, [[card_info objectForKey:kCardTypeKey] UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_text(stmt, 13, [identifier UTF8String], -1, SQLITE_STATIC);
        if(sqlite3_step(stmt) == SQLITE_ROW)
        {
            
        }
    }
    sqlite3_reset(stmt);
    sqlite3_finalize(stmt);
}

- (void)deleteOverDayCard
{
    NSInteger intResult;
    sqlite3_stmt *stmt;
    
    SInt32 sec = [[NSDate date] timeIntervalSince1970];
    SInt32 cleanSec = sec - ([[[PublicMethod sharedMethod] getValueForKey:kCleanDayKey] intValue] * 3600 * 24);
    if ([[[PublicMethod sharedMethod] getValueForKey:kCleanDayKey] intValue] == 99)
    {
        cleanSec = 0;
    }
    //delete from system
    NSMutableArray *marray = [[NSMutableArray alloc] init];
    NSString *select = [NSString stringWithFormat:@"select card_identifier from card_list where date < %d", DELETE_SEC(cleanSec)];
    if(sqlite3_prepare_v2(_database, [select UTF8String], -1, &stmt, NULL) == SQLITE_OK) 
    {
        while (sqlite3_step(stmt) == SQLITE_ROW) 
        {
            int numCol = sqlite3_column_count(stmt);
            if (numCol) 
            {
                const unsigned char *value = sqlite3_column_text(stmt, 0);
                NSString *valueString = [NSString string];
                if (value) {
                    valueString = [NSString stringWithUTF8String:(const char *)value];
                }
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:valueString, kCardIdentifierKey, nil];
                [marray addObject:dict];
                [dict release];
            }
        }
    }
    sqlite3_finalize(stmt);
    for (NSDictionary *dict in marray)
    {
        [self removeEvent:dict];
    }
    
    NSString *strSql = [NSString stringWithFormat:@"delete from card_list where date < '%d'", DELETE_SEC(cleanSec)];
    intResult = sqlite3_exec(_database, [strSql UTF8String],nil, &stmt, nil);
    if (SQLITE_OK == intResult) 
    {
        
    }
}

- (BOOL)deleteCard:(NSDictionary *)card_info
{
    [self removeEvent:card_info];
    NSInteger intResult;
    sqlite3_stmt *stmt;
    NSString *strSQL = [[NSMutableString alloc] initWithFormat:@"delete from card_list where card_id=%@", [card_info objectForKey:kCardIDKey]];
    intResult = sqlite3_exec(_database, [strSQL UTF8String],nil, &stmt, nil);
    [strSQL release];
    if (SQLITE_OK == intResult) 
    {
        return YES;
    }
    return NO;
}

- (BOOL)updateCard:(NSDictionary *)card_info
{
    [self modifyEvent:card_info];
    NSInteger intResult;
    sqlite3_stmt *stmt;
    NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
    for (NSString *key in [card_info allKeys])
    {
        if (![key isEqualToString:kCardIDKey])
        {
            [mdict setValue:[card_info objectForKey:key] forKey:key];
        }
    }
    
    NSMutableString *strSQL = [[NSMutableString alloc] initWithString:@"update card_list set "];
    NSArray *arrayKey = [mdict allKeys];
    if ([arrayKey count])
    {
        [strSQL appendFormat:@"%@='%@'", [arrayKey objectAtIndex:0], [mdict objectForKey:[arrayKey objectAtIndex:0]]];
    }
    
    for (int i = 1; i < [arrayKey count]; i ++)
    {
        [strSQL appendFormat:@", %@='%@'", [arrayKey objectAtIndex:i], [mdict objectForKey:[arrayKey objectAtIndex:i]]];
    }
    [strSQL appendFormat:@" where card_id=%d",[[card_info objectForKey:kCardIDKey] intValue]];
    
    intResult = sqlite3_exec(_database, [strSQL UTF8String],nil, &stmt, nil);
    [strSQL release];

    if (SQLITE_OK == intResult) 
    {
        return YES;
    }
    return NO;
}

- (NSDictionary *)cardList:(BOOL)isFirst card_id:(SInt32)card_id;
{
    SInt32 firstEffective = 0;
    SInt32 newCard = 0;
    BOOL   isFound = NO;
    
    [self deleteOverDayCard];

    SInt32 sec = [[NSDate date] timeIntervalSince1970];
    NSMutableArray *marrayCardList = [[NSMutableArray alloc] init];
    
    SInt32 cleanSec = sec - ([[[PublicMethod sharedMethod] getValueForKey:kCleanDayKey] intValue] * 3600 * 24);
    if ([[[PublicMethod sharedMethod] getValueForKey:kCleanDayKey] intValue] == 99)
    {
        cleanSec = 0;
    }
    
    NSMutableString *strSql = [[NSMutableString alloc] initWithFormat:@"select * from card_list where date > '%d'", DELETE_SEC(cleanSec)];
    
    if (![[[PublicMethod sharedMethod] getValueForKey:kSynchronizationSystemKey] intValue])
    {
        [strSql appendString:@" and card_type=1"];
    }
    
    [strSql appendString:@" order by date asc"];
    const char *sql = [strSql UTF8String];
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(_database, sql, -1, &stmt, NULL) == SQLITE_OK) 
    {
        while (sqlite3_step(stmt) == SQLITE_ROW) 
        {
            NSMutableDictionary *mdictCard = [[NSMutableDictionary alloc] init];
            int numCol = sqlite3_column_count(stmt);
            for (int i = 0; i < numCol; i++) {
                const char *key = sqlite3_column_name(stmt, i);
                NSAssert(key, @"Field title cannot be null");
                const unsigned char *value = sqlite3_column_text(stmt, i);
                NSString *valueString = [NSString string];
                if (value) {
                    valueString = [NSString stringWithUTF8String:(const char *)value];
                }
                [mdictCard setObject:valueString forKey:[NSString stringWithUTF8String:key]];
            }
            if ([mdictCard objectForKey:kDateKey])
            {
                if (isFirst)
                {
                    if ([[mdictCard objectForKey:kDateKey] floatValue] < sec)
                    {
                        firstEffective ++;
                    }
                }
                else 
                {
                    if (([[mdictCard objectForKey:kCardIDKey] intValue] !=  card_id) && !isFound)
                    {
                        newCard ++;
                    }
                    
                    if ([[mdictCard objectForKey:kCardIDKey] intValue] == card_id)
                    {
                        isFound = YES;
                    }
                }
            }
            [marrayCardList addObject:mdictCard];
            [mdictCard release];
        }
    }
    sqlite3_reset(stmt);
    sqlite3_finalize(stmt);
    [strSql release];
    
    firstEffective = (firstEffective > [marrayCardList count] -1) ? ([marrayCardList count] - 1) : firstEffective;
//    newCard = (newCard > [marrayCardList count] -1) ? ([marrayCardList count] - 1) : newCard;

    NSDictionary *dict = nil;
    if (isFirst)
    {
        dict = [[NSDictionary alloc] initWithObjectsAndKeys:marrayCardList,[NSString stringWithFormat:@"%d",firstEffective], nil];
    }
    else
    {
        dict = [[NSDictionary alloc] initWithObjectsAndKeys:marrayCardList,[NSString stringWithFormat:@"%d", newCard], nil];
    }
    
    [marrayCardList release];
    return [dict autorelease];
}

- (SInt32)maxCardID
{
    NSString *strSql = [NSString stringWithString:@"select max(card_id) from card_list"];
    const char *sql = [strSql UTF8String];
    sqlite3_stmt *stmt;
    
    SInt32 maxCardID = 0;
    if(sqlite3_prepare_v2(_database, sql, -1, &stmt, NULL) == SQLITE_OK)
    {
        char *contentData = nil;
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            contentData = (char *)sqlite3_column_text(stmt, 0);
            if (contentData)
            {
                maxCardID = [[NSString stringWithUTF8String:contentData] intValue];
            }
        }
    }
    sqlite3_reset(stmt);
    sqlite3_finalize(stmt);
    return maxCardID;
}

#pragma mark --
- (void)synchronizationSystem:(BOOL)isSy
{
    if (isSy)
    {//不同步　变为同步
        [[PublicMethod sharedMethod] saveValue:@"1" forKey:kSynchronizationSystemKey];
        NSDictionary * dict = [self cardList:YES card_id:0];
        for (NSMutableDictionary *card in [[dict allValues] lastObject])
        {
            if (([card objectForKey:kCardIdentifierKey] == nil) || ([[card objectForKey:kCardIdentifierKey] isEqualToString:@""]))
            {
                NSString *strCardIdentifier =  [self createEvent:card];
                [card setValue:strCardIdentifier forKey:kCardIdentifierKey];
                [self updateCard:card];
            }
        }
    }
    else
    {//同步　变为不同步
        [[PublicMethod sharedMethod] saveValue:@"0" forKey:kSynchronizationSystemKey];
    }
}

#pragma mark - KalDataSource Delegate Method -
- (NSString *)startDateForDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    NSDate *startDate = [dateFormatter dateFromString:strDate];
    NSTimeInterval start = [startDate timeIntervalSince1970];
    [dateFormatter release];
    return [NSString stringWithFormat:@"%0.lf",start];
}

- (void)presentingDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate delegate:(id<KalDataSourceCallbacks>)delegate
{
    [_mdictMonthLog removeAllObjects];
    [self loadDataFrom:fromDate to:toDate];
    if ([delegate respondsToSelector:@selector(loadDataSource:)]) 
    {
        [delegate loadDataSource:self];
    }
}

- (NSDictionary *)markedDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
    NSString *strFrom = [self startDateForDate:fromDate];
    NSString *strTo = [self startDateForDate:toDate];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (NSString *strDate in [_mdictMonthLog allKeys])
    {
        if (IsDateBetweenInclusive(strDate, strFrom, strTo)) 
        {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[strDate doubleValue]];
            [dict setObject:[_mdictMonthLog objectForKey:strDate] forKey:date];
        }
    }
    return [dict autorelease];
}

- (NSDictionary *)loadItemsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    if (!fromDate && !toDate) {
        return nil;
    }
    
    NSString *strFrom = [self startDateForDate:fromDate];
    NSString *strTo = [self startDateForDate:toDate];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (NSString *strDate in [_mdictMonthLog allKeys])
    {
        if (IsDateBetweenInclusive(strDate, strFrom, strTo)) 
        {
            [dict setObject:[_mdictMonthLog objectForKey:strDate] forKey:strDate];
        }
    }
    return [dict autorelease];
}

- (void)loadDataFrom:(NSDate *)fromDate to:(NSDate *)toDate
{   
    SInt32 from = [fromDate timeIntervalSince1970];
    SInt32 to = [toDate timeIntervalSince1970];
    
    NSString *strFromTime = [NSString stringWithFormat:@"%d", DELETE_SEC(from)];
    NSString *strToTime = [NSString stringWithFormat:@"%d", DELETE_SEC(to)];
    
    
    NSMutableString *strSql = [[NSMutableString alloc] initWithFormat:@"select * from card_list where (date between %@ and %@)",strFromTime, strToTime];
    
    if (![[[PublicMethod sharedMethod] getValueForKey:kSynchronizationSystemKey] intValue])
    {
        [strSql appendString:@" and card_type=1"];
    }
    
    [strSql appendString:@" order by date asc"];

    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(_database, [strSql UTF8String], -1, &stmt, NULL) == SQLITE_OK) 
    {
        while (sqlite3_step(stmt) == SQLITE_ROW) 
        {
            NSMutableDictionary *mdictCard = [[NSMutableDictionary alloc] init];
            int numCol = sqlite3_column_count(stmt);
            for (int i = 0; i < numCol; i++)
            {
                const char *key = sqlite3_column_name(stmt, i);
                NSAssert(key, @"Field title cannot be null");
                const unsigned char *value = sqlite3_column_text(stmt, i);
                NSString *valueString = [NSString string];
                if (value) {
                    valueString = [NSString stringWithUTF8String:(const char *)value];
                }
                [mdictCard setObject:valueString forKey:[NSString stringWithUTF8String:key]];
            }   
            
            NSString *strDate = [mdictCard objectForKey:kDateKey];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[strDate doubleValue]];
            NSString *beginDate = [self startDateForDate:date];
            NSMutableArray *dayHistorys = [_mdictMonthLog objectForKey:beginDate];
            if (dayHistorys == nil) {
                dayHistorys = [[NSMutableArray alloc] init];
                [_mdictMonthLog setObject:dayHistorys forKey:beginDate];
                [dayHistorys release];
            }
            [dayHistorys addObject:mdictCard];
            [mdictCard release];
        }
    }
    sqlite3_reset(stmt);
    sqlite3_finalize(stmt);
    [strSql release];
}

#pragma mark - System card manager-
-(NSString *)createEvent:(NSDictionary *)card_info
{      
    if (![[[PublicMethod sharedMethod] getValueForKey:kSynchronizationSystemKey] intValue])
    {
        return nil;
    }
    // Get the event store object  
//    EKEventStore *eventStore = [[EKEventStore alloc] init];  
    // Create a new event
    EKEvent *event  = [EKEvent eventWithEventStore:_eventStore];
    // Create NSDates to hold the start and end date  
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:([[card_info objectForKey:kDateKey] intValue])];
    NSDate *endDate  = [NSDate dateWithTimeIntervalSince1970:([[card_info objectForKey:kDateKey] intValue] + 1)];  
    // Set properties of the new event object  
    NSString *mstrTitle = [card_info objectForKey:kContactTextKey];
    if ((mstrTitle == nil) || ([mstrTitle isEqualToString:DEFAULT_LEJIAN_TEXT]))
    {
        mstrTitle = DEFAULT_CREAT_TEXT;
    }
    event.title = mstrTitle; 
    
    if ([card_info objectForKey:kMapNameKey] != nil)
    {
        event.location = [card_info objectForKey:kMapNameKey];
    }
    
    ///提醒   
    SInt32 offset = [[card_info objectForKey:kRemindTimeKey] intValue];
    if (offset)
    {
        EKAlarm *alerm = [EKAlarm alarmWithRelativeOffset:(- offset)];
        [event addAlarm:alerm];
    }
    event.notes = [NSString stringWithFormat:@"与 %@ 乐见", [card_info objectForKey:kContactNameKey]];
    event.startDate = startDate;  
    event.endDate   = endDate;  
    event.allDay = NO;  
    // set event's calendar to the default calendar  
    [event setCalendar:_calendar];
    // Create an NSError pointer  
    NSError *err;  
    // Save the event  
    [_eventStore saveEvent:event span:EKSpanThisEvent error:&err];
    return [event eventIdentifier];
} 

- (void)removeEvent:(NSDictionary *)card_info
{
    if (![[[PublicMethod sharedMethod] getValueForKey:kSynchronizationSystemKey] intValue])
    {
        return;
    }
    // Get the event store object  
//    EKEventStore *eventStore = [[EKEventStore alloc] init];  
    // Create a new event
    EKEvent *event  = [_eventStore eventWithIdentifier:[card_info objectForKey:kCardIdentifierKey]];
    [event setCalendar:_calendar];
    
    NSError *err;  
    
    [_eventStore removeEvent:event span:EKSpanThisEvent error:&err];
}

- (void)modifyEvent:(NSDictionary *)card_info
{
    if (![[[PublicMethod sharedMethod] getValueForKey:kSynchronizationSystemKey] intValue])
    {
        return;
    }
    // Get the event store object  
//    EKEventStore *eventStore = [[EKEventStore alloc] init];  
    // Create a new event
    EKEvent *event  = [_eventStore eventWithIdentifier:[card_info objectForKey:kCardIdentifierKey]];
    // Create NSDates to hold the start and end date  
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:([[card_info objectForKey:kDateKey] intValue])];
    NSDate *endDate  = [NSDate dateWithTimeIntervalSince1970:([[card_info objectForKey:kDateKey] intValue] + 1)];  
    // Set properties of the new event object  
    NSString *mstrTitle = [card_info objectForKey:kContactTextKey];
    if ((mstrTitle == nil) || ([mstrTitle isEqualToString:DEFAULT_LEJIAN_TEXT]))
    {
        mstrTitle = DEFAULT_CREAT_TEXT;
    }
    event.title = mstrTitle; 
    
    if ([card_info objectForKey:kMapNameKey] != nil)
    {
        event.location = [card_info objectForKey:kMapNameKey];
    }
    
    ///提醒   
    SInt32 offset = [[card_info objectForKey:kRemindTimeKey] intValue];
    if (offset)
    {
        EKAlarm *alerm = [EKAlarm alarmWithRelativeOffset:(- offset)];
        [event addAlarm:alerm];
    }

    event.notes = [NSString stringWithFormat:@"与 %@ 乐见", [card_info objectForKey:kContactNameKey]];
    event.startDate = startDate;  
    event.endDate   = endDate;  
    event.allDay = NO;  
    // set event's calendar to the default calendar  
    [event setCalendar:_calendar];
    
    // Create an NSError pointer  
    NSError *err;  
    // Save the event  
    [_eventStore saveEvent:event span:EKSpanThisEvent error:&err];
}

- (NSArray *)fetchAllEvents 
{	
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    CFGregorianDate gregorianStartDate, gregorianEndDate;
    //    CFGregorianUnits startUnits = {-10, 0, 0, 0, 0, 0};
    //    CFGregorianUnits endUnits = {10, 0, 0, 0, 0, 0};
    //iTouch
    CFGregorianUnits startUnits = {-1, 0, 0, 0, 0, 0};
    CFGregorianUnits endUnits = {1, 0, 0, 0, 0, 0};
    CFTimeZoneRef timeZone = CFTimeZoneCopySystem();
    
    gregorianStartDate = CFAbsoluteTimeGetGregorianDate(CFAbsoluteTimeAddGregorianUnits(CFAbsoluteTimeGetCurrent(), timeZone, startUnits),timeZone);
    gregorianStartDate.hour = 0;
    gregorianStartDate.minute = 0;
    gregorianStartDate.second = 0;
    
    gregorianEndDate = CFAbsoluteTimeGetGregorianDate(CFAbsoluteTimeAddGregorianUnits(CFAbsoluteTimeGetCurrent(), timeZone, endUnits),
                                                      timeZone);
    gregorianEndDate.hour = 0;
    gregorianEndDate.minute = 0;
    gregorianEndDate.second = 0;
    
    NSDate* startDate =
    [NSDate dateWithTimeIntervalSinceReferenceDate:CFGregorianDateGetAbsoluteTime(gregorianStartDate, timeZone)];
    NSDate* endDate =
    [NSDate dateWithTimeIntervalSinceReferenceDate:CFGregorianDateGetAbsoluteTime(gregorianEndDate, timeZone)];
    
    CFRelease(timeZone);
    
    NSArray *calendarArray = [NSArray arrayWithObject:_calendar];
    // Create the predicate.
    NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:calendarArray]; // eventStore is an instance variable.
    // Fetch all events that match the predicate.
    NSArray *events = [eventStore eventsMatchingPredicate:predicate];
    return events;
}

- (void)appicationDidBecomActive
{
    if (![[[PublicMethod sharedMethod] getValueForKey:kSynchronizationSystemKey] intValue])
    {
        return;
    }
    NSArray *array = [self fetchAllEvents];
    
    NSMutableArray *marrayCards = [[NSMutableArray alloc] initWithArray:[[[self cardList:YES card_id:0] allValues] lastObject]];
    for (EKEvent *event in array)
    {
        if ([[event calendar] type] != 4)
        {
            NSMutableDictionary *card_info = [[NSMutableDictionary alloc] init];
            
            ///读取事件
            NSString *title = [event title];
            if ([[event title] isEqualToString:DEFAULT_CREAT_TEXT])
            {
                title = @"编辑添加约会描述";
            }
            [card_info setValue:title forKey:kContactTextKey];
            
            ///读取提醒
            NSArray *alerms = [event alarms];
            if ([alerms count])
            {
                EKAlarm *alerm = [alerms objectAtIndex:0];
                [card_info setValue:[NSString stringWithFormat:@"%.0f", -[alerm relativeOffset]] forKey:kRemindTimeKey];
            }
            ///读取时间
            NSString *date = [NSString stringWithFormat:@"%0.f", [[event startDate] timeIntervalSince1970]];
            [card_info setValue:date forKey:kDateKey];
            
            if (![[card_info objectForKey:kCardTypeKey] intValue])
            {
                [card_info setValue:[NSString stringWithFormat:@"%d", SystemCalendarType] forKey:kCardTypeKey];
                [card_info setValue:[event eventIdentifier] forKey:kCardIdentifierKey];
            }
            
            [self updateSystemCard:card_info];
            for (NSDictionary *dictCard in marrayCards)
            {
                if ([[dictCard objectForKey:kCardIdentifierKey] isEqualToString:[event eventIdentifier]])
                {
                    [marrayCards removeObject:dictCard];
                    break;
                }
            }
        }
    }
    
    [self deleteNotExistForSystem:marrayCards];
    [marrayCards release];
}
@end
