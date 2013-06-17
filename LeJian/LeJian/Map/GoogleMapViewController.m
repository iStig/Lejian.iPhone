//
//  GoogleMapViewController.m
//  MobileAiFang
//
//  Created by  ybjia on 11-9-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "GoogleMapViewController.h"
#import "PublicMethod.h"
#import "CustomAnnotationView.h"
#import "LeJianDatabase.h"

#define kProviedeName @"provider_name"
#define kLatitude @"lat"
#define kLongitude  @"lng"
#define kGeometry @"geometry"

@interface GoogleMapViewController ()
{
    MKCoordinateRegion _theRegion;
    NSMutableArray     *_marrayPlace;
    NSString           *_currentLat;
    NSString           *_currentLng;
    BOOL                _isTouched;
    BOOL                _isProcessed;
    MapAnnotation      *_touchAnnotation;
    CLLocationCoordinate2D  _lastCLLocation;
}
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) NSString   *currentLat;
@property (nonatomic, retain) NSString   *currentLng;
@property (nonatomic, retain) MapAnnotation *touchAnnotation;

- (void)configureMapView:(CLLocation *)location;
- (void)zoomToFitMapAnnotations:(MKMapView*)mapView;

//在包含经纬度的字典中查找位置
- (CLLocation *)getLocation:(NSDictionary *)dictLocation;
- (MapAnnotation *)getAnnotation:(CLLocation *)location title:(NSString *)ttl;
- (void)startedReverseGeoderWithLatitude:(double)latitude longitude:(double)longitude;

@end

@implementation GoogleMapViewController
@synthesize touchAnnotation = _touchAnnotation;
@synthesize currentLat = _currentLat;
@synthesize currentLng = _currentLng;
@synthesize strAddress = _strAddress;
@synthesize strLatitude = _strLatitude;
@synthesize strLongitude = _strLongitude;
@synthesize mapViewFrame = _mapViewFrame;
@synthesize marrayAnnotation = _marrayAnnotation;

@synthesize currentLocation = _currentLocation;
@synthesize loupanLocation = _loupanLocation;
@synthesize strProvideId;
@synthesize delegate = _delegate;

@synthesize nav;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.strAddress= nil;
	self.strLatitude = nil;
	self.strLongitude = nil;
    self.currentLocation  = nil;
	self.loupanLocation  = nil;
    _mapView.delegate = nil;

    [_marrayPlace release];
    [_currentLat release];
    [_currentLng release];
    [_annotation release];
    [_mapView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

///地图长按的响应方法
- (void)longPress:(UIGestureRecognizer*)gestureRecognizer{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan){
        return;
    }
    if (_isProcessed)
    {
        return;
    }
    _isProcessed = YES;
    _isTouched = YES;
    //坐标转换
    CGPoint touchPoint = [gestureRecognizer locationInView:_mapView];
    CLLocationCoordinate2D touchMapCoordinate = [_mapView convertPoint:touchPoint toCoordinateFromView:_mapView];
    if ((ABS(_lastCLLocation.latitude - touchMapCoordinate.latitude) < 0.001) && (ABS(_lastCLLocation.longitude - touchMapCoordinate.longitude) < 0.001))
    {
        _isProcessed = NO;
        _isTouched = NO;
        return;
    }
    _lastCLLocation = touchMapCoordinate;
    CLLocation *tempLocation = [[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude longitude:touchMapCoordinate.longitude];
    MapAnnotation *tempAnnotation = [[self getAnnotation:tempLocation title:@"未知"] retain];
    self.touchAnnotation = tempAnnotation;
    [tempAnnotation release];
    
    [_mapView addAnnotation:self.touchAnnotation];
}

#pragma mark - View lifecycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];  
        
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
	_mapView.delegate = self;
    _mapView.mapType = MKMapTypeStandard;
    _mapView.showsUserLocation = YES;
    
    UILongPressGestureRecognizer *lpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    lpress.minimumPressDuration = 0.5;//按0.5秒响应longPress方法
    lpress.allowableMovement = 10.0;
    [_mapView addGestureRecognizer:lpress];//m_mapView是MKMapView的实例
    [lpress release];
    
    _marrayPlace = [[NSMutableArray alloc] init];
    CLLocationManager *locationManager = [[PublicMethod sharedMethod] startLocationManager];//创建位置管理器
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;//指定需要的精度级别
    locationManager.distanceFilter=1000.0f;//设置距离筛选器
    [locationManager startUpdatingLocation];//启动位置管理器
    NSString *strLat = [[NSString alloc] initWithFormat:@"%.15f",locationManager.location.coordinate.latitude];
    NSString *strLng = [[NSString alloc] initWithFormat:@"%.15f",locationManager.location.coordinate.longitude];
    self.currentLat = strLat;
    [strLat release];
    self.currentLng = strLng;
    [strLng release];
    
    if (!self.strLatitude || !self.strLongitude || !self.strAddress)
    {
        MKCoordinateSpan theSpan;
        //地图的范围 越小越精确
        theSpan.latitudeDelta=0.02;
        theSpan.longitudeDelta=0.02;
        _theRegion.center=[[locationManager location] coordinate];
        _theRegion.span=theSpan;
        [_mapView setRegion:_theRegion];
    }
    else
    {
        CLLocation *tempLocation = [[CLLocation alloc] initWithLatitude:[_strLatitude doubleValue] longitude:[_strLongitude doubleValue]];
        MapAnnotation *tempAnnotation = [[self getAnnotation:tempLocation title:_strAddress] retain];
        tempAnnotation.strProvideID = @"0";
        [_marrayPlace addObject:tempAnnotation];
        [tempAnnotation release];
        
        MKCoordinateRegion region;
        region.center.latitude = [self.strLatitude doubleValue];
        region.center.longitude = [self.strLongitude doubleValue];
        region.span.latitudeDelta = 0.02;
        region.span.longitudeDelta = 0.02;
        [_mapView setRegion:region animated:NO];
        [_mapView selectAnnotation:[_marrayPlace objectAtIndex:0] animated:YES];
    }
    [self.view addSubview:_mapView];
}

