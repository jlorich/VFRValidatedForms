//
//  VFRFormValidator.m
//
//  Copyright (c) 2014 Joseph Lorich.
//

#import "VFRFormValidator.h"

@implementation VFRFormValidator

# pragma mark - Initializers and generators

/**
 * Sets up a base validator
 */
- (id)init
{
  self = [super init];
  
  if (self)
  {
    _fields = [[NSMutableArray  alloc] init];
  }
  
  return self;
}

/**
 * Adds fields from a VA list
 */
- (void)addFieldsFromArguments:(va_list)fields
{
  if (fields)
  {
    VFRValidatedTextField *field;
    
    while ((field = va_arg(fields, VFRValidatedTextField *)))
    {
      [_fields addObject:field];
    }
  }
}


/**
 * Inits a validator for a set of fields
 */
- (id)initWithFields:(VFRValidatedTextField *)textField1,...
{
  self = [self init];
  
  if (textField1)
  {
    [_fields addObject:textField1];
    
    va_list fields;
    
    va_start(fields, textField1);
    [self addFieldsFromArguments:fields];
    va_end(fields);
  }
  
  return self;
}

/**
 * Builds a validator for a set of fields
 */
+ (VFRFormValidator *)formValidatorWithFields:(VFRValidatedTextField *)textField1,... {
  VFRFormValidator * validator = [[VFRFormValidator alloc] init];
  
  if (textField1)
  {
    [validator.fields addObject:textField1];
    
    va_list fields;
    
    va_start(fields, textField1);
    [validator addFieldsFromArguments:fields];
    va_end(fields);
  }
  
  return validator;
}

/**
 * Validates the form fields and generates the error message
 */
- (BOOL) validate {
  BOOL valid = YES;
  NSMutableString *errorMessage;
  
  // Gather error messages for any invalid fields
  for (VFRValidatedTextField *field in _fields)
  {
    if (!field.valid)
    {
      valid = NO;
      
      for (NSString *message in field.errorMessages)
      {
        if (!errorMessage)
        {
          errorMessage = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@" - %@", message]];
        }
        else
        {
          [errorMessage appendString:[NSString stringWithFormat:@"\n - %@", message]];
        }
      }
      
    }
  }
  
  self.errorMessage = valid ? nil : errorMessage;
  
  return valid;
}

/**
 * 
 */
- (BOOL) valid
{
  return [self validate];
}

@end
