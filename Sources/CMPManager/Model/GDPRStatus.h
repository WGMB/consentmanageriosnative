//
//  GDPRStatus.h
//  Pods
// @brief General Data Protection Regulation Enum
// Consentmanager API gives Feedback about the GDPR Status
// Depending on Regulation feedback GDPR is Enabled. If the Regulation Status is unknown or
// CCPA (California Consumer Privacy Act) Applies, GDPR should be disabled -> Fallback value is UNKNOWN
// Created by Skander Ben Abdelmalak on 20.11.21.
//
//

#ifndef GDPRStatus_h
#define GDPRStatus_h

#include <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, GDPRStatus) {
	GDPR_UNKNOWN = -1,
	GDPR_DISABLED = 0,
	GDPR_ENABLED = 1
};

#endif /* GDPRStatus_h */
