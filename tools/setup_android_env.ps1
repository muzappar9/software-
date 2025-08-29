<#
Setup Android SDK environment variables (PowerShell).
Edit the variables below to match your installation paths, then run this script as a normal user.

Usage (PowerShell):
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
  .\setup_android_env.ps1

After running, open a new PowerShell or run:
  $env:ANDROID_SDK_ROOT = [System.Environment]::GetEnvironmentVariable("ANDROID_SDK_ROOT","User")
  $env:JAVA_HOME = [System.Environment]::GetEnvironmentVariable("JAVA_HOME","User")

Then run:
  flutter doctor --android-licenses
  flutter doctor -v

#> 

## === Edit these to your actual install locations ===
$userSdk = "C:\Users\<you>\AppData\Local\Android\Sdk"
$javaHome = "C:\Program Files\Android\Android Studio\jbr"

Write-Host "Setting ANDROID_SDK_ROOT to $userSdk"
setx ANDROID_SDK_ROOT $userSdk | Out-Null
Write-Host "Setting JAVA_HOME to $javaHome"
setx JAVA_HOME $javaHome | Out-Null

Write-Host "Done. To apply in current session run:`n`$env:ANDROID_SDK_ROOT = [System.Environment]::GetEnvironmentVariable('ANDROID_SDK_ROOT','User')`n`$env:JAVA_HOME = [System.Environment]::GetEnvironmentVariable('JAVA_HOME','User')"

Write-Host "If you haven't installed Android Studio, please download and install it first: https://developer.android.com/studio"

