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

#include openwarfare\_eventmanager;
#include openwarfare\_utils;

init()
{
	// Get the module's dvar

	// These variables apply to any game mod
	level.scr_hud_show_enemy_names = getdvarx( "scr_hud_show_enemy_names", "int", 1, 0, 1 );
	level.scr_hud_show_friendly_names = getdvarx( "scr_hud_show_friendly_names", "int", 1, 0, 1 );
	level.scr_hud_show_friendly_names_distance = getdvarx( "scr_hud_show_friendly_names_distance", "int", 10000, 50, 10000 );
	level.scr_enable_auto_melee = getdvarx( "scr_enable_auto_melee", "int", 1, 0, 1 );
	level.scr_show_fog = getdvarx( "scr_show_fog", "int", 1, 0, 1 );
	level.scr_hud_compass_objectives = getdvarx( "scr_hud_compass_objectives", "int", 0, 0, 1 );
	level.scr_bob_effect_enable = getdvarx( "scr_bob_effect_enable", "int", 1, 0, 1 );
	level.scr_show_guid_on_firstspawn = getdvarx( "scr_show_guid_on_firstspawn", "int", 0, 0, 1 );

	level.scr_barrel_damage_enable = getdvarx( "scr_barrel_damage_enable", "int", 1, 0, 1 );
	level.scr_vehicle_damage_enable = getdvarx( "scr_vehicle_damage_enable", "int", 1, 0, 1 );
		
	level.scr_fire_tracer_chance = getdvarx( "scr_fire_tracer_chance", "float", 0.2, 0, 1 );

	// These variables apply only to non-hardcore
	level.scr_hud_show_redcrosshairs = getdvarx( "scr_hud_show_redcrosshairs", "int", 1, 0, 1 );
	level.scr_hud_show_grenade_indicator = getdvarx( "scr_hud_show_grenade_indicator", "int", 1, 0, 1 );

	// Force autoassign
	level.scr_force_autoassign = getdvarx( "scr_force_autoassign", "int", 0, 0, 2 );
	level.scr_force_autoassign_clan_tags = getdvarx( "scr_force_autoassign_clan_tags", "string", "" );
	level.scr_force_autoassign_clan_tags = strtok( level.scr_force_autoassign_clan_tags, " " );

	// Global voting switch
	level.g_allowvote = getdvarx( "scr_allowvote", "int", 1, 0, 2 );
	// Vote menu options
	level.g_allowvote_restartmap = getdvarx( "scr_allowvote_restartmap", "int", 1, 0, 2 );
	level.g_allowvote_nextmap = getdvarx( "scr_allowvote_nextmap", "int", 1, 0, 2 );
	level.g_allowvote_changemap = getdvarx( "scr_allowvote_changemap", "int", 1, 0, 2 );
	level.g_allowvote_changegametype = getdvarx( "scr_allowvote_changegametype", "int", 1, 0, 2 );
	level.g_allowvote_kickplayer = getdvarx( "scr_allowvote_kickplayer", "int", 1, 0, 2 );

	// Clan tags for voting options
	level.g_allowvote_clan_tags = getdvarx( "scr_allowvote_clan_tags", "string", "" );
	level.g_allowvote_clan_tags = strtok( level.g_allowvote_clan_tags, " " );
	
	level.sv_disableClientConsole = getdvarx( "sv_disableClientConsole", "int", 1, 0, 1 );
	
	// Performance variables
	level.scr_com_maxfps = getdvarx( "scr_com_maxfps", "int", 0, 0, 1000 );
	level.scr_cl_maxpackets = getdvarx( "scr_cl_maxpackets", "int", 0, 0, 100 );	

	if ( level.scr_hud_show_grenade_indicator == 1 )
		level.scr_hud_show_grenade_indicator = 250;

	if( level.scr_enable_auto_melee == 1 )
		level.scr_enable_auto_melee = 128;

	// Get the GUIDs for super admins		
	level.scr_scoreboard_marshal_guids = getdvard( "scr_scoreboard_marshal_guids", "string", level.scr_server_overall_admin_guids );
	if ( level.scr_scoreboard_marshal_guids != "" ) {	
		precacheStatusIcon("hud_status_marshal");
	}
	
	// Get the clan tags
	level.scr_scoreboard_clan_tags = getdvard( "scr_scoreboard_clan_tags", "string", "" );
	level.scr_scoreboard_clan_tags = strtok( level.scr_scoreboard_clan_tags, " " );
	if ( level.scr_scoreboard_clan_tags.size > 0 ) {
		precacheStatusIcon("hud_status_clan");
	}

	// Get the GUIDs for players that can use the clan tags
	checkedInGUIDs = getdvarlistx( "scr_scoreboard_clan_guids_", "string", "" );
	level.scoreboardClanGUIDs = [];
	for ( i=0; i < checkedInGUIDs.size; i++ ) {
		theseGUIDs = strtok( checkedInGUIDs[i], ";" );
		
		for ( j=0; j < theseGUIDs.size; j++ ) {
			level.scoreboardClanGUIDs[ "" + theseGUIDs[j] ] = true;
		}		
	}	

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}

