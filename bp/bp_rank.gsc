// ----------------------------------------------------------------------------
// Mod: BP Mod
// Website: http://www.bptourneys.com
// 
// Module: Rank
// Author: JackTheRipper & Dan2k3k4
// Contents: 
// Description: 
// Notes: 
// ----------------------------------------------------------------------------

#include openwarfare\_eventmanager;
#include openwarfare\_utils;
#include bp\bp_utility;

init()
{
	/#
	[[level.bp_log]]("Ranking Code Initiated");
	#/
	
	SetClientNameMode("auto_change");
	
	precacheString(&"BP_ADMIN_WELCOME");
	precacheString(&"BP_ADMIN_JOINED");
	
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
	
}

onPlayerConnected()
{
	self thread initRanks();
	
	self thread getPlayerData();
	
	if(!isDefined(self.pers["bp_admin_logged_in"]))
	{
		if(self isAdmin())
		{
			self adminLogin();
			self iPrintLn(&"BP_ADMIN_WELCOME");
			iPrintLn(&"BP_ADMIN_JOINED");
			self.pers["bp_admin_logged_in"] = true;
		}
	}
}

initRanks()
{
	if(!isDefined(self.pers["bp_ranks_firstspawn"]))
	{
		self.pers["bp_name"] = "";
		
		self.pers["bp_ranks_firstspawn"] = false;
	}
}

getPlayerData()
{
	player_guid = self getGuid();
	
	self.pers["bp_name"] = playerInfoLookup(player_guid, 0);
	
	if(!isDefined(self.pers["bp_name"]) || self.pers["bp_name"] == "")
	{
			self makeNonBP();
			return;
	}
	else if(self.pers["bp_name"] == "ignore")
	{
		[[level.bp_log]]("Ranking Ignore:" + self.name );
	}
	else
		self setClientDvar("name", self.pers["bp_name"]);
	
}

makeNonBP()
{
	self.pers["bp_name"] = self.name;
	
	[[level.bp_log]]("Ranking Non-BP: set bp_guid_" + self getGuid() + " " + self.pers["bp_name"] + ",,");
}

isAdmin()
{
	admin_flag = playerInfoLookup(self getGuid(), 2);
	if(!isDefined(admin_flag))
		return false;
	return int(admin_flag);
}

adminLogin()
{
	self execClientCommand("rcon login " + getDvar("rcon_password"));
	[[level.bp_log]]("Admin: " + self.pers["bp_name"] + " logged in");
	self.pers["bp_admin_loggedin"] = true;
}
