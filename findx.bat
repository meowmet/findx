@echo off
chcp 65001 > nul
color 0A
cls

:menu
echo #####################################################
echo #                                                   #
echo #  ███████╗██╗███╗   ██╗██████╗ ██╗  ██╗           #
echo #  ██╔════╝██║████╗  ██║██╔══██╗██║  ██║           #
echo #  █████╗  ██║██╔██╗ ██║██║  ██║╚═███╚═╝           #
echo #  ██╔══╝  ██║██║╚██╗██║██║  ██║██║  ██║           #
echo #  ██║     ██║██║ ╚████║██████╔╝██╗  ██╗           #
echo #  ╚═╝     ╚═╝╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝ FINDX     #
echo #                                                   #
echo #####################################################
echo.
echo  [1] Dosya Ara (Tüm Sürücülerde)
echo  [2] Çoklu Klasör Oluştur
echo  [3] Dosya Sıralama
echo  [4] Dosya İçerik Arama
echo  [5] Hızlı Dosya Kopyalama/Taşıma
echo  [6] Dosya Özellikleri Değiştirme
echo  [7] Toplu Dosya Yeniden Adlandırma
echo  [8] Dosya Karşılaştırma
echo  [9] Sistem Bilgisi Görüntüleme
echo  [10] Dosya Şifreleme/Şifre Çözme
echo  [11] Çıkış
echo.
set /p choice=Seçiminizi yapın (1-11): 
if "%choice%"=="1" goto search
if "%choice%"=="2" goto create_folders
if "%choice%"=="3" goto sort_files
if "%choice%"=="4" goto content_search
if "%choice%"=="5" goto file_operations
if "%choice%"=="6" goto file_attributes
if "%choice%"=="7" goto batch_rename
if "%choice%"=="8" goto compare_files
if "%choice%"=="9" goto system_info
if "%choice%"=="10" goto file_encryption
if "%choice%"=="11" exit
goto menu

:search
set /p filename=Aranacak dosya adını girin: 
echo Dosya aranıyor, lütfen bekleyin...
powershell -command "$searchPattern = '*%filename%*'; $foundFiles = Get-PSDrive -PSProvider FileSystem | ForEach-Object { Get-ChildItem $_.Root -Recurse -File -Filter $searchPattern -ErrorAction SilentlyContinue }; if ($foundFiles) { Write-Host 'Bulunan dosyalar:'; $foundFiles | ForEach-Object -Begin {$i=0} -Process { Write-Host (\"[$i] \" + $_.Name + ' - ' + $_.FullName); $i++ }; Write-Host \"`nToplam bulunan dosya sayısı: \" $foundFiles.Count; $foundFiles | ConvertTo-Json | Set-Content '%TEMP%\findx_files.json' } else { Write-Host 'Dosya bulunamadı.' }"

findstr /c:"Dosya bulunamadı" "%TEMP%\findx_results.txt" > nul 2>&1
if %errorlevel%==0 (
    del "%TEMP%\findx_files.json" 2>nul
    pause
    goto menu
)

echo.
echo İşlem Seçenekleri:
echo [1] Dosyayı Aç
echo [2] Klasörü Aç
echo [3] Ana Menüye Dön
echo.
set /p action=Seçiminizi yapın (1-3): 

if "%action%"=="1" (
    powershell -command "$foundFiles = Get-Content '%TEMP%\findx_files.json' | ConvertFrom-Json; if ($foundFiles.Count -gt 1) { Write-Host 'Lütfen açmak istediğiniz dosyanın numarasını girin (0-' ($foundFiles.Count-1) '):'; $index = Read-Host; if ($index -match '^\d+$' -and [int]$index -ge 0 -and [int]$index -lt $foundFiles.Count) { Invoke-Item $foundFiles[$index].FullName } else { Write-Host 'Geçersiz seçim!' } } elseif ($foundFiles.Count -eq 1) { Invoke-Item $foundFiles[0].FullName }"
) else if "%action%"=="2" (
    powershell -command "$foundFiles = Get-Content '%TEMP%\findx_files.json' | ConvertFrom-Json; if ($foundFiles.Count -gt 1) { Write-Host 'Lütfen açmak istediğiniz klasörün numarasını girin (0-' ($foundFiles.Count-1) '):'; $index = Read-Host; if ($index -match '^\d+$' -and [int]$index -ge 0 -and [int]$index -lt $foundFiles.Count) { explorer (Split-Path -Parent $foundFiles[$index].FullName) } else { Write-Host 'Geçersiz seçim!' } } elseif ($foundFiles.Count -eq 1) { explorer (Split-Path -Parent $foundFiles[0].FullName) }"
)

del "%TEMP%\findx_files.json" 2>nul
pause
goto menu

:create_folders
set /p foldername=Oluşturulacak klasör ismini girin: 
set /p foldercount=Kaç tane oluşturulsun?: 
for /l %%i in (1,1,%foldercount%) do mkdir "%foldername%%%i"
echo %foldercount% adet "%foldername%" klasörü oluşturuldu!
pause
goto menu

