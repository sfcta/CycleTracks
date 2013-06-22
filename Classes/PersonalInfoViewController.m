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
//  PersonalInfoViewController.m
//  CycleTracks
//
//  Copyright 2009-2013 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/23/09.
//	For more information on the project, 
//	e-mail Elizabeth Sall at the SFCTA <elizabeth.sall@sfcta.org>
//

//
// Adapted to Open Bike by Gregory Kip (gkip@permusoft.com) and others.
//


#import "PersonalInfoViewController.h"
#import "User.h"

#define kMaxCyclingFreq 3

@implementation PersonalInfoViewController

@synthesize delegate, managedObjectContext, user;
@synthesize age, email, gender, homeZIP, workZIP, schoolZIP, cyclingFreq;


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
    }
    return self;
}


- (id)init
{
	NSLog(@"INIT");
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
    }
    return self;
}


- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		NSLog(@"PersonalInfoViewController::initWithManagedObjectContext");
		self.managedObjectContext = context;
    }
    return self;
}

/*
- (void)initTripManager:(TripManager*)manager
{
	self.managedObjectContext = manager.managedObjectContext;
}
*/

- (UITextField*)initTextFieldAlpha
{
	CGRect frame = CGRectMake( 152, 7, 138, 29 );
	UITextField *textField = [[UITextField alloc] initWithFrame:frame];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.textAlignment = UITextAlignmentRight;
	textField.placeholder = @"";
	textField.keyboardType = UIKeyboardTypeDefault;
	textField.returnKeyType = UIReturnKeyDone;
	textField.delegate = self;
	return textField;
}


- (UITextField*)initTextFieldEmail
{
	CGRect frame = CGRectMake( 152, 7, 138, 29 );
	UITextField *textField = [[UITextField alloc] initWithFrame:frame];
	textField.autocapitalizationType = UITextAutocapitalizationTypeNone,
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.textAlignment = UITextAlignmentRight;
	textField.placeholder = @"";
	textField.keyboardType = UIKeyboardTypeEmailAddress;
	textField.returnKeyType = UIReturnKeyDone;
	textField.delegate = self;
	return textField;
}


- (UITextField*)initTextFieldNumeric
{
	CGRect frame = CGRectMake( 152, 7, 138, 29 );
	UITextField *textField = [[UITextField alloc] initWithFrame:frame];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.textAlignment = UITextAlignmentRight;
	textField.placeholder = @"12345";
	textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	textField.returnKeyType = UIReturnKeyDone;
	textField.delegate = self;
	return textField;
}


- (User *)createUser
{
	// Create and configure a new instance of the User entity
	User *noob = (User *)[[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext] retain];
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"createUser error %@, %@", error, [error localizedDescription]);
	}
	
	return noob;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

	// Set the title.
	// self.title = @"Personal Info";
	
	// initialize text fields
	self.age		= [self initTextFieldNumeric];
	self.email		= [self initTextFieldEmail];
	self.gender		= [self initTextFieldAlpha];
	self.homeZIP	= [self initTextFieldNumeric];
	self.workZIP	= [self initTextFieldNumeric];
	self.schoolZIP	= [self initTextFieldNumeric];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;

	// Set up the buttons.
	UIBarButtonItem* done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
																		  target:self action:@selector(done)];
	done.enabled = YES;
	self.navigationItem.rightBarButtonItem = done;
	
	NSFetchRequest		*request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	NSError *error;
	NSInteger count = [managedObjectContext countForFetchRequest:request error:&error];
	NSLog(@"saved user count  = %d", count);
	if ( count == 0 )
	{
		// create an empty User entity
		[self setUser:[self createUser]];
	}
	
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
		NSLog(@"no saved user");
		if ( error != nil )
			NSLog(@"PersonalInfo viewDidLoad fetch error %@, %@", error, [error localizedDescription]);
	}
	
	[self setUser:[mutableFetchResults objectAtIndex:0]];
	if ( user != nil )
	{
		// initialize text fields to saved personal info
		age.text		= user.age;
		email.text		= user.email;
		gender.text		= user.gender;
		homeZIP.text	= user.homeZIP;
		workZIP.text	= user.workZIP;
		schoolZIP.text	= user.schoolZIP;
		
		// init cycling frequency
		NSLog(@"init cycling freq: %d", [user.cyclingFreq intValue]);
		cyclingFreq		= [NSNumber numberWithInt:[user.cyclingFreq intValue]];
		
		if ( !([user.cyclingFreq intValue] > kMaxCyclingFreq) )
			[self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:[user.cyclingFreq integerValue] 
																					  inSection:2]];
	}
	else
		NSLog(@"init FAIL");
	
	[mutableFetchResults release];
	[request release];
}


#pragma mark UITextFieldDelegate methods


// the user pressed the "Done" button, so dismiss the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	NSLog(@"textFieldShouldReturn");
	[textField resignFirstResponder];
	return YES;
}


