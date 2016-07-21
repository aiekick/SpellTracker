-- -------------------------------------------------------------------------- --
-- SpellTracker By Xulos ( EU ALLIANCE DALARAN )      
-- -------------------------------------------------------------------------- --
UIPanelWindows["SpellTrackerFrame"] = { area = "doublewide", pushable = 0, width = 200, xoffset = 80, whileDead = 1 };
SpellTracker = {};
SpellTracker.Version = GetAddOnMetadata("SpellTracker", "Version");
SpellTracker.Build = select(4, GetBuildInfo());
SpellTracker.BARS = {}; -- stock les abbres qui sont cree au debut et sont dans le cache
SpellTracker.SpellListToSort = {}; -- litse ordonnee des barres a afficher
SpellTracker.ScrollValue = 0; -- valeur de la scrolbar virtuelle
SpellTracker.CountBarToDisplay = 0;
SpellTracker.CountBarDisplayed = 0;
SpellTracker.MinimapBtnDown = false;
SpellTracker.EventPerSec_LastTickTime = 0;
SpellTracker.EventPerSec_Ticks = 0;
SpellTracker.RefreshTime = 0;
SpellTracker.RaidLst = {}; -- raid tracking ( included raid palyer and raid pet )
SpellTracker.PartyLst = {}; -- grou tracking ( included party player and party pet )
SpellTracker.NodesToSort = {}; -- 0.48 on stocke par indexer parent des list ordonnee de childs
SpellTracker.NodesToSort_Position = {};
SpellTracker.KeyDown = ""; -- 0.55 key input
-- Expand / Collapse Constant
local SpellTracker_ExpandTypeNode1 = 1;
local SpellTracker_ExpandTypeNode2 = 2;
local SpellTracker_Collapse = 0;
local SortSpellList = nil; -- func de tri selon SpellTrackerDB.NumLineDisplay -- 0.66
-- bar font --
local FontPathTree = {
      name = [[Interface\AddOns\SpellTracker\Font\FRIZQT_MODIFIED.ttf]],
      size = 13,
      outline = "OUTLINE, MONOCHROME",
      shadow = 0,
    };
local ProfilStruct;
local currentIndexer;
local t0;
SpellTracker.CombatFlags = {
	[0x00004000]="TYPE_OBJECT",
	[0x00002000]="TYPE_GUARDIAN",
	[0x00001000]="TYPE_PET",
	[0x00000800]="TYPE_NPC",
	[0x00000400]="TYPE_PLAYER",
	[0x00000200]="CONTROL_NPC",
	[0x00000100]="CONTROL_PLAYER",
	[0x00000040]="REACTION_HOSTILE",
	[0x00000020]="REACTION_NEUTRAL",
	[0x00000010]="REACTION_FRIENDLY",
	[0x00000008]="AFFILIATION_OUTSIDER",
	[0x00000004]="AFFILIATION_RAID",
	[0x00000002]="AFFILIATION_PARTY",
	[0x00000001]="AFFILIATION_MINE",
};
-- Language
local L = setmetatable({}, {
    __index = function(t, k)
        error("Locale key " .. tostring(k) .. " is not provided.")
    end
});
if (GetLocale() == "frFR") then
	-- mots
	L[""] = "";
	L["BY"] = " par ";
	L["COUNT"] = "Nombre";
	L["HEAL"] = "Soin";
	L["DAMAGE"] = "D√©gat";
	L["TOTAL"] = "Total";
	L["DETAIL"] = "D√©tail";
	L["BAR"] = "Barre";
	L["AMOUNT"] = "Montant";
	L["HIT"] = "Hit";
	L["CRIT"] = "Crit";
	L["OVER"] = "Over";
	L["ABSORB"] = "Absorb";
	L["RECORDING"] = "ENREGISTREMENT";
	L["LOADED"] = "Charg√©";
	L["NOT"] = "Non";
	L["SOURCE"] = "Source";
	L["TYPE"] = "Type";
	L["NAME"] = "Nom";
	L["TARGET"] = "Cible";
	L["PRODUCED"] = "Produit";
	L["SPELL"] = "Sort";
	L["EMITTED"] = "Emit";
	L["RECEIVED"] = "Re√ßu";
	L["STOP"] = "ARRET";
	L["FRIEND"] = "Amis";
	L["HOSTILE"] = "Hostile";
	L["NEUTRAL"] = "Neute";
	L["REACTION"] = "R√©action";
	L["BEST"] = "Meilleur";
	L["MISSED"] = "Manqu√©";
	L["IMMUNE"] = "Immunit√©";
	L["CLASS"] = "Classe";
	L["SUM"] = "Somme";
	L["BEST"] = "Meilleur";
	L["BEST(S)"] = "Meilleurs";
	L["OF"] = "de";
	L["OF(S)"] = "des";
	L["REFRESH"] = "Rafraichir la vue";
	
	L["CLEAR_VIEW_DLG_INFOS"] = "Les donn√©es actuelles seront perdues !\nEtes vous sur de vouloir continuer ?";
    L["YES"] = "Oui";
    L["CANCEL"] = "Annuler";
	
	L["VIEWPLAYING"] = "Mise √† Jour de la Vue en Cours";
	L["VIEWPAUSE"] = "Mise √† Jour de la Vue en Pause";
	L["MODERECORDING"] = "Enregistrement en Cours";
	L["MODEPAUSE"] = "Enregistrement en Pause";
	
	L["NUMLINEDISP_SHORT_AMOUNT"] = "V";
	L["NUMLINEDISP_LONG_AMOUNT"] = "Valeurs";
	L["NUMLINEDISP_SHORT_TICK"] = "T";
	L["NUMLINEDISP_LONG_TICK"] = "Ticks";
	L["NUMLINEDISP_SHORT_BEST"] = "M";
	L["NUMLINEDISP_LONG_BEST"] = "Meilleurs";
	
	L["CONTEXT_MODE_SHORT"] = "CO";
	L["CONTEXT_MODE_LONG"] = "Contexte";
	L["CONTEXTLESS_MODE_SHORT"] = "HC";
	L["CONTEXTLESS_MODE_LONG"] = "Hors Contexte";
	
	L["SORTING_TOTAL"] = "Tri sur le Total";
	L["SORTING_HIT"] = "Tri sur le Hit";
	L["SORTING_CRIT"] = "Tri sur le Critique";
	L["SORTING_OVERCRIT"] = "Tri sur le Critique en exces";
	L["SORTING_OVER"] = "Tri sur le Hit en exces";
	L["SORTING_OVERABSORB"] = "Tri sur le Absorb en exces";
	L["SORTING_CRITABSORB"] = "Tri sur le Absorb Critique";
	L["SORTING_ABSORB"] = "Tri sur le Absorb";
	
	L["PLAYER_CHAR"] = "Joueur";
	L["PLAYER_CHAR_SHORT"] = "J";
	L["MOB_CHAR"] = "Pnj";
	L["MOB_CHAR_SHORT"] = "P";
	L["VEHICLE_CHAR"] = "Vehicule";
	L["VEHICLE_CHAR_SHORT"] = "V";
	L["PET_CHAR"] = "familier";
	L["PET_CHAR_SHORT"] = "f";
	
	-- complex
	L["SPT_CUR_VERS"] = "SpellTracker Version Courante :";
	L["SPT_DB_VERS"] = "SpellTracker DB Version :";
	L["SPT_DB_ERASE"] = "SpellTracker DB Effac√©e";
	L["TRACK_SRC"] = "Suivi de l'√©mission";
	L["TRACK_DST"] = "Suivi de la r√©ception";
	L["TRACK_ZONE"] = "Mode de Suivi de Zone par ";
	L["PLAYER_TRACKED"] = " Joueur/Pnj Suivi : ";
	L["LeftMouseButton"] = "LMB :";
	L["RightMouseButton"] = "LMD :";
	L["INFOS_CUR_TRACK"] = "Infos √† propos du suivi actuel :";
	L["FRIENDLY_PLAYER"] = "Joueurs Amis :";
	
	L["ERR_MSG1"] = "object == nil. print not functional";
	L["ERR_MSG2"] = " Is Not A String. Print Not Functional";
	
	L["HEAL_TOTAL"] = L["HEAL"].." "..L["TOTAL"] .." :";
	L["DAMAGE_TOTAL"] = L["DAMAGE"].." "..L["TOTAL"] .." :";
	
	L["HIT_AMOUNT"] = " : "..L["AMOUNT"].." de "..L["HIT"].." :";
	L["CRIT_AMOUNT"] = " : "..L["AMOUNT"].." de "..L["CRIT"].." :";
	L["OVER_CRIT_AMOUNT"] = " : "..L["AMOUNT"].." de "..L["OVER"].." & "..L["CRIT"].." :";
	L["OVER_AMOUNT"] = " : "..L["AMOUNT"].." de "..L["OVER"].." :";
	L["OVER_ABSRORB_AMOUNT"] = " : "..L["AMOUNT"].." de "..L["OVER"].." & "..L["ABSORB"].." :";
	L["CRIT_ABSORB_AMOUNT"] = " : "..L["AMOUNT"].." de "..L["CRIT"].." & "..L["ABSORB"].." :";
	L["ABSORB_AMOUNT"] = " : "..L["AMOUNT"].." de "..L["ABSORB"].." :";
	
	L["COUNT_HIT"] = L["COUNT"].." de "..L["HIT"].." :";
	L["COUNT_CRIT"] = L["COUNT"].." de "..L["CRIT"].." :";
	L["COUNT_CRIT_OVER"] = L["COUNT"].." de "..L["OVER"].." & "..L["CRIT"].." :";
	L["COUNT_OVER"] = L["COUNT"].." de "..L["OVER"].." :";
	L["COUNT_OVER_ABSORB"] = L["COUNT"].." de "..L["OVER"].." & "..L["ABSORB"].." :";
	L["COUNT_CRIT_ABSORB"] = L["COUNT"].." de "..L["CRIT"].." & "..L["ABSORB"].." :";
	L["COUNT_ABSORB"] = L["COUNT"].." de "..L["ABSORB"].." :";
	
	L["HIT_BEST"] = " : "..L["BEST"].." "..L["HIT"].." :";
	L["CRIT_BEST"] = " : "..L["BEST"].." "..L["CRIT"].." :";
	L["OVER_CRIT_BEST"] = " : "..L["BEST"].." "..L["OVER"].." & "..L["CRIT"].." :";
	L["OVER_BEST"] = " : "..L["BEST"].." "..L["OVER"].." :";
	L["OVER_ABSORB_BEST"] = " : "..L["BEST"].." "..L["OVER"].." & "..L["ABSORB"].." :";
	L["CRIT_ABSORB_BEST"] = " : "..L["BEST"].." "..L["CRIT"].." & "..L["ABSORB"].." :";
	L["ABSORB_BEST"] = " : "..L["BEST"].." "..L["ABSORB"].." :";
	
	L["SRC_TYPE_NAME"] = L["TYPE"].."/"..L["NAME"].." de la "..L["SOURCE"].." :";
	L["SRC_TYPE"] = L["TYPE"].." de la "..L["SOURCE"].." :";
	L["SRC_NAME"] = L["NAME"].." de la "..L["SOURCE"].." :";
	L["TGT_TYPE_NAME"] = L["TYPE"].."/"..L["NAME"].." de la "..L["TARGET"].." :";
	L["TGT_TYPE"] = L["TYPE"].." de la "..L["TARGET"].." :";
	L["TGT_NAME"] = L["NAME"].." de la "..L["TARGET"].." :";
	
	L["TOTAL_PRODUCED"] = L["TOTAL"].." "..L["PRODUCED"].." :";
	L["SUM_BEST"] = L["SUM"].." "..L["OF(S)"].." "..L["BEST(S)"].." :";
	
	L["TOOLTIP_MSG1"] = "Clickez sur le bouton gauche de la souris pour afficher le message de description du sort !";
	L["TOOLTIP_MSG2"] = "Clickez sur le bouton gauche de la souris pour afficher le message de description du tick !";
	L["ERROR_RELOAD_MSG1"] = "SVP RECHARGEZ L'INTERFACE APRES LA FIN DE VOTRE COMBAT";
	L["PAUSE_VIEW_UPDATING"] = "MISE A JOUR DE LA VUE EN PAUSE";
	L["PAUSE_VIEW_UPDATING_SHORT"] = "VUE EN PAUSE"; 
	L["NOCOMBAT_MSG1"] = "NE PEUT PAS FONTIONNER PENDANT UN COMBAT";
	L["TOOLTIP_MSG3"] = "Configurer la structure de donn√©e";
	L["TOOLTIP_MSG4"] = "Suivi de moi m√™me";
	L["TOOLTIP_MSG5"] = "Suivi de la cible actuelle";
	L["TOOLTIP_MSG6"] = "Suivi de zone";
	L["TOOLTIP_MSG7"] = "Suivi du raid";
	L["TOOLTIP_MSG8"] = "Suivi du groupe";
	L["ERROR_TARGET_MSG1"] = "ERREUR : CIBLE NON DETECTEE";
	L["ERROR_RAID_MSG1"] = "ERREUR : RAID NON DETECTE";
	L["ERROR_GROUP_MSG1"] = "ERREUR : GROUP NON DETECTE";
	L["TOOLTIP_MSG9"] = "Enregistrement d√©mar√©";
	L["TOOLTIP_MSG10"] = "Mise √† jour de la vue en pause (Peut etre automatique pour eviter les freeze pendant un combat)";
	L["TOOLTIP_MSG11"] = "Enregistrement Stopp√©";
	
	L["HIT_TYPE"] = L["HIT"].." "..L["TYPE"].." :";
	L["SRC_TYPE"] = L["SOURCE"].." "..L["TYPE"].." :";
	L["SRC_CLASS"] = L["SOURCE"].." "..L["CLASS"].." :";
	L["SRC_REACTION"] = L["SOURCE"].." "..L["REACTION"].." :";
	L["SRC_NAME"] = L["SOURCE"].." "..L["NAME"].." :";
	L["TGT_TYPE"] = L["TARGET"].." "..L["TYPE"].." :";
	L["TGT_CLASS"] = L["TARGET"].." "..L["CLASS"].." :";
	L["TGT_REACTION"] = L["TARGET"].." "..L["REACTION"].." :";
	L["TGT_NAME"] = L["TARGET"].." "..L["NAME"].." :";
else
	-- words
	L[""] = "";
	L["BY"] = " by ";
	L["COUNT"] = "Count";
	L["HEAL"] = "Heal";
	L["DAMAGE"] = "Damage";
	L["TOTAL"] = "Total";
	L["DETAIL"] = "Detail";
	L["BAR"] = "Bar";
	L["AMOUNT"] = "Amount";
	L["HIT"] = "Hit";
	L["CRIT"] = "Crit";
	L["OVER"] = "Over";
	L["ABSORB"] = "Absorb";
	L["RECORDING"] = "RECORDING";
	L["LOADED"] = "LOADED";
	L["NOT"] = "NOT";
	L["SOURCE"] = "Source";
	L["TYPE"] = "Type";
	L["NAME"] = "Name";
	L["TARGET"] = "Target";
	L["PRODUCED"] = "Produced :";
	L["SPELL"] = "Spell";
	L["EMITTED"] = "Emitted";
	L["RECEIVED"] = "Received";
	L["STOP"] = "STOP";
	L["FRIEND"] = "Friend";
	L["HOSTILE"] = "Hostile";
	L["NEUTRAL"] = "Neutral";
	L["REACTION"] = "Reaction";
	L["BEST"] = "BEST";
	L["MISSED"] = "MISSED";
	L["IMMUNE"] = "IMMUNE";
	L["CLASS"] = "Class";
	L["SUM"] = "Somme";
	L["BEST"] = "Best";
	L["OF"] = "of";
	L["REFRESH"] = "Refresh the View";
	
	L["CLEAR_VIEW_DLG_INFOS"] = "The actual Datas will be deleted !\nAre you sure to continue ?";
    L["YES"] = "Yex";
    L["CANCEL"] = "Cancel";
	
	L["VIEWPLAYING"] = "View Updating";
	L["VIEWPAUSE"] = "Pause View Update";
	L["MODERECORDING"] = "Recording";
	L["MODEPAUSE"] = "Pause Record";
	
	L["NUMLINEDISP_SHORT_AMOUNT"] = "A";
	L["NUMLINEDISP_LONG_AMOUNT"] = "Amount";
	L["NUMLINEDISP_SHORT_TICK"] = "T";
	L["NUMLINEDISP_LONG_TICK"] = "Ticks";
	L["NUMLINEDISP_SHORT_BEST"] = "B";
	L["NUMLINEDISP_LONG_BEST"] = "Best";
	
	L["CONTEXT_MODE_SHORT"] = "CO";
	L["CONTEXT_MODE_LONG"] = "Context";
	L["CONTEXTLESS_MODE_SHORT"] = "CL";
	L["CONTEXTLESS_MODE_LONG"] = "Context Less";
	
	L["SORTING_TOTAL"] = "Total Sorting";
	L["SORTING_HIT"] = "Hit Sorintg";
	L["SORTING_CRIT"] = "Critik Sorting";
	L["SORTING_OVERCRIT"] = "Over Critik Sorting";
	L["SORTING_OVER"] = "Over Sorting";
	L["SORTING_OVERABSORB"] = "Over Absorb Sorting";
	L["SORTING_CRITABSORB"] = "Critik Absorb Sorting";
	L["SORTING_ABSORB"] = "Absorb Sorting";
	
	L["PLAYER_CHAR"] = "Player";
	L["PLAYER_CHAR_SHORT"] = "P";
	L["MOB_CHAR"] = "Mob";
	L["MOB_CHAR_SHORT"] = "M";
	L["VEHICLE_CHAR"] = "Vehicle";
	L["VEHICLE_CHAR_SHORT"] = "V";
	L["PET_CHAR"] = "pet";
	L["PET_CHAR_SHORT"] = "p";
	
	-- complex
	L["SPT_CUR_VERS"] = "SpellTracker Current Version :";
	L["SPT_DB_VERS"] = "SpellTracker DB Version :";
	L["SPT_DB_ERASE"] = "SpellTracker DB Erased";
	L["TRACK_SRC"] = "Track Source";
	L["TRACK_DST"] = "Track Dest";
	L["TRACK_ZONE"] = " Zone Tracking Mode by ";
	L["PLAYER_TRACKED"] = " Player/Mob Tracked : ";
	L["LeftMouseButton"] = "LMB :";
	L["RightMouseButton"] = "DMB :";
	L["INFOS_CUR_TRACK"] = "Infos about current track :";
	L["FRIENDLY_PLAYER"] = "Friendly Players :";
	
	L["ERR_MSG1"] = "object == nil. print not functional";
	L["ERR_MSG2"] = " Is Not A String. Print Not Functional";
	
	L["HEAL_TOTAL"] = L["HEAL"].." "..L["TOTAL"] .." :";
	L["DAMAGE_TOTAL"] = L["DAMAGE"].." "..L["TOTAL"] .." :";
	
	L["HIT_AMOUNT"] = " : "..L["AMOUNT"].." de "..L["HIT"].." :";
	L["CRIT_AMOUNT"] = " : "..L["AMOUNT"].." de "..L["CRIT"].." :";
	L["OVER_CRIT_AMOUNT"] = " : "..L["AMOUNT"].." de "..L["OVER"].." & "..L["CRIT"].." :";
	L["OVER_AMOUNT"] = " : "..L["AMOUNT"].." de "..L["OVER"].." :";
	L["OVER_ABSRORB_AMOUNT"] = " : "..L["AMOUNT"].." de "..L["OVER"].." & "..L["ABSORB"].." :";
	L["CRIT_ABSORB_AMOUNT"] = " : "..L["AMOUNT"].." de "..L["CRIT"].." & "..L["ABSORB"].." :";
	L["ABSORB_AMOUNT"] = " : "..L["AMOUNT"].." de "..L["ABSORB"].." :";
	
	L["COUNT_HIT"] = L["COUNT"].." de "..L["HIT"].." :";
	L["COUNT_CRIT"] = L["COUNT"].." de "..L["CRIT"].." :";
	L["COUNT_CRIT_OVER"] = L["COUNT"].." de "..L["OVER"].." & "..L["CRIT"].." :";
	L["COUNT_OVER"] = L["COUNT"].." de "..L["OVER"].." :";
	L["COUNT_OVER_ABSORB"] = L["COUNT"].." de "..L["OVER"].." & "..L["ABSORB"].." :";
	L["COUNT_CRIT_ABSORB"] = L["COUNT"].." de "..L["CRIT"].." & "..L["ABSORB"].." :";
	L["COUNT_ABSORB"] = L["COUNT"].." de "..L["ABSORB"].." :";
	
	L["HIT_BEST"] = " : "..L["BEST"].." "..L["HIT"].." :";
	L["CRIT_BEST"] = " : "..L["BEST"].." "..L["CRIT"].." :";
	L["OVER_CRIT_BEST"] = " : "..L["BEST"].." "..L["OVER"].." & "..L["CRIT"].." :";
	L["OVER_BEST"] = " : "..L["BEST"].." "..L["OVER"].." :";
	L["OVER_ABSORB_BEST"] = " : "..L["BEST"].." "..L["OVER"].." & "..L["ABSORB"].." :";
	L["CRIT_ABSORB_BEST"] = " : "..L["BEST"].." "..L["CRIT"].." & "..L["ABSORB"].." :";
	L["ABSORB_BEST"] = " : "..L["BEST"].." "..L["ABSORB"].." :";
	
	L["SRC_TYPE_NAME"] = L["SOURCE"].." "..L["TYPE"].."/"..L["NAME"].." :";
	L["SRC_TYPE"] = L["SOURCE"].." "..L["TYPE"].." :";
	L["SRC_NAME"] = L["SOURCE"].." "..L["NAME"].." :";
	L["TGT_TYPE_NAME"] = L["TARGET"].." "..L["TYPE"].."/"..L["NAME"].." :";
	L["TGT_TYPE"] = L["TARGET"].." "..L["TYPE"].." :";
	L["TGT_NAME"] = L["TARGET"].." "..L["NAME"].." :";
	
	L["OF(S)"] = L["OF"];
	L["BEST(S)"] = L["BEST"];
	
	L["TOTAL_PRODUCED"] = L["TOTAL"].." "..L["PRODUCED"].." :";
	L["SUM_BEST"] = L["SUM"].." "..L["OF(S)"].." "..L["BEST(S)"].." :";
	
	L["TOOLTIP_MSG1"] = "Click on Left Button for show Spell Description ToolTip !";
	L["TOOLTIP_MSG2"] = "Click on Right Button for show Spell Tick Description ToolTip !";
	L["ERROR_RELOAD_MSG1"] = "PLEASE RELOAD INTERFACE AFTER THE END OF YOUR FIGHT";
	L["PAUSE_VIEW_UPDATING"] = "PAUSE VIEW UPDATING"; 
	L["PAUSE_VIEW_UPDATING_SHORT"] = "PAUSE VIEW"; 
	L["NOCOMBAT_MSG1"] = "CANT WORK WHILE IN FIGHT";
	L["TOOLTIP_MSG3"] = "Configure Datas Structure";
	L["TOOLTIP_MSG4"] = "My Player Tracking";
	L["TOOLTIP_MSG5"] = "Current Target Tracking";
	L["TOOLTIP_MSG6"] = "Zone Tracking";
	L["TOOLTIP_MSG7"] = "Raid Zone Tracking";
	L["TOOLTIP_MSG8"] = "Group Zone Tracking";
	L["ERROR_TARGET_MSG1"] = "ERROR : TARGET NOT DETECTED";
	L["ERROR_RAID_MSG1"] = "ERROR : RAID NOT DETECTED";
	L["ERROR_GROUP_MSG1"] = "ERROR : GROUP NOT DETECTED";
	L["TOOLTIP_MSG9"] = "Recording Started";
	L["TOOLTIP_MSG10"] = "Pause Updating View (Can be auto for Avoid Freeze while inf fight)";
	L["TOOLTIP_MSG11"] = "Recording Stopped";
	
	L["HIT_TYPE"] = L["HIT"].." "..L["TYPE"].." :";
	L["SRC_TYPE"] = L["SOURCE"].." "..L["TYPE"].." :";
	L["SRC_CLASS"] = L["SOURCE"].." "..L["CLASS"].." :";
	L["SRC_REACTION"] = L["SOURCE"].." "..L["REACTION"].." :";
	L["SRC_NAME"] = L["SOURCE"].." "..L["NAME"].." :";
	L["TGT_TYPE"] = L["TARGET"].." "..L["TYPE"].." :";
	L["TGT_CLASS"] = L["TARGET"].." "..L["CLASS"].." :";
	L["TGT_REACTION"] = L["TARGET"].." "..L["REACTION"].." :";
	L["TGT_NAME"] = L["TARGET"].." "..L["NAME"].." :";
end
-- Fonctions statiques GUI liees au XML
-- OnLoad ( SpellTrackerDB existe pas encore )
function SpellTrackerButtonTemplate_OnLoad(self)
	self.selected = false;
end
function SpellTrackerFilterButtonTemplate_OnLoad(self)
	self.selected = false;
	self:RegisterForClicks("AnyUp");
	--SpellTracker_ColumnFilterDropDownMenu_Init(self);
end
function SpellTrackerMinimapButton_OnLoad(self)
	SpellTrackerMinimapButton_UpdateTitle();
end
function SpellTrackerFrameContainer_OnLoad(self) -- chargement du container du grid
	self:RegisterForDrag("LeftButton");
	--self:SetScrollChild(SpellTrackerFrameContainerContainer);
end
function SpellTrackerFrame_OnLoad(self)
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_REGEN_DISABLED"); -- Get Aggro
    self:RegisterEvent("PLAYER_REGEN_ENABLED");	-- Leave Aggro
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED"); -- recuper les event de combat 
	self:RegisterEvent("RAID_ROSTER_UPDATE");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
