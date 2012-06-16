// ----------------------------------------------------------------------------
// Mod: BP Mod
// Website: http://www.bptourneys.com
// 
// Module: Log File
// Author: JackTheRipper
// Contents: 
// Description: 
// Notes: 
// ----------------------------------------------------------------------------

init()
{
	level.bp_log = ::bp_log;
	level.bp_removeColorTags = ::removeColorTags;
}

bp_log(str)
{
	text = removeColorTags(str);
	
	logPrint("BPMod: " + text + "\n");
}

removeColorTags(str)
{
	if(!isDefined(str) || (str == ""))
		return("");
	
	_s = "";
	
	_colorCheck = false;
	for(i = 0; i < str.size; i++)
	{
		ch = str[ i ];
		if(_colorCheck)
		{
			_colorCheck = false;
			
			switch(ch)
			{
				case "0": // black
				case "1": // red
				case "2": // green
				case "3": // yellow
				case "4": // blue
				case "5": // cyan
				case "6": // pink
				case "7": // white
				case "8": // Olive
				case "9": // Grey
				  break;
				default:
				  _s += ("^" + ch);
				  break;
			}
		}
		else if(ch == "^")
			_colorCheck = true;
		else
			_s += ch;
	}
	return(_s);
}