// save the new value for this textField
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	NSLog(@"textFieldDidEndEditing");
	
	// save value
	if ( user != nil )
	{
		if ( textField == age )
		{
			NSLog(@"saving age: %@", age.text);
			[user setAge:age.text];
		}
		if ( textField == email )
		{
			NSLog(@"saving email: %@", email.text);
			[user setEmail:email.text];
		}
		if ( textField == gender )
		{
			NSLog(@"saving gender: %@", gender.text);
			[user setGender:gender.text];
		}
		if ( textField == homeZIP )
		{
			NSLog(@"saving homeZIP: %@", homeZIP.text);
			[user setHomeZIP:homeZIP.text];
		}
		if ( textField == schoolZIP )
		{
			NSLog(@"saving schoolZIP: %@", schoolZIP.text);
			[user setSchoolZIP:schoolZIP.text];
		}
		if ( textField == workZIP )
		{
			NSLog(@"saving workZIP: %@", workZIP.text);
			[user setWorkZIP:workZIP.text];
		}
		
		NSError *error;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"PersonalInfo save textField error %@, %@", error, [error localizedDescription]);
		}
	}
}


- (void)done
{
   NSError *error;

	if ( user != nil )
	{
		NSLog(@"saving age: %@", age.text);
		[user setAge:age.text];

		NSLog(@"saving email: %@", email.text);
		[user setEmail:email.text];

		NSLog(@"saving gender: %@", gender.text);
		[user setGender:gender.text];

		NSLog(@"saving homeZIP: %@", homeZIP.text);
		[user setHomeZIP:homeZIP.text];

		NSLog(@"saving schoolZIP: %@", schoolZIP.text);
		[user setSchoolZIP:schoolZIP.text];

		NSLog(@"saving workZIP: %@", workZIP.text);
		[user setWorkZIP:workZIP.text];
		
		NSLog(@"saving cycling freq: %d", [cyclingFreq intValue]);
		[user setCyclingFreq:cyclingFreq];

		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"PersonalInfo save cycling freq error %@, %@", error, [error localizedDescription]);
		}
	}
	else
		NSLog(@"ERROR can't save personal info for nil user");
	
	// update UI
	// TODO: test for at least one set value
	[delegate setSaved:YES];
   
   NSString *title = (user == nil) ? @"Error!" : @"Got it!";
   NSString *message = (user == nil) ? [error localizedDescription] : @"Your data will be associated with your routes. You may change or delete your data at any time.";

   
   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Thanks, Open Bike!" otherButtonTitles:nil];
   [alertView show];
	
	[self.navigationController popViewControllerAnimated:YES];
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
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
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
		default:
			return @"Tell us about yourself";
			break;
		case 1:
			return @"Your typical commute";
			break;
		case 2:
			return @"Your cycling frequency";
			break;
	}
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch ( section )
	{
		case 0:
			return 3;
			break;
		case 1:
			return 3;
			break;
		case 2:
			return 4;
			break;
		default:
			return 0;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    // Set up the cell...
	UITableViewCell *cell = nil;
	
	// outer switch statement identifies section
	switch ([indexPath indexAtPosition:0])
	{
		case 0:
		{
			static NSString *CellIdentifier = @"CellTextField";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}

			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
					cell.textLabel.text = @"Age";
					[cell.contentView addSubview:age];
					break;
				case 1:
					cell.textLabel.text = @"Email";
					[cell.contentView addSubview:email];
					break;
				case 2:
					cell.textLabel.text = @"Gender";
					[cell.contentView addSubview:gender];
					break;
			}
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
	
		case 1:
		{
			static NSString *CellIdentifier = @"CellTextField";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}

			switch ([indexPath indexAtPosition:1])
			{
				case 0:
					cell.textLabel.text = @"Home ZIP";
					[cell.contentView addSubview:homeZIP];
					break;
				case 1:
					cell.textLabel.text = @"Work ZIP";
					[cell.contentView addSubview:workZIP];
					break;
				case 2:
					cell.textLabel.text = @"School ZIP";
					[cell.contentView addSubview:schoolZIP];
					break;
			}
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
			
		case 2:
		{
			static NSString *CellIdentifier = @"CellCheckmark";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
			
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
					cell.textLabel.text = @"Less than once a month";
					break;
				case 1:
					cell.textLabel.text = @"Several times per month";
					break;
				case 2:
					cell.textLabel.text = @"Several times per week";
					break;
				case 3:
					cell.textLabel.text = @"Daily";
					break;
			}
			/*
			if ( user != nil )
				if ( [user.cyclingFreq intValue] == [indexPath indexAtPosition:1] )
					cell.accessoryType = UITableViewCellAccessoryCheckmark;
			 */
			if ( [cyclingFreq intValue] == [indexPath indexAtPosition:1] )
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			else
				cell.accessoryType = UITableViewCellAccessoryNone;
		}
	}
	
	// debug
	//NSLog(@"%@", [cell subviews]);
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];

    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];

	// outer switch statement identifies section
	switch ([indexPath indexAtPosition:0])
	{
		case 0:
		{
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
					break;
				case 1:
					break;
			}
			break;
		}
			
		case 1:
		{
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
					break;
				case 1:
					break;
			}
			break;
		}
		
		case 2:
		{
			// cycling frequency
			// remove all checkmarks
			UITableViewCell *cell;
			cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:2]];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:2]];
			cell.accessoryType = UITableViewCellAccessoryNone;
			
			// apply checkmark to selected cell
			cell = [tableView cellForRowAtIndexPath:indexPath];
			cell.accessoryType = UITableViewCellAccessoryCheckmark;

			// store cycling freq
			cyclingFreq = [NSNumber numberWithInt:[indexPath indexAtPosition:1]];
			NSLog(@"setting instance variable cycling freq: %d", [cyclingFreq intValue]);
		}
	}
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
    [super dealloc];
}


@end

