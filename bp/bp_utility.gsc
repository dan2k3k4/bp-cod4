// ----------------------------------------------------------------------------
// Mod: BP Mod
// Website: http://www.bptourneys.com
// 
// Module: Utility
// Author: JackTheRipper
// Contents: 	assertBP(<test>, <message>)
//				playerInfoLookup(<guid>, <lookup>)
//				tokenize(<str>, <delim>)
//				addConsoleCommand(<dVar>, <function>)
// Description: 
// Notes: 
// ----------------------------------------------------------------------------

// --------------------------------------
// Name: assertBP(<test>, <message>)
// Summary: if test is false, forces error of message
// Module: Assert
// CallOn: 
// MandatoryArg: <test> : argument to test
// MandatoryArg: <message> : message to display if test is false
// OptionalArg: 
// Returns: 
// Example: assertBP(isDefined(variable), "variable is undefined");
// SPMP: both
// --------------------------------------
assertBP(test, message)
{
	assertEx(test, "BPMod: " + message);
}


// --------------------------------------
// Name: playerInfoLookup(<guid>, <lookup>)
// Summary: looks up player info based on guid
// Module: Player Info
// CallOn: 
// MandatoryArg: <guid> : guid to lookup
// MandatoryArg: <lookup> : value to lookup
// OptionalArg: 
// Returns: the specified value
// Example: rank = playerInfoLookup(self getGuid(), 4);
// SPMP: multiplayer
// --------------------------------------
playerInfoLookup(guid, lookup)
{
	assertBP(isDefined(guid), "playerInfoLookup() called with undefined guid");
	assertBP(isDefined(lookup), "playerInfoLookup() called with undefined lookup");
	
	playerdata = getDvar("bp_guid_" + guid);
	if(!isDefined(playerdata))
		return;
	
	playerinfo = tokenize(playerdata, ",");
	if(!isDefined(playerinfo) || playerinfo.size < 1)
		return;
	
	return playerinfo[lookup];
}

// --------------------------------------
// Name: tokenize(<str>, <delim>)
// Summary: tokenizes the given string
// Module: String
// CallOn: 
// MandatoryArg: <str> : string to tokenize
// MandatoryArg: <delim> : delimeter to tokenize with
// OptionalArg: 
// Returns: The tokenized string as an array
// Example: tokens = tokenize(mystring, ",");
// SPMP: both
// --------------------------------------
tokenize(str, delim)
{
	if(!isDefined(str) || (str == ""))
		return("");
	if(!isDefined(delim) || (delim == ""))
		return(str);
	
	num_toks = 0;
	tokens = [];
	tokens[num_toks] = "";
	token = "";
	
	for(i = 0; i < str.size; i++)
	{
		ch = str[i];
		
		if(ch != delim)
			token += ch;
		
		if(ch == delim || i == str.size - 1)
		{
			tokens[num_toks] = token;
			num_toks++;
			token = "";
		}
	}
	return(tokens);
}

// --------------------------------------
// Name: addConsoleCommand(<dVar>, <function>)
// Summary: sets up the given command
// Module: Commands
// CallOn: 
// MandatoryArg: <dVar> : command to setup
// MandatoryArg: <function> : function to call when command is run
// OptionalArg: 
// Returns: 
// Example: addConsoleCommand("bp_exec", ::execCommand);
// SPMP: multiplayer
// --------------------------------------
addConsoleCommand(dVar, function)
{
	if(!isDefined(level.bp_consolecommands))
		level.bp_consolecommands = [];
	
	i = level.bp_consolecommands.size;
	level.bp_consolecommands[i] = [];
	level.bp_consolecommands[i]["dvar"] = dVar;
	level.bp_consolecommands[i]["function"] = function;
	
	setDvar(dVar, "");
}
