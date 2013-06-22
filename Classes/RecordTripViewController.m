/**  CycleTracks, Copyright 2009-2013 San Francisco County Transportation Authority
 *                                    San Francisco, CA, USA
 *
 *   @author Matt Paul <mattpaul@mopimp.com>
 *
 *   This file is part of CycleTracks.
 *
 *   CycleTracks is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   CycleTracks is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with CycleTracks.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  RecordTripViewController.m
//  CycleTracks
//
//  Copyright 2009-2013 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 8/10/09.
//	For more information on the project,
//	e-mail Elizabeth Sall at the SFCTA <elizabeth.sall@sfcta.org>


#import "constants.h"
#import "MapViewController.h"
#import "PersonalInfoViewController.h"
#import "TripDetailViewController.h"
#import "RecordTripViewController.h"
#import "ReminderManager.h"
#import "TripManager.h"
#import "Trip.h"
#import "User.h"

#define kBatteryLevelThreshold	0.20

#define kResumeInterruptedRecording 101
#define kBatteryLowStopRecording    201
#define kBatteryLowNotRecording     202

@implementation RecordTripViewController

@synthesize locationManager, tripManager, reminderManager;
@synthesize startButton, cancelButton;
@synthesize timer, timeCounter, distCounter;
@synthesize recording, shouldUpdateCounter, userInfoSaved;


#pragma mark CLLocationManagerDelegate methods


- (CLLocationManager *)getLocationManager {
	
   if (locationManager != nil) {
      return locationManager;
   }
	
   if (![CLLocationManager locationServicesEnabled]) {
      NSLog(@"CLLocationManager locationServicesEnabled == false!!");
      //handle this?
   }
   locationManager = [[CLLocationManager alloc] init];
   locationManager.desiredAccuracy = kCLLocationAccuracyBest;
   //locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
   locationManager.delegate = self;
	
   return locationManager;
}

/**
 * Returns True if the battery level is too low
 */
