//******************************************************************************
//  _____                  _    _             __
// |  _  |                | |  | |           / _|
// | | | |_ __   ___ _ __ | |  | | __ _ _ __| |_ __ _ _ __ ___
// | | | | '_ \ / _ \ '_ \| |/\| |/ _` | '__|  _/ _` | '__/ _ \
// \ \_/ / |_) |  __/ | | \  /\  / (_| | |  | || (_| | | |  __/
//  \___/| .__/ \___|_| |_|\/  \/ \__,_|_|  |_| \__,_|_|  \___|
//       | |               We don't make the game you play.
//       |_|                 We make the game you play BETTER.
//
//            Website: http://openwarfaremod.com/
//******************************************************************************

init()
{
	// Initialize the arrays to hold the gametype names and stock map names
	initGametypesAndMaps();

	// Do not thread these initializations
	openwarfare\_eventmanager::eventManagerInit();
	
	thread bp\bp_globalinit::init();
	
	thread openwarfare\_advancedacp::init();
	thread openwarfare\_advancedmvs::init();
	thread openwarfare\_antibunnyhopping::init();
	thread openwarfare\_anticamping::init();
	thread openwarfare\_bigbrotherbot::init();
	thread openwarfare\_binoculars::init();
	thread openwarfare\_blackscreen::init();
	thread openwarfare\_bloodsplatters::init();
	thread openwarfare\_bodyremoval::init();
	thread openwarfare\_caceditor::init();	
	thread openwarfare\_capeditor::init();
	thread openwarfare\_clanvsall::init();
	thread openwarfare\_damageeffect::init();
	thread openwarfare\_daycyclesystem::init();
	thread openwarfare\_disarmexplosives::init();
	thread openwarfare\_dogtags::init();
	thread openwarfare\_dvarmonitor::init();
	thread openwarfare\_dynamicattachments::init();		
	thread openwarfare\_extendedobituaries::init();
	thread openwarfare\_fitnesscs::init();	
	thread openwarfare\_globalchat::init();
	thread openwarfare\_guidcs::init();
	thread openwarfare\_healthsystem::init();
	thread openwarfare\_hidescores::init();
	thread openwarfare\_idlemonitor::init();
	thread openwarfare\_keybinds::init();		
	thread openwarfare\_killingspree::init();
	thread openwarfare\_limitexplosives::init();
	thread openwarfare\_maprotationcs::init();
	thread openwarfare\_martyrdom::init();
	thread openwarfare\_objoptions::init();
	thread openwarfare\_overtime::init();
	thread openwarfare\_owbattlechatter::init();
	thread openwarfare\_paindeathsounds::init();
	thread openwarfare\_playerdvars::init();
	thread openwarfare\_powerrank::init();
	thread openwarfare\_quickactions::init();
	thread openwarfare\_rangefinder::init();
	thread openwarfare\_realtimestats::init();
	thread openwarfare\_reservedslots::init();
	thread openwarfare\_rng::init();
	thread openwarfare\_rotateifempty::init();
	thread openwarfare\_rsmonitor::init();
	thread openwarfare\_scorebot::init();
	thread openwarfare\_scoresystem::init();
	thread openwarfare\_serverbanners::init();
	thread openwarfare\_servermessages::init();
	thread openwarfare\_sniperzoom::init();
	thread openwarfare\_spawnprotection::init();
	thread openwarfare\_speedcontrol::init();
	thread openwarfare\_sponsors::init();
	thread openwarfare\_stationaryturrets::init();
	thread openwarfare\_teamstatus::init();
	thread openwarfare\_testbots::init();
	thread openwarfare\_thirdperson::init();
	thread openwarfare\_timeout::init();
	thread openwarfare\_timer::init();
	thread openwarfare\_tkmonitor::init();
	thread openwarfare\_virtualranks::init();
	thread openwarfare\_weapondamagemodifier::init();
	thread openwarfare\_weaponjam::init();
	thread openwarfare\_weaponlocationmodifier::init();
	thread openwarfare\_weaponrangemodifier::init();
	thread openwarfare\_weaponweightmodifier::init();
	thread openwarfare\_welcomerulesinfo::init();
}