end
function SpellTrackerFrame_Init(self)
	local WellLoaded = false;

	SpellTrackerDB = SpellTrackerDB or {};

	print(L["SPT_CUR_VERS"]..SpellTracker.Version);
	
	if ( SpellTrackerDB.Version ) then
		print(L["SPT_DB_VERS"]..SpellTrackerDB.Version);
		if ( SpellTrackerDB.Version ~= SpellTracker.Version ) then
			print(L["SPT_DB_ERASE"]);
			SpellTrackerDB = {};
			SpellTrackerDB.Version = SpellTracker.Version;
		end
	else
		SpellTrackerDB = {};
		SpellTrackerDB.Version = SpellTracker.Version;
	end
	
	SpellTrackerDB.Separator = "@"; -- 0.49 bug fix
	
	-- Tracking Option
	SpellTrackerDB.Tracking_Target = SpellTrackerDB.Tracking_Target or 1; -- my player / sel player / zone / group / raid
	SpellTrackerDB.Tracking_Mode = SpellTrackerDB.Tracking_Mode or 1; -- src / dst

	SpellTrackerDB.Recording_Mode = SpellTrackerDB.Recording_Mode or 1; -- 1 = recording / 0 = pause
	SpellTracker_SetRecordingMode(SpellTrackerDB.Recording_Mode);
	
	-- Context or Not
	SpellTrackerDB.Context = SpellTrackerDB.Context or 0; -- Context = 0 / Context Less = 1
	if ( SpellTrackerDB.Context == 0 ) then SpellTrackerFrameMainMenuTitleContextBtnLabel:SetText("");--L["CONTEXT_MODE_SHORT"]);
	elseif ( SpellTrackerDB.Context == 1 ) then SpellTrackerFrameMainMenuTitleContextBtnLabel:SetText("");--L["CONTEXTLESS_MODE_SHORT"]);
	end
	
	-- NumLine Display
	SpellTrackerDB.NumLineDisplay = SpellTrackerDB.NumLineDisplay or 0; -- 0 Amount / 1 Ticks / 2 Best
	if ( SpellTrackerDB.NumLineDisplay == 0 ) then SpellTrackerFrameMainMenuTitleNumLineDisplayBtnLabel:SetText(L["NUMLINEDISP_SHORT_AMOUNT"]); SortSpellList = SortSpellList_Amount;
	elseif ( SpellTrackerDB.NumLineDisplay == 1 ) then SpellTrackerFrameMainMenuTitleNumLineDisplayBtnLabel:SetText(L["NUMLINEDISP_SHORT_TICK"]); SortSpellList = SortSpellList_Tick;
	elseif ( SpellTrackerDB.NumLineDisplay == 2 ) then SpellTrackerFrameMainMenuTitleNumLineDisplayBtnLabel:SetText(L["NUMLINEDISP_SHORT_BEST"]); SortSpellList = SortSpellList_Best;
	end
	
	SpellTrackerDB.Record = SpellTrackerDB.Record or {}; -- les record ( valeur la plus garnd atteinte )
	SpellTrackerDB.SPELLS = SpellTrackerDB.SPELLS or {}; -- stock les infos a afficher
	SpellTrackerDB.FILTEREDSPELLS = SpellTrackerDB.FILTEREDSPELLS or {}; -- version filtrÈs en fonction justement des filtres
	SpellTrackerDB.FILTEREDSPELLS.count = 0;
	SpellTrackerDB.NodesToSort = {};
	
	SpellTrackerDB.Params = SpellTrackerDB.Params or {};
	SpellTrackerDB.Params.SpellBarHeight = SpellTrackerDB.Params.SpellBarHeight or 20;
	SpellTrackerDB.Params.FrameWidth = SpellTrackerDB.Params.FrameWidth or 600;
	SpellTrackerDB.Params.FrameHeight = SpellTrackerDB.Params.FrameHeight or 600;
	
	SpellTrackerDB.ColumnFilter = SpellTrackerDB.ColumnFilter or {Count=0; QuickAcces={}};
	SpellTrackerDB.Params.CurrentColumnFilter = SpellTrackerDB.Params.CurrentColumnFilter or "";
	SpellTrackerDB.Params.CurrentColumnFilterString = SpellTrackerDB.Params.CurrentColumnFilterString or "";
	
	-- faudra trouver une formule pour calculer automatiquement la valeur selon le nombre de barres totales a afficher et le nombre de barres qu'on peut afficher
	-- en fait le mieux est jutse de tenir compte d'un ratio du nombre de barres qu'on peut afficher
	SpellTrackerDB.Params.SrollStep = 2; -- en nombres de barres
	
	-- seuil en seconde au dela duquel l'indicateur de Ev/s est reset
	SpellTrackerDB.Params.EventPerSec_SeuilInSecBeforeReset = 5;
	
	-- indique les items possible pour la structure de donnÈe / 0.41
	SpellTrackerDB.Params.DataStructItems = 
	{
		[1]="SpellName", -- permet de pas Ítre embÍtÈ avec un sort en 8... et son tick en 10... ( ce serait bien de faire le distinguo..; => a voir )
		[2]="HitType", -- le meme sort peux faire du heal et du dÈgat
		[3]="SourceClass", -- donne la class qui qui a Íµ© dÍµ•ctÈ°∞our les sort
		[4]="SourceType", -- Mob / Player / Pet / Vehicle
		[5]="SourceReaction", -- rÈaction de la source par rapport a mon perso
		[6]="SourceName", -- Name
		[7]="TargetClass", -- donne la class qui qui a Íµ© dÍµ•ctÈ°∞our les sort
		[8]="TargetType", -- Mob / Player / Pet / Vehicle
		[9]="TargetReaction", -- rÈaction de la cible par rapport a mon perso
		[10]="TargetName" -- Name
	};
	
	-- on inverse dans la meme table
	SpellTrackerDB.Params.DataStructItemsInv = {};
	for k,v in ipairs(SpellTrackerDB.Params.DataStructItems) do
		SpellTrackerDB.Params.DataStructItemsInv[v] = k;
	end
	
	SpellTrackerDB.Params.DataStructString = SpellTrackerDB.Params.DataStructString or "SpellName>HitType>SourceClass>SourceType>SourceReaction>SourceName>TargetClass>TargetType>TargetReaction>TargetName";
	SpellTrackerDB.Params.DataStructStringDisplayedFilter = DataStructStringDisplayedFilter or string.gsub(SpellTrackerDB.Params.DataStructString, ">", "+");
	
	-- DropDown Menus
		-- TARGET
		SpellTracker_TargetDropDownMenu_Init();
		-- SRC OR DST
		SpellTracker_SrcOrDstDropDownMenu_Init();
		-- RECORDING / PAUSE / STOP
		--SpellTracker_RecordingDropDownMenu_Init();
		-- FILTER
		--SpellTracker_FilterDropDownMenu_Init();
		-- CATEGORY
		--SpellTracker_ColumnFilterDropDownMenu_Init();
		
	--Color => ce qui suit vien du fichier bli≤ constant.lua
	--NORMAL_FONT_COLOR           = {r=1.0, g=0.82, b=0.0};
	--HIGHLIGHT_FONT_COLOR        = {r=1.0, g=1.0, b=1.0};
	--RED_FONT_COLOR              = {r=1.0, g=0.1, b=0.1};
	--DIM_RED_FONT_COLOR          = {r=0.8, g=0.1, b=0.1};
	--GREEN_FONT_COLOR            = {r=0.1, g=1.0, b=0.1};
	--GRAY_FONT_COLOR             = {r=0.5, g=0.5, b=0.5};
	--YELLOW_FONT_COLOR           = {r=1.0, g=1.0, b=0.0};
	--LIGHTYELLOW_FONT_COLOR      = {r=1.0, g=1.0, b=0.6};
	--ORANGE_FONT_COLOR           = {r=1.0, g=0.5, b=0.25};
	--PASSIVE_SPELL_FONT_COLOR    = {r=0.77, g=0.64, b=0.0};
	--BATTLENET_FONT_COLOR        = {r=0.510, g=0.773, b=1.0};
	
	SpellTrackerDB.Params.DefaultColor = SpellTrackerBar_GetColorCodeFromRGBStruct(NORMAL_FONT_COLOR);
	SpellTrackerDB.Params.NeutralColor = SpellTrackerBar_GetColorCodeFromRGBStruct(ORANGE_FONT_COLOR);
	SpellTrackerDB.Params.FriendlyColor = SpellTrackerBar_GetColorCodeFromRGBStruct(GREEN_FONT_COLOR);
	SpellTrackerDB.Params.HostileColor = SpellTrackerBar_GetColorCodeFromRGBStruct(RED_FONT_COLOR);
	
	-- Dicos
	SpellTrackerDB.Dicos = SpellTrackerDB.Dicos or {};
	SpellTrackerDB.Dicos.Icons = SpellTrackerDB.Dicos.Icons or {};
	SpellTrackerDB.Dicos.Class = SpellTrackerDB.Dicos.Class or {};
	
	-- Dicos : Prepare Raid_Class_Color struct -- vient de RAID_CLASS_COLORS
	SpellTrackerDB.Dicos.ColorOfClass = {};
	for k, w in pairs (RAID_CLASS_COLORS) do
		SpellTrackerDB.Dicos.ColorOfClass[k] = SpellTrackerBar_GetColorCodeFromRGB(w.r,w.g,w.b);
	end

	-- par default => SpellTrackerDB.Params.DefaultCountSpellsToTrack = 50; -- pilote le nombre de barres qui vont Ítre crÈes ‡ l'avance
	-- un raid sur orgri ca fait 200 barres de sort principale
	--SpellTrackerDB.Params.DefaultCountSpellsToTrack = 200; -- pilote le nombre de barres qui vont Ítre crÈes ‡ l'avance
	
	SpellTrackerDB.SPELLSTOTTRACK = SpellTrackerDB.SPELLSTOTTRACK or {}; -- stock les sort ‡ traquer
	
	SpellTrackerDB.CurrentPlayerTracked = SpellTrackerDB.CurrentPlayerTracked or {};
	if ( SpellTrackerDB.Tracking_Target ~= 3 ) then -- zone tracking c'est les 3 membre == nil ce qui est faususÈ par l'affectation + init de base truc = truc or machin
		SpellTrackerDB.CurrentPlayerTracked.GUID = SpellTrackerDB.CurrentPlayerTracked.GUID or UnitGUID("player");
		SpellTrackerDB.CurrentPlayerTracked.Name = SpellTrackerDB.CurrentPlayerTracked.Name or UnitName("player");
		SpellTrackerDB.CurrentPlayerTracked.lvl = SpellTrackerDB.CurrentPlayerTracked.lvl or UnitLevel("player");
	end
	--SpellTrackerDB.CurrentPlayerTracked.Track_Attack_or_Attacked = SpellTrackerDB.CurrentPlayerTracked.Track_Attack_or_Attacked or true;
	SpellTrackerDB.MsgToolTip = SpellTrackerDB.MsgToolTip or L["TRACK_SRC"];
	
	WellLoaded = SpellTracker:InitDataStruct(SpellTrackerDB.Params.DataStructString);
	WellLoaded = SpellTracker:InitDisplayedFilter(SpellTrackerDB.Params.DataStructStringDisplayedFilter);
	
	-- PLAY VIEW / PAUSE VIEW
	SpellTrackerDB.ViewPlaying = SpellTrackerDB.ViewPlaying or 1; -- 1 playing view / 0 pause view
	SpellTrackerDB.LastViewPlayingValue = SpellTrackerDB.LastViewPlayingValue or 1; -- 1 playing view / 0 pause view
	SpellTracker_SetViewPlayingMode(SpellTrackerDB.ViewPlaying);
	
	-- record de ev/s
	SpellTrackerDB.Record.MaxEventPerSecValue = SpellTrackerDB.Record.MaxEventPerSecValue or 0;
	SpellTrackerDB.Record.MaxRefreshTime = SpellTrackerDB.Record.MaxRefreshTime or 0;
	SpellTrackerDB.Record.MaxRefreshTime_CountBars = SpellTrackerDB.Record.MaxRefreshTimeCountBars or 0; -- le nombre de bar quand on est au max en temps
	SpellTrackerDB.Record.MaxRefreshTime_EventPerSec = SpellTrackerDB.Record.MaxRefreshTime_EventPerSec or 0; -- la valeur ev/s quand on est au max
	
	SpellTrackerDB.currentSessionHealTotal = SpellTrackerDB.currentSessionHealTotal or 0;
	SpellTrackerDB.currentSessionDamageTotal = SpellTrackerDB.currentSessionDamageTotal or 0;
	
	SpellTracker:AdjustColorOfSpellTrackerMinimapButton();
	
	SpellTrackerButton_UpdateTitle();

	if ( SpellTrackerDB.SortColors == nil ) then
		SpellTrackerDB.SortColors = {};
		SpellTrackerDB.SortColors.Absorb = {r=0.8,g=0.8,b=0.8};
		SpellTrackerDB.SortColors.CritAndAbsorb = {r=0.85,g=0.75,b=0.6};
		SpellTrackerDB.SortColors.OverHitAndAbsorb = {r=0.9,g=0.7,b=0.4};
		SpellTrackerDB.SortColors.OverHit = {r=1,g=0.6,b=0};
		SpellTrackerDB.SortColors.OverHitAndCrit = {r=0.6,g=0.5,b=0.5};
		SpellTrackerDB.SortColors.Crit = {r=0.2,g=0.4,b=1};
		SpellTrackerDB.SortColors.CritAndHit = {r=0.2,g=0.7,b=0.6};
		SpellTrackerDB.SortColors.Hit = {r=0.2,g=1,b=0.2};
		SpellTrackerDB.SortColors.Light = {r=1.0,g=1.0,b=1.0};
	end
	
	-- SortBtn Adjust Color
	SpellTrackerBar_SetTextureColorFromColorTab(SpellTrackerFrameMainMenuTitleSortHitBtn.bg, SpellTrackerDB.SortColors.Hit);
	SpellTrackerBar_SetTextureColorFromColorTab(SpellTrackerFrameMainMenuTitleSortHitBtn.hl, SpellTrackerDB.SortColors.Light);	
	SpellTrackerBar_SetTextureColorFromColorTab(SpellTrackerFrameMainMenuTitleSortCritBtn.bg, SpellTrackerDB.SortColors.Crit);
	SpellTrackerBar_SetTextureColorFromColorTab(SpellTrackerFrameMainMenuTitleSortCritBtn.hl, SpellTrackerDB.SortColors.Light);	
	SpellTrackerBar_SetTextureColorFromColorTab(SpellTrackerFrameMainMenuTitleSortOverCritBtn.bg, SpellTrackerDB.SortColors.OverHitAndCrit);
	SpellTrackerBar_SetTextureColorFromColorTab(SpellTrackerFrameMainMenuTitleSortOverCritBtn.hl, SpellTrackerDB.SortColors.Light);	
	SpellTrackerBar_SetTextureColorFromColorTab(SpellTrackerFrameMainMenuTitleSortOverBtn.bg, SpellTrackerDB.SortColors.OverHit);
	SpellTrackerBar_SetTextureColorFromColorTab(SpellTrackerFrameMainMenuTitleSortOverBtn.hl, SpellTrackerDB.SortColors.Light);	
	SpellTrackerBar_SetTextureColorFromColorTab(SpellTrackerFrameMainMenuTitleSortOverAbsorbBtn.bg, SpellTrackerDB.SortColors.OverHitAndAbsorb);
	SpellTrackerBar_SetTextureColorFromColorTab(SpellTrackerFrameMainMenuTitleSortOverAbsorbBtn.hl, SpellTrackerDB.SortColors.Light);	
	SpellTrackerBar_SetTextureColorFromColorTab(SpellTrackerFrameMainMenuTitleSortCritAbsorbBtn.bg, SpellTrackerDB.SortColors.CritAndAbsorb);
	SpellTrackerBar_SetTextureColorFromColorTab(SpellTrackerFrameMainMenuTitleSortCritAbsorbBtn.hl, SpellTrackerDB.SortColors.Light);	
	SpellTrackerBar_SetTextureColorFromColorTab(SpellTrackerFrameMainMenuTitleSortAbsorbBtn.bg, SpellTrackerDB.SortColors.Absorb);
	SpellTrackerBar_SetTextureColorFromColorTab(SpellTrackerFrameMainMenuTitleSortAbsorbBtn.hl, SpellTrackerDB.SortColors.Light);	
					
	SpellTrackerDB.CurrentSort = SpellTrackerDB.CurrentSort or 1; -- 1 Total / 2 hit / 3 crit / 4 overcrit / 5 over / 6 overAbsorb / 7 CritAbsorb / 8 Absorb
	SpellTracker_SwitchSorting(SpellTrackerDB.CurrentSort);
	
	-- Target
	--SpellTracker_SwitchTarget({arg1=SpellTrackerDB.Tracking_Target});
	
	-- Popup Dialog
	StaticPopupDialogs["CLEAR_VIEW_DLG"] = 
	{
        text = L["CLEAR_VIEW_DLG_INFOS"],
        button1 = L["YES"],
        button2 = L["CANCEL"],
        OnAccept = function() end,
		OnCancel = function() end,
        timeout = 0,
        hideOnEscape = 1,
        exclusive = 1,
        whileDead = 1,
        --hasEditBox = 0,
        preferredIndex = 3,
		result = false,
    }
	
	if ( SpellTracker:IsInCombat() == false ) then
		SpellTrackerFrame:SetWidth(SpellTrackerDB.Params.FrameWidth);
		SpellTrackerFrame:SetHeight(SpellTrackerDB.Params.FrameHeight);
		SpellTrackerPopupDataStructDlg_Create();
		SpellTrackerPopupReportDlg_Create();
		SpellTrackerPopupColumnFilterDlg_Create();
	end
end
--- DataStruct Dlg Popup
function SpellTrackerPopupDataStructDlg_Create()
	local DataStructDlg = CreateFrame("Frame", "SpellTrackerDataStructConfigDlg", UIParent, "SpellTrackerPopupTemplate");
	if ( DataStructDlg ) then
		DataStructDlg:SetFrameStrata("FULLSCREEN_DIALOG");
		DataStructDlg:SetToplevel(1);
		DataStructDlg:Hide();
		DataStructDlg:SetWidth(180);
		DataStructDlg:SetPoint("TOPLEFT", SpellTrackerFrameMainMenuTitleFilterBtn, "BOTTOMLEFT", 0,0);
		DataStructDlg.Buttons = {};
		DataStructDlg.var = {};
		DataStructDlg.var.FilterString = "";
		
		local offsetY = -2;
		local itW = DataStructDlg:GetWidth();
		local itH = SpellTrackerDB.Params.SpellBarHeight;
		local lastBar;
		for k, v in ipairs(SpellTrackerDB.Params.DataStructItems) do
			local frmName = "SpellTrackerDataStructConfigDlgBar"..tostring(k);
			local bar = CreateFrame("Button", frmName, DataStructDlg, "SpellTrackerPopupButtonTemplate");
			if ( bar ) then
				DataStructDlg.Buttons[k] = bar;
				bar:SetScript("OnClick", SpellTrackerPopupDataStructDlgBtn_Click);
				bar:RegisterForClicks("AnyUp");
				bar.var = {};
				bar.var.Label = _G[frmName.."Label"];
				--bar.var.Label:SetFont(FontPath.name, FontPath.size);
				bar:SetParent(DataStructDlg);
				if ( lastBar == nil ) then
					bar:SetPoint("TOPLEFT", DataStructDlg, "TOPLEFT", 0, 0);
				else
					bar:SetPoint("TOPLEFT", lastBar, "BOTTOMLEFT", 0, offsetY);
				end
				bar:SetWidth(itW);
				bar:SetHeight(itH);
				lastBar = bar;
			end
		end
		
		local ApplyBtnHeight = 20;
		local ApplyButton = CreateFrame("Button", "SpellTrackerDataStructConfigDlgApplyBtn", DataStructDlg, "UIPanelButtonTemplate");
		if ( ApplyButton ) then
			--ApplyButton:SetFrameStrata("FULLSCREEN_DIALOG");
			--ApplyButton:SetToplevel(1);
			ApplyButton:SetWidth(180);
			ApplyButton:SetPoint("TOPLEFT", lastBar, "BOTTOMLEFT", 0, 0);
			ApplyButton:SetText("Apply");
			ApplyButton:SetHeight(ApplyBtnHeight);
			ApplyButton:SetScript("OnClick", SpellTrackerPopupDataStructDlg_Apply);
		end
		
		local NewHeight = #SpellTrackerDB.Params.DataStructItems * ( itH + math.abs(offsetY) ) + ApplyBtnHeight;
		DataStructDlg:SetHeight(NewHeight);		
	end
end
function SpellTrackerPopupDataStructDlgBtn_Click(self) -- DataStruct dlg button click
	if ( self.var.Label ) then
		local DataStructDlg = SpellTrackerDataStructConfigDlg;
		local item = SpellTrackerDB.Params.DataStructItems[self.var.idx];
		if ( string.match(DataStructDlg.var.FilterString, item) ) then -- on l'enleve de la chaine
			local fString = DataStructDlg.var.FilterString;
			if ( fString:gsub(item..">","") ~= fString ) then fString = fString:gsub(item..">",""); 
			elseif ( fString:gsub(">"..item,"") ~= fString ) then fString = fString:gsub(">"..item,""); 
			elseif ( fString == item ) then fString = ""; 
			end
			DataStructDlg.var.FilterString = fString;
		else
			if ( DataStructDlg.var.FilterString == "" ) then
				DataStructDlg.var.FilterString = item;
			else
				DataStructDlg.var.FilterString = DataStructDlg.var.FilterString..">"..item;
			end
		end
		SpellTrackerPopupDataStructDlgBtn_Update(); -- DataStruct view update
	end
end
function SpellTrackerPopupDataStructDlg_Show() -- DataStruct dlg show
	local DataStructDlg = SpellTrackerDataStructConfigDlg;
	DataStructDlg.var.FilterString = SpellTrackerDB.Params.DataStructString;
	SpellTrackerPopupDataStructDlgBtn_Update();
	DataStructDlg:Show();
end
function SpellTrackerPopupDataStructDlg_Hide() -- DataStruct dlg hide
	local DataStructDlg = SpellTrackerDataStructConfigDlg;
	DataStructDlg:Hide();
end
function SpellTrackerPopupDataStructDlg_Apply() -- DataStruct dlg apply FilterString
	local function PopupDataStructDlg_Accept(self)
        local popup;
        if self:GetParent():GetName() == "UIParent" then popup = self;
        else popup = self:GetParent();
        end
        
		local DataStructDlg = SpellTrackerDataStructConfigDlg;
		SpellTracker:ChangeDataStruct(DataStructDlg.var.FilterString);			
		DataStructDlg:Hide();
		
        popup:Hide(); -- on ferme la boite de dialogue
    end
	
	local function PopupDataStructDlg_Cancel(self)
        local popup;
        if self:GetParent():GetName() == "UIParent" then popup = self;
        else popup = self:GetParent();
        end
        
		local DataStructDlg = SpellTrackerDataStructConfigDlg;
		DataStructDlg:Hide();
		
        popup:Hide(); -- on ferme la boite de dialogue
    end
	
	StaticPopupDialogs["CLEAR_VIEW_DLG"].OnAccept = PopupDataStructDlg_Accept;
	StaticPopupDialogs["CLEAR_VIEW_DLG"].OnCancel = PopupDataStructDlg_Cancel;
	
	StaticPopup_Show("CLEAR_VIEW_DLG");
end
function SpellTrackerPopupDataStructDlgBtn_Update() -- DataStruct dlg iew update
	local DataStructDlg = SpellTrackerDataStructConfigDlg;
	local FilterString = DataStructDlg.var.FilterString;
	local arr = SpellTracker:StringFiltering(FilterString, "(%S+)>(%S+)");
	if ( arr ) then
		local BarIdx = 0;
		if ( FilterString ~= "" ) then
			local count = #arr+1;
			for k=0, count do
				BarIdx = k;
				local btn = DataStructDlg.Buttons[BarIdx];
				if ( btn ) then
					local str = SpellTracker:RepeatString(" ", k).."¬≤¬π "..arr[k-1];
					btn.var.Label:SetText(str);
					btn.var.idx = SpellTrackerDB.Params.DataStructItemsInv[arr[k-1]];
				end
			end
		end
		-- on affiche le reste √† la fin --
		local dsItems = SpellTrackerDB.Params.DataStructItems;
		for k, v in ipairs(dsItems) do
			if ( not string.match(FilterString, dsItems[k]) ) then -- l'item est pas dans la liste des filtre de cette dlg
				BarIdx = BarIdx + 1;
				local btn = DataStructDlg.Buttons[BarIdx];
				if ( btn ) then
					btn.var.Label:SetText(dsItems[k]);
					btn.var.idx = k;
				end
			end
		end
	end   
end
--- ColumnFilter Dlg Popup
function SpellTrackerPopupColumnFilterDlg_Create()
	local ColumnFilterDlg = CreateFrame("Frame", "SpellTrackerPopupColumnFilterDlg", SpellTrackerFrame, "SpellTrackerPopupTemplate");
	if ( ColumnFilterDlg ) then
	   ColumnFilterDlg:SetFrameStrata("FULLSCREEN_DIALOG");
	   ColumnFilterDlg:SetToplevel(1);
	   ColumnFilterDlg:Hide();
	   ColumnFilterDlg:SetWidth(300);
	   ColumnFilterDlg:SetPoint("CENTER", UIParent, "CENTER", 0,250);
	   ColumnFilterDlg.Buttons = {};
	   ColumnFilterDlg.var = {};
	   ColumnFilterDlg.var.FilterString = "";
	   
	   --[[
	   local EditBoxHeight = 20;
	   local EditFilterCompletion = CreateFrame("EditBox", "SpellTrackerColumnFilterEditFilterCompletion", ColumnFilterDlg, "InputBoxTemplate");
	   if ( EditFilterCompletion ) then
		  EditFilterCompletion:SetPoint("TOPLEFT", ColumnFilterDlg, "TOPLEFT", 6, 0);
		  EditFilterCompletion:SetPoint("TOPRIGHT", ColumnFilterDlg, "TOPRIGHT", -1, 0);
		  EditFilterCompletion:SetHeight(EditBoxHeight);
		  EditFilterCompletion:Show();
	   end
	   ]]
	   
	   local ApplyBtnHeight = 20;
	   local ApplyButton = CreateFrame("Button", "SpellTrackerColumnFilterConfigDlgApplyBtn", ColumnFilterDlg, "UIPanelButtonTemplate");
	   if ( ApplyButton ) then
		  ApplyButton:SetPoint("BOTTOMLEFT", ColumnFilterDlg, "BOTTOMLEFT", 1,2);
		  ApplyButton:SetPoint("BOTTOMRIGHT", ColumnFilterDlg, "BOTTOMRIGHT", -1, 2);
		  ApplyButton:SetText("Apply");
		  ApplyButton:SetHeight(ApplyBtnHeight);
		  ApplyButton:SetScript("OnClick", SpellTrackerPopupColumnFilterDlg_Apply);
		  ApplyButton:Show();
	   end
	   
	   ColumnFilterDlg.nBarDisplayed = 10; -- nombre de barres
	   
	   local Container = CreateFrame("Frame", "SpellTrackerPopupColumnFilterDlgContainer", ColumnFilterDlg);
	   if ( Container ) then
			if ( EditFilterCompletion ) then
				Container:SetPoint("TOPLEFT", EditFilterCompletion, "BOTTOMLEFT", 0, -2);
			else
				Container:SetPoint("TOPLEFT", ColumnFilterDlg, "TOPLEFT", 0, -2);
			end
		  Container:SetPoint("BOTTOMRIGHT", ApplyButton, "TOPRIGHT", -5, -2);
		  
		  Container:SetScript("OnMouseWheel",SpellTrackerPopupColumnFilterDlgVirtualScrollBar_OnMouseWheel);
		  
		  local offsetY = -2;
		  local itW = ColumnFilterDlg:GetWidth();
		  local itH = SpellTrackerDB.Params.SpellBarHeight;
		  local lastBar;
		  for k=0, ColumnFilterDlg.nBarDisplayed-1 do
			 local frmName = "SpellTrackerPopupColumnFilterDlgContainerBar"..tostring(k);
			 local bar = _G[frmName] or CreateFrame("Button", frmName, Container, "SpellTrackerPopupButtonCheckableTemplate");
			 if ( bar ) then
				ColumnFilterDlg.Buttons[k] = bar;
				bar:SetScript("OnClick", SpellTrackerPopupColumnFilterDlgBtn_Click);
				bar:RegisterForClicks("AnyUp");
				bar.var = {};
				bar.var.Label = _G[frmName.."Label"];
				--bar.var.Label:SetFont(FontPath.name, FontPath.size);
				bar:SetParent(Container);
				if ( lastBar == nil ) then
				   bar:SetPoint("TOPLEFT", Container, "TOPLEFT", 0, 0);
				   bar:SetPoint("TOPRIGHT", Container, "TOPRIGHT", 0, 0);
				else
				   bar:SetPoint("TOPLEFT", lastBar, "BOTTOMLEFT", 0, offsetY);
				   bar:SetPoint("TOPRIGHT", lastBar, "BOTTOMRIGHT", 0, offsetY);
				end
				bar:SetHeight(itH);
				lastBar = bar;
			 end
		  end

		  ColumnFilterDlg.SrollStep = 1; -- nombre de barres a sauter en defilement
		  ColumnFilterDlg.ScrollValue = 0;
		  
		  local NewHeightContainer = ColumnFilterDlg.nBarDisplayed * ( itH + math.abs(offsetY) ) + 2;
		  
		  local NewHeight = NewHeightContainer + ApplyBtnHeight;
		  
			if ( EditFilterCompletion ) then
				NewHeight = NewHeight + EditBoxHeight;
			end
			
		  ColumnFilterDlg:SetHeight(NewHeight);        
	   end
	end
	ColumnFilterDlg:Hide();
end
function SpellTrackerPopupColumnFilterDlgBtn_Click(self) -- ColumnFilter dlg button click
	if ( self.var.item ) then
		--print(self.var.item);
		local ColumnFilterDlg = SpellTrackerPopupColumnFilterDlg;
		local help = SpellTrackerDB.Params.CurrentColumnFilter;
		if ( ColumnFilterDlg and help ) then
			if ( ColumnFilterDlg.tmpArr ) then
				if ( ColumnFilterDlg.tmpArr[self.var.item] ~= nil ) then
					-- 0 == false / 1 == true / 2 == false + desactiv√© / 3 == true + d√©sactiv√©
					if ( ColumnFilterDlg.tmpArr[self.var.item] == 0 ) then ColumnFilterDlg.tmpArr[self.var.item] = 1;
					elseif ( ColumnFilterDlg.tmpArr[self.var.item] == 1 ) then ColumnFilterDlg.tmpArr[self.var.item] = 0;
					elseif ( ColumnFilterDlg.tmpArr[self.var.item] == 2 ) then ColumnFilterDlg.tmpArr[self.var.item] = 3;
					elseif ( ColumnFilterDlg.tmpArr[self.var.item] == 3 ) then ColumnFilterDlg.tmpArr[self.var.item] = 2;
					end
					SpellTrackerPopupColumnFilterDlgBtn_Update(help, true);
				end
			end
		end
	end
end
function SpellTrackerPopupColumnFilterDlg_ShowOrHide(self) -- ColumnFilter dlg show
	local ColumnFilterDlg = SpellTrackerPopupColumnFilterDlg;
	if ( ColumnFilterDlg ) then
		local visible = false;
		if ( SpellTrackerDB.Params.CurrentColumnFilter == self.help ) then 
			if ( ColumnFilterDlg:IsVisible() ) then -- si d√©ja ouvert on cache
				visible = true;
				ColumnFilterDlg:Hide(); -- on cache si on a ouvert l'item courant et qu'on veut le cahcer
			end 
		end
		if ( visible == false ) then
			ColumnFilterDlg.ScrollValue = 0; -- reset de la position de la scrollbar virtuelle
			SpellTrackerDB.Params.CurrentColumnFilter = self.help; -- voir SpellTracker_ColumnFilterDropDownMenu_OnLoad
			SpellTrackerPopupColumnFilterDlgBtn_Update(self.help, false);
			ColumnFilterDlg:SetPoint("TOPLEFT",self, "BOTTOMLEFT", 0,0);
			ColumnFilterDlg:Show();
		end
	end
end
function SpellTrackerPopupColumnFilterDlg_Hide() -- ColumnFilter dlg hide
	local ColumnFilterDlg = SpellTrackerPopupColumnFilterDlg;
	if ( ColumnFilterDlg ) then
		ColumnFilterDlg:Hide();
	end
end
function SpellTrackerPopupColumnFilterDlg_Apply() -- ColumnFilter dlg apply FilterString
	local ColumnFilterDlg = SpellTrackerPopupColumnFilterDlg;
	if ( ColumnFilterDlg ) then
		if ( ColumnFilterDlg.tmpArr ) then
			-- on va recopier la veleur bool de ce tab tmp dans la base
			local cFilter = SpellTrackerDB.Params.CurrentColumnFilter;
			--SpellTrackerDB.ColumnFilter[cFilter].Count = SpellTrackerDB.ColumnFilter[cFilter].Count or 0;
			for k, v in pairs(ColumnFilterDlg.tmpArr) do
				SpellTrackerDB.ColumnFilter[cFilter][k] = v;
				if ( v == 1 ) then -- 0 == false / 1 == true / 2 == false + desactiv√© / 3 == true + d√©sactiv√©
					SpellTrackerDB.ColumnFilter[cFilter].Count = SpellTrackerDB.ColumnFilter[cFilter].Count + 1;
					SpellTrackerDB.ColumnFilter.Count = SpellTrackerDB.ColumnFilter.Count + 1;
				end
			end
		
			SpellTracker:DoColumnFiltering(); -- apply column filtering
			
			ColumnFilterDlg:Hide();
		end
	end
end
function SpellTrackerPopupColumnFilterDlgBtn_Update(help, scrollUpdate) -- ColumnFilter dlg view update / si scrollUpdate == true pas de maj data juste scrollvalue
	local ColumnFilterDlg = SpellTrackerPopupColumnFilterDlg;
	if ( help and ColumnFilterDlg ) then
		if ( scrollUpdate == false or ColumnFilterDlg.tmpArr == nil ) then -- on regenere les donn√©es
			ColumnFilterDlg.columnArr = {}; -- tri alpha
			ColumnFilterDlg.tmpArr = SpellTracker:CopyVar(SpellTrackerDB.ColumnFilter[help]); -- copie temporaire
			for k, v in pairs(ColumnFilterDlg.tmpArr) do
				if ( k ~= "Count" ) then
					-- seulement les donn√©es active
					if ( v == 0 or v == 1 ) then -- 0 == false / 1 == true / 2 == false + desactiv√© / 3 == true + d√©sactiv√©
						tinsert(ColumnFilterDlg.columnArr, k);
					end
				end
			end
			table.sort(ColumnFilterDlg.columnArr, function(x,y) return x<y; end);
		end
		if ( ColumnFilterDlg.tmpArr ) then
			-- on efface les barres actuelles
			for k,v in pairs(ColumnFilterDlg.Buttons) do
				v.var.Label:SetText("");
				v.var.item = "";
			end
			-- affichage des barres
			local Count_Position = 1;
			local str = "";
			local BarIdx = 0;
			for k, v in ipairs(ColumnFilterDlg.columnArr) do
				if ( k and v ) then
					if ( ColumnFilterDlg.tmpArr[v] == 0 or ColumnFilterDlg.tmpArr[v] == 1 ) then -- 0 == false / 1 == true / 2 == false + desactiv√© / 3 == true + d√©sactiv√©
						if ( (Count_Position) > ColumnFilterDlg.ScrollValue and (Count_Position) <= (ColumnFilterDlg.ScrollValue + ColumnFilterDlg.nBarDisplayed) ) then -- correspond a la position de la barre dÍ¥©rÍ•†comme cela on n'affiche que les barres qui sont affichable -- gain mÍÆØire donc
							local GuiBar = ColumnFilterDlg.Buttons[BarIdx]; -- stock des bar
							BarIdx = BarIdx + 1;
							if ( GuiBar ) then
								str = v;
								if ( ColumnFilterDlg.tmpArr[v] == 0 ) then -- 0 == false / 1 == true / 2 == false + desactiv√© / 3 == true + d√©sactiv√©
									str = "[] "..str;
								elseif ( ColumnFilterDlg.tmpArr[v] == 1 ) then -- 0 == false / 1 == true / 2 == false + desactiv√© / 3 == true + d√©sactiv√©
									str = "[x] "..str;
								elseif ( ColumnFilterDlg.tmpArr[v] == 2 ) then -- 0 == false / 1 == true / 2 == false + desactiv√© / 3 == true + d√©sactiv√©
									str = "[][des] "..str;
								elseif ( ColumnFilterDlg.tmpArr[v] == 3 ) then -- 0 == false / 1 == true / 2 == false + desactiv√© / 3 == true + d√©sactiv√©
									str = "[x][des] "..str;
								end
								GuiBar.var.Label:SetText(str);
								GuiBar.var.item = v;
							end
						end
						Count_Position = Count_Position + 1;
					end
				end
			end
			ColumnFilterDlg.nBarToDisplay = Count_Position;
		end
	end
end
function SpellTrackerPopupColumnFilterDlgVirtualScrollBar_OnMouseWheel (self, delta, stepSize) -- se produit quand la molette de la sourie roule
	local ColumnFilterDlg = SpellTrackerPopupColumnFilterDlg;
	if ( ColumnFilterDlg and delta ) then
		local minVal, maxVal = 0, ColumnFilterDlg.nBarToDisplay-ColumnFilterDlg.nBarDisplayed-1; -- 0.51 (ajout du -1 pour aps avoir une barre noire ( espace ) en bout de liste
		if ( maxVal < 0 ) then maxVal = 0; end
		if ( delta == 1 ) then
			ColumnFilterDlg.ScrollValue = max(minVal, ColumnFilterDlg.ScrollValue - ColumnFilterDlg.SrollStep);
		elseif ( delta == -1 ) then
			ColumnFilterDlg.ScrollValue = min(maxVal, ColumnFilterDlg.ScrollValue + ColumnFilterDlg.SrollStep);
		end
		SpellTrackerPopupColumnFilterDlgBtn_Update(SpellTrackerDB.Params.CurrentColumnFilter, true);
	end
end	
--- Report Dlg Popup
function SpellTrackerPopupReportDlg_Create()
	local ReportDlg = CreateFrame("Frame", "SSpellTrackerPopupReportDlg", UIParent, "SpellTrackerPopupTemplate");
	if ( ReportDlg ) then
		ReportDlg:SetFrameStrata("FULLSCREEN_DIALOG");
		ReportDlg:SetToplevel(1);
		ReportDlg:Hide();
		ReportDlg:SetWidth(180);
		ReportDlg:SetPoint("TOPLEFT", SpellTrackerFrameMainMenuTitleFilterBtn, "BOTTOMLEFT", 0,0);
		ReportDlg.Buttons = {};
		ReportDlg.var = {};
		ReportDlg.var.FilterString = "";
		
		local offsetY = -2;
		local itW = ReportDlg:GetWidth();
		local itH = SpellTrackerDB.Params.SpellBarHeight;
		local lastBar;
		--[[
		for k, v in ipairs(SpellTrackerDB.Params.DataStructItems) do
			local frmName = "SSpellTrackerPopupReportDlggBar"..tostring(k);
			local bar = CreateFrame("Button", frmName, ReportDlg, "SpellTrackerPopupButtonTemplate");
			if ( bar ) then
				ReportDlg.Buttons[k] = bar;
				bar:SetScript("OnClick", SpellTrackerPopupReportDlgBtn_Click);
				bar:RegisterForClicks("AnyUp");
				bar.var = {};
				bar.var.Label = _G[frmName.."Label"];
				--bar.var.Label:SetFont(FontPath.name, FontPath.size);
				bar:SetParent(ReportDlg);
				if ( lastBar == nil ) then
					bar:SetPoint("TOPLEFT", ReportDlg, "TOPLEFT", 0, 0);
				else
					bar:SetPoint("TOPLEFT", lastBar, "BOTTOMLEFT", 0, offsetY);
				end
				bar:SetWidth(itW);
				bar:SetHeight(itH);
				lastBar = bar;
			end
		end
		]]--
		
		local ApplyBtnHeight = 20;
		local ApplyButton = CreateFrame("Button", "SpellTrackerPopupReportDlgApplyBtn", ReportDlg, "UIPanelButtonTemplate");
		if ( ApplyButton ) then
			--ApplyButton:SetFrameStrata("FULLSCREEN_DIALOG");
			--ApplyButton:SetToplevel(1);
			ApplyButton:SetWidth(180);
			ApplyButton:SetPoint("BOTTOMLEFT", ReportDlg, "BOTTOMLEFT", 0, 0);
			ApplyButton:SetText("Apply");
			ApplyButton:SetHeight(ApplyBtnHeight);
			ApplyButton:SetScript("OnClick", SpellTrackerPopupReportDlg_Apply);
		end
		
		local NewHeight = #SpellTrackerDB.Params.DataStructItems * ( itH + math.abs(offsetY) ) + ApplyBtnHeight;
		ReportDlg:SetHeight(NewHeight);		
	end
end
function SpellTrackerPopupReportDlgBtn_Click(self) -- show hide report popup
	if ( SSpellTrackerPopupReportDlg ) then
		--[[if ( SSpellTrackerPopupReportDlg:IsVisible() ) then
			SpellTrackerPopupReportDlg_Hide();
		else
			SpellTrackerPopupReportDlg_Show(self);
		end]]
	end
end
function SpellTrackerPopupReportDlg_Show(self) -- report popup dlg show
	local ReportDlg = SSpellTrackerPopupReportDlg;
	--ReportDlg.var.FilterString = SpellTrackerDB.Params.DataStructString;
	SpellTrackerPopupReportDlgBtn_Update();
	ReportDlg:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, 0);
	ReportDlg:Show();