//create a MapAnnotation according to the location and title
- (MapAnnotation *)getAnnotation:(CLLocation *)location title:(NSString *)ttl
{
    MapAnnotation *annotation = [[[MapAnnotation alloc] init] autorelease];
    annotation.latitude = location.coordinate.latitude;
    annotation.longitude = location.coordinate.longitude;
    annotation.strTitle = ttl;
    return annotation;
}

//configure MKMapView
- (void)configureMapView:(CLLocation *)location
{
    self.view.frame = _mapViewFrame;
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
	_mapView.delegate = self;
    _mapView.mapType = MKMapTypeStandard;
    _mapView.showsUserLocation = YES;
    [self selectTargetArea:location];
    [self.view addSubview:_mapView];

}

- (void)setMarrayAnnotation:(NSMutableArray *)marrayAnnotation
{
    if (_marrayAnnotation != marrayAnnotation)
    {
        [_marrayAnnotation removeAllObjects];
        [_marrayAnnotation release];
        _marrayAnnotation = [marrayAnnotation retain];
    }
    [_mapView removeAnnotations:_marrayPlace];
    [_marrayPlace removeAllObjects];
    [self selectTargetArea:nil];
}

- (void)wakeupSystemMap 
{
    NSString *theString = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%@,%@&daddr=%@,%@", _currentLat,_currentLng,_strLatitude, _strLongitude];
    theString =  [theString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSURL *url = [[NSURL alloc] initWithString:theString];
    [[UIApplication sharedApplication] openURL:url];
}

//选择目标区域
- (void)selectTargetArea:(CLLocation *)location 
{
//    if (!_annotation)
//    {
        for (NSInteger i = 0; i < [_marrayAnnotation count]; i++)
        {
            NSDictionary *dict = [_marrayAnnotation objectAtIndex:i];
            NSDictionary *dictLocation = [[dict objectForKey:kGeometry] objectForKey:@"location"];
            if (!i)
            {
                self.strLatitude = [dictLocation objectForKey:kLatitude];
                self.strLongitude = [dictLocation objectForKey:kLongitude];
            }
            CLLocation *tempLocation = [[CLLocation alloc] initWithLatitude:[[dictLocation objectForKey:kLatitude] doubleValue] longitude:[[dictLocation objectForKey:kLongitude] doubleValue]];
            
            NSArray *arrayAdd = [dict objectForKey:@"address_components"];
            NSString *title = nil ;
            if ([arrayAdd count])
            {
                if ([arrayAdd count] < 4)
                {
                    title = [[arrayAdd objectAtIndex:0] objectForKey:@"long_name"];
                }
                else
                {
                    title = [NSString stringWithFormat:@"%@ %@",[[arrayAdd objectAtIndex:3] objectForKey:@"long_name"], [[arrayAdd objectAtIndex:0] objectForKey:@"long_name"]];
                }
            }
            MapAnnotation *tempAnnotation = [[self getAnnotation:tempLocation title:title] retain];
            tempAnnotation.strProvideID = [NSString stringWithFormat:@"%d",i];
            [_mapView addAnnotation:tempAnnotation];
            [_marrayPlace addObject:tempAnnotation];
            
            [tempLocation release];
            [tempAnnotation release];
        }
//    } 
    
    if ([_marrayPlace count])
    {
        MKCoordinateRegion region;
        region.center.latitude = [self.strLatitude doubleValue];
        region.center.longitude = [self.strLongitude doubleValue];
        region.span.latitudeDelta = 0.02;
        region.span.longitudeDelta = 0.02;
        [_mapView setRegion:region animated:NO];
        [_mapView selectAnnotation:[_marrayPlace objectAtIndex:0] animated:YES];
    }
}

//在包含经纬度的字典中查找位置
- (CLLocation *)getLocation:(NSDictionary *)dictLocation 
{
    CLLocation *location = nil;
    if ([_marrayAnnotation count] >= 1) 
    {
        location = [[CLLocation alloc] initWithLatitude:[[dictLocation objectForKey:kLatitude] doubleValue] longitude:[[dictLocation objectForKey:kLongitude] doubleValue]];
    }
    
    return [location autorelease];
}

//- (void)zoomToFitMapAnnotations:(MKMapView*)mapView
//{		
//    if ([mapView.annotations count] == 0) return;
//    
//    MKCoordinateRegion region;
//    
//    if ([mapView.annotations count] == 1)
//    {
//        region.center.latitude = [self.strLatitude doubleValue];
//        region.center.longitude = [self.strLongitude doubleValue];
//        region.span.latitudeDelta = 0.05;
//        region.span.longitudeDelta = 0.05;
//    }
//    else 
//    {
//        CLLocationCoordinate2D topLeftCoord;
//        topLeftCoord.latitude = -90;
//        topLeftCoord.longitude = 180;
//        
//        CLLocationCoordinate2D bottomRightCoord;
//        bottomRightCoord.latitude = 90;
//        bottomRightCoord.longitude = -180;
//        
//        for(MapAnnotation *annotation in mapView.annotations)
//        {
//            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
//            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
//            
//            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
//            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
//        }
//        
//        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
//        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
//        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.2; // Add a little extra space on the sides
//        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.2; // Add a little extra space on the sides
//    }
//    
//    region = [mapView regionThatFits:region];
//    [mapView setRegion:region animated:NO];
//    
//    [_mapView deselectAnnotation:_annotation animated:NO];
//    [_mapView selectAnnotation:_annotation animated:NO];
//}

/*
 //go to googlemap and try to find a route 
 - (void)findMyRoute
 {
 self.currentLocation = _mapView.userLocation.location;
 NSString *url = nil;
 if (self.currentLocation) {
 url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",
 _currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude,_loupanLocation.coordinate.latitude,_loupanLocation.coordinate.longitude];
 }
 else {
 url = [NSString stringWithFormat: @"http://maps.google.com/maps?ll=%f,%f",_loupanLocation.coordinate.latitude,_loupanLocation.coordinate.longitude];
 }
 [[UIApplication sharedApplication] openURL: [NSURL URLWithString:url]];
 
 [MobClick event:@"Func_Google_Map"];
 [AppLog insertLogEventWithEventName:@"Func_Google_Map" pageController:NSStringFromClass([self class])];
 }
 */


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark == MKMapViewDelegate == 
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *defaultPinID = @"smilingmobile ";
    if ([annotation isKindOfClass:[MKUserLocation class]]) 
    {
        return nil;
    } 
    else 
    {
        CustomAnnotationView *customPinView = nil;
        
        customPinView = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if (customPinView == nil )
        {
            customPinView = [[[CustomAnnotationView alloc]
                        initWithAnnotation:annotation reuseIdentifier:defaultPinID] autorelease];
                UIButton *btn =[UIButton buttonWithType:UIButtonTypeContactAdd];
                customPinView.rightCalloutAccessoryView = btn;
            
            customPinView.canShowCallout = YES;
            customPinView.animatesDrop = YES;
        } 
        else 
        {
            customPinView.annotation = annotation;
        }
        
        if (_isTouched)
        {
            _isTouched = NO;
            self.touchAnnotation = annotation;
            [self startedReverseGeoderWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
        }
        return customPinView;
    }
}



- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view NS_AVAILABLE(NA, 4_0)
{
    NSLog(@"**********");

}   
- (NSString *)handleNull:(NSString *)str
{
    if ([str isKindOfClass:[NSNull class]])
    {
        NSLog(@"1");
    }
    return ([str isKindOfClass:[NSNull class]] ? @"" : str);
}

- (void)selectedPlaceDelegate:(NSDictionary *)dict
{
    if ([_delegate respondsToSelector:@selector(selectedPlace:)])
    {
        [_delegate selectedPlace:dict];
    }
    [dict release];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    MapAnnotation *tempAnnotation  =  view.annotation;
    
    MKCoordinateRegion region;
    region.center.latitude = [tempAnnotation latitude];
    region.center.longitude = [tempAnnotation longitude];
    region.span.latitudeDelta = 0.03;
    region.span.longitudeDelta = 0.03;
    [_mapView setRegion:region animated:NO];

    NSString *path = [NSString stringWithFormat:@"%@/%.15f-%.15f.png",[[LeJianDatabase sharedDatabase] filePath], [tempAnnotation latitude], [tempAnnotation longitude]];
    
    NSMutableArray *marray = [[NSMutableArray alloc] initWithArray:_mapView.annotations];
    [marray removeObject:tempAnnotation];
    [_mapView removeAnnotations:marray];
    [marray release];
    
    [[PublicMethod sharedMethod] saveImage:path view:_mapView];
    
    NSDictionary *dict = nil;
    if ([tempAnnotation isKindOfClass:[MapAnnotation class]])
    {
        dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%.15f",tempAnnotation.latitude], kMapXKey,[NSString stringWithFormat:@"%.15f", tempAnnotation.longitude], kMapYKey, 
                tempAnnotation.title, kMapNameKey, path, kImagePathKey,nil];
    }
    else 
    {
        dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%.15f",tempAnnotation.coordinate.latitude], kMapXKey,[NSString stringWithFormat:@"%.15f", tempAnnotation.coordinate.longitude], kMapYKey, tempAnnotation.title, @"当前位置", path, kImagePathKey,nil];   
    }
    [_mapView deselectAnnotation:view.annotation animated:NO];
    
    [self performSelector:@selector(selectedPlaceDelegate:) withObject:dict afterDelay:0.1];
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"111");
}

