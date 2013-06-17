//
//  MapAnnotation.h
//  MobileAiFang
//
//  Created by  ybjia on 11-9-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface MapAnnotation : NSObject < MKAnnotation > {
    CLLocationDegrees _longitude;
    CLLocationDegrees _latitude;
    NSString *_strTitle;
    CLLocationCoordinate2D _coordinate;
}

@property (nonatomic, assign) CLLocationDegrees longitude;
@property (nonatomic, assign) CLLocationDegrees latitude;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *strTitle;
@property (nonatomic, retain)NSString *strProvideID;


@end