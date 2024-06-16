SetWorkingDir, A_ScriptDir

; Delete the updated file if it already exists
updatedFile := "GENERATED_MAPS.ipd"
If FileExist(updatedFile)
    FileDelete, %updatedFile%

; List of files and their corresponding markers
filesAndMarkers := {"_MAPS.IPD": "//Runmap_"}

; Read the contents of the template file
FileRead, templateContent, %A_ScriptDir%\dependencies\__MAPS_TEMPLATE.IPD

; Write the updated content to a new file
FileAppend, %templateContent%, %updatedFile%

FileRead, IPD_Content, %A_ScriptDir%\IPD\IPD_DateAndTime.IPD
FileRead, Template_Content, GENERATED_MAPS.ipd
Template_Content := StrReplace(Template_Content, "//DateAndTime", IPD_Content)
FileDelete, GENERATED_MAPS.ipd
FileAppend, %Template_Content%, GENERATED_MAPS.ipd


FileRead, IPD_Content, %A_ScriptDir%\IPD\_MAPS.IPD
FileRead, Template_Content, GENERATED_MAPS.ipd
Template_Content := StrReplace(Template_Content, "//Runmap_", IPD_Content)
FileDelete, GENERATED_MAPS.ipd
FileAppend, %Template_Content%, GENERATED_MAPS.ipd
