//
//  ViewController.m
//  LocationApp
//
//  Created by Charita R on 23/01/17.
//  Copyright © 2017 Charita R. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SaveOrUpdateDataModel.h"

@interface ViewController ()
{
    CLLocationManager* locationManager;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    SaveOrUpdateDataModel* fetchData = [[SaveOrUpdateDataModel alloc] init];
//    int a  = [fetchData fetchAllPlaces];
   
//    AudioServicesPlaySystemSound (1003);
    
//    
//    NSURL *fileURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/SentMessage.caf"]; // see list below
//    SystemSoundID soundID;
//    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)fileURL,&soundID);
//    AudioServicesPlaySystemSound(soundID);
//    
//    // Construct URL to sound file
//    NSString *path = [NSString stringWithFormat:@"%@/drum01.mp3", [[NSBundle mainBundle] resourcePath]];
//    NSURL *soundUrl = [NSURL fileURLWithPath:path];
//    
//    // Create audio player object and initialize with URL to sound
//    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    
    NSLog(@"Destination latitude: %f", [[NSUserDefaults standardUserDefaults] doubleForKey:@"destinationLatitude"]);//12.410876
    NSLog(@"Destination longitude: %f", [[NSUserDefaults standardUserDefaults] doubleForKey:@"destinationLongitude"]);//76.693244
    
    NSLog(@"Current latitude: %f", [[NSUserDefaults standardUserDefaults] doubleForKey:@"currentLatitude"]);
    NSLog(@"Current longitude: %f", [[NSUserDefaults standardUserDefaults] doubleForKey:@"currentLongitude"]);
    
//    locationManager = [[CLLocationManager alloc] init];
//    locationManager.delegate = self;
//    if([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
//        {
//            [locationManager requestAlwaysAuthorization];
//        }
//    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    locationManager.distanceFilter = 50.0;
//    [locationManager startUpdatingLocation];
    // Do any additional setup after loading the view, typically from a nib.
}



//CLLocationCoordinate2D MKCoordinateOffsetFromCoordinate(CLLocationCoordinate2D coordinate, CLLocationDistance offsetLatMeters, CLLocationDistance offsetLongMeters) {
//    MKMapPoint offsetPoint = MKMapPointForCoordinate(coordinate);
//    
//    CLLocationDistance metersPerPoint = MKMetersPerMapPointAtLatitude(coordinate.latitude);
//    double latPoints = offsetLatMeters / metersPerPoint;
//    offsetPoint.y -= latPoints;
//    double longPoints = offsetLongMeters / metersPerPoint;
//    offsetPoint.x -= longPoints;
//    
//    CLLocationCoordinate2D offsetCoordinate = MKCoordinateForMapPoint(offsetPoint);
//    
//    NSLog(@"Dest latitude %f", coordinate.latitude);//12.927495
//    NSLog(@"Dest longitude %f", coordinate.longitude);//77.680966
//    NSLog(@"Offset longitude %f", offsetCoordinate.longitude);//77.682821
//    NSLog(@"Offset latitude %f", offsetCoordinate.latitude);//12.925687
//    
//    return offsetCoordinate;
//}


/*-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    NSLog(@"%@", locations);
    CLLocation* locationData = [locations lastObject];

    [[NSUserDefaults standardUserDefaults] setDouble:locationData.coordinate.latitude forKey:@"currentLatitude"];
    [[NSUserDefaults standardUserDefaults]setDouble:locationData.coordinate.longitude forKey:@"currentLongitude"];
    
    double lat = [[NSUserDefaults standardUserDefaults] doubleForKey:@"currentLatitude"];
    double lng = [[NSUserDefaults standardUserDefaults] doubleForKey:@"currentLongitude"];
    
     [[NSUserDefaults standardUserDefaults] synchronize];
    
    CLLocation* destinationLatitudeLongitude = [[CLLocation alloc] initWithLatitude:[[NSUserDefaults standardUserDefaults] doubleForKey:@"destinationLatitude"] longitude:[[NSUserDefaults standardUserDefaults] doubleForKey:@"destinationLongitude"]];
    double metersAway = [locationData distanceFromLocation:destinationLatitudeLongitude];
    
//    if(metersAway == 250.0){
//        UILocalNotification *notification = [[UILocalNotification alloc] init];
//        notification.fireDate = [[NSDate date] dateByAddingTimeInterval:60*60*24];
//        notification.alertBody = @"Just 250 meters away form your destination :-)";
//        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
//    }
//    [locationManager stopUpdatingLocation];
}*/

-(void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)wasCancelled:(GMSAutocompleteViewController *)viewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewController:(GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(NSError *)error{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Error: %@", [error description]);
}

-(void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"Place Name: %@", place.name);
    NSLog(@"Place Address: %@", place.formattedAddress);
    NSLog(@"Place Latitude: %f", place.coordinate.latitude);
    NSLog(@"Place Longitude: %f", place.coordinate.longitude);
    
//    [[NSUserDefaults standardUserDefaults] setObject:place forKey:@"placeData"];
    
    SaveOrUpdateDataModel * saveData = [[SaveOrUpdateDataModel alloc] init];
    [saveData saveDestinationPlaceInfo:place.name withAddress:place.formattedAddress withLat:[NSNumber numberWithDouble:place.coordinate.latitude] withLong:[NSNumber numberWithDouble:place.coordinate.longitude]];
    
    [[NSUserDefaults standardUserDefaults] setDouble:place.coordinate.latitude forKey:@"destinationLatitude"];
    [[NSUserDefaults standardUserDefaults]setDouble:place.coordinate.longitude forKey:@"destinationLongitude"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
//    NSLog(@"Place attributions: %@", place.attributions);//is always null
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getPlacesAutocomplete:(id)sender {
    GMSAutocompleteViewController* autoController = [[GMSAutocompleteViewController alloc] init];
    autoController.delegate = self;
    [self presentViewController:autoController animated:YES completion:nil];
}

@end
