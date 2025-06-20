/**
 *  script: poe_ninja_json_to_ipd
 *      The script uses a Library from https://github.com/cocobelgica/AutoHotkey-JSON
 *      to convert a given JSON file into ExileBot usable IPD structure. JSON data is
 *      being pulled from "poe.ninja/api/data".
 *      "chaosValues" can be adjusted to limit the results for uniques.
 *      
 *      Array "allCategories" can be filled with desired categories to pull from.
 *      Each entry will receive it's own named output file respectively. The RAW
 *      JSON data remains untouched for verification purposes.
 */

;____________________________________________________________________________________

/**
*   not possible to fetch:
*                           SkillGem           (no need)
*                           BaseType           (advanced endgame mapping)
*                           HelmetEnchant      (not dropped)
*                           Beast              (not dropped)
*                           Vial               (too specific of a drop)
*                           UniqueRelic        (not relevant of a drop for EB)
*                           ClusterJewel       (itemlevel very important, manual setup)
*                           BlightedMap        (covered by taking all maps)
*                           BlightRavagedMap   (covered by taking all maps)
*                           Coffin             (not dropped)
*/

;_____________ CATEGORIES
chaosValues := {}

; values greater -> "StashItem"
chaosValues["Currency"]         := 0.0
chaosValues["Fragment"]         := 4.0
chaosValues["Oil"]              := 1.0
chaosValues["Incubator"]        := 4.0
chaosValues["Scarab"]           := 1.0
chaosValues["Fossil"]           := 0.0
chaosValues["Resonator"]        := 0.0
chaosValues["Essence"]          := 2.0
chaosValues["DivinationCard"]   := 2.0
chaosValues["DeliriumOrb"]      := 1.0
chaosValues["Omen"]             := 5.0
chaosValues["Invitation"]       := 0.0
chaosValues["Memory"]           := 0.0

; values lower -> "ForceSellItem"
chaosValues["UniqueMap"]        := 9.0
chaosValues["UniqueJewel"]      := 9.0
chaosValues["UniqueFlask"]      := 9.0
chaosValues["UniqueWeapon"]     := 9.0
chaosValues["UniqueArmour"]     := 9.0
chaosValues["UniqueAccessory"]  := 9.0

/**
*   5 and 6 link bodyarmors/weapons are ignored
*   all items usually have 3 entries: unlinked/5link/6link
*   we only care about unlinked market value
*/


; special category for map ipd - value has no effect
chaosValues["Map"]              := 0.0
;_____________ CATEGORIES


; current league name - case sensitive!
league := "Mercenaries"

/**
*   see full list of available categories here:
*   https://github.com/ayberkgezer/poe.ninja-API-Document
*
*   list of categories to receive data - case sensitive!
*   remove those you do not want to pull from
*/