:sort_files
set /p targetdir=Sıralanacak klasörün yolunu girin: 
echo.
echo Sıralama Seçenekleri:
echo [1] Boyut (Büyükten Küçüğe)
echo [2] Boyut (Küçükten Büyüğe)
echo [3] Zaman (Büyükten Küçüğe)
echo [4] Zaman (Küçükten Büyüğe)
echo.
set /p sorttype=Sıralama türünü seçin (1-4): 

if "%sorttype%"=="1" (
    powershell -command "Get-ChildItem '%targetdir%' | Sort-Object Length -Descending | Format-Table Name,@{Name='Size(MB)';Expression={'{0:N2}' -f ($_.Length/1MB)}},LastWriteTime -AutoSize"
) else if "%sorttype%"=="2" (
    powershell -command "Get-ChildItem '%targetdir%' | Sort-Object Length | Format-Table Name,@{Name='Size(MB)';Expression={'{0:N2}' -f ($_.Length/1MB)}},LastWriteTime -AutoSize"
) else if "%sorttype%"=="3" (
    powershell -command "Get-ChildItem '%targetdir%' | Sort-Object LastWriteTime -Descending | Format-Table Name,@{Name='Size(MB)';Expression={'{0:N2}' -f ($_.Length/1MB)}},LastWriteTime -AutoSize"
) else if "%sorttype%"=="4" (
    powershell -command "Get-ChildItem '%targetdir%' | Sort-Object LastWriteTime | Format-Table Name,@{Name='Size(MB)';Expression={'{0:N2}' -f ($_.Length/1MB)}},LastWriteTime -AutoSize"
)
pause
goto menu

:content_search
echo Dosya İçerik Arama
echo -------------------
set /p searchdir=Aramayı yapacağınız klasörü girin: 
set /p searchterm=Aranacak metni girin: 
set /p filetype=Dosya türünü girin (örn: *.txt, *.docx veya * tüm dosyalar için): 
echo Arama yapılıyor, lütfen bekleyin...
powershell -command "Get-ChildItem -Path '%searchdir%' -Recurse -File -Filter '%filetype%' | Select-String '%searchterm%' -List | Select-Object Path,LineNumber | Format-Table -AutoSize"
pause
goto menu

:file_operations
echo Hızlı Dosya Kopyalama/Taşıma
echo ---------------------------
echo [1] Dosya Kopyala
echo [2] Dosya Taşı
echo [3] Ana Menüye Dön
set /p optype=İşlem türünü seçin (1-3): 
if "%optype%"=="3" goto menu
if not "%optype%"=="1" if not "%optype%"=="2" goto file_operations

set /p sourcefile=Kaynak dosya/klasör yolunu girin: 
set /p targetdir=Hedef klasör yolunu girin: 

if "%optype%"=="1" (
    powershell -command "Copy-Item -Path '%sourcefile%' -Destination '%targetdir%' -Recurse; Write-Host 'Kopyalama işlemi tamamlandı.'"
) else (
    powershell -command "Move-Item -Path '%sourcefile%' -Destination '%targetdir%'; Write-Host 'Taşıma işlemi tamamlandı.'"
)
pause
goto menu

:file_attributes
echo Dosya Özellikleri Değiştirme
echo ---------------------------
set /p filepath=Dosya/Klasör yolunu girin: 
echo.
echo Mevcut öznitelikler:
powershell -command "Get-ItemProperty -Path '%filepath%' | Select-Object Attributes"
echo.
echo [1] Salt okunur ekle/kaldır
echo [2] Gizli dosya yap/yapma
echo [3] Arşiv özniteliği ekle/kaldır
echo [4] Sistem dosyası yap/yapma
echo [5] Ana menüye dön
set /p attrib=İşlem seçin (1-5): 
if "%attrib%"=="5" goto menu

if "%attrib%"=="1" (
    echo [1] Ekle [2] Kaldır
    set /p attribop=İşlem: 
    if "%attribop%"=="1" attrib +R "%filepath%"
    if "%attribop%"=="2" attrib -R "%filepath%"
) else if "%attrib%"=="2" (
    echo [1] Ekle [2] Kaldır
    set /p attribop=İşlem: 
    if "%attribop%"=="1" attrib +H "%filepath%"
    if "%attribop%"=="2" attrib -H "%filepath%"
) else if "%attrib%"=="3" (
    echo [1] Ekle [2] Kaldır
    set /p attribop=İşlem: 
    if "%attribop%"=="1" attrib +A "%filepath%"
    if "%attribop%"=="2" attrib -A "%filepath%"
) else if "%attrib%"=="4" (
    echo [1] Ekle [2] Kaldır
    set /p attribop=İşlem: 
    if "%attribop%"=="1" attrib +S "%filepath%"
    if "%attribop%"=="2" attrib -S "%filepath%"
)
echo Öznitelikler değiştirildi.
pause
goto menu

