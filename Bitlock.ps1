#Used to enable Bitlocker on physical or HyperV VMs. 
#Dismounts external device

$vol= (Get-WmiObject -Class Win32_Volume | where {$_.drivetype -eq '2' -or $_.drivetype -eq '5'}  )

foreach ($disks in $vol)  {
    $Eject =  New-Object -comObject Shell.Application
    $Eject.NameSpace(17).ParseName($disks.driveletter).InvokeVerb("Eject")
}

Start-Sleep -s 8

#generates key if one does not exist
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






