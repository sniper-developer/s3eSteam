#ifndef __Q_STEAMWORKS_H
#define __Q_STEAMWORKS_H

#include <s3eTypes.h>
#include "s3eSteam.h"

// tolua_begin

namespace steamworks {
// Common
bool isAvailable();
bool isStarted();
bool start();
bool restartAppIfNecessary(uint32 unOwnAppID);

bool storeStats();
bool requestCurrentStats();

const char * getCurrentGameLanguage();

// Achievements
bool getAchievement(const char* pchName);
bool getAchievement(const char* pchName);
bool clearAchievement(const char* pchName);

// Stats
int getStatInt(const char* pchName);
float getStatFloat(const char* pchName);

bool setStatInt(const char* pchName, int nData);
bool setStatFloat(const char* pchName, float fData);

// Leaderboards
bool leaderboardInit(const char* pchName);
bool leaderboardUploadScore(const char* pchName, int32 value, bool forceUpdate);
int leaderboardGetEntryCount(const char* pchName);
bool leaderboardDownloadEntries(const char* pchName, s3eSteamELeaderboardDataRequest eLeaderboardData, int nRangeStart, int nRangeEnd);
}

// tolua_end
#endif // __Q_STEAMWORKS_H
