# Script de creation du keystore et key.properties pour le Play Store
# Execute dans PowerShell : cd android puis .\setup_keystore.ps1

$keystoreName = "upload-keystore.jks"
$alias = "upload"
$keyPropsPath = "key.properties"

# Trouver keytool (JDK) - obligatoire pour creer le keystore
$keytoolExe = $null
if (Get-Command keytool -ErrorAction SilentlyContinue) {
    $keytoolExe = "keytool"
}
if (-not $keytoolExe -and $env:JAVA_HOME) {
    $jdkKeytool = Join-Path $env:JAVA_HOME "bin\keytool.exe"
    if (Test-Path $jdkKeytool) { $keytoolExe = $jdkKeytool }
}
if (-not $keytoolExe -and (Test-Path "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe")) {
    $keytoolExe = "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
}
if (-not $keytoolExe -and (Test-Path "C:\Program Files\Android\Android Studio\jre\bin\keytool.exe")) {
    $keytoolExe = "C:\Program Files\Android\Android Studio\jre\bin\keytool.exe"
}
if (-not $keytoolExe) {
    $paths = Get-ChildItem "C:\Program Files\Java" -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "jdk" }
    foreach ($p in $paths) {
        $kt = Join-Path $p.FullName "bin\keytool.exe"
        if (Test-Path $kt) { $keytoolExe = $kt; break }
    }
}
if (-not $keytoolExe) {
    $paths = Get-ChildItem "C:\Program Files\Eclipse Adoptium" -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "jdk" }
    foreach ($p in $paths) {
        $kt = Join-Path $p.FullName "bin\keytool.exe"
        if (Test-Path $kt) { $keytoolExe = $kt; break }
    }
}
if (-not $keytoolExe) {
    Write-Host "Erreur : keytool (JDK) introuvable." -ForegroundColor Red
    Write-Host ""
    Write-Host "keytool est fourni par le JDK (Java). Sans Android Studio, installez un JDK :" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Option simple - Eclipse Temurin (gratuit) :" -ForegroundColor Cyan
    Write-Host "    1. Allez sur : https://adoptium.net/temurin/releases/" -ForegroundColor White
    Write-Host "    2. Choisissez : Windows x64, JDK 17 (LTS), .msi" -ForegroundColor White
    Write-Host "    3. Installez en cochant 'Set JAVA_HOME' et 'Java PATH'" -ForegroundColor White
    Write-Host "    4. Fermez ce terminal, rouvrez-le, puis relancez setup_keystore.bat" -ForegroundColor White
    Write-Host ""
    Write-Host "  Ou installez Android Studio (inclut un JDK) : https://developer.android.com/studio" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "=== Configuration du bundle signe Play Store ===" -ForegroundColor Cyan
Write-Host ""

# Verifier si le keystore existe deja
if (Test-Path $keystoreName) {
    Write-Host "Le fichier $keystoreName existe deja." -ForegroundColor Yellow
    $overwrite = Read-Host "Ecraser ? (o/N)"
    if ($overwrite -ne "o" -and $overwrite -ne "O") {
        Write-Host "Annule. Configurez manuellement android/key.properties" -ForegroundColor Yellow
        exit 0
    }
    Remove-Item $keystoreName -Force
}

# Demander les mots de passe (masques)
$secStore = Read-Host "Mot de passe du keystore" -AsSecureString
$storePass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secStore))
$secKey = Read-Host "Mot de passe de la cle (Enter = meme que keystore)" -AsSecureString
$keyPass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secKey))
if ([string]::IsNullOrWhiteSpace($keyPass)) { $keyPass = $storePass }

# Infos pour le certificat (modifiables)
$dname = "CN=AESD Buzz, OU=Mobile, O=AESD, L=Paris, ST=IDF, C=FR"

Write-Host ""
Write-Host "Creation du keystore..." -ForegroundColor Green
& $keytoolExe -genkey -v -keystore $keystoreName -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias $alias -storepass $storePass -keypass $keyPass -dname $dname

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erreur lors de la creation du keystore." -ForegroundColor Red
    exit 1
}

# Chemin relatif pour key.properties (le keystore est dans android/)
$storeFileRel = $keystoreName

$keyPropsContent = @"
storePassword=$storePass
keyPassword=$keyPass
keyAlias=$alias
storeFile=$storeFileRel
"@

Set-Content -Path $keyPropsPath -Value $keyPropsContent -Encoding UTF8
Write-Host ""
Write-Host "Fichier $keyPropsPath cree." -ForegroundColor Green
Write-Host ""
Write-Host "=== Termine ===" -ForegroundColor Cyan
Write-Host "  - Keystore : android/$keystoreName"
Write-Host "  - Config   : android/$keyPropsPath"
Write-Host ""
Write-Host "Prochaine etape (a la racine du projet) :" -ForegroundColor Yellow
Write-Host "  flutter clean"
Write-Host "  flutter pub get"
Write-Host "  flutter build appbundle"
Write-Host ""
Write-Host "Le bundle signe sera dans : build/app/outputs/bundle/release/app-release.aab" -ForegroundColor Cyan
Write-Host ""
