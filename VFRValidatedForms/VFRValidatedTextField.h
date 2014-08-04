//
//  VFRValidatedTextField.h
//
//  Copyright (c) 2014 Joseph Lorich.
//

#import <UIKit/UIKit.h>

/// Validation block type
typedef BOOL(^ValidationBlock)(NSString *text, NSMutableArray *errors);

/// Post validation block type
typedef void(^PostValidationBlock)(BOOL valid);


/**
 * A validated text field
 */
@interface VFRValidatedTextField : UITextField


#pragma mark - Properties

/// Manually set text field validity (triggers postValidationBlock)
@property (nonatomic, assign) BOOL valid;

/// Should text validate on each change (defaults to yes)
/// If false, validation will occur when editing is finished
@property (nonatomic, assign) BOOL validateOnTextChange;

/// An array of NSString regular expressions to validate against
@property (nonatomic, retain) NSArray *validations;

/// An array of error messages for validation faliure
@property (readonly) NSMutableArray *errorMessages;

/// A single error message for this field
@property (readonly) NSString *errorMessage;

/// If set, set this text color when valid
@property (nonatomic, retain) UIColor *validTextColor;
  
/// If set, set this text color when invalid
@property (nonatomic, retain) UIColor *invalidTextColor;


#pragma mark - Block Properties

/// A block that will be run after validation
@property (strong, nonatomic) PostValidationBlock postValidationBlock;


#pragma mark - Methods

/**
 * Adds a block validation to this field
 * This block should return whether the field is valid/invalid
 * This block should also add any appropriate errors to the given errors array
 */
- (void)addBlockValidation:(ValidationBlock)blockValidation;

/**
 * Adds a regex validation to this field
 */
- (void)addRegexValidation:(NSString*)regexValidation errorMessage:(NSString *)errorMessage;

/**
 * Revalidates the textfield against it's current text
 */
- (void)revalidate;


@end
