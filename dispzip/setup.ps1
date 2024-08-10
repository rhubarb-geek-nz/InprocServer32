# Copyright (c) 2024 Roger Brown.
# Licensed under the MIT License.

param([switch]$UnregServer)

trap
{
	throw $PSItem
}

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

$ProcessArchitecture = $Env:PROCESSOR_ARCHITECTURE.ToLower()

switch ($ProcessArchitecture)
{
	'amd64' { $ProcessArchitecture = 'x64' }
}

$ProgramFiles = $Env:ProgramFiles

$CompanyDir = Join-Path -Path $ProgramFiles -ChildPath 'rhubarb-geek-nz'
$ProductDir = Join-Path -Path $CompanyDir -ChildPath 'InprocServer32'
$InstallDir = Join-Path -Path $ProductDir -ChildPath $ProcessArchitecture
$DllName = 'RhubarbGeekNzInprocServer32.dll'
$DllPath = Join-Path -Path $InstallDir -ChildPath $DllName

$CLSID = '{A2B77E14-CA38-4333-A85E-5DB7D4566CA2}'
$LIBID = '{6D87ADD0-284B-4414-B5C3-9800E19A234E}'
$LIBVER = '0.0'
$IID = '{B45D5AF8-F3B2-4895-BBC8-02610E9E50CC}'
$PROGID = 'RhubarbGeekNz.InprocServer32'

if ($UnregServer)
{
	$DllPath, $InstallDir, $ProductDir | ForEach-Object {
		$FilePath = $_
		if (Test-Path $FilePath)
		{
			Remove-Item -LiteralPath $FilePath
		}
	}

	if (Test-Path $CompanyDir)
	{
		$children = Get-ChildItem -LiteralPath $CompanyDir

		if (-not $children)
		{
			Remove-Item -LiteralPath $CompanyDir
		}
	}

	foreach ($RegistryPath in 
		"HKLM:\SOFTWARE\Classes\CLSID\$CLSID\InprocServer32",
		"HKLM:\SOFTWARE\Classes\CLSID\$CLSID",
		"HKLM:\SOFTWARE\Classes\$PROGID\CLSID",
		"HKLM:\SOFTWARE\Classes\$PROGID",
		"HKLM:\SOFTWARE\Classes\TypeLib\$LIBID\$LIBVER\0\win32",
		"HKLM:\SOFTWARE\Classes\TypeLib\$LIBID\$LIBVER\0\win64",
		"HKLM:\SOFTWARE\Classes\TypeLib\$LIBID\$LIBVER\0",
		"HKLM:\SOFTWARE\Classes\TypeLib\$LIBID\$LIBVER\FLAGS",
		"HKLM:\SOFTWARE\Classes\TypeLib\$LIBID\$LIBVER\HELPDIR",
		"HKLM:\SOFTWARE\Classes\TypeLib\$LIBID\$LIBVER",
		"HKLM:\SOFTWARE\Classes\TypeLib\$LIBID",
		"HKLM:\SOFTWARE\Classes\Interface\$IID\ProxyStubClsid32",
		"HKLM:\SOFTWARE\Classes\Interface\$IID\ProxyStubClsid",
		"HKLM:\SOFTWARE\Classes\Interface\$IID\TypeLib",
		"HKLM:\SOFTWARE\Classes\Interface\$IID"
	)
	{
		if (Test-Path $RegistryPath)
		{
			Remove-Item -Path $RegistryPath
		}
	}
}
else
{
	if (Test-Path $DllPath)
	{
		Write-Warning "$DllPath is already installed"
	}
	else
	{
		$SourceDir = Join-Path -Path $PSScriptRoot -ChildPath $ProcessArchitecture
		$SourceFile = Join-Path -Path $SourceDir -ChildPath $DllName

		if (-not (Test-Path $SourceFile))
		{
			Write-Error "$SourceFile does not exist"
		}
		else
		{
			$CompanyDir, $ProductDir, $InstallDir | ForEach-Object {
				$FilePath = $_
				if (-not (Test-Path $FilePath))
				{
					$Null = New-Item -Path $FilePath -ItemType 'Directory'
				}
			}

			Copy-Item $SourceFile $DllPath
		}

		$RegistryPath = "HKLM:\SOFTWARE\Classes\CLSID\$CLSID\InprocServer32"

		if (Test-Path $RegistryPath)
		{
			$null = Set-Item -Path $RegistryPath -Value $DllPath
		}
		else
		{
			$null = New-Item -Path $RegistryPath -Value $DllPath -Force
		}

		$null = New-ItemProperty -Path $RegistryPath -Name 'ThreadingModel' -Value 'Both' -PropertyType 'String'

		$RegistryPath = "HKLM:\SOFTWARE\Classes\$PROGID\CLSID"

		if (Test-Path $RegistryPath)
		{
			$null = Set-Item -Path $RegistryPath -Value $CLSID
		}
		else
		{
			$null = New-Item -Path $RegistryPath -Value $CLSID -Force
		}

		$RegistryPath = "HKLM:\SOFTWARE\Classes\Interface\$IID\ProxyStubClsid32"

		if (Test-Path $RegistryPath)
		{
			$null = Set-Item -Path $RegistryPath -Value '{00020424-0000-0000-C000-000000000046}'
		}
		else
		{
			$null = New-Item -Path $RegistryPath -Value '{00020424-0000-0000-C000-000000000046}' -Force
		}

		$RegistryPath = "HKLM:\SOFTWARE\Classes\Interface\$IID\TypeLib"

		if (Test-Path $RegistryPath)
		{
			$null = Set-Item -Path $RegistryPath -Value $LIBID
		}
		else
		{
			$null = New-Item -Path $RegistryPath -Value $LIBID -Force
		}

		$null = New-ItemProperty -Path $RegistryPath -Name 'Version' -Value $LIBVER -PropertyType 'String'

		Add-Type -TypeDefinition @"
			using System;
			using System.ComponentModel;
			using System.Runtime.InteropServices;

			namespace RhubarbGeekNz.InprocServer32
			{
				public class InterOp
				{
					[DllImport("oleaut32.dll", CharSet = CharSet.Unicode, PreserveSig = false)]
					private static extern void LoadTypeLibEx(string szFile, uint regkind, out IntPtr pptlib);

					public static void RegisterTypeLib(string path)
					{
						IntPtr punk;
						LoadTypeLibEx(path, 1, out punk);
						Marshal.Release(punk);
					}
				}
			}
"@

		[RhubarbGeekNz.InprocServer32.InterOp]::RegisterTypeLib($DllPath)
	}
}
