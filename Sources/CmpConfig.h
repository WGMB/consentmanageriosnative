//
//  CmpConfig.h
//  GDPR
//

#import <Foundation/Foundation.h>

/**
 Object that provides the interface for storing and retrieving GDPR-related information
 */
@interface CmpConfig : NSObject

/**
 NSURL that is used to create and load the request into the WKWebView – it is the request for the consent webpage. This property is mandatory.
 */
@property(class) NSString *consentToolDomain;

/**
 Language that is used to create and load the request into the WKWebView – it is the request for the consent webpage. This property is mandatory.
 */
@property(class) NSString *consentToolLanguage;

/**
 AppName that is used to create and load the request into the WKWebView – it is the request for the consent webpage. This property is mandatory.
 */
@property(class) NSString *consentToolAppName;

/**
 User ID that is used to create and load the request into the WKWebView – it is the request for the consent webpage. This property is mandatory.
 */
@property(class) NSString *consentToolId;

+ (void)setConsentToolDomain:(NSString *)consentToolDomain;

+ (NSString *)consentToolDomain;

+ (void)setConsentToolId:(NSString *)consentToolId;

+ (NSString *)consentToolId;

+ (void)setConsentToolAppName:(NSString *)consentToolAppName;

+ (NSString *)consentToolAppName;

+ (void)setConsentToolLanguage:(NSString *)consentToolLanguage;

+ (NSString *)consentToolLanguage;

/**
 Returns if all Config parameter are set
 */
+ (BOOL)isValid;

/**
 Returns the Advertising Device ID
 */
+ (void)setIDFA:(NSString *)setIDFA;

+ (NSString *)getIdfa;

+ (void)setAppleTrackingStatus:(NSUInteger)status;

+ (void)setAutoAppleTracking:(BOOL)addAttActive;

+ (BOOL)getAutoAppleTracking;

+ (NSInteger)getVerboseLevel;

+ (void)setVerboseLevel:(NSInteger)level;
/**
 Creates a new singleton Instance from the config and returns this
 */
+ (void)setValues:(NSString *)domain addCmpId:(NSString *)appId addAppName:(NSString *)appName addLanguage:(NSString *)language;

/**
 Returns the ConsentManager url String which needs to be called, to get the url for the consentView
 */
+ (NSString *)getConsentToolURLString:(NSString *)consent;

+ (NSInteger)getAppleTrackingStatus;

+ (NSString *)description;
@end
