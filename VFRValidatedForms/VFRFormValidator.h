//
//  VFRFormValidator.h
//
//  Copyright (c) 2014 Joseph Lorich.
//

#import <Foundation/Foundation.h>
#import "VFRValidatedTextField.h"

/**
 * A form field validator
 */
@interface VFRFormValidator : NSObject


#pragma mark - Properties

/// The fields tied to this validator
@property (nonatomic) NSMutableArray *fields;

/// Whether or not the form is currently valid (triggers validation)
@property (readonly) BOOL valid;

/// A combined error message for this form
@property NSString *errorMessage;


#pragma mark - Methods

/**
 * Inits a validator for a set of fields
 */
- (id)initWithFields:(VFRValidatedTextField *)textField1,... NS_REQUIRES_NIL_TERMINATION;

/**
 * Creates a form validator based on a set of fields
 */
+ (VFRFormValidator *)formValidatorWithFields:(VFRValidatedTextField *)textField1,... NS_REQUIRES_NIL_TERMINATION;

/**
 * Check validity on all form fields
 */
- (BOOL) validate;

/**
 * Adds a general block validator
 */
//- (void)addBlockValidator:(ValidationBlock)block;


@end
