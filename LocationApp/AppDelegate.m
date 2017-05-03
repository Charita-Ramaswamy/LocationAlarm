//
//  AppDelegate.m
//  LocationApp
//
//  Created by Charita R on 23/01/17.
//  Copyright © 2017 Charita R. All rights reserved.
//

#import "AppDelegate.h"
#import "LocationManager.h"
#import "SaveOrUpdateDataModel.h"

//Google places API key: AIzaSyBbxH_MYhGdUzqKlhvydlL965Qyu_3XRiw
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GMSPlacesClient provideAPIKey:@"AIzaSyBbxH_MYhGdUzqKlhvydlL965Qyu_3XRiw"];
   
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    NSString* controllerId = @"FirstViewController";
    SaveOrUpdateDataModel* data = [[SaveOrUpdateDataModel alloc] init];
    if ([data fetchAllPlaces] > 0)
    {
        controllerId = @"SecondViewController";
    }
    UIViewController* controller = [storyboard instantiateViewControllerWithIdentifier:controllerId];
    self.window.rootViewController = controller;
    [self.window makeKeyAndVisible];
    
    NSLog(@"didFinishLaunchingWithOptions");
    
    self.shareModel = [LocationManager sharedManager];
    self.shareModel.afterResume = NO;
    
    [self.shareModel addApplicationStatusToPList:@"didFinishLaunchingWithOptions"];
    
    UIAlertView * alert;
    
    //We have to make sure that the Background App Refresh is enable for the Location updates to work in the background.
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied) {
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh"
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    } else if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted) {
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The functions of this app are limited because the Background App Refresh is disable."
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    } else {
        
        // When there is a significant changes of the location,
        // The key UIApplicationLaunchOptionsLocationKey will be returned from didFinishLaunchingWithOptions
        // When the app is receiving the key, it must reinitiate the locationManager and get
        // the latest location updates
        
        // This UIApplicationLaunchOptionsLocationKey key enables the location update even when
        // the app has been killed/terminated (Not in th background) by iOS or the user.
        
        NSLog(@"UIApplicationLaunchOptionsLocationKey : %@" , [launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]);
        if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
            
            // This "afterResume" flag is just to show that he receiving location updates
            // are actually from the key "UIApplicationLaunchOptionsLocationKey"
            self.shareModel.afterResume = YES;
            
            [self.shareModel startMonitoringLocation];
            [self.shareModel addResumeLocationToPList];
        }
    }
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey]) {
        UILocalNotification *localNotif =
        [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        
        if(localNotif){
            [self application:application didReceiveLocalNotification:localNotif];
        }
    }

    
    
    return YES;
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif
{
//    [[UIApplication sharedApplication]cancelAllLocalNotifications];
//    app.applicationIconBadgeNumber = notif.applicationIconBadgeNumber -1;
//    
//    notif.soundName = UILocalNotificationDefaultSoundName;
//    
//    [self _showAlert:[NSString stringWithFormat:@"%@",Your msg withTitle:@"Title"];
}
     
     
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"applicationDidEnterBackground");
    [self.shareModel restartMonitoringLocation];
    
    [self.shareModel addApplicationStatusToPList:@"applicationDidEnterBackground"];

    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"applicationDidBecomeActive");
    
    [self.shareModel addApplicationStatusToPList:@"applicationDidBecomeActive"];
    
    //Remove the "afterResume" Flag after the app is active again.
    self.shareModel.afterResume = NO;
    
    [self.shareModel startMonitoringLocation];

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"applicationWillTerminate");
    [self.shareModel addApplicationStatusToPList:@"applicationWillTerminate"];
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.geoligence.test.LocationApp" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"LocationApp" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"LocationApp.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}



