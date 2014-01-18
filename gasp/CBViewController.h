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
- (void)displayLocations: (NSArray *)places;
@end
