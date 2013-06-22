//
//	TripDetailViewController.h
//	CycleTracks

#import <UIKit/UIKit.h>
#import "CustomPickerDataSource.h"
#import "TripPurposeDelegate.h"

@class StarSlider;

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

@property (nonatomic, retain) StarSlider *easeSlider;
@property (nonatomic, retain) StarSlider *safetySlider;
@property (nonatomic, retain) StarSlider *convenienceSlider;


- (id)initWithPurpose:(NSInteger)index;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end
