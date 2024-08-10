# Copyright (c) 2024 Roger Brown.
# Licensed under the MIT License.

param(
	$ProgID = 'RhubarbGeekNz.InprocServer32',
	$Method = 'GetMessage',
	$Hint = @(1, 2, 3, 4, 5)
)

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

$helloWorld = New-Object -ComObject $ProgID

foreach ($h in $hint)
{
	$result = $helloWorld.$Method($h)

	"$h $result"
}
