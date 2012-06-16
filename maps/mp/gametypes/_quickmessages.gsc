init()
{
	game["menu_quickcommands"] = "quickcommands";
	game["menu_quickstatements"] = "quickstatements";
	game["menu_quickresponses"] = "quickresponses";
	game["menu_quickpromod"] = "quickpromod";
	game["menu_quickpromodgfx"] = "quickpromodgfx";

	precacheMenu(game["menu_quickcommands"]);
	precacheMenu(game["menu_quickstatements"]);
	precacheMenu(game["menu_quickresponses"]);
	precacheMenu(game["menu_quickpromod"]);
	precacheMenu(game["menu_quickpromodgfx"]);
	precacheHeadIcon("talkingicon");

	precacheString( &"QUICKMESSAGE_FOLLOW_ME" );
	precacheString( &"QUICKMESSAGE_MOVE_IN" );
	precacheString( &"QUICKMESSAGE_FALL_BACK" );
	precacheString( &"QUICKMESSAGE_SUPPRESSING_FIRE" );
	precacheString( &"QUICKMESSAGE_ATTACK_LEFT_FLANK" );
	precacheString( &"QUICKMESSAGE_ATTACK_RIGHT_FLANK" );
	precacheString( &"QUICKMESSAGE_HOLD_THIS_POSITION" );
	precacheString( &"QUICKMESSAGE_REGROUP" );
	precacheString( &"QUICKMESSAGE_ENEMY_SPOTTED" );
	precacheString( &"QUICKMESSAGE_ENEMIES_SPOTTED" );
	precacheString( &"QUICKMESSAGE_IM_IN_POSITION" );
	precacheString( &"QUICKMESSAGE_AREA_SECURE" );
	precacheString( &"QUICKMESSAGE_GRENADE" );
	precacheString( &"QUICKMESSAGE_SNIPER" );
	precacheString( &"QUICKMESSAGE_NEED_REINFORCEMENTS" );
	precacheString( &"QUICKMESSAGE_HOLD_YOUR_FIRE" );
	precacheString( &"QUICKMESSAGE_YES_SIR" );
	precacheString( &"QUICKMESSAGE_NO_SIR" );
	precacheString( &"QUICKMESSAGE_IM_ON_MY_WAY" );
	precacheString( &"QUICKMESSAGE_SORRY" );
	precacheString( &"QUICKMESSAGE_GREAT_SHOT" );
	precacheString( &"QUICKMESSAGE_TOOK_LONG_ENOUGH" );
	precacheString( &"QUICKMESSAGE_ARE_YOU_CRAZY" );
	precacheString( &"QUICKMESSAGE_WATCH_SIX" );
	precacheString( &"QUICKMESSAGE_COME_ON" );
}

quickcommands(response)
{
	self endon ( "disconnect" );

	if(!isdefined(self.pers["team"]) || self.pers["team"] == "spectator" || isdefined(self.spamdelay))
		return;

	self.spamdelay = true;

	switch(response)
	{
		case "1":
			soundalias = "mp_cmd_followme";
			saytext = &"QUICKMESSAGE_FOLLOW_ME";
			break;

		case "2":
			soundalias = "mp_cmd_movein";
			saytext = &"QUICKMESSAGE_MOVE_IN";
			break;

		case "3":
			soundalias = "mp_cmd_fallback";
			saytext = &"QUICKMESSAGE_FALL_BACK";
			break;

		case "4":
			soundalias = "mp_cmd_suppressfire";
			saytext = &"QUICKMESSAGE_SUPPRESSING_FIRE";
			break;

		case "5":
			soundalias = "mp_cmd_attackleftflank";
			saytext = &"QUICKMESSAGE_ATTACK_LEFT_FLANK";
			break;

		case "6":
			soundalias = "mp_cmd_attackrightflank";
			saytext = &"QUICKMESSAGE_ATTACK_RIGHT_FLANK";
			break;

		case "7":
			soundalias = "mp_cmd_holdposition";
			saytext = &"QUICKMESSAGE_HOLD_THIS_POSITION";
			break;

		default:
			assert(response == "8");
			soundalias = "mp_cmd_regroup";
			saytext = &"QUICKMESSAGE_REGROUP";
			break;
	}

	self saveHeadIcon();
	self doQuickMessage(soundalias, saytext);

	wait 3;
	self.spamdelay = undefined;
	self restoreHeadIcon();
}

