Bomb_Drop()
{
	if ( level.gameType != "sd" && level.gameType != "sab" && level.gameType != "osd" )
		return;

	if( level.gameType == "sd" && self.pers["team"] != game["attackers"] || level.gameType == "osd" && self.pers["team"] != game["attackers"]  )
		return;

	if (self.sessionstate != "playing")
		return;

	if( !self.isBombCarrier )
		return;

	if( self.isPlanting )
		return;

	if(isDefined(self.carryObject)) {
		self.carryObject thread maps\mp\gametypes\_gameobjects::setDropped();
		self.isBombCarrier = false;
	}
}