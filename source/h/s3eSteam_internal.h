/*
 * Internal header for the s3eSteam extension.
 *
 * This file should be used for any common function definitions etc that need to
 * be shared between the platform-dependent and platform-indepdendent parts of
 * this extension.
 */

/*
 * NOTE: This file was originally written by the extension builder, but will not
 * be overwritten (unless --force is specified) and is intended to be modified.
 */


#ifndef S3ESTEAM_INTERNAL_H
#define S3ESTEAM_INTERNAL_H

#include "s3eTypes.h"
#include "s3eSteam.h"
#include "s3eSteam_autodefs.h"


/**
 * Initialise the extension.  This is called once then the extension is first
 * accessed by s3eregister.  If this function returns S3E_RESULT_ERROR the
 * extension will be reported as not-existing on the device.
 */
s3eResult s3eSteamInit();

/**
 * Platform-specific initialisation, implemented on each platform
 */
s3eResult s3eSteamInit_platform();

/**
 * Terminate the extension.  This is called once on shutdown, but only if the
 * extension was loader and Init() was successful.
 */
void s3eSteamTerminate();

/**
 * Platform-specific termination, implemented on each platform
 */
void s3eSteamTerminate_platform();
s3eResult s3eSteamRegister_platform(s3eSteamCallback callbackID, s3eCallback callbackFn, void* userData);

s3eResult s3eSteamUnRegister_platform(s3eSteamCallback callbackID, s3eCallback callbackFn);

s3eBool s3eSteamStart_platform();
s3eBool s3eSteamStarted_platform();

s3eBool s3eSteamRestartAppIfNecessary_platform(uint32 unOwnAppID);

s3eBool s3eSteamStoreStats_platform();

s3eBool s3eSteamRequestCurrentStats_platform();

void s3eSteamUpdate_platform();

s3eBool s3eSteamGetAchievement_platform(const char* pchName);

s3eBool s3eSteamSetAchievement_platform(const char* pchName);

s3eBool s3eSteamClearAchievement_platform(const char* pchName);

int s3eSteamGetStatInt_platform(const char* pchName);

float s3eSteamGetStatFloat_platform(const char* pchName);

s3eBool s3eSteamSetStatInt_platform(const char* pchName, int nData);

s3eBool s3eSteamSetStatFloat_platform(const char* pchName, float fData);

const char * s3eSteamGetCurrentGameLanguage_platform();

s3eBool s3eSteamLeaderboardInit_platform(const char* pchName);
s3eBool s3eSteamLeaderboardUploadScore_platform(const char* pchName, int32 value, s3eBool forceUpdate);
int s3eSteamLeaderboardGetEntryCount_platform(const char* pchName);
s3eBool s3eSteamLeaderboardDownloadEntries_platform(const char* pchName, s3eSteamELeaderboardDataRequest eLeaderboardData, int nRangeStart, int nRangeEnd);

#endif /* !S3ESTEAM_INTERNAL_H */