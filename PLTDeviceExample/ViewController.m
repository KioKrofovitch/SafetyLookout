//
//  ViewController.m
//  PLTDeviceExample
//
//  Created by Davis, Morgan on 9/12/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "ViewController.h"
#import "PLTDevice.h"
#import <CoreLocation/CoreLocation.h>


@interface ViewController () <PLTDeviceConnectionDelegate, PLTDeviceInfoObserver>

- (void)newDeviceAvailableNotification:(NSNotification *)notification;
- (void)startFreeFallResetTimer;
- (void)stopFreeFallResetTimer;
- (void)freeFallResetTimer:(NSTimer *)theTimer;
- (void)startTapsResetTimer;
- (void)stopTapsResetTimer;
- (void)tapsResetTimer:(NSTimer *)theTimer;
- (IBAction)calibrateOrientationButton:(id)sender;

@property(nonatomic, strong)	PLTDevice				*device;
@property(nonatomic, strong)	NSTimer					*freeFallResetTimer;
@property(nonatomic, strong)	NSTimer					*tapsResetTimer;
@property(nonatomic, strong)	IBOutlet UIProgressView	*headingProgressView;
@property(nonatomic, strong)	IBOutlet UIProgressView	*pitchProgressView;
@property(nonatomic, strong)	IBOutlet UIProgressView	*rollProgressView;
@property(nonatomic, strong)	IBOutlet UILabel		*headingLabel;
@property(nonatomic, strong)	IBOutlet UILabel		*pitchLabel;
@property(nonatomic, strong)	IBOutlet UILabel		*rollLabel;
@property(nonatomic, strong)	IBOutlet UILabel		*wearingStateLabel;
@property(nonatomic, strong)	IBOutlet UILabel		*mobileProximityLabel;
@property(nonatomic, strong)	IBOutlet UILabel		*pcProximityLabel;
@property(nonatomic, strong)	IBOutlet UILabel		*tapsLabel;
@property(nonatomic, strong)	IBOutlet UILabel		*pedometerLabel;
@property(nonatomic, strong)	IBOutlet UILabel		*freeFallLabel;
@property(nonatomic, strong)	IBOutlet UILabel		*magnetometerCalLabel;
@property(nonatomic, strong)	IBOutlet UILabel		*gyroscopeCalLabel;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocationManager *locationGet;


@end


@implementation ViewController


// ****************************** START KELLY'S CHANGES  *****************************

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startStandardUpdates];
}

- (void)startStandardUpdates
{
    
    // Create the location manager if this object does not
    // already have one.
    if (nil == self.locationManager)
        self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // Set a movement threshold for new events.
    self.locationManager.distanceFilter = 50;
    [self.locationManager startUpdatingLocation];
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager

     didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    gLatitude=location.coordinate.latitude;
    gLongitude=location.coordinate.longitude;
    
    if (abs(howRecent) < 10.0) {
        // If the event is recent, do something with it.
        [self SendDataToWeb: gLatitude: gLongitude: 1 ];
        gLatitude=location.coordinate.latitude;
        gLongitude=location.coordinate.longitude;
        self.pitchLabel.text = [NSString stringWithFormat:@"%.6fº", location.coordinate.latitude];
		self.rollLabel.text = [NSString stringWithFormat:@"%.6fº", location.coordinate.longitude];
     //   NSLog(@"latitude %+.6f, longitude %+.6f\n",
       //       location.coordinate.latitude,
         //     location.coordinate.longitude);
    }

    //Send to packaging...(add args to pass along as well?)
    NSLog(@"ReturningFromLocationCall");
//    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:2];
//    [array addObject:[NSNumber numberWithDouble:location.coordinate.latitude]];
//    [array addObject:[NSNumber numberWithDouble:location.coordinate.longitude]];
//    return array;
    }