end
function SpellTrackerPopupReportDlg_Hide() -- report popup dlg hide
	local ReportDlg = SSpellTrackerPopupReportDlg;
	ReportDlg:Hide();
end
function SpellTrackerPopupReportDlg_Apply() -- report popup dlg apply
	local function PopupReportDlg_Accept(self)
        local popup;
        if self:GetParent():GetName() == "UIParent" then popup = self;
        else popup = self:GetParent();
        end
        
		local ReportDlg = SSpellTrackerPopupReportDlg;
		--SpellTracker:ChangeDataStruct(ReportDlg.var.FilterString);			
		ReportDlg:Hide();
		
        popup:Hide(); -- on ferme la boite de dialogue
    end
	
	local function PopupReportDlg_Cancel(self)
        local popup;
        if self:GetParent():GetName() == "UIParent" then popup = self;
        else popup = self:GetParent();
        end
        
		local ReportDlg = SSpellTrackerPopupReportDlg;
		ReportDlg:Hide();
		
        popup:Hide(); -- on ferme la boite de dialogue
    end
	
	StaticPopupDialogs["CLEAR_VIEW_DLG"].OnAccept = PopupReportDlg_Accept;
	StaticPopupDialogs["CLEAR_VIEW_DLG"].OnCancel = PopupReportDlg_Cancel;
	
	StaticPopup_Show("CLEAR_VIEW_DLG");
end
function SpellTrackerPopupReportDlgBtn_Update() -- DataStruct dlg iew update
	local ReportDlg = SSpellTrackerPopupReportDlg;
end
---
function hideSpellTrackerFrameButton_OnClick(self) -- Bouton pour fermer la mainFrame
	SpellTrackerMinimapButton_OnClick(self);
end
function resetSpellTrackerButton_OnClick(self) -- Bouton pour reset les sorts traques
	local function AcceptFunc()
		SpellTracker.ResetView();
	end
	
	local function CancelFunc()
	
	end

	GetChoice(AcceptFunc,CancelFunc);
end
function GetChoice(AcceptFunc,CancelFunc) -- 0.71 -- dlg bug fix
	if ( AcceptFunc and CancelFunc ) then
	
		local function ClearViewDlg_Accept(self)
			local popup;
			if self:GetParent():GetName() == "UIParent" then popup = self;
			else popup = self:GetParent();
			end
			
			AcceptFunc();
			
			popup:Hide(); -- on ferme la boite de dialogue
		end
		
		
		local function ClearViewDlg_Cancel(self)
			local popup;
			if self:GetParent():GetName() == "UIParent" then popup = self;
			else popup = self:GetParent();
			end
			
			CancelFunc();
			
			popup:Hide(); -- on ferme la boite de dialogue
		end
		
		StaticPopupDialogs["CLEAR_VIEW_DLG"].OnAccept = ClearViewDlg_Accept;
		StaticPopupDialogs["CLEAR_VIEW_DLG"].OnCancel = ClearViewDlg_Cancel;
		
		StaticPopup_Show("CLEAR_VIEW_DLG");
	end
end
function RecordingButtonSpellTrackerButton_OnClick(self) -- 0.47 / button for recording / pause or stop control en advertissement to user
	if ( SpellTrackerDB.Recording_Mode == 0 ) then SpellTrackerDB.Recording_Mode = 1; GameTooltip:SetText(L["MODERECORDING"]);
	elseif ( SpellTrackerDB.Recording_Mode == 1 ) then SpellTrackerDB.Recording_Mode = 0; GameTooltip:SetText(L["MODEPAUSE"]);
	end
	
	SpellTracker_SetRecordingMode(SpellTrackerDB.Recording_Mode);
end
function ViewPlayingButtonSpellTrackerButton_OnClick(self)
	if ( SpellTrackerDB.ViewPlaying == 0 ) then SpellTrackerDB.ViewPlaying = 1; GameTooltip:SetText(L["VIEWPLAYING"]);
	elseif ( SpellTrackerDB.ViewPlaying == 1 ) then SpellTrackerDB.ViewPlaying = 0; GameTooltip:SetText(L["VIEWPAUSE"]);
	end
	
	SpellTracker_SetViewPlayingMode(SpellTrackerDB.ViewPlaying);
end
function ViewRefreshButtonSpellTrackerButton_OnClick(self)
	SpellTracker:RefreshView();
end
function NumLineDisplayButtonSpellTrackerButton_OnClick(self)
	-- SpellTrackerDB.NumLineDisplay = SpellTrackerDB.NumLineDisplay or 0; -- 0 Amount / 1 Ticks / 2 Best
	if ( SpellTrackerDB.NumLineDisplay == 0 ) then -- 0 Amount / 1 Ticks / 2 Best
		SpellTrackerDB.NumLineDisplay = 1;
		SpellTrackerFrameMainMenuTitleNumLineDisplayBtnLabel:SetText(L["NUMLINEDISP_SHORT_TICK"]);
		SortSpellList = SortSpellList_Tick;
		GameTooltip:SetText(L["NUMLINEDISP_LONG_TICK"]);
	elseif ( SpellTrackerDB.NumLineDisplay == 1 ) then -- 0 Amount / 1 Ticks / 2 Best
		SpellTrackerDB.NumLineDisplay = 2;
		SpellTrackerFrameMainMenuTitleNumLineDisplayBtnLabel:SetText(L["NUMLINEDISP_SHORT_BEST"]);
		SortSpellList = SortSpellList_Best;
		GameTooltip:SetText(L["NUMLINEDISP_LONG_BEST"]);
	elseif ( SpellTrackerDB.NumLineDisplay == 2 ) then -- 0 Amount / 1 Ticks / 2 Best
		SpellTrackerDB.NumLineDisplay = 0;
		SpellTrackerFrameMainMenuTitleNumLineDisplayBtnLabel:SetText(L["NUMLINEDISP_SHORT_AMOUNT"]);
		SortSpellList = SortSpellList_Amount;
		GameTooltip:SetText(L["NUMLINEDISP_LONG_AMOUNT"]);
	end
	
	SpellTracker:ReComputeFilteredSpellList();
	SpellTracker:UpdateFrame();
end
function ContextButtonSpellTrackerButton_OnClick(self)
	if ( SpellTrackerDB.Context == 0 ) then -- Context = 0 / Context Less = 1
		SpellTrackerDB.Context = 1;
		SpellTrackerFrameMainMenuTitleContextBtnLabel:SetText(L["CONTEXTLESS_MODE_SHORT"]);
		GameTooltip:SetText(L["CONTEXTLESS_MODE_LONG"]);
	elseif ( SpellTrackerDB.Context == 1 ) then -- Context = 0 / Context Less = 1
		SpellTrackerDB.Context = 0;
		SpellTrackerFrameMainMenuTitleContextBtnLabel:SetText(L["CONTEXT_MODE_SHORT"]);
		GameTooltip:SetText(L["CONTEXT_MODE_LONG"]);
	end
	
	SpellTracker:UpdateFrame();
end
function SpellTrackerButtonTemplate_OnClick(self)
	SpellTracker:UpdateFilterButton(self);
	SpellTracker:UpdateDisplayedFiterFromButtons();
end
function SpellTrackerFilterButtonTemplate_OnClick(self, button) -- comlumn critete filter to activate or deactivate here
	if ( button == "RightButton" ) then
		if ( self.help and string.match(SpellTrackerDB.Params.DisplayedFilters, self.help) ) then
			--SpellTrackerPopupColumnFilterDlg_ShowOrHide(self);
		end
	else
		SpellTracker:UpdateFilterButton(self);
		SpellTracker:RefreshView();
	end
end
function SpellTrackerButton_UpdateTitle()
	local TitleStr = "";
	
	if ( SpellTrackerDB.ViewPlaying == 0 or SpellTracker.EventPerSec_Ticks == 0 ) then TitleStr = "( "..string.format("%.2f", SpellTracker.RefreshTime).." ms) ";
	else TitleStr = "( "..string.format("%.2f", (SpellTracker.RefreshTime/1000)*SpellTracker.EventPerSec_Ticks).." s) ";
	end
	
	local vers = SpellTracker.Version;
	local pName = SpellTrackerDB.CurrentPlayerTracked.Name;
	local srcORdst = "";--Tracking_Mode
	
	if ( SpellTrackerDB.Tracking_Mode == 1 ) then srcORdst = "SRC";
	elseif ( SpellTrackerDB.Tracking_Mode == 2 ) then srcORdst = "DST";
	end
	
	if ( pName == nil ) then TitleStr = TitleStr..L["TRACK_ZONE"]..srcORdst; -- tracking zone
	else TitleStr = TitleStr..L["PLAYER_TRACKED"]..pName..L["BY"]..srcORdst;
	end
	
	SpellTrackerFrameMainMenuTitleTitleText:SetText(TitleStr);
end
function SpellTrackerButton_ShowTooltip(self, LMBtextToShow, LMDtextToShow)
	if ( LMBtextToShow and LMDtextToShow ) then
		GameTooltip:SetOwner(self);
		GameTooltip:SetText(L["LeftMouseButton"].." :"..LMBtextToShow);
		GameTooltip:AddLine(L["RightMouseButton"].." :"..LMDtextToShow);
		GameTooltip:Show();
	elseif ( LMBtextToShow and not LMDtextToShow ) then
		GameTooltip:SetOwner(self);
		GameTooltip:SetText(LMBtextToShow);
		GameTooltip:Show();
	elseif ( SpellTrackerDB.MsgToolTip ) then
		GameTooltip:SetOwner(self);
		GameTooltip:SetText(SpellTrackerDB.MsgToolTip);
		GameTooltip:Show();
	end
end
function SpellTrackerInfosButton_ShowTooltip(self)
	if( SpellTracker.Infos ) then -- 0.48
		GameTooltip:SetOwner(self);
		GameTooltip:SetText(L["INFOS_CUR_TRACK"]);
		GameTooltip:AddLine("----------");
		GameTooltip:AddLine(SpellTrackerDB.Params.FriendlyColor..L["FRIENDLY_PLAYER"]);
		GameTooltip:AddDoubleLine(SpellTrackerDB.Params.FriendlyColor..L["COUNT"].." :", SpellTrackerDB.Params.FriendlyColor..tostring(SpellTracker.Infos.CountFriendlyPlayer));
		GameTooltip:AddDoubleLine(SpellTrackerDB.Params.FriendlyColor..L["HEAL_TOTAL"], SpellTrackerDB.Params.FriendlyColor..SpellTrackerBar_FormatAmountValueToString(SpellTracker.Infos.CurrentFriendlyPlayerHealAmountTotal));
		GameTooltip:AddDoubleLine(SpellTrackerDB.Params.HostileColor..L["DAMAGE_TOTAL"], SpellTrackerDB.Params.HostileColor..SpellTrackerBar_FormatAmountValueToString(SpellTracker.Infos.CurrentFriendlyPlayerDamageAmountTotal));
		GameTooltip:AddLine("----------");
		--[[
		GameTooltip:AddDoubleLine(SpellTrackerDB.Params.HostileColor.."CountHostilePlayer", SpellTrackerDB.Params.HostileColor..tostring(SpellTracker.Infos.CountHostilePlayer));
		GameTooltip:AddDoubleLine(SpellTrackerDB.Params.HostileColor.."CurrentHostilePlayerHealAmountTotal", SpellTrackerDB.Params.HostileColor..tostring(SpellTracker.Infos.CurrentHostilePlayerHealAmountTotal));
		GameTooltip:AddDoubleLine(SpellTrackerDB.Params.HostileColor.."CurrentHostilePlayerDamageAmountTotal", SpellTrackerDB.Params.HostileColor..tostring(SpellTracker.Infos.CurrentHostilePlayerDamageAmountTotal));

		GameTooltip:AddDoubleLine(SpellTrackerDB.Params.FriendlyColor.."CountFriendlyPlayerPet", SpellTrackerDB.Params.FriendlyColor..tostring(SpellTracker.Infos.CountFriendlyPlayerPet));
		GameTooltip:AddDoubleLine(SpellTrackerDB.Params.FriendlyColor.."CurrentFriendlyPlayerPetHealAmountTotal", SpellTrackerDB.Params.FriendlyColor..tostring(SpellTracker.Infos.CurrentFriendlyPlayerPetHealAmountTotal));
		GameTooltip:AddDoubleLine(SpellTrackerDB.Params.FriendlyColor.."CurrentFriendlyPlayerPetDamageAmountTotal", SpellTrackerDB.Params.FriendlyColor..tostring(SpellTracker.Infos.CurrentFriendlyPlayerPetDamageAmountTotal));

		GameTooltip:AddDoubleLine(SpellTrackerDB.Params.HostileColor.."CountHostilePlayerPet", SpellTrackerDB.Params.HostileColor..tostring(SpellTracker.Infos.CountHostilePlayerPet));
		GameTooltip:AddDoubleLine(SpellTrackerDB.Params.HostileColor.."CurrentHostilePlayerPetHealAmountTotal", SpellTrackerDB.Params.HostileColor..tostring(SpellTracker.Infos.CurrentHostilePlayerPetHealAmountTotal));
		GameTooltip:AddDoubleLine(SpellTrackerDB.Params.HostileColor.."CurrentHostilePlayerPetDamageAmountTotal", SpellTrackerDB.Params.HostileColor..tostring(SpellTracker.Infos.CurrentHostilePlayerPetDamageAmountTotal));

		GameTooltip:AddDoubleLine(SpellTrackerDB.Params.FriendlyColor.."CountFriendlyMob", SpellTrackerDB.Params.FriendlyColor..tostring(SpellTracker.Infos.CountFriendlyMob));
		GameTooltip:AddDoubleLine(SpellTrackerDB.Params.FriendlyColor.."CurrentFriendlyMobHealAmountTotal", SpellTrackerDB.Params.FriendlyColor..tostring(SpellTracker.Infos.CurrentFriendlyMobHealAmountTotal));
		GameTooltip:AddDoubleLine(SpellTrackerDB.Params.FriendlyColor.."CurrentFriendlyMobDamageAmountTotal", SpellTrackerDB.Params.FriendlyColor..tostring(SpellTracker.Infos.CurrentFriendlyMobDamageAmountTotal));

		GameTooltip:AddDoubleLine(SpellTrackerDB.Params.HostileColor.."CountHostileMob", SpellTrackerDB.Params.HostileColor..tostring(SpellTracker.Infos.CountHostileMob));
		GameTooltip:AddDoubleLine(SpellTrackerDB.Params.HostileColor.."CurrentHostileMobHealAmountTotal", SpellTrackerDB.Params.HostileColor..tostring(SpellTracker.Infos.CurrentHostileMobHealAmountTotal));
		GameTooltip:AddDoubleLine(SpellTrackerDB.Params.HostileColor.."CurrentHostileMobDamageAmountTotal", SpellTrackerDB.Params.HostileColor..tostring(SpellTracker.Infos.CurrentHostileMobDamageAmountTotal));
		]]--
		GameTooltip:Show();
	end
end
function SpellTrackerItemFilterButton_ShowTooltip(self)
end
function SpellTrackerTitleFrameButton_ShowTooltip(self)

end
function SpellTrackerButton_HideTooltip(self)
	GameTooltip:Hide();
end
function SpellTrackerBar_OnEnter(self) -- affiche des infos sup sur les sort traques
	if ( self.VAR.Used ) then 
		SpellTracker:CalcEventsPerSec(true); -- on refesh ev/s
		GameTooltip:SetOwner(self);
		local SpellStruct = nil;
		local SpellStructParent = nil;
		if ( self.VAR.IndexerOfParent and self.VAR.SpellIndexer) then -- un child
			SpellStruct = SpellTracker:GetFilteredSpellsStructByParsingOfIndexer(self.VAR.IndexerOfParent..SpellTrackerDB.Separator..self.VAR.SpellIndexer);
			--print(self.VAR.IndexerOfParent);
			SpellStructParent = SpellTracker:GetFilteredSpellsStructByParsingOfIndexer(self.VAR.IndexerOfParent);
			--print(SpellStructParent.Indexer);
		else
			if ( self.VAR.SpellIndexer ) then
				SpellStruct = SpellTrackerDB.FILTEREDSPELLS[self.VAR.SpellIndexer];
			end
		end
		
		if ( SpellStruct ) then
			if ( SpellStructParent ) then
				local HitTypeColor;
				if ( SpellStruct.HitType == "HEAL" or SpellStructParent.HitType == "HEAL" ) then
					HitTypeColor = SpellTrackerDB.Params.FriendlyColor;
				elseif ( SpellStruct.HitType == "DAMAGE" or SpellStructParent.HitType == "DAMAGE" ) then
					HitTypeColor = SpellTrackerDB.Params.HostileColor;
				else
					HitTypeColor = SpellTrackerDB.Params.DefaultColor;
				end
				
				local title = "";
				if ( SpellStruct.SpellName ) then title = HitTypeColor..SpellStruct.SpellName;
				elseif ( SpellStructParent.SpellName ) then title = HitTypeColor..SpellStructParent.SpellName;
				else title = " "..L["DETAIL"].." :"; end
				GameTooltip:SetText(title);
					
				--SetItemRef(link, text, button, self);
				
				local nBarRatio  = tostring(self.VAR.ChildListToSort_Position).."/"..tostring(SpellStructParent.Nodes.count);
				GameTooltip:AddLine("Bar "..nBarRatio);
				
				-- colorise en vert ou en rouge selon que la source soie hostile ou friendly
				local SrcColor = SpellTrackerDB.Params.FriendlyColor;
				local DstColor = SpellTrackerDB.Params.FriendlyColor;
				if ( SpellStruct.SourceReaction == "REACTION_HOSTILE" or SpellStructParent.SourceReaction == "REACTION_HOSTILE" ) then SrcColor = SpellTrackerDB.Params.HostileColor; end
				if ( SpellStruct.TargetReaction == "REACTION_HOSTILE" or SpellStructParent.TargetReaction == "REACTION_HOSTILE" ) then DstColor = SpellTrackerDB.Params.HostileColor; end
					
				if ( SpellStruct.SourceType and SpellStruct.SourceName ) then
					GameTooltip:AddDoubleLine(L["SRC_TYPE_NAME"],SrcColor..SpellStruct.SourceType.." / "..SpellStruct.SourceName);
				elseif ( SpellStruct.SourceType ) then
					GameTooltip:AddDoubleLine(L["SRC_TYPE"],SrcColor..SpellStruct.SourceType);
				elseif ( SpellStruct.SourceName ) then
					GameTooltip:AddDoubleLine(L["SRC_NAME"],SrcColor..SpellStruct.SourceName);
				end
				
				if ( SpellStruct.TargetType and SpellStruct.TargetName ) then
					GameTooltip:AddDoubleLine(L["TGT_TYPE_NAME"],SrcColor..SpellStruct.TargetType.." / "..SpellStruct.TargetName);
				elseif ( SpellStruct.TargetType ) then
					GameTooltip:AddDoubleLine(L["TGT_TYPE"],SrcColor..SpellStruct.TargetType);
				elseif ( SpellStruct.TargetName ) then
					GameTooltip:AddDoubleLine(L["TGT_NAME"],SrcColor..SpellStruct.TargetName);
				end
				
				local StatBarColor = SpellTracker.StatusBarColors;
				
				local HitTypeStr = "";
				if ( SpellStruct.HitType ) then
					HitTypeStr = SpellStruct.HitType;
				end
					
				-- Recup des donnÈes / 0.40
				local LocalStruct = {};
				if ( SpellStruct.AmountLine ) then
					--print(string.match(SpellStruct.AmountLine, "(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)"));
					LocalStruct.SpellTotalAmount,
						LocalStruct.SpellHitAmount, LocalStruct.SpellCritAmount, 
						LocalStruct.SpellCritAndOverAmount, LocalStruct.SpellOverAmount, 
						LocalStruct.SpellOverAndAbsorbAmount, LocalStruct.SpellCritAndAbsorbAmount, LocalStruct.SpellAbsorbAmount
						= string.match(SpellStruct.AmountLine, "(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)");
						-- self.HitType vaut "Heal" ou "Damage" / modif 0.40
									
					GameTooltip:AddLine("----- "..L["AMOUNT"].." "..L[HitTypeStr].." : -----");
					GameTooltip:AddDoubleLine(L["TOTAL_PRODUCED"],SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellTotalAmount));
					GameTooltip:AddDoubleLine(StatBarColor.SpellHitAmount..L[HitTypeStr]..L["HIT_AMOUNT"],StatBarColor.SpellHitAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellHitAmount).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.SpellHitAmount, 1, LocalStruct.SpellTotalAmount));
					GameTooltip:AddDoubleLine(StatBarColor.SpellCritAmount..L[HitTypeStr]..L["CRIT_AMOUNT"],StatBarColor.SpellCritAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellCritAmount).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.SpellCritAmount, 1, LocalStruct.SpellTotalAmount));
					GameTooltip:AddDoubleLine(StatBarColor.SpellCritAndOverAmount..L[HitTypeStr]..L["OVER_CRIT_AMOUNT"],StatBarColor.SpellCritAndOverAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellCritAndOverAmount).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.SpellCritAndOverAmount, 1, LocalStruct.SpellTotalAmount));
					GameTooltip:AddDoubleLine(StatBarColor.SpellOverAmount..L[HitTypeStr]..L["OVER_AMOUNT"],StatBarColor.SpellOverAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellOverAmount).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.SpellOverAmount, 1, LocalStruct.SpellTotalAmount));
					GameTooltip:AddDoubleLine(StatBarColor.SpellOverAndAbsorbAmount..L[HitTypeStr]..L["OVER_ABSRORB_AMOUNT"],StatBarColor.SpellOverAndAbsorbAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellOverAndAbsorbAmount).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.SpellOverAndAbsorbAmount, 1, LocalStruct.SpellTotalAmount));
					GameTooltip:AddDoubleLine(StatBarColor.SpellCritAndAbsorbAmount..L[HitTypeStr]..L["CRIT_ABSORB_AMOUNT"],StatBarColor.SpellCritAndAbsorbAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellCritAndAbsorbAmount).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.SpellCritAndAbsorbAmount, 1, LocalStruct.SpellTotalAmount));
					GameTooltip:AddDoubleLine(StatBarColor.SpellAbsorbAmount..L[HitTypeStr]..L["ABSORB_AMOUNT"],StatBarColor.SpellAbsorbAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellAbsorbAmount).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.SpellAbsorbAmount, 1, LocalStruct.SpellTotalAmount));
				end
				
				local NNumAfterComa = 1;
				local NNumAfterComaStr = "%."..tostring(NNumAfterComa).."f";
				-- nombre de chiffres apres la virgule -- string.format(NNumAfterComaStr, num);
				-- Recup des Ticks / 0.40
				if ( SpellStruct.TickLine ) then
					LocalStruct.CountTicks,
						LocalStruct.CountSpellHit, LocalStruct.CountSpellCrit, 
						LocalStruct.CountSpellCritAndOver, LocalStruct.CountSpellOver, 
						LocalStruct.CountSpellOverAndAbsorb, LocalStruct.CountSpellCritAndAbsorb, LocalStruct.CountSpellAbsorb
						= string.match(SpellStruct.TickLine, "(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)");
		
					GameTooltip:AddLine("----- "..L[HitTypeStr].." Ticks : -----");
					GameTooltip:AddDoubleLine(L["COUNT"].." Ticks ", LocalStruct.CountTicks);
					GameTooltip:AddDoubleLine(StatBarColor.SpellHitAmount..L["COUNT_HIT"], StatBarColor.SpellHitAmount..(LocalStruct.CountSpellHit).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.CountSpellHit, 1, LocalStruct.CountTicks));
					GameTooltip:AddDoubleLine(StatBarColor.SpellCritAmount..L["COUNT_CRIT"], StatBarColor.SpellCritAmount..(LocalStruct.CountSpellCrit).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.CountSpellCrit, 1, LocalStruct.CountTicks));
					GameTooltip:AddDoubleLine(StatBarColor.SpellCritAndOverAmount..L["COUNT_CRIT_OVER"], StatBarColor.SpellCritAndOverAmount..(LocalStruct.CountSpellCritAndOver).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.CountSpellCritAndOver, 1, LocalStruct.CountTicks));
					GameTooltip:AddDoubleLine(StatBarColor.SpellOverAmount..L["COUNT_OVER"], StatBarColor.SpellOverAmount..(LocalStruct.CountSpellOver).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.CountSpellOver, 1, LocalStruct.CountTicks));
					GameTooltip:AddDoubleLine(StatBarColor.SpellOverAndAbsorbAmount..L["COUNT_OVER_ABSORB"], StatBarColor.SpellOverAndAbsorbAmount..(LocalStruct.CountSpellOverAndAbsorb).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.CountSpellOverAndAbsorb, 1, LocalStruct.CountTicks));
					GameTooltip:AddDoubleLine(StatBarColor.SpellCritAndAbsorbAmount..L["COUNT_CRIT_ABSORB"], StatBarColor.SpellCritAndAbsorbAmount..(LocalStruct.CountSpellCritAndAbsorb).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.CountSpellCritAndAbsorb, 1, LocalStruct.CountTicks));
					GameTooltip:AddDoubleLine(StatBarColor.SpellAbsorbAmount..L["COUNT_ABSORB"], StatBarColor.SpellAbsorbAmount..(LocalStruct.CountSpellAbsorb).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.CountSpellAbsorb, 1, LocalStruct.CountTicks));
				end
				
				-- Recup des Best / 0.53
				if ( SpellStruct.BestLine ) then
					LocalStruct.SpellTotalBest,
						LocalStruct.SpellHitBest, LocalStruct.SpellCritBest, 
						LocalStruct.SpellCritAndOverBest, LocalStruct.SpellOverBest, 
						LocalStruct.SpellOverAndAbsorbBest, LocalStruct.SpellCritAndAbsorbBest, LocalStruct.SpellAbsorbBest
						= string.match(SpellStruct.BestLine, "(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)");
									
					GameTooltip:AddLine("----- "..L["BEST"].." "..L[HitTypeStr].." : -----");
					GameTooltip:AddDoubleLine(L["SUM_BEST"],SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellTotalBest));
					GameTooltip:AddDoubleLine(StatBarColor.SpellHitAmount..L[HitTypeStr]..L["HIT_BEST"],StatBarColor.SpellHitAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellHitBest));
					GameTooltip:AddDoubleLine(StatBarColor.SpellCritAmount..L[HitTypeStr]..L["CRIT_BEST"],StatBarColor.SpellCritAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellCritBest));
					GameTooltip:AddDoubleLine(StatBarColor.SpellCritAndOverAmount..L[HitTypeStr]..L["OVER_CRIT_BEST"],StatBarColor.SpellCritAndOverAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellCritAndOverBest));
					GameTooltip:AddDoubleLine(StatBarColor.SpellOverAmount..L[HitTypeStr]..L["OVER_BEST"],StatBarColor.SpellOverAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellOverBest));
					GameTooltip:AddDoubleLine(StatBarColor.SpellOverAndAbsorbAmount..L[HitTypeStr]..L["OVER_ABSORB_BEST"],StatBarColor.SpellOverAndAbsorbAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellOverAndAbsorbBest));
					GameTooltip:AddDoubleLine(StatBarColor.SpellCritAndAbsorbAmount..L[HitTypeStr]..L["CRIT_ABSORB_BEST"],StatBarColor.SpellCritAndAbsorbAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellCritAndAbsorbBest));
					GameTooltip:AddDoubleLine(StatBarColor.SpellAbsorbAmount..L[HitTypeStr]..L["ABSORB_BEST"],StatBarColor.SpellAbsorbAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellAbsorbBest));
				end
				
				GameTooltip:Show();
			else
				local HitTypeColor = SpellTrackerDB.Params.HostileColor;
				if ( SpellStruct.HitType ) then
					if ( SpellStruct.HitType == "HEAL" ) then HitTypeColor = SpellTrackerDB.Params.FriendlyColor; end
				else
					HitTypeColor = SpellTrackerDB.Params.DefaultColor;
				end
				
				local title = "";
				if ( SpellStruct.SpellName ) then
					title = HitTypeColor..SpellStruct.SpellName;
				else
					title = " "..L["DETAIL"].." :";
				end
				GameTooltip:SetText(title);
					
				local nBarRatio  = "";
				if ( self.VAR.IndexerOfParent and SpellStructParent ) then -- un child
					--nBarRatio = tostring(self.VAR.ChildListToSort_Position).."/"..tostring(SpellTrackerDB.FILTEREDSPELLS[self.VAR.IndexerOfParent].Nodes.count);
					--nBarRatio = tostring(self.VAR.ChildListToSort_Position).."/"..tostring(SpellStructParent.Nodes.count);
				else
					nBarRatio = tostring(self.VAR.SpellListToSort_Position).."/"..tostring(#SpellTracker.SpellListToSort);
				end
				GameTooltip:AddLine(L["BAR"].." "..nBarRatio);
				
				-- colorise en vert ou en rouge selon que la source soie hostile ou friendly
				local SrcColor = SpellTrackerDB.Params.FriendlyColor;
				local DstColor = SpellTrackerDB.Params.FriendlyColor;
				if ( SpellStruct.SourceReaction == "REACTION_HOSTILE" ) then SrcColor = SpellTrackerDB.Params.HostileColor; end
				if ( SpellStruct.TargetReaction == "REACTION_HOSTILE" ) then DstColor = SpellTrackerDB.Params.HostileColor; end
					
				if ( SpellStruct.SourceType and SpellStruct.SourceName ) then
					GameTooltip:AddDoubleLine(L["SRC_TYPE_NAME"],SrcColor..SpellStruct.SourceType.." / "..SpellStruct.SourceName);
				elseif ( SpellStruct.SourceType ) then
					GameTooltip:AddDoubleLine(L["SRC_TYPE"],SrcColor..SpellStruct.SourceType);
				elseif ( SpellStruct.SourceName ) then
					GameTooltip:AddDoubleLine(L["SRC_NAME"],SrcColor..SpellStruct.SourceName);
				end
				
				if ( SpellStruct.TargetType and SpellStruct.TargetName ) then
					GameTooltip:AddDoubleLine(L["TGT_TYPE_NAME"],SrcColor..SpellStruct.TargetType.." / "..SpellStruct.TargetName);
				elseif ( SpellStruct.TargetType ) then
					GameTooltip:AddDoubleLine(L["TGT_TYPE"],SrcColor..SpellStruct.TargetType);
				elseif ( SpellStruct.TargetName ) then
					GameTooltip:AddDoubleLine(L["TGT_NAME"],SrcColor..SpellStruct.TargetName);
				end
				
				local StatBarColor = SpellTracker.StatusBarColors;
				
				local HitTypeStr = "";
				if ( SpellStruct.HitType ) then
					HitTypeStr = SpellStruct.HitType;
				end
					
				-- Recup des donnÍ¶≥ / 0.40
				local LocalStruct = {};
				if ( SpellStruct.AmountLine ) then
					--print(string.match(SpellStruct.AmountLine, "(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)"));
					LocalStruct.SpellTotalAmount,
						LocalStruct.SpellHitAmount, LocalStruct.SpellCritAmount, 
						LocalStruct.SpellCritAndOverAmount, LocalStruct.SpellOverAmount, 
						LocalStruct.SpellOverAndAbsorbAmount, LocalStruct.SpellCritAndAbsorbAmount, LocalStruct.SpellAbsorbAmount
						= string.match(SpellStruct.AmountLine, "(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)");
						-- self.HitType vaut "Heal" ou "Damage" / modif 0.40
					--print(LocalStruct.SpellTotalAmount);
					GameTooltip:AddLine("----- "..L["AMOUNT"].." "..L[HitTypeStr].." : -----");
					GameTooltip:AddDoubleLine(L["TOTAL_PRODUCED"],SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellTotalAmount));
					GameTooltip:AddDoubleLine(StatBarColor.SpellHitAmount..L[HitTypeStr]..L["HIT_AMOUNT"],StatBarColor.SpellHitAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellHitAmount).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.SpellHitAmount, 1, LocalStruct.SpellTotalAmount));
					GameTooltip:AddDoubleLine(StatBarColor.SpellCritAmount..L[HitTypeStr]..L["CRIT_AMOUNT"],StatBarColor.SpellCritAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellCritAmount).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.SpellCritAmount, 1, LocalStruct.SpellTotalAmount));
					GameTooltip:AddDoubleLine(StatBarColor.SpellCritAndOverAmount..L[HitTypeStr]..L["OVER_CRIT_AMOUNT"],StatBarColor.SpellCritAndOverAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellCritAndOverAmount).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.SpellCritAndOverAmount, 1, LocalStruct.SpellTotalAmount));
					GameTooltip:AddDoubleLine(StatBarColor.SpellOverAmount..L[HitTypeStr]..L["OVER_AMOUNT"],StatBarColor.SpellOverAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellOverAmount).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.SpellOverAmount, 1, LocalStruct.SpellTotalAmount));
					GameTooltip:AddDoubleLine(StatBarColor.SpellOverAndAbsorbAmount..L[HitTypeStr]..L["OVER_ABSRORB_AMOUNT"],StatBarColor.SpellOverAndAbsorbAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellOverAndAbsorbAmount).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.SpellOverAndAbsorbAmount, 1, LocalStruct.SpellTotalAmount));
					GameTooltip:AddDoubleLine(StatBarColor.SpellCritAndAbsorbAmount..L[HitTypeStr]..L["CRIT_ABSORB_AMOUNT"],StatBarColor.SpellCritAndAbsorbAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellCritAndAbsorbAmount).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.SpellCritAndAbsorbAmount, 1, LocalStruct.SpellTotalAmount));
					GameTooltip:AddDoubleLine(StatBarColor.SpellAbsorbAmount..L[HitTypeStr]..L["ABSORB_AMOUNT"],StatBarColor.SpellAbsorbAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellAbsorbAmount).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.SpellAbsorbAmount, 1, LocalStruct.SpellTotalAmount));
				end
				
				local NNumAfterComa = 1;
				local NNumAfterComaStr = "%."..tostring(NNumAfterComa).."f";
				-- nombre de chiffres apres la virgule -- string.format(NNumAfterComaStr, num);
				-- Recup des Ticks / 0.40
				if ( SpellStruct.TickLine ) then
					LocalStruct.CountTicks,
						LocalStruct.CountSpellHit, LocalStruct.CountSpellCrit, 
						LocalStruct.CountSpellCritAndOver, LocalStruct.CountSpellOver, 
						LocalStruct.CountSpellOverAndAbsorb, LocalStruct.CountSpellCritAndAbsorb, LocalStruct.CountSpellAbsorb
						= string.match(SpellStruct.TickLine, "(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)");
		
					GameTooltip:AddLine("----- "..L[HitTypeStr].." Ticks : -----");
					GameTooltip:AddDoubleLine(L["COUNT"].." Ticks ", LocalStruct.CountTicks);
					GameTooltip:AddDoubleLine(StatBarColor.SpellHitAmount..L["COUNT_HIT"], StatBarColor.SpellHitAmount..(LocalStruct.CountSpellHit).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.CountSpellHit, 1, LocalStruct.CountTicks));
					GameTooltip:AddDoubleLine(StatBarColor.SpellCritAmount..L["COUNT_CRIT"], StatBarColor.SpellCritAmount..(LocalStruct.CountSpellCrit).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.CountSpellCrit, 1, LocalStruct.CountTicks));
					GameTooltip:AddDoubleLine(StatBarColor.SpellCritAndOverAmount..L["COUNT_CRIT_OVER"], StatBarColor.SpellCritAndOverAmount..(LocalStruct.CountSpellCritAndOver).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.CountSpellCritAndOver, 1, LocalStruct.CountTicks));
					GameTooltip:AddDoubleLine(StatBarColor.SpellOverAmount..L["COUNT_OVER"], StatBarColor.SpellOverAmount..(LocalStruct.CountSpellOver).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.CountSpellOver, 1, LocalStruct.CountTicks));
					GameTooltip:AddDoubleLine(StatBarColor.SpellOverAndAbsorbAmount..L["COUNT_OVER_ABSORB"], StatBarColor.SpellOverAndAbsorbAmount..(LocalStruct.CountSpellOverAndAbsorb).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.CountSpellOverAndAbsorb, 1, LocalStruct.CountTicks));
					GameTooltip:AddDoubleLine(StatBarColor.SpellCritAndAbsorbAmount..L["COUNT_CRIT_ABSORB"], StatBarColor.SpellCritAndAbsorbAmount..(LocalStruct.CountSpellCritAndAbsorb).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.CountSpellCritAndAbsorb, 1, LocalStruct.CountTicks));
					GameTooltip:AddDoubleLine(StatBarColor.SpellAbsorbAmount..L["COUNT_ABSORB"], StatBarColor.SpellAbsorbAmount..(LocalStruct.CountSpellAbsorb).." - "..SpellTrackerBar_FormatAmountToPercentValueToString(LocalStruct.CountSpellAbsorb, 1, LocalStruct.CountTicks));
				end
				
				-- Recup des Best / 0.53
				if ( SpellStruct.BestLine ) then
					LocalStruct.SpellTotalBest,
						LocalStruct.SpellHitBest, LocalStruct.SpellCritBest, 
						LocalStruct.SpellCritAndOverBest, LocalStruct.SpellOverBest, 
						LocalStruct.SpellOverAndAbsorbBest, LocalStruct.SpellCritAndAbsorbBest, LocalStruct.SpellAbsorbBest
						= string.match(SpellStruct.BestLine, "(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)");
									
					GameTooltip:AddLine("----- "..L["BEST"].." "..L[HitTypeStr].." : -----");
					GameTooltip:AddDoubleLine(L["SUM_BEST"],SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellTotalBest));
					GameTooltip:AddDoubleLine(StatBarColor.SpellHitAmount..L[HitTypeStr]..L["HIT_BEST"],StatBarColor.SpellHitAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellHitBest));
					GameTooltip:AddDoubleLine(StatBarColor.SpellCritAmount..L[HitTypeStr]..L["CRIT_BEST"],StatBarColor.SpellCritAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellCritBest));
					GameTooltip:AddDoubleLine(StatBarColor.SpellCritAndOverAmount..L[HitTypeStr]..L["OVER_CRIT_BEST"],StatBarColor.SpellCritAndOverAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellCritAndOverBest));
					GameTooltip:AddDoubleLine(StatBarColor.SpellOverAmount..L[HitTypeStr]..L["OVER_BEST"],StatBarColor.SpellOverAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellOverBest));
					GameTooltip:AddDoubleLine(StatBarColor.SpellOverAndAbsorbAmount..L[HitTypeStr]..L["OVER_ABSORB_BEST"],StatBarColor.SpellOverAndAbsorbAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellOverAndAbsorbBest));
					GameTooltip:AddDoubleLine(StatBarColor.SpellCritAndAbsorbAmount..L[HitTypeStr]..L["CRIT_ABSORB_BEST"],StatBarColor.SpellCritAndAbsorbAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellCritAndAbsorbBest));
					GameTooltip:AddDoubleLine(StatBarColor.SpellAbsorbAmount..L[HitTypeStr]..L["ABSORB_BEST"],StatBarColor.SpellAbsorbAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellAbsorbBest));
				end
				
				GameTooltip:Show();
			end
		end
	end
