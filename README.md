# EB-POENINJA-TO-IPD
JSON to IPD

usage -> poe_ninja_json_to_ipd.ahk -> generate_IPD.ahk

       The script uses a Library from https://github.com/cocobelgica/AutoHotkey-JSON
       to convert a given JSON file into ExileBot usable IPD structure. JSON data is
       being pulled from "poe.ninja/api/data".
       "chaosValues" can be adjusted to limit the results for uniques.
       
       Array "allCategories" can be filled with desired categories to pull from.
       Each entry will receive it's own named output file respectively. The RAW
       JSON data remains untouched for verification purposes.

       Everything is pulled by default! You have to go into poe_ninja_json_to_ipd.ahk
       and adjust the values at the very top of the file to your needs.

       UNID- chaos recipe is the default behavior!
       Edit "\dependencies\__IPD_TEMPLATE.IPD" to generate different outcomes.

       Check the template past line 250 to remove most likely "deprecated" stuff.

       Feedback please to kintaro_oe Discord - or channel #pickit-ipd

       HAVE FUN!

