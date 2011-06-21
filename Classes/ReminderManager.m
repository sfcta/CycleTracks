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
//  ReminderManager.m
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/30/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>


#include <AudioToolbox/AudioToolbox.h>
#import "constants.h"
#import "ReminderManager.h"
#import "TripManager.h"


#define k15Minutes	900
#define k5Minutes	300

//#define kBatteryLevelThreshold	0.90
#define kBatteryLevelThreshold	0.20

//#define kEnableTestReminder		YES
#define kEnableTestReminder		NO


/*
 Let's use a dual bike bell/vibrate every 5 idle minutes, every 15 minutes starting at 30 minutes (non idle).  
 Additionally, we should do an auto shutoff after 20 idle minutes (i put my phone in my desk drawer and went 
 to a meeting), and after 180 total minutes (will the battery even last that long? basically we just want to 
 shut it off before the battery is killed...is there a way for app to know what the battery level is?  that 
 would be cool).  
 */


@interface Reminder : NSObject <UIAlertViewDelegate>
{
	id <RecordingInProgressDelegate> delegate;
	NSTimer *timer;
	
	BOOL audible;
	BOOL battery;
	BOOL enabled;
	BOOL vibrate;
}

@property (nonatomic, retain) id <RecordingInProgressDelegate> delegate;
@property (assign) BOOL audible;
@property (assign) BOOL battery;
@property (assign) BOOL enabled;
@property (assign) BOOL vibrate;

- (void)trigger:(NSTimer*)theTimer;

@end


@implementation Reminder
@synthesize delegate, audible, battery, enabled, vibrate;

- (void)trigger:(NSTimer*)theTimer
{
	if ( audible && enabled && vibrate )
	{
		CFURLRef		soundFileURLRef;
		SystemSoundID	soundFileObject;
		
		// Get the main bundle for the app
		CFBundleRef mainBundle = CFBundleGetMainBundle();
		
		// Get the URL to the sound file to play
		soundFileURLRef = CFBundleCopyResourceURL( mainBundle, CFSTR ("bicycle-bell-normalized"), CFSTR ("aiff"), NULL );
		
		// Create a system sound object representing the sound file
		AudioServicesCreateSystemSoundID( soundFileURLRef, &soundFileObject );
		
		// play audio + vibrate
		AudioServicesPlayAlertSound( soundFileObject );
		/*		
		 // just vibrate
		 AudioServicesPlaySystemSound( kSystemSoundID_Vibrate );
		 */
	}
	
	if ( battery && delegate )
	{
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
		if ( device.batteryLevel < kBatteryLevelThreshold )
		{
			// halt location updates
			[[delegate getLocationManager] stopUpdatingLocation];

			// re-enable screen lock
			[UIApplication sharedApplication].idleTimerDisabled = NO;
			
			// notify user
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kBatteryTitle
															message:kBatteryMessage
														   delegate:self
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
			
			// note this in saved data?
			// exit app?
			
			// set battery to NO to prevent multiple re-triggerings of this dialog box
			battery = NO;
		}
	}
}

- (id)initWithFireDate:(NSDate *)date
			  interval:(NSTimeInterval)seconds
			  delegate:(id <RecordingInProgressDelegate>)_delegate
{
	NSLog(@"Reminder initWithFireDate: %@ interval: %f", date, seconds);
	if ( self = [super init] )
	{
		self.delegate = _delegate;
		
		self.audible = YES;
		self.battery = YES;
		self.enabled = YES;
		self.vibrate = YES;
		
		// schedule our reminder to fire
		timer = [[NSTimer alloc] initWithFireDate:date 
										 interval:seconds 
										   target:self
										 selector:@selector(trigger:) 
										 userInfo:nil 
										  repeats:YES];
		
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
		[runLoop addTimer:timer forMode:NSDefaultRunLoopMode]; 
	}
	
	return self;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	// user has acknowledged battery alert => re-enable
	battery = YES;
}

@end


@implementation ReminderManager
@synthesize reminders;

- (id)initWithRecordingInProgressDelegate:(id <RecordingInProgressDelegate>)delegate
{
	if ( self = [super init] )
	{
		//NSLog(@"ReminderManager init");
		reminders = [[NSMutableArray arrayWithCapacity:10] retain];
		
		// add reminders here
		if ( kEnableTestReminder )
			[reminders addObject:[[Reminder alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:60] 
														   interval:30
														   delegate:delegate]];
			
		[reminders addObject:[[Reminder alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:k15Minutes] 
													   interval:k5Minutes
													   delegate:delegate]];
	}
	
	return self;
}


- (void)enableReminders
{
	NSLog(@"enableReminders");
	if ( [reminders count] )
	{
		NSEnumerator *enumerator = [reminders objectEnumerator];
		Reminder *reminder;
		while ( reminder = [enumerator nextObject] )
			reminder.enabled = YES;
	}		
}


- (void)disableReminders
{
	NSLog(@"disableReminders");
	if ( [reminders count] )
	{
		NSEnumerator *enumerator = [reminders objectEnumerator];
		Reminder *reminder;
		while ( reminder = [enumerator nextObject] )
			reminder.enabled = NO;
	}		
}


@end
