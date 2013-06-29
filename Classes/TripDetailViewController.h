//
//	TripDetailViewController.h
//	CycleTracks
//

//
// Adapted to Open Bike by Gregory Kip (gkip@permusoft.com) and others.
//

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


@property (nonatomic, strong) id <TripPurposeDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIPickerView *customPickerView;
@property (nonatomic, strong) CustomPickerDataSource *customPickerDataSource;

@property (nonatomic, strong) StarSlider *easeSlider;
@property (nonatomic, strong) StarSlider *safetySlider;
@property (nonatomic, strong) StarSlider *convenienceSlider;


- (id)initWithPurpose:(NSInteger)index;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end
