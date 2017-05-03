//
//  ViewController.h
//  LocationApp
//
//  Created by Charita R on 23/01/17.
//  Copyright © 2017 Charita R. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GooglePlaces/GooglePlaces.h>

@interface ViewController : UIViewController<CLLocationManagerDelegate, GMSAutocompleteViewControllerDelegate>

- (IBAction)getPlacesAutocomplete:(id)sender;

@end

