# SUPER DESBLOQUEIO DE WALLPAPER COM SANTOS
# Execute como ADMINISTRADOR

# Verifica se e Administrador
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERRO: EXECUTE COMO ADMINISTRADOR!" -ForegroundColor Red
    Write-Host "Botao direito > Executar como Administrador" -ForegroundColor Yellow
    pause
    exit
}

Clear-Host
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "           SUPER DESBLOQUEIO WALLPAPER" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Inicia o hino em background
Write-Host "[INFO] Iniciando processo de restauracao..." -ForegroundColor Gray
$hinoJob = Start-Job -ScriptBlock {
    try {
        $hinoUri = 'https://drive.google.com/uc?export=download&id=12FNjsJfyjL5S9yQd1vWGA6yggjhPlsue'
        $hinoPath = "$env:TEMP\santos_hino.mp3"
        
        Invoke-WebRequest -Uri $hinoUri -OutFile $hinoPath -UseBasicParsing
        
        if (Test-Path $hinoPath) {
            Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Audio {
    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);
    public static void SetMaxVolume() {
        for (int i = 0; i < 50; i++) {
            keybd_event(0xAF, 0, 0, UIntPtr.Zero);
            System.Threading.Thread.Sleep(20);
        }
    }
}
"@
            [Audio]::SetMaxVolume()
            
            $player = New-Object -ComObject WMPlayer.OCX
            $player.settings.volume = 100
            $player.URL = $hinoPath
            $player.controls.play()
            
            Start-Sleep -Seconds 30
            $player.controls.stop()
        }
    } catch { }
}

# 1. PARA PROCESSOS
Write-Host "[1/6] Parando processos..." -ForegroundColor Cyan
Get-Process powershell -ErrorAction SilentlyContinue | Where-Object { 
    $_.CommandLine -like "*wallpaper*" -or $_.CommandLine -like "*neymar*" 
} | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Host "   Processos removidos" -ForegroundColor Green

# 2. REMOVE ARQUIVOS
Write-Host "[2/6] Removendo arquivos..." -ForegroundColor Cyan
$filesToRemove = @(
    "$env:TEMP\neymar_wallpaper.jpg",
    "$env:TEMP\wallpaper_monitor.ps1",
    "$env:TEMP\wallpaper_keeper.ps1", 
    "$env:TEMP\restore_wallpaper.ps1"
)

foreach ($file in $filesToRemove) {
    if (Test-Path $file) {
        Remove-Item $file -Force -ErrorAction SilentlyContinue
    }
}
Write-Host "   Arquivos temporarios limpos" -ForegroundColor Green

# 3. REMOVE TAREFAS
Write-Host "[3/6] Removendo tarefas..." -ForegroundColor Cyan
$tasks = @("WallpaperKeeper", "WallpaperRestorer", "WallpaperMonitor")
foreach ($task in $tasks) {
    try {
        Unregister-ScheduledTask -TaskName $task -Confirm:$false -ErrorAction SilentlyContinue
    } catch { }
}
Write-Host "   Tarefas agendadas removidas" -ForegroundColor Green

# 4. LIMPA REGISTRO DO USUARIO
Write-Host "[4/6] Limpando registro do usuario..." -ForegroundColor Cyan
$desktopPath = "HKCU:\Control Panel\Desktop"
Remove-ItemProperty -Path $desktopPath -Name "Wallpaper" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path $desktopPath -Name "WallpaperStyle" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path $desktopPath -Name "TileWallpaper" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path $desktopPath -Name "ConvertedWallpaper" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path $desktopPath -Name "OriginalWallpaper" -ErrorAction SilentlyContinue

$userPolicies = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies"
if (Test-Path $userPolicies) {
    Get-ChildItem $userPolicies -Recurse | ForEach-Object {
        Remove-ItemProperty -Path $_.PSPath -Name "*" -ErrorAction SilentlyContinue
    }
}
Write-Host "   Registro do usuario limpo" -ForegroundColor Green

# 5. LIMPA REGISTRO DO SISTEMA
Write-Host "[5/6] Limpando registro do sistema..." -ForegroundColor Cyan
$systemPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
)

foreach ($path in $systemPaths) {
    if (Test-Path $path) {
        Remove-ItemProperty -Path $path -Name "NoChangingWallPaper" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $path -Name "NoDispBackgroundPage" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $path -Name "NoThemesTab" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $path -Name "NoControlPanel" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $path -Name "ForceDefaultWallpaper" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $path -Name "Wallpaper" -ErrorAction SilentlyContinue
    }
}
Write-Host "   Registro do sistema limpo" -ForegroundColor Green

# 6. CONFIGURA NOVO WALLPAPER
Write-Host "[6/6] Configurando novo wallpaper..." -ForegroundColor Cyan
try {
    $wallpaperUri = 'https://drive.google.com/uc?export=download&id=1ThfoNjxAjjnr4kGQSLSHTnzfvqnRvCxO'
    $wallpaperPath = "$env:TEMP\santos_wallpaper.jpg"
    
    Invoke-WebRequest -Uri $wallpaperUri -OutFile $wallpaperPath -UseBasicParsing
    
    if (Test-Path $wallpaperPath) {
        Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
        [Wallpaper]::SystemParametersInfo(0x0014, 0, $wallpaperPath, 0x01 -bor 0x02)
        
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper" -Value $wallpaperPath -Force
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallpaperStyle" -Value "6" -Force
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "TileWallpaper" -Value "0" -Force
        
        Write-Host "   Wallpaper aplicado com sucesso" -ForegroundColor Green
    }
} catch {
    Write-Host "   Erro ao aplicar wallpaper" -ForegroundColor Red
}

# Aplica mudancas
rundll32.exe user32.dll, UpdatePerUserSystemParameters 1, True
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue

# Espera o hino terminar
Start-Sleep -Seconds 3

# RESULTADO FINAL
Clear-Host
Write-Host "==================================================" -ForegroundColor Green
Write-Host "           DESBLOQUEIO CONCLUIDO!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""
Write-Host "[OK] Todas as travas foram removidas" -ForegroundColor Cyan
Write-Host "[OK] Permissoes de personalizacao restauradas" -ForegroundColor Cyan
Write-Host "[OK] Wallpaper do Santos aplicado" -ForegroundColor Cyan
Write-Host "[OK] Hino do Santos executado" -ForegroundColor Cyan
Write-Host ""
Write-Host "*** AGORA VOCE E SANTISTA! PEIXE! ***" -ForegroundColor Yellow
Write-Host ""
Write-Host "Agora voce pode:" -ForegroundColor White
Write-Host "   - Trocar o wallpaper normalmente" -ForegroundColor Gray
Write-Host "   - Acessar Personalizacao" -ForegroundColor Gray
Write-Host "   - Usar todos os recursos do Windows" -ForegroundColor Gray
Write-Host ""
pause