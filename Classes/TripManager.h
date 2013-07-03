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
//  TripManager.h
//  CycleTracks
//
//  Copyright 2009-2013 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/22/09.
//	For more information on the project, 
//	e-mail Elizabeth Sall at the SFCTA <elizabeth.sall@sfcta.org>
//

//
// Adapted to Open Bike by Gregory Kip (gkip@permusoft.com) and others.
//


#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import "ActivityIndicatorDelegate.h"
#import "TripPurposeDelegate.h"


@class Trip;


@interface TripManager : NSObject
<ActivityIndicatorDelegate, 
TripPurposeDelegate, 
UIAlertViewDelegate, 
UITextViewDelegate>
{
	id <ActivityIndicatorDelegate> activityDelegate;
	id <UIAlertViewDelegate> alertDelegate;
   
	UIActivityIndicatorView *activityIndicator;
	UIAlertView *saving;
	UIAlertView *tripNotes;
	UITextView	*tripNotesText;
   
	BOOL dirty;
	Trip *trip;
	CLLocationDistance distance;
	NSInteger purposeIndex;
   NSInteger ease;
   NSInteger safety;
   NSInteger convenience;
	
	NSMutableArray *coords;
   NSManagedObjectContext *managedObjectContext;
   
	NSMutableData *receivedData;
	
	NSMutableArray *unSavedTrips;
	NSMutableArray *unSyncedTrips;
	NSMutableArray *zeroDistanceTrips;
}


@property (nonatomic, strong) id <ActivityIndicatorDelegate> activityDelegate;
@property (nonatomic, strong) id <UIAlertViewDelegate> alertDelegate;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIAlertView *saving;
@property (nonatomic, strong) UIAlertView *tripNotes;
@property (nonatomic, strong) UITextView *tripNotesText;

@property (assign) BOOL dirty;
@property (nonatomic, strong) Trip *trip;

@property (nonatomic, strong) NSMutableArray *coords;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSMutableData *receivedData;


- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context;
- (id)initWithTrip:(Trip*)trip;
- (BOOL)loadTrip:(Trip*)trip;
- (void)unloadTrip;

- (void)createTrip;
- (void)createTrip:(unsigned int)index;

- (CLLocationDistance)addCoord:(CLLocation*)location;
- (void)saveNotes:(NSString*)notes;
- (void)saveTrip;
- (void)showSaveDialog;

- (CLLocationDistance)getDistanceEstimate;

- (NSInteger)getPurposeIndex;

- (void)promptForTripNotes;

- (int)countUnSavedTrips;
- (int)countUnSyncedTrips;
- (int)countZeroDistanceTrips;

- (BOOL)loadMostRecentUnSavedTrip;
- (int)recalculateTripDistances;
- (CLLocationDistance)calculateTripDistance:(Trip*)_trip;

-(NSString *)setPurpose:(unsigned int)index ease:(unsigned int)ease safety:(unsigned int)safety convenience:(unsigned int)convenience;

@end


@interface TripPurpose : NSObject { }

+ (NSInteger)getPurposeIndex:(NSString*)string;
+ (NSString *)getPurposeString:(unsigned int)index;

@end


