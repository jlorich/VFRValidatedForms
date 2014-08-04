//
//  VFRValidatedTextField.m
//
//  Copyright (c) 2014 Joseph Lorich.
//

#import "VFRValidatedTextField.h"


/*
 Unfotunately a UITextField cannot be its own delegate, due to a infinite loop in [self respondsToSelector]
 because of this, delegate methods are routed through another object
 Reference: http://www.cocoabuilder.com/archive/cocoa/241465-iphone-why-can-a-uitextfield-be-its-own-delegate.html#241505
 */
@interface DelegateHandler : NSObject<UITextFieldDelegate>


/**
 * The validated text field this is a delegate for
 */
@property VFRValidatedTextField *textField;

/**
 * Init
 */
- (id)initWithValidatingTextField:(VFRValidatedTextField *)textField;


@end


#pragma mark - VFRValidatedTextField internal interface

@interface VFRValidatedTextField()
{
  UIColor *_baseTextColor;
}

/**
 * The internal delegate handler
 */
@property (strong, nonatomic) DelegateHandler *delegateHandler;

/**
 * The forward delegate for this tableView
 *
 * This UITextField implements some methods of UITextFieldDelegate to assist in validation, however
 * since we still want the user to be able to use a UITextField delegate, we use this to store the user's
 * delegate and forward methods calls to it.
 */
@property (nonatomic, assign) id <UITextFieldDelegate> forwardDelegate;


@end


#pragma mark - VFRValidatedTextField implementation


@implementation VFRValidatedTextField

@synthesize valid = _valid;


#pragma mark - Initializers

/**
 * Calls setup on init with frame
 */
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setup];
  }
  return self;
}

/**
 * Calls setup on init with coder
 */
- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if ( self ) {
    [self setup];
  }
  return self;
}

/**
 * Calls setup on init
 */
- (id)init
{
  self = [super init];
  
  if ( self ) {
    [self setup];
  }
  return self;
}

/**
 * Sets up the delegate to be the DelegateRouter
 */
- (void)setup
{
  // Init the delegate router with this text field
  _delegateHandler = [[DelegateHandler alloc] initWithValidatingTextField:self];
  
  // Set the delegate on super to enable use of the forward delegate
  [super setDelegate:_delegateHandler];
  
  _errorMessages = [[NSMutableArray alloc] init];
  _baseTextColor = self.textColor;
  _validateOnTextChange = YES;
}


#pragma mark - Add Validations

/**
 * Appends blockValidation to self.validations if it isn't blank
 */
- (void)addBlockValidation:(ValidationBlock)blockValidation
{
  if (!_validations)
    _validations = @[blockValidation];
  else if (blockValidation) [_validations arrayByAddingObject:blockValidation];
}


/**
 * Builds a block validation that checks a string against a regular expression and calls
 * [self addBlockValidation] with it
 */
- (void)addRegexValidation:(NSString*)regexValidation errorMessage:(NSString *)errorMessage
{
  if (!regexValidation) return;
  
  ValidationBlock regexBlock = (ValidationBlock)^(NSString *text, NSMutableArray *errorStrings){
    BOOL valid = ([text rangeOfString:regexValidation options:NSRegularExpressionSearch].location != NSNotFound);
    
    if (!valid && errorMessage) [errorStrings addObject:errorMessage];
    
    return valid;
  };
  
  [self addBlockValidation:regexBlock];
}


#pragma mark - Set/Check validity

/**
 * Manually sets validity and calls post validation
 */
- (void)setValid:(BOOL)valid
{
  _valid = valid;
  if ( _postValidationBlock ) {
    _postValidationBlock(_valid);
  }
}

/**
 * Is this field currently valid (triggers validation)
 */
- (BOOL)valid
{
  return [self validateAgainstString:self.text];
}

/**
 * Validates the current field against a given string
 */
- (BOOL)validateAgainstString:(NSString *)string
{
  // Clear error messages
  [_errorMessages removeAllObjects];
  
  // Assume base validity of true
  BOOL valid = true;
  
  // Check for failing validations
  for (ValidationBlock validationBlock in _validations)
  {
    if (!validationBlock(string, _errorMessages))
    {
      valid = false;
    }
  }
  
  _valid = valid;
  
  [self updateTextColor];
  
  if (_postValidationBlock) _postValidationBlock(_valid);
  
  return valid;
}

/**
 * Calls [self validateAgainstString] with the current text
 */
- (void)revalidate {
  [self validateAgainstString:self.text];
}


#pragma mark - Colors and error methods

/**
 * Updates the text color based on validity and whether or not there is a color set
 */
- (void)updateTextColor
{
  if (_valid && _validTextColor)
    [self setTextColor:_validTextColor];
  
  if (!_valid && _invalidTextColor)
    [self setTextColor:_invalidTextColor];
}

/**
 * joins _errorMessages or returns @""
 */
- (NSString *)errorMessage
{
  NSString *combined = [_errorMessages componentsJoinedByString:@"\n"];
  
  if (combined)
    return combined;
  else
    return @"";
}


#pragma mark - Delegate forwarding methods

/**
 * Override setting the delegate to enable use of both the DelegateRouter and
 * a custom delegate designated by the user
 */
- (void)setDelegate:(id <UITextFieldDelegate>)delegate
{
  if (delegate == _delegateHandler) return;
  
  self.forwardDelegate = delegate;
}

@end


#pragma mark - Delegate Handler


@implementation DelegateHandler


/**
 * Inits a new delegate handler
 */
- (id)initWithValidatingTextField:(VFRValidatedTextField *)textField
{
  self = [super init];
  _textField = textField;
  return self;
}


#pragma mark - UITextFieldDelegate methods
/**
 * Fires on text field character change
 * Validates if appropriate  and calls the forward delegate if appropriate
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  // Validate
  if (_textField.validateOnTextChange)
    [_textField validateAgainstString:[_textField.text stringByReplacingCharactersInRange:range withString:string]];

  // Forward delegate call
  if ([_textField.forwardDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
    return [_textField.forwardDelegate textField:_textField shouldChangeCharactersInRange:range replacementString:string];
  else
    return YES;
}

/**
 * Fires when the text field editing in finished
 * Validates if appropriate and calls the forward delegate if appropriate
 */
- (void)textFieldDidEndEditing:(UITextField *)textField
{
  // Validate
  if (!_textField.validateOnTextChange)
    [_textField validateAgainstString:textField.text];
  
  // Forward delegate call
  if ([_textField.forwardDelegate respondsToSelector:@selector(textFieldDidEndEditing:)])
    return [_textField.forwardDelegate textFieldDidEndEditing:textField];
}


#pragma mark - Delegate Forwarding

/**
 * Returns YES if DelegateRouter or the ForwardDelegate respond to the selector
 */
- (BOOL)respondsToSelector:(SEL)aSelector
{
  return [super respondsToSelector:aSelector] || [_textField.forwardDelegate respondsToSelector:aSelector];
}

/**
 * Pass off any methods not implemented by DelegateRouter to the delegate the user set on _textField
 */
- (id)forwardingTargetForSelector:(SEL)aSelector
{
  if ([super respondsToSelector:aSelector]) return self;
  if ([_textField.forwardDelegate respondsToSelector:aSelector]) return _textField.forwardDelegate;
  
  return nil;
}


@end
