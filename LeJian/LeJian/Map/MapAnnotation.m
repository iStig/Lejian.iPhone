//
//  MapAnnotation.m
//  MobileAiFang
//
//  Created by  ybjia on 11-9-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "MapAnnotation.h"


@implementation MapAnnotation

@synthesize longitude = _longitude;
@synthesize latitude = _latitude;
@synthesize strTitle = _strTitle;
@synthesize strProvideID;
- (CLLocationCoordinate2D)coordinate
{
    _coordinate.latitude = self.latitude;
    _coordinate.longitude = self.longitude;
    return _coordinate;
}

- (NSString *)title 
{
    return _strTitle;
}


- (void)dealloc {
    self.strTitle = nil;
    self.strProvideID = nil;
    [super dealloc];
}

- (NSString *)provideId
{
    return self.strProvideID;
}


@end