quickstatements(response)
{
	if(!isdefined(self.pers["team"]) || self.pers["team"] == "spectator" || isdefined(self.spamdelay))
		return;

	self.spamdelay = true;

	switch(response)
	{
		case "1":
			soundalias = "mp_stm_enemyspotted";
			saytext = &"QUICKMESSAGE_ENEMY_SPOTTED";
			break;

		case "2":
			soundalias = "mp_stm_enemiesspotted";
			saytext = &"QUICKMESSAGE_ENEMIES_SPOTTED";
			break;

		case "3":
			soundalias = "mp_stm_iminposition";
			saytext = &"QUICKMESSAGE_IM_IN_POSITION";
			break;

		case "4":
			soundalias = "mp_stm_areasecure";
			saytext = &"QUICKMESSAGE_AREA_SECURE";
			break;

		case "5":
			soundalias = "mp_stm_watchsix";
			saytext = &"QUICKMESSAGE_WATCH_SIX";
			break;

		case "6":
			soundalias = "mp_stm_sniper";
			saytext = &"QUICKMESSAGE_SNIPER";
			break;

		default:
			assert(response == "7");
			soundalias = "mp_stm_needreinforcements";
			saytext = &"QUICKMESSAGE_NEED_REINFORCEMENTS";
			break;
	}

	self saveHeadIcon();
	self doQuickMessage(soundalias, saytext);

	wait 3;
	self.spamdelay = undefined;
	self restoreHeadIcon();
}

quickresponses(response)
{
	if(!isdefined(self.pers["team"]) || self.pers["team"] == "spectator" || isdefined(self.spamdelay))
		return;

	self.spamdelay = true;

	switch(response)
	{
		case "1":
			soundalias = "mp_rsp_yessir";
			saytext = &"QUICKMESSAGE_YES_SIR";
			break;

		case "2":
			soundalias = "mp_rsp_nosir";
			saytext = &"QUICKMESSAGE_NO_SIR";
			break;

		case "3":
			soundalias = "mp_rsp_onmyway";
			saytext = &"QUICKMESSAGE_IM_ON_MY_WAY";
			break;

		case "4":
			soundalias = "mp_rsp_sorry";
			saytext = &"QUICKMESSAGE_SORRY";
			break;

		case "5":
			soundalias = "mp_rsp_greatshot";
			saytext = &"QUICKMESSAGE_GREAT_SHOT";
			break;

		default:
			assert(response == "6");
			soundalias = "mp_rsp_comeon";
			saytext = &"QUICKMESSAGE_COME_ON";
			break;
	}

	self saveHeadIcon();
	self doQuickMessage(soundalias, saytext);

	wait 3;
	self.spamdelay = undefined;
	self restoreHeadIcon();
}