- (BOOL)batteryLevelLowStartPressed:(BOOL)startPressed {
	
   // check battery level
   UIDevice *device = [UIDevice currentDevice];
   device.batteryMonitoringEnabled = YES;
   switch (device.batteryState)
   {
      case UIDeviceBatteryStateUnknown:
         NSLog(@"battery state = UIDeviceBatteryStateUnknown");
         break;
      case UIDeviceBatteryStateUnplugged:
         NSLog(@"battery state = UIDeviceBatteryStateUnplugged");
         break;
      case UIDeviceBatteryStateCharging:
         NSLog(@"battery state = UIDeviceBatteryStateCharging");
         break;
      case UIDeviceBatteryStateFull:
         NSLog(@"battery state = UIDeviceBatteryStateFull");
         break;
   }
   
   NSLog(@"battery level = %f%%", device.batteryLevel * 100.0 );
   if ( (device.batteryState == UIDeviceBatteryStateUnknown) ||
       (device.batteryLevel >= kBatteryLevelThreshold) )
   {
      return FALSE;
   }
   
   int alert_tag = kBatteryLowNotRecording;
   if (recording) {
      alert_tag = kBatteryLowStopRecording;
      
      // stop recording cleanly
      [self doneRecordingDidCancel:FALSE];
   }
   
   // make sure we halt location updates
   [[self getLocationManager] stopUpdatingLocation];
   
   // if this is happening not in response to a GUI event,
   // only notify if we didn't just notify -- no need to be annoying and sometimes it takes a while
   // for the location manager to stop
   if (startPressed || ([[NSDate date] timeIntervalSince1970] - lastBatteryWarning > 120)) {
      
      // notify user -- alert if foreground, otherwise send a notification
      if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
      {
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kBatteryTitle
                                                         message:kBatteryMessage
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
         alert.tag = alert_tag;
         [alert show];
         [alert release];
      }
      else {
         UILocalNotification *localNotif = [[UILocalNotification alloc] init];
         localNotif.alertBody = kBatteryMessage;
         localNotif.soundName = @"bicycle-bell-normalized.aiff";
         [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
         [localNotif release];
      }
      
      lastBatteryWarning = [[NSDate date] timeIntervalSince1970];
   }
   // battery was low - return TRUE
   return TRUE;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
	NSLog(@"location update: %@", [newLocation description]);
	CLLocationDistance deltaDistance = [newLocation distanceFromLocation:oldLocation];
	NSLog(@"deltaDistance = %f", deltaDistance);
	
	if ( !didUpdateUserLocation )
	{
		NSLog(@"zooming to current user location");
		//MKCoordinateRegion region = { mapView.userLocation.location.coordinate, { 0.0078, 0.0068 } };
		MKCoordinateRegion region = { newLocation.coordinate, { 0.0058, 0.0048 } };
		[mapView setRegion:region animated:YES];
      
		didUpdateUserLocation = YES;
	}
	
	// only update map if deltaDistance is at least some epsilon
	else if ( deltaDistance > 1.0 )
	{
		//NSLog(@"center map to current user location");
		[mapView setCenterCoordinate:newLocation.coordinate animated:YES];
	}
   
	if ( recording )
	{
		// add to CoreData store
		CLLocationDistance distance = [tripManager addCoord:newLocation];
		self.distCounter.text = [NSString stringWithFormat:@"%.1f mi", distance / 1609.344];
	} else {
      // save the location for when we do start
      if (lastLocation) [lastLocation release];
      lastLocation = newLocation;
      [lastLocation retain];
   }
	
	// 	double mph = ( [trip.distance doubleValue] / 1609.344 ) / ( [trip.duration doubleValue] / 3600. );
	if ( newLocation.speed >= 0. )
		speedCounter.text = [NSString stringWithFormat:@"%.1f mph", newLocation.speed * 3600 / 1609.344];
	else
		speedCounter.text = @"0.0 mph";
   
   // check the battery level and stop recording if low
   [self batteryLevelLowStartPressed:FALSE];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
	NSLog(@"locationManager didFailWithError: %@", error );
}


#pragma mark MKMapViewDelegate methods

/*
 - (void)mapViewDidFinishLoadingMap:(MKMapView *)theMapView
 {
 NSLog(@"mapViewDidFinishLoadingMap");
 if ( didUpdateUserLocation )
 {
 MKCoordinateRegion region = { theMapView.userLocation.location.coordinate, { 0.0078, 0.0068 } };
 [theMapView setRegion:region animated:YES];
 }
 }
 
 
 - (void)mapView:(MKMapView *)theMapView regionDidChangeAnimated:(BOOL)animated
 {
 NSLog(@"mapView changed region");
 if ( didUpdateUserLocation )
 {
 MKCoordinateRegion region = { theMapView.userLocation.location.coordinate, { 0.0078, 0.0068 } };
 [theMapView setRegion:region animated:YES];
 }
 }
 */

- (void)initTripManager:(TripManager*)manager
{
	//manager.activityDelegate = self;
	manager.alertDelegate	= self;
	manager.dirty			= YES;
	self.tripManager		= manager;
}

- (BOOL)hasUserInfoBeenSaved
{
	BOOL					response = NO;
	NSManagedObjectContext	*context = tripManager.managedObjectContext;
	NSFetchRequest			*request = [[NSFetchRequest alloc] init];
	NSEntityDescription		*entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
	[request setEntity:entity];
	
	NSError *error;
	NSInteger count = [context countForFetchRequest:request error:&error];
	//NSLog(@"saved user count  = %d", count);
	if ( count )
	{
		NSArray *fetchResults = [context executeFetchRequest:request error:&error];
		if ( fetchResults != nil )
		{
			User *user = (User*)[fetchResults objectAtIndex:0];
			if (user			!= nil &&
             (user.age		!= nil ||
              user.gender	!= nil ||
              user.email		!= nil ||
              user.homeZIP	!= nil ||
              user.workZIP	!= nil ||
              user.schoolZIP	!= nil ||
              ([user.cyclingFreq intValue] < 4 )))
			{
				NSLog(@"found saved user info");
				self.userInfoSaved = YES;
				response = YES;
			}
			else
				NSLog(@"no saved user info");
		}
		else
		{
			// Handle the error.
			NSLog(@"no saved user");
			if ( error != nil )
				NSLog(@"PersonalInfo viewDidLoad fetch error %@, %@", error, [error localizedDescription]);
		}
	}
	else
		NSLog(@"no saved user");
	
	[request release];
	return response;
}

- (void)hasRecordingBeenInterrupted
{
	if ( [tripManager countUnSavedTrips] )
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kInterruptedTitle
                                                      message:kInterruptedMessage
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Continue", nil];
		alert.tag = kResumeInterruptedRecording;
		[alert show];
		[alert release];
	}
	else
		NSLog(@"no unsaved trips found");
}

