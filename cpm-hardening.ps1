#
# CPM_Hardening.ps1
#
function Add-LogErrorDetails{
	[CmdletBinding()] 
	param(
		$Exception
	)

	Process {
		if ($Exception -ne $null){
			$ErrorMessage = $Exception.Message
			Write-Host "The following error occurred: $ErrorMessage" "Error"
		} else {
			Write-Host "An uncaught error occurred" "Error"
		}
	}
	End{
   }
}

Function Run{
	[CmdletBinding()] 
	Param(
		$zipFileName,
		$startScript
	)
	
	Process{
		
		Write-Host "Start Execution"
		Write-Host "current location:  $pwd"
				
		$zipFilePath = "$pwd\$zipFileName"
		Write-Host "zip file path:  $zipFilePath"
					
		try{
			$now = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
			$scriptDir = "$pwd\$now"
			Write-Host "Create working directory: $scriptDir"
			mkdir "$scriptDir" > $null
			Copy-Item -Path $pwd\"CPM_Hardening_Config.xml" -Destination $scriptDir\"CPM_Hardening_Config.xml"
			cd $scriptDir
		} catch {
			Write-Host "Error creating working directory"
			Add-LogErrorDetails $_.Exception
			return $null
		}
		
		try{
			Write-Host "Add zip compression type"
			Add-Type -assembly "system.io.compression.filesystem"
			
			
			Write-Host "Extract zip file to : $scriptDir"
			[System.IO.Compression.ZipFile]::ExtractToDirectory($zipFilePath, $scriptDir)
		} catch {
			Write-Host "Error unzipping $zipFilePath"
			Add-LogErrorDetails $_.Exception
			return $null
		}

		try{
			Write-Host "Run script $startScript"
			$scriptResult = . $startScript
			Start-Process powershell -argument ".\AddiMacrosRegistryToCPMLocalUser.ps1" -NoNewWindow -Wait
		} catch {
			Write-Host "Error running script $startScript"
			Add-LogErrorDetails $_.Exception
			return $null
		} 
		
		try{
			Write-Host "Cleanup - Delete files except logs and backup"
			Remove-Item -Path * -Exclude *.log,*.backup -ErrorAction SilentlyContinue
		} catch {
			Write-Host "Error cleaning up"
			Add-LogErrorDetails $_.Exception
		} 
		
		Write-Host "Finish Execution"
		return $scriptResult
	}
}

$initialPwd = $pwd.Path
Run "CPM_Hardening.zip" ".\RunCPMHardening.ps1"
cd $initialPwd 
