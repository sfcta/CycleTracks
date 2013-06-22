//
//	TripDetailViewController.m
//	CycleTracks
//

#import "CustomView.h"
#import "TripDetailViewController.h"
#import "StarSlider.h"

@implementation TripDetailViewController

@synthesize customPickerView, customPickerDataSource, delegate;
@synthesize easeSlider, safetySlider, convenienceSlider;


// return the picker frame based on its size
- (CGRect)pickerFrameWithSize:(CGSize)size
{
	
	// layout at bottom of page
	/*
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    CGRect pickerRect = CGRectMake(	0.0,
    screenRect.size.height - 84.0 - size.height,
    size.width,
    size.height);
	 */
	
	// layout at top of page
	//CGRect pickerRect = CGRectMake(	0.0, 0.0, size.width, size.height );
	
	// layout at top of page, leaving room for translucent nav bar
	//CGRect pickerRect = CGRectMake(	0.0, 43.0, size.width, size.height );
	CGRect pickerRect = CGRectMake(	0.0, 43.0, size.width, size.height );
	return pickerRect;
}


- (void)createCustomPicker
{
	customPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
	customPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	// setup the data source and delegate for this picker
	customPickerDataSource = [[CustomPickerDataSource alloc] init];
	customPickerDataSource.parent = self;
	customPickerView.dataSource = customPickerDataSource;
	customPickerView.delegate = customPickerDataSource;
	
	// note we are using CGRectZero for the dimensions of our picker view,
	// this is because picker views have a built in optimum size,
	// you just need to set the correct origin in your view.
	//
	// position the picker at the bottom
	CGSize pickerSize = [customPickerView sizeThatFits:CGSizeZero];
	customPickerView.frame = [self pickerFrameWithSize:pickerSize];
	
	customPickerView.showsSelectionIndicator = YES;
	
	// add this picker to our view controller, initially hidden
	//customPickerView.hidden = YES;
	[self.view addSubview:customPickerView];
}


- (IBAction)cancel:(id)sender
{
	[delegate didCancelPurpose];
}


- (IBAction)save:(id)sender
{
	NSInteger row = [customPickerView selectedRowInComponent:0];
	//[delegate didPickPurpose:row];
   [delegate didPickPurpose:row ease:[self.easeSlider value] safety:[self.safetySlider value] convenience:[self.convenienceSlider value]];
}


- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
	NSLog(@"initWithNibNamed");
	if (self = [super initWithNibName:nibName bundle:nibBundle])
	{
		//NSLog(@"TripDetailViewController init");
		[self createCustomPicker];
		
		// picker defaults to top-most item => update the description
		[self pickerView:customPickerView didSelectRow:0 inComponent:0];
	}
	return self;
}


- (id)initWithPurpose:(NSInteger)index
{
	if (self = [self init])
	{
		//NSLog(@"TripDetailViewController initWithPurpose: %d", index);
		
		// update the picker
		[customPickerView selectRow:index inComponent:0 animated:YES];
		
		// update the description
		[self pickerView:customPickerView didSelectRow:index inComponent:0];
	}
	return self;
}


- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"Trip Purpose", @"");
   
	//self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	// self.view.backgroundColor = [[UIColor alloc] initWithRed:40. green:42. blue:57. alpha:1. ];
   
	// Set up the buttons.
	/*
    UIBarButtonItem* done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
    target:self action:@selector(done)];
    done.enabled = YES;
    self.navigationItem.rightBarButtonItem = done;
	 */
	//[self.navigationController setNavigationBarHidden:NO animated:YES];
	UIColor *transparent = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
   
   self.easeSlider = [StarSlider control];
	[self.easeSlider setFrame:CGRectMake(128.0, 274.0, 192.0, 34.0) ];
	self.easeSlider.backgroundColor = transparent;
   [self.view addSubview:self.easeSlider];
	
   self.safetySlider = [StarSlider control];
	[self.safetySlider setFrame:CGRectMake(128.0, 324.0, 192.0, 34.0)];
	self.safetySlider.backgroundColor = transparent;
   [self.view addSubview:self.safetySlider];
   
   self.convenienceSlider = [StarSlider control];
	[self.convenienceSlider setFrame:CGRectMake(128.0, 374.0, 192.0, 34.0)];
	self.convenienceSlider.backgroundColor = transparent;
   [self.view addSubview:self.convenienceSlider];
}


// called after the view controller's view is released and set to nil.
// For example, a memory warning which causes the view to be purged. Not invoked as a result of -dealloc.
// So release any properties that are loaded in viewDidLoad or can be recreated lazily.
//
- (void)viewDidUnload
{
	[super viewDidUnload];
	self.customPickerView = nil;
	self.customPickerDataSource = nil;
}


- (void)dealloc
{
	[customPickerDataSource release];
	[customPickerView release];
	
	[super dealloc];
}


#pragma mark UIPickerViewDelegate


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	NSLog(@"parent didSelectRow: %d inComponent:%d not setting description", row, component);
}


@end