- (void)infoAction:(id)sender
{
	if ( !recording )
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString: kInfoURL]];
}


- (void)viewDidLoad
{
	NSLog(@"RecordTripViewController viewDidLoad");
   [super viewDidLoad];
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
   
   UIImage *startButtonImage = [UIImage imageNamed:@"start_button"];
   UIImage *cancelButtonImage = [UIImage imageNamed:@"cancel_button"];
   
   if ([startButtonImage respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)]) {
      // iOS 6
      [startButton setBackgroundImage:[startButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(48,20,48,20) resizingMode: UIImageResizingModeStretch] forState:UIControlStateNormal];
      [cancelButton setBackgroundImage:[cancelButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(48,20,48,20) resizingMode: UIImageResizingModeStretch] forState:UIControlStateNormal];
   } else {
      // iOS 5
      [startButton setBackgroundImage:[startButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(48,20,48,20)] forState:UIControlStateNormal];
      [cancelButton setBackgroundImage:[cancelButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(48,20,48,20)] forState:UIControlStateNormal];
   }
   
	
	// init map region to San Francisco
	MKCoordinateRegion region = { { 37.7620, -122.4350 }, { 0.10825, 0.10825 } };
	[mapView setRegion:region animated:NO];
	
	self.recording = NO;
	self.shouldUpdateCounter = NO;
	
	// Start the location manager.
	[[self getLocationManager] startUpdatingLocation];
	
	// Start receiving updates as to battery level
	UIDevice *device = [UIDevice currentDevice];
	device.batteryMonitoringEnabled = YES;
	switch (device.batteryState)
	{
		case UIDeviceBatteryStateUnknown:
			NSLog(@"battery state = UIDeviceBatteryStateUnknown");
			break;
		case UIDeviceBatteryStateUnplugged:
			NSLog(@"battery state = UIDeviceBatteryStateUnplugged");
			break;
		case UIDeviceBatteryStateCharging:
			NSLog(@"battery state = UIDeviceBatteryStateCharging");
			break;
		case UIDeviceBatteryStateFull:
			NSLog(@"battery state = UIDeviceBatteryStateFull");
			break;
	}
   
	NSLog(@"battery level = %f%%", device.batteryLevel * 100.0 );
   
	// check if any user data has already been saved and pre-select personal info cell accordingly
	if ( [self hasUserInfoBeenSaved] )
		[self setSaved:YES];
	
	// check for any unsaved trips / interrupted recordings
	[self hasRecordingBeenInterrupted];
}


- (void)resetTimer
{
	// invalidate timer
	if ( timer )
	{
		[timer invalidate];
		//[timer release];
		timer = nil;
	}
}


- (void)resetRecordingInProgress
{
	// reset button states
	recording = NO;
	startButton.enabled = YES;
	
	// reset trip, reminder managers
	NSManagedObjectContext *context = tripManager.managedObjectContext;
	[self initTripManager:[[TripManager alloc] initWithManagedObjectContext:context]];
	tripManager.dirty = YES;
	
	if ( reminderManager )
	{
		[reminderManager release];
		reminderManager = nil;
	}
	
	[self resetCounter];
	[self resetTimer];
}

#pragma mark UIAlertViewDelegate methods


