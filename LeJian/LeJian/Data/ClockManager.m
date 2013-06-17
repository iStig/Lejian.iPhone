//
//  ClockManage.m
//  LeJian
//
//  Created by gongxuehan on 8/22/12.
//  Copyright (c) 2012 smilingmobile. All rights reserved.
//

#import "ClockManager.h"
#import "PublicMethod.h"
#import "LejianData.h"
#import "LeJianDatabase.h"

@implementation ClockManager

static ClockManager *sharedInstance = nil;

+ (ClockManager *) shardeScheduleData {
    @synchronized(self) {
        if (sharedInstance == nil) {
            [[self alloc] init];
        }
    }
    
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if(sharedInstance == nil) { 
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;
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

- (id)init
{
    if ((self = [super init])) {
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (BOOL)localNotificationIsAlreadyExists:(NSDictionary *)clocker
{
    NSArray *allNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications]; 
    for (UILocalNotification  *localNotif in allNotifications)
    {
        NSDictionary *dict = [localNotif userInfo];
        NSDictionary *card_info = [dict objectForKey:kLocalNotificationUserInfoKey];
        if ([[clocker objectForKey:kCardIDKey] intValue] == [[card_info objectForKey:kCardIDKey] intValue]) 
        {
            return YES;
        }
    }
    return NO;
}


- (BOOL)deleteLocalNotification:(NSDictionary *)clocker
{
    BOOL successed = NO;
    SInt32 clockID = [[clocker objectForKey:kCardIDKey] intValue];
    NSArray *allNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications]; 
    for (UILocalNotification  *localNotif in allNotifications)
    {
        NSDictionary *dict = [localNotif userInfo];
        if (clockID == [[[dict objectForKey:kLocalNotificationUserInfoKey] objectForKey:kCardIDKey] intValue]) 
        {
            [[UIApplication sharedApplication] cancelLocalNotification:localNotif];
            successed = YES;
        }
    }
    return successed;
}

- (void)addNewLocalNotification:(NSDictionary *)clocker
{
    NSTimeInterval secDate = [[clocker objectForKey:kDateKey] intValue];
    if (secDate < [[NSDate date] timeIntervalSince1970])
    {
        return;
    }
    if (![self localNotificationIsAlreadyExists:clocker] && [[[PublicMethod sharedMethod] getValueForKey:kRemindKey] boolValue])
    {
        NSDictionary *dictUserInfo = [[NSDictionary alloc] initWithObjectsAndKeys:clocker,kLocalNotificationUserInfoKey, nil];
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        
        NSTimeInterval remind = [[clocker objectForKey:kRemindTimeKey] intValue];
//        if (!remind) {
//            remind = 3600;
//        }
        NSTimeInterval sec = [[clocker objectForKey:kDateKey] intValue] - remind;
        if (sec < [[NSDate date] timeIntervalSince1970]) 
        {
            return;
        }
        
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        [fmt setDateFormat:@"MM月dd日　HH:mm"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[clocker objectForKey:kDateKey] intValue]];
        localNotif.fireDate = [NSDate dateWithTimeIntervalSince1970:sec];
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        localNotif.userInfo = dictUserInfo;
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        [dictUserInfo release];
        NSString *body = [NSString stringWithFormat:@"您将在 %@ 与　%@　乐见",[fmt stringFromDate:date], [clocker objectForKey:kContactNameKey]];
        [fmt release];
        localNotif.alertBody = body;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        [localNotif release];
    }
}

- (void)modifyLocalNotification:(NSDictionary *)clocker
{
    [self deleteLocalNotification:clocker];
    [self addNewLocalNotification:clocker];
}

- (void)remindFuntionIsOn:(BOOL)on
{
    if (!on)
    {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    else
    {
        NSDictionary *dict = [[LeJianDatabase sharedDatabase] cardList:YES card_id:0];
        NSArray *array = [[dict allValues] lastObject];
        for (NSDictionary *card_info in array)
        {
            [self addNewLocalNotification:card_info];
        }
    }
}

@end
