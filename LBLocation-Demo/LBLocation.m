//
//  LBLocation.m
//  Bottle
//
//  Created by Lucian Boboc on 9/16/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import "LBLocation.h"
#import <AddressBookUI/AddressBookUI.h>

#define MAX_LATITUDE -90.0f
#define MIN_LATITUDE 90.0f

#define MAX_LONGITUDE -180.f
#define MIN_LONGITUDE 180.0


#define kLocationServicesDisabled @"Location services are disabled in Settings/Privacy"
#define kLocationServicesDisabledByTheUser @"You have denied the request for this app to use location services, please go to Settings/Privacy and select ON for this app"


@interface LBLocation () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *myLocation;
@property (copy, nonatomic) LocationBlock locationBlock;
@end

@implementation LBLocation

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] removeObserver: self name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
}

//- (id) init
//{
//    self = [super init];
//    if(self)
//    {
//        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(startLocationServices) name:UIApplicationDidBecomeActiveNotification object: [UIApplication sharedApplication]];
//        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(stopLocationServices) name:UIApplicationWillResignActiveNotification object: [UIApplication sharedApplication]];
//        [self configureLocationManager];
//    }
//    return self;
//}

- (id) initWithLocationUpdateBlock: (LocationBlock) locationBlock
{
    self = [self init];
    if(self)
    {
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(startLocationServices) name:UIApplicationDidBecomeActiveNotification object: [UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(stopLocationServices) name:UIApplicationWillResignActiveNotification object: [UIApplication sharedApplication]];

        self.locationBlock = locationBlock;
        
        [self startLocationServices];
    }
    return self;
}


- (void) configureLocationManager
{
    if(![CLLocationManager locationServicesEnabled])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Message" message: kLocationServicesDisabled delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Message" message: kLocationServicesDisabledByTheUser delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
            [alert show];
        }
        
        if(!self.locationManager)
            self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.distanceFilter = 10;
    }
}

- (void) startLocationServices
{
    [self configureLocationManager];
    [self.locationManager startUpdatingLocation];
}

- (void) stopLocationServices
{
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
}







#pragma mark - fit all pins on the map

+ (void) fitAllPinsOnTheMap: (MKMapView *) mapView
{
//    MKMapRect zoomRect = MKMapRectNull;
//    for (id <MKAnnotation> annotation in mapView.annotations)
//    {
//        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
//        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
//        if (MKMapRectIsNull(zoomRect)) {
//            zoomRect = pointRect;
//        } else {
//            zoomRect = MKMapRectUnion(zoomRect, pointRect);
//        }
//    }
//    [mapView setVisibleMapRect: zoomRect animated:YES];
    
    CLLocationDegrees maxLat = MAX_LATITUDE;
    CLLocationDegrees maxLon = MAX_LONGITUDE;
    CLLocationDegrees minLat = MIN_LATITUDE;
    CLLocationDegrees minLon = MIN_LONGITUDE;
    
    for (id <MKAnnotation> annotation in mapView.annotations) {
        CLLocationDegrees lat = annotation.coordinate.latitude;
        CLLocationDegrees lon = annotation.coordinate.longitude;
        
        maxLat = MAX(maxLat, lat);
        maxLon = MAX(maxLon, lon);
        minLat = MIN(minLat, lat);
        minLon = MIN(minLon, lon);
    }
    MKCoordinateRegion region;
    region.center.latitude     = (maxLat + minLat) / 2;
    region.center.longitude    = (maxLon + minLon) / 2;
    region.span.latitudeDelta  = maxLat - minLat + 0.05;
    region.span.longitudeDelta = maxLon - minLon + 0.05;
    
    [mapView setRegion:region animated:NO];
}

















#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"%@",NSStringFromSelector(_cmd));
    // If it's a relatively recent event, turn off updates to save power
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        CGFloat latitude = location.coordinate.latitude;
        CGFloat longitude = location.coordinate.longitude;
        self.myLocation = [[CLLocation alloc] initWithLatitude: latitude longitude: longitude];
        if(location)
        {
            if(self.locationBlock)
            {
                self.locationBlock(self.myLocation);
                [self stopLocationServices];
            }
        }
    }
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@",error.localizedDescription);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message:[self getErrorMessageFromError: error] delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
    [alert show];
    if(self.locationBlock)
        self.locationBlock(nil);
}



- (NSString *) getErrorMessageFromError: (NSError *) error
{
    switch (error.code) {
        case kCLErrorLocationUnknown:
            return @"The location manager was unable to obtain a location value right now.";
            break;
        case kCLErrorDenied:
            return @"Access to the location service was denied by the user.";
            break;
        case kCLErrorNetwork:
            return @"The network is unavailable or a network error occurred.";
            break;
        case kCLErrorHeadingFailure:
            return @"The heading could not be determined.";
            break;
        case kCLErrorRegionMonitoringDenied:
            return @"Access to the region monitoring service was denied by the user.";
            break;
        case kCLErrorRegionMonitoringFailure:
            return @"A registered region cannot be monitored.";
            break;
        case kCLErrorRegionMonitoringSetupDelayed:
            return @"Core Location could not initialize the region monitoring feature immediately.";
            break;
        case kCLErrorRegionMonitoringResponseDelayed:
            return @"Core Location will deliver events but they may be delayed.";
            break;
        case kCLErrorGeocodeFoundNoResult:
            return @"The geocode request yielded no result.";
            break;
        case kCLErrorGeocodeFoundPartialResult:
            return @"The geocode request yielded a partial result.";
            break;
        case kCLErrorGeocodeCanceled:
            return @"The geocode request was canceled.";
            break;
        case kCLErrorDeferredFailed:
            return @"The location manager did not enter deferred mode for an unknown reason.";
            break;
        case kCLErrorDeferredNotUpdatingLocation:
            return @"The location manager did not enter deferred mode because location updates were already disabled or paused.";
            break;
        case kCLErrorDeferredAccuracyTooLow:
            return @"Deferred mode is not supported for the requested accuracy.";
            break;
        case kCLErrorDeferredDistanceFiltered:
            return @"Deferred mode does not support distance filters.";
            break;
        case kCLErrorDeferredCanceled:
            return @"The request for deferred updates was canceled by a subsequent call.";
            break;
            
        default:
            return error.localizedDescription;
            break;
    }
}























