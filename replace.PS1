# powershell -window minimized -command ""
Get-ChildItem *.ts | Rename-Item -NewName {$_.Name -replace "Смотреть сериал", ""}
Get-ChildItem *.ts | Rename-Item -NewName {$_.Name -replace "онлайн бесплатно в хорошем качестве", ''}


echo ::done
