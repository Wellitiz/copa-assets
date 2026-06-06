Add-Type -AssemblyName System.Drawing

$folderPath = ".\images\wallpapers"
$images = Get-ChildItem -Path $folderPath -Include *.png, *.jpg, *.jpeg -Recurse

# Resolução alvo: 1080x1920 (9:16)
$destWidth = 1080
$destHeight = 1920

foreach ($imgFile in $images) {
    try {
        $img = [System.Drawing.Image]::FromFile($imgFile.FullName)
        
        $width = $img.Width
        $height = $img.Height
        
        # Só processa se não for 9:16 vertical
        $currentRatio = $width / $height
        $targetRatio = 9.0 / 16.0
        
        if ([math]::Abs($currentRatio - $targetRatio) -gt 0.05 -or $width -lt 1080) {
            Write-Host "Processando: $($imgFile.Name) ($width x $height)"
            
            # 1. Determinar área de recorte (Source Rectangle)
            $srcWidth = $width
            $srcHeight = $height
            
            if ($currentRatio -gt $targetRatio) {
                # Mais larga que 9:16 -> Recortar laterais (Width)
                $srcWidth = [int]($height * $targetRatio)
            } else {
                # Mais alta que 9:16 -> Recortar topo/base (Height)
                $srcHeight = [int]($width / $targetRatio)
            }
            
            $srcX = [int](($width - $srcWidth) / 2)
            $srcY = [int](($height - $srcHeight) / 2)
            
            $srcRect = New-Object System.Drawing.Rectangle($srcX, $srcY, $srcWidth, $srcHeight)
            $destRect = New-Object System.Drawing.Rectangle(0, 0, $destWidth, $destHeight)
            
            # 2. Criar novo bitmap em 1080x1920
            $bmp = New-Object System.Drawing.Bitmap($destWidth, $destHeight)
            $g = [System.Drawing.Graphics]::FromImage($bmp)
            
            # Qualidade máxima
            $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
            
            # 3. Desenhar a imagem recortada e escalada
            $g.DrawImage($img, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
            
            $g.Dispose()
            $img.Dispose()
            
            # 4. Salvar por cima
            $tempPath = $imgFile.FullName + ".tmp.png"
            $bmp.Save($tempPath, [System.Drawing.Imaging.ImageFormat]::Png)
            $bmp.Dispose()
            
            Remove-Item $imgFile.FullName -Force
            # Garante que vai salvar como PNG
            $finalPath = [System.IO.Path]::ChangeExtension($imgFile.FullName, ".png")
            Rename-Item $tempPath (Split-Path $finalPath -Leaf)
            
            Write-Host "SUCESSO: $($imgFile.Name) convertido para 1080x1920!"
        } else {
            $img.Dispose()
            Write-Host "IGNORADO: $($imgFile.Name) já está na proporção certa e com tamanho bom."
        }
    } catch {
        Write-Host "ERRO em $($imgFile.Name): $($_.Exception.Message)"
    }
}
Write-Host "Concluído!"