allCategories := [   "Currency"
                    ,"Fragment"
                    ,"Oil"
                    ,"Incubator"
                    ,"Scarab"
                    ,"Fossil"
                    ,"Resonator"
                    ,"Essence"
                    ,"DivinationCard"
                    ,"DeliriumOrb"
                    ,"Omen"
                    ,"Invitation"
                    ,"Memory"
                    ,"UniqueMap"
                    ,"UniqueJewel"
                    ,"UniqueFlask"
                    ,"UniqueWeapon"
                    ,"UniqueArmour"
                    ,"UniqueAccessory"
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

        Loop, Files, %A_ScriptDir%\JSON\*.IPD
        {
            FileDelete, %A_LoopFileFullPath%
        }

;_____________ PREPERATION
; Library from https://github.com/cocobelgica/AutoHotkey-JSON
#Include dependencies\JSON.ahk

for indexA, category in allCategories
{
    ; safety delay to avoid being ip-banned
    Sleep 100

    ; URL of the JSON file
    if ( category == "Fragment" OR category == "Currency" ) {
        jsonUrl := "https://poe.ninja/api/data/currencyoverview?league=" . league . "&type=" . category
    }
    else {
        jsonUrl := "https://poe.ninja/api/data/itemoverview?league="     . league . "&type=" . category
    }

    ; Path to save the downloaded JSON file
    downloadedJsonPath := A_ScriptDir . "\JSON\poe_ninja_" . category . ".json"

    ; Download the JSON file
    URLDownloadToFile, %jsonUrl%, %downloadedJsonPath%
    if (ErrorLevel)
    {
        MsgBox, Failed to download the JSON file. Exiting.
        ExitApp
    }

                 ; Read the downloaded JSON file
                FileRead, FileContent, %downloadedJsonPath%

                ; Remove the starting `{"lines":` and the ending `}`
                FileContent := RegExReplace(FileContent, "^{""lines"":", "")
                FileContent := RegExReplace(FileContent, "}$", "")

                    ; Check if 'currencyDetails' exists
                    IfInString, FileContent, "currencyDetails"
                    {
                        ; Remove everything after 'currencyDetails' including itself
                        FileContent := SubStr(FileContent, 1, InStr(FileContent, "currencyDetails")-1)
                        FileContent := SubStr(FileContent, 1, StrLen(FileContent)-2)
                    }

                ; Save the modified content back to the file
                FileDelete, %downloadedJsonPath%
                FileAppend, %FileContent%, %downloadedJsonPath%


    ; Read the edited JSON file
    FileRead, jsonData, %downloadedJsonPath%
    if (ErrorLevel)
    {
        MsgBox, Failed to read the downloaded JSON file. Exiting.
        ExitApp
    }


    ;_____________ PARSING
    ; Parse the JSON data
    jsonVar := JSON.Load(jsonData)

    ; File path in the local application directory
    if ( category == "Map" ) {
        filePath := A_ScriptDir . "\IPD\_MAPS.IPD"
    }
    else {
        filePath := A_ScriptDir . "\IPD\IPD_" . category . ".IPD"
    }


    ; Open the file for writing
    FileAppend,, %filePath%, UTF-8  ; Clear the file if it exists

    uniqueNames := {}

    ; Iterate over the JSON array
    for indexB, item in jsonVar
    {

;_______Currency_StashItem_______________________________________________________________________________________________________
        if      (      category == "Currency"
                    || category == "Fragment" )
        {

            if ( (item.currencyTypeName == "Scroll of Wisdom") || (item.currencyTypeName == "Portal Scroll") )
            {
                continue
            }


            if ( (category == "Currency") && (indexB == 1) )
            {
                chaosLine := "[Type] == ""Chaos Orb"" # [StashItem] == ""true"""
                FileAppend, %chaosLine%`n, %filePath%
            }

            currentChaosValue := chaosValues[category]
            if (item.chaosEquivalent > currentChaosValue)
            {
                output := "[Type] == """ item.currencyTypeName """ # [StashItem] == ""true"" // "   item.chaosEquivalent
                FileAppend, %output%`n, %filePath%
            }

        }
;_______Other_StashItem__________________________________________________________________________________________________________
        else if (      category == "Oil"
                    || category == "Incubator"
                    || category == "Scarab"
                    || category == "Fossil"
                    || category == "Resonator"
                    || category == "Essence"
                    || category == "DivinationCard"
                    || category == "DeliriumOrb"
                    || category == "Omen"
                    || category == "Invitation"
                    || category == "Memory"
                    || category == "AllflameEmber")
        {

            currentChaosValue := chaosValues[category]
            if (item.chaosValue > currentChaosValue)
            {
                if (!uniqueNames.HasKey(item.name)) {
                    uniqueNames[item.name] := true
                    output := "[Type] == """ item.name """ # [StashItem] == ""true"" // "   item.chaosValue
                    FileAppend, %output%`n, %filePath%
                }

            }

        }
;_______UniqueName_ForceSellItem_________________________________________________________________________________________________
        else if (      category == "UniqueMap"
                    || category == "UniqueJewel"
                    || category == "UniqueFlask"
                    || category == "UniqueWeapon"
                    || category == "UniqueArmour"
                    || category == "UniqueAccessory")
        {

            currentChaosValue := chaosValues[category]
            if (item.chaosValue < currentChaosValue)
            {
                if (!uniqueNames.HasKey(item.name)) {
                    if (item.links < 5) {
                        uniqueNames[item.name] := true
                        output := "[UniqueName] == """ item.name """ # [ForceSellItem] == ""true"" // "   item.chaosValue
                        FileAppend, %output%`n, %filePath%
                    }
                }

            }

        }
;_______Map_RunMap_______________________________________________________________________________________________________________
        else if (      category == "Map" )
        {

            currentChaosValue := chaosValues[category]
                if (!uniqueNames.HasKey(item.name)) {
                    uniqueNames[item.name] := true
                    output := "[Type] == """ item.name """ # [RunMap] == ""true"""
                    FileAppend, %output%`n, %filePath%
                }

        }
;________________________________________________________________________________________________________________________________

    }

    Progress += ( 100/allCategories.Length() )
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