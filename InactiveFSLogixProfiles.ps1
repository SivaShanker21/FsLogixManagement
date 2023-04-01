<#
     .REQUIREMENTS
        Read and write access to the SMB share
     .SYNOPSIS
        Gets or Gets and Delete inavtive FsLogix profile  
    .DESCRIPTION
        Retrieves all AVD Fslogix inactive profile past X days
    .NOTES
        Author: Siva Shanker Balakrishnan
    .INPUTS
        You will need to enter the SMB location
    .DISCLAIMER
        Please test the script in QC before using it in PROD.

#>


$loc= "us" # set storage location for report/export result if you have more than one storage location
$stgnetworkpath = "\\servernameFQDN\userprofileshare" # Fslogix user profile SMB path
$date = Get-Date -Format 'ddMMyyyy'
$Days = "30" # Number of days before current date
#Calculate Cutoff date
$CutoffDate = (Get-Date).AddDays(-$Days)

$allProfileFolder = Get-ChildItem -Path $stgnetworkpath
[array]$vhds = @()

foreach($profileFolder in $allProfileFolder){
    
   $vhd = Get-ChildItem -Path "$($stgnetworkpath)\$($profileFolder)" -Filter 'Profile*' 
    
    If($vhd.LastWriteTime -lt $CutoffDate) {
        
        $username = $profileFolder.Name
        $remove = $username.IndexOf("_")
        $adname = $username.Substring(0,$remove)

        $vhds += $vhd
        Write-Host "Removing $($adname)" -ForegroundColor White -BackgroundColor Red
        #Remove-Item -Path "$($stgnetworkpath)\$($profileFolder)" -Force -Recurse #Remove the comment block if you want to delete inactive user profile
    }

}

$vhds | select Name,LastWriteTime,LastAccessTime | Sort-Object LastWriteTime | Export-Csv -Path "C:\temp\$($loc)_fslogix_profilelastwrite_$($date).csv" -NoTypeInformation
$vhds.Count