- (NSMutableArray *)locationGet:(CLLocationManager *)manager
    getLocations:(NSMutableArray*)locations {
    CLLocation* location = [locations lastObject];
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:2];
    [array addObject:[NSNumber numberWithDouble:location.coordinate.latitude]];
    [array addObject:[NSNumber numberWithDouble:location.coordinate.longitude]];
    NSLog(@"LatitudeQuintana: %f",location.coordinate.latitude);
    return array;
}


// ****************************** END KELLY'S CHANGES  *****************************

#pragma mark - Private

- (void)newDeviceAvailableNotification:(NSNotification *)notification
{
	NSLog(@"newDeviceAvailableNotification: %@", notification);
	
	if (!self.device) {
		self.device = notification.userInfo[PLTDeviceNewDeviceNotificationKey];
		self.device.connectionDelegate = self;
		[self.device openConnection];
	}
}

- (void)startFreeFallResetTimer
{
	// currrently free fall is only reported as info indicating isInFreeFall, immediately followed by info indicating !isInFreeFall (during is not yet supported)
	// so to make sure the user sees a visual indication of the device having been in/is in free fall, a timer is used to display "Free Fall? yes" for three seconds.
	
	[self stopFreeFallResetTimer];
	self.freeFallResetTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(freeFallResetTimer:) userInfo:nil repeats:NO];
}

- (void)stopFreeFallResetTimer
{
	if ([self.freeFallResetTimer isValid]) {
		[self.freeFallResetTimer invalidate];
		self.freeFallResetTimer = nil;
	}
}

- (void)freeFallResetTimer:(NSTimer *)theTimer
{
	self.freeFallLabel.text = @"no";
}

- (void)startTapsResetTimer
{
	// since taps are only reported in one brief info update, a timer is used to display the most recent taps for three seconds.
	
	[self stopTapsResetTimer];
	self.tapsResetTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(tapsResetTimer:) userInfo:nil repeats:NO];
}

- (void)stopTapsResetTimer
{
	if ([self.tapsResetTimer isValid]) {
		[self.tapsResetTimer invalidate];
		self.tapsResetTimer = nil;
	}
}

- (void)tapsResetTimer:(NSTimer *)theTimer
{
    self.tapsLabel.text = @"-";
}

- (IBAction)calibrateOrientationButton:(id)sender
{
	// zero's orientation tracking
	[self.device setCalibration:nil forService:PLTServiceOrientationTracking];
}

#pragma mark - PLTDeviceConnectionDelegate

- (void)PLTDeviceDidOpenConnection:(PLTDevice *)aDevice
{
	NSLog(@"PLTDeviceDidOpenConnection: %@", aDevice);
	
	NSError *err = [self.device subscribe:self toService:PLTServiceOrientationTracking withMode:PLTSubscriptionModeOnChange minPeriod:0];
	if (err) NSLog(@"Error: %@", err);
	
	err = [self.device subscribe:self toService:PLTServiceWearingState withMode:PLTSubscriptionModeOnChange minPeriod:0];
	if (err) NSLog(@"Error: %@", err);

	err = [self.device subscribe:self toService:PLTServiceProximity withMode:PLTSubscriptionModeOnChange minPeriod:0];
	if (err) NSLog(@"Error: %@", err);
	
	err = [self.device subscribe:self toService:PLTServicePedometer withMode:PLTSubscriptionModeOnChange minPeriod:0];
	if (err) NSLog(@"Error: %@", err);
	
	err = [self.device subscribe:self toService:PLTServiceFreeFall withMode:PLTSubscriptionModeOnChange minPeriod:0];
	if (err) NSLog(@"Error: %@", err);
	
	// note: this doesn't work right.
	err = [self.device subscribe:self toService:PLTServiceTaps withMode:PLTSubscriptionModeOnChange minPeriod:0];
	if (err) NSLog(@"Error: %@", err);
	
	err = [self.device subscribe:self toService:PLTServiceMagnetometerCalStatus withMode:PLTSubscriptionModeOnChange minPeriod:0];
	if (err) NSLog(@"Error: %@", err);
	
	err = [self.device subscribe:self toService:PLTServiceGyroscopeCalibrationStatus withMode:PLTSubscriptionModeOnChange minPeriod:0];
	if (err) NSLog(@"Error: %@", err);
}