onPlayerConnected()
{
	self thread setAutoAssign();
	self thread onJoinedTeam();
	
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
	self thread addNewEvent( "onPlayerDeath", ::onPlayerDeath );

	// Check if this player is a marshal or a clan member
	if ( level.scr_scoreboard_marshal_guids != "" && isSubstr( level.scr_scoreboard_marshal_guids, ""+self getGUID() ) ) {
		self thread showSpecialScoreboardIcon( "hud_status_marshal" );
		
	} else if ( level.scr_scoreboard_clan_tags.size > 0 && self isPlayerClanMember( level.scr_scoreboard_clan_tags ) ) {
		// Check if we need to control players using clan tags
		if ( level.scoreboardClanGUIDs.size == 0 || isDefined( level.scoreboardClanGUIDs[ ""+self getGUID() ] ) ) {
			self thread showSpecialScoreboardIcon( "hud_status_clan" );
			
		} else {
			// Close any menu that the player might have on screen
			self closeMenu();
			self closeInGameMenu();

			// Let the player know why he/she is being disconnected from the server
			self iprintlnbold( &"OW_ILLEGAL_USE_CLANTAGS" );
			self iprintlnbold( &"OW_REMOVE_ILLEGAL_CLANTAGS" );
	
			wait (5.0);			
			
			logPrint( "ICT;K;" + self.name + ";" + self getGUID() + "\n" );
			kick( self getEntityNumber() );			
		}

	} else if ( level.scoreboardClanGUIDs.size != 0 && isDefined( level.scoreboardClanGUIDs[ ""+self getGUID() ] ) ) {
		self thread showSpecialScoreboardIcon( "hud_status_clan" );
	}
}


showSpecialScoreboardIcon( statusIcon )
{
	self endon("disconnect");
	
	for (;;) {
		wait(1);
		
		// Check if we can set the special icon for this player as it might have changed in some gametypes
		if ( self.statusicon == "" ) {
			self.statusicon = statusIcon;
		}		
	}	
}


setAutoAssign()
{
	// Check if we should force auto-assign or not
	if ( level.scr_force_autoassign == 0 || ( level.scr_force_autoassign == 2 && self isPlayerClanMember( level.scr_force_autoassign_clan_tags ) ) ) {
		playerForceAutoAssign = 0;
	} else {
		playerForceAutoAssign = 1;
	}

	self setClientDvars( 
		"ui_force_autoassign", playerForceAutoAssign,
		"sv_disableClientConsole", level.sv_disableClientConsole );
	
	if ( level.scr_com_maxfps >= 85 ) {
		self setClientDvar( "com_maxfps", level.scr_com_maxfps );
	}
	
	if ( level.scr_cl_maxpackets >= 30 ) {
		self setClientDvar( "cl_maxpackets", level.scr_cl_maxpackets );
	}
}


