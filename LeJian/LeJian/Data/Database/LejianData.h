//
//  LejianData.h
//  LeJian
//
//  Created by gongxuehan on 8/14/12.
//  Copyright (c) 2012 smilingmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeJianDatabase.h"

@protocol LejianDataDelegate;
@interface LejianData : NSObject
{
    id<LejianDataDelegate> _delegate;
    LeJianDatabase         *_LJDatabase;
}

@property (nonatomic, assign) id<LejianDataDelegate> delegate;
+ (LejianData *) sharedData;
- (void)mapInfo:(NSDictionary *)dict;
- (void)appendNewCard:(NSDictionary *)card_info;

- (BOOL)updateCardInfo:(NSDictionary *)card_info;

- (BOOL)deleteCard:(NSDictionary *)card_info;

- (void)updateSystemCardInfo:(NSDictionary *)card;

- (void)appicationDidBecomActive;

- (void)synchronizationSystem:(BOOL)isSy;

@end

@protocol LejianDataDelegate <NSObject>

- (void)searchInfoIsRecived:(NSArray *)array;

@end