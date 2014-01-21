//
//  CBViewController.h
//  gasp
//
//  Created by Mark Prichard on 1/8/14.
//  Copyright (c) 2014 CloudBees. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface CBViewController : UIViewController<GMSMapViewDelegate, CLLocationManagerDelegate>
- (void)loadInitialRestaurants;
- (void)loadInitialReviews;
- (void)loadInitialUsers;
- (void)viewDidLoad;
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;
- (void)displayLocations: (NSArray *)places;
- (void)didReceiveMemoryWarning;
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate;
@end