end
function SpellTrackerBar_FormatAmountValueToString(val)
	local ret = "";
	if (string.len(tostring(val)) > 10 ) then
		ret = string.format("%.0f", val/1000000000).."M";
    elseif (string.len(tostring(val)) > 7 ) then
		ret = string.format("%.0f", val/1000000).."m";
	elseif (string.len(tostring(val)) > 4 ) then
		ret = string.format("%.0f", val/1000).."K";
	else
		ret = string.format("%.0f", val);
	end
	return ret;
end
function SpellTrackerBar_FormatAmountToPercentValueToString(val, precision, total)
	local percentVal = (val*100)/total;
	return string.format("(%."..tostring(0).."f", percentVal).."%)";	
end
function SpellTrackerBar_GetColorCodeFromStatusBarColor(StatusBar)
	local codeWow = nil;
	if ( StatusBar ) then
		local r,g,b,a = StatusBar:GetStatusBarColor();
		if ( r and g and b ) then
			codeWow = SpellTrackerBar_GetColorCodeFromRGB(r, g, b);
		end
	end
	return codeWow; 
end
function SpellTrackerBar_SetTextureColorFromColorTab(TextureToColorise, ColorTab)
	if ( TextureToColorise and ColorTab ) then
		TextureToColorise:SetVertexColor(ColorTab.r,ColorTab.g,ColorTab.b, 1.0);
	end
end
function SpellTrackerBar_GetColorCodeFromRGB(red, green, blue) -- de 0 √† 1 en float
	local codeWow = nil;
	if ( red and green and blue ) then
		local redColor = string.format("%0.2X", math.ceil(string.format("%.2f", red)*255));
		local greenColor = string.format("%0.2X", math.ceil(string.format("%.2f", green)*255));
		local blueColor = string.format("%0.2X", math.ceil(string.format("%.2f", blue)*255));
		codeWow = "|cFF"..tostring(redColor)..tostring(greenColor)..tostring(blueColor);
	end
	return codeWow; 
end
function SpellTrackerBar_GetColorCodeFromRGBStruct(rgbStruct) -- de 0 √† 1 en float
	local codeWow = SpellTrackerBar_GetColorCodeFromRGB(rgbStruct.r, rgbStruct.g, rgbStruct.b);
	return codeWow; 
end
function SpellTrackerBar_OnLeave(self)
	GameTooltip:Hide();
end
function SpellTrackerBar_OnClick(self, button) -- 0.47 -- mode arborescent -- 0.48 expand / collapse -- 0.50 mode arbo OK -- 0.52 -- 0.53 bug fix -- 0.55 Key Input
	if ( self.VAR.Used ) then 
		SpellTracker:CalcEventsPerSec(true); -- on refesh ev/s
		local NodeMode = 0;
		if ( button == "LeftButton" ) then NodeMode = 1;
		elseif ( button == "RightButton" ) then NodeMode = 2;
		elseif ( button == "MiddleButton" ) then NodeMode = 0;
		end
		
		local SpellStruct = nil;
		if ( self.VAR.IndexerOfParent ) then -- un child
			SpellStruct = SpellTracker:GetFilteredSpellsStructByParsingOfIndexer(self.VAR.IndexerOfParent..SpellTrackerDB.Separator..self.VAR.SpellIndexer);
			--print(self.VAR.IndexerOfParent..SpellTrackerDB.Separator..self.VAR.SpellIndexer);
		else
			if ( self.VAR.SpellIndexer ) then
				SpellStruct = SpellTrackerDB.FILTEREDSPELLS[self.VAR.SpellIndexer];
				--print(self.VAR.SpellIndexer);
			end
		end
		
		if ( SpellStruct ) then
			if ( SpellStruct.Nodes == nil ) then
				--print("Mouse Btn = "..button);
				--print("Key Input = "..SpellTracker.KeyDown);
				if ( button == "LeftButton" ) then -- Left Btn => Type 1
					SpellTracker:ExpandForNodeType1(SpellStruct);
				elseif ( button == "RightButton" ) then -- Right Btn => Type 2
					SpellTracker:ExpandForNodeType2(SpellStruct);
				elseif ( button == "MiddleButton" ) then
					SpellTracker:ExpandAll(SpellStruct);
				
				end
			elseif ( SpellStruct.Nodes ) then
				if ( button == "LeftButton" ) then
					SpellTracker:Collapse(SpellStruct);
				elseif ( button == "RightButton" ) then
					SpellTracker:Collapse(SpellStruct);
				elseif ( button == "MiddleButton" ) then
					SpellTracker:CollapseAll(SpellStruct);
				end
			end
		end
	end
end
function SpellTrackerBarSpellIconBtn_OnClick(self, button) -- 0.56 spell tooltip
	if ( button == "LeftButton" ) then
		if ( self.SpellId ) then 
			SetItemRef(SpellTracker:GetSpellHyperlink(self.SpellId)); -- show tooltip on spell link
		end
	elseif ( button == "RgihtButton" ) then
		if ( self.TickSpellId ) then
			SetItemRef(SpellTracker:GetSpellHyperlink(self.TickSpellId)); -- show tooltip on spell link
		end
	end	
end
function SpellTrackerBarSpellIconBtn_OnEnter(self) -- 0.56 spell tooltip
	if ( self.SpellId ) then 
		GameTooltip:SetOwner(self);
		GameTooltip:SetText(L["SPELL"].." : "..self.SpellName.. "("..self.SpellId..")");
		GameTooltip:AddLine(L["TOOLTIP_MSG1"]);
		if ( self.TickSpellId ) then
			GameTooltip:AddLine(L["TOOLTIP_MSG2"]);
		end
		GameTooltip:Show();
	end
end
function SpellTrackerBarSpellIconBtn_OnLeave(self) -- 0.56 spell tooltip
	GameTooltip:Hide();
end
function SpellTrackerMinimapButton_UpdateTitle(EventPerSec)
	if ( EventPerSec == nil or EventPerSec == 0 ) then
		SpellTrackerMinimapButton.label:SetText("SPT "..SpellTracker.Version);
	else
		SpellTrackerMinimapButton.label:SetText("SPT "..tostring(EventPerSec).."ev/s");
	end
end
function SpellTrackerMinimapButton_OnEnter(self)
	GameTooltip:SetOwner(self);
	GameTooltip:SetText("SpellTracker "..SpellTracker.Version);
	--GameTooltip:AddDoubleLine(SpellTrackerDB.Params.FriendlyColor.."Heal :",SpellTrackerDB.Params.FriendlyColor..tostring(SpellTrackerDB.currentSessionHealTotal));
	--GameTooltip:AddDoubleLine(SpellTrackerDB.Params.HostileColor.."Damage :",SpellTrackerDB.Params.HostileColor..tostring(SpellTrackerDB.currentSessionDamageTotal));
	GameTooltip:Show();
end
function SpellTrackerMinimapButton_OnLeave(self)
	GameTooltip:Hide();
end
function SpellTrackerMinimapButton_OnClick(self)
	if (SpellTrackerFrame) then
        if(SpellTrackerFrame:IsVisible() ) then
			CloseDropDownMenus();
            SpellTracker.MinimapBtnDown = False;
			SpellTrackerMinimapButton:UnlockHighlight();
			SpellTrackerDataStructConfigDlg:Hide();
			SpellTrackerFrame:Hide();
		else
			CloseDropDownMenus();
            SpellTrackerFrame:Show();
			SpellTracker.MinimapBtnDown = true;
			SpellTrackerMinimapButton:LockHighlight();
			SpellTracker:ReComputeFilteredSpellList();
			SpellTracker:UpdateFrame();
		end
    end
end
function SpellTrackerResizeFrame_OnEnter(self) -- widget de redimentionnement -- survol IN
	if ( SpellTracker:IsInCombat() == false ) then
		SpellTrackerFrameResizeFrameTexture:SetDesaturated(false);
		SpellTrackerFrameResizeFrameTexture:SetAlpha(1);
	end
end
function SpellTrackerResizeFrame_OnLeave(self) -- widget de redimentionnement -- survol OUT
	if ( SpellTracker:IsInCombat() == false ) then
		SpellTrackerFrameResizeFrameTexture:SetDesaturated(true);
		SpellTrackerFrameResizeFrameTexture:SetAlpha(0);
	end
end
function SpellTrackerResizeFrame_OnMouseDown(self) -- widget et de redimentionnement -- CLICK DOWN -- 0.53 (function ext)
	SpellTracker:StartFrameResize();
end
function SpellTrackerResizeFrame_OnMouseUp(self) -- widget de redimentionnement -- CLICK UP -- 0.53 (function ext)
	SpellTracker:EndFrameResize();