#pragma mark - reverse geocoding

- (void) reverseGeocodeCurrentLocationWithCompletionBlock:(ReverseGeocodeBlock)reverseGeocodingBlock
{
    if(!self.myLocation)
    {
#if DEBUG
        NSLog(@"*** reverseGeocodeCurrentLocationWithCompletionBlock called, current location is nil  ***");
#endif
        if(reverseGeocodingBlock)
            reverseGeocodingBlock(nil);
        return;
    }
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation: self.myLocation completionHandler:^(NSArray *placemarks, NSError *error){
        if([placemarks count] > 0)
        {
            CLPlacemark *placemark = [placemarks objectAtIndex: 0];
#if DEBUG
            NSLog(@"*** reverseGeocodeCurrentLocationWithCompletionBlock called, placemark: %@  ***",placemark);
#endif
            if(reverseGeocodingBlock)
                reverseGeocodingBlock(placemark);
        }
        else
        {
#if DEBUG
            NSLog(@"*** reverseGeocodeCurrentLocationWithCompletionBlock called, placemark count is 0 ***");
#endif
            if(reverseGeocodingBlock)
                reverseGeocodingBlock(nil);
        }
    }];
}





+ (void) reverseGeocodeLocation: (CLLocation *) location completionBlock: (ReverseGeocodeBlock) reverseGeocodingBlock
{
    if(!location)
    {
#if DEBUG
        NSLog(@"*** reverseGeocodeLocation:completionBlock: called, location parameter is nil ***");
#endif
        if(reverseGeocodingBlock)
            reverseGeocodingBlock(nil);
        return;
    }
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation: location completionHandler:^(NSArray *placemarks, NSError *error){
        if([placemarks count] > 0)
        {
            CLPlacemark *placemark = [placemarks objectAtIndex: 0];
#if DEBUG
            NSLog(@"*** reverseGeocodeLocation:completionBlock: called, placemark: %@ ***",placemark);
#endif
            if(reverseGeocodingBlock)
                reverseGeocodingBlock(placemark);
        }
        else
        {
#if DEBUG
            NSLog(@"*** reverseGeocodeLocation:completionBlock: called, placemark count is 0 ***");
#endif
            if(reverseGeocodingBlock)
                reverseGeocodingBlock(nil);
        }
    }];
}


+ (NSString *) addressStringFromPlacemark: (CLPlacemark *) placemark
{
    if(!placemark)
        return nil;
    
    NSDictionary *dictionaryAddress = [placemark addressDictionary];
    if(!dictionaryAddress)
        return nil;

    NSString *addressString = ABCreateStringWithAddressDictionary(dictionaryAddress, YES);
    return addressString;
}


















#pragma mark - forward geocoding

- (void) geocodeAddressString:(NSString *)addressString completionBlock:(LocationBlock)locationBlock
{
    if(!addressString)
    {
#if DEBUG
        NSLog(@"*** geocodeAddressString:completionBlock: called, address parameter is nil ***");
#endif
        if(locationBlock)
            locationBlock(nil);
        return;
    }

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString: addressString completionHandler:^(NSArray *placemarks, NSError *error) {
        if([placemarks count] > 0)
        {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            CLLocation *location = placemark.location;
#if DEBUG
            NSLog(@"*** geocodeAddressString:completionBlock: called, location: %@ ***",location);
#endif
            
            if(locationBlock)
                locationBlock(location);
        }
        else
        {
#if DEBUG
            NSLog(@"*** geocodeAddressString:completionBlock: called, placemark count is 0 ***");
#endif
            if(locationBlock)
                locationBlock(nil);
        }
    }];
}



- (void) geocodeAddressDictionary:(NSDictionary *)dictionary completionBlock:(LocationBlock)locationBlock
{
    if(!dictionary)
    {
#if DEBUG
        NSLog(@"*** geocodeAddressDictionary:completionBlock: called, address parameter is nil ***");
#endif
        if(locationBlock)
            locationBlock(nil);
        return;
    }

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressDictionary: dictionary completionHandler:^(NSArray *placemarks, NSError *error) {
        if([placemarks count] > 0)
        {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            CLLocation *location = placemark.location;
#if DEBUG
            NSLog(@"*** geocodeAddressDictionary:completionBlock: called, location: %@ ***",location);
#endif
            if(locationBlock)
            locationBlock(location);
        }
        else
        {
#if DEBUG
            NSLog(@"*** geocodeAddressDictionary:completionBlock: called, placemark count is 0 ***");
#endif
            if(locationBlock)
            locationBlock(nil);
        }
    }];
}




#pragma mark - validate coordinates

+ (BOOL) validCoordinates: (CLLocationCoordinate2D) coordinates
{
    if(coordinates.latitude >= -90 && coordinates.latitude <= 90)
    {
        if(coordinates.longitude >= -180 && coordinates.longitude <= 180)
            return YES;
        else
            return NO;
    }
    else
        return NO;
}



@end
