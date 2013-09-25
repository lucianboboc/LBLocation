LBLocation
==========

LBLocation class will help you get the user location very easy and make forward and reverse geocoding.
 
 How to use LBLocation class into your project
==========
 
 1. Import <code><CoreLocation/CoreLocation.h></code>, <code><MapKit/MapKit.h></code> and <code><AddressBookUI/AddressBookUI.h></code> frameworks.
 2. Create the LBLocation object using <code>initWithLocationUpdateBlock:</code>.
  
 The completionBlock will be called with the <code>CLLocation</code> value.
 
 In case of error the completionBlock is called with a <code>nil</code> value.
 
 The LBLocation class uses <code>NSNotificationCenter</code> and calls the <code>startLocationServices</code> method when the <code>UIApplicationDidBecomeActiveNotification</code> notification is received. It also calls the <code>stopLocationServices</code> when the <code>UIApplicationWillResignActiveNotification</code> notification is received.

 Reverse Geocoding
==========

 You can use <code>reverseGeocodeCurrentLocationWithCompletionBlock:</code> and <code>reverseGeocodeLocation:completionBlock:</code> methods and the completion block will be called with a <code>CLPlacemark</code> object or <code>nil</code> value.
 You can get a string with the address from the CLPlacemark object using the <code>addressStringFromPlacemark:</code> method.


 Forward Geocoding
==========

 You can use the <code>geocodeAddressString:completionBlock:</code> and <code>geocodeAddressDictionary:completionBlock:</code> methdos,pass a string or dictionary with the address and the completion block will be called with a <code>CLLocation</code> object or <code>nil</code> value.

EXAMPLE
==========
```
     __weak ViewController *weakSelf = self;
    self.location = [[LBLocation alloc] initWithLocationUpdateBlock:^(CLLocation *location) {
        weakSelf.myLocation = location;
    }];

```


LICENSE
==========

This content is released under the MIT License https://github.com/lucianboboc/LBFacebook/blob/master/LICENSE.md

 Enjoy!