- (void)PLTDevice:(PLTDevice *)aDevice didFailToOpenConnection:(NSError *)error
{
	NSLog(@"PLTDevice: %@ didFailToOpenConnection: %@", aDevice, error);
	self.device = nil;
}

- (void)PLTDeviceDidCloseConnection:(PLTDevice *)aDevice
{
	NSLog(@"PLTDeviceDidCloseConnection: %@", aDevice);
	self.device = nil;
}

#pragma mark - PLTDeviceInfoObserver

//- (void)subscribe
//{
//	NSError *err = [self.device subscribe:self
//								toService:PLTServiceOrientationTracking
//								 withMode:PLTSubscriptionModeOnChange
//								minPeriod:0];
//	if (err) NSLog(@"Error: %@", err);
//}
//
//- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
//{
//	NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
//	
//	if ([theInfo isKindOfClass:[PLTOrientationTrackingInfo class]]) {
//		PLTOrientationTrackingInfo *orientationInfo = (PLTOrientationTrackingInfo *)theInfo;
//		NSLog(@"Orientation: %@", NSStringFromEulerAngles(theInfo.eulerAngles));
//	}
//}

- ( BOOL) PLTDevice:(PLTDevice *)aDevice didExceedThreshold:(PLTInfo *)threshold
{
    
    return false;
}

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
	NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
	
	if ([theInfo isKindOfClass:[PLTOrientationTrackingInfo class]]) {
		PLTEulerAngles eulerAngles = ((PLTOrientationTrackingInfo *)theInfo).eulerAngles;
		self.headingLabel.text = [NSString stringWithFormat:@"%ldº", lroundf(eulerAngles.x)];
        
        //capture head value and package up the information and call geolocate
 //       if
//if(isInfreefall)NSLog(@"FreeFall!");
        
		//self.pitchLabel.text = [NSString stringWithFormat:@"%sº", "False"];//lroundf(eulerAngles.y)];
		//self.rollLabel.text = [NSString stringWithFormat:@"%ldº", lroundf(eulerAngles.z)];
	}
//	else if ([theInfo isKindOfClass:[PLTWearingStateInfo class]]) {
//		self.wearingStateLabel.text = (((PLTWearingStateInfo *)theInfo).isBeingWorn ? @"yes" : @"no");
//	}
//	else if ([theInfo isKindOfClass:[PLTProximityInfo class]]) {
//		PLTProximityInfo *proximityInfp = (PLTProximityInfo *)theInfo;
//		self.mobileProximityLabel.text = NSStringFromProximity(proximityInfp.mobileProximity);
//		self.pcProximityLabel.text = NSStringFromProximity(proximityInfp.pcProximity);
//	}
//	if ([theInfo isKindOfClass:[PLTPedometerInfo class]]) {
//		self.pedometerLabel.text = [NSString stringWithFormat:@"%u", ((PLTPedometerInfo *)theInfo).steps];
//	}
	else if ([theInfo isKindOfClass:[PLTFreeFallInfo class]]) {
		BOOL isInFreeFall = ((PLTFreeFallInfo *)theInfo).isInFreeFall;
		if (isInFreeFall) {
			self.freeFallLabel.text = (isInFreeFall ? @"yes" : @"no");
            self.tapsLabel.text = (isInFreeFall ? @"yes" : @"no");
            //quintan trigger event 1 and call (capture geolocation)
            NSLog(@"Calling Location");
            
            [self SendDataToWeb: gLatitude: gLongitude: 3 ];
            if(self.locationManager){
                NSLog(@"Successful Location Call");
            }
        
           
			[self startFreeFallResetTimer];
		}
	}
