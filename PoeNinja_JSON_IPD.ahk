/**
 *  script: poe_ninja_json_to_ipd
 *      The script uses a Library from https://github.com/cocobelgica/AutoHotkey-JSON
 *      to convert a given JSON file into ExileBot usable IPD structure. JSON data is
 *      being pulled from "poe.ninja/api/data".
 *      "chaosValues" can be adjusted to limit the results for uniques.
 *      
 *      Array "_ALL_CATEGORIES" can be filled with desired categories to pull from.
 *      Each entry will receive it's own named output file respectively. The RAW
 *      JSON data remains untouched for verification purposes.
 */

;____________________________________________________________________________________


; current __CURRENT_LEAGUE name - case sensitive!
__CURRENT_LEAGUE := "Keepers"

;_____________ CATEGORIES
chaosValue := {}

; values greater -> "StashItem"
chaosValue["Currency"]        := 0.0
chaosValue["Fragment"]        := 5.0
chaosValue["Runegraft"]       := 5.0
chaosValue["AllflameEmber"]   := 5.0
chaosValue["Tattoo"]          := 5.0
chaosValue["Omen"]            := 5.0
chaosValue["DivinationCard"]  := 5.0
chaosValue["Artifact"]        := 5.0
chaosValue["Oil"]             := 5.0
chaosValue["DeliriumOrb"]     := 5.0
chaosValue["Scarab"]          := 5.0
chaosValue["Fossil"]          := 5.0
chaosValue["Resonator"]       := 1.0
chaosValue["Essence"]         := 5.0
chaosValue["Incubator"]       := 1.0
chaosValue["Invitation"]      := 5.0
chaosValue["Memory"]          := 5.0
chaosValue["Beast"]           := 5.0
chaosValue["Vial"]            := 2.0

; values lower -> "ForceSellItem"
chaosValue["UniqueWeapon"]    := 9.0
chaosValue["UniqueArmour"]    := 9.0
chaosValue["UniqueAccessory"] := 9.0
chaosValue["UniqueFlask"]     := 9.0
chaosValue["UniqueJewel"]     := 9.0
chaosValue["UniqueTincture"]  := 9.0
chaosValue["UniqueRelic"]     := 9.0
chaosValue["UniqueMap"]       := 9.0

/**
*   5 and 6 link bodyarmors/weapons are ignored
*   all items usually have 3 entries: unlinked/5link/6link
*   we only care about unlinked market value
*/

; special _ARRAY_CATEGORY for map ipd - value has no effect
chaosValue["Map"]              := 0.0
;_____________ CATEGORIES

/**
*   full list of available categories unknown
*   manual work currently
*
*   list of categories to receive data - case sensitive!
*   remove those you do not want to pull from
*/

_ALL_CATEGORIES := [ "Currency"
                    ,"Fragment"
                    ,"Runegraft"
                    ,"AllflameEmber"
                    ,"Tattoo"
                    ,"Omen"
                    ,"DivinationCard"
                    ,"Artifact"
                    ,"Oil"
                    ,"DeliriumOrb"
                    ,"Scarab"
                    ,"Fossil"
                    ,"Resonator"
                    ,"Essence"
                    ,"Incubator"
                    ,"Invitation"
                    ,"Memory"
                    ,"Beast"
                    ,"Vial"
                    ,"UniqueWeapon"
                    ,"UniqueArmour"
                    ,"UniqueAccessory"
                    ,"UniqueFlask"
                    ,"UniqueJewel"
                    ,"UniqueTincture"
                    ,"UniqueRelic"
                    ,"UniqueMap"
                    ,"Map"]


;_____________ GUI INTERFACE
Gui, Add, Progress, vProgressBar w300 h30 cBlue, 0
Gui, Add, Text,, Please wait, loading...
Gui, Show,, Loading

;______________ NO EDITS BELOW _________________________________
; --------------------------------------------------------------
;______________ BEGINNING OF SCRIPT  ___________________________

