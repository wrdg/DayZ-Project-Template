class CfgPatches
{
	class Template_Scripts
	{
		requiredAddons[] = {};
	};
};

class CfgMods
{
	class Template
	{
		type = "mod";
		author = "Wardog";
		dir = "Template";
		name = "Template";
		inputs = "Template/Scripts/Data/Inputs.xml";
		dependencies[] = {"Game","World","Mission"};
		class defs
		{
			class gameScriptModule
			{
				files[] = {"Template/Scripts/3_Game"};
			};
			class worldScriptModule
			{
				files[] = {"Template/Scripts/4_World"};
			};
			class missionScriptModule
			{
				files[] = {"Template/Scripts/5_Mission"};
			};
		};
	};
};