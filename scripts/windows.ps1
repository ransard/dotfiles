$errorlog = "$DesktopPath\winget_error.log"

$apps = @(
    "KDE.digikam"
    "qBittorrent.qBittorrent"
    "WinSCP.WinSCP"
    "darktable.darktable"
)

Foreach ($app in $apps) {
    $listApp = winget list --exact --accept-source-agreements -q $app
    if (![String]::Join("", $listApp).Contains($app)) {
        Write-Host -ForegroundColor Yellow  "Install:" $app
        # MS Store apps
        if ((winget search --exact -q $app) -match "msstore") {
            winget install --exact --silent --accept-source-agreements --accept-package-agreements $app --source msstore
        }
        # All other Apps
        else {
            winget install --exact --silent --scope machine --accept-source-agreements --accept-package-agreements $app
        }
        if ($LASTEXITCODE -eq 0) {
            Write-Host -ForegroundColor Green "$app successfully installed."
        }
        else {
            $app + " couldn't be installed." | Add-Content $errorlog
            Write-Warning "$app couldn't be installed."
            Write-Host -ForegroundColor Yellow "Write in $errorlog"
            Pause
        }  
    }
    else {
        Write-Host -ForegroundColor Yellow "$app already installed. Skip..."
    }
}