//	else if ([theInfo isKindOfClass:[PLTTapsInfo class]]) {
//		PLTTapsInfo *tapsInfo = (PLTTapsInfo *)theInfo;
//		NSString *directionString = NSStringFromTapDirection(tapsInfo.direction);
//		self.tapsLabel.text = [NSString stringWithFormat:@"%u in %@", tapsInfo.taps, directionString];
//		[self startTapsResetTimer];
//	}
//	else if ([theInfo isKindOfClass:[PLTMagnetometerCalibrationInfo class]]) {
//		self.magnetometerCalLabel.text = (((PLTMagnetometerCalibrationInfo *)theInfo).isCalibrated ? @"YES" : @"NO");
//	}
//	else if ([theInfo isKindOfClass:[PLTGyroscopeCalibrationInfo class]]) {
//		self.gyroscopeCalLabel.text = (((PLTGyroscopeCalibrationInfo *)theInfo).isCalibrated ? @"YES" : @"NO" );
//	}
}

#pragma mark - UIViewContorller

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:@"ViewController_iPhone" bundle:nil];
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSArray *devices = [PLTDevice availableDevices];
	if ([devices count]) {
		self.device = devices[0];
		self.device.connectionDelegate = self;
		[self.device openConnection];
	}
	else {
		NSLog(@"No available devices.");
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDeviceAvailableNotification:) name:PLTDeviceNewDeviceAvailableNotification object:nil];
}

// ********************** START JSON! ***************************************
- (void) SendDataToWeb:(double)latitude: (double)longitude: (int)eventStatus
{
    NSLog(@"%f",latitude);
    NSLog(@"%f",longitude);
    
    //    {
    //        "point":[
    //                 { "name": "Sally"  },
    //                 { "phone": "720-336-3337" },
    //                 { "status": "0" },
    //                 { "geo": [
    //                           { "lon": "39.73925" },
    //                           { "lat": "-104.98619" }
    //                           ] }
    //                 ] }
    NSString *thisName = @"Royce";
    NSString *thisPhone = @"720-336-3337";
    //NSString *thisEventStatus = @"3";
 //   NSString *currentLon = @"39.73925";
//    NSString *currentLat = @"-104.98619";
    
    //NSString *fname= @"KIO";
    // Setup POST message and give the encoding needed
    //NSString *post = @"{\"username\":\"user\",\"password\":\"letmein\"}";
    //NSString *post = @"{\"username\":\"user\",\"password\":\"letmein\"}";
    //NSString *jsonRequest = [NSString stringWithFormat:@"{\"Email\":\"%@\",\"FirstName\":\"%@\"}",user,fname]
    //NSString *post = [NSString stringWithFormat:@"{\"Email\":\"%@\",\"FirstName\":\"%@\"}",userName,fname];
    //NSMutableArray *coords = self.locationGet;
   // double currentLat = [[coords objectAtIndex:0]doubleValue];
    //double currentLon = [[coords objectAtIndex:1]doubleValue];
    //
    //NSLog(@"%f",currentLat);
   // double latitude = [[coords objectAtIndex:0]doubleValue];
   // double longitude = [[coords objectAtIndex:1]doubleValue];

    NSString *post = [NSString stringWithFormat:@"{\
                      \"point\":[ \
                      { \"name\": \"%@\"  }, \
                      { \"phone\": \"%@\" }, \
                      { \"status\": \"%d\" }, \
                      { \"geo\": [ \
                      { \"lon\": \"%f\" }, \
                      { \"lat\": \"%f\" } \
                      ] } \
                      ] }",
                      thisName,
                      thisPhone,
                      eventStatus,
                      latitude,
                      longitude];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    // Read the post length
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    //applicationJson
    // Make a new NSMutableURLRequest, and add the necessary URL, Headers and POST Body
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://api.mongolab.com/api/1/databases/points/collections/feedback?apiKey=GKsb6abmOhn1U63x8eZOl8uxd8WmKDml"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    // Send/recieve answer:
    NSURLResponse *response;
    NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSString *theReply = [[NSString alloc] initWithBytes:[POSTReply bytes] length:[POSTReply length] encoding: NSASCIIStringEncoding];
    NSLog(@"Reply: %@", theReply);
}

@end