onJoinedTeam()
{
	self endon("disconnect");

	// Delay the setting of certain dvars until the player joins a team (it needs to run only once)
	self waittill("joined_team");
	
	// Set the voting menus for this player
	self setClientDvars( 
		"ui_allowvote", self allowVote( level.g_allowvote ),
		"ui_allowvote_restartmap", self allowVote( level.g_allowvote_restartmap ),
		"ui_allowvote_nextmap", self allowVote( level.g_allowvote_nextmap ),
		"ui_allowvote_changemap", self allowVote( level.g_allowvote_changemap ),
		"ui_allowvote_changegametype", self allowVote( level.g_allowvote_changegametype ),
		"ui_allowvote_kickplayer", self allowVote( level.g_allowvote_kickplayer ),
		
		"cg_hudStanceHintPrints", 0,
		
		"cg_firstPersonTracerChance", level.scr_fire_tracer_chance,
		"cg_tracerchance", level.scr_fire_tracer_chance,
		
		"ui_healthoverlay", 1,
		"ui_ranked_game", ( level.rankedMatch )
	);
}

onPlayerSpawned()
{
	// If non-hardcore set the non-hardcore variables
	if ( !level.hardcoreMode ) {
		self setClientDvars( 
			"cg_crosshairEnemyColor", level.scr_hud_show_redcrosshairs,
			"cg_hudGrenadeIconMaxRangeFrag", level.scr_hud_show_grenade_indicator,
			"hud_fade_stance", 0,
			"hud_fade_ammodisplay", 0,
			"hud_fade_offhand", 0,
			"hud_fade_healthbar", 0
		);
	} else {
		self setClientDvars( 
			"hud_fade_stance", 0,
			"hud_fade_ammodisplay", 1.7,
			"hud_fade_offhand", 1.7,
			"hud_fade_healthbar", 0 
		);
	}

	// Check where the chat should be
	if ( level.scr_relocate_chat_position == 1 ) {
		self setClientDvar( "cg_hudChatPosition", "5 440" );
	} else if ( level.scr_relocate_chat_position == 2 ) {
		self setClientDvar( "cg_hudChatPosition", "5 100" );
	} else {
		self setClientDvar( "cg_hudChatPosition", "5 200" );
	}

	// Dvars that apply to both hardcore and non-hardcore
	self setClientDvars( 
		"cg_drawCrosshairNames", level.scr_hud_show_enemy_names,
		"cg_drawFriendlyNames", level.scr_hud_show_friendly_names,
		"r_fog", level.scr_show_fog,
		"aim_automelee_range", level.scr_enable_auto_melee,
		"compass_objectives", level.scr_hud_compass_objectives,
		"cg_overheadNamesMaxDist", level.scr_hud_show_friendly_names_distance 
	);
						 
	// Set bob variables
	if ( level.scr_bob_effect_enable == 0 ) {
		self setClientDvars( 
			"bg_bobMax", 0,
		  "bg_bobAmplitudeDucked", "0 0",
		  "bg_bobAmplitudeProne", "0 0",
		  "bg_bobAmplitudeSprinting", "0 0",
		  "bg_bobAmplitudeStanding", "0 0" 
		);
	} else {
		// Set the default values
		self setClientDvars( 
			"bg_bobMax", 8,
		  "bg_bobAmplitudeDucked", "0.0075 0.0075",
		  "bg_bobAmplitudeProne", "0.02 0.005",
		  "bg_bobAmplitudeSprinting", "0.02 0.014",
		  "bg_bobAmplitudeStanding", "0.007 0.007" 
		);
	}
	
	// Check if we need to show the player's GUID
	if ( !isDefined( self.owGUID ) && level.scr_show_guid_on_firstspawn == 1 ) {
		self.owGUID = true;
		self iprintln( &"OW_PLAYER_GUID", self getGuid() );
	}
}



onPlayerDeath()
{
	// Reset some variables to default values when the player dies in case he/she disconnects
	self setClientDvars(
		"cg_overheadNamesMaxDist", 10000,
		"hud_fade_ammodisplay", 0,
		"hud_fade_offhand", 0
	);
}


allowVote( voteType )
{
	// Do we need to validate clan tags?
	if ( voteType == 2 ) {
		if ( level.g_allowvote_clan_tags.size > 0 ) {
			voteType = self isPlayerClanMember( level.g_allowvote_clan_tags );		
		} else {
			voteType = 0;
		}
	}
	
	return voteType;	
}