/**
 * This method is called upon closing the following alert boxes.
 * - battery low
 * - do you want to continue a previous, interrupted recording? (tag=kResumeInterruptedRecording)
 * - upload attempt is complete (TripManager connection:didReceiveResponse:)
 */
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
   if (alertView.tag == kResumeInterruptedRecording) {
      NSLog(@"recording interrupted didDismissWithButtonIndex: %d", buttonIndex);
      if (buttonIndex == 0) {
         // new trip => do nothing
      }
      else {
         // continue => load most recent unsaved trip
         [tripManager loadMostRecentUnSavedTrip];
         
         // update UI to reflect trip once loading has completed
         [self setCounterTimeSince:tripManager.trip.start distance:[tripManager getDistanceEstimate]];
         
         startButton.enabled = YES;
      }
      return;
   }
   
   // go to the map view of the trip
   // not relevant if we weren't recording
   if (alertView.tag != kBatteryLowNotRecording) {
      NSLog(@"saving didDismissWithButtonIndex: %d", buttonIndex);
      
      // keep a pointer to our trip to pass to map view below
      Trip *trip = tripManager.trip;
      [self resetRecordingInProgress];
      
      // load map view of saved trip
      MapViewController *mvc = [[MapViewController alloc] initWithTrip:trip];
      [[self navigationController] pushViewController:mvc animated:YES];
      [mvc release];
	}
}


// handle save button action
- (IBAction)save:(UIButton *)sender
{
	NSLog(@"save");
	
   // Trip Purpose
   TripDetailViewController *tripDetailViewController = [[TripDetailViewController alloc]
                                                         //initWithPurpose:[tripManager getPurposeIndex]];
                                                         initWithNibName:@"TripDetailPicker" bundle:nil];
   [tripDetailViewController setDelegate:self];
   [self.navigationController presentModalViewController:tripDetailViewController animated:YES];
   [tripDetailViewController release];
	
}

- (IBAction)cancel:(UIButton *)sender
{
   NSLog(@"Cancel");
   [self doneRecordingDidCancel:TRUE];
}

/**
 * Call when we are done recording.
 */
- (void)doneRecordingDidCancel:(BOOL)didCancel {
	// update UI
	recording = NO;
   
   
   // transform save button into start button
   
   UIImage *startButtonImage = [UIImage imageNamed:@"start_button"];
   
   if ([startButtonImage respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)]) {
      // iOS 6
      [startButton setBackgroundImage:[startButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(48,20,48,20) resizingMode: UIImageResizingModeStretch] forState:UIControlStateNormal];
   } else {
      // iOS 5
      [startButton setBackgroundImage:[startButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(48,20,48,20)] forState:UIControlStateNormal];
   }
   
   [startButton setTitle:@"Start" forState:UIControlStateNormal];
   startButton.frame = CGRectMake( 24.0, 198.0, 272.0, kCustomButtonHeight );
	cancelButton.hidden = TRUE;
   
   // kill the timer that is updating the UI and reset the UI counter
   [self resetTimer];
   [self resetCounter];
   
   // remove all reminders
   if ( reminderManager )
      [reminderManager disableReminders];
   
   // if cancel - reset state
   if (didCancel) {
      [self.tripManager unloadTrip];
   }
   
   // stop the location manager if we're in background mode
   // if we're in foreground mode, backgrounding will do it
   if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
      [[self getLocationManager] stopUpdatingLocation];
}