;_____________ DELETE CURRENT FILES
    Loop, Files, %A_ScriptDir%\IPD\*.IPD
    {
        FileDelete, %A_LoopFileFullPath%
    }
    Loop, Files, %A_ScriptDir%\JSON\*.json
    {
        FileDelete, %A_LoopFileFullPath%
    }
;_____________ PREPERATION
; Library from https://github.com/cocobelgica/AutoHotkey-JSON
#Include dependencies\JSON.ahk

for indexA, _ARRAY_CATEGORY in _ALL_CATEGORIES
{
    ; safety delay to avoid being ip-banned
    Sleep 100

    ; URL of the JSON file by _ARRAY_CATEGORY difference
    ; ---------
    ; EXCHANGE
    ; ---------
    if (   _ARRAY_CATEGORY == "Currency"
        || _ARRAY_CATEGORY == "Fragment"
        || _ARRAY_CATEGORY == "Runegraft"
        || _ARRAY_CATEGORY == "AllflameEmber"
        || _ARRAY_CATEGORY == "Tattoo"
        || _ARRAY_CATEGORY == "Omen"
        || _ARRAY_CATEGORY == "DivinationCard"
        || _ARRAY_CATEGORY == "Artifact"
        || _ARRAY_CATEGORY == "Oil"
        || _ARRAY_CATEGORY == "DeliriumOrb"
        || _ARRAY_CATEGORY == "Scarab"
        || _ARRAY_CATEGORY == "Fossil"
        || _ARRAY_CATEGORY == "Resonator"
        || _ARRAY_CATEGORY == "Essence" )
    {
        jsonUrl := "https://poe.ninja./poe1/api/economy/exchange/current/overview?league="   . __CURRENT_LEAGUE . "&type=" . _ARRAY_CATEGORY
        _ITERATION_METHOD := "EXCHANGE"
    }
    ; ---------
    ; STASH
    ; ---------
    if (   _ARRAY_CATEGORY == "Incubator"
        || _ARRAY_CATEGORY == "Invitation"
        || _ARRAY_CATEGORY == "Memory"
        || _ARRAY_CATEGORY == "Beast"
        || _ARRAY_CATEGORY == "Vial"
        || _ARRAY_CATEGORY == "UniqueWeapon"
        || _ARRAY_CATEGORY == "UniqueArmour"
        || _ARRAY_CATEGORY == "UniqueAccessory"
        || _ARRAY_CATEGORY == "UniqueFlask"
        || _ARRAY_CATEGORY == "UniqueJewel"
        || _ARRAY_CATEGORY == "UniqueTincture"
        || _ARRAY_CATEGORY == "UniqueRelic"
        || _ARRAY_CATEGORY == "UniqueMap" 
        || _ARRAY_CATEGORY == "Map" )
    {
        jsonUrl := "https://poe.ninja./poe1/api/economy/stash/current/item/overview?league=" . __CURRENT_LEAGUE . "&type=" . _ARRAY_CATEGORY
        _ITERATION_METHOD := "STASH"
    }



    ; Path to save the downloaded JSON file
    downloadedJsonPath := A_ScriptDir . "\JSON\poe_ninja_" . _ARRAY_CATEGORY . ".json"

    ; Download the JSON file
    URLDownloadToFile, %jsonUrl%, %downloadedJsonPath%
    if (ErrorLevel)
    {
        MsgBox, Failed to download the JSON file. Exiting.
        ExitApp
    }

    ; Read the edited JSON file
    FileRead, jsonData, %downloadedJsonPath%
    if (ErrorLevel)
    {
        MsgBox, Failed to read the downloaded JSON file. Exiting.
        ExitApp
    }


    ;_____________ PARSING
    ; Parse the JSON data
    _PARSED_JSONDATA := JSON.Load(jsonData)

    ; File path in the local application directory
    if ( _ARRAY_CATEGORY == "Map" ) {
        _IPD_FILEPATH := A_ScriptDir . "\IPD\_MAPS.IPD"
    }
    else {
        _IPD_FILEPATH := A_ScriptDir . "\IPD\IPD_" . _ARRAY_CATEGORY . ".IPD"
    }


    ; Open the file for writing
    FileAppend,, %_IPD_FILEPATH%, UTF-8  ; Clear the file if it exists

    __UNIQUE_ENTRIES := {}

    _JSON_ITEMS := _PARSED_JSONDATA.items
    _JSON_LINES := _PARSED_JSONDATA.lines

    if ( _ITERATION_METHOD == "EXCHANGE" ) {
        _ITERATION_ARRAY := _PARSED_JSONDATA.items
    }
    if ( _ITERATION_METHOD == "STASH"    ) {
        _ITERATION_ARRAY := _PARSED_JSONDATA.lines
    }
    ; Iterate over the JSON array
    for indexB, _CURRENT_ITEM in _ITERATION_ARRAY
    {
        ;EXCHANGE_DATA_________________________________________________________________________________________________
            if (   _ARRAY_CATEGORY == "Currency"
                || _ARRAY_CATEGORY == "Fragment"
                || _ARRAY_CATEGORY == "Runegraft"
                || _ARRAY_CATEGORY == "AllflameEmber"
                || _ARRAY_CATEGORY == "Tattoo"
                || _ARRAY_CATEGORY == "Omen"
                || _ARRAY_CATEGORY == "DivinationCard"
                || _ARRAY_CATEGORY == "Artifact"
                || _ARRAY_CATEGORY == "Oil"
                || _ARRAY_CATEGORY == "DeliriumOrb"
                || _ARRAY_CATEGORY == "Scarab"
                || _ARRAY_CATEGORY == "Fossil"
                || _ARRAY_CATEGORY == "Resonator"
                || _ARRAY_CATEGORY == "Essence" )
            {
                ; matching line entry
                _CURRENT_LINE := _JSON_LINES[indexB]
                ; CAST TO FLOAT
                _NINJA_CHAOSVALUE   := _CURRENT_LINE.primaryValue + 0.0
                _NINJA_NAME         := _CURRENT_ITEM.name
                _DESIRED_CHAOSVALUE := chaosValue[_ARRAY_CATEGORY]

                ; exclude both scrolls - should not be in the pickit file
                ; UI maintains rules for those!
                if ( (_NINJA_NAME == "Scroll of Wisdom") || (_NINJA_NAME == "Portal Scroll") ) {
                    continue
                }
                ; force chaos orb entry
                if ( _NINJA_NAME == "Chaos Orb" )
                {
                    chaosEntry := "[Type] == ""Chaos Orb"" # [StashItem] == ""true"""
                    FileAppend, %chaosEntry%`n, %_IPD_FILEPATH%
                    continue
                }
                ; only add items with higher desired chaosvalue
                if (_NINJA_CHAOSVALUE >= _DESIRED_CHAOSVALUE)
                {
                    _IPD_OUTPUT := "[Type] == """ . _NINJA_NAME . """ # [StashItem] == ""true"" // " . _NINJA_CHAOSVALUE
                    FileAppend, %_IPD_OUTPUT%`n, %_IPD_FILEPATH%
                }
            }
        ;______________________________________________________________________________________________________________

        ;STASH_DATA____________________________________________________________________________________________________
            else if (   _ARRAY_CATEGORY == "Incubator"
                     || _ARRAY_CATEGORY == "Invitation"
                     || _ARRAY_CATEGORY == "Memory"
                     || _ARRAY_CATEGORY == "Beast"
                     || _ARRAY_CATEGORY == "Vial" )
            {
                ; CAST TO FLOAT
                _NINJA_CHAOSVALUE   := _CURRENT_ITEM.chaosValue + 0.0
                _NINJA_NAME         := _CURRENT_ITEM.name
                _DESIRED_CHAOSVALUE := chaosValue[_ARRAY_CATEGORY]

                if (_NINJA_CHAOSVALUE >= _DESIRED_CHAOSVALUE)
                {
                    if (!__UNIQUE_ENTRIES.HasKey(_NINJA_NAME)) {
                        __UNIQUE_ENTRIES[_NINJA_NAME] := true
                        _IPD_OUTPUT := "[Type] == """ _NINJA_NAME """ # [StashItem] == ""true"" // "   _NINJA_CHAOSVALUE
                        FileAppend, %_IPD_OUTPUT%`n, %_IPD_FILEPATH%
                    }
                }
            }
            ; FORCESELL ON UNIQUES INSTEAD
            else if (   _ARRAY_CATEGORY == "UniqueWeapon"
                     || _ARRAY_CATEGORY == "UniqueArmour"
                     || _ARRAY_CATEGORY == "UniqueAccessory"
                     || _ARRAY_CATEGORY == "UniqueFlask"
                     || _ARRAY_CATEGORY == "UniqueJewel"
                     || _ARRAY_CATEGORY == "UniqueTincture"
                     || _ARRAY_CATEGORY == "UniqueRelic"
                     || _ARRAY_CATEGORY == "UniqueMap" )
            {
                ; CAST TO FLOAT
                _NINJA_CHAOSVALUE   := _CURRENT_ITEM.chaosValue + 0.0
                _NINJA_NAME         := _CURRENT_ITEM.name
                _NINJA_LINKS        := _CURRENT_ITEM.links
                _DESIRED_CHAOSVALUE := chaosValue[_ARRAY_CATEGORY]
                if (_NINJA_CHAOSVALUE < _DESIRED_CHAOSVALUE)
                {
                    if (!__UNIQUE_ENTRIES.HasKey(_NINJA_NAME)) {
                        if (_NINJA_LINKS < 5) {
                            __UNIQUE_ENTRIES[_NINJA_NAME] := true
                            _IPD_OUTPUT := "[UniqueName] == """ _NINJA_NAME """ # [ForceSellItem] == ""true"" // "   _NINJA_CHAOSVALUE
                            FileAppend, %_IPD_OUTPUT%`n, %_IPD_FILEPATH%
                        }
                    }
                }
            }
            ; MAPS -> RUNMAP "TRUE" AND MANUAL EDIT REQUIRED!
            else if ( _ARRAY_CATEGORY == "Map" )
            {
                ; CAST TO FLOAT
                _NINJA_CHAOSVALUE   := _CURRENT_ITEM.chaosValue + 0.0
                _NINJA_NAME         := _CURRENT_ITEM.name
                _DESIRED_CHAOSVALUE := chaosValue[_ARRAY_CATEGORY]
                    if (!__UNIQUE_ENTRIES.HasKey(_NINJA_NAME)) {
                        __UNIQUE_ENTRIES[_NINJA_NAME] := true
                        _IPD_OUTPUT := "[Type] == """ _NINJA_NAME """ # [RunMap] == ""true"""
                        FileAppend, %_IPD_OUTPUT%`n, %_IPD_FILEPATH%
                    }
            }
        ;______________________________________________________________________________________________________________
    }
    Progress += ( 100/_ALL_CATEGORIES.Length() )
    GuiControl,, ProgressBar, %Progress%
}

; create IPD_DateAndTime.IPD with the current timestamp - marks creating/pull time
FormatTime, CurrentDateTime,, dd.MM.yyyy HH:mm:ss
FileAppend, // Creation Date: %CurrentDateTime%, %A_ScriptDir%\IPD\IPD_DateAndTime.IPD
; play windows notification sound
DllCall("winmm\PlaySound" (A_IsUnicode?"W":"A"), Str,"none", Ptr,0, UInt,0x20000)

Gui, Destroy
MsgBox, JSON to IPD finished!
ExitApp