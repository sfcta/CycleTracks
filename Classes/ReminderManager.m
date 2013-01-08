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
//  ReminderManager.m
//  CycleTracks
//
//  Copyright 2009-2013 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/30/09.
//	For more information on the project, 
//	e-mail Elizabeth Sall at the SFCTA <elizabeth.sall@sfcta.org>


#include <AudioToolbox/AudioToolbox.h>
#import "constants.h"
#import "ReminderManager.h"
#import "TripManager.h"


#define k15Minutes	900
#define k10Minutes	600
#define kNumReminders 10

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


- (id)initWithFirstFireInterval:(NSTimeInterval)first_seconds
                       interval:(NSTimeInterval)seconds
                       delegate:(id <RecordingInProgressDelegate>)_delegate
{
    NSLog(@"Reminder initWithFirstFireInterval: %f interval: %f", first_seconds, seconds);
	if ( self = [super init] )
	{
		self.delegate = _delegate;
		
		self.audible = YES;
		self.battery = YES;
		self.enabled = YES;
		self.vibrate = YES;
		
		// schedule all of our reminders to fire
        for (int reminder_num=0; reminder_num < kNumReminders; reminder_num++) {
            UILocalNotification *localNotif = [[UILocalNotification alloc] init];
            localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:(reminder_num==0 ? first_seconds : first_seconds+reminder_num*seconds)];
            localNotif.timeZone = [NSTimeZone defaultTimeZone];
            localNotif.alertBody = [NSString stringWithFormat:@"CycleTracks <%d> has been recording for %d minutes",
                                    getpid(), (int)(reminder_num==0 ? first_seconds : first_seconds+reminder_num*seconds)/60];
        
            localNotif.soundName = @"bicycle-bell-normalized.aiff"; // UILocalNotificationDefaultSoundName;
            //NSDictionary *infoDict = [NSDictionary dictionaryWithObject:item.eventName forKey:ToDoItemKey];
            //localNotif.userInfo = infoDict;
        
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
            [localNotif release];
        }
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
			[reminders addObject:[[Reminder alloc] initWithFirstFireInterval:120
                                                                    interval:120
                                                                    delegate:delegate]];
			
		[reminders addObject:[[Reminder alloc] initWithFirstFireInterval:k15Minutes
                                                                interval:k10Minutes
                                                                delegate:delegate]];
	}
	
	return self;
}


- (void)disableReminders
{
	NSLog(@"disableReminders");
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}


@end
