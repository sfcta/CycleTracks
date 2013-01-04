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
#import "PickerViewController.h"
#import "RecordTripViewController.h"
#import "ReminderManager.h"
#import "TripManager.h"
#import "Trip.h"
#import "User.h"


@implementation RecordTripViewController

@synthesize locationManager, tripManager, reminderManager;
@synthesize infoButton, saveButton, startButton, parentView;
@synthesize timer, timeCounter, distCounter;
@synthesize recording, shouldUpdateCounter, userInfoSaved;


#pragma mark CLLocationManagerDelegate methods


- (CLLocationManager *)getLocationManager {
	
    if (locationManager != nil) {
        return locationManager;
    }
	
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    locationManager.delegate = self;
	
    return locationManager;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
	// NSLog(@"location update: %@", [newLocation description]);
	CLLocationDistance deltaDistance = [newLocation getDistanceFrom:oldLocation];
	//NSLog(@"deltaDistance = %f", deltaDistance);
	
	if ( !didUpdateUserLocation )
	{
		NSLog(@"zooming to current user location");
		//MKCoordinateRegion region = { mapView.userLocation.location.coordinate, { 0.0078, 0.0068 } };
		MKCoordinateRegion region = { newLocation.coordinate, { 0.0078, 0.0068 } };
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
	}
	
	// 	double mph = ( [trip.distance doubleValue] / 1609.344 ) / ( [trip.duration doubleValue] / 3600. );
	if ( newLocation.speed >= 0. )
		speedCounter.text = [NSString stringWithFormat:@"%.1f mph", newLocation.speed * 3600 / 1609.344];
	else
		speedCounter.text = @"0.0 mph";
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

/*
- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context
{
    if (self = [super initWithStyle:UITableViewStyleGrouped])
	{
		//NSLog(@"RecordTripViewController::initWithManagedObjectContext");
		self.managedObjectContext = context;
    }
    return self;
}
*/

- (void)initTripManager:(TripManager*)manager
{
	//manager.activityDelegate = self;
	manager.alertDelegate	= self;
	manager.dirty			= YES;
	self.tripManager		= manager;
}

/*
- (id)initWithTripManager:(TripManager*)manager
{
    if (self = [super initWithStyle:UITableViewStyleGrouped])
	{
		//NSLog(@"RecordTripViewController::initWithTripManager");
		[self initTripManager:manager];
    }
    return self;
}
*/

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
		alert.tag = 101;
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

	// Set the title.
	// self.title = @"Record New Trip";
	
	// init map region to San Francisco
	MKCoordinateRegion region = { { 37.7620, -122.4350 }, { 0.10825, 0.10825 } };
	[mapView setRegion:region animated:NO];
	
	// setup info button
	infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	infoButton.showsTouchWhenHighlighted = YES;
	/*
	[infoButton addTarget:self action:@selector(infoAction:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc] initWithCustomView:infoButton];
	*/
	
	// Set up the buttons.
	/*
	[self.view addSubview:[self createSaveButton]];
	[self.view addSubview:[self createStartButton]];
	[self.view addSubview:[self createLockButton]];
	*/
	
//	[self createCounter];

	

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


// instantiate start button
- (UIButton *)createStartButton
{
	if (startButton == nil)
	{
		// create a UIButton (UIButtonTypeRoundedRect)
		startButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
		[startButton setBackgroundImage:[UIImage imageNamed:@"start_button.png"] forState:UIControlStateNormal];
		startButton.frame = CGRectMake( 9.0, 181.0, kCustomButtonWidth, kCustomButtonHeight );
		startButton.backgroundColor = [UIColor clearColor];
		startButton.enabled = YES;
		//startButton.hidden = YES;
		
		[startButton setTitle:@"Start" forState:UIControlStateNormal];
		[startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		startButton.titleLabel.font = [UIFont boldSystemFontOfSize: 24];
		//startButton.titleLabel.shadowOffset = CGSizeMake (1.0, 1.0);
		startButton.titleLabel.textColor = [UIColor whiteColor];
		[startButton addTarget:self action:@selector(start:) forControlEvents:UIControlEventTouchUpInside];
	}
	return startButton;
}


// instantiate save button
- (UIButton *)createSaveButton
{
	if (saveButton == nil)
	{
		// create a UIButton (UIButtonTypeRoundedRect)
		saveButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[saveButton setBackgroundImage:[UIImage imageNamed:@"save_button.png"] forState:UIControlStateNormal];
		saveButton.frame = CGRectMake( 9.0, 240.0, kCustomButtonWidth, kCustomButtonHeight );
		saveButton.backgroundColor = [UIColor clearColor];
		saveButton.enabled = NO;
		//saveButton.hidden = YES;
		
		[saveButton setTitle:@"Save" forState:UIControlStateNormal];
		[saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		saveButton.titleLabel.font = [UIFont boldSystemFontOfSize: 24];
		//saveButton.titleLabel.shadowOffset = CGSizeMake (1.0, 1.0);
		saveButton.titleLabel.textColor = [UIColor whiteColor];
		[saveButton addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
	}
	return saveButton;
}


- (void)resetPurpose
{
	/*
	NSLog(@"resetPurpose");
	if ( tripPurposeCell != nil )
	{
		//tripPurposeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		tripPurposeCell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		if ( tripPurposeCell.accessoryView )
		{
			// release our custom checkmark accessory image
			[tripPurposeCell.accessoryView release];
			tripPurposeCell.accessoryView = nil;
		}
		tripPurposeCell.detailTextLabel.text = @"Required";
		tripPurposeCell.detailTextLabel.enabled = NO;
	}
	[self.tableView reloadData];
	 */
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
    [startButton setBackgroundImage:[UIImage imageNamed:@"start_button.png"] forState:UIControlStateNormal];
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
	saveButton.enabled = NO;
	
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
	[self resetPurpose];
	[self resetTimer];
}


#pragma mark UIActionSheet delegate methods


// NOTE: implement didDismissWithButtonIndex to process after sheet has been dismissed
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	NSLog(@"actionSheet clickedButtonAtIndex %d", buttonIndex);
	switch ( buttonIndex )
	{
			/*
		case kActionSheetButtonDiscard:
			NSLog(@"Discard");
			[self resetRecordingInProgress];
			break;
			*/
			/*
		case kActionSheetButtonConfirm:
			NSLog(@"Confirm => creating Trip Notes dialog");
			[tripManager promptForTripNotes];
			
			// stop recording new GPS data points
			recording = NO;
			
			// update UI
			saveButton.enabled = NO;
			
			[self resetTimer];
			break;
			*/
			/*
		case kActionSheetButtonChange:
			NSLog(@"Change => push Trip Purpose picker");
			 */
		case 0: // push Trip Purpose picker
			// stop recording new GPS data points
		{
			recording = NO;
			
			// update UI
			saveButton.enabled = NO;
			
			[self resetTimer];
			
			// Trip Purpose
			NSLog(@"INIT + PUSH");
			PickerViewController *pickerViewController = [[PickerViewController alloc]
														  //initWithPurpose:[tripManager getPurposeIndex]];
														  initWithNibName:@"TripPurposePicker" bundle:nil];
			[pickerViewController setDelegate:self];
			//[[self navigationController] pushViewController:pickerViewController animated:YES];
			[self.navigationController presentModalViewController:pickerViewController animated:YES];
			[pickerViewController release];
		}
			break;
			
		case kActionSheetButtonCancel:
		default:
			NSLog(@"Cancel");
			// re-enable counter updates
			shouldUpdateCounter = YES;
			break;
	}
}


// called if the system cancels the action sheet (e.g. homescreen button has been pressed)
- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
	NSLog(@"actionSheetCancel");
}


#pragma mark UIAlertViewDelegate methods


// NOTE: method called upon closing save error / success alert
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	switch (alertView.tag) {
		case 101:
		{
			NSLog(@"recording interrupted didDismissWithButtonIndex: %d", buttonIndex);
			switch (buttonIndex) {
				case 0:
					// new trip => do nothing
					break;
				case 1:
				default:
					// continue => load most recent unsaved trip
					[tripManager loadMostRecetUnSavedTrip];
					
					// update UI to reflect trip once loading has completed
					[self setCounterTimeSince:tripManager.trip.start
									 distance:[tripManager getDistanceEstimate]];

					startButton.enabled = YES;					
					break;
			}
		}
			break;
		default:
		{
			NSLog(@"saving didDismissWithButtonIndex: %d", buttonIndex);
			
			// keep a pointer to our trip to pass to map view below
			Trip *trip = tripManager.trip;
			[self resetRecordingInProgress];
			
			// load map view of saved trip
			MapViewController *mvc = [[MapViewController alloc] initWithTrip:trip];
			[[self navigationController] pushViewController:mvc animated:YES];
			[mvc release];
		}
			break;
	}
}



// handle save button action
- (IBAction)save:(UIButton *)sender
{
	NSLog(@"save");
	
	// go directly to TripPurpose, user can cancel from there
	if ( YES )
	{
		// Trip Purpose
		NSLog(@"INIT + PUSH");
		PickerViewController *pickerViewController = [[PickerViewController alloc]
													  //initWithPurpose:[tripManager getPurposeIndex]];
													  initWithNibName:@"TripPurposePicker" bundle:nil];
		[pickerViewController setDelegate:self];
		//[[self navigationController] pushViewController:pickerViewController animated:YES];
		[self.navigationController presentModalViewController:pickerViewController animated:YES];
		[pickerViewController release];
	}
	
	// prompt to confirm first
	else
	{
		// pause updating the counter
		shouldUpdateCounter = NO;
		
		// construct purpose confirmation string
		NSString *purpose = nil;
		if ( tripManager != nil )
			purpose = [self getPurposeString:[tripManager getPurposeIndex]];
		
		NSString *confirm = [NSString stringWithFormat:@"Stop recording & save this trip?"];
		
		// present action sheet
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:confirm
																 delegate:self
														cancelButtonTitle:@"Cancel"
												   destructiveButtonTitle:nil
														otherButtonTitles:@"Save", nil];
		
		actionSheet.actionSheetStyle		= UIActionSheetStyleBlackTranslucent;
		UIViewController *pvc = self.parentViewController;
		UITabBarController *tbc = (UITabBarController *)pvc.parentViewController;
		
		[actionSheet showFromTabBar:tbc.tabBar];
		[actionSheet release];
	}
}


