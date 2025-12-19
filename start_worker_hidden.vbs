' VBScript to run start_worker.bat completely hidden without any visible windows
Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' Get the directory where this script is located
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)

' Run the batch file hidden (0 = hidden window, False = don't wait for it to finish)
WshShell.Run """" & scriptDir & "\start_worker.bat""", 0, False

Set WshShell = Nothing
Set fso = Nothing
