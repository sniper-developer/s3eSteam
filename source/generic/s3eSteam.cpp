/*
Generic implementation of the s3eSteam extension.
This file should perform any platform-indepedentent functionality
(e.g. error checking) before calling platform-dependent implementations.
*/

/*
 * NOTE: This file was originally written by the extension builder, but will not
 * be overwritten (unless --force is specified) and is intended to be modified.
 */


#include "s3eSteam_internal.h"
#include "s3eEdk.h"

s3eResult s3eSteamInit()
{
    //Add any generic initialisation code here
    return s3eSteamInit_platform();
}

void s3eSteamTerminate()
{
    //Add any generic termination code here
    s3eSteamTerminate_platform();
}

s3eBool s3eSteamStart()
{
    return s3eSteamStart_platform();
}

s3eBool s3eSteamStarted()
{
    return s3eSteamStarted_platform();
}

s3eBool s3eSteamRestartAppIfNecessary(uint32 unOwnAppID)
{
    return s3eSteamRestartAppIfNecessary_platform(unOwnAppID);
}

s3eResult s3eSteamRegister(s3eSteamCallback callbackID, s3eCallback callbackFn, void* userData)
{
    return s3eEdkCallbacksRegister(S3E_EXT_STEAM_HASH, s3eSteamCallback_MAX, callbackID, callbackFn, userData, false);
}

s3eResult s3eSteamUnRegister(s3eSteamCallback callbackID, s3eCallback callbackFn)
{
    return s3eEdkCallbacksUnRegister(S3E_EXT_STEAM_HASH, s3eSteamCallback_MAX, callbackID, callbackFn);
}

s3eBool s3eSteamStoreStats()
{
	return s3eSteamStoreStats_platform();
}

s3eBool s3eSteamRequestCurrentStats()
{
	return s3eSteamRequestCurrentStats_platform();
}

void s3eSteamUpdate()
{
	s3eSteamUpdate_platform();
}

s3eBool s3eSteamGetAchievement(const char* pchName)
{
	return s3eSteamGetAchievement_platform(pchName);
}

s3eBool s3eSteamSetAchievement(const char* pchName)
{
	return s3eSteamSetAchievement_platform(pchName);
}

s3eBool s3eSteamClearAchievement(const char* pchName)
{
	return s3eSteamClearAchievement_platform(pchName);
}

int s3eSteamGetStatInt(const char* pchName)
{
	return s3eSteamGetStatInt_platform(pchName);
}

float s3eSteamGetStatFloat(const char* pchName)
{
	return s3eSteamGetStatFloat_platform(pchName);
}

s3eBool s3eSteamSetStatInt(const char* pchName, int nData)
{
	return s3eSteamSetStatInt_platform(pchName, nData);
}

s3eBool s3eSteamSetStatFloat(const char* pchName, float fData)
{
	return s3eSteamSetStatFloat_platform(pchName, fData);
}

const char * s3eSteamGetCurrentGameLanguage()
{
    return s3eSteamGetCurrentGameLanguage_platform();
}

s3eBool s3eSteamLeaderboardInit(const char* pchName)
{
    return s3eSteamLeaderboardInit_platform(pchName);
}

s3eBool s3eSteamLeaderboardUploadScore(const char* pchName, int32 value, s3eBool forceUpdate)
{
    return s3eSteamLeaderboardUploadScore_platform(pchName, value, forceUpdate);
}

int s3eSteamLeaderboardGetEntryCount(const char* pchName)
{
    return s3eSteamLeaderboardGetEntryCount_platform(pchName);
}

s3eBool s3eSteamLeaderboardDownloadEntries(const char* pchName, s3eSteamELeaderboardDataRequest eLeaderboardData, int nRangeStart, int nRangeEnd)
{
    return s3eSteamLeaderboardDownloadEntries_platform(pchName, eLeaderboardData, nRangeStart, nRangeEnd);
}