//
//  LeJianRequest.h
//  LeJian
//
//  Created by gongxuehan on 8/14/12.
//  Copyright (c) 2012 smilingmobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LeJianRequestDelegate;

@interface LeJianRequest : NSObject
{
    id<LeJianRequestDelegate> _delegate;
}

@property (nonatomic, assign) id<LeJianRequestDelegate> delegate;
+ (LeJianRequest *) sharedRequest;
- (void)search:(NSString *)name;

@end

@protocol LeJianRequestDelegate <NSObject>

- (void)requestIsFailed;

@end