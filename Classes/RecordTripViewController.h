/**  CycleTracks, Copyright 2009,2010 San Francisco County Transportation Authority
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
//  RecordTripViewController.h
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 8/10/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>


#import <CoreLocation/CoreLocation.h>
#import "ActivityIndicatorDelegate.h"
#import <MapKit/MapKit.h>
#import "PersonalInfoDelegate.h"
#import "RecordingInProgressDelegate.h"
#import "TripPurposeDelegate.h"


@class ReminderManager;
@class TripManager;


//@interface RecordTripViewController : UITableViewController 
@interface RecordTripViewController : UIViewController 
	<CLLocationManagerDelegate,
	MKMapViewDelegate,
	UINavigationControllerDelegate, 
	UITabBarControllerDelegate, 
	PersonalInfoDelegate,
	RecordingInProgressDelegate,
	TripPurposeDelegate,
	UIActionSheetDelegate,
	UIAlertViewDelegate,
	UITextViewDelegate>
{
    NSManagedObjectContext *managedObjectContext;
	
    CLLocationManager *locationManager;
	/*
	UITableViewCell *tripPurposeCell;
	UITableViewCell *personalInfoCell;
	*/
	BOOL				didUpdateUserLocation;
	IBOutlet MKMapView	*mapView;
	
	IBOutlet UIButton *infoButton;
	IBOutlet UIButton *saveButton;
	IBOutlet UIButton *startButton;
	
	IBOutlet UILabel *timeCounter;
	IBOutlet UILabel *distCounter;
	IBOutlet UILabel *speedCounter;


	NSTimer *timer;
	
	// pointer to opacity mask, TabBar view
	UIView *opacityMask;
	UIView *parentView;
	
	BOOL recording;
	BOOL shouldUpdateCounter;
	BOOL userInfoSaved;
	
	TripManager		*tripManager;
	ReminderManager *reminderManager;
}

//@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) CLLocationManager *locationManager;
/*
@property (nonatomic, retain) UITableViewCell	*tripPurposeCell;
@property (nonatomic, retain) UITableViewCell	*personalInfoCell;
*/
@property (nonatomic, retain) UIButton *infoButton;
@property (nonatomic, retain) UIButton *saveButton;
@property (nonatomic, retain) UIButton *startButton;

@property (nonatomic, retain) UILabel *timeCounter;
@property (nonatomic, retain) UILabel *distCounter;


@property (assign) NSTimer *timer;

@property (nonatomic, retain) UIView   *parentView;


@property (assign) BOOL recording;
@property (assign) BOOL shouldUpdateCounter;
@property (assign) BOOL userInfoSaved;

@property (nonatomic, retain) ReminderManager *reminderManager;
@property (nonatomic, retain) TripManager *tripManager;

- (void)initTripManager:(TripManager*)manager;

// DEPRECATED
//- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context;
//- (id)initWithTripManager:(TripManager*)manager;

// IBAction handlers
- (IBAction)save:(UIButton *)sender;
- (IBAction)start:(UIButton *)sender;


// timer methods
- (void)start:(UIButton *)sender;
- (void)createCounter;
- (void)resetCounter;
- (void)setCounterTimeSince:(NSDate *)startDate distance:(CLLocationDistance)distance;
- (void)updateCounter:(NSTimer *)theTimer;

- (UIButton *)createSaveButton;
- (UIButton *)createStartButton;




@end