:batch_rename
echo Toplu Dosya Yeniden Adlandırma
echo -----------------------------
set /p folder=Klasör yolunu girin: 
set /p pattern=Aranacak deseni girin (örn: *.jpg): 
set /p prefix=Yeni dosya adı öneki girin: 
set /p startnum=Başlangıç numarası girin: 

powershell -command "$i = %startnum%; Get-ChildItem -Path '%folder%' -Filter '%pattern%' | ForEach-Object { Rename-Item -Path $_.FullName -NewName (('%prefix%' + $i++) + $_.Extension) }"
echo Yeniden adlandırma tamamlandı.
pause
goto menu

:compare_files
echo Dosya Karşılaştırma
echo -----------------
set /p file1=İlk dosyanın yolunu girin: 
set /p file2=İkinci dosyanın yolunu girin: 
echo Dosyalar karşılaştırılıyor...
powershell -command "if (Test-Path '%file1%' -and Test-Path '%file2%') { $diff = Compare-Object -ReferenceObject (Get-Content '%file1%') -DifferenceObject (Get-Content '%file2%'); if ($diff) { $diff | ForEach-Object { if($_.SideIndicator -eq '=>') { Write-Host ('Yalnızca ikinci dosyada: ' + $_.InputObject) } else { Write-Host ('Yalnızca ilk dosyada: ' + $_.InputObject) } } } else { Write-Host 'Dosyalar aynı içeriğe sahip.' } } else { Write-Host 'Bir veya her iki dosya da bulunamadı.' }"
pause
goto menu

:system_info
echo Sistem Bilgisi
echo ------------
echo Bilgiler toplanıyor...
echo ----- CPU Bilgisi -----
powershell -command "Get-WmiObject Win32_Processor | Select-Object Name, NumberOfCores, MaxClockSpeed, LoadPercentage | Format-List"
echo.
echo ----- Bellek Bilgisi -----
powershell -command "$os = Get-WmiObject Win32_OperatingSystem; $totalMemory = [math]::Round($os.TotalVisibleMemorySize/1MB, 2); $freeMemory = [math]::Round($os.FreePhysicalMemory/1MB, 2); $usedMemory = $totalMemory - $freeMemory; Write-Host ('Toplam RAM: ' + $totalMemory + ' GB'); Write-Host ('Kullanılan RAM: ' + $usedMemory + ' GB (' + [math]::Round(($usedMemory/$totalMemory)*100, 0) + '%)'); Write-Host ('Boş RAM: ' + $freeMemory + ' GB')"
echo.
echo ----- Disk Bilgisi -----
powershell -command "Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | Select-Object DeviceID, VolumeName, @{Name='Size(GB)';Expression={[math]::Round($_.Size/1GB, 2)}}, @{Name='FreeSpace(GB)';Expression={[math]::Round($_.FreeSpace/1GB, 2)}}, @{Name='UsedSpace(GB)';Expression={[math]::Round(($_.Size - $_.FreeSpace)/1GB, 2)}}, @{Name='Usage(%)';Expression={[math]::Round((($_.Size - $_.FreeSpace)/$_.Size)*100, 0)}} | Format-Table -AutoSize"
echo.
echo ----- İşletim Sistemi Bilgisi -----
powershell -command "Get-WmiObject Win32_OperatingSystem | Select-Object Caption, Version, OSArchitecture, InstallDate | Format-List"
pause
goto menu

:file_encryption
echo Dosya Şifreleme/Şifre Çözme
echo --------------------------
echo [1] Dosya Şifrele
echo [2] Dosya Şifresini Çöz
echo [3] Ana Menüye Dön
set /p enctype=İşlem seçin (1-3): 
if "%enctype%"=="3" goto menu

set /p filepath=Dosya yolunu girin: 
set /p password=Şifre girin: 

if "%enctype%"=="1" (
    echo Dosya şifreleniyor...
    powershell -command "$bytes = [System.IO.File]::ReadAllBytes('%filepath%'); $secure = ConvertTo-SecureString '%password%' -AsPlainText -Force; $encrypted = ConvertFrom-SecureString $secure; $encryptedPath = '%filepath%.encrypted'; [System.IO.File]::WriteAllText($encryptedPath, $encrypted); Write-Host 'Dosya şifrelendi: ' $encryptedPath"
) else if "%enctype%"=="2" (
    echo Dosya şifresi çözülüyor...
    powershell -command "try { $encrypted = [System.IO.File]::ReadAllText('%filepath%'); $secure = ConvertTo-SecureString $encrypted; $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure); $decrypted = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($ptr); $decryptedPath = '%filepath%.decrypted'; [System.IO.File]::WriteAllText($decryptedPath, $decrypted); Write-Host 'Dosya şifresi çözüldü: ' $decryptedPath } catch { Write-Host 'Şifre çözme hatası. Yanlış şifre veya hasar görmüş dosya.' }"
)
pause
goto menu