initGametypesAndMaps()
{
	// ********************************************************************
	// WE DO NOT USE LOCALIZED STRINGS TO BE ABLE TO USE THEM IN MENU FILES
	// ********************************************************************
	
	// Define some default values for other modules
	level.defaultGametypeList = "ass;bel;ch;ctf;dom;dm;ftag;gg;koth;lms;lts;re;sab;sd;war"; 
	level.defaultMapList = "mp_convoy;mp_backlot;mp_bloc;mp_bog;mp_broadcast;mp_carentan;mp_countdown;mp_crash;mp_creek;mp_crossfire;mp_citystreets;mp_farm;mp_killhouse;mp_overgrown;mp_pipeline;mp_shipment;mp_showdown;mp_strike;mp_cargoship;mp_crash_snow;mp_vacant";
	
	// Load all the gametypes we currently support
	level.supportedGametypes = [];
	level.supportedGametypes["ass"] = "Assassination";
	level.supportedGametypes["bel"] = "Behind Enemy Lines";
	level.supportedGametypes["ch"] = "Capture and Hold";
	level.supportedGametypes["ctf"] = "Capture the Flag";
	level.supportedGametypes["dm"] = "Free for All";
	level.supportedGametypes["dom"] = "Domination";
	level.supportedGametypes["ftag"] = "Freeze Tag";
	level.supportedGametypes["gg"] = "Gun Game";
	level.supportedGametypes["koth"] = "Headquarters";
	level.supportedGametypes["lms"] = "Last Man Standing";
	level.supportedGametypes["lts"] = "Last Team Standing";
	level.supportedGametypes["re"] = "Retrieval";
	level.supportedGametypes["sab"] = "Sabotage";
	level.supportedGametypes["sd"] = "Search and Destroy";
	level.supportedGametypes["war"] = "Team Deathmatch";
	
	// Gametypes in capitalized form
	level.supportedGametypesCaps = [];
	level.supportedGametypesCaps["ass"] = "ASSASSINATION";
	level.supportedGametypesCaps["bel"] = "BEHIND ENEMY LINES";
	level.supportedGametypesCaps["ch"] = "CAPTURE AND HOLD";
	level.supportedGametypesCaps["ctf"] = "CAPTURE THE FLAG";
	level.supportedGametypesCaps["dm"] = "FREE FOR ALL";
	level.supportedGametypesCaps["dom"] = "DOMINATION";
	level.supportedGametypesCaps["ftag"] = "FREEZE TAG";
	level.supportedGametypesCaps["gg"] = "GUN GAME";
	level.supportedGametypesCaps["koth"] = "HEADQUARTERS";
	level.supportedGametypesCaps["lms"] = "LAST MAN STANDING";
	level.supportedGametypesCaps["lts"] = "LAST TEAM STANDING";
	level.supportedGametypesCaps["re"] = "RETRIEVAL";
	level.supportedGametypesCaps["sab"] = "SABOTAGE";
	level.supportedGametypesCaps["sd"] = "SEARCH AND DESTROY";
	level.supportedGametypesCaps["war"] = "TEAM DEATHMATCH";	
	
	// Load the name of the stock maps
	level.stockMapNames = [];
	level.stockMapNames["mp_backlot"] = "Backlot";
	level.stockMapNames["mp_bloc"] = "Bloc";
	level.stockMapNames["mp_bog"] = "Bog";
	level.stockMapNames["mp_broadcast"] = "Broadcast";
	level.stockMapNames["mp_cargoship"] = "Wet Work";
	level.stockMapNames["mp_carentan"] = "Chinatown";
	level.stockMapNames["mp_citystreets"] = "District";
	level.stockMapNames["mp_convoy"] = "Ambush";
	level.stockMapNames["mp_countdown"] = "Countdown";
	level.stockMapNames["mp_crash"] = "Crash";
	level.stockMapNames["mp_crash_snow"] = "Winter Crash";
	level.stockMapNames["mp_creek"] = "Creek";
	level.stockMapNames["mp_crossfire"] = "Crossfire";
	level.stockMapNames["mp_farm"] = "Downpour";
	level.stockMapNames["mp_killhouse"] = "Killhouse";
	level.stockMapNames["mp_overgrown"] = "Overgrown";
	level.stockMapNames["mp_pipeline"] = "Pipeline";
	level.stockMapNames["mp_shipment"] = "Shipment";
	level.stockMapNames["mp_showdown"] = "Showdown";
	level.stockMapNames["mp_strike"] = "Strike";
	level.stockMapNames["mp_vacant"] = "Vacant";
	
	// Maps in capitalized form
	level.stockMapNamesCaps = [];
	level.stockMapNamesCaps["mp_backlot"] = "BACKLOT";
	level.stockMapNamesCaps["mp_bloc"] = "BLOC";
	level.stockMapNamesCaps["mp_bog"] = "BOG";
	level.stockMapNamesCaps["mp_broadcast"] = "BROADCAST";
	level.stockMapNamesCaps["mp_cargoship"] = "WET WORK";
	level.stockMapNamesCaps["mp_carentan"] = "CHINATOWN";
	level.stockMapNamesCaps["mp_citystreets"] = "DISTRICT";
	level.stockMapNamesCaps["mp_convoy"] = "AMBUSH";
	level.stockMapNamesCaps["mp_countdown"] = "COUNTDOWN";
	level.stockMapNamesCaps["mp_crash"] = "CRASH";
	level.stockMapNamesCaps["mp_crash_snow"] = "WINTER CRASH";
	level.stockMapNamesCaps["mp_creek"] = "CREEK";
	level.stockMapNamesCaps["mp_crossfire"] = "CROSSFIRE";
	level.stockMapNamesCaps["mp_farm"] = "DOWNPOUR";
	level.stockMapNamesCaps["mp_killhouse"] = "KILLHOUSE";
	level.stockMapNamesCaps["mp_overgrown"] = "OVERGROWN";
	level.stockMapNamesCaps["mp_pipeline"] = "PIPELINE";
	level.stockMapNamesCaps["mp_shipment"] = "SHIPMENT";
	level.stockMapNamesCaps["mp_showdown"] = "SHOWDOWN";
	level.stockMapNamesCaps["mp_strike"] = "STRIKE";
	level.stockMapNamesCaps["mp_vacant"] = "VACANT";	
}
