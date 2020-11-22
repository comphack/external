$ErrorActionPreference = "Stop"

$ROOT_DIR = $(Get-Location).Path

Write-Output "Platform      = ${env:PLATFORM}"
Write-Output "MS Platform   = ${env:MSPLATFORM}"
Write-Output "Configuration = ${env:CONFIGURATION}"
Write-Output "Generator     = ${env:GENERATOR}"

Invoke-WebRequest "${env:OPENSSL_URL}" -OutFile "OpenSSL.msi"
Start-Process msiexec.exe -Wait -ArgumentList '/i OpenSSL.msi /l OpenSSL-install.log /qn'
Remove-Item OpenSSL.msi
Remove-Item OpenSSL-install.log

New-Item -ItemType directory -Path build | Out-Null
Set-Location build

cmake -DCMAKE_INSTALL_PREFIX="${ROOT_DIR}/build/install" -DCMAKE_CUSTOM_CONFIGURATION_TYPES="${env:CONFIGURATION}" -DOPENSSL_ROOT_DIR="${env:OPENSSL_ROOT_DIR}" -DUSE_SYSTEM_OPENSSL=ON -G"${env:GENERATOR}" ..
cmake --build . --config "${env:CONFIGURATION}"
cmake --build . --config "${env:CONFIGURATION}" --target package

Move-Item external-0.1.1-*.zip "${ROOT_DIR}/external-${env:PLATFORM}-${env:COMPILER}.zip"