-(void)addResumeLocationToPList{
    UIApplication* application = [UIApplication sharedApplication];
    
    NSString * appState;
    if([application applicationState]==UIApplicationStateActive)
        appState = @"UIApplicationStateActive";
    if([application applicationState]==UIApplicationStateBackground)
        appState = @"UIApplicationStateBackground";
    if([application applicationState]==UIApplicationStateInactive)
        appState = @"UIApplicationStateInactive";
    
    self.shareModel.myLocationDictInPlist = [[NSMutableDictionary alloc]init];
    [self.shareModel.myLocationDictInPlist setObject:@"UIApplicationLaunchOptionsLocationKey" forKey:@"Resume"];
    [self.shareModel.myLocationDictInPlist setObject:appState forKey:@"AppState"];
    
    NSString* time = [self getCurrentTime];
    [self.shareModel.myLocationDictInPlist setObject:time forKey:@"currTime"];
    [self.shareModel.myLocationDictInPlist setObject:[NSDate date] forKey:@"currDate"];
    
    NSString *plistName = [NSString stringWithFormat:@"LocationArray.plist"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", docDir, plistName];
    
    NSMutableDictionary *savedProfile = [[NSMutableDictionary alloc] initWithContentsOfFile:fullPath];
    
    if (!savedProfile){
        savedProfile = [[NSMutableDictionary alloc] init];
        self.shareModel.myLocationArrayInPlist = [[NSMutableArray alloc]init];
    }
    else{
        self.shareModel.myLocationArrayInPlist = [savedProfile objectForKey:@"LocationArray"];
    }
    
    if(self.shareModel.myLocationDictInPlist)
    {
        [self.shareModel.myLocationArrayInPlist addObject:self.shareModel.myLocationDictInPlist];
        [savedProfile setObject:self.shareModel.myLocationArrayInPlist forKey:@"LocationArray"];
    }
    
    if (![savedProfile writeToFile:fullPath atomically:FALSE] ) {
        NSLog(@"Couldn't save LocationArray.plist" );
    }
}



-(void)addLocationToPList:(BOOL)fromResume{
    
    UIApplication* application = [UIApplication sharedApplication];
    
    NSString * appState;
    if([application applicationState]==UIApplicationStateActive)
        appState = @"UIApplicationStateActive";
    if([application applicationState]==UIApplicationStateBackground)
        appState = @"UIApplicationStateBackground";
    if([application applicationState]==UIApplicationStateInactive)
        appState = @"UIApplicationStateInactive";
    
    self.shareModel.myLocationDictInPlist = [[NSMutableDictionary alloc]init];
    [self.shareModel.myLocationDictInPlist setObject:[NSNumber numberWithDouble:self.myLocation.latitude]  forKey:@"Latitude"];
    [self.shareModel.myLocationDictInPlist setObject:[NSNumber numberWithDouble:self.myLocation.longitude] forKey:@"Longitude"];
    [self.shareModel.myLocationDictInPlist setObject:[NSNumber numberWithDouble:self.myLocationAccuracy] forKey:@"Accuracy"];
    
    NSString* time = [self getCurrentTime];
    [self.shareModel.myLocationDictInPlist setObject:time forKey:@"currTime"];
    [self.shareModel.myLocationDictInPlist setObject:[NSDate date] forKey:@"currDate"];
    
    [self.shareModel.myLocationDictInPlist setObject:appState forKey:@"AppState"];
    
    if(fromResume)
        [self.shareModel.myLocationDictInPlist setObject:@"YES" forKey:@"AddFromResume"];
    else
        [self.shareModel.myLocationDictInPlist setObject:@"NO" forKey:@"AddFromResume"];
    
    [self.shareModel.myLocationDictInPlist setObject:[NSDate date] forKey:@"Time"];
    
    NSString *plistName = [NSString stringWithFormat:@"LocationArray.plist"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", docDir, plistName];
    
    NSMutableDictionary *savedProfile = [[NSMutableDictionary alloc] initWithContentsOfFile:fullPath];
    
    if (!savedProfile){
        savedProfile = [[NSMutableDictionary alloc] init];
        self.shareModel.myLocationArrayInPlist = [[NSMutableArray alloc]init];
    }
    else{
        self.shareModel.myLocationArrayInPlist = [savedProfile objectForKey:@"LocationArray"];
    }
    
    // NSLog(@"Dict: %@",self.shareModel.myLocationDictInPlist);
    
    if(self.shareModel.myLocationDictInPlist)
    {
        if(!self.shareModel.myLocationArrayInPlist){
            self.shareModel.myLocationArrayInPlist = [[NSMutableArray alloc]init];
        }
        [self.shareModel.myLocationArrayInPlist addObject:self.shareModel.myLocationDictInPlist];
        [savedProfile setObject:self.shareModel.myLocationArrayInPlist forKey:@"LocationArray"];
    }
    
    if (![savedProfile writeToFile:fullPath atomically:FALSE] ) {
        NSLog(@"Couldn't save LocationArray.plist" );
    }
}



-(void)addApplicationStatusToPList:(NSString*)applicationStatus{
    UIApplication* application = [UIApplication sharedApplication];
    
    NSString * appState;
    if([application applicationState]==UIApplicationStateActive)
        appState = @"UIApplicationStateActive";
    if([application applicationState]==UIApplicationStateBackground)
        appState = @"UIApplicationStateBackground";
    if([application applicationState]==UIApplicationStateInactive)
        appState = @"UIApplicationStateInactive";
    
    self.shareModel.myLocationDictInPlist = [[NSMutableDictionary alloc]init];
    [self.shareModel.myLocationDictInPlist setObject:applicationStatus forKey:@"applicationStatus"];
    [self.shareModel.myLocationDictInPlist setObject:appState forKey:@"AppState"];
    
    NSString* time = [self getCurrentTime];
    [self.shareModel.myLocationDictInPlist setObject:time forKey:@"currTime"];
    [self.shareModel.myLocationDictInPlist setObject:[NSDate date] forKey:@"currDate"];
    
    
    NSString *plistName = [NSString stringWithFormat:@"LocationArray.plist"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", docDir, plistName];
    
    NSMutableDictionary *savedProfile = [[NSMutableDictionary alloc] initWithContentsOfFile:fullPath];
    
    if (!savedProfile){
        savedProfile = [[NSMutableDictionary alloc] init];
        self.shareModel.myLocationArrayInPlist = [[NSMutableArray alloc]init];
    }
    else{
        self.shareModel.myLocationArrayInPlist = [savedProfile objectForKey:@"LocationArray"];
    }
    
    if(self.shareModel.myLocationDictInPlist)
    {
        if(!self.shareModel.myLocationArrayInPlist){
            self.shareModel.myLocationArrayInPlist = [[NSMutableArray alloc]init];
        }
        [self.shareModel.myLocationArrayInPlist addObject:self.shareModel.myLocationDictInPlist];
        [savedProfile setObject:self.shareModel.myLocationArrayInPlist forKey:@"LocationArray"];
    }
    
    if (![savedProfile writeToFile:fullPath atomically:FALSE] ) {
        NSLog(@"Couldn't save LocationArray.plist" );
    }
}


-(NSString*)getCurrentTime{
    NSDate * now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm:ss"];
    NSString *newDateString = [outputFormatter stringFromDate:now];
    NSString *stringToWrite = newDateString;
    return stringToWrite;
}



-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"%@", error.description);
}

@end
