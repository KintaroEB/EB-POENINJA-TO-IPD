SetWorkingDir, A_ScriptDir

; Delete the updated file if it already exists
updatedFile := "GENERATED_PICKIT.ipd"
If FileExist(updatedFile)
    FileDelete, %updatedFile%

; List of files and their corresponding markers
filesAndMarkers := { "IPD\IPD_Currency.IPD":        "//Currency"
					,"IPD\IPD_Fragment.IPD":        "//Fragment"
					,"IPD\IPD_Runegraft.IPD":       "//Runegraft"
					,"IPD\IPD_AllflameEmber.IPD":   "//AllflameEmber"
					,"IPD\IPD_Tattoo.IPD":          "//Tattoo"
					,"IPD\IPD_Omen.IPD":            "//Omen"
					,"IPD\IPD_DivinationCard.IPD":  "//DivinationCard"
					,"IPD\IPD_Artifact.IPD":        "//Artifact"
					,"IPD\IPD_Oil.IPD":             "//Oil"
					,"IPD\IPD_DeliriumOrb.IPD":     "//DeliriumOrb"
					,"IPD\IPD_Scarab.IPD":          "//Scarab"
					,"IPD\IPD_Fossil.IPD":          "//Fossil"
					,"IPD\IPD_Resonator.IPD":       "//Resonator"
					,"IPD\IPD_Essence.IPD":         "//Essence"
					,"IPD\IPD_Incubator.IPD":       "//Incubator"
					,"IPD\IPD_Invitation.IPD":      "//Invitation"
					,"IPD\IPD_Memory.IPD":          "//Memory"
					,"IPD\IPD_Beast.IPD":           "//Beast"
					,"IPD\IPD_Vial.IPD":            "//Vial"
					,"IPD\IPD_UniqueWeapon.IPD":    "//UniqueWeapon"
					,"IPD\IPD_UniqueArmour.IPD":    "//UniqueArmour"
					,"IPD\IPD_UniqueAccessory.IPD": "//UniqueAccessory"
					,"IPD\IPD_UniqueFlask.IPD":     "//UniqueFlask"
					,"IPD\IPD_UniqueJewel.IPD":     "//UniqueJewel"
					,"IPD\IPD_UniqueTincture.IPD":  "//UniqueTincture"
					,"IPD\IPD_UniqueRelic.IPD":     "//UniqueRelic"
					,"IPD\IPD_UniqueMap.IPD":       "//UniqueMap" }


; Read the contents of the template file
FileRead, templateContent, %A_ScriptDir%\dependencies\__PICKIT_TEMPLATE.IPD

; Loop through each file-marker pair
for fileName, marker in filesAndMarkers
{
    ; Read the contents of the current file
    FileRead, fileContent, %fileName%
    
    ; Find the position where to insert the content after the marker
    insertPosition := InStr(templateContent, marker) + StrLen(marker)
    
    ; Insert the file content into the template content
    if (insertPosition)
        templateContent := SubStr(templateContent, 1, insertPosition) . fileContent . "`n" . SubStr(templateContent, insertPosition)
}

; Write the updated content to a new file
FileAppend, %templateContent%, %updatedFile%

FileRead, IPD_Content, %A_ScriptDir%\IPD\IPD_DateAndTime.IPD
FileRead, Template_Content, GENERATED_PICKIT.ipd
Template_Content := StrReplace(Template_Content, "//DateAndTime", IPD_Content)
FileDelete, GENERATED_PICKIT.ipd
FileAppend, %Template_Content%, GENERATED_PICKIT.ipd