// handle start button action
- (IBAction)start:(UIButton *)sender
{
	NSLog(@"start - recording=%d", recording);
   
   // just one button - we really want to save
   if (recording) {
      [self save:sender];
      return;
   }
	
   // if the battery level is low then NM
   if ([self batteryLevelLowStartPressed:TRUE])
      return;
   
	// start the timer if needed
	if ( timer == nil )
	{
      NSDictionary* counterUserDict;
		// check if we're continuing a trip - then start the trip from there
		if ( tripManager.trip && tripManager.trip.start && [tripManager.trip.coords count] )
		{
         counterUserDict = [NSDictionary dictionaryWithObjectsAndKeys:tripManager.trip.start, @"StartDate",
                            tripManager, @"TripManager", nil ];
      }
      // or starting a new recording
      else {
			[self resetCounter];
         counterUserDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], @"StartDate",
                            tripManager, @"TripManager", nil ];
      }
      timer = [NSTimer scheduledTimerWithTimeInterval:kCounterTimeInterval
                                               target:self selector:@selector(updateCounter:)
                                             userInfo:counterUserDict
                                              repeats:YES];
	}
   
	// init reminder manager
	if ( reminderManager )
      [reminderManager disableReminders];
   [reminderManager release];
	
	reminderManager = [[ReminderManager alloc] init];
	
   // transform start button into save button
   UIImage *saveButtonImage = [UIImage imageNamed:@"save_button"];
   
   if ([saveButtonImage respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)]) {
      // iOS 6
      [startButton setBackgroundImage:[saveButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(48,20,48,20) resizingMode: UIImageResizingModeStretch] forState:UIControlStateNormal];
   } else {
      // iOS 5
      [startButton setBackgroundImage:[saveButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(48,20,48,20)] forState:UIControlStateNormal];
   }
   
   [startButton setTitle:@"Save" forState:UIControlStateNormal];
   
   startButton.frame = CGRectMake(24.0, 198.0, kCustomButtonWidth, kCustomButtonHeight);
   cancelButton.enabled = TRUE;
   cancelButton.hidden = FALSE;
	
   // Start the location manager.
	[[self getLocationManager] startUpdatingLocation];
   
   // set recording flag so future location updates will be added as coords
	recording = YES;
	
   // add the last location we know about to start
   if (lastLocation) {
      NSLog(@"tripManager = %@", tripManager);
      CLLocationDistance distance = [tripManager addCoord:lastLocation];
      self.distCounter.text = [NSString stringWithFormat:@"%.1f mi", distance / 1609.344];
      [lastLocation release];
      lastLocation = nil;
   }
	
	// set flag to update counter
	shouldUpdateCounter = YES;
}

- (void)resetCounter
{
	if ( timeCounter != nil )
		timeCounter.text = @"00:00:00";
	
	if ( distCounter != nil )
		distCounter.text = @"0 mi";
}


- (void)setCounterTimeSince:(NSDate *)startDate distance:(CLLocationDistance)distance
{
	if ( timeCounter != nil )
	{
		NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:startDate];
		
		static NSDateFormatter *inputFormatter = nil;
		if ( inputFormatter == nil )
			inputFormatter = [[NSDateFormatter alloc] init];
		
		[inputFormatter setDateFormat:@"HH:mm:ss"];
		NSDate *fauxDate = [inputFormatter dateFromString:@"00:00:00"];
		[inputFormatter setDateFormat:@"HH:mm:ss"];
		NSDate *outputDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:fauxDate];
		
		timeCounter.text = [inputFormatter stringFromDate:outputDate];
	}
	
	if ( distCounter != nil )
		distCounter.text = [NSString stringWithFormat:@"%.1f mi", distance / 1609.344];
}


// Updates the elapsed-time counter in the GUI.
- (void)updateCounter:(NSTimer *)theTimer
{
	// NSLog(@"updateCounter");
	if ( shouldUpdateCounter )
	{
		NSDate *startDate = [[theTimer userInfo] objectForKey:@"StartDate"];
		NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:startDate];
      
		static NSDateFormatter *inputFormatter = nil;
		if ( inputFormatter == nil )
			inputFormatter = [[NSDateFormatter alloc] init];
		
		[inputFormatter setDateFormat:@"HH:mm:ss"];
		NSDate *fauxDate = [inputFormatter dateFromString:@"00:00:00"];
		[inputFormatter setDateFormat:@"HH:mm:ss"];
		NSDate *outputDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:fauxDate];
		
		//NSLog(@"Timer started on %@", startDate);
		//NSLog(@"Timer started %f seconds ago", interval);
		//NSLog(@"elapsed time: %@", [inputFormatter stringFromDate:outputDate] );
		
		//self.timeCounter.text = [NSString stringWithFormat:@"%.1f sec", interval];
		self.timeCounter.text = [inputFormatter stringFromDate:outputDate];
	}
}

/**
 * Handle the fact that we're going to be backgrounded
 * If we're not recording,
 * - No need to run the timer
 * - No need to get locations
 * - No need to run the reminder clock
 */
- (void)handleBackgrounding
{
   if (!recording) {
      [[self getLocationManager] stopUpdatingLocation];
   }
   // the timer is for visuals - no need for that but it doesn't seem to hurt
   // [self resetTimer];
}

- (void)handleForegrounding
{
   NSLog(@"handleForegrounding : recording=%d", recording);
   // Start the location manager.
	[[self getLocationManager] startUpdatingLocation];
}

