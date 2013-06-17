//
//  GoogleMapViewController.h
//  QubaoMedicalCare
//
//  Created by  on 12-7-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapAnnotation.h"

@protocol GoogleMapViewControllerDelegate;
@interface GoogleMapViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate, UIGestureRecognizerDelegate,MKReverseGeocoderDelegate>
{
    NSString *_strAddress;
    NSString *_strLatitude;
    NSString *_strLongitude;

    CGRect    _mapViewFrame;
    MKMapView *_mapView;

    CLLocation *_currentLocation;
    CLLocation *_loupanLocation;

    MapAnnotation *_annotation;
    NSMutableArray  *_marrayAnnotation;
    CLLocationManager *_locationManager;
    UINavigationController *nav;
    
    id <GoogleMapViewControllerDelegate> _delegate;
}

@property (nonatomic, assign) id<GoogleMapViewControllerDelegate> delegate;
@property (nonatomic, retain)  UINavigationController *nav;
@property (nonatomic, retain) NSString *strAddress;
@property (nonatomic, retain) NSString *strLatitude;
@property (nonatomic, retain) NSString *strLongitude;
@property (nonatomic, assign) CGRect mapViewFrame;
@property (nonatomic, retain) CLLocation *loupanLocation;
@property (nonatomic, retain) NSMutableArray *marrayAnnotation;
@property (nonatomic, retain) NSString *strProvideId;

//选择目标区域
- (void)selectTargetArea:(CLLocation *)location;
- (void)wakeupSystemMap;
@end

@protocol GoogleMapViewControllerDelegate <NSObject>

- (void)selectedPlace:(NSDictionary *)dictInfo;

@end