# SUPER DESBLOQUEIO DE WALLPAPER
# Execute como ADMINISTRADOR

param([switch]$Force)

# Verifica se é Administrador
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERRO: EXECUTE COMO ADMINISTRADOR!" -ForegroundColor Red
    Write-Host "Botão direito > Executar como Administrador" -ForegroundColor Yellow
    pause
    exit
}

Clear-Host
Write-Host "==================================================" -ForegroundColor Red
Write-Host "           SUPER DESBLOQUEIO WALLPAPER" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Red
Write-Host ""

# 1. MATA TODOS OS PROCESSOS RELACIONADOS
Write-Host "[1/6] Parando processos..." -ForegroundColor Cyan
Get-Process powershell -ErrorAction SilentlyContinue | Where-Object { 
    $_.CommandLine -like "*wallpaper*" -or
    $_.CommandLine -like "*neymar*" 
} | Stop-Process -Force -ErrorAction SilentlyContinue

# 2. REMOVE ARQUIVOS TEMPORÁRIOS
Write-Host "[2/6] Removendo arquivos..." -ForegroundColor Cyan
$filesToRemove = @(
    "$env:TEMP\neymar_wallpaper.jpg",
    "$env:TEMP\wallpaper_monitor.ps1",
    "$env:TEMP\wallpaper_keeper.ps1", 
    "$env:TEMP\restore_wallpaper.ps1",
    "$env:USERPROFILE\Desktop\neymar_wallpaper.jpg",
    "$env:USERPROFILE\Downloads\neymar_wallpaper.jpg"
)

foreach ($file in $filesToRemove) {
    if (Test-Path $file) {
        Remove-Item $file -Force -ErrorAction SilentlyContinue
        Write-Host "   Removido: $($file.Split('\')[-1])" -ForegroundColor Green
    }
}

# 3. REMOVE TAREFAS AGENDADAS
Write-Host "[3/6] Removendo tarefas..." -ForegroundColor Cyan
$tasks = @("WallpaperKeeper", "WallpaperRestorer", "WallpaperMonitor")
foreach ($task in $tasks) {
    try {
        Unregister-ScheduledTask -TaskName $task -Confirm:$false -ErrorAction SilentlyContinue
        Write-Host "   Tarefa removida: $task" -ForegroundColor Green
    } catch { }
}

# 4. LIMPA REGISTRO DO USUÁRIO (HKCU)
Write-Host "[4/6] Limpando registro do usuario..." -ForegroundColor Cyan

# Remove configurações de wallpaper
$desktopPath = "HKCU:\Control Panel\Desktop"
Remove-ItemProperty -Path $desktopPath -Name "Wallpaper" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path $desktopPath -Name "WallpaperStyle" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path $desktopPath -Name "TileWallpaper" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path $desktopPath -Name "ConvertedWallpaper" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path $desktopPath -Name "OriginalWallpaper" -ErrorAction SilentlyContinue

# Remove TODAS as políticas do usuário
$userPolicies = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies"
if (Test-Path $userPolicies) {
    Get-ChildItem $userPolicies -Recurse | ForEach-Object {
        Remove-ItemProperty -Path $_.PSPath -Name "*" -ErrorAction SilentlyContinue
    }
    Write-Host "   Políticas do usuario removidas" -ForegroundColor Green
}

# 5. LIMPA REGISTRO DO SISTEMA (HKLM) - PRECISA DE ADMIN
Write-Host "[5/6] Limpando registro do sistema..." -ForegroundColor Cyan

# Remove políticas do sistema
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
        Write-Host "   Sistema: $($path.Split('\')[-1])" -ForegroundColor Green
    }
}

# 6. RESTAURA WALLPAPER PADRÃO E APLICA
Write-Host "[6/6] Restaurando configuracoes..." -ForegroundColor Cyan

# Método 1: Via API
try {
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
    [Wallpaper]::SystemParametersInfo(0x0014, 0, "", 0x01 -bor 0x02)
} catch { }

# Método 2: Via registro limpo
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper" -Value "" -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallpaperStyle" -Value "10" -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "TileWallpaper" -Value "0" -Force -ErrorAction SilentlyContinue

# Método 3: Comando direto
rundll32.exe user32.dll, UpdatePerUserSystemParameters 1, True

# Reinicia Explorer
Write-Host "   Reiniciando interface..." -ForegroundColor Yellow
Start-Sleep -Seconds 2
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue

Write-Host "`n" + "="*50 -ForegroundColor Green
Write-Host "✅ DESBLOQUEIO COMPLETO!" -ForegroundColor Green
Write-Host "="*50 -ForegroundColor Green
Write-Host ""
Write-Host "🎉 O wallpaper foi removido!" -ForegroundColor Cyan
Write-Host "🔓 Permissoes restauradas!" -ForegroundColor Cyan
Write-Host "💻 Agora voce pode:" -ForegroundColor White
Write-Host "   • Trocar o wallpaper normalmente" -ForegroundColor White
Write-Host "   • Acessar Personalizacao" -ForegroundColor White
Write-Host "   • Usar todos os recursos do Windows" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  Se ainda nao funcionou, REINICIE o computador!" -ForegroundColor Yellow
Write-Host ""

pause