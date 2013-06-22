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
//  CustomPickerDataSource.m
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

#import "CustomPickerDataSource.h"
#import "CustomView.h"
#import "TripPurposeDelegate.h"

@implementation CustomPickerDataSource

@synthesize customPickerArray, parent;

- (id)init
{
	// use predetermined frame size
	self = [super init];
	if (self)
	{
		// create the data source for this custom picker
		NSMutableArray *viewArray = [[NSMutableArray alloc] init];

		/*
		 * Commute
		 * School
		 * Work-Related
		 * Exercise
		 * Social
		 * Shopping
		 * Errand
		 * Other
		 */
		
		CustomView *view;
		view = [[CustomView alloc] initWithFrame:CGRectZero];
		view.title = @"Commute";
		view.image = [UIImage imageNamed:kTripPurposeCommuteIcon];
		[viewArray addObject:view];
		[view release];
		
		view = [[CustomView alloc] initWithFrame:CGRectZero];
		view.title = @"School";
		view.image = [UIImage imageNamed:kTripPurposeSchoolIcon];
		[viewArray addObject:view];
		[view release];
		
		view = [[CustomView alloc] initWithFrame:CGRectZero];
		view.title = @"Work-Related";
		view.image = [UIImage imageNamed:kTripPurposeWorkIcon];
		[viewArray addObject:view];
		[view release];
		
		view = [[CustomView alloc] initWithFrame:CGRectZero];
		view.title = @"Exercise";
		view.image = [UIImage imageNamed:kTripPurposeExerciseIcon];
		[viewArray addObject:view];
		[view release];
		
		view = [[CustomView alloc] initWithFrame:CGRectZero];
		view.title = @"Social";
		view.image = [UIImage imageNamed:kTripPurposeSocialIcon];
		[viewArray addObject:view];
		[view release];
		
		view = [[CustomView alloc] initWithFrame:CGRectZero];
		view.title = @"Shopping";
		view.image = [UIImage imageNamed:kTripPurposeShoppingIcon];
		[viewArray addObject:view];
		[view release];
		
		view = [[CustomView alloc] initWithFrame:CGRectZero];
		view.title = @"Errand";
		view.image = [UIImage imageNamed:kTripPurposeErrandIcon];
		[viewArray addObject:view];
		[view release];
		
		view = [[CustomView alloc] initWithFrame:CGRectZero];
		view.title = @"Other";
		view.image = [UIImage imageNamed:kTripPurposeOtherIcon];
		[viewArray addObject:view];
		[view release];

		self.customPickerArray = viewArray;
		[viewArray release];
	}
	return self;
}

- (void)dealloc
{
	[customPickerArray release];
	[super dealloc];
}


#pragma mark UIPickerViewDataSource


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	return [CustomView viewWidth];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return [CustomView viewHeight];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [customPickerArray count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}


#pragma mark UIPickerViewDelegate


// tell the picker which view to use for a given component and row, we have an array of views to show
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
		  forComponent:(NSInteger)component reusingView:(UIView *)view
{
	return [customPickerArray objectAtIndex:row];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	//NSLog(@"child didSelectRow: %d inComponent:%d", row, component);
	[parent pickerView:pickerView didSelectRow:row inComponent:component];
}



@end
