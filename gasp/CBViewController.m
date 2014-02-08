//
//  CBViewController.m
//  gasp
//
//  Created by Mark Prichard on 1/8/14.
//  Copyright (c) 2014 CloudBees. All rights reserved.
//

#import "CBViewController.h"
#import "CBGaspRestaurants.h"
#import "CBGaspReviews.h"
#import "CBGaspUsers.h"
#import "CBGaspPlaces.h"
#import "CBAddReviewDelegate.h"
#import "CBAddUserDelegate.h"
#import "CBAddRestaurantDelegate.h"

#import <GoogleMaps/GoogleMaps.h>

#define GOOGLE_TYPES @"Restaurant|food|cafe"

@interface CBViewController ()

@end

@implementation CBViewController {
    GMSMapView *mapView_;
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    CLLocation *location;
    NSArray *restaurants;
    NSArray *reviews;
    NSArray *users;
}

static NSString *const HOST = @"http://gasp2.partnerdemo.cloudbees.net";

- (void)loadInitialRestaurants {
    CBGaspRestaurants *client = [CBGaspRestaurants sharedNetworkClient];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *data = [client listRestaurants:HOST];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data != nil) {
                restaurants = data;
            } else {
                NSLog(@"Unable to get restaurant data");
            }
        });
    });
}

- (void)loadInitialReviews {
    CBGaspReviews *client = [CBGaspReviews sharedNetworkClient];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *data = [client listReviews:HOST];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data != nil) {
                reviews = data;
            } else {
                NSLog(@"Unable to get review data");
            }
        });
    });
}

- (void)loadInitialUsers {
    CBGaspUsers *client = [CBGaspUsers sharedNetworkClient];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *data = [client listUsers:HOST];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data != nil) {
                users = data;
            } else {
                NSLog(@"Unable to get user data");
            }
        });
    });
}

- (void)addReview {
    CBGaspReviews *client = [[CBGaspReviews alloc] init];
    CBAddReviewDelegate *addReviewHandler = [[CBAddReviewDelegate alloc] init];
    [client addReview:HOST withDelegate:addReviewHandler withUser:@1 withRestaurant:@1 withStar:@5 withComments:@"Great"];

}

- (void)addUser {
    CBGaspUsers *client = [[CBGaspUsers alloc] init];
    CBAddUserDelegate *addUserHandler = [[CBAddUserDelegate alloc] init];
    [client AddUser:HOST withDelegate:addUserHandler withName:@"A N Other"];
}

- (void)addRestaurant {
    CBGaspRestaurants *client = [[CBGaspRestaurants alloc] init];
    CBAddRestaurantDelegate *addRestaurantHandler = [[CBAddRestaurantDelegate alloc] init];
    [client AddRestaurant:HOST withDelegate:addRestaurantHandler withName:@"Restaurant" withWebsite:@"www.restaruant.com" withPlacesId:@"1234567890"];
}

- (void)viewDidLoad
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [locationManager startMonitoringSignificantLocationChanges];
    
    geocoder = [[CLGeocoder alloc] init];
    
    [self loadInitialRestaurants];
    [self loadInitialReviews];
    [self loadInitialUsers];
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.3750274
                                                            longitude:-122.1142916
                                                                 zoom:15];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.settings.compassButton = YES;
    mapView_.settings.myLocationButton = YES;
    mapView_.myLocationEnabled = YES;
    mapView_.delegate = self;
    
    self.view = mapView_;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:@"Failed to Get Your Location"
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    location = newLocation;
    
    // Reverse Geocoding
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            NSLog(@"Current Location: %@ %@ %@ %@ %@ %@",
                                 placemark.subThoroughfare,
                                 placemark.thoroughfare,
                                 placemark.locality,
                                 placemark.administrativeArea,
                                 placemark.postalCode,
                                 placemark.country);
            
            NSString *latlng = [NSString stringWithFormat:@"%f,%f",
                                location.coordinate.latitude,
                                location.coordinate.longitude];
            NSString *radius = [NSString stringWithFormat:@"%i", 500];
            
            CBGaspPlaces* places = [CBGaspPlaces sharedNetworkClient];
            [places getGooglePlaces:GOOGLE_TYPES
                       withLocation:latlng
                         withRadius:radius
                       withCallback:^(NSDictionary *data, NSError *error) {
                           @try {
                               if (error != nil) {
                                   NSLog(@"Google Places API Error: %@", error);
                               } else {
                                   NSArray* places = [data objectForKey:@"results"];
                                   NSLog(@"Returned %lu places", (unsigned long)[places count]);
                                   
                                   for (int i = 0; i < [places count]; i++) {
                                       NSDictionary* place = [places objectAtIndex:i];
                                       NSString* id = [place objectForKey:@"id"];
                                       //NSLog(@"Google Places API Id: %@", id);
                                       
                                       CLLocationCoordinate2D position = CLLocationCoordinate2DMake(
                                        [[[[place objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] doubleValue],
                                        [[[[place objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] doubleValue]
                                       );
                                       
                                       GMSMarker *marker = [GMSMarker markerWithPosition:position];
                                       marker.title = [place objectForKey:@"name"];
                                       marker.map = mapView_;
                                       marker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
                                       
                                       for (int j = 0; j < [restaurants count]; j++) {
                                           if ([[[restaurants objectAtIndex:j] valueForKey:@"placesId"] isEqualToString:id]) {
                                               marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
                                               break;
                                           }
                                       }
                                   }
                               }
                           }
                           @catch (NSException *exception) {
                               NSLog(@"%@", exception);
                           }
                       }];
            
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    }];
}

- (void)displayLocations: (NSArray *)places
{
    return;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView
didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    NSLog(@"You tapped at %f,%f", coordinate.latitude, coordinate.longitude);
}

@end
