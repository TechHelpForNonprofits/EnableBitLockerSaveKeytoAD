$vol = (get-wmiobject -Class Win32_Volume | where{$_.drivetype -eq '5'}  )
$Eject =  New-Object -comObject Shell.Application
$Eject.NameSpace(17).ParseName($vol.driveletter).InvokeVerb(“Eject”)

Start-Sleep -s 8

$keyID = Get-BitLockerVolume -MountPoint c: | select -ExpandProperty keyprotector | 
            where {$_.KeyProtectorType -eq 'RecoveryPassword'} #captures key

If ($keyID -eq $Null) {
    cmd /c manage-bde.exe -protectors -add c: -recoverypassword #generates a Numerical Password
    $keyID = Get-BitLockerVolume -MountPoint c: | select -ExpandProperty keyprotector | 
            where {$_.KeyProtectorType -eq 'RecoveryPassword'} #captures key
}

Backup-BitLockerKeyProtector -MountPoint c: -KeyProtectorId $keyID.KeyProtectorId
Enable-BitLocker -MountPoint C: -SkipHardwareTest -RecoveryPasswordProtector