- (void)startedReverseGeoderWithLatitude:(double)latitude longitude:(double)longitude{
    CLLocationCoordinate2D coordinate2D;
    coordinate2D.longitude = longitude;
    coordinate2D.latitude = latitude;
    MKReverseGeocoder *geoCoder = [[MKReverseGeocoder alloc] initWithCoordinate:coordinate2D];
    geoCoder.delegate = self;
    [geoCoder start];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
//    NSLog(@"当前城市:%@",placemark.locality);
//    NSLog(@"name:%@",placemark.name);
//    NSLog(@"thoroughfare:%@",placemark.thoroughfare);
//    NSLog(@"subThoroughfare:%@",placemark.subThoroughfare);
//    NSLog(@"locality:%@",placemark.subLocality);
//    NSLog(@"administrativeArea:%@",placemark.administrativeArea);
//    NSLog(@"postalCode:%@",placemark.postalCode);
//    NSLog(@"ISOcountryCode:%@",placemark.ISOcountryCode);
//    NSLog(@"country:%@",placemark.country);
//    NSLog(@"ocean:%@",placemark.ocean);
//    NSLog(@"areasOfInterest:%@",placemark.areasOfInterest);
//    NSLog(@"the end <<<<<");
    if (placemark.thoroughfare)
    {
        NSString *strTitle = nil;
        if (placemark.locality != nil)
        {
            strTitle = [NSString stringWithFormat:@"%@ %@", placemark.locality,  placemark.thoroughfare];
        }
        else 
        {
            strTitle = [NSString stringWithFormat:@"%@",placemark.thoroughfare];
        }
        
        [_touchAnnotation setStrTitle: strTitle];
        [_mapView selectAnnotation:_touchAnnotation animated:YES];

    }
    else
    {
        [[PublicMethod sharedMethod] showAlert:@"对不起，定位失败!"];
    }
    if (_isProcessed)
    {
        _isProcessed = NO;
    }
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    [[PublicMethod sharedMethod] showAlert:@"对不起，定位失败!"];
    if (_isProcessed)
    {
        _isProcessed = NO;
    }
}


@end