- (void)handleTermination
{
   if ( reminderManager )
      [reminderManager disableReminders];
}

#pragma mark UIViewController overrides

- (void)viewWillAppear:(BOOL)animated
{
   // listen for keyboard hide/show notifications so we can properly adjust the table's height
	[super viewWillAppear:animated];
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
   [super viewDidDisappear:animated];
   [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
   [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
	NSLog(@"keyboardWillShow");
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
	NSLog(@"keyboardWillHide");
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
   [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
   //self.coords = nil;
   self.locationManager = nil;
   self.startButton = nil;
}


- (NSString *)updatePurposeWithString:(NSString *)purpose
{
	// update UI
	/*
	 if ( tripPurposeCell != nil )
	 {
	 tripPurposeCell.accessoryType = UITableViewCellAccessoryCheckmark;
	 tripPurposeCell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GreenCheckMark3.png"]];
	 tripPurposeCell.detailTextLabel.text = purpose;
	 tripPurposeCell.detailTextLabel.enabled = YES;
	 tripPurposeCell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
	 tripPurposeCell.detailTextLabel.minimumFontSize = kMinimumFontSize;
	 }
	 */
	
	// only enable start button if we don't already have a pending trip
	if ( timer == nil )
		startButton.enabled = YES;
	
	startButton.hidden = NO;
	
	return purpose;
}


- (NSString *)updatePurposeWithIndex:(unsigned int)index
{
	return [self updatePurposeWithString:[tripManager getPurposeString:index]];
}


- (void)dealloc {
   [managedObjectContext release];
   //[coords release];
   [locationManager release];
   [startButton release];
   [super dealloc];
}


#pragma mark UINavigationController

- (void)navigationController:(UINavigationController *)navigationController
	   willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
   NSLog(@"navigationController willShowViewController animated");
	if ( viewController == self )
	{
		//NSLog(@"willShowViewController:self");
		self.title = @"Record New Trip";
	}
	else
	{
		//NSLog(@"willShowViewController:else");
		self.title = @"Back";
		self.tabBarItem.title = @"Record New Trip"; // important to maintain the same tab item title
	}
}

#pragma mark PersonalInfoDelegate methods


- (void)setSaved:(BOOL)value
{
	NSLog(@"setSaved");
	// update UI
	/*
    if ( personalInfoCell != nil )
    {
    NSLog(@"Personal Info saved");
    personalInfoCell.accessoryType = UITableViewCellAccessoryCheckmark;
    personalInfoCell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GreenCheckMark3.png"]];
    personalInfoCell.detailTextLabel.text = @"Saved";
    personalInfoCell.detailTextLabel.enabled = YES;
    }
	 */
}


#pragma mark TripPurposeDelegate methods


- (NSString *)setPurpose:(unsigned int)index
{
	NSString *purpose = [tripManager setPurpose:index];
	NSLog(@"setPurpose: %@", purpose);
   
	//[self.navigationController popViewControllerAnimated:YES];
	
	return [self updatePurposeWithString:purpose];
}


- (NSString *)getPurposeString:(unsigned int)index
{
	return [tripManager getPurposeString:index];
}


- (void)didCancelPurpose
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
	recording = YES;
	shouldUpdateCounter = YES;
}


- (void)didPickPurpose:(unsigned int)index
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
	[self doneRecordingDidCancel:FALSE];
   
	[tripManager setPurpose:index];
	[tripManager promptForTripNotes];
}


-(void)didPickPurpose:(unsigned int)index ease:(unsigned int)ease safety:(unsigned int)safety convenience:(unsigned int)convenience {
   NSLog(@"%@", NSStringFromSelector(_cmd));
   [self.navigationController dismissModalViewControllerAnimated:YES];
	[self doneRecordingDidCancel:FALSE];
   
	//[tripManager setPurpose:index];
   [tripManager setPurpose:index ease:ease safety:safety convenience:convenience];
	[tripManager promptForTripNotes];

}



#pragma mark RecordingInProgressDelegate method


- (Trip*)getRecordingInProgress
{
	if ( recording )
		return tripManager.trip;
	else
		return nil;
}


@end