- (NSDictionary *)newTripTimerUserInfo
{
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], @"StartDate",
			tripManager, @"TripManager", nil ];
}


- (NSDictionary *)continueTripTimerUserInfo
{
	if ( tripManager.trip && tripManager.trip.start )
		return [NSDictionary dictionaryWithObjectsAndKeys:tripManager.trip.start, @"StartDate",
				tripManager, @"TripManager", nil ];
	else {
		NSLog(@"WARNING: tried to continue trip timer but failed to get trip.start date");
		return [self newTripTimerUserInfo];
	}
	
}


// handle start button action
- (IBAction)start:(UIButton *)sender
{
    if(recording == NO)
    {
	NSLog(@"start");
	
	// start the timer if needed
	if ( timer == nil )
	{
		// check if we're continuing a trip
		if ( tripManager.trip && [tripManager.trip.coords count] )
		{
			timer = [NSTimer scheduledTimerWithTimeInterval:kCounterTimeInterval
													 target:self selector:@selector(updateCounter:)
												   userInfo:[self continueTripTimerUserInfo] repeats:YES];
		}
		
		// or starting a new recording
		else {
			[self resetCounter];
			timer = [NSTimer scheduledTimerWithTimeInterval:kCounterTimeInterval
													 target:self selector:@selector(updateCounter:)
												   userInfo:[self newTripTimerUserInfo] repeats:YES];
		}
	}

	// init reminder manager
	if ( reminderManager )
		[reminderManager release];
	
	reminderManager = [[ReminderManager alloc] initWithRecordingInProgressDelegate:self];
	
	// Toggle start button
	[startButton setBackgroundImage:[UIImage imageNamed:@"cancel_button.png"] forState:UIControlStateNormal];
    [startButton setTitle:@"Cancel" forState:UIControlStateNormal];    
	
	// enable save button
	saveButton.enabled = YES;
	saveButton.hidden = NO;
	
	// set recording flag so future location updates will be added as coords
	recording = YES;
	
	// update "Touch start to begin text"
	//[self.tableView reloadData];
	
	/*
	CGRect sectionRect = [self.tableView rectForSection:0];
	[self.tableView setNeedsDisplayInRect:sectionRect];
	[self.view setNeedsDisplayInRect:sectionRect];
	*/
	
	// set flag to update counter
	shouldUpdateCounter = YES;
    }
    
    else
    {
        NSLog(@"User Cancel");
        [self resetRecordingInProgress];
        
    }
	
}



