//
//  GoogleMapDirectionService.m
//  RLandApp
//
//  Created by Vikhyath on 12/16/15.
//  Copyright © 2015 Self. All rights reserved.


#import "GoogleMapDirectionService.h"

@implementation GoogleMapDirectionService{
  @private
  BOOL _sensor;
  BOOL _alternatives;
  NSURL *_directionsURL;
  NSArray *_waypoints;
}

static NSString *kMDDirectionsURL = @"http://maps.googleapis.com/maps/api/directions/json? to ";

- (void)setDirectionsQuery:(NSDictionary *)query withSelector:(SEL)selector
              withDelegate:(id)delegate{
    
  NSArray *waypoints = [query objectForKey:@"waypoints"];
    
  NSString *origin = [waypoints objectAtIndex:0];
  NSUInteger waypointCount = [waypoints count];
    //destination
  int destinationPos = waypointCount -1;
  NSString *destination = [waypoints objectAtIndex:destinationPos];
    
  NSString *sensor = [query objectForKey:@"sensor"];
  NSMutableString *url = [NSMutableString stringWithFormat:@"%@&origin=%@&destination=%@&sensor=%@",kMDDirectionsURL,origin,destination, sensor];
    
  if(waypointCount>2) {
    [url appendString:@"&waypoints=optimize:true"];
    int wpCount = waypointCount-2;
    for(int i=1;i<wpCount;i++){
      [url appendString: @"|"];
      [url appendString:[waypoints objectAtIndex:i]];
    }
  }
    url = [url stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
    _directionsURL = [NSURL URLWithString:url];
  [self retrieveDirections:selector withDelegate:delegate];
}


- (void)retrieveDirections:(SEL)selector withDelegate:(id)delegate{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData* data =[NSData dataWithContentsOfURL:_directionsURL];
      [self fetchedData:data withSelector:selector withDelegate:delegate];
    });
}

- (void)fetchedData:(NSData *)data withSelector:(SEL)selector withDelegate:(id)delegate{
    NSError* error;
  NSDictionary *json = [NSJSONSerialization
                        JSONObjectWithData:data
                                   options:kNilOptions
                                     error:&error];
    
  [delegate performSelector:selector withObject:json];
}

@end
