//
//  CBGaspPlaces.m
//  gasp
//
//  Created by Mark Prichard on 1/15/14.
//  Copyright (c) 2014 CloudBees. All rights reserved.
//

#import "CBGaspPlaces.h"

#define GOOGLE_API_KEY @"AIzaSyD8RPFcX_YY3-M21yGGaww2_NBPLHsjU5o"
#define GOOGLE_PLACES_SEARCH @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%@&radius=%@&types=%@&sensor=true&key=%@"
#define GOOGLE_PLACES_DETAILS @"https://maps.googleapis.com/maps/api/place/details/json?&sensor=true&key=%@&reference=%@"
#define GOOGLE_PLACES_EVENT_ADD @"https://maps.googleapis.com/maps/api/place/event/add/json?&sensor=true&key=%@"
#define GOOGLE_PLACES_EVENT_DELETE @"https://maps.googleapis.com/maps/api/place/event/delete/json?&sensor=true&key=%@"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@implementation CBGaspPlaces

+ (CBGaspPlaces *)sharedNetworkClient {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void) getGooglePlaces:(NSString *)googleType withLocation:(NSString *) location withRadius:(NSString *) radius {

    NSString *url = [NSString stringWithFormat:GOOGLE_PLACES_SEARCH, location, radius, googleType, GOOGLE_API_KEY];
    
    //Formulate the string as a URL object.
    NSURL *googleRequestURL = [[NSURL alloc] initWithString:[url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSLog(@"%@", googleRequestURL);
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(placesSearchResult:) withObject:data waitUntilDone:YES];
    });
}

-(void)placesSearchResult:(NSData *)responseData {
    if (responseData == nil)
        NSLog(@"%@", @"Google Places API call Failed");

    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    NSArray* places = [json objectForKey:@"results"];
    NSLog(@"Returned %i places", [places count]);
    //NSLog(@"Google Data: %@", places);
    
    for (int i = 0; i < [places count]; i++) {
        NSDictionary* location = [places objectAtIndex:i];
        NSString* id = [location objectForKey:@"id"];
        NSLog(@"Google Places API Id: %@", id);
        
        NSString* reference = [location objectForKey:@"reference"];
        NSLog(@"Google Places API Reference: %@", reference);
        
        NSString* latitude = [[[location objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"];
        NSString* longitude = [[[location objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"];
        NSLog(@"Co-ords = %@,%@", latitude, longitude);
        
        [self getPlaceDetails:reference];
    }
}

-(void) getPlaceDetails:(NSString *) reference {
    
    NSString *url = [NSString stringWithFormat:GOOGLE_PLACES_DETAILS, GOOGLE_API_KEY, reference];
    
    //Formulate the string as a URL object.
    NSURL *googleRequestURL = [[NSURL alloc] initWithString:[url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSLog(@"%@", googleRequestURL);
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(placesDetailsResult:) withObject:data waitUntilDone:YES];
    });
}

-(void)placesDetailsResult:(NSData *)responseData {
    if (responseData == nil)
        NSLog(@"%@", @"Google Places API call Failed");
    
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    NSDictionary* details = [json objectForKey:@"result"];
    //NSLog(@"Google Data: %@", details);
        
    NSString* website = [details objectForKey:@"website"];
    NSLog(@"Website: %@", website);
}

@end