- (void)createCounter
{
	// create counter window
	/*
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LargeCounter.png"]];
	//CGRect frame = CGRectMake( 155, 181, 156, 89 );
	CGRect frame = CGRectMake( 155, 181, 156, 107 );
	imageView.frame = frame;
	[self.view addSubview:imageView];
	*/
	
	// create time counter text
	if ( timeCounter == nil )
	{
		/*
		frame = CGRectMake(	165, 179, 135, 50 );
		self.timeCounter = [[[UILabel alloc] initWithFrame:frame] autorelease];
		self.timeCounter.backgroundColor	= [UIColor clearColor];
		self.timeCounter.font				= [UIFont boldSystemFontOfSize:kCounterFontSize];
		self.timeCounter.textAlignment		= UITextAlignmentRight;
		self.timeCounter.textColor			= [UIColor darkGrayColor];
		[self.view addSubview:self.timeCounter];
		*/
		
		// time elapsed
		/*
		frame = CGRectMake(	165, 213, 135, 20 );
		UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
		label.backgroundColor	= [UIColor clearColor];
		label.font				= [UIFont systemFontOfSize:12.0];
		label.text				= @"time elapsed";
		label.textAlignment		= UITextAlignmentRight;
		label.textColor			= [UIColor grayColor];
		[self.view addSubview:label];
		 */
	}
	
	// create GPS counter (e.g. # coords) text
	if ( distCounter == nil )
	{
		/*
		frame = CGRectMake(	165, 226, 135, 50 );
		//frame = CGRectMake(	165, 255, 135, 20 );
		self.distCounter = [[[UILabel alloc] initWithFrame:frame] autorelease];
		self.distCounter.font = [UIFont boldSystemFontOfSize:kCounterFontSize];
		self.distCounter.textAlignment = UITextAlignmentRight;
		self.distCounter.textColor = [UIColor darkGrayColor];
		self.distCounter.backgroundColor = [UIColor clearColor];
		[self.view addSubview:self.distCounter];
		*/
		// distance
		/*
		frame = CGRectMake(	165, 260, 135, 20 );
		//frame = CGRectMake(	165, 218, 135, 50 );
		UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
		label.backgroundColor	= [UIColor clearColor];
		label.font				= [UIFont systemFontOfSize:12.0];
		label.text				= @"est. distance";
		label.textAlignment		= UITextAlignmentRight;
		label.textColor			= [UIColor grayColor];
		[self.view addSubview:label];
		 */
	}
	
	[self resetCounter];
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
;
}


// handle start button action
- (void)updateCounter:(NSTimer *)theTimer
{
	//NSLog(@"updateCounter");
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
	/*
	if ( reminderManager )
		[reminderManager updateReminder:theTimer];
	 */
}




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
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/

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

/*
- (void)navigationController:(UINavigationController *)navigationController 
	   didShowViewController:(UIViewController *)viewController 
					animated:(BOOL)animated
{
	if ( viewController == self )
		NSLog(@"didShowViewController:self");
	else
		NSLog(@"didShowViewController:else");

}
*/

- (void)navigationController:(UINavigationController *)navigationController 
	   willShowViewController:(UIViewController *)viewController 
					animated:(BOOL)animated
{
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


#pragma mark UITabBarControllerDelegate


- (BOOL)tabBarController:(UITabBarController *)tabBarController 
shouldSelectViewController:(UIViewController *)viewController
{
		return YES;		
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
	saveButton.enabled = YES;
	shouldUpdateCounter = YES;
}


- (void)didPickPurpose:(unsigned int)index
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
	
	// update UI
	recording = NO;	
	saveButton.enabled = NO;
	startButton.enabled = YES;
	[self resetTimer];
	
	[tripManager setPurpose:index];
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

