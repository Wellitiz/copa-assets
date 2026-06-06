Add-Type -AssemblyName System.Drawing

$folderPath = ".\images\wallpapers"
$images = Get-ChildItem -Path $folderPath -Include *.png, *.jpg, *.jpeg -Recurse

foreach ($imgFile in $images) {
    try {
        $img = [System.Drawing.Image]::FromFile($imgFile.FullName)
        
        $width = $img.Width
        $height = $img.Height
        
        # Target ratio is 9/16 = 0.5625
        $currentRatio = $width / $height
        $targetRatio = 9.0 / 16.0
        
        # Check if we need to crop
        if ([math]::Abs($currentRatio - $targetRatio) -gt 0.01) {
            Write-Host "Cropping: $($imgFile.Name) ($width x $height)"
            
            $targetWidth = $width
            $targetHeight = $height
            
            if ($currentRatio -gt $targetRatio) {
                # Image is wider than 9:16, crop width
                $targetWidth = [int]($height * $targetRatio)
            } else {
                # Image is taller than 9:16, crop height
                $targetHeight = [int]($width / $targetRatio)
            }
            
            $x = [int](($width - $targetWidth) / 2)
            $y = [int](($height - $targetHeight) / 2)
            
            $rect = New-Object System.Drawing.Rectangle($x, $y, $targetWidth, $targetHeight)
            $bmp = New-Object System.Drawing.Bitmap($targetWidth, $targetHeight)
            
            $g = [System.Drawing.Graphics]::FromImage($bmp)
            $g.DrawImage($img, 0, 0, $rect, [System.Drawing.GraphicsUnit]::Pixel)
            $g.Dispose()
            
            $img.Dispose()
            
            # Save the cropped image
            $tempPath = $imgFile.FullName + ".tmp"
            $bmp.Save($tempPath, [System.Drawing.Imaging.ImageFormat]::Png)
            $bmp.Dispose()
            
            Remove-Item $imgFile.FullName -Force
            Rename-Item $tempPath $imgFile.Name
            
            Write-Host "Success: $($imgFile.Name) -> ($targetWidth x $targetHeight)"
        } else {
            $img.Dispose()
            Write-Host "Skipping: $($imgFile.Name) (Already 9:16)"
        }
    } catch {
        Write-Host "Error processing $($imgFile.Name): $($_.Exception.Message)"
    }
}
Write-Host "Done."
