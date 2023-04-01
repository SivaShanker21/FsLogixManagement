<#
     .REQUIREMENTS
        Read and write access to the SMB share
        AD Powershell Module
     .SYNOPSIS
        Cleanup orphan FsLogix profile
    .DESCRIPTION
        Retrieves all orphan AVD Fslogix profile and delete it
    .NOTES
        Author: Siva Shanker Balakrishnan
    .INPUTS
        You will need to enter the SMB location
    .DISCLAIMER
        Please test the script in QC before using it in PROD.

#>

$loc= "us"
$stgnetworkpath = "\\servernameFQDN\userprofileshare"

$allProfileFolder = Get-ChildItem -Path $stgnetworkpath
[array]$usernames=@()
[array]$notinad=@()
$currentdate = Get-Date -Format ddMMyyyy
foreach($profileFolder in $allProfileFolder ){

   $username = $profileFolder.Name
   $remove = $username.IndexOf("_")
   $adname = $username.Substring(0,$remove)

   $testuser = try{
    Get-ADUser -Filter 'SamAccountName -eq $adname'
   }catch{

      $null

   }

   if($testuser -eq $null){
        $notinad += $adname
        Remove-Item -Path "$stgnetworkpath\$profileFolder" -Force -Recurse

   }
}

$notinad | Out-File -FilePath "C:\temp\$($loc)_removed_UserProfile_$($currentdate).txt" -Force

Write-Host "Total orphan found:"$notinad.Count -ForegroundColor Red