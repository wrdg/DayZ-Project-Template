$DAYZ_ROOT_PATH = "C:\Program Files (x86)\Steam\steamapps\common\DayZ"
$OFFLINE_MISSION_PATH = "C:\Program Files (x86)\Steam\steamapps\common\DayZ\Missions\DayZCommunityOfflineMode.ChernarusPlus"

$LOCAL_DAYZ_SERVER_PATH = "C:\Program Files (x86)\Steam\steamapps\common\DayZServer"
$SERVER_PROFILE_PATH = "C:\Program Files (x86)\Steam\steamapps\common\DayZServer\ServerProfile"

$ADDITIONAL_MODS = "" # SEPERATE BY SEMI COLON, PATH IS RELATIVE TO $DAYZ_ROOT_PATH! I.E. !Workshop\@CF;!Workshop\@BuildAnywhere

$CLEAR_LOGS_AUTOMATIC = $false # CLEAR LOGS AFTER EACH LAUNCH OF LOCALMP OR OFFLINE
$REVEAL_COMPLETE = $false # OPEN EXPLORER AFTER PROJECT SUCCESSFULLY BUILDS
$LAUNCH_AFTER_BUILD = 0 # 0 = NONE, 1 = OFFLINE, 2 = LOCALMP

$PROJECT_DRIVE = "P:"
$PROJECT_PREFIX = "Template"
$OUTPUT_DIR = "@Template" # OUTPUTS TO PROJECT DRIVE

# SUPPORTS RELATIVE AND ABSOLUTE PATH
$PRIVATE_KEY_PATH = ".\.key\Template.biprivatekey" # LEAVE BLANK TO SKIP THE SIGNING PROCESS
$PUBLIC_KEY_PATH = ".\.key\Template.bikey"