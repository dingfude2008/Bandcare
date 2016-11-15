//
//  HTAutocompleteTextField.m
//  HotelTonight
//
//  Created by Jonathan Sibley on 11/29/12.
//  Inspired by DOAutocompleteTextField by DoAT.
//
//  Copyright (c) 2012 Hotel Tonight. All rights reserved.
//

#import "HTAutocompleteTextField.h"

static NSObject<HTAutocompleteDataSource> *DefaultAutocompleteDataSource = nil;

@interface HTAutocompleteTextField ()

@property (nonatomic, strong) NSString *autocompleteString;

@end

@implementation HTAutocompleteTextField

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self setupAutocompleteTextField];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setupAutocompleteTextField];    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self];
}

- (void)setupAutocompleteTextField
{
    self.autocompleteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.autocompleteLabel.font = self.font;
    self.autocompleteLabel.backgroundColor = [UIColor clearColor];
    self.autocompleteLabel.textColor = [UIColor lightGrayColor];
    
    self.autocompleteLabel.lineBreakMode = NSLineBreakByClipping; //UILineBreakModeClip
    self.autocompleteLabel.hidden = YES;
    [self addSubview:self.autocompleteLabel];
    [self bringSubviewToFront:self.autocompleteLabel];

    self.autocompleteString = @"";

    self.ignoreCase = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ht_textDidChange:) name:UITextFieldTextDidChangeNotification object:self];
}

#pragma mark - Configuration

+ (void)setDefaultAutocompleteDataSource:(id)dataSource
{
    DefaultAutocompleteDataSource = dataSource;
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self.autocompleteLabel setFont:font];
}

#pragma mark - UIResponder

- (BOOL)becomeFirstResponder
{
    if (!self.autocompleteDisabled)
    {
        if ([self clearsOnBeginEditing])
        {
            self.autocompleteLabel.text = @"";
        }

        self.autocompleteLabel.hidden = NO;
    }

    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    if (!self.autocompleteDisabled)
    {
        self.autocompleteLabel.hidden = YES;

        [self commitAutocompleteText];

        // This is necessary because committing the autocomplete text changes the text field's text, but for some reason UITextField doesn't post the UITextFieldTextDidChangeNotification notification on its own
        [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification
                                                            object:self];
    }

    return [super resignFirstResponder];
}

#pragma mark - Autocomplete Logic

- (CGRect)autocompleteRectForBounds:(CGRect)bounds
{
    CGRect returnRect = CGRectZero;
    CGRect textRect = [self textRectForBounds:self.bounds];
    
    CGSize prefixTextSize;
    CGSize size1 = CGSizeMake([[UIScreen mainScreen] bounds].size.width * 0.7,MAXFLOAT);
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByCharWrapping];
    NSDictionary *attributes = @{ NSFontAttributeName : self.font, NSParagraphStyleAttributeName : style };
    prefixTextSize = [self.text boundingRectWithSize:size1
                                   options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                attributes:attributes context:nil].size;
    
    
    CGSize autocompleteTextSize;
    CGSize size2 = CGSizeMake([[UIScreen mainScreen] bounds].size.width * 0.7,MAXFLOAT);
    NSMutableParagraphStyle *style2 = [[NSMutableParagraphStyle alloc] init];
    [style2 setLineBreakMode:NSLineBreakByCharWrapping];
    NSDictionary *attributes1 = @{ NSFontAttributeName : self.font, NSParagraphStyleAttributeName : style2 };
    autocompleteTextSize = [self.autocompleteString boundingRectWithSize:size2
                                             options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                          attributes:attributes1 context:nil].size;
    
    
    returnRect = CGRectMake(textRect.origin.x + prefixTextSize.width + self.autocompleteTextOffset.x,
                            textRect.origin.y + self.autocompleteTextOffset.y,
                            autocompleteTextSize.width,
                            textRect.size.height);

    return returnRect;
}

- (void)ht_textDidChange:(NSNotification*)notification
{
    [self refreshAutocompleteText];
}

- (void)updateAutocompleteLabel
{
    [self.autocompleteLabel setText:self.autocompleteString];
    [self.autocompleteLabel sizeToFit];
    [self.autocompleteLabel setFrame: [self autocompleteRectForBounds:self.bounds]];
}

- (void)refreshAutocompleteText
{
    if (!self.autocompleteDisabled)
    {
        id <HTAutocompleteDataSource> dataSource = nil;

        if ([self.autocompleteDataSource respondsToSelector:@selector(textField:completionForPrefix:ignoreCase:)])
        {
            dataSource = (id <HTAutocompleteDataSource>)self.autocompleteDataSource;
        }
        else if ([DefaultAutocompleteDataSource respondsToSelector:@selector(textField:completionForPrefix:ignoreCase:)])
        {
            dataSource = DefaultAutocompleteDataSource;
        }

        if (dataSource)
        {
            self.autocompleteString = [dataSource textField:self completionForPrefix:self.text ignoreCase:self.ignoreCase];

            [self updateAutocompleteLabel];
        }
    }
}

- (void)commitAutocompleteText
{
    if ([self.autocompleteString isEqualToString:@""] == NO
        && self.autocompleteDisabled == NO)
    {
        self.text = [NSString stringWithFormat:@"%@%@", self.text, self.autocompleteString];

        self.autocompleteString = @"";
        [self updateAutocompleteLabel];
    }
}

- (void)forceRefreshAutocompleteText
{
    [self refreshAutocompleteText];
}

@end
