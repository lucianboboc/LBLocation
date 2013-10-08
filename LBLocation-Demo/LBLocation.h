//
//  LBLocation.h
//  Bottle
//
//  Created by Lucian Boboc on 9/16/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//


/****** TO USE THIS CLASS IMPORT THE CoreLocation FRAMEWORK AND AddressBookUI FRAMEWORK ******/

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

typedef void(^LocationBlock)(CLLocation *location);
typedef void(^ReverseGeocodeBlock)(CLPlacemark *placemark);

@interface LBLocation : NSObject

//****** INIT, START and STOP LOCATION SERVICES ******/
- (id) initWithLocationUpdateBlock: (LocationBlock) locationBlock;
- (void) startLocationServices;
- (void) stopLocationServices;

//****** FIT ALL PINS ON A MAP *******/
+ (void) fitAllPinsOnTheMap: (MKMapView *) mapView;



/****** REVERSE GEOCODING ******/
- (void) reverseGeocodeCurrentLocationWithCompletionBlock: (ReverseGeocodeBlock) reverseGeocodingBlock;
+ (void) reverseGeocodeLocation: (CLLocation *) location completionBlock: (ReverseGeocodeBlock) reverseGeocodingBlock;

// to get a dictionary from the CLPlacemark object call [placemark addressDictionary];
// to get areas of interest from the CLPlacemark object call [placemark areasOfInterest];
+ (NSString *) addressStringFromPlacemark: (CLPlacemark *) placemark;




/****** FORWARD GEOCODING ******/
- (void) geocodeAddressString: (NSString *) addressString completionBlock: (LocationBlock) locationBlock;

/******
 The keys in this dictionary are those defined by the Address Book framework and used to access address information for a person.
 For a list of the strings that can be in this dictionary:
 const ABPropertyID kABPersonAddressProperty;
 const CFStringRef kABPersonAddressStreetKey;
 const CFStringRef kABPersonAddressCityKey;
 const CFStringRef kABPersonAddressStateKey;
 const CFStringRef kABPersonAddressZIPKey;
 const CFStringRef kABPersonAddressCountryKey;
 const CFStringRef kABPersonAddressCountryCodeKey;
******/

/****** For more info see the "Address Property" constants in ABPerson Reference ******/
- (void) geocodeAddressDictionary: (NSDictionary *) dictionary completionBlock: (LocationBlock) locationBlock;

// call this method to validate coordinates before setting a region, if coordinates are not valid the app will crash
+ (BOOL) validCoordinates: (CLLocationCoordinate2D) coordinates;


@end
