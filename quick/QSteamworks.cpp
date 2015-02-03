#include "QSteamworks.h"

namespace steamworks {
//------------------------------------------------------------------------------
bool isAvailable() { return s3eSteamAvailable() == S3E_TRUE; }
bool isStarted() { return s3eSteamStarted() == S3E_TRUE; }
bool start() { return s3eSteamStart() == S3E_TRUE; }
bool restartAppIfNecessary(uint32 unOwnAppID) { return s3eSteamRestartAppIfNecessary(unOwnAppID) == S3E_TRUE; }

bool storeStats() { return s3eSteamStoreStats() == S3E_TRUE; }
bool requestCurrentStats() { return s3eSteamStoreStats() == S3E_TRUE; }

const char * getCurrentGameLanguage() { return s3eSteamGetCurrentGameLanguage(); }

// Achievements
bool getAchievement(const char* pchName) { return s3eSteamGetAchievement(pchName) == S3E_TRUE; }
bool setAchievement(const char* pchName) { return s3eSteamSetAchievement(pchName) == S3E_TRUE; }
bool clearAchievement(const char* pchName) { return s3eSteamClearAchievement(pchName) == S3E_TRUE; }

// Stats
int getStatInt(const char* pchName) { return s3eSteamGetStatInt(pchName); }
float getStatFloat(const char* pchName) { return s3eSteamGetStatFloat(pchName); }

bool setStatInt(const char* pchName, int nData) { return s3eSteamSetStatInt(pchName, nData) == S3E_TRUE; }
bool setStatFloat(const char* pchName, float fData) { return s3eSteamSetStatFloat(pchName, fData) == S3E_TRUE; }

// Leaderboards
bool leaderboardInit(const char* pchName) { return s3eSteamLeaderboardInit(pchName) == S3E_TRUE; }
bool leaderboardUploadScore(const char* pchName, int32 value, bool forceUpdate) { return s3eSteamLeaderboardUploadScore(pchName, value, forceUpdate ? S3E_TRUE : S3E_FALSE) == S3E_TRUE; }
int leaderboardGetEntryCount(const char* pchName) { return s3eSteamLeaderboardGetEntryCount(pchName); }
bool leaderboardDownloadEntries(const char* pchName, s3eSteamELeaderboardDataRequest eLeaderboardData, int nRangeStart, int nRangeEnd) { return s3eSteamLeaderboardDownloadEntries(pchName, eLeaderboardData, nRangeStart, nRangeEnd) == S3E_TRUE; }

} // namespace steamworks
