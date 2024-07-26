# EB-POENINJA-TO-IPD
JSON to IPD

AKH v1 required -> https://www.autohotkey.com/download/ahk-install.exe

usage -> delete current generated IPDs -> PoeNinja_JSON_IPD.ahk -> _CREATE_PICKIT.ahk - > _CREATE_MAPS.ahk

       The script uses a Library from https://github.com/cocobelgica/AutoHotkey-JSON
       to convert a given JSON file into ExileBot usable IPD structure. JSON data is
       being pulled from "poe.ninja/api/data".
       "chaosValues" can be adjusted to limit the results for uniques.
       
       Array "allCategories" can be filled with desired categories to pull from.
       Each entry will receive it's own named output file respectively. The RAW
       JSON data remains untouched for verification purposes.

       Everything is pulled by default! You have to go into PoeNinja_JSON_IPD.ahk
       and adjust the values at the very top of the file to your needs.

       UNID- chaos recipe is the default behavior!
       Edit "\dependencies\__IPD_TEMPLATE.IPD" to generate different PICKIT outcomes.
       Edit "\dependencies\__MAPS_TEMPLATE.IPD" to generate different MAP outcomes.

       PICKIT -> check the template past line 250 to remove most likely "deprecated" stuff.
       MAP -> check section 3 to set ignored maps and similar correctly

       Feedback please to kintaro_oe Discord - or channel #pickit-ipd

       HAVE FUN!