quickpromod(response)
{
	switch(response)
	{
		case "1":
			self switchToWeapon( "binoculars_mp" );
			break;
		
		case "2":
			self thread promod\bombdrop::Bomb_Drop();
			break;

		case "3":
			if(level.gametype != "ftag")
				self suicide();
			break;

		case "grenade":
			
			if ( self.pers["team"] != "axis" && self.pers["team"] != "allies" )
				return;

			classType = self.pers["class"];

			if( self.pers[classType]["loadout_sgrenade"] == "smoke_grenade" )
			{
				if (getDvar( "weap_allow_flash_grenade" ) == "0" )
					return;

				self.pers[classType]["loadout_sgrenade"] = "flash_grenade";
				self iprintln("Flash selected");
			}
			else if( self.pers[classType]["loadout_sgrenade"] == "flash_grenade" )
			{
				if (getDvar( "weap_allow_smoke_grenade" ) == "0" )
					return;

				self.pers[classType]["loadout_sgrenade"] = "smoke_grenade";
				self iprintln("Smoke selected");
			}
			else
				return;

			self classBind( classType );
			
			break;

		case "assault":
			
			if ( self.pers["team"] != "axis" && self.pers["team"] != "allies" )
				return;

			self classBind( "assault" );
			
			break;

		case "specops":
			
			if ( self.pers["team"] != "axis" && self.pers["team"] != "allies" )
				return;

			self classBind( "specops" );
			
			break;

		case "demolitions":
			
			if ( self.pers["team"] != "axis" && self.pers["team"] != "allies" )
				return;

			self classBind( "demolitions" );
			
			break;

		case "sniper":
			
			if ( self.pers["team"] != "axis" && self.pers["team"] != "allies" )
				return;

			self classBind( "sniper" );
			
			break;

		case "X":
			if ( self.pers["team"] != "axis" && self.pers["team"] != "allies" )
				return;

			team = self.pers["team"];
			self openMenu( game[ "menu_changeclass_" + team ] );
			break;
	}
}

classBind( response )
{
	if ( !self.hasSpawned )
		return;

	if ( !self maps\mp\gametypes\_modwarfare::verifyClassChoice( self.pers["team"], response ) )
		return;

	if(self.pers["class"] == response)
		return;

	oldClass = self.pers["class"];

	self maps\mp\gametypes\_modwarfare::setClassChoice( response );
	//self closeMenu();
	//self closeInGameMenu();

	if( oldClass != self.pers["class"] )
	{
		if( response == "assault" )
			self iprintln("Assault selected");
		else if( response == "specops" )
			self iprintln("Spec Ops selected");
		else if( response == "demolitions" )
			self iprintln("Demolitions selected");
		else if( response == "sniper" )
			self iprintln("Sniper selected");
	}
}

quickpromodgfx(response)
{
	switch(response)
	{
		case "1":
			self thread promod\config::toggle_sunlight();
			break;

		case "2":
			self thread promod\config::toggle_filmtweak();
			break;

		case "3":
			self thread promod\config::toggle_texture();
			break;

		case "4":
			self thread promod\config::toggle_normalmap();
			break;

		case "5":
			self thread promod\config::toggle_fovscale();
			break;

		case "6":
			self thread promod\config::toggle_gfxblur();
			break;
	}
}

doQuickMessage( soundalias, saytext )
{
	if(self.sessionstate != "playing")
		return;

	if ( self.pers["team"] == "allies" )
	{
		if ( game["allies"] == "sas" )
			prefix = "UK_";
		else
			prefix = "US_";
	}
	else
	{
		if ( game["axis"] == "russian" )
			prefix = "RU_";
		else
			prefix = "AB_";
	}

	if(isdefined(level.QuickMessageToAll) && level.QuickMessageToAll)
	{
		self.headiconteam = "none";
		self.headicon = "talkingicon";

		self playSound( prefix+soundalias );
		self sayAll(saytext);
	}
	else
	{
		if(self.sessionteam == "allies")
			self.headiconteam = "allies";
		else if(self.sessionteam == "axis")
			self.headiconteam = "axis";

		self.headicon = "talkingicon";

		self playSound( prefix+soundalias );
		self sayTeam( saytext );
		self pingPlayer();
	}
}

saveHeadIcon()
{
	if(isdefined(self.headicon))
		self.oldheadicon = self.headicon;

	if(isdefined(self.headiconteam))
		self.oldheadiconteam = self.headiconteam;
}

restoreHeadIcon()
{
	if(isdefined(self.oldheadicon))
		self.headicon = self.oldheadicon;

	if(isdefined(self.oldheadiconteam))
		self.headiconteam = self.oldheadiconteam;
}