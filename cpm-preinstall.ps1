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
			pushd $scriptDir
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

Run "CPM_PreInstallation.zip" ".\RunCpmPreInstallation.ps1"
