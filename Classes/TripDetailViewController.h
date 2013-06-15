//
//	TripDetailViewController.h
//	CycleTracks

#import <UIKit/UIKit.h>
#import "CustomPickerDataSource.h"
#import "TripPurposeDelegate.h"


@interface TripDetailViewController : UIViewController <UIPickerViewDelegate>
{
	id <TripPurposeDelegate> delegate;
	UIPickerView			*customPickerView;
	CustomPickerDataSource	*customPickerDataSource;
	
	UITextView				*description;
}


@property (nonatomic, retain) id <TripPurposeDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIPickerView *customPickerView;
@property (nonatomic, retain) CustomPickerDataSource *customPickerDataSource;

- (id)initWithPurpose:(NSInteger)index;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end
