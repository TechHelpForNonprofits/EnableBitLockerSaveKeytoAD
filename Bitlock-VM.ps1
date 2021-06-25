#This works for Hyper-V virtual machines only
#finds the mounted ISO and ejects it since Bitlocker won't work if it's still mounted
$vol = (get-wmiobject -Class Win32_Volume | where{$_.drivetype -eq '5'} )
$Eject =  New-Object -comObject Shell.Application
$Eject.NameSpace(17).ParseName($vol.driveletter).InvokeVerb(“Eject”)

Start-Sleep -s 8

#checks for key and if one doesn't exist it generates one
$keyID = Get-BitLockerVolume -MountPoint c: | select -ExpandProperty keyprotector | 
            where {$_.KeyProtectorType -eq 'RecoveryPassword'} #captures key

If ($keyID -eq $Null) {
    cmd /c manage-bde.exe -protectors -add c: -recoverypassword #generates a Numerical Password
    $keyID = Get-BitLockerVolume -MountPoint c: | select -ExpandProperty keyprotector | 
            where {$_.KeyProtectorType -eq 'RecoveryPassword'} #captures key
}

#enables Bitlocker and saves key to AD
Backup-BitLockerKeyProtector -MountPoint c: -KeyProtectorId $keyID.KeyProtectorId
Enable-BitLocker -MountPoint C: -SkipHardwareTest -RecoveryPasswordProtector






