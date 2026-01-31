# Create OpenClaw Monitor icon (lobster claw)
Add-Type -AssemblyName System.Drawing

function Create-Icon {
    $sizes = @(16, 32, 48, 256)
    $images = @()

    foreach ($size in $sizes) {
        $bitmap = New-Object System.Drawing.Bitmap($size, $size)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphics.SmoothingMode = "AntiAlias"
        $graphics.InterpolationMode = "HighQualityBicubic"

        # Background circle (lobster red/orange)
        $bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 100, 50))
        $graphics.FillEllipse($bgBrush, 0, 0, $size-1, $size-1)

        # Inner highlight
        $highlightBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(80, 255, 255, 255))
        $graphics.FillEllipse($highlightBrush, [int]($size*0.1), [int]($size*0.1), [int]($size*0.5), [int]($size*0.4))

        # Draw claw shape (simplified)
        $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, [Math]::Max(2, $size/10))
        $pen.StartCap = "Round"
        $pen.EndCap = "Round"

        # Left claw arm
        $graphics.DrawArc($pen, [int]($size*0.15), [int]($size*0.25), [int]($size*0.4), [int]($size*0.5), 180, 120)
        # Right claw arm
        $graphics.DrawArc($pen, [int]($size*0.45), [int]($size*0.25), [int]($size*0.4), [int]($size*0.5), -60, 120)
        # Center body
        $graphics.DrawLine($pen, [int]($size*0.5), [int]($size*0.55), [int]($size*0.5), [int]($size*0.8))

        $pen.Dispose()
        $highlightBrush.Dispose()
        $bgBrush.Dispose()
        $graphics.Dispose()

        $images += $bitmap
    }

    # Save as ICO
    $iconPath = "D:\OpenClaw\openclaw.ico"
    $ms = New-Object System.IO.MemoryStream

    # ICO header
    $bw = New-Object System.IO.BinaryWriter($ms)
    $bw.Write([Int16]0)  # Reserved
    $bw.Write([Int16]1)  # Type (1 = ICO)
    $bw.Write([Int16]$images.Count)  # Number of images

    $imageDataOffset = 6 + (16 * $images.Count)
    $imageData = @()

    foreach ($img in $images) {
        $imgMs = New-Object System.IO.MemoryStream
        $img.Save($imgMs, [System.Drawing.Imaging.ImageFormat]::Png)
        $imgBytes = $imgMs.ToArray()
        $imgMs.Dispose()

        # Directory entry
        $bw.Write([byte]$(if ($img.Width -ge 256) { 0 } else { $img.Width }))
        $bw.Write([byte]$(if ($img.Height -ge 256) { 0 } else { $img.Height }))
        $bw.Write([byte]0)  # Color palette
        $bw.Write([byte]0)  # Reserved
        $bw.Write([Int16]1)  # Color planes
        $bw.Write([Int16]32)  # Bits per pixel
        $bw.Write([Int32]$imgBytes.Length)  # Size
        $bw.Write([Int32]$imageDataOffset)  # Offset

        $imageDataOffset += $imgBytes.Length
        $imageData += ,$imgBytes
    }

    foreach ($data in $imageData) {
        $bw.Write($data)
    }

    $bytes = $ms.ToArray()
    [System.IO.File]::WriteAllBytes($iconPath, $bytes)

    $bw.Dispose()
    $ms.Dispose()
    foreach ($img in $images) { $img.Dispose() }

    Write-Host "Icon created: $iconPath"
}

Create-Icon
