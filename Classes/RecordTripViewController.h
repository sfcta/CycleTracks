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
//  RecordTripViewController.h
//  CycleTracks
//
//  Copyright 2009-2013 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 8/10/09.
//	For more information on the project, 
//	e-mail Elizabeth Sall at the SFCTA <elizabeth.sall@sfcta.org>
//

//
// Adapted to Open Bike by Gregory Kip (gkip@permusoft.com) and others.
//


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
	PersonalInfoDelegate,
	RecordingInProgressDelegate,
	TripPurposeDelegate,
	UIAlertViewDelegate,
	UITextViewDelegate>
{
    NSManagedObjectContext *managedObjectContext;
	
    CLLocationManager *locationManager;
    CLLocation* lastLocation;
	/*
	UITableViewCell *tripPurposeCell;
	UITableViewCell *personalInfoCell;
	*/
	BOOL				didUpdateUserLocation;
	IBOutlet MKMapView	*mapView;
	
	IBOutlet UIButton *startButton;
    IBOutlet UIButton *cancelButton;
	
	IBOutlet UILabel *timeCounter;
	IBOutlet UILabel *distCounter;
	IBOutlet UILabel *speedCounter;
	
	NSTimer *__weak timer;
	
	BOOL recording;
	BOOL shouldUpdateCounter;
	BOOL userInfoSaved;
    NSTimeInterval lastBatteryWarning;
	
	TripManager		*tripManager;
	ReminderManager *reminderManager;
}

//@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) CLLocationManager *locationManager;
/*
@property (nonatomic, retain) UITableViewCell	*tripPurposeCell;
@property (nonatomic, retain) UITableViewCell	*personalInfoCell;
*/

@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UILabel *timeCounter;
@property (nonatomic, strong) UILabel *distCounter;

@property (weak) NSTimer *timer;

@property (assign) BOOL recording;
@property (assign) BOOL shouldUpdateCounter;
@property (assign) BOOL userInfoSaved;

@property (nonatomic, strong) ReminderManager *reminderManager;
@property (nonatomic, strong) TripManager *tripManager;

- (void)initTripManager:(TripManager*)manager;

// IBAction handlers
- (IBAction)save:(UIButton *)sender;
- (IBAction)start:(UIButton *)sender;
- (IBAction)cancel:(UIButton *)sender;
- (void)doneRecordingDidCancel:(BOOL)didCancel;

// timer methods
- (void)start:(UIButton *)sender;
- (void)resetCounter;
- (void)setCounterTimeSince:(NSDate *)startDate distance:(CLLocationDistance)distance;
- (void)updateCounter:(NSTimer *)theTimer;

- (void)handleBackgrounding;
- (void)handleForegrounding;
- (void)handleTermination;

@end
