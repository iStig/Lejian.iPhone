//
//  LeJianRequest.m
//  LeJian
//
//  Created by gongxuehan on 8/14/12.
//  Copyright (c) 2012 smilingmobile. All rights reserved.
//

#import "LeJianRequest.h"
#import "JSON.h"
#import "LejianData.h"

#define GOOGLE_URL @"https://maps.google.com/maps/api/geocode/json?"

@interface LeJianRequest ()
{
    NSMutableData *_data;
    NSURLConnection *_searchConnection;
    LejianData     *_leJianData;
}

@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) NSURLConnection *searchConnection;
@end

@implementation LeJianRequest
@synthesize data = _data;
@synthesize searchConnection = _searchConnection;
@synthesize delegate = _delegate;

static LeJianRequest *sharedRequest = nil;

+ (LeJianRequest *) sharedRequest{
    @synchronized(self) {
        if (sharedRequest == nil) {
            [[self alloc] init];
        }
    }
    
    return sharedRequest;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if(sharedRequest == nil) { 
            sharedRequest = [super allocWithZone:zone];
            return sharedRequest;
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
    self = [super init];
    if (self) 
    {
        _leJianData = [LejianData sharedData];
        //
        if (!self.data)
        {
            NSMutableData *d = [[NSMutableData alloc] init];
            self.data = d;
            [d release];
        }
    }
    return self;
}

- (void)dealloc
{
    [_data release];
    [_searchConnection release];
    [super dealloc];
}

- (void)cancelRequest
{
    [NSURLRequest cancelPreviousPerformRequestsWithTarget:self];
    [_searchConnection cancel];
}

- (NSString *)urlEncodedParaString:(NSString *)str
{
    if (str) {
        CFStringRef strEncode = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                        (CFStringRef)str,
                                                                        NULL,
                                                                        CFSTR("!*'();:@+$,&=/?%#[]"),
                                                                        kCFStringEncodingUTF8);
        NSString *result=[(NSString *)strEncode retain];
        CFRelease(strEncode);
        [result autorelease];
        return result;
    }
    return nil;
}

- (void)search:(NSString *)name
{
    [self cancelRequest];
    NSMutableString *strUrl = [[NSMutableString alloc] initWithString:GOOGLE_URL];
    [strUrl appendFormat:@"address=%@&",[self urlEncodedParaString:name]];
    [strUrl appendFormat:@"sensor=true"];
    NSURL *url = [[NSURL alloc] initWithString:strUrl];  
    [strUrl release];
    
    NSMutableURLRequest *request = nil;
    request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    [request setHTTPMethod:@"GET"];
    [url release];
    NSURLConnection *co;
    co = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    self.searchConnection = co;
    [request release];
    [co release];   
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ([_delegate respondsToSelector:@selector(requestIsFailed)]) {
        [_delegate requestIsFailed];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{    
    // If there is no data in finish loading buffer, do nothing
    if (![_data length]) 
        return;
    NSString *strJson = [[NSString alloc] initWithBytes:[_data mutableBytes] length:[_data length] encoding:NSUTF8StringEncoding];
    NSDictionary *dict = nil;
    if (connection == _searchConnection)
    {
        dict = [strJson JSONValue];
        if (dict)
        {
            [_leJianData mapInfo:dict];
        }
    }
    [strJson release];
    self.data.length = 0;
}

@end
