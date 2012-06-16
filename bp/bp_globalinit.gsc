// ----------------------------------------------------------------------------
// Mod: BP Mod
// Website: http://www.bptourneys.com
// 
// Module: Init
// Author: Dan2k3k4
// Contents: 
// Description: Main initialisation for BP Mod
// Notes: 
// ----------------------------------------------------------------------------

init()
{
	thread bp\bp_logfile::init();
	
	/#
	[[level.bp_log]]("Setting Up BP");
	#/
	
	thread bp\bp_antiglitch::init();
	thread bp\bp_rank::init();
	thread bp\bp_stats::init();
}