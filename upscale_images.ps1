Add-Type -AssemblyName System.Drawing

$folderPath = ".\images\wallpapers"
$images = Get-ChildItem -Path $folderPath -Include *.png, *.jpg, *.jpeg -Recurse

$scaleFactor = 2  # 576x1024 -> 1152x2048

foreach ($imgFile in $images) {
    try {
        $img = [System.Drawing.Image]::FromFile($imgFile.FullName)
        
        $newWidth = $img.Width * $scaleFactor
        $newHeight = $img.Height * $scaleFactor
        
        Write-Host "Upscaling: $($imgFile.Name) ($($img.Width)x$($img.Height)) -> ($newWidth x $newHeight)"
        
        $bmp = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        
        # Qualidade máxima de interpolação
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        
        $g.DrawImage($img, 0, 0, $newWidth, $newHeight)
        $g.Dispose()
        $img.Dispose()
        
        # Salvar com qualidade máxima
        $tempPath = $imgFile.FullName + ".tmp"
        $bmp.Save($tempPath, [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Dispose()
        
        Remove-Item $imgFile.FullName -Force
        Rename-Item $tempPath $imgFile.Name
        
        Write-Host "  OK: $($imgFile.Name)"
    } catch {
        Write-Host "  ERRO: $($imgFile.Name): $($_.Exception.Message)"
    }
}
Write-Host "Upscale concluido!"
