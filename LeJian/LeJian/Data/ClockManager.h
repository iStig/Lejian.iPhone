//
//  ClockManage.h
//  LeJian
//
//  Created by gongxuehan on 8/22/12.
//  Copyright (c) 2012 smilingmobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClockManager : NSObject

+ (ClockManager *) shardeScheduleData;

- (BOOL)deleteLocalNotification:(NSDictionary *)clocker;
- (void)addNewLocalNotification:(NSDictionary *)clocker;
- (void)modifyLocalNotification:(NSDictionary *)clocker;
- (void)remindFuntionIsOn:(BOOL)on;
@end
