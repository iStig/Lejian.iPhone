//
//  MapViewController.h
//  QubaoMedicalCare
//
//  Created by  on 12-7-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleMapViewController.h"
#import "NavigationController.h"
#import "LeJianRequest.h"
#import "LejianData.h"
#import "PublicMethod.h"

@protocol MapViewControllerDelegate;
@interface MapViewController :UIViewController < MKMapViewDelegate, UISearchBarDelegate, LejianDataDelegate, GoogleMapViewControllerDelegate, LeJianRequestDelegate>
{
    
    GoogleMapViewController *_mapVC;
    //CLLocationManager *_locationManager;
    CLLocation *_startingPoint;
    
    NSMutableArray  *_marrayNearLibrary;
    NSMutableArray  *_marrayPlaceMark;
    
    UIButton *_btnForward;
    UIButton *_btnBackward;
    
    id<MapViewControllerDelegate> _delegate;
    NSDictionary *_dictMapLocation;
}

@property (nonatomic, retain) NSDictionary *dictMapLocation;
@property (nonatomic, assign) id<MapViewControllerDelegate> delegate;
@property(nonatomic, retain)NSMutableArray *arrayAddress;

@end

@protocol MapViewControllerDelegate <NSObject>

- (void)mapPlaceIsSelected:(NSDictionary *)dict;

@end
