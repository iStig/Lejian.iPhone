//
//  LejianData.m
//  LeJian
//
//  Created by gongxuehan on 8/14/12.
//  Copyright (c) 2012 smilingmobile. All rights reserved.
//

#import "LejianData.h"
#import "ClockManager.h"

@implementation LejianData
@synthesize delegate = _delegate;

static LejianData *sharedData = nil;

+ (LejianData *) sharedData
{
    @synchronized(self) {
        if (sharedData == nil) {
            [[self alloc] init];
        }
    }
    
    return sharedData;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if(sharedData == nil) { 
            sharedData = [super allocWithZone:zone];
            return sharedData;
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


- (void)dealloc
{
    [super dealloc];
    
}

- (id)init
{
    self = [super init];
    if (self) 
    {
        _LJDatabase = [LeJianDatabase sharedDatabase];
    }
    return self;
}

- (void)mapInfo:(NSDictionary *)dict
{
    if (dict)
    {
        NSArray *arrayAddress = [dict objectForKey:@"results"];
//        if ([arrayAddress count])
//        {
            if ([_delegate respondsToSelector:@selector(searchInfoIsRecived:)])
            {
                [_delegate searchInfoIsRecived:arrayAddress];
            }
//        }
    }
}

- (BOOL)deleteCard:(NSDictionary *)card_info
{
    return [_LJDatabase deleteCard:card_info] && [[ClockManager shardeScheduleData] deleteLocalNotification:card_info];
}

- (void)appendNewCard:(NSDictionary *)card_info
{
    if (card_info)
    {
        [_LJDatabase appendCardInfo:card_info];
    }
}

- (BOOL)updateCardInfo:(NSDictionary *)card_info
{
    return [[LeJianDatabase sharedDatabase] updateCard:card_info];
}

- (void)updateSystemCardInfo:(NSDictionary *)card
{
    [[LeJianDatabase sharedDatabase] updateSystemCard:card];
}

- (void)appicationDidBecomActive
{
    [[LeJianDatabase sharedDatabase] appicationDidBecomActive];
}

- (void)synchronizationSystem:(BOOL)isSy
{
    [[LeJianDatabase sharedDatabase] synchronizationSystem:isSy];
}
@end