end
function SpellTrackerFrameContainerVirtualScrollBar_OnMouseWheel (self, delta, stepSize) -- se produit quand la molette de la sourie roule
	-- SpellTracker.ScrollValue => correspond au numÈro de la barre affichÈ en haut
	-- SpellTracker.CountBarToDisplay => correspond au nombre de barres ‡ afficher 
	-- SpellTracker.CountBarDisplayed => correspond au nombres de bars qui puevent etre affcihÈs en meme temps.
	if ( delta ) then
		local minVal, maxVal = 0, SpellTracker.CountBarToDisplay-SpellTracker.CountBarDisplayed-1; -- 0.51 (ajout du -1 pour aps avoir une barre noire ( espace ) en bout de liste
		if ( maxVal < 0 ) then maxVal = 0; end
		--print("SpellTracker.CountBarDisplayed=",SpellTracker.CountBarDisplayed);
		--print("SpellTracker.CountBarToDisplay=",SpellTracker.CountBarToDisplay);
		if ( delta == 1 ) then
			SpellTracker.ScrollValue = max(minVal, SpellTracker.ScrollValue - SpellTrackerDB.Params.SrollStep);
		elseif ( delta == -1 ) then
			SpellTracker.ScrollValue = min(maxVal, SpellTracker.ScrollValue + SpellTrackerDB.Params.SrollStep);
		end
		
		SpellTracker:UpdateFrame();
	end
end	
function SpellTrackerFrame_OnEvent(self, event, ...)
	if ( event == "VARIABLES_LOADED" ) then
		SpellTrackerFrame_Init(self);
		self:UnregisterEvent("VARIABLES_LOADED");
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		if ( SpellTracker:IsInCombat() == false ) then
			SpellTracker:InitFrame();
			DEFAULT_CHAT_FRAME:AddMessage("SpellTracker "..SpellTracker.Version.." "..L["LOADED"]);
			SpellTracker:UpdateFrame();
			SpellTracker:CreateOrUpdateRaidMembersList(); -- on refresh la list des membre du raid
			SpellTracker:CreateOrUpdateGroupMembersList(); -- on refresh la lst des membres du groupe
			self:UnregisterEvent("PLAYER_ENTERING_WORLD");
		else
			DEFAULT_CHAT_FRAME:AddMessage("SpellTracker "..SpellTracker.Version.." "..L["NOT"].." "..L["LOADED"]);
			DEFAULT_CHAT_FRAME:AddMessage(L["ERROR_RELOAD_MSG1"]);
		end
	elseif ( event == "COMBAT_LOG_EVENT_UNFILTERED" ) then
		if ( SpellTrackerDB.Recording_Mode == 1 ) then -- 0.47
			SpellTracker:COMBAT_LOG_EVENT_UNFILTERED(self, ...);
		end
	elseif ( event == "RAID_ROSTER_UPDATE" ) then
		SpellTracker:CreateOrUpdateRaidMembersList();
	elseif ( event == "PARTY_MEMBERS_CHANGED" ) then
		SpellTracker:CreateOrUpdateGroupMembersList();	
	elseif ( event == "PLAYER_REGEN_DISABLED" ) then -- FIGHT STARTING -- 0.47
		--print(event);
		SpellTracker:StartFight();
	elseif ( event == "PLAYER_REGEN_ENABLED" ) then -- END FIGHT -- 0.47
		--print(event);
		SpellTracker:EndFight();
	end
	SpellTracker:CalcEventsPerSec(true); -- refresh ev/s
end
function SpellTracker_FilterDropDownMenu_Init() -- FILTER - ChangeDataStruct - MENU -- 0.54 ok - not used line 506
	-- INIT TARGET
	UIDropDownMenu_Initialize(SpellTracker_FilterDropDownMenu, SpellTracker_FilterDropDownMenu_OnLoad, "MENU");
	SpellTrackerFrameMainMenuTitleFilterBtn:SetScript("OnClick", 
		function()	
			ToggleDropDownMenu(1, nil, SpellTracker_FilterDropDownMenu, SpellTrackerFrameMainMenuTitleFilterBtn, 0, 0);
		end
	);
end
function SpellTracker_FilterDropDownMenu_OnLoad(self, lvl) -- FILTER - ChangeDataStruct - MENU -- 0.54 ok - not used line 506
	if ( SpellTracker:IsInCombat() == false ) then
		lvl = lvl or 1;
		local str = "";
		if ( UIDROPDOWNMENU_MENU_VALUE ) then
			str = UIDROPDOWNMENU_MENU_VALUE;
		end
		for k, v in ipairs(SpellTrackerDB.Params.DataStructItems) do
			if ( string.match(str, v) == nil ) then
				local info = {}
				info.text = v;
				info.notCheckable = false;
				if ( lvl == #SpellTrackerDB.Params.DataStructItems ) then
					info.hasArrow = false; -- creates submenu
				else
					info.hasArrow = true; -- creates submenu
				end
				if ( str and str ~= "" ) then
					info.value = tostring(str)..">"..v;
				else
					info.value = v;
				end
				info.func = 
					function()
						SpellTracker:ChangeDataStruct(tostring(str)..">"..v); -- tostring(str)..">"..v ald info.value biarre mais ok sinon marhce pas car me rajoute targetname
						CloseDropDownMenus();
					end
				UIDropDownMenu_AddButton(info, lvl);
			end
		end
	else
		print(L["NOCOMBAT_MSG1"]);
	end
end
function SpellTracker_FilterDropDownMenu_ShowTootlip(self) -- FILTER - ChangeDataStruct - MENU -- 0.54 ok - not used line 506
	GameTooltip:SetOwner(self);
	local strToShow = L["TOOLTIP_MSG3"];
	GameTooltip:SetText(strToShow);
	GameTooltip:Show();
end
function SpellTracker_ViewPlaying_ShowTootlip(self) -- FILTER MENU
	GameTooltip:SetOwner(self);
	local strToShow;
	if ( SpellTrackerDB.ViewPlaying == 1 ) then
		strToShow = L["VIEWPLAYING"];
	elseif ( SpellTrackerDB.ViewPlaying == 0 ) then
		strToShow = L["VIEWPAUSE"];
	end
	GameTooltip:SetText(strToShow);
	GameTooltip:Show();
end
function SpellTracker_RecordingMode_ShowTootlip(self) -- FILTER MENU
	GameTooltip:SetOwner(self);
	local strToShow;
	if ( SpellTrackerDB.Recording_Mode == 1 ) then
		strToShow = L["MODERECORDING"];
	elseif ( SpellTrackerDB.Recording_Mode == 0 ) then
		strToShow = L["MODEPAUSE"];
	end
	GameTooltip:SetText(strToShow);
	GameTooltip:Show();
end
function SpellTracker_ViewRefresh_ShowTootlip(self)
	GameTooltip:SetOwner(self);
	local label = L["REFRESH"];
	GameTooltip:SetText(label);
	GameTooltip:Show();
end
function SpellTracker_NumLineDisplay_ShowTootlip(self)
	GameTooltip:SetOwner(self);
	local label;
	if ( SpellTrackerDB.NumLineDisplay == 0 ) then
		label = L["NUMLINEDISP_LONG_AMOUNT"];
	elseif ( SpellTrackerDB.NumLineDisplay == 1 ) then
		label = L["NUMLINEDISP_LONG_TICK"];
	elseif ( SpellTrackerDB.NumLineDisplay == 2 ) then
		label = L["NUMLINEDISP_LONG_BEST"];
	end
	GameTooltip:SetText(label);
	GameTooltip:Show();
end
function SpellTracker_Context_ShowTootlip(self)
	-- Context = 0 / Context Less = 1
	
	GameTooltip:SetOwner(self);
	local label;
	if ( SpellTrackerDB.Context == 0 ) then
		label = L["CONTEXT_MODE_LONG"];
	elseif ( SpellTrackerDB.Context == 1 ) then
		label = L["CONTEXTLESS_MODE_LONG"];
	end
	GameTooltip:SetText(label);
	GameTooltip:Show();
end
function SpellTracker_SortBtn_ShowTootlip(id, self)
	-- SpellTrackerDB.CurrentSort  -- 1 Total / 2 hit / 3 crit / 4 overcrit / 5 over / 6 overAbsorb / 7 CritAbsorb / 8 Absorb
	
	GameTooltip:SetOwner(self);
	local label;
	if ( id == 1 ) then label = L["SORTING_TOTAL"];
	elseif ( id == 2 ) then label = L["SORTING_HIT"];
	elseif ( id == 3 ) then label = L["SORTING_CRIT"];
	elseif ( id == 4 ) then label = L["SORTING_OVERCRIT"];
	elseif ( id == 5 ) then label = L["SORTING_OVER"];
	elseif ( id == 6 ) then label = L["SORTING_OVERABSORB"];
	elseif ( id == 7 ) then label = L["SORTING_CRITABSORB"];
	elseif ( id == 8 ) then label = L["SORTING_ABSORB"];
	end
	GameTooltip:SetText(label);
	GameTooltip:Show();
end
function SpellTracker_SortBtn_OnClick(id, self)
	-- SpellTrackerDB.CurrentSort  -- 1 Total / 2 hit / 3 crit / 4 overcrit / 5 over / 6 overAbsorb / 7 CritAbsorb / 8 Absorb
	
	SpellTracker_SwitchSorting(id, self);
	
	SpellTracker:ReComputeFilteredSpellList();
	SpellTracker:UpdateFrame();
end
function SpellTracker_SwitchSorting(id)
	-- SpellTrackerDB.CurrentSort  -- 1 Total / 2 hit / 3 crit / 4 overcrit / 5 over / 6 overAbsorb / 7 CritAbsorb / 8 Absorb
	
	SpellTrackerDB.CurrentSort = id;
	
	-- Unlock Highlight
	SpellTrackerFrameMainMenuTitleSortTotalBtn:UnlockHighlight();
	SpellTrackerFrameMainMenuTitleSortHitBtn:UnlockHighlight();
	SpellTrackerFrameMainMenuTitleSortCritBtn:UnlockHighlight();
	SpellTrackerFrameMainMenuTitleSortOverCritBtn:UnlockHighlight();
	SpellTrackerFrameMainMenuTitleSortOverBtn:UnlockHighlight();
	SpellTrackerFrameMainMenuTitleSortOverAbsorbBtn:UnlockHighlight();
	SpellTrackerFrameMainMenuTitleSortCritAbsorbBtn:UnlockHighlight();
	SpellTrackerFrameMainMenuTitleSortAbsorbBtn:UnlockHighlight();
	
	local label;
	if ( SpellTrackerDB.CurrentSort == 1 ) then SpellTrackerFrameMainMenuTitleSortTotalBtn:LockHighlight();
	elseif ( SpellTrackerDB.CurrentSort == 2 ) then SpellTrackerFrameMainMenuTitleSortHitBtn:LockHighlight();
	elseif ( SpellTrackerDB.CurrentSort == 3 ) then SpellTrackerFrameMainMenuTitleSortCritBtn:LockHighlight();
	elseif ( SpellTrackerDB.CurrentSort == 4 ) then SpellTrackerFrameMainMenuTitleSortOverCritBtn:LockHighlight();
	elseif ( SpellTrackerDB.CurrentSort == 5 ) then SpellTrackerFrameMainMenuTitleSortOverBtn:LockHighlight();
	elseif ( SpellTrackerDB.CurrentSort == 6 ) then SpellTrackerFrameMainMenuTitleSortOverAbsorbBtn:LockHighlight();
	elseif ( SpellTrackerDB.CurrentSort == 7 ) then SpellTrackerFrameMainMenuTitleSortCritAbsorbBtn:LockHighlight();
	elseif ( SpellTrackerDB.CurrentSort == 8 ) then SpellTrackerFrameMainMenuTitleSortAbsorbBtn:LockHighlight();
	end
end
-- function for adding buttons in the context menu
function SpellTracker_AddDropDownItem(...)
  --[[
	List of button attributes
	======================================================
	info.text = [STRING]  --  The text of the button
	info.value = [ANYTHING]  --  The value that UIDROPDOWNMENU_MENU_VALUE is set to when the button is clicked
	info.func = [function()]  --  The function that is called when you click the button
	info.checked = [nil, true, function]  --  Check the button if true or function returns true
	info.isNotRadio = [nil, true]  --  Check the button uses radial image if false check box image if true
	info.isTitle = [nil, true]  --  If it's a title the button is disabled and the font color is set to yellow
	info.disabled = [nil, true]  --  Disable the button and show an invisible button that still traps the mouseover event so menu doesn't time out
	info.tooltipWhileDisabled = [nil, 1] -- Show the tooltip, even when the button is disabled.
	info.hasArrow = [nil, true]  --  Show the expand arrow for multilevel menus
	info.hasColorSwatch = [nil, true]  --  Show color swatch or not, for color selection
	info.r = [1 - 255]  --  Red color value of the color swatch
	info.g = [1 - 255]  --  Green color value of the color swatch
	info.b = [1 - 255]  --  Blue color value of the color swatch
	info.colorCode = [STRING] -- "|cAARRGGBB" embedded hex value of the button text color. Only used when button is enabled
	info.swatchFunc = [function()]  --  Function called by the color picker on color change
	info.hasOpacity = [nil, 1]  --  Show the opacity slider on the colorpicker frame
	info.opacity = [0.0 - 1.0]  --  Percentatge of the opacity, 1.0 is fully shown, 0 is transparent
	info.opacityFunc = [function()]  --  Function called by the opacity slider when you change its value
	info.cancelFunc = [function(previousValues)] -- Function called by the colorpicker when you click the cancel button (it takes the previous values as its argument)
	info.notClickable = [nil, 1]  --  Disable the button and color the font white
	info.notCheckable = [nil, 1]  --  Shrink the size of the buttons and don't display a check box
	info.owner = [Frame]  --  Dropdown frame that "owns" the current dropdownlist
	info.keepShownOnClick = [nil, 1]  --  Don't hide the dropdownlist after a button is clicked
	info.tooltipTitle = [nil, STRING] -- Title of the tooltip shown on mouseover
	info.tooltipText = [nil, STRING] -- Text of the tooltip shown on mouseover
	info.tooltipOnButton = [nil, 1] -- Show the tooltip attached to the button instead of as a Newbie tooltip.
	info.justifyH = [nil, "CENTER"] -- Justify button text
	info.arg1 = [ANYTHING] -- This is the first argument used by info.func
	info.arg2 = [ANYTHING] -- This is the second argument used by info.func
	info.fontObject = [FONT] -- font object replacement for Normal and Highlight
	info.menuTable = [TABLE] -- This contains an array of info tables to be displayed as a child menu
	info.noClickSound = [nil, 1]  --  Set to 1 to suppress the sound when clicking the button. The sound only plays if .func is set.
	info.padding = [nil, NUMBER] -- Number of pixels to pad the text on the right side
	]]
  it = {};
  level, it.text, it.value, it.checked, it.hasArrow, it.func, it.arg1 = ...;
  UIDropDownMenu_AddButton(it, level);
  wipe(it);
end
function SpellTracker_TargetDropDownMenu_Init() -- TARGET MENU
	SpellTracker_TargetDropDownMenu.displayMode = "MENU"
	
	SpellTracker_TargetDropDownMenu.initialize = function(self, level)
		if level == 1 then
			SpellTracker_AddDropDownItem(level, L["TOOLTIP_MSG4"], nil, (SpellTrackerDB.Tracking_Target == 1), nil, SpellTracker_SwitchTarget, 1, nil);
			SpellTracker_AddDropDownItem(level, L["TOOLTIP_MSG5"], nil, (SpellTrackerDB.Tracking_Target == 2), nil, SpellTracker_SwitchTarget, 2, nil);
			SpellTracker_AddDropDownItem(level, L["TOOLTIP_MSG6"], nil, (SpellTrackerDB.Tracking_Target == 3), nil, SpellTracker_SwitchTarget, 3, nil);
			SpellTracker_AddDropDownItem(level, L["TOOLTIP_MSG7"], nil, (SpellTrackerDB.Tracking_Target == 4), nil, SpellTracker_SwitchTarget, 4, nil);
			SpellTracker_AddDropDownItem(level, L["TOOLTIP_MSG8"], nil, (SpellTrackerDB.Tracking_Target == 5), nil, SpellTracker_SwitchTarget, 5, nil);
		end
	end
	
	SpellTrackerFrameMainMenuTitleOtherTarget:SetScript("OnClick", 
		function()	
			ToggleDropDownMenu(1, nil, SpellTracker_TargetDropDownMenu, SpellTrackerFrameMainMenuTitleOtherTarget, 0, 0);
		end
	);
end
function SpellTracker_SwitchTarget(mode)
	local AcceptFunc = nil;
	local CancelFunc = function() end;
	
	if ( mode.arg1 == 1 ) then
		AcceptFunc = function()
			SpellTrackerDB.CurrentPlayerTracked.GUID = UnitGUID("player");
			SpellTrackerDB.CurrentPlayerTracked.Name = UnitName("player");
			SpellTrackerDB.CurrentPlayerTracked.lvl = UnitLevel("player");
			SpellTrackerDB.Tracking_Target = 1;
			SpellTracker.ResetView();
		end
	elseif ( mode.arg1 == 2 ) then 			
		if ( UnitName("target") ~= nil ) then
			AcceptFunc = function()
				SpellTrackerDB.CurrentPlayerTracked.GUID = UnitGUID("target");
				SpellTrackerDB.CurrentPlayerTracked.Name = UnitName("target");
				SpellTrackerDB.CurrentPlayerTracked.lvl = UnitLevel("player");
				SpellTrackerDB.Tracking_Target = 2;
				SpellTracker.ResetView();
			end
		else
			print(L["ERROR_TARGET_MSG1"]);
		end
	elseif ( mode.arg1 == 3 ) then 			
		AcceptFunc = function()
			SpellTrackerDB.CurrentPlayerTracked.GUID = nil;
			SpellTrackerDB.CurrentPlayerTracked.Name = nil;
			SpellTrackerDB.CurrentPlayerTracked.lvl = nil;
			SpellTrackerDB.Tracking_Target = 3;
			SpellTracker.ResetView();
		end
	elseif ( mode.arg1 == 4 ) then 			
		if ( IsInRaid() ) then
			AcceptFunc = function()
				SpellTrackerDB.CurrentPlayerTracked.GUID = nil;
				SpellTrackerDB.CurrentPlayerTracked.Name = nil;
				SpellTrackerDB.CurrentPlayerTracked.lvl = nil;
				SpellTracker:CreateOrUpdateRaidMembersList();
				SpellTrackerDB.Tracking_Target = 4;
				SpellTracker.ResetView();
			end
		else
			print(L["ERROR_RAID_MSG1"]);
		end
	elseif ( mode.arg1 == 5 ) then 			
		if ( IsInGroup() ) then
			AcceptFunc = function()
				SpellTrackerDB.CurrentPlayerTracked.GUID = nil;
				SpellTrackerDB.CurrentPlayerTracked.Name = nil;
				SpellTrackerDB.CurrentPlayerTracked.lvl = nil;
				SpellTracker:CreateOrUpdateGroupMembersList();
				SpellTrackerDB.Tracking_Target = 5;
				SpellTracker.ResetView();
			end
		else
			print(L["ERROR_GROUP_MSG1"]);
		end
	end
	
	GetChoice(AcceptFunc,CancelFunc);
end
function SpellTracker_TargetDropDownMenu_ShowTootlip(self) -- TARGET MENU
	GameTooltip:SetOwner(self);
	local strToShow = "";
	if ( SpellTrackerDB.Tracking_Target == 1 ) then strToShow = L["TOOLTIP_MSG4"];
	elseif ( SpellTrackerDB.Tracking_Target == 2 ) then strToShow = L["TOOLTIP_MSG5"];
	elseif ( SpellTrackerDB.Tracking_Target == 3 ) then strToShow = L["TOOLTIP_MSG6"];
	elseif ( SpellTrackerDB.Tracking_Target == 4 ) then strToShow = L["TOOLTIP_MSG7"];
	elseif ( SpellTrackerDB.Tracking_Target == 5 ) then strToShow = L["TOOLTIP_MSG8"];
	end
	GameTooltip:SetText(strToShow);
	GameTooltip:Show();
end
function SpellTracker_SrcOrDstDropDownMenu_Init() -- SRC/DST MENU
	-- INIT SRC OR DST
	SpellTracker_SrcOrDstDropDownMenu.displayMode = "MENU"

	SpellTracker_SrcOrDstDropDownMenu.initialize = function(self, level)
		if level == 1 then
			SpellTracker_AddDropDownItem(level, L["EMITTED"], nil, (SpellTrackerDB.Tracking_Mode == 1), nil, SpellTracker_SwitchTrackingMode, 1, nil);
			SpellTracker_AddDropDownItem(level, L["RECEIVED"], nil, (SpellTrackerDB.Tracking_Mode == 2), nil, SpellTracker_SwitchTrackingMode, 2, nil);
		end
	end
	
	SpellTrackerFrameMainMenuTitleAttackORAttacked:SetScript("OnClick", 
		function()	
			ToggleDropDownMenu(1, nil, SpellTracker_SrcOrDstDropDownMenu, SpellTrackerFrameMainMenuTitleAttackORAttacked, 0, 0);
		end
	);
end
function SpellTracker_SwitchTrackingMode(mode)
	local AcceptFunc = nil;
	local CancelFunc = function() end;
	
	if ( mode.arg1 == 1 ) then
		AcceptFunc = function()
			SpellTrackerDB.Tracking_Mode = 1;
			SpellTrackerDB.MsgToolTip = L["TRACK_SRC"];
			SpellTracker.ResetView();
		end
	elseif ( mode.arg1 == 2 ) then 			
		AcceptFunc = function()
			SpellTrackerDB.Tracking_Mode = 2;
			SpellTrackerDB.MsgToolTip = L["TRACK_DST"];
			SpellTracker.ResetView();
		end
	end
	
	GetChoice(AcceptFunc,CancelFunc);
end
function SpellTracker_SrcOrDstDropDownMenu_ShowTootlip(self) -- SRC/DST MENU
	GameTooltip:SetOwner(self);
	local strToShow = "";
	if ( SpellTrackerDB.Tracking_Mode == 1 ) then strToShow = L["TRACK_SRC"];
	elseif ( SpellTrackerDB.Tracking_Mode == 2 ) then strToShow = L["TRACK_DST"];
	end
	GameTooltip:SetText(strToShow);
	GameTooltip:Show();
end
function SpellTracker_RecordingDropDownMenu_Init() -- 0.47 -- RECORDING MENU
	SpellTrackerDB.MenuDropDown_RECORDING = SpellTrackerDB.MenuDropDown_RECORDING or {}
	
	SpellTrackerDB.MenuDropDown_RECORDING.It1 = SpellTrackerDB.MenuDropDown_RECORDING.It1 or {};
	SpellTrackerDB.MenuDropDown_RECORDING.It1.txt = L["RECORDING"];
	if ( SpellTrackerDB.MenuDropDown_RECORDING.It1.check == nil ) then SpellTrackerDB.MenuDropDown_RECORDING.It1.check = true; end
	
	SpellTrackerDB.MenuDropDown_RECORDING.It2 = SpellTrackerDB.MenuDropDown_RECORDING.It2 or {};
	SpellTrackerDB.MenuDropDown_RECORDING.It2.txt = L["PAUSE_VIEW_UPDATING"];
	if ( SpellTrackerDB.MenuDropDown_RECORDING.It2.check == nil ) then SpellTrackerDB.MenuDropDown_RECORDING.It2.check = false; end
	
	SpellTrackerDB.MenuDropDown_RECORDING.It3 = SpellTrackerDB.MenuDropDown_RECORDING.It3 or {};
	SpellTrackerDB.MenuDropDown_RECORDING.It3.txt = L["STOP"];
	if ( SpellTrackerDB.MenuDropDown_RECORDING.It3.check == nil ) then SpellTrackerDB.MenuDropDown_RECORDING.It3.check = false; end
	
	-- RECORDING / PAUSE / STOP
	--UIDropDownMenu_Initialize(SpellTracker_RecordingDropDownMenu, SpellTracker_RecordingDropDownMenu_OnLoad, "MENU");
	SpellTracker_RecordingDropDownMenu_OnLoad();
	SpellTrackerFrameMainMenuTitleRecordBtn:SetScript("OnClick", 
		function()	
			ToggleDropDownMenu(1, nil, SpellTracker_RecordingDropDownMenu, SpellTrackerFrameMainMenuTitleRecordBtn, 0, 0);
		end
	);
end
function SpellTracker_RecordingDropDownMenu_OnLoad() -- 0.47 -- RECORDING MENU
	info = {};
    info.text = SpellTrackerDB.MenuDropDown_RECORDING.It1.txt;
    info.value = "OptionVariable";
	info.checked = SpellTrackerDB.MenuDropDown_RECORDING.It1.check;
    info.func = 
		function() 
			SpellTracker_SetViewPlayingMode(L["RECORDING"])
		end 
	UIDropDownMenu_AddButton(info);
	
	info = {};
    info.text = SpellTrackerDB.MenuDropDown_RECORDING.It2.txt;
    info.value = "OptionVariable";
	info.checked = SpellTrackerDB.MenuDropDown_RECORDING.It2.check;
    info.func = 
		function() 
			SpellTracker_SetViewPlayingMode(L["PAUSE_VIEW_UPDATING"])
		end 
	UIDropDownMenu_AddButton(info);
	
	info = {};
    info.text = SpellTrackerDB.MenuDropDown_RECORDING.It3.txt;
    info.value = "OptionVariable";
	info.checked = SpellTrackerDB.MenuDropDown_RECORDING.It3.check;
    info.func = 
		function() 
			SpellTracker_SetViewPlayingMode(L["STOP"])
		end 
	UIDropDownMenu_AddButton(info);
end
function SpellTracker_RecordingDropDownMenu_ShowTootlip(self) -- 0.47 -- RECORDING MENU
	GameTooltip:SetOwner(self);
	local strToShow = "";
	--if ( SpellTrackerDB.MenuDropDown_RECORDING.It1.check == true ) then strToShow = SpellTrackerDB.MenuDropDown_RECORDING.It1.txt;
	--elseif ( SpellTrackerDB.MenuDropDown_RECORDING.It2.check == true ) then strToShow = SpellTrackerDB.MenuDropDown_RECORDING.It2.txt;
	--elseif ( SpellTrackerDB.MenuDropDown_RECORDING.It3.check == true ) then strToShow = SpellTrackerDB.MenuDropDown_RECORDING.It3.txt;
	--end
	GameTooltip:SetText(strToShow);
	GameTooltip:Show();
end
function SpellTracker_SetViewPlayingMode(ViewPlaying) -- 0.47 -- active view playing configuration -- 0.62
    if ( ViewPlaying == 0 ) then -- 1 = recording / 0 = pause
		SpellTrackerDB.ViewPlaying = 0;
		SpellTrackerFrameMainMenuTitleViewPlayingBtnIcon:SetTexture("Interface\\TIMEMANAGER\\PauseButton");
	elseif ( ViewPlaying == 1 ) then -- 1 = recording / 0 = pause / 0 = stop
		SpellTrackerDB.ViewPlaying = 1;
		SpellTrackerFrameMainMenuTitleViewPlayingBtnIcon:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up");
	end
	
	SpellTracker:AdjustColorOfMainMenuTitle();
end
function SpellTracker_SetRecordingMode(Recording) -- 0.47 -- active recording configuration -- 0.62
    if ( Recording == 0 ) then -- 1 = recording / 0 = pause
		SpellTrackerDB.Recording_Mode = 0;
		SpellTrackerFrameMainMenuTitleRecordingBtnIcon:SetTexture("Interface\\TIMEMANAGER\\PauseButton");
		GameTooltip:SetText(L["MODEPAUSE"]);
	elseif ( Recording == 1 ) then -- 1 = recording / 0 = pause
		SpellTrackerDB.Recording_Mode = 1;
		SpellTrackerFrameMainMenuTitleRecordingBtnIcon:SetTexture("Interface\\TIMEMANAGER\\ResetButton");
		GameTooltip:SetText(L["MODERECORDING"]);
	end
	
	SpellTracker:AdjustColorOfMainMenuTitle();
end
-- core --
function SpellTracker:ResetView()
	SpellTrackerDB.GetFilteredSpellsStructByParsingOfIndexer = {};
	
	SpellTrackerDB.SPELLS = {};
	SpellTrackerDB.ColumnFilter = {Count=0; QuickAcces={}};
	
	SpellTrackerDB.currentSessionHealTotal = 0;
	SpellTrackerDB.currentSessionDamageTotal = 0;
	SpellTrackerMinimapButton_OnLoad();
	SpellTrackerMinimapButton_UpdateTitle();
	SpellTrackerButton_UpdateTitle();
	SpellTracker:ReComputeFilteredSpellList();
	SpellTracker:UpdateFrame();
end
-- Column filtering
function SpellTracker:DoColumnFiltering() -- 0.70 column filtering
	SpellTracker:PrepareColumnFilter();
	SpellTracker:FillListToSortAndNodeToSortFromColumnFilter(true);
	if ( SpellTrackerDB.ViewPlaying ~= L["PAUSE_VIEW_UPDATING"] ) then -- 0.47
		SpellTracker:UpdateFrame(); -- maj
	end
end
function SpellTracker:PrepareColumnFilter() -- 0.62 column filter
	local cCFilter = SpellTrackerDB.ColumnFilter;
	local sep = SpellTrackerDB.Separator;
	SpellTrackerDB.ColumnFilter.QuickAcces = SpellTrackerDB.ColumnFilter.QuickAcces or {};
	for k,v in pairs(cCFilter) do
		if ( k and v ) then
			if ( type(v) == "table" ) then
				if ( k ~= "QuickAcces" ) then
					for kk,vv in pairs(v) do
						if ( kk and vv == 1 ) then  -- 0 == false / 1 == true / 2 == false + desactiv√© / 3 == true + d√©sactiv√©
							if ( SpellTrackerDB.ColumnFilter.QuickAcces[k] == nil ) then
								SpellTrackerDB.ColumnFilter.QuickAcces[k] = kk;
							else
								SpellTrackerDB.ColumnFilter.QuickAcces[k] = SpellTrackerDB.ColumnFilter.QuickAcces[k]..sep..kk;
							end
						end
					end
				end
			end
		end
	end
end
function SpellTracker:ResetCurrentColumnFilter(Filter) -- 0.62 reset column filter
	local cCFilter = SpellTrackerDB.ColumnFilter[Filter];
	if ( cCFilter ) then
		for k,v in pairs(cCFilter) do
			print(k,v);
			if ( k and v == true ) then
				cCFilter[k] = false;
			end
		end
	end
end
function SpellTracker:ChangeDataStruct(newStruct)  -- 0.54 ok DYNAMIC FILTER MENU
	if ( SpellTracker:IsInCombat() == false ) then
		SpellTrackerDB.Params.DataStructString = newStruct;
		SpellTracker:InitDataStruct(SpellTrackerDB.Params.DataStructString);
		
		SpellTrackerDB.Params.DataStructStringDisplayedFilter = string.gsub(newStruct, ">", "+");
		SpellTracker:InitDisplayedFilter(SpellTrackerDB.Params.DataStructStringDisplayedFilter);
		
		-- SpellTracker:InitFilterFrame();
		if ( SpellTrackerFrameMainMenuTitleDisplayFilterSelectFrame ) then
			if ( SpellTrackerFrameMainMenuTitleDisplayFilterSelectFrame.Buttons ) then
				-- on cache les anciens boutons
				for index, btn in pairs(SpellTrackerFrameMainMenuTitleDisplayFilterSelectFrame.Buttons) do
					btn.Used = false;
					btn:Hide();
				end
				local BtnName = "SpellTrackerFilterBtn";
				local lastBtn = nil;
				local btn = nil;
				for k=0, #SpellTrackerDB.DataStruct do
					local btnName = BtnName..tostring(k);
					SpellTrackerFrameMainMenuTitleDisplayFilterSelectFrame.Buttons[k] = SpellTrackerFrameMainMenuTitleDisplayFilterSelectFrame.Buttons[k] or CreateFrame("Button", btnName, SpellTrackerFrameMainMenuTitleDisplayFilterSelectFrame, "SpellTrackerFilterButtonTemplate");
					btn = SpellTrackerFrameMainMenuTitleDisplayFilterSelectFrame.Buttons[k];
					if ( btn ) then
						btn.idx = k;
						btn.Used = true;
						btn.selected = false;
						btnName = SpellTrackerDB.DataStruct[k];
						if ( btnName ) then
							btn.label.nameStr = SpellTrackerDB.DataStruct[k];
							btn.label:SetText(btn.label.nameStr);
						end
						if ( k == 0 ) then
							btn:SetPoint("TOPLEFT", SpellTrackerFrameMainMenuTitleDisplayFilterSelectFrame, "TOPLEFT", 5, 0);
						else
							btn:SetPoint("TOPLEFT", lastBtn, "TOPRIGHT", -1, 0);
						end
						btn:Show();
						lastBtn = btn;
					end
				end
				if ( btn ) then btn.last = true; end -- 0.51 pour pas afficher de fleche au dernier bouton 
			end
		end
	
		SpellTracker:AutoResizeFilterFrame();
		SpellTracker:UpdateButtonsFromDisplayedFiter();
		
		SpellTracker:UpdateFilterButton(self);
		SpellTracker:UpdateDisplayedFiterFromButtons();
	
		SpellTracker:ResetView();
	end
end	
function SpellTracker:StartFrameResize() -- 0.53 -- 0.57
	if ( SpellTracker:IsInCombat() == false ) then
		SpellTrackerFrame.isMovingOrSizing = false;
		local minHeight = SpellTrackerFrameMainMenuTitle:GetHeight() + SpellTrackerDB.Params.SpellBarHeight + 2;
		local maxWidth, maxHeight = UIParent:GetWidth()-10, UIParent:GetHeight()-10;
		SpellTrackerFrame:SetMinResize(80, minHeight);
		SpellTrackerFrame:SetMaxResize(maxWidth, maxHeight);
		SpellTrackerFrame:StartSizing();
	end
end
function SpellTracker:EndFrameResize() -- 0.53 
	if ( SpellTracker:IsInCombat() == false ) then
		SpellTracker:AutoRedimSpellTrackerFrame();
		SpellTrackerFrame:StopMovingOrSizing();
		SpellTrackerFrame:ClearAllPoints();
		SpellTrackerFrame.isMovingOrSizing = nil;
		SpellTrackerDB.Params.FrameWidth = SpellTrackerFrame:GetWidth();
		
		SpellTracker:InitFrame(); -- on a redimentionnÈ donc on reinit le layout	
		SpellTracker:ReComputeFilteredSpellList(); -- on recalcule
		SpellTracker:UpdateFrame(); -- on update la frame
	end
end
function SpellTracker:ExpandForNodeType1(spellStruct) -- 0.48 Tree Node -- 0.53 bug fix -- 0.55 Node Type 1 = Simple Node
	if ( spellStruct ) then
		--print("Expand");
		local localStruct = nil;
		if ( spellStruct.IndexerOfParent ) then
			localStruct = SpellTracker:GetDBSpellsStructByParsingOfIndexer(spellStruct.IndexerOfParent..SpellTrackerDB.Separator..spellStruct.Indexer);
		else
			localStruct = SpellTracker:GetDBSpellsStructByParsingOfIndexer(spellStruct.Indexer);
		end
		if ( localStruct ) then
			if ( localStruct.Expanded ~= nil ) then -- 0.53 pour elominer la tex de exapnd collapse si pas d'enfants
				localStruct.Expanded = SpellTracker_ExpandTypeNode1;
				SpellTracker:ReComputeFilteredSpellList();
				SpellTracker:UpdateFrame();
			end
		end
	end
end
function SpellTracker:ExpandForNodeType2(spellStruct) -- 0.48 Tree Node -- 0.53 bug fix -- 0.55 Node Type 2 = Agregated Node
	if ( spellStruct ) then
		--print("Expand");
		local localStruct = nil;
		if ( spellStruct.IndexerOfParent ) then
			localStruct = SpellTracker:GetDBSpellsStructByParsingOfIndexer(spellStruct.IndexerOfParent..SpellTrackerDB.Separator..spellStruct.Indexer);
		else
			localStruct = SpellTracker:GetDBSpellsStructByParsingOfIndexer(spellStruct.Indexer);
		end
		if ( localStruct ) then
			if ( localStruct.Expanded ~= nil ) then -- 0.53 pour elominer la tex de exapnd collapse si pas d'enfants
				localStruct.Expanded = SpellTracker_ExpandTypeNode2;
				SpellTracker:ReComputeFilteredSpellList();
				SpellTracker:UpdateFrame();
			end
		end
	end
end
function SpellTracker:ExpandAll(spellStruct) -- 0.52 -- 0.53 bug fix -- 0.55 Node Type 2 = Agregated Node
	function RecursExpand(struct)
		if ( struct ) then
			struct.Expanded = 1;
			for k, v in pairs(struct) do
				if ( type(v) == "table" ) then RecursExpand(v); end
			end 
		end
	end
	
	if ( spellStruct ) then
		--print("Expand");
		local localStruct = nil;
		if ( spellStruct.IndexerOfParent ) then
			localStruct = SpellTracker:GetDBSpellsStructByParsingOfIndexer(spellStruct.IndexerOfParent..SpellTrackerDB.Separator..spellStruct.Indexer);
		else
			localStruct = SpellTracker:GetDBSpellsStructByParsingOfIndexer(spellStruct.Indexer);
		end
		if ( localStruct ) then
			if ( localStruct.Expanded ~= nil ) then -- 0.53 pour eliminer la tex de expand collapse si pas d'enfants
				localStruct.Expanded = SpellTracker_ExpandTypeNode2;
				RecursExpand(localStruct);
				SpellTracker:ReComputeFilteredSpellList();
				SpellTracker:UpdateFrame();
			end
		end
	end
end
function SpellTracker:Collapse(spellStruct) -- 0.48 Tree Node -- 0.55 Node Type 2 or 1
	if ( spellStruct ) then
		--print("Collapse");
		local localStruct = nil;
		if ( spellStruct.IndexerOfParent ) then
			localStruct = SpellTracker:GetDBSpellsStructByParsingOfIndexer(spellStruct.IndexerOfParent..SpellTrackerDB.Separator..spellStruct.Indexer);
		else
			localStruct = SpellTracker:GetDBSpellsStructByParsingOfIndexer(spellStruct.Indexer);
		end
		if ( localStruct ) then
			localStruct.Expanded = SpellTracker_Collapse;
			SpellTracker:ReComputeFilteredSpellList();
			SpellTracker:UpdateFrame();
		end
	end
end
function SpellTracker:CollapseAll(spellStruct) -- 0.52 -- 0.55 Node Type 2 or 1
	function RecursCollapse(struct)
		if ( struct ) then
			struct.Expanded = SpellTracker_Collapse;
			for k, v in pairs(struct) do
				if ( type(v) == "table" ) then RecursCollapse(v); end
			end 
		end
	end
	
	if ( spellStruct ) then
	--print("Collapse All");
		local localStruct = nil;
		if ( spellStruct.IndexerOfParent ) then
			localStruct = SpellTracker:GetDBSpellsStructByParsingOfIndexer(spellStruct.IndexerOfParent..SpellTrackerDB.Separator..spellStruct.Indexer);
		else
			localStruct = SpellTracker:GetDBSpellsStructByParsingOfIndexer(spellStruct.Indexer);
		end
		if ( localStruct ) then
			localStruct.Expanded = SpellTracker_Collapse;
			RecursCollapse(localStruct);
			SpellTracker:ReComputeFilteredSpellList();
			SpellTracker:UpdateFrame();
		end
	end
end
function SpellTracker:GetDBSpellsStructByParsingOfIndexer(IndexerString) -- 0.48 Tree Node
	--print(IndexerString);
	local CurrentIndexerTab = SpellTracker:StringFiltering(IndexerString, "(.+)"..SpellTrackerDB.Separator.."(.+)");
	local idx=0;
	local tmpStruct = SpellTrackerDB.SPELLS;
	for idx=0,#CurrentIndexerTab do
		--print("CurrentIndexerTab["..tostring(idx).."]="..tostring(CurrentIndexerTab[idx]));
		if ( tmpStruct[CurrentIndexerTab[idx]] ) then
			tmpStruct = tmpStruct[CurrentIndexerTab[idx]];
		else
			break;
		end
	end
	return tmpStruct;
end
function SpellTracker:GetFilteredSpellsStructByParsingOfIndexer(IndexerString)-- 0.58
	local CurrentIndexerTab = SpellTracker:StringFiltering(IndexerString, "(.+)"..SpellTrackerDB.Separator.."(.+)");
	local tmpIndexer = "";
    local tmpStruct = SpellTrackerDB.FILTEREDSPELLS;
    for idx=0,#CurrentIndexerTab do
		if ( tmpIndexer == "" ) then tmpIndexer = CurrentIndexerTab[idx];
        else tmpIndexer = tmpIndexer..SpellTrackerDB.Separator..CurrentIndexerTab[idx]; end
		if ( tmpStruct.Nodes and tmpStruct.Nodes[tmpIndexer] ) then
            tmpStruct = tmpStruct.Nodes[tmpIndexer];
            tmpIndexer = "";
        elseif ( tmpStruct[tmpIndexer] ) then
            tmpStruct = tmpStruct[tmpIndexer];
            tmpIndexer = "";
        end
    end
    
	--print("URL( "..IndexerString.." ) = "..tostring(tmpStruct));
	
	return tmpStruct;
end
function SpellTracker:CreateOrUpdateRaidMembersList()
	local _guid;
	SpellTracker.RaidLst = {};
	SpellTracker.RaidLst[UnitGUID("player")]=1; -- je m'ajoute
	for idx=1,40 do
		_guid = UnitGUID("raid"..tostring(idx)); -- raid player member
		if ( _guid ) then SpellTracker.RaidLst[_guid] = 1; end
		_guid = UnitGUID("raidpet"..tostring(idx)); -- raid pet member
		if ( _guid ) then SpellTracker.RaidLst[_guid] = 1; end
	end
end
function SpellTracker:CreateOrUpdateGroupMembersList()
	local _guid;
	SpellTracker.PartyLst = {};
	SpellTracker.PartyLst[UnitGUID("player")]=1; -- je m'ajoute
	for idx=1,5 do
		_guid = UnitGUID("party"..tostring(idx)); -- party player member
		if ( _guid ) then SpellTracker.PartyLst[_guid] = 1; end
		_guid = UnitGUID("partypet"..tostring(idx)); -- party pet member
		if ( _guid ) then SpellTracker.PartyLst[_guid] = 1; end
	end
end
function SpellTracker:InitDataStruct(dataStruct) -- 0.43 OK
	local ret = false;
	if ( dataStruct ) then
		if ( type(dataStruct ) == "string" ) then
			SpellTrackerDB.Params.DataStruct = dataStruct;
			-- 0.41 / on extrait la structure de donnÈe et les filtres d'affichage
			SpellTrackerDB.DataStruct = SpellTracker:StringFiltering(SpellTrackerDB.Params.DataStruct, "(%S+)>(%S+)");
			SpellTrackerDB.DataStructInv = SpellTracker:StringFilteringInv(SpellTrackerDB.Params.DataStruct, "(%S+)>(%S+)");
			ret = true;
		end
	end
	return ret;
end
function SpellTracker:InitDisplayedFilter(dispFilter) -- 0.43 OK
	local ret = false;
	
	if ( dispFilter ) then
		if ( type(dispFilter ) == "string" ) then
			SpellTrackerDB.Params.DisplayedFilters = SpellTrackerDB.Params.DisplayedFilters or dispFilter;
			-- 0.41 / on extrait la structure de donnÈe et les filtres d'affichage
			SpellTrackerDB.DisplayedFilters = SpellTracker:StringFiltering(SpellTrackerDB.Params.DisplayedFilters, "(%S+)+(%S+)");
			SpellTrackerDB.DisplayedFiltersInv = SpellTracker:StringFilteringInv(SpellTrackerDB.Params.DisplayedFilters, "(%S+)+(%S+)");
			SpellTrackerDB.ColumnFilter = {Count=0; QuickAcces={}};
			ret = true;
		end
	end
	return ret;
end
function SpellTracker:InitFilterFrame() -- 0.43 OK -- 0.54 bug fix ( btn.Used for compatibility with AutoResizeFilterFrame modify )
	if ( SpellTrackerFrameMainMenuTitleDisplayFilterSelectFrame ) then
		if ( not SpellTrackerFrameMainMenuTitleDisplayFilterSelectFrame.Buttons ) then
			local BtnName = "SpellTrackerFilterBtn";
			local lastBtn = nil;
			local btn = nil;
			for k=0, #SpellTrackerDB.DataStruct do
				local btnName = BtnName..tostring(k);
				btn = CreateFrame("Button", btnName, SpellTrackerFrameMainMenuTitleDisplayFilterSelectFrame, "SpellTrackerFilterButtonTemplate");
				if ( btn ) then
					SpellTrackerFrameMainMenuTitleDisplayFilterSelectFrame.Buttons = SpellTrackerFrameMainMenuTitleDisplayFilterSelectFrame.Buttons or {};
					SpellTrackerFrameMainMenuTitleDisplayFilterSelectFrame.Buttons[k] = btn;
					btn.idx = k;
					btn.Used = true; -- 0.54 bug fix
					btn.selected = false;
					local btnName = SpellTrackerDB.DataStruct[k];
					if ( btnName ) then
						btn.label.nameStr = SpellTrackerDB.DataStruct[k];
						btn.label:SetText(btn.label.nameStr);
						btn.help = SpellTrackerDB.DataStruct[k];
					end
					if ( k == 0 ) then
						btn:SetPoint("TOPLEFT", SpellTrackerFrameMainMenuTitleDisplayFilterSelectFrame, "TOPLEFT", 5, 0);
					else
						btn:SetPoint("TOPLEFT", lastBtn, "TOPRIGHT", -1, 0);
					end
					btn:Show();
					lastBtn = btn;
				end
			end
			if ( btn ) then btn.last = true; end -- 0.51 pour pas afficher de fleche au dernier bouton 
		end
	end
end
function SpellTracker:AutoResizeFilterFrame() -- 0.43 OK  -- 0.54 modified for dynamique filter
	if ( SpellTrackerFrameMainMenuTitleDisplayFilterSelectFrame ) then
		local FrameWidth = SpellTrackerFrameMainMenuTitleDisplayFilterSelectFrame:GetWidth();
		if ( SpellTrackerFrameMainMenuTitleDisplayFilterSelectFrame.Buttons ) then
			local CountBtn = 0;
			for k, btn in pairs(SpellTrackerFrameMainMenuTitleDisplayFilterSelectFrame.Buttons) do
				if ( btn.Used == true ) then 
					CountBtn = CountBtn + 1; -- +1 a cause du 0 
				end
			end
			local NewWidth = math.floor(FrameWidth/CountBtn);
			for index, btn in pairs(SpellTrackerFrameMainMenuTitleDisplayFilterSelectFrame.Buttons) do
				if ( btn ) then
					btn:SetWidth(NewWidth);
					if ( btn.label ) then
						SpellTracker:ModifyBtnLabelAccordingToFinalWidth(btn.label, NewWidth);
					end
				end
			end
		end
	end
end
function SpellTracker:ModifyBtnLabelAccordingToFinalWidth(btnLabel, finalWidth) -- 0.43 OK
	local name = btnLabel.nameStr;
	local substring;
	for length=#name, 1, -1 do
		substring = SpellTracker:utf8sub(name, 1, length);
		btnLabel:SetText(substring);
		if ( btnLabel:GetStringWidth() <= finalWidth ) then
			return;
		end
	end
end
function SpellTracker:utf8sub(str, start, numChars) -- 0.43 OK
	-- This function can be a substring of a UTF-8 string, properly
	-- handling UTF-8 codepoints. Rather than taking a start index and
	-- optionally an end index, it takes the string, the start index, and
	-- the number of characters to select from the string.
	--
	-- UTF-8 Reference:
	-- 0xxxxxx - ASCII character
	-- 110yyyxx - 2 byte UTF codepoint
	-- 1110yyyy - 3 byte UTF codepoint
	-- 11110zzz - 4 byte UTF codepoint
	local currentIndex = start
	while numChars > 0 and currentIndex <= #str do
		local char = string.byte(str, currentIndex)
		if char >= 240 then
			currentIndex = currentIndex + 4
		elseif char >= 225 then
			currentIndex = currentIndex + 3
		elseif char >= 192 then
			currentIndex = currentIndex + 2
		else
			currentIndex = currentIndex + 1
		end
		numChars = numChars - 1
	end
	return str:sub(start, currentIndex - 1);
end
function SpellTracker:UpdateDisplayedFiterFromButtons() -- 0.43 simplification OK -- 0.42 -- met a jour SpellTrackerDB.Params.DisplayedFilters en fonction de l'etat de selection des filtres -- 0.53 bug fix
	-- check les boutons de filtre et met ‡ jour la string SpellTrackerDB.Params.DisplayedFilters qui sera utilisÈ pour afficher les infos des barres
	local filterString = "";
	local btns = SpellTrackerFrameMainMenuTitleDisplayFilterSelectFrame.Buttons;
	for i=0, #btns do
		local cBtn = btns[i];
		if ( cBtn ) then
			if ( cBtn.selected ) then
				if ( i == 0 ) then
					filterString = filterString..cBtn.label.nameStr;
				else
					filterString = filterString.."+"..cBtn.label.nameStr;
				end
			end
		end
	end		
	SpellTrackerDB.Params.DisplayedFilters = filterString;
	SpellTrackerDB.DisplayedFilters = SpellTracker:StringFiltering(SpellTrackerDB.Params.DisplayedFilters, "(%S+)+(%S+)");
	SpellTrackerDB.DisplayedFiltersInv = SpellTracker:StringFilteringInv(SpellTrackerDB.Params.DisplayedFilters, "(%S+)+(%S+)");
	SpellTracker:ReComputeFilteredSpellList();
	
	-- 0.53 Bug fix : pour eviter qu'au changement de bouton on se retrouve de 1000 barre ‡ 100 barre et en position 1000, on recale la scrollbar pour la dernier barre
	if ( SpellTracker.ScrollValue > #SpellTracker.SpellListToSort) then 
		SpellTracker.ScrollValue = max(0, #SpellTracker.SpellListToSort-SpellTracker.CountBarDisplayed-1);
	end

	SpellTracker:UpdateFrame();							
end
function SpellTracker:old_DisplayedFiterButtonsToStringIndexer() -- 0.50 cree un indexer en fonction de l'etat de selection des filtres
	-- check les boutons de filtre et met ‡ jour la string SpellTrackerDB.Params.DisplayedFilters qui sera utilisÈ pour afficher les infos des barres
	local filterString = "";
	local btns = SpellTrackerFrameMainMenuTitleDisplayFilterSelectFrame.Buttons;
	for i=0, #btns do
		local cBtn = btns[i];
		if ( cBtn ) then
			if ( cBtn.selected ) then
				if ( i == 0 ) then
					filterString = filterString..cBtn.label.nameStr;
				else
					filterString = filterString..SpellTrackerDB.Separator..cBtn.label.nameStr;
				end
			end
		end
	end			
	return filterString;
end
function SpellTracker:UpdateButtonsFromDisplayedFiter() -- 0.43 simplfication OK -- 0.42 -- met a jour l'etat des boutons de selection des filtres en fonction de SpellTrackerDB.Params.DisplayedFilters
	local count = #SpellTrackerDB.DisplayedFilters;
	local btns = SpellTrackerFrameMainMenuTitleDisplayFilterSelectFrame.Buttons;
	SpellTracker:UpdateFilterButton(btns[count]);			
end
function SpellTracker:UpdateFilterButton(btn) -- 0.43 OK
	if ( btn ) then
		if ( btn.selected == false ) then -- alors on selction tout les boutons qui sont avant et on deseltionne ceux qui sont apres
			self.selected = true;
			--btn:LockHighlight();
			local btnPos = btn.idx;
			local btns = SpellTrackerFrameMainMenuTitleDisplayFilterSelectFrame.Buttons;
			for i=0, #btns do
				local cBtn = btns[i];
				if ( cBtn ) then
					if ( i <= btnPos ) then
						cBtn.selected = true;
						cBtn.selectedTex:Show();
						cBtn.arrowUp:Hide();
						if ( cBtn.last == true ) then cBtn.arrowDown:Hide(); -- 0.51 bug fix : arrow showed at startup
						else cBtn.arrowDown:Show(); end
						--cBtn:LockHighlight();
					else
						cBtn.selected = false;
						cBtn.selectedTex:Hide();
						cBtn.arrowUp:Hide();
						cBtn.arrowDown:Hide();
						--cBtn:UnlockHighlight();
					end
				end
			end
		else -- alors on deselectionne tout les boutons qui sont apres
			if ( btn.idx ) then -- bug fix
				local btnPos = btn.idx+1; -- on prends le bouton d'apres
				local btns = SpellTrackerFrameMainMenuTitleDisplayFilterSelectFrame.Buttons;
				for i=btnPos, #btns do
					local cBtn = btns[i];
					if ( cBtn ) then
						cBtn.selected = false;
						cBtn.selectedTex:Hide();
						cBtn.arrowUp:Hide();
						cBtn.arrowDown:Hide();
						--cBtn:UnlockHighlight();
					end
				end
			end
		end
	end
end
function SpellTracker:CalcEventsPerSec(refresh) -- calcul le nombre de tick de spell track log par second
	if ( refresh == nil or refresh == false ) then
		local tickTime = math.floor(GetTime());
		if ( tickTime == SpellTracker.EventPerSec_LastTickTime ) then -- tick ++
			SpellTracker.EventPerSec_Ticks = SpellTracker.EventPerSec_Ticks + 1;
		else -- new seconde
			--local newWidth = 70 + string.len(tostring(EventPerSec_Ticks))*5;
			if ( SpellTracker.EventPerSec_Ticks > SpellTrackerDB.Record.MaxEventPerSecValue ) then -- on enregistre le record de Event/s
				SpellTrackerDB.Record.MaxEventPerSecValue = SpellTracker.EventPerSec_Ticks;
			end
			SpellTracker:AdjustColorOfSpellTrackerMinimapButton();
			SpellTrackerMinimapButton_UpdateTitle(SpellTracker.EventPerSec_Ticks);
			SpellTracker.EventPerSec_Ticks = 0;
		end
		SpellTracker.EventPerSec_LastTickTime = tickTime;
	else -- on rafraichit juste
		if ( SpellTracker.EventPerSec_Ticks > 0 ) then
			local tickTime = math.floor(GetTime());
			if ( tickTime - SpellTracker.EventPerSec_LastTickTime > SpellTrackerDB.Params.EventPerSec_SeuilInSecBeforeReset ) then 
				SpellTracker.EventPerSec_Ticks = 0;
				SpellTrackerMinimapButton_UpdateTitle(SpellTracker.EventPerSec_Ticks);
				SpellTracker:AdjustColorOfSpellTrackerMinimapButton();
			end
		end
	end
end
function SpellTracker:AdjustColorOfSpellTrackerMinimapButton()
	if ( SpellTracker.EventPerSec_Ticks > 10 ) then -- Orange
		SpellTrackerMinimapButton.background:SetVertexColor(0.5,0.5,0,1);
		SpellTrackerMinimapButton.highlight:SetVertexColor(0.5,0.5,0,1);
	elseif ( SpellTracker.EventPerSec_Ticks > 100 ) then -- Rouge
		SpellTrackerMinimapButton.background:SetVertexColor(1,0,0,1);
		SpellTrackerMinimapButton.highlight:SetVertexColor(1,0,0,1);
	else -- rien
		SpellTrackerMinimapButton.background:SetVertexColor(0,1,0,1);
		SpellTrackerMinimapButton.highlight:SetVertexColor(0,1,0,1);
	end
	
	if ( SpellTracker.RefreshTime > 10 ) then -- Orange
		SpellTrackerMinimapButton.background:SetVertexColor(0.5,0.5,0,1);
		SpellTrackerMinimapButton.highlight:SetVertexColor(0.5,0.5,0,1);
	elseif ( SpellTracker.RefreshTime > 20 ) then -- Rouge
		SpellTrackerMinimapButton.background:SetVertexColor(1,0,0,1);
		SpellTrackerMinimapButton.highlight:SetVertexColor(1,0,0,1);
	else -- rien
		SpellTrackerMinimapButton.background:SetVertexColor(0,1,0,1);
		SpellTrackerMinimapButton.highlight:SetVertexColor(0,1,0,1);
	end
end
function SpellTracker:AdjustColorOfMainMenuTitle()
	-- bg tex color -- vert quand ca enregiste / rouge quand ca enregistre pas / orange quand la vue est en pause
	if ( SpellTrackerDB.Recording_Mode == 0 ) then
		SpellTrackerFrameMainMenuTitle.bg:SetVertexColor(1,0,0,1); -- rouge
	elseif ( SpellTrackerDB.Recording_Mode == 1 and SpellTrackerDB.ViewPlaying == 0 ) then
		SpellTrackerFrameMainMenuTitle.bg:SetVertexColor(1,0.4,0,1); -- orange
	elseif ( SpellTrackerDB.Recording_Mode == 1 and SpellTrackerDB.ViewPlaying == 1 ) then
		SpellTrackerFrameMainMenuTitle.bg:SetVertexColor(1,1,1,1); -- vert
	end
end
function SpellTracker:AdjustViewPauseRecordingMode()
	local TotalRefreshTime = (SpellTracker.RefreshTime*SpellTracker.EventPerSec_Ticks)/1000;
	--local TotalRefreshTime = (SpellTracker.RefreshTime)/1000;
	if ( TotalRefreshTime > 1 ) then -- Rouge si > a 1 sec
		--print(TotalRefreshTime);
		SpellTrackerDB.LastViewPlayingValue = SpellTrackerDB.ViewPlaying;
		SpellTrackerDB.ViewPlaying = 0; -- when frame is visible view updating paused
		SpellTracker_SetViewPlayingMode(SpellTrackerDB.ViewPlaying);
	else
		SpellTrackerDB.ViewPlaying = SpellTrackerDB.LastViewPlayingValue;
		SpellTracker_SetViewPlayingMode(SpellTrackerDB.ViewPlaying);
	end 
end
function SpellTracker:AutoRedimSpellTrackerFrame(CountDisplayedBar)
	SpellTrackerFrame.isMovingOrSizing = false;
	SpellTrackerFrame:StartSizing();
	-- on reajuste la valuer y a un mulitple de Hbarre + offsety
	local barHeight = SpellTrackerDB.Params.SpellBarHeight + 2; -- 2 == offset
	local minHeight = SpellTrackerFrameMainMenuTitle:GetHeight() + barHeight;
	if ( CountDisplayedBar == nil ) then 
		CountDisplayedBar = math.floor(SpellTrackerFrameContainer:GetHeight() / barHeight); 
		SpellTracker.CountBarDisplayed = CountDisplayedBar;
	end
	local newSpellTrackerFrameContainerHeight = CountDisplayedBar*barHeight;
	local newSpellTrackerFrameHeight = (SpellTrackerFrame:GetHeight() - SpellTrackerFrameContainer:GetHeight()) + newSpellTrackerFrameContainerHeight;
	if ( newSpellTrackerFrameHeight < minHeight ) then newSpellTrackerFrameHeight = minHeight; end
	SpellTrackerFrame:SetHeight(newSpellTrackerFrameHeight);
	SpellTrackerDB.Params.FrameHeight = newSpellTrackerFrameHeight;
	SpellTrackerFrame:StopMovingOrSizing();
	SpellTrackerFrame.isMovingOrSizing = nil;
	
	-- redim buttons on FilterFrame
	SpellTracker:AutoResizeFilterFrame();
end
function SpellTracker:CreateBar(frmName) -- 0.48 TreeIcon -- 0.51 bug fix about overlappiung of bar ( first white bar ) -- 0.77 report
	local mFrameContainerLevel = SpellTrackerFrameContainer:GetFrameLevel();
	
	local GuiBar = CreateFrame("Button", frmName, SpellTrackerFrame, "SpellTrackerBarTemplate");
        
	GuiBar:RegisterForClicks("AnyUp");
	
	GuiBar.GUI = {};

	GuiBar.GUI.SpellIconBtn = _G[frmName.."SpellIconBtn"];
	GuiBar.GUI.SpellIconBtn:SetFrameLevel(mFrameContainerLevel + 9);
	
	GuiBar.GUI.SpellIconBtnTex = _G[frmName.."SpellIconBtnTex"];
	
	GuiBar.GUI.ReportBtn = _G[frmName.."ReportBtn"];
	GuiBar.GUI.ReportBtn:SetFrameLevel(mFrameContainerLevel + 9);
	
	GuiBar.GUI.ReportBtn:SetScript("OnClick", SpellTrackerPopupReportDlgBtn_Click);
	
	GuiBar.GUI.TreeIcon = _G[frmName.."StatusBarSpellHitTreeIcon"];
	
	GuiBar.GUI.TreeSymbolLabel = _G[frmName.."StatusBarSpellHitTreeSymbolLabel"];
	GuiBar.GUI.TreeSymbolLabel:SetFont(FontPathTree.name, FontPathTree.size);
	GuiBar.GUI.SpellNameLabel = _G[frmName.."StatusBarSpellHitSpellNameLabel"];
	--GuiBar.GUI.SpellNameLabel:SetFont(FontPath.name, FontPath.size);
	GuiBar.GUI.SpellAmountLabel = _G[frmName.."StatusBarSpellHitSpellAmountLabel"];
	--GuiBar.GUI.SpellOverHitLabel = _G[frmName.."SpellOverHitLabel"];
	--GuiBar.GUI.SpellCritAmountLabel = _G[frmName.."SpellCritAmountLabel"];
	--GuiBar.GUI.SpellAbsorbAmountLabel = _G[frmName.."SpellAbsorbAmountLabel"];
	--GuiBar.GUI.SpellOverHitAndAbsorbAmount = _G[frmName.."SpellOverHitAndAbsorbAmountLabel"];
	--GuiBar.GUI.SpellCritAndAbsorbAmount = _G[frmName.."SpellCritAndAbsorbAmountLabel"];
	
	GuiBar.GUI.StatusBarSpellHit = _G[frmName.."StatusBarSpellHit"];
	GuiBar.GUI.StatusBarSpellHit:SetValue(0);
	GuiBar.GUI.StatusBarSpellHit:SetMinMaxValues(0, 100);
	GuiBar.GUI.StatusBarSpellHit:SetFrameLevel(mFrameContainerLevel + 8);
	
	GuiBar.GUI.StatusBarSpellCritAmountAndHit = _G[frmName.."StatusBarSpellCritAmountAndHit"];
	GuiBar.GUI.StatusBarSpellCritAmountAndHit:SetValue(0);
	GuiBar.GUI.StatusBarSpellCritAmountAndHit:SetMinMaxValues(0, 100);
	GuiBar.GUI.StatusBarSpellCritAmountAndHit:SetFrameLevel(mFrameContainerLevel + 7);
	
	GuiBar.GUI.StatusBarSpellCritAmount = _G[frmName.."StatusBarSpellCritAmount"];
	GuiBar.GUI.StatusBarSpellCritAmount:SetValue(0);
	GuiBar.GUI.StatusBarSpellCritAmount:SetMinMaxValues(0, 100);
	GuiBar.GUI.StatusBarSpellCritAmount:SetFrameLevel(mFrameContainerLevel + 6);
	
	GuiBar.GUI.StatusBarSpellOverHitAndCrit = _G[frmName.."StatusBarSpellOverHitAndCrit"];
	GuiBar.GUI.StatusBarSpellOverHitAndCrit:SetValue(0);
	GuiBar.GUI.StatusBarSpellOverHitAndCrit:SetMinMaxValues(0, 100);
	GuiBar.GUI.StatusBarSpellOverHitAndCrit:SetFrameLevel(mFrameContainerLevel + 5);
	
	GuiBar.GUI.StatusBarSpellOverHit = _G[frmName.."StatusBarSpellOverHit"];
	GuiBar.GUI.StatusBarSpellOverHit:SetValue(0);
	GuiBar.GUI.StatusBarSpellOverHit:SetMinMaxValues(0, 100);
	GuiBar.GUI.StatusBarSpellOverHit:SetFrameLevel(mFrameContainerLevel + 4);
	
	GuiBar.GUI.StatusBarSpellOverHitAndAbsorb = _G[frmName.."StatusBarSpellOverHitAndAbsorb"];
	GuiBar.GUI.StatusBarSpellOverHitAndAbsorb:SetValue(0);
	GuiBar.GUI.StatusBarSpellOverHitAndAbsorb:SetMinMaxValues(0, 100);
	GuiBar.GUI.StatusBarSpellOverHitAndAbsorb:SetFrameLevel(mFrameContainerLevel + 3);
	
	GuiBar.GUI.StatusBarSpellCritAndAbsorb = _G[frmName.."StatusBarSpellCritAndAbsorb"];
	GuiBar.GUI.StatusBarSpellCritAndAbsorb:SetValue(0);
	GuiBar.GUI.StatusBarSpellCritAndAbsorb:SetMinMaxValues(0, 100);
	GuiBar.GUI.StatusBarSpellCritAndAbsorb:SetFrameLevel(mFrameContainerLevel + 2);
	
	GuiBar.GUI.StatusBarSpellAbsorbAmount = _G[frmName.."StatusBarSpellAbsorbAmount"];
	GuiBar.GUI.StatusBarSpellAbsorbAmount:SetValue(0);
	GuiBar.GUI.StatusBarSpellAbsorbAmount:SetMinMaxValues(0, 100);
	GuiBar.GUI.StatusBarSpellAbsorbAmount:SetFrameLevel(mFrameContainerLevel + 1);
	
	if ( SpellTracker.StatusBarColors == nil ) then -- pour le tooltip de la barre
		SpellTracker.StatusBarColors = {};
		SpellTracker.StatusBarColors.SpellHitAmount = SpellTrackerBar_GetColorCodeFromStatusBarColor(GuiBar.GUI.StatusBarSpellHit)
		SpellTracker.StatusBarColors.SpellCritAmount = SpellTrackerBar_GetColorCodeFromStatusBarColor(GuiBar.GUI.StatusBarSpellCritAmount)
		SpellTracker.StatusBarColors.SpellCritAndOverAmount = SpellTrackerBar_GetColorCodeFromStatusBarColor(GuiBar.GUI.StatusBarSpellOverHitAndCrit)
		SpellTracker.StatusBarColors.SpellOverAmount = SpellTrackerBar_GetColorCodeFromStatusBarColor(GuiBar.GUI.StatusBarSpellOverHit)
		SpellTracker.StatusBarColors.SpellOverAndAbsorbAmount = SpellTrackerBar_GetColorCodeFromStatusBarColor(GuiBar.GUI.StatusBarSpellOverHitAndAbsorb)
		SpellTracker.StatusBarColors.SpellCritAndAbsorbAmount = SpellTrackerBar_GetColorCodeFromStatusBarColor(GuiBar.GUI.StatusBarSpellCritAndAbsorb)
		SpellTracker.StatusBarColors.SpellAbsorbAmount = SpellTrackerBar_GetColorCodeFromStatusBarColor(GuiBar.GUI.StatusBarSpellAbsorbAmount)
	end
    GuiBar.VAR = {};
	GuiBar.VAR.SpellIndexer = nil;
	GuiBar.VAR.SpellTracked = false; -- si le spell est demandÈ a traquer
	GuiBar.VAR.Used = false; -- indique si la barre affiche des donnÈes actuellment ( remeit ‡ false pendant le reset de la barre )
	
	GuiBar:SetBackdropColor(0.1, 0.1, 0.1, 0.9);
    GuiBar:SetBackdropBorderColor(0, 0, 0, 0);
	
	return GuiBar;
end
function SpellTracker:ResetBar(GuiBar) -- 0.48 TreeIcon -- 0.77 report
	if ( GuiBar ) then
		GuiBar.GUI.SpellIconBtn.SpellId = nil;
		
		GuiBar.GUI.TreeIcon:SetTexture(nil); 
		GuiBar.GUI.SpellIconBtnTex:SetTexture(nil); 
		GuiBar.GUI.ReportBtn:SetNormalTexture(nil);
		GuiBar.GUI.ReportBtn:SetHighlightTexture(nil);
	
		GuiBar.GUI.TreeSymbolLabel:SetText("");
		GuiBar.GUI.SpellNameLabel:SetText("");
		GuiBar.GUI.SpellAmountLabel:SetText("");
		
		GuiBar.GUI.StatusBarSpellHit:SetValue(0);
		GuiBar.GUI.StatusBarSpellCritAmountAndHit:SetValue(0);
		GuiBar.GUI.StatusBarSpellCritAmount:SetValue(0);
		GuiBar.GUI.StatusBarSpellOverHitAndCrit:SetValue(0);
		GuiBar.GUI.StatusBarSpellOverHit:SetValue(0);
		GuiBar.GUI.StatusBarSpellOverHitAndAbsorb:SetValue(0);
		GuiBar.GUI.StatusBarSpellCritAndAbsorb:SetValue(0);
		GuiBar.GUI.StatusBarSpellAbsorbAmount:SetValue(0);
		
		GuiBar.VAR.Used = false;
		GuiBar.VAR.IndexerOfParent = nil;
	end
end
function SpellTracker:InitFrame()
	local mFrameContainer = SpellTrackerFrameContainer;
	SpellTracker.CountBarDisplayed = math.floor(mFrameContainer:GetHeight() / (SpellTrackerDB.Params.SpellBarHeight + 2));
	SpellTracker:AutoRedimSpellTrackerFrame(SpellTracker.CountBarDisplayed);
	--print("SpellTracker.CountBarDisplayed=",SpellTracker.CountBarDisplayed);
	--SpellTrackerDB.Params.SrollStep = math.floor(SpellTracker.CountBarDisplayed/3); -- le nombre de barres qu'on peut afficher sur 3 est un bon ration mais que ce apsste
	
	local idx = 1;
	if ( #SpellTracker.BARS < SpellTracker.CountBarDisplayed ) then
		local countBarToCreate = SpellTracker.CountBarDisplayed; --SpellTrackerDB.Params.DefaultCountSpellsToTrack; Ètait dÈfini par parametrage avant et coutait pas mal de mÈmoire du coup
		for k=0,countBarToCreate do 
			local frmName = "SpellTrackerBar"..tostring(idx);
			if ( _G[frmName] == nil ) then -- si la barre a pas encore ÈtÈ crÈÈ on la crÈÈ / permet de s'assurer qu'on aura tujours un nombre de barres suffisant et en corÈlation avec la fenetre
				local Bar = SpellTracker:CreateBar(frmName);
				--Bar:Hide();
				SpellTracker.BARS[idx] = Bar;
			end
			idx = idx + 1;
		end
	else
		-- on montre celles qui doivent etre utilisÈe et on cache les autres
		for i=0, #SpellTracker.BARS do
			local frmName = "SpellTrackerBar"..tostring(i);
			if ( _G[frmName] ) then
				if ( i <= SpellTracker.CountBarDisplayed ) then
					_G[frmName]:Show(); 
				else
					_G[frmName]:Hide(); 
				end
			end
		end
	end
	
	local offsetY = -2;
    
	local ncolMax, nrowMax, itW, itH = 0, 0, 0, 0;
	local nrowMax = math.ceil(#SpellTracker.BARS);
	
	mFrameContainer:SetWidth(SpellTrackerFrame:GetWidth());
	
	local itW = mFrameContainer:GetWidth();
    local itH = SpellTrackerDB.Params.SpellBarHeight;
	
	local heightMax = nrowMax * itH + offsetY * nrowMax * -1;
	
	mFrameContainer:SetHeight(heightMax);
	
    local lastGuiBar = nil;
	for idx, guiBar in pairs(SpellTracker.BARS) do
		if ( guiBar ) then
			guiBar:SetParent(mFrameContainer);
			if ( lastGuiBar == nil ) then
				guiBar:SetPoint("TOPLEFT", mFrameContainer, "TOPLEFT", 0, 0);
			else
				guiBar:SetPoint("TOPLEFT", lastGuiBar, "BOTTOMLEFT", 0, offsetY);
			end
			guiBar:SetWidth(itW);
			guiBar:SetHeight(itH);
			lastGuiBar = guiBar;
		end
    end
	-- FilterFrame
	SpellTracker:InitFilterFrame();
	SpellTracker:AutoResizeFilterFrame();
	SpellTracker:UpdateButtonsFromDisplayedFiter();
end
function SpellTracker:CopyVar(varToCopy) -- quand je fait var2 = var1 les adresse des sous-object restent identique donc var1.toto = var2.toto
	local copiedVar = {};
    for k,v in pairs(varToCopy) do
        copiedVar[k] = v;
    end
	return copiedVar;
end
function SpellTracker:UpdateFilteredStructureAccordingToFilters() -- 0.57
	-- le but du jeu c'est de parcourir la bd et et des qu'on rentre dans une structure qui est visible dans la liste des filtre √† afficher on 
	local SpellStruct = SpellTrackerDB.SPELLS;
	SpellTrackerDB.FILTEREDSPELLS = {};
	SpellTrackerDB.FILTEREDSPELLS.count = 0;
	local saveStruct = nil;
    
    for k,v in pairs(SpellStruct) do
		if ( type(v) == "table" ) then
            if ( v.help ) then
                if ( string.match(SpellTrackerDB.Params.DisplayedFilters, v.help) ) then -- si la key est voulu ou continuu plus loins
                    SpellTracker:RecursExploringOfStructureAccordingToFilters(k, v, {}, 0, SpellTrackerDB.FILTEREDSPELLS);
                end
            end
		end
	end
end
function SpellTracker:RecursExploringOfStructureAccordingToFilters(key, struct, heritedStruct, NodeMode, baseStruct, indexerOfParent) -- 0.41 / rempli ou met √† jour SpellTrackerDB.FILTEREDSPELLS en fonction des filtres d'affichage et de la strucutre de donnee -- 0.49 Tree Node
    --print(key, struct, heritedStruct, NodeMode, baseStruct, indexerOfParent);
    if ( key and struct and heritedStruct ) then
        
        local newStruct = nil;
        
        if (  NodeMode == 0 ) then
            newStruct = SpellTracker:CopyVar(heritedStruct);
        elseif (  NodeMode == 2 ) then
            newStruct = SpellTracker:CopyVar(heritedStruct);
        else
            newStruct = {}; 
        end
        
        if ( SpellTrackerDB.DataStructInv[struct.help] < SpellTrackerDB.DataStructInv.count ) then newStruct.Expanded = struct.Expanded;
        else newStruct.Expanded = nil; end
        
        -- quand nodemode == 2 il faudrait invers√© index et indexerofparent
        -- SpellTrackerDB.FILTEREDSPELLS.mob.Nodes.Ilaris.Indexer = "Ilaris";
        -- SpellTrackerDB.FILTEREDSPELLS.mob.Nodes.Ilaris.IndexerOfParent = "REACTION_FRIENDLY@Tr√©ant@HEAL@Toucher gu√©risseur@player@REACTION_FRIENDLY";
        if ( NodeMode == 2 ) then
            if ( heritedStruct.Indexer ) then newStruct.Indexer = heritedStruct.Indexer..SpellTrackerDB.Separator..key; -- il faut un autre separator
            else newStruct.Indexer = key; end
        else
            if ( newStruct.Indexer ) then newStruct.Indexer = newStruct.Indexer..SpellTrackerDB.Separator..key; -- il faut un autre separator
            else newStruct.Indexer = key; end
        end
		
        if ( NodeMode == 1 ) then
            if ( heritedStruct.IndexerOfParent ) then newStruct.IndexerOfParent = heritedStruct.IndexerOfParent..SpellTrackerDB.Separator..heritedStruct.Indexer;
            else newStruct.IndexerOfParent = heritedStruct.Indexer; end
        elseif ( NodeMode == 2 ) then
            if ( indexerOfParent ) then newStruct.IndexerOfParent = indexerOfParent; end
            --print("RecursExploringOfStructureAccordingToFilters.indexerOfParent=",indexerOfParent);
        end
                
        if ( heritedStruct.Level ) then 
			if ( NodeMode < 2 ) then
				newStruct.Level = heritedStruct.Level + 1;
			end
        else newStruct.Level = 0; end
        
        newStruct[struct.help] = key;
        
		-- custom : spell attribut -- 0.59
		if ( struct.help == "SpellName" ) then
			newStruct.SpellIconTex = struct.SpellIconTex;
			newStruct.SpellId = struct.SpellId;
		end
		
		-- category
		SpellTrackerDB.ColumnFilter[struct.help] = SpellTrackerDB.ColumnFilter[struct.help] or {Count=0};
		SpellTrackerDB.ColumnFilter[struct.help][key] = SpellTrackerDB.ColumnFilter[struct.help][key] or 0; -- 0 == false / 1 == true / 2 == false + desactiv√© / 3 == true + d√©sactiv√©
		
		--SpellTrackerDB.CurrentSort  -- 0.66
		local CurrentSort = SpellTrackerDB.CurrentSort;
		local Pattern8 = "(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)";
		
		-- des enfants
        for k, v in pairs(struct) do
            if ( k and v ) then
                if ( type(v) == "table" and v.help ) then
                    if ( string.match(SpellTrackerDB.Params.DisplayedFilters, v.help) ) then
                        SpellTracker:RecursExploringOfStructureAccordingToFilters(k, v, newStruct, 0, baseStruct);
                    else
                        if ( NodeMode == 2 ) then
                            SpellTracker:RecursExploringOfStructureAccordingToFilters(k, v, newStruct, 2, baseStruct);
                        elseif ( struct.Expanded == 1 ) then
                            newStruct.Nodes = newStruct.Nodes or {};
                            SpellTracker:RecursExploringOfStructureAccordingToFilters(k, v, newStruct, 1, newStruct.Nodes);
                        elseif ( struct.Expanded == 2 ) then
                            newStruct.Nodes = newStruct.Nodes or {};
                            local AbsoluteIndexer = newStruct.Indexer;
							if ( newStruct.IndexerOfParent ) then AbsoluteIndexer = newStruct.IndexerOfParent..SpellTrackerDB.Separator..AbsoluteIndexer; end
                            --print("RecursExploringOfStructureAccordingToFilters.AbsoluteIndexer=",AbsoluteIndexer);
                            SpellTracker:RecursExploringOfStructureAccordingToFilters(k, v, {Level = newStruct.Level;}, 2, newStruct.Nodes, AbsoluteIndexer);
                        end
                    end
                else
                    if ( k == "AmountLine") then -- 0.66
						newStruct.AmountLine = v;
						newStruct.SortAmount = SpellTracker_MatchAndSelect(CurrentSort, v, Pattern8);
					elseif ( k == "BestLine" ) then -- 0.66
                        newStruct.BestLine = v;
						newStruct.SortBest = SpellTracker_MatchAndSelect(CurrentSort, v, Pattern8);
                    elseif ( k == "TickLine" ) then -- 0.66
                        newStruct.TickLine = v;
						newStruct.SortTick = SpellTracker_MatchAndSelect(CurrentSort, v, Pattern8);
                    end
                end
            end
        end
        
		newStruct.NodeType = NodeMode;
				
        -- on sauve
        if ( NodeMode == 0 ) then
            if ( SpellTrackerDB.DisplayedFiltersInv[struct.help] == SpellTrackerDB.DisplayedFiltersInv.count ) then
                --print("N0:"..newStruct.Indexer);
                baseStruct[newStruct.Indexer] = newStruct;                
                baseStruct.count = baseStruct.count or 0;
                baseStruct.count = baseStruct.count + 1; -- nombre
            end
        elseif ( NodeMode == 2 ) then
            --print("N2:"..newStruct.Indexer);
			if ( SpellTrackerDB.DataStructInv[struct.help] == SpellTrackerDB.DataStructInv.count ) then
				newStruct.Level = newStruct.Level + 1;
				baseStruct[newStruct.Indexer] = newStruct;
				baseStruct.count = baseStruct.count or 0;
				baseStruct.count = baseStruct.count + 1; -- nombre
			end
        else
            --print("N1:"..newStruct.Indexer);
            baseStruct[newStruct.Indexer] = newStruct;
            baseStruct.count = baseStruct.count or 0;
            baseStruct.count = baseStruct.count + 1; -- nombre
        end
    end
end
function SpellTracker:RecursExploreNodesToSortNodes(StructNodes)
	for k, v in pairs(StructNodes) do
		if ( type(v) == "table" ) then
            local localStruct = SpellTracker:CopyVar(v);
            localStruct.Nodes = nil;
            local ChildIndexer = localStruct.IndexerOfParent;
            SpellTrackerDB.NodesToSort[ChildIndexer] = SpellTrackerDB.NodesToSort[ChildIndexer] or { count = 0 }; -- 0.48
            table.insert(SpellTrackerDB.NodesToSort[ChildIndexer], localStruct); -- 0.48
            SpellTrackerDB.NodesToSort[ChildIndexer].count = SpellTrackerDB.NodesToSort[ChildIndexer].count + 1;
            if ( v.Nodes ) then
                SpellTracker:RecursExploreNodesToSortNodes(v.Nodes);
            end
			table.sort(SpellTrackerDB.NodesToSort[ChildIndexer], SortSpellList);
		end
	end
    --table.sort(SpellTrackerDB.NodesToSort[spellStruct.Indexer], SortSpellList);
end
function SpellTracker:ReComputeFilteredSpellList() -- recree la liste a afficher en fonction des filtre -- 0.47 ( calcul du temps d'execution de cette func ) -- 0.48 / Tree Node
	SpellTracker:UpdateFilteredStructureAccordingToFilters(); -- rempli SpellTrackerDB.FILTEREDSPELLS
	
	SpellTracker:FillListToSortAndNodeToSortFromColumnFilter();
end
function SpellTracker:FillListToSortAndNodeToSortFromColumnFilter(ReComputeFiltering) -- recree la liste a afficher en fonction des filtre -- 0.47 ( calcul du temps d'execution de cette func ) -- 0.48 / Tree Node -- 0.72 bug fix on string.match( cCFilterString, spellStruct[v] )
	local cCFilterString = "";
	
	SpellTracker.SpellListToSort = {};
	SpellTrackerDB.NodesToSort = {};
	
	for spellIndexer, spellStruct in pairs(SpellTrackerDB.FILTEREDSPELLS) do
        if ( spellIndexer and spellStruct ) then 
			if ( type(spellStruct) == "table" ) then
				local FindedInFilters = false;
				for k, v in ipairs(SpellTrackerDB.DisplayedFilters) do
					cCFilterString = SpellTrackerDB.ColumnFilter.QuickAcces[v] or "";
					if ( spellStruct[v] ) then -- 0.72 - bug ifx
						if ( string.match( cCFilterString, spellStruct[v] ) ) then -- column filtering
							FindedInFilters = true;
						end
					end
				end
				if ( FindedInFilters == true or SpellTrackerDB.ColumnFilter.Count == 0 ) then
					table.insert(SpellTracker.SpellListToSort, spellStruct);
					if ( spellStruct.Nodes ) then -- des enfants a extraire -- 0.48 childs extract
						SpellTracker:RecursExploreNodesToSortNodes(spellStruct.Nodes);
						--print("#SpellTrackerDB.NodesToSort["..spellStruct.Indexer.."] = "..tostring(#SpellTrackerDB.NodesToSort[spellStruct.Indexer]));
						table.sort(SpellTrackerDB.NodesToSort[spellStruct.Indexer], SortSpellList);
					end
				end
			end
        end
    end
	
	if ( SpellTrackerDB.ColumnFilter.Count > 0 or ReComputeFiltering == true) then -- on met √† jour la liste des filtres de colonne
		-- on desactive tout en base // -- 0 == false / 1 == true / 2 == false + desactiv√© / 3 == true + d√©sactiv√©
		for k, v in pairs(SpellTrackerDB.ColumnFilter) do
			if ( type(v) == "table" and k ~= "QuickAcces" ) then
				for kk, vv in pairs(v) do
					if ( kk ~= "Count" ) then
						if ( vv == 0 ) then SpellTrackerDB.ColumnFilter[k][kk] = 2;
						elseif ( vv == 1 ) then SpellTrackerDB.ColumnFilter[k][kk] = 3;
						end
					end
				end
			end
		end
		-- on reactive que ce qui est dans la liste tri√©s
		for k, v in ipairs (SpellTracker.SpellListToSort) do -- k = num, v = tbl
			for kk, vv in ipairs(SpellTrackerDB.DisplayedFilters) do -- k = num, v = string
				local val = v[vv]; -- vv = help / v[vv] = valeur de help
				if ( val ) then
					if ( val ~= "Count" ) then
						if ( SpellTrackerDB.ColumnFilter[vv][val] ) then
							if ( SpellTrackerDB.ColumnFilter[vv][val] == 2 ) then SpellTrackerDB.ColumnFilter[vv][val] = 0;
							elseif ( SpellTrackerDB.ColumnFilter[vv][val] == 3 ) then SpellTrackerDB.ColumnFilter[vv][val] = 1;
							end
						end
					end
				end
			end
		end
	end
	
    --print("#SpellTracker.SpellListToSort = "..tostring(#SpellTracker.SpellListToSort));
	table.sort(SpellTracker.SpellListToSort, SortSpellList);
end
function SpellTracker:RepeatString(s, n) -- 0.60 ( level delay )
	return n > 0 and s .. SpellTracker:RepeatString(s, n-1) or "" 
end
-- Sorting funcs -- SortSpellList
function SortSpellList_Amount(x,y) -- 0.66 / function detach of SpellTracker:ReComputeFilteredSpellList() for debug and verbose
	if ( x and y ) then
		if  ( x.SortAmount and y.SortAmount ) then return( x.SortAmount > y.SortAmount ) ;
		elseif ( x.SortAmount ) then return true; 
		elseif ( y.SortAmount ) then return false;
		elseif ( x.SpellName and y.SpellName ) then return ( x.SpellName < y.SpellName ) ;
		elseif ( x.Class and y.Class ) then return ( x.Class < y.Class ) ;
		end
	end
end
function SortSpellList_Tick(x,y) -- 0.66 / function detach of SpellTracker:ReComputeFilteredSpellList() for debug and verbose
	if ( x and y ) then
		if  ( x.SortTick and y.SortTick ) then return( x.SortTick > y.SortTick ) ;
		elseif ( x.SortTick ) then return true; 
		elseif ( y.SortTick ) then return false;
		elseif ( x.SpellName and y.SpellName ) then return ( x.SpellName < y.SpellName ) ;
		elseif ( x.Class and y.Class ) then return ( x.Class < y.Class ) ;
		end
	end
end
function SortSpellList_Best(x,y) -- 0.66 / function detach of SpellTracker:ReComputeFilteredSpellList() for debug and verbose
	if ( x and y ) then
		if  ( x.SortBest and y.SortBest ) then return( x.SortBest > y.SortBest ) ;
		elseif ( x.SortBest ) then return true; 
		elseif ( y.SortBest ) then return false;
		elseif ( x.SpellName and y.SpellName ) then return ( x.SpellName < y.SpellName ) ;
		elseif ( x.Class and y.Class ) then return ( x.Class < y.Class ) ;
		end
	end
end
function SpellTracker_MatchAndSelect(id, buf, ptn)
	local val = select(id, string.match(buf,ptn));
	--print(id, buf, val);
	if ( val ) then return tonumber(val); end
end
-- Update View Funcs
function SpellTracker:RefreshView()
	local t0 = debugprofilestop();
	SpellTracker:UpdateDisplayedFiterFromButtons();
	SpellTracker.RefreshTime = (debugprofilestop() - t0); -- ms
	SpellTrackerButton_UpdateTitle();
end
function SpellTracker:UpdateFrame() -- 0.41 / affiche simplement mais ne recalcule aucune liste -- 0.48 Tree Node -- 0.49 Tree Node -- 0.50
	for i, bar in pairs(SpellTracker.BARS) do
		if ( bar ) then
			if ( bar.VAR.Used ) then -- la barre est utlisÈe;
				SpellTracker:ResetBar(bar); -- on la reset, car sinon la cacher va provoquer une erreur blizard en combat
			end
		end
	end
				
	local SpellListToSort_Position = 1;
	local NodesToSort_Position = {};
	local idx = 1; 
	local CountAllChilds = 0;
	local Count_Position = 1;
	
	-- declarer la fonction dans la portÈe de Count_Position et CountAllChilds permet de les garder en variables locales
	-- pour l'execution de RecursUpdateNodes
	function RecursUpdateNodes(Indexer)
		for k, v in pairs(SpellTrackerDB.NodesToSort[Indexer]) do -- 0.48
			if ( type(v) == "table" ) then
				local ChildListToSort_Position = NodesToSort_Position[Indexer];
				if ( (Count_Position) >= SpellTracker.ScrollValue and (Count_Position) < (SpellTracker.ScrollValue + SpellTracker.CountBarDisplayed) ) then -- correspond a la position de la barre dÈsirÈe comme cela on n'affiche que les barres qui sont affichable -- gain mÈmoire donc
					local GuiBar = SpellTracker.BARS[idx]; -- stock des guibar
					idx = idx + 1;
					if ( GuiBar ) then
						local CountChild = #SpellTrackerDB.NodesToSort[Indexer];
						SpellTracker:UpdateGuiBar(GuiBar, v, SpellListToSort_Position, ChildListToSort_Position, CountChild); -- 0.48
						CountAllChilds = CountAllChilds + 1;
					end
				end
				NodesToSort_Position[Indexer] = NodesToSort_Position[Indexer] + 1;
				Count_Position = Count_Position + 1;
				-- on explore les enfants
				local ChildIndexer = Indexer..SpellTrackerDB.Separator..v.Indexer;
				if ( SpellTrackerDB.NodesToSort[ChildIndexer] ) then -- des enfants -- 0.48
					NodesToSort_Position[ChildIndexer]=1;
					RecursUpdateNodes(ChildIndexer);
				end
			end
		end
	end
	
	local GuiBar = nil;
	for spellIndexer, spellStruct in pairs(SpellTracker.SpellListToSort) do
		if ( spellIndexer and spellStruct ) then
			if ( type(spellStruct) == "table" ) then
				if ( (Count_Position) > SpellTracker.ScrollValue and (Count_Position) <= (SpellTracker.ScrollValue + SpellTracker.CountBarDisplayed) ) then -- correspond a la position de la barre dÈsirÈe comme cela on n'affiche que les barres qui sont affichable -- gain mÈmoire donc
					local GuiBar = SpellTracker.BARS[idx]; -- stock des guibar
					idx = idx + 1;
					if ( GuiBar ) then
						SpellTracker:UpdateGuiBar(GuiBar, spellStruct, SpellListToSort_Position); -- 0.48
					end
				end
				if ( SpellTrackerDB.NodesToSort[spellStruct.Indexer] ) then -- des enfants -- 0.48
					NodesToSort_Position[spellStruct.Indexer]=1;
					RecursUpdateNodes(spellStruct.Indexer);
				end
				SpellListToSort_Position = SpellListToSort_Position + 1;
				Count_Position = Count_Position + 1;
			end
		end
	end
	SpellTracker.CountBarToDisplay = Count_Position;--#SpellTracker.SpellListToSort + CountAllChilds; -- 0.48 // ajout de CountAllChilds pour SpellTrackerFrameContainerVirtualScrollBar_OnMouseWheel et donc la gestion de la virtualmousewheel
end
function SpellTracker:UpdateGuiBar(GuiBar, spellStruct, SpellListToSort_Position, ChildListToSort_Position, CountChild) -- 0.48 -- 0.55 type nodes -- 0.73 harmonisation des infos et display bug fix
	if ( GuiBar and spellStruct ) then
		if ( spellStruct.Expanded and spellStruct.Expanded > 0 ) then -- 0.48 / Tree Icon -- 0.55 was == true instead of > 0
			GuiBar.GUI.TreeIcon:SetTexture("Interface\\Buttons\\Arrow-Down-Up"); -- Tree Icon
		elseif ( spellStruct.Expanded and spellStruct.Expanded == 0 ) then -- 0.55 was false instead of 0
			GuiBar.GUI.TreeIcon:SetTexture("Interface\\MoneyFrame\\Arrow-Right-Up"); -- Tree Icon
		end

		GuiBar.GUI.ReportBtn:SetNormalTexture(nil);
		GuiBar.GUI.ReportBtn:SetHighlightTexture(nil);
	
		--GuiBar.GUI.ReportBtn:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-MOTD-Up");
		--GuiBar.GUI.ReportBtn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight");
	
		GuiBar.VAR.SpellIndexer = spellStruct.Indexer;

		GuiBar.VAR.SpellListToSort_Position = SpellListToSort_Position;
		GuiBar.VAR.ChildListToSort_Position	= ChildListToSort_Position; -- 0.48 / peut valoir nil mais c'est voulu

		local SpellStructParent;
		if ( spellStruct.IndexerOfParent ) then
			GuiBar.VAR.IndexerOfParent = spellStruct.IndexerOfParent;
			SpellStructParent = SpellTracker:GetFilteredSpellsStructByParsingOfIndexer(spellStruct.IndexerOfParent);
		end
		
        local HitType = SpellTracker:GetInfosFromStructOrParentStruct("HitType", spellStruct, SpellStructParent);
        local HitTypeString = "";
		local HitTypeColor = "";
		if ( HitType ) then
			if ( HitType == "HEAL" ) then HitTypeColor = SpellTrackerDB.Params.FriendlyColor; -- heal en vert
			elseif ( HitType == "DAMAGE" ) then  HitTypeColor = SpellTrackerDB.Params.HostileColor; -- degat en rouge
			else HitTypeColor = SpellTrackerDB.Params.NeutralColor; -- degat en orange
			end
			HitTypeString = " "..HitTypeColor..HitType;
		end
		
		local SourceClassName = spellStruct.SourceClass;
		if ( SpellTrackerDB.Dicos.ColorOfClass[SourceClassName] ) then 
			SourceClassName = SpellTrackerDB.Dicos.ColorOfClass[SourceClassName]..SourceClassName..SpellTrackerDB.Params.DefaultColor;
        end
		
		local TargetClassName = spellStruct.TargetClass;
		if ( SpellTrackerDB.Dicos.ColorOfClass[TargetClassName] ) then
			TargetClassName = SpellTrackerDB.Dicos.ColorOfClass[TargetClassName]..TargetClassName..SpellTrackerDB.Params.DefaultColor;
		end

		local SpellName  = "";
		local SpellId = "";
		if ( spellStruct.SpellName ) then
			GuiBar.GUI.SpellIconBtnTex:SetTexture(spellStruct.SpellIconTex); -- Spell Icon
			SpellName = spellStruct.SpellName;
			SpellId = spellStruct.SpellId;
			GuiBar.GUI.SpellIconBtn.SpellId = SpellId;
			GuiBar.GUI.SpellIconBtn.SpellName = SpellName;
			if ( spellStruct.TickSpellId ) then
				GuiBar.GUI.SpellIconBtn.TickSpellId = TickSpellId;
			end
			if ( HitTypeColor ) then -- hit color
                SpellName = " "..HitTypeColor..SpellName;
            end
			if ( spellStruct.CountTicks ) then
				SpellName = " "..HitTypeColor.."x"..tostring(spellStruct.CountTicks)..SpellName;
            end	
		end
		
		local TargetType = "";
		local TargetTypeName = "";
		if ( spellStruct.TargetType ) then
			if ( spellStruct.TargetType == "player" ) then TargetType = L["PLAYER_CHAR_SHORT"]; TargetTypeName = L["PLAYER_CHAR"];
			elseif ( spellStruct.TargetType == "mob" ) then TargetType = L["MOB_CHAR_SHORT"]; TargetTypeName = L["PLAYER_CHAR"];
			elseif ( spellStruct.TargetType == "vehicle" ) then TargetType = L["VEHICLE_CHAR_SHORT"]; TargetTypeName = L["PLAYER_CHAR"];
			elseif ( spellStruct.TargetType == "pet" ) then TargetType = L["PET_CHAR_SHORT"]; TargetTypeName = L["PLAYER_CHAR"];
			end
		end

		local SourceType = "";
		local SourceTypeName = "";
		if ( spellStruct.SourceType ) then
			if ( spellStruct.SourceType == "player" ) then SourceType = L["PLAYER_CHAR_SHORT"]; SourceTypeName = L["PLAYER_CHAR"];
			elseif ( spellStruct.SourceType == "mob" ) then SourceType = L["MOB_CHAR_SHORT"]; SourceTypeName = L["MOB_CHAR"];
			elseif ( spellStruct.SourceType == "vehicle" ) then SourceType = L["VEHICLE_CHAR_SHORT"]; SourceTypeName = L["VEHICLE_CHAR"];
			elseif ( spellStruct.SourceType == "pet" ) then SourceType = L["PET_CHAR_SHORT"]; SourceTypeName = L["PET_CHAR"];
			end
		end

		local SpellDirection = "";
		if ( SpellTrackerDB.Tracking_Mode == 1 ) then SpellDirection = " ==>";
		elseif ( SpellTrackerDB.Tracking_Mode == 2 ) then  SpellDirection = " <==";
		end

        local SourceReaction = SpellTracker:GetInfosFromStructOrParentStruct("SourceReaction", spellStruct, SpellStructParent);
        
		-- colorise en vert ou en rouge selon que la source soie hostile ou friendly
		local SourceName = "";
		if ( SourceReaction ) then
			if ( SourceReaction == "REACTION_HOSTILE" ) then -- Hostile
				if ( spellStruct.SourceName ) then SourceName = SpellTrackerDB.Params.HostileColor..spellStruct.SourceName; end
				if ( spellStruct.SourceType ) then SourceType = SpellTrackerDB.Params.HostileColor..SourceType; end
			    SourceReaction = "";
			elseif ( SourceReaction == "REACTION_FRIENDLY" ) then -- Hostile
				if ( spellStruct.SourceName ) then SourceName = SpellTrackerDB.Params.FriendlyColor..spellStruct.SourceName; end
				if ( spellStruct.SourceType ) then SourceType = SpellTrackerDB.Params.FriendlyColor..SourceType; end
                SourceReaction = "";
			elseif ( SourceReaction == "REACTION_NEUTRAL" ) then -- Hostile
				if ( spellStruct.SourceName ) then SourceName = SpellTrackerDB.Params.NeutralColor..spellStruct.SourceName; end
				if ( spellStruct.SourceType ) then SourceType = SpellTrackerDB.Params.NeutralColor..SourceType; end
			    SourceReaction = "";
			end
		else
			if ( spellStruct.SourceName ) then SourceName = SpellTrackerDB.Params.DefaultColor..spellStruct.SourceName; end
			if ( spellStruct.SourceType ) then SourceType = SpellTrackerDB.Params.DefaultColor..SourceType; end
		end

		SourceName = SourceName..SpellTrackerDB.Params.DefaultColor;
		SourceType = SourceType..SpellTrackerDB.Params.DefaultColor;
		
        local TargetReaction = SpellTracker:GetInfosFromStructOrParentStruct("TargetReaction", spellStruct, SpellStructParent);

		-- colorise en vert ou en rouge selon que la cible soie hostile ou friendly
		local TargetName = "";
		if ( TargetReaction ) then
			if ( TargetReaction == "REACTION_HOSTILE" ) then -- Hostile
				if ( spellStruct.TargetName ) then TargetName = SpellTrackerDB.Params.HostileColor..spellStruct.TargetName; end
				if ( spellStruct.TargetType ) then TargetType = SpellTrackerDB.Params.HostileColor..TargetType; end
                TargetReaction = "";
			elseif ( TargetReaction == "REACTION_FRIENDLY" ) then -- Hostile
				if ( spellStruct.TargetName ) then TargetName = SpellTrackerDB.Params.FriendlyColor..spellStruct.TargetName; end
				if ( spellStruct.TargetType ) then TargetType = SpellTrackerDB.Params.FriendlyColor..TargetType; end
                TargetReaction = "";
			elseif ( TargetReaction == "REACTION_NEUTRAL" ) then -- Hostile
				if ( spellStruct.TargetName ) then TargetName = SpellTrackerDB.Params.NeutralColor..spellStruct.TargetName; end
				if ( spellStruct.TargetType ) then TargetType = SpellTrackerDB.Params.NeutralColor..TargetType; end
			    TargetReaction = "";
			end
		else
			if ( spellStruct.TargetName ) then TargetName = SpellTrackerDB.Params.DefaultColor..spellStruct.TargetName; end
			if ( spellStruct.TargetType ) then TargetType = SpellTrackerDB.Params.DefaultColor..TargetType; end
		end
		
		TargetName = TargetName..SpellTrackerDB.Params.DefaultColor;
		TargetType = TargetType..SpellTrackerDB.Params.DefaultColor;
		
		local SpellNameLabel = "";
		local TreeSymbolLabel = "";
		
		-- on ajoute un decalage selon le lvl
		local FirstNode = "¬≤¬≥¬π";
		local MiddleNode = "¬º¬Ω¬π";		
		local LastNode = "¬≤¬Ω¬π";
		local baseLvl = #SpellTrackerDB.DisplayedFilters;
		local diffLvl = spellStruct.Level - (baseLvl+1);
		if ( ChildListToSort_Position and CountChild ) then
			local spacer = SpellTracker:RepeatString("  ", diffLvl);
			if ( ChildListToSort_Position == CountChild ) then
				TreeSymbolLabel = spacer..LastNode;
				SpellNameLabel = SpellNameLabel..spacer.."   ";
			else
				TreeSymbolLabel = spacer..MiddleNode;
				SpellNameLabel = SpellNameLabel..spacer.."   ";
			end
			if ( spellStruct.Expanded and spellStruct.Expanded > 0 ) then
				TreeSymbolLabel = spacer..FirstNode;
				SpellNameLabel = SpellNameLabel..spacer.."   ";
			end
		end
		
		if ( ChildListToSort_Position ) then -- 0.48 c'est un child
			TreeSymbolLabel = " "..tostring(ChildListToSort_Position).." "..TreeSymbolLabel; -- c (pour child 0.53 ) + numÍ≥Ø de l'enfant 
			SpellNameLabel = SpellTracker:RepeatString(" ", string.len(TreeSymbolLabel)+3);
		else
			TreeSymbolLabel = " "..tostring(SpellListToSort_Position).." "..TreeSymbolLabel; -- numÍ≥Ø de la barre
			SpellNameLabel = SpellTracker:RepeatString(" ", string.len(TreeSymbolLabel)+3);
		end; 
		
		local ReactionConv = {};
		ReactionConv["REACTION_FRIENDLY"] = SpellTrackerDB.Params.FriendlyColor..L["FRIEND"]..SpellTrackerDB.Params.DefaultColor;
		ReactionConv["REACTION_HOSTILE"] = SpellTrackerDB.Params.HostileColor..L["HOSTILE"]..SpellTrackerDB.Params.DefaultColor;
		ReactionConv["REACTION_NEUTRAL"] = SpellTrackerDB.Params.NeutralColor..L["NEUTRAL"]..SpellTrackerDB.Params.DefaultColor;
		
		if ( spellStruct.IndexerOfParent == nil ) then
			local lastIt = nil;
			local nextIt = nil;
			for i=0,#SpellTrackerDB.DataStruct do
				local item = SpellTrackerDB.DataStruct[i];
				if ( item ) then
					if ( string.match(SpellTrackerDB.Params.DisplayedFilters, item) ) then
						if ( i < #SpellTrackerDB.DataStruct ) then -- nextIt
							if ( string.match(SpellTrackerDB.Params.DisplayedFilters, SpellTrackerDB.DataStruct[i+1]) ) then nextIt = SpellTrackerDB.DataStruct[i+1]; end -- si nextIt est hors du filtre on le delete
						end
						if (lastIt ~= nil) then -- Spell Direction
							if ( string.find(lastIt,"Source") ~= nil and string.find(item,"Target") ~= nil ) then
								if (SpellTrackerDB.Tracking_Mode == 1 ) then
									SpellNameLabel = SpellNameLabel.." "..SpellTrackerDB.Params.DefaultColor..SpellDirection;
								else
									SpellNameLabel = SpellNameLabel.." /";
								end
							elseif ( string.find(lastIt,"Target") ~= nil and string.find(item,"Source") ~= nil ) then
								if ( SpellTrackerDB.Tracking_Mode == 2 ) then
									SpellNameLabel = SpellNameLabel.." "..SpellTrackerDB.Params.DefaultColor..SpellDirection;
								else
									SpellNameLabel = SpellNameLabel.." /";
								end
							end
						end
						if ( item == "SpellName" ) then
							local spellColor = "";
							if ( string.match(SpellTrackerDB.Params.DisplayedFilters, "HitType") ) then
								spellColor = tostring(HitTypeColor);
							end
							SpellNameLabel = SpellNameLabel..spellColor..tostring(SpellName);
							if ( spellStruct.CountTicks ) then
								SpellNameLabel = SpellNameLabel.." "..SpellTrackerDB.Params.DefaultColor.." x"..tostring(spellStruct.CountTicks); -- default color pour les ticks
							end
						elseif ( item == "HitType" ) then
							if (lastIt == nil and nextIt ~= "SpellName" ) then
								SpellNameLabel = SpellNameLabel.." "..HitTypeString;
							end
						elseif ( item == "TargetClass" ) then
							SpellNameLabel = SpellNameLabel.." "..tostring(TargetClassName);
						elseif ( item == "SourceClass" ) then
							SpellNameLabel = SpellNameLabel.." "..tostring(SourceClassName);
						elseif ( item == "SourceType" ) then -- Mob / Player / Pet / Vehicle*
							SpellNameLabel = SpellNameLabel.." "..tostring(SourceType);
						elseif ( item=="SourceReaction" ) then -- rÈaction de la source par rapport a mon perso
							if ( nextIt ~= nil and nextIt == "SourceName" ) then 
							elseif ( lastIt ~= nil and string.find(lastIt,"Source") == nil ) then
								SpellNameLabel = SpellNameLabel.." "..ReactionConv[tostring(spellStruct.SourceReaction)];
							end
						elseif ( item == "SourceName" ) then -- Name
							SpellNameLabel = SpellNameLabel.." "..tostring(SourceName);
						elseif ( item == "TargetType" ) then -- Mob / Player / Pet / Vehicle
							SpellNameLabel = SpellNameLabel.." "..tostring(TargetType);
						elseif ( item=="TargetReaction" ) then -- rÈaction de la cible par rapport a mon perso
							if ( nextIt ~= nil and nextIt == "TargetName" ) then 
							elseif ( lastIt ~= nil and string.find(lastIt,"Target") == nil ) then
								SpellNameLabel = SpellNameLabel.." "..ReactionConv[tostring(spellStruct.TargetReaction)];
							end
						elseif ( item == "TargetName" ) then -- Name
							SpellNameLabel = SpellNameLabel.." "..tostring(TargetName);
						end
					end
				end
				lastIt = item;
			end
		elseif ( spellStruct.NodeType == 2 ) then -- node from child to end
			local lastIt = nil;
			for i=0,#SpellTrackerDB.DataStruct do
				local item = SpellTrackerDB.DataStruct[i];
				if ( item ) then
					if ( not string.match(SpellTrackerDB.Params.DisplayedFilters, item) ) then
						if (lastIt ~= nil) then -- Spell Direction
							if ( string.find(lastIt,"Source") ~= nil and string.find(item,"Target") ~= nil ) then
								SpellNameLabel = SpellNameLabel.." "..SpellTrackerDB.Params.DefaultColor..SpellDirection;
							elseif ( string.find(lastIt,"Target") ~= nil and string.find(item,"Source") ~= nil ) then
								SpellNameLabel = SpellNameLabel.." "..SpellTrackerDB.Params.DefaultColor..SpellDirection;
							end
						end
						if ( item == "SpellName" ) then
							local spellColor = "";
							if ( string.match(SpellTrackerDB.Params.DisplayedFilters, "HitType") ) then
								spellColor = tostring(HitTypeColor);
							end
							SpellNameLabel = SpellNameLabel.." "..spellColor..tostring(SpellName);
							if ( spellStruct.CountTicks ) then
								SpellNameLabel = SpellNameLabel.." "..SpellTrackerDB.Params.DefaultColor.." x"..tostring(spellStruct.CountTicks); -- default color pour les ticks
							end
						elseif ( item == "HitType" ) then
							if (lastIt == nil and nextIt ~= "SpellName" ) then
								SpellNameLabel = SpellNameLabel.." "..HitTypeString;
							end
						elseif ( item == "TargetClass" and TargetClassName ) then
							SpellNameLabel = SpellNameLabel.." "..tostring(TargetClassName);
						elseif ( item == "SourceClass" and SourceClassName ) then
							SpellNameLabel = SpellNameLabel.." "..tostring(SourceClassName);
						elseif ( item == "SourceType" and SourceType ) then -- Mob / Player / Pet / Vehicle*
							SpellNameLabel = SpellNameLabel.." "..tostring(SourceType);
						elseif ( item=="SourceReaction" and SourceReaction ) then -- rÍ¢£tion de la source par rapport a mon perso
							SpellNameLabel = SpellNameLabel.." "..tostring(SourceReaction);
						elseif ( item == "SourceName" and SourceName ) then -- Name
							SpellNameLabel = SpellNameLabel.." "..tostring(SourceName);
						elseif ( item == "TargetType" and TargetType ) then -- Mob / Player / Pet / Vehicle
							SpellNameLabel = SpellNameLabel.." "..tostring(TargetType);
						elseif ( item=="TargetReaction" and TargetReaction ) then -- rÍ¢£tion de la cible par rapport a mon perso
							SpellNameLabel = SpellNameLabel.." "..tostring(TargetReaction);
						elseif ( item == "TargetName" and TargetName ) then -- Name
							SpellNameLabel = SpellNameLabel.." "..tostring(TargetName);
						end
					end
				end
				lastIt = item;
			end
		else -- un child
			if ( spellStruct.CountTicks ) then
				SpellNameLabel = SpellNameLabel.." "..SpellTrackerDB.Params.DefaultColor.." x"..tostring(spellStruct.CountTicks); -- default color pour les ticks
			end
			if ( spellStruct.HitType ) then SpellNameLabel = SpellNameLabel.." "..L["HIT_TYPE"]..(HitTypeString or ""); end
			if ( spellStruct.SpellName ) then SpellNameLabel = SpellNameLabel.." "..(HitTypeColor or "")..tostring(SpellName); end
			if ( spellStruct.SourceType ) then SpellNameLabel = SpellNameLabel.." "..L["SRC_TYPE"].." "..tostring(SourceTypeName); end
			if ( spellStruct.SourceClass ) then SpellNameLabel = SpellNameLabel.." "..L["SRC_CLASS"].." "..tostring(SourceClassName); end
			if ( spellStruct.SourceReaction ) then SpellNameLabel = SpellNameLabel.." "..L["SRC_REACTION"].." "..ReactionConv[tostring(spellStruct.SourceReaction)]; end
			if ( spellStruct.SourceName ) then SpellNameLabel = SpellNameLabel.." "..L["SRC_NAME"].." "..tostring(SourceName) end
			if ( spellStruct.TargetClass ) then SpellNameLabel = SpellNameLabel.." "..L["TGT_CLASS"].." "..tostring(TargetClassName); end
			if ( spellStruct.TargetType ) then SpellNameLabel = SpellNameLabel.." "..L["TGT_TYPE"].." "..tostring(TargetTypeName); end
			if ( spellStruct.TargetReaction ) then SpellNameLabel = SpellNameLabel.." "..L["TGT_REACTION"].." "..ReactionConv[tostring(spellStruct.TargetReaction)]; end
			if ( spellStruct.TargetName ) then SpellNameLabel = SpellNameLabel.." "..L["TGT_NAME"].." "..tostring(TargetName); end
		end
		
		GuiBar.GUI.TreeSymbolLabel:SetText(	TreeSymbolLabel );
		GuiBar.GUI.SpellNameLabel:SetText( SpellNameLabel );
		
		if ( SpellTrackerDB.NumLineDisplay == 0 ) then SpellTracker:DisplayLineOnBarsFromBuffer(GuiBar, spellStruct.AmountLine); -- Amount
		elseif ( SpellTrackerDB.NumLineDisplay == 1 ) then SpellTracker:DisplayLineOnBarsFromBuffer(GuiBar, spellStruct.TickLine); -- Tick
		elseif ( SpellTrackerDB.NumLineDisplay == 2 ) then SpellTracker:DisplayLineOnBarsFromBuffer(GuiBar, spellStruct.BestLine); -- Best
		end
		
		GuiBar.VAR.Used = true;
	end
end
function SpellTracker:DisplayLineOnBarsFromBuffer(GuiBar, buffer) -- show amount bars -- 0.66
-- AMMOUNT LINE
	-- On recupe les donnÍ¶≥ Amount / 0.40
	local LocalStruct = {};
	if ( buffer ) then
		local StatBarColor = SpellTracker.StatusBarColors;
	
		--print("buffer=",buffer);
		LocalStruct.SpellTotal,
			LocalStruct.SpellHit, LocalStruct.SpellCrit, 
			LocalStruct.SpellCritAndOver, LocalStruct.SpellOver, 
			LocalStruct.SpellOverAndAbsorb, LocalStruct.SpellCritAndAbsorb, LocalStruct.SpellAbsorb
			= string.match(buffer, "(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)");
		LocalStruct.SpellTotal = tonumber(LocalStruct.SpellTotal);
		LocalStruct.SpellHit = tonumber(LocalStruct.SpellHit);
		LocalStruct.SpellCrit = tonumber(LocalStruct.SpellCrit);
		LocalStruct.SpellCritAndOver = tonumber(LocalStruct.SpellCritAndOver);
		LocalStruct.SpellOver = tonumber(LocalStruct.SpellOver);
		LocalStruct.SpellOverAndAbsorb = tonumber(LocalStruct.SpellOverAndAbsorb);
		LocalStruct.SpellCritAndAbsorb = tonumber(LocalStruct.SpellCritAndAbsorb);
		LocalStruct.SpellAbsorb = tonumber(LocalStruct.SpellAbsorb);
		local tmp = {};
		local LineString = "";
		
		if ( SpellTrackerDB.Context == 0 ) then -- contexte
			tmp[1]=SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellTotal);
			tmp[2]=StatBarColor.SpellHitAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellHit);
			tmp[3]=StatBarColor.SpellCritAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellCrit);
			tmp[4]=StatBarColor.SpellCritAndOverAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellCritAndOver);
			tmp[5]=StatBarColor.SpellOverAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellOver);
			tmp[6]=StatBarColor.SpellOverAndAbsorbAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellOverAndAbsorb);
			tmp[7]=StatBarColor.SpellCritAndAbsorbAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellCritAndAbsorb);
			tmp[8]=StatBarColor.SpellAbsorbAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellAbsorb);
			tmp[SpellTrackerDB.CurrentSort] = "|r["..tmp[SpellTrackerDB.CurrentSort].."|r]";
			LineString = tmp[1].."/"..tmp[2].."/"..tmp[3].."/"..tmp[4].."/"..tmp[5].."/"..tmp[6].."/"..tmp[7].."/"..tmp[8];
		elseif ( SpellTrackerDB.Context == 1 ) then -- hors contexte
			tmp[1]=SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellTotal);
			tmp[2]=StatBarColor.SpellHitAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellHit+LocalStruct.SpellOver+LocalStruct.SpellOverAndAbsorb);
			tmp[3]=StatBarColor.SpellCritAmount..SpellTrackerBar_FormatAmountValueToString(LocalStruct.SpellCrit+LocalStruct.SpellCritAndOver+LocalStruct.SpellCritAndAbsorb);
			local curSort = SpellTrackerDB.CurrentSort;
			if ( curSort == 2 or curSort == 5 or curSort == 6 ) then
				tmp[2] = "|r["..tmp[2].."|r]";
			elseif ( curSort == 3 or curSort == 4 or curSort == 7 ) then
				tmp[3] = "|r["..tmp[3].."|r]";
			end
			LineString = tmp[1].."/"..tmp[2].."/"..tmp[3];
		end
		
		GuiBar.GUI.SpellAmountLabel:SetText(LineString);
	end
	if ( LocalStruct.SpellTotal ) then
		if ( LocalStruct.SpellTotal > 0 ) then
			local Hit = LocalStruct.SpellHit*100/LocalStruct.SpellTotal;
			local Crit = LocalStruct.SpellCrit*100/LocalStruct.SpellTotal;
			local OverHitAndCrit = LocalStruct.SpellCritAndOver*100/LocalStruct.SpellTotal;
			local OverHit = LocalStruct.SpellOver*100/LocalStruct.SpellTotal;
			local OverHitAndAbsorb = LocalStruct.SpellOverAndAbsorb*100/LocalStruct.SpellTotal;
			local CritAndAbsorb = LocalStruct.SpellCritAndAbsorb*100/LocalStruct.SpellTotal;
			
			if ( SpellTrackerDB.Context == 0 ) then -- contexte
				GuiBar.GUI.StatusBarSpellHit:SetValue(Hit);
				GuiBar.GUI.StatusBarSpellCritAmount:SetValue(Crit+Hit);
				GuiBar.GUI.StatusBarSpellOverHitAndCrit:SetValue(OverHitAndCrit+Crit+Hit);
				GuiBar.GUI.StatusBarSpellOverHit:SetValue(OverHit+OverHitAndCrit+Crit+Hit);
				GuiBar.GUI.StatusBarSpellOverHitAndAbsorb:SetValue(OverHitAndAbsorb+OverHit+OverHitAndCrit+Crit+Hit);
				GuiBar.GUI.StatusBarSpellCritAndAbsorb:SetValue(CritAndAbsorb+OverHitAndAbsorb+OverHit+OverHitAndCrit+Crit+Hit);
			elseif ( SpellTrackerDB.Context == 1 ) then -- hors contexte
				GuiBar.GUI.StatusBarSpellHit:SetValue(Hit+OverHit+OverHitAndAbsorb);
				GuiBar.GUI.StatusBarSpellCritAmount:SetValue(Hit+OverHit+OverHitAndAbsorb+Crit+OverHitAndCrit+CritAndAbsorb);
			end
		end
	end
	GuiBar.GUI.StatusBarSpellAbsorbAmount:SetValue(100);
	
end
-- Infos Fight
function SpellTracker:IsInCombat() -- 0.74 +> change for 6.0.2
	return UnitAffectingCombat("player");
end
function SpellTracker:GetInfosFromStructOrParentStruct(itemStr, struct, structParent)
    local item;
    if ( struct and itemStr ) then
        item = struct[itemStr];
        if ( struct[itemStr] == nil and structParent ) then
            if ( structParent[itemStr] ) then
                item = structParent[itemStr];
            end
        end
    end
    return item;
end
function SpellTracker:StartFight() -- 0.47 regen disabled so fight starting
	SpellTracker:EndFrameResize(); -- 0.53 on met fin a une eventuelle action de redimentionnement pour eviter le blocage de la manip a la souris sur toute l'interface (CRITIC CAT1)
	
	SpellTrackerDB.LastViewPlayingValue = SpellTrackerDB.ViewPlaying;
	SpellTrackerDB.ViewPlaying = 0; -- when frame is visible view updating paused
	SpellTracker_SetViewPlayingMode(SpellTrackerDB.ViewPlaying);
end
function SpellTracker:EndFight() -- 0.47 regen enabled so fight ending
	SpellTrackerDB.ViewPlaying = SpellTrackerDB.LastViewPlayingValue;
	SpellTracker_SetViewPlayingMode(SpellTrackerDB.ViewPlaying);
	if ( SpellTrackerFrame ) then
		if ( SpellTrackerFrame:IsVisible() ) then
			SpellTracker:ReComputeFilteredSpellList();
			SpellTracker:UpdateFrame();
		end
	end
end
function SpellTracker:StringFiltering(strToFilter, pattern) -- 0.41 / pour separer les valeur du style : HitType > SpellName > SourceType > SourceReaction en list indexe par int
	local ret = {};
	
	if ( strToFilter and pattern ) then
		local lst = {};
		local idx = 0;
		while ( string.match(strToFilter, pattern) ) do
			strToFilter, it = string.match(strToFilter,pattern);
			lst[idx] = it;
			idx = idx + 1;
		end
		lst[idx] = strToFilter;
		
		-- on inverse
		for i=0,idx do
			ret[i] = lst[idx-i];
		end
	else
		print("ERROR : SpellTracker StringFilteringInv string args == nil");
	end
	return ret;
end
function SpellTracker:StringFilteringInv(strToFilter, pattern) -- 0.41 / pour separer les valeur du style : HitType > SpellName > SourceType > SourceReaction en list indexe par nom
	local lst = {};
	
	if ( strToFilter and pattern) then
		local idx = 0;
		while ( string.match(strToFilter, pattern) ) do
			strToFilter, it = string.match(strToFilter,pattern);
			lst[it] = idx;
			idx = idx + 1;
		end
		lst[strToFilter] = idx;
		
		-- on inverse
		for k,v in pairs(lst) do
			lst[k] = idx-tonumber(v);
		end
		lst.count = idx; -- important car #lst d'une liste type dico renvoi rien du tout sauf si les index sont des number
	else
		print("ERROR : SpellTracker StringFilteringInv string args == nil");
	end
	return lst;
end
function SpellTracker:WhatIsThisFlag(flag)
	if ( flag == nil )  then return; end
	if ( flag == 0 )  then return; end
	
    -- on sort quatre infos utile : TYPE CONTROL REACTION AFFILIATION
	local flagType, flagControl, flagReaction, flagAffiliation;

	if ( bit.band(flag, 0x00004000) > 0 ) then flagType = SpellTracker.CombatFlags[0x00004000]; end -- TYPE_OBJECT
	if ( bit.band(flag, 0x00002000) > 0 ) then flagType = SpellTracker.CombatFlags[0x00002000]; end -- TYPE_GUARDIAN
	if ( bit.band(flag, 0x00001000) > 0 ) then flagType = SpellTracker.CombatFlags[0x00001000]; end -- TYPE_PET
	if ( bit.band(flag, 0x00000800) > 0 ) then flagType = SpellTracker.CombatFlags[0x00000800]; end -- TYPE_NPC
	if ( bit.band(flag, 0x00000400) > 0 ) then flagType = SpellTracker.CombatFlags[0x00000400]; end -- TYPE_PLAYER
	
	if ( bit.band(flag, 0x00000200) > 0 ) then flagControl = SpellTracker.CombatFlags[0x00000200]; end -- CONTROL_NPC
	if ( bit.band(flag, 0x00000100) > 0 ) then flagControl = SpellTracker.CombatFlags[0x00000100]; end -- CONTROL_PLAYER
	
	if ( bit.band(flag, 0x00000040) > 0 ) then flagReaction = SpellTracker.CombatFlags[0x00000040]; end -- REACTION_HOSTILE
	if ( bit.band(flag, 0x00000020) > 0 ) then flagReaction = SpellTracker.CombatFlags[0x00000020]; end -- REACTION_NEUTRAL
	if ( bit.band(flag, 0x00000010) > 0 ) then flagReaction = SpellTracker.CombatFlags[0x00000010]; end -- REACTION_FRIENDLY
	
    if ( bit.band(flag, 0x00000008) > 0 ) then flagAffiliation = SpellTracker.CombatFlags[0x00000008]; end -- AFFILIATION_OUTSIDER
	if ( bit.band(flag, 0x00000004) > 0 ) then flagAffiliation = SpellTracker.CombatFlags[0x00000004]; end -- AFFILIATION_RAID
	if ( bit.band(flag, 0x00000002) > 0 ) then flagAffiliation = SpellTracker.CombatFlags[0x00000002]; end -- AFFILIATION_PARTY
	if ( bit.band(flag, 0x00000001) > 0 ) then flagAffiliation = SpellTracker.CombatFlags[0x00000001]; end -- AFFILIATION_MINE

    return flagType, flagControl, flagReaction, flagAffiliation;
end
function SpellTracker:WhatIsThisGuid(GUIDNumber) -- 0.74 +> change for 6.0.2
	local ret = "Unknow";
	if ( GUIDNumber and GUIDNumber ~= "" ) then
		if ( string.find(tostring(GUIDNumber), "Player") ~= nil ) then -- "Creature", "Pet", "GameObject", and "Vehicle"
			ret = "player";
		elseif ( string.find(tostring(GUIDNumber), "Creature") ~= nil ) then
			ret = "mob";
		elseif ( string.find(tostring(GUIDNumber), "Pet") ~= nil ) then
			ret = "Pet";
		elseif ( string.find(tostring(GUIDNumber), "GameObject") ~= nil ) then
			ret = "object";
		elseif ( string.find(tostring(GUIDNumber), "Vehicle") ~= nil ) then
			ret = "vehicle";
		end
	end
	return ret;
end
function SpellTracker:COMBAT_LOG_EVENT_UNFILTERED(_,DATETIME, EVENTTYPE, hideCaster, GUIDSRC, SRC, SRCFLAG1, SRCFLAG2, GUIDDST, DST, DSTFLAG1, DSTFLAG2, ...)
	local TargetType, GUID = nil, TargetName, SourceName, SourceType, SourceClass, TargetClass;
	
	local ret = nil;
	-- on donne pas suite si le guid est pas prÈsent dans le raid
	local PartyTrackingContinue = false;
	
	if ( SpellTrackerDB.Tracking_Target == 4 ) then -- Raid Tracking Active
		RaidTrackingContinue = false;
		if ( SpellTracker.RaidLst[GUIDSRC] or SpellTracker.RaidLst[GUIDDST] ) then
			RaidTrackingContinue = true;
		end
		if ( RaidTrackingContinue == false ) then
			return nil;
		end
	end

	-- on donne pas suite si le guid est pas prÈsent dans le groupe
	if ( SpellTrackerDB.Tracking_Target == 5 ) then -- Party Tracking Active
		PartyTrackingContinue = false;
		if ( SpellTracker.PartyLst[GUIDSRC] or SpellTracker.PartyLst[GUIDDST] ) then
			PartyTrackingContinue = true;
		end
		if ( PartyTrackingContinue == false ) then
			return nil;
		end
	end
	
	local ClassType = "";
	if ( SpellTrackerDB.Tracking_Mode == 1 ) then
		GUID = GUIDSRC;
		SourceType = SpellTracker:WhatIsThisGuid(GUIDSRC);
		if ( SourceType ~= "Unknow" ) then _, SourceClass, _, _, _ = GetPlayerInfoByGUID(GUIDSRC); end
		SourceName = tostring(SRC);
		TargetType = SpellTracker:WhatIsThisGuid(GUIDDST);
		if ( TargetType ~= "Unknow" ) then _, TargetClass, _, _, _ = GetPlayerInfoByGUID(GUIDDST); end
		TargetName = tostring(DST);
	elseif ( SpellTrackerDB.Tracking_Mode == 2 ) then
		GUID = GUIDDST;
		SourceType = SpellTracker:WhatIsThisGuid(GUIDDST);
		if ( SourceType ~= "Unknow" ) then _, SourceClass, _, _, _ = GetPlayerInfoByGUID(GUIDDST); end
		SourceName = tostring(DST);
		TargetType = SpellTracker:WhatIsThisGuid(GUIDSRC);
		if ( TargetType ~= "Unknow" ) then _, TargetClass, _, _, _ = GetPlayerInfoByGUID(GUIDSRC); end
		TargetName = tostring(SRC);
	end
        
	if ( SourceClass ) then SpellTrackerDB.Dicos.Class[SourceClass] = locClass; else SourceClass = "PNJ"; end
	if ( TargetClass ) then SpellTrackerDB.Dicos.Class[TargetClass] = locClass; else TargetClass = "PNJ"; end

	if ( SpellTrackerDB.CurrentPlayerTracked.GUID ) then
		if ( GUID == SpellTrackerDB.CurrentPlayerTracked.GUID ) then
			local struct = SpellTracker:ReFormatEvent(DATETIME, EVENTTYPE, hideCaster, GUIDSRC, SRC, SRCFLAG1, SRCFLAG2, GUIDDST, DST, DSTFLAG1, DSTFLAG2, ...);
			if ( struct ) then
				SpellTracker:UpdateSpell(SourceClass, SourceType, SourceName, TargetClass, TargetType, TargetName, struct);
			end
		end
	else -- zone tracking enabled
		local struct = SpellTracker:ReFormatEvent(DATETIME, EVENTTYPE, hideCaster, GUIDSRC, SRC, SRCFLAG1, SRCFLAG2, GUIDDST, DST, DSTFLAG1, DSTFLAG2, ...);
		if ( struct ) then
			SpellTracker:UpdateSpell(SourceClass, SourceType, SourceName, TargetClass, TargetType, TargetName, struct);
		end
	end
end
function SpellTracker:ReFormatEvent(DATETIME, EVENTTYPE, hideCaster, GUIDSRC, SRC, SRCFLAG1, SRCFLAG2, GUIDDST, DST, DSTFLAG1, DSTFLAG2, ...)
	local Struct = nil;
	if ( EVENTTYPE == "SPELL_DAMAGE" ) then -- domage de sort
		Struct = {};
		Struct.SPELLID, Struct.SPELLNAME, Struct.SPELLSCHOOL, 
		Struct.AMOUNT, Struct.OVERKILL,
		Struct.SCHOOL, Struct.RESISTED,	Struct.BLOCKED,	
		Struct.ABSORBED, Struct.CRITICAL, Struct.GLANCING, Struct.CRUSHING = ...;
		Struct.EVENTTYPE = EVENTTYPE;
		Struct.HITTYPE = "DAMAGE";
		Struct.TYPE = "DAMAGE SPELL";
	elseif ( EVENTTYPE == "SPELL_PERIODIC_DAMAGE" ) then -- dommage de sort en tick genre dot fievre de givre
		Struct = {};
		Struct.SPELLID, Struct.SPELLNAME, Struct.SPELLSCHOOL, 
		Struct.AMOUNT, Struct.OVERKILL,
		Struct.SCHOOL, Struct.RESISTED, Struct.BLOCKED,	
		Struct.ABSORBED, Struct.CRITICAL, Struct.GLANCING, Struct.CRUSHING = ...;
		Struct.EVENTTYPE = EVENTTYPE;
		Struct.HITTYPE = "DAMAGE";
		Struct.TYPE = "DAMAGE SPELL TICK";
	elseif ( EVENTTYPE == "SWING_DAMAGE" ) then -- coup blanc
		Struct = {};
		Struct.AMOUNT, Struct.OVERKILL,
		Struct.SCHOOL, Struct.RESISTED,	Struct.BLOCKED,	
		Struct.ABSORBED, Struct.CRITICAL, Struct.GLANCING, Struct.CRUSHING = ...;
		Struct.EVENTTYPE = EVENTTYPE;
		Struct.SPELLNAME = "COUP BLANC";
		Struct.HITTYPE = "DAMAGE";
		Struct.TYPE = "DAMAGE COUP BLANC";
	elseif ( EVENTTYPE == "SPELL_HEAL" ) then -- sort de soins
		Struct = {};
		Struct.SPELLID, Struct.SPELLNAME, Struct.SPELLSCHOOL, 
		Struct.AMOUNT, Struct.OVERHEALING,
		Struct.ABSORBED, Struct.CRITICAL = ...;
		Struct.EVENTTYPE = EVENTTYPE;
		Struct.HITTYPE = "HEAL";
		Struct.TYPE = "HEAL SPELL";
	elseif ( EVENTTYPE == "SPELL_PERIODIC_HEAL" ) then -- tick de sort de soins
		Struct = {};
		Struct.SPELLID, Struct.SPELLNAME, Struct.SPELLSCHOOL, 
		Struct.AMOUNT, Struct.OVERHEALING,
		Struct.ABSORBED, Struct.CRITICAL = ...;
		Struct.EVENTTYPE = EVENTTYPE;
		Struct.HITTYPE = "HEAL";
		Struct.TYPE = "HEAL SPELL TICK";
	elseif ( EVENTTYPE == "SPELL_MISSED" ) then -- Sort Manque ou partiellement manque
		Struct = {};
		Struct.SPELLID, Struct.SPELLNAME, Struct.SPELLSCHOOL, 
		Struct.MISSEDTYPE, Struct.ISOFFHAND, Struct.MULTISTRIKE, Struct.AMOUNT = ...; -- ISOFFHAND & MULTISTRIKE sont des bool / AMOUNT => montant du sort qui est absorbe
		Struct.EVENTTYPE = EVENTTYPE;
		Struct.HITTYPE = "MISSED";
		Struct.TYPE = "MISSED SPELL";
	elseif ( EVENTTYPE == "SPELL_PERIODIC_MISSED" ) then -- Tick de Sort Manque ou partiellement manque
		Struct = {};
		Struct.SPELLID, Struct.SPELLNAME, Struct.SPELLSCHOOL, 
		Struct.MISSEDTYPE, Struct.ISOFFHAND, Struct.MULTISTRIKE, Struct.AMOUNT = ...; -- ISOFFHAND & MULTISTRIKE sont des bool / AMOUNT => montant du sort qui est absorbe
		Struct.EVENTTYPE = EVENTTYPE;
		Struct.HITTYPE = "MISSED";
		Struct.TYPE = "MISSED SPELL TICK";
	elseif ( EVENTTYPE == "SWING_MISSED" ) then -- coup blanc maqnue
		Struct = {};
		Struct.MISSEDTYPE, Struct.ISOFFHAND, Struct.MULTISTRIKE, Struct.AMOUNT = ...; -- ISOFFHAND & MULTISTRIKE sont des bool / AMOUNT => montant du sort qui est absorb
		Struct.EVENTTYPE = EVENTTYPE;
		Struct.SPELLNAME = "COUP BLANC";
		Struct.HITTYPE = "MISSED";
		Struct.TYPE = "MISSED COUP BLANC";
	end
	if ( Struct ) then
		Struct.SRCFLAG1 = SRCFLAG1;
		Struct.DSTFLAG1 = DSTFLAG1;
	end
	return Struct;
end
function SpellTracker:GetAllSpellTexture(spellID) -- 0.40 / pour remplacer
	local ret = nil;
	if ( spellID ) then
		if ( SpellTrackerDB.Dicos.Icons[spellID] == nil ) then
			name, rank, icon, cost, isFunnel, powerType, castTime, minRange, maxRange = GetSpellInfo(spellID);
			SpellTrackerDB.Dicos.Icons[spellID] = icon;
		end
		ret = SpellTrackerDB.Dicos.Icons[spellID];
	end
	return ret;
end
function SpellTracker:GetSpellHyperlink(spellID) -- 0.41 / OK
	local name, rank = GetSpellInfo(spellID);
	name = name or "";
	rank = rank or "";
	return "|Hspell:" .. spellID .."|h|r|cff71d5ff[" .. name .. " " .. rank .. "]|r|h";
end
function SpellTracker:UpdateSpell(SourceClass, SourceType, SourceName, TargetClass, TargetType, TargetName, CombatLogStruct) -- TargetType = player or MOB / -- 0.54 simplification lol tout les nom vont dans updatespell ^^
	-- voir http://www.wowwiki.com/API_COMBAT_LOG_EVENT
	local SpellIndexer;
	local SpellStruct = SpellTrackerDB.SPELLS;
			
	local flagTypeSrc, flagControlSrc, flagReactionSrc, flagAffiliationSrc = SpellTracker:WhatIsThisFlag(CombatLogStruct.SRCFLAG1);
	local flagTypeDst, flagControlDst, flagReactionDst, flagAffiliationDst = SpellTracker:WhatIsThisFlag(CombatLogStruct.DSTFLAG1);
	
	-- 0.41 => modification du comportement de l'indexer
	local currentKey = nil;
	local currentStruct = nil;
	local currentIT = nil;
	local res = nil;
	
	local FilterDataStruct = SpellTrackerDB.DataStruct;
	local CountFilterDataStructItem = #FilterDataStruct;
	for i=0,CountFilterDataStructItem do
		if ( SpellStruct == nil ) then break; end
		local it = FilterDataStruct[i];
		if ( it == "HitType" ) then -- Heal / Damage
			currentKey = tostring(CombatLogStruct.HITTYPE);
			currentIT = it;
			SpellStruct = SpellTracker:AddOrUpdateSpellsAmountsAndTicksStruct(SpellStruct, currentKey, currentIT, CombatLogStruct);
		elseif ( it == "SourceClass" ) then -- nom de la classe
			currentKey = tostring(SourceClass);
			currentIT = it;
			SpellStruct = SpellTracker:AddOrUpdateSpellsAmountsAndTicksStruct(SpellStruct, currentKey, currentIT, CombatLogStruct);
		elseif ( it == "TargetClass" ) then -- nom de la classe
			currentKey = tostring(TargetClass);
			currentIT = it;
			SpellStruct = SpellTracker:AddOrUpdateSpellsAmountsAndTicksStruct(SpellStruct, currentKey, currentIT, CombatLogStruct);
		elseif ( it == "SpellName" ) then -- Nom du sort
			currentKey = tostring(CombatLogStruct.SPELLNAME);
			currentIT = it;
			SpellStruct = SpellTracker:AddOrUpdateSpellsAmountsAndTicksStruct(SpellStruct, currentKey, currentIT, CombatLogStruct);
		elseif ( it == "SourceType" ) then -- Type de source ( Mob, Player, Vehicle, Pet )
			currentKey = tostring(SourceType);
			currentIT = it;
			SpellStruct = SpellTracker:AddOrUpdateSpellsAmountsAndTicksStruct(SpellStruct, currentKey, currentIT, CombatLogStruct);
		elseif ( it == "SourceReaction" ) then -- reaction de la source par rapport a mon perso
			currentKey = tostring(flagReactionSrc);
			currentIT = it;
			SpellStruct = SpellTracker:AddOrUpdateSpellsAmountsAndTicksStruct(SpellStruct, currentKey, currentIT, CombatLogStruct);
		elseif ( it == "SourceName" ) then -- Nom de la source
			currentKey = tostring(SourceName);
			currentIT = it;
			SpellStruct = SpellTracker:AddOrUpdateSpellsAmountsAndTicksStruct(SpellStruct, currentKey, currentIT, CombatLogStruct);
		elseif ( it == "TargetType" ) then -- Type de cible
			currentKey = tostring(TargetType);
			currentIT = it;
			SpellStruct = SpellTracker:AddOrUpdateSpellsAmountsAndTicksStruct(SpellStruct, currentKey, currentIT, CombatLogStruct);
		elseif ( it == "TargetReaction" ) then -- reaction de la cible par rapport a mon perso
			currentKey = tostring(flagReactionDst);
			currentIT = it;
			SpellStruct = SpellTracker:AddOrUpdateSpellsAmountsAndTicksStruct(SpellStruct, currentKey, currentIT, CombatLogStruct);
		elseif ( it == "TargetName" ) then -- Nom de la cible
			currentKey = tostring(TargetName);
			currentIT = it;
			SpellStruct = SpellTracker:AddOrUpdateSpellsAmountsAndTicksStruct(SpellStruct, currentKey, currentIT, CombatLogStruct);
		end
	end
	
	if ( SpellStruct ) then -- on ajoute a la BD
		-- On maj la frame / 0.40 ralentissait toute l'interface lors des raids capitale
		if ( SpellTrackerFrame ) then
			if ( SpellTrackerFrame:IsVisible() ) then
				if ( SpellTrackerDB.ViewPlaying ~= 0 ) then -- 0.47
					local t0 = debugprofilestop();
					SpellTracker:ReComputeFilteredSpellList(); -- recalcul -- 0.47 freeze le jeu quand plus de X event/sec -- donc & seule maj lors de ouverture frame
					SpellTracker:UpdateFrame(); -- maj
					SpellTracker.RefreshTime = (debugprofilestop() - t0); -- ms
					SpellTrackerButton_UpdateTitle();
					SpellTracker:AdjustViewPauseRecordingMode();
				end
			end
		end
	end
end
function SpellTracker:AddOrUpdateSpellsAmountsAndTicksStruct(SpellStruct, currentKey, currentIT, CombatLogStruct) -- 0.41 / OK -- 0.66 refonte pour le sort
	local ret = nil;
	
	local currentStruct = SpellStruct[currentKey];
	currentStruct = currentStruct or {};
	currentStruct.help = currentIT; --ca dit a quoi ca correspond
	
	-- spell
	if ( currentIT == "SpellName" ) then
		currentStruct.SpellIconTex = ""; -- chemin de la texture du sort
		if ( currentStruct.SpellId ) then
			if ( currentStruct.SpellId ~= CombatLogStruct.SPELLID ) then currentStruct.TickSpellId = CombatLogStruct.SPELLID; -- id du tick
			end
		else currentStruct.SpellId = CombatLogStruct.SPELLID; -- id du sort
		end
		currentStruct.SpellIconTex = SpellTracker:GetAllSpellTexture(currentStruct.SpellId);
	end
	
	-- Expanded / 0.48
	--currentStruct.Expanded = false;
	
	-- Amount / 0.40
	currentStruct.AmountLine = currentStruct.AmountLine or "0/0/0/0/0/0/0/0";
	
	-- Best / 0.53
	currentStruct.BestLine = currentStruct.BestLine or "0/0/0/0/0/0/0/0";
	
	-- Ticks / 0.40
	currentStruct.TickLine = currentStruct.TickLine or "0/0/0/0/0/0/0/0";
	
	-- Calcul
	CombatLogStruct.ABSORBED = CombatLogStruct.ABSORBED or 0;
	CombatLogStruct.OVERKILL = CombatLogStruct.OVERKILL or 0;
	CombatLogStruct.OVERHEALING = CombatLogStruct.OVERHEALING or 0;
	CombatLogStruct.CRITICAL = CombatLogStruct.CRITICAL or 0;
	
	if ( CombatLogStruct.OVERKILL < 0 ) then CombatLogStruct.OVERKILL = 0; end
	
	-- affectation des donnees selon le log de combat
	local TotalAmount = 0;
	local TotalTick = 0;
	local TotalBest = 0;
	
	local SpellHitAmount = 0;
	local SpellCritAmount = 0;
	local SpellCritAndOverAmount = 0;
	local SpellOverAmount = 0;
	local SpellOverAndAbsorbAmount = 0;
	local SpellCritAndAbsorbAmount = 0;
	local SpellAbsorbAmount = 0;
	
	-- 6.0.2 : CombatLogStruct.CRITICAL est un boolean maintenant
	-- AMOUNT = 145000
	-- OVERKILL = 32000
	-- ce qui veut dure sur sur les 145000 seulement 32000 sont en exces
	-- donc AMOUNT vaut en fait AMOUNT - OVERKILL
	if ( CombatLogStruct.HITTYPE == "DAMAGE" ) then -- DAMAGE
		if ( CombatLogStruct.CRITICAL == true ) then -- crit
			SpellCritAmount = CombatLogStruct.AMOUNT - CombatLogStruct.OVERKILL;
			SpellCritAndOverAmount = CombatLogStruct.OVERKILL;
			SpellCritAndAbsorbAmount = CombatLogStruct.ABSORBED;
		else -- normal
			SpellHitAmount = CombatLogStruct.AMOUNT - CombatLogStruct.OVERKILL;
			SpellOverAmount = CombatLogStruct.OVERKILL;
			SpellAbsorbAmount = CombatLogStruct.ABSORBED;
		end
	elseif ( CombatLogStruct.HITTYPE == "HEAL" ) then -- HEAL
		if ( CombatLogStruct.CRITICAL == true ) then -- crit
			SpellCritAmount = CombatLogStruct.AMOUNT - CombatLogStruct.OVERHEALING;
			SpellCritAndOverAmount = CombatLogStruct.OVERHEALING;
			SpellCritAndAbsorbAmount = CombatLogStruct.ABSORBED;
		else -- normal
			SpellHitAmount = CombatLogStruct.AMOUNT - CombatLogStruct.OVERHEALING;
			SpellOverAmount = CombatLogStruct.OVERHEALING;
			SpellAbsorbAmount = CombatLogStruct.ABSORBED;
		end
	elseif ( CombatLogStruct.HITTYPE == "MISSED" ) then -- MISSED
		if ( CombatLogStruct.MISSEDTYPE == "ABSORB" ) then
			SpellAbsorbAmount = CombatLogStruct.AMOUNT or 0; -- au cas ou CombatLogStruct.AMOUNT vaudrait nil
		end
	end
	
	-- On recup les donnees actuelle / 0.40
	local LocalStruct = {};
	_,--total
		LocalStruct.SpellHitAmount, LocalStruct.SpellCritAmount, 
		LocalStruct.SpellCritAndOverAmount, LocalStruct.SpellOverAmount, 
		LocalStruct.SpellOverAndAbsorbAmount, LocalStruct.SpellCritAndAbsorbAmount, LocalStruct.SpellAbsorbAmount
		= string.match(currentStruct.AmountLine, "(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)");
	LocalStruct.SpellHitAmount = tonumber(LocalStruct.SpellHitAmount);
	LocalStruct.SpellCritAmount = tonumber(LocalStruct.SpellCritAmount);
	LocalStruct.SpellCritAndOverAmount = tonumber(LocalStruct.SpellCritAndOverAmount);
	LocalStruct.SpellOverAmount = tonumber(LocalStruct.SpellOverAmount);
	LocalStruct.SpellOverAndAbsorbAmount = tonumber(LocalStruct.SpellOverAndAbsorbAmount);
	LocalStruct.SpellCritAndAbsorbAmount = tonumber(LocalStruct.SpellCritAndAbsorbAmount);
	LocalStruct.SpellAbsorbAmount = tonumber(LocalStruct.SpellAbsorbAmount);
					
	_,--total
		LocalStruct.SpellHitBest, LocalStruct.SpellCritBest, 
		LocalStruct.SpellCritAndOverBest, LocalStruct.SpellOverBest, 
		LocalStruct.SpellOverAndAbsorbBest, LocalStruct.SpellCritAndAbsorbBest, LocalStruct.SpellAbsorbBest
		= string.match(currentStruct.BestLine, "(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)");
	LocalStruct.SpellHitBest = tonumber(LocalStruct.SpellHitBest);
	LocalStruct.SpellCritBest = tonumber(LocalStruct.SpellCritBest);
	LocalStruct.SpellCritAndOverBest = tonumber(LocalStruct.SpellCritAndOverBest);
	LocalStruct.SpellOverBest = tonumber(LocalStruct.SpellOverBest);
	LocalStruct.SpellOverAndAbsorbBest = tonumber(LocalStruct.SpellOverAndAbsorbBest);
	LocalStruct.SpellCritAndAbsorbBest = tonumber(LocalStruct.SpellCritAndAbsorbBest);
	LocalStruct.SpellAbsorbBest = tonumber(LocalStruct.SpellAbsorbBest);
	
	TotalTick,--total
		LocalStruct.CountSpellHit, LocalStruct.CountSpellCrit, 
		LocalStruct.CountSpellCritAndOver, LocalStruct.CountSpellOver, 
		LocalStruct.CountSpellOverAndAbsorb, LocalStruct.CountSpellCritAndAbsorb, LocalStruct.CountSpellAbsorb
		= string.match(currentStruct.TickLine, "(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)/(%S+)");
	TotalTick = tonumber(TotalTick);
	LocalStruct.CountSpellHit = tonumber(LocalStruct.CountSpellHit);
	LocalStruct.CountSpellAbsorb = tonumber(LocalStruct.CountSpellAbsorb);
	LocalStruct.CountSpellOver = tonumber(LocalStruct.CountSpellOver);
	LocalStruct.CountSpellCrit = tonumber(LocalStruct.CountSpellCrit);
	LocalStruct.CountSpellCritAndOver = tonumber(LocalStruct.CountSpellCritAndOver);
	LocalStruct.CountSpellCritAndAbsorb = tonumber(LocalStruct.CountSpellCritAndAbsorb);
	LocalStruct.CountSpellOverAndAbsorb = tonumber(LocalStruct.CountSpellOverAndAbsorb);
	
	-- Bests
	if ( SpellHitAmount > LocalStruct.SpellHitBest ) then  LocalStruct.SpellHitBest = SpellHitAmount; end
	if ( SpellCritAmount > LocalStruct.SpellCritBest ) then  LocalStruct.SpellCritBest = SpellCritAmount; end
	if ( SpellCritAndOverAmount > LocalStruct.SpellCritAndOverBest ) then  LocalStruct.SpellCritAndOverBest = SpellCritAndOverAmount; end
	if ( SpellOverAmount > LocalStruct.SpellOverBest ) then  LocalStruct.SpellOverBest = SpellOverAmount; end
	if ( SpellCritAndAbsorbAmount > LocalStruct.SpellCritAndAbsorbBest ) then  LocalStruct.SpellCritAndAbsorbBest = SpellCritAndAbsorbAmount; end
	if ( SpellOverAndAbsorbAmount > LocalStruct.SpellOverAndAbsorbBest ) then  LocalStruct.SpellOverAndAbsorbBest = SpellOverAndAbsorbAmount; end
	if ( SpellAbsorbAmount > LocalStruct.SpellAbsorbBest ) then  LocalStruct.SpellAbsorbBest = SpellAbsorbAmount; end
	
	local CurrentSpellTotalAmount = 
		SpellCritAmount + SpellCritAndOverAmount + SpellCritAndAbsorbAmount + -- crit
		SpellHitAmount + SpellOverAmount + SpellAbsorbAmount; -- hit
		
	if ( CurrentSpellTotalAmount > 0 ) then -- on ajoute a la BD
		-- Montants
		LocalStruct.SpellHitAmount = (LocalStruct.SpellHitAmount) + SpellHitAmount;
		LocalStruct.SpellCritAmount = (LocalStruct.SpellCritAmount) + SpellCritAmount;
		LocalStruct.SpellCritAndOverAmount = (LocalStruct.SpellCritAndOverAmount) + SpellCritAndOverAmount;
		LocalStruct.SpellOverAmount = (LocalStruct.SpellOverAmount) + SpellOverAmount;
		LocalStruct.SpellCritAndAbsorbAmount = (LocalStruct.SpellCritAndAbsorbAmount) + SpellCritAndAbsorbAmount;
		LocalStruct.SpellOverAndAbsorbAmount = (LocalStruct.SpellOverAndAbsorbAmount) + SpellOverAndAbsorbAmount;
		LocalStruct.SpellAbsorbAmount = (LocalStruct.SpellAbsorbAmount) + SpellAbsorbAmount;
	
		-- Amount Total
		TotalAmount = LocalStruct.SpellHitAmount + LocalStruct.SpellCritAmount + LocalStruct.SpellCritAndOverAmount +
			LocalStruct.SpellOverAmount + LocalStruct.SpellCritAndAbsorbAmount + LocalStruct.SpellOverAndAbsorbAmount + LocalStruct.SpellAbsorbAmount;
			
		-- 1 tick de plus
		TotalTick = TotalTick + 1;
		
		-- Best
		TotalBest = LocalStruct.SpellHitBest + LocalStruct.SpellCritBest + LocalStruct.SpellCritAndOverBest + 
			LocalStruct.SpellOverBest + LocalStruct.SpellOverAndAbsorbBest + LocalStruct.SpellCritAndAbsorbBest + LocalStruct.SpellAbsorbBest;
			
		-- Ticks
		if ( SpellHitAmount > 0 ) then LocalStruct.CountSpellHit = LocalStruct.CountSpellHit + 1; end
		if ( SpellCritAmount > 0 ) then LocalStruct.CountSpellCrit = LocalStruct.CountSpellCrit + 1; end
		if ( SpellCritAndOverAmount > 0 ) then LocalStruct.CountSpellCritAndOver = LocalStruct.CountSpellCritAndOver + 1; end
		if ( SpellOverAmount > 0 ) then LocalStruct.CountSpellOver = LocalStruct.CountSpellOver + 1; end
		if ( SpellCritAndAbsorbAmount > 0 ) then LocalStruct.CountSpellCritAndAbsorb = LocalStruct.CountSpellCritAndAbsorb + 1; end
		if ( SpellOverAndAbsorbAmount > 0 ) then LocalStruct.CountSpellOverAndAbsorb = LocalStruct.CountSpellOverAndAbsorb + 1; end
		if ( SpellAbsorbAmount > 0 ) then LocalStruct.CountSpellAbsorb = LocalStruct.CountSpellAbsorb + 1; end
		
		-- On retransforme les donnees en deux lignes / 0.40
		currentStruct.AmountLine = TotalAmount.."/"..
			LocalStruct.SpellHitAmount.."/"..
			LocalStruct.SpellCritAmount.."/"..LocalStruct.SpellCritAndOverAmount.."/"..
			LocalStruct.SpellOverAmount.."/"..LocalStruct.SpellOverAndAbsorbAmount.."/"..LocalStruct.SpellCritAndAbsorbAmount.."/"..
			LocalStruct.SpellAbsorbAmount;
		
		currentStruct.BestLine = TotalBest.."/"..
			LocalStruct.SpellHitBest.."/"..
			LocalStruct.SpellCritBest.."/"..LocalStruct.SpellCritAndOverBest.."/"..
			LocalStruct.SpellOverBest.."/"..LocalStruct.SpellOverAndAbsorbBest.."/"..LocalStruct.SpellCritAndAbsorbBest.."/"..
			LocalStruct.SpellAbsorbBest;
				
		currentStruct.TickLine = TotalTick.."/"..
			LocalStruct.CountSpellHit.."/"..
			LocalStruct.CountSpellCrit.."/"..LocalStruct.CountSpellCritAndOver.."/"..
			LocalStruct.CountSpellOver.."/"..LocalStruct.CountSpellOverAndAbsorb.."/"..LocalStruct.CountSpellCritAndAbsorb.."/"..
			LocalStruct.CountSpellAbsorb;	
	
		currentStruct.Expanded = currentStruct.Expanded or 0;
		
		SpellStruct[currentKey] = currentStruct;
		
		SpellTracker:CalcEventsPerSec();
		
		ret = currentStruct;
	end
	return	ret;
end
function SpellTracker:RecursPrint(key, element)
    print(key.." = {};");
    if ( element ) then
        for i,v in pairs(element) do 
            --print("i,v="..tostring(i)..","..tostring(v));
            if ( type(v) == "table" ) then 
                SpellTracker:RecursPrint(key.."."..tostring(i), v); 
            elseif ( type(i) == "table" ) then 
                --SpellTracker:RecursPrint(key.."."..tostring(i), i); 
            elseif ( type(element[i]) == "table" ) then
                --SpellTracker:RecursPrint(key.."."..tostring(i), element[i]); 
            elseif ( type(element[i]) == "string") then
                print(tostring(key).."."..tostring(i).." = \""..tostring(element[i]).."\";");
            else
                print(tostring(key).."."..tostring(i).." = "..tostring(element[i])..";");
            end
        end
    end
end
