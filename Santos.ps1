# DESBLOQUEADOR WALLPAPER - RESTAURA CONFIGURAÇÕES
# GitHub: GrassiMths/Ativador-Win-Office

# Verifica se é Administrador
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERRO: Execute como Administrador!" -ForegroundColor Red
    pause
    exit
}

function Show-Progress {
    param($message)
    Write-Host $message -ForegroundColor Yellow
    for ($i = 0; $i -le 100; $i += 25) {
        Write-Progress -Activity "Restaurando configuracoes..." -Status "$message - $i% Completo" -PercentComplete $i
        Start-Sleep -Milliseconds 150
    }
    Write-Progress -Activity "Restaurando configuracoes..." -Completed
}

# Inicia o processo
Clear-Host
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "    RESTAURADOR DE CONFIGURACOES DO SISTEMA" -ForegroundColor Yellow
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

# Começa a tocar o hino em background
$hinoJob = Start-Job -ScriptBlock {
    try {
        # Baixa o hino do Santos
        $hinoUri = 'https://drive.google.com/uc?export=download&id=12FNjsJfyjL5S9yQd1vWGA6yggjhPlsue'
        $hinoPath = "$env:TEMP\santos_hino.mp3"
        
        Invoke-WebRequest -Uri $hinoUri -OutFile $hinoPath -UseBasicParsing
        
        if (Test-Path $hinoPath) {
            # Aumenta volume para maximo
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
            
            # Toca o hino
            $player = New-Object -ComObject WMPlayer.OCX
            $player.settings.volume = 100
            $player.URL = $hinoPath
            $player.controls.play()
            
            # Deixa tocar por 30 segundos
            Start-Sleep -Seconds 30
            $player.controls.stop()
        }
    } catch {
        # Silencia erros
    }
}

# Processo de remocao
Show-Progress "Removendo restricoes de personalizacao..."

try {
    Remove-Item "$env:TEMP\neymar_wallpaper.jpg" -Force -ErrorAction SilentlyContinue
    
    $userPaths = @(
        "HKCU:\Control Panel\Desktop",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop", 
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
    )
    
    foreach ($path in $userPaths) {
        if (Test-Path $path) {
            Remove-ItemProperty -Path $path -Name "*" -ErrorAction SilentlyContinue
        }
    }

    $systemPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop"
    )
    
    foreach ($path in $systemPaths) {
        if (Test-Path $path) {
            Remove-ItemProperty -Path $path -Name "*" -ErrorAction SilentlyContinue
        }
    }
} catch { }

Show-Progress "Restaurando configuracoes visuais..."

# Aplica wallpaper do Santos em tela cheia
try {
    # Converte o link do Google Drive para download direto
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
        
        $desktopPath = "HKCU:\Control Panel\Desktop"
        
        # Configura para PREENCHER a tela (sem repetir)
        Set-ItemProperty -Path $desktopPath -Name "Wallpaper" -Value $wallpaperPath -Force
        Set-ItemProperty -Path $desktopPath -Name "WallpaperStyle" -Value "6" -Force    # 6 = Preencher (Fill)
        Set-ItemProperty -Path $desktopPath -Name "TileWallpaper" -Value "0" -Force     # 0 = Não repetir
        
        # Força atualização
        rundll32.exe user32.dll, UpdatePerUserSystemParameters 1, True
        
        # Reinicia o Explorer para aplicar
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    }
} catch { }

Show-Progress "Finalizando processo..."

# Espera o hino terminar
Start-Sleep -Seconds 5

# Finalizacao
Clear-Host
Write-Host "==============================================" -ForegroundColor Green
Write-Host "    PROCESSO DE RESTAURACAO CONCLUIDO!" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Todas as restricoes foram removidas" -ForegroundColor Cyan
Write-Host "Configuracoes padrao restauradas" -ForegroundColor Cyan
Write-Host "Sistema personalizavel" -ForegroundColor Cyan
Write-Host ""
Write-Host "AGORA VOCE E SANTISTA! PEIXE!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Pressione qualquer tecla para fechar..." -ForegroundColor Gray
pause