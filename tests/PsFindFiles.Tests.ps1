$modulePath = Join-Path $PSScriptRoot '..\PsFindFiles\PsFindFiles.psd1'

Describe 'PsFindFiles module' {
    BeforeAll {
        $scriptPath = if ($PSCommandPath) { $PSCommandPath } elseif ($MyInvocation.MyCommand.Path) { $MyInvocation.MyCommand.Path } else { $null }
        if (-not $scriptPath) { throw 'Unable to determine test script path.' }
        $scriptRoot = Split-Path -Parent $scriptPath
        $modulePath = Join-Path -Path $scriptRoot -ChildPath '..\PsFindFiles\PsFindFiles.psd1'
        $resolved = Resolve-Path -LiteralPath $modulePath -ErrorAction Stop
        Import-Module $resolved.Path -Force
    }

    Context 'Module surface' {
        It 'exports the expected functions and aliases' {
            $cmds = Get-Command -Module PsFindFiles | Select-Object -ExpandProperty Name
            ($cmds -contains 'Find-MsOfficeFile') | Should -BeTrue
            ($cmds -contains 'Find-MediaFile') | Should -BeTrue
            ($cmds -contains 'Find-GraphicsFile') | Should -BeTrue
            ($cmds -contains 'Find-MsOfficeFiles') | Should -BeTrue
            ($cmds -contains 'Find-MediaFiles') | Should -BeTrue
            ($cmds -contains 'Find-GraphicsFiles') | Should -BeTrue
            ($cmds | Measure-Object).Count | Should -Be 6
        }
    }

    Context 'Find-MsOfficeFile' {
        It 'finds modern formats by default' {
            $root = Join-Path $TestDrive 'office-default'
            New-Item -ItemType Directory -Path $root | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'doc.docx') | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'sheet.xlsm') | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'legacy.doc') | Out-Null

            $results = Find-MsOfficeFile -Path $root
            ($results.Name -contains 'doc.docx') | Should -BeTrue
            ($results.Name -contains 'sheet.xlsm') | Should -BeTrue
            ($results.Name -contains 'legacy.doc') | Should -BeFalse
        }

        It 'includes legacy formats when IncludeLegacy is set' {
            $root = Join-Path $TestDrive 'office-legacy'
            New-Item -ItemType Directory -Path $root | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'doc.docx') | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'legacy.doc') | Out-Null

            $results = Find-MsOfficeFile -Path $root -IncludeLegacy
            ($results.Name -contains 'doc.docx') | Should -BeTrue
            ($results.Name -contains 'legacy.doc') | Should -BeTrue
        }

        It 'respects recurse for nested directories' {
            $root = Join-Path $TestDrive 'office-recurse'
            $nested = Join-Path $root 'nested'
            New-Item -ItemType Directory -Path $nested -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'top.docx') | Out-Null
            New-Item -ItemType File -Path (Join-Path $nested 'nested.pptx') | Out-Null

            @(Find-MsOfficeFile -Path $root -Recurse:$false).Count | Should -Be 1
            @(Find-MsOfficeFile -Path $root -Recurse).Count | Should -Be 2
        }

        It 'throws when path does not exist' {
            $missing = Join-Path $TestDrive ([guid]::NewGuid().Guid)
            Test-Path $missing | Should -BeFalse
            $thrown = $false
            try {
                Find-MsOfficeFile -Path $missing -ErrorAction Stop | Out-Null
            } catch {
                $thrown = $true
            }
            $thrown | Should -BeTrue
        }
    }

    Context 'Find-MediaFile' {
        It 'filters by media type' {
            $root = Join-Path $TestDrive 'media-filter'
            New-Item -ItemType Directory -Path $root | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'song.mp3') | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'video.mkv') | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'photo.jpg') | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'vault.kdbx') | Out-Null

            (Find-MediaFile -Path $root -MediaType Audio -Recurse:$false).Count | Should -Be 1
            (Find-MediaFile -Path $root -MediaType Video -Recurse:$false).Count | Should -Be 1
            (Find-MediaFile -Path $root -MediaType Picture -Recurse:$false).Count | Should -Be 1
            (Find-MediaFile -Path $root -MediaType Vaults -Recurse:$false).Count | Should -Be 1
            (Find-MediaFile -Path $root -MediaType All -Recurse:$false).Count | Should -Be 4
        }

        It 'respects recurse for nested directories' {
            $root = Join-Path $TestDrive 'media-recurse'
            $nested = Join-Path $root 'nested'
            New-Item -ItemType Directory -Path $nested -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'top.mp3') | Out-Null
            New-Item -ItemType File -Path (Join-Path $nested 'deep.jpg') | Out-Null

            (Find-MediaFile -Path $root -MediaType All -Recurse:$false).Count | Should -Be 1
            (Find-MediaFile -Path $root -MediaType All -Recurse:$true).Count | Should -Be 2
        }

        It 'exports to CSV and JSON when requested' {
            $root = Join-Path $TestDrive 'media-export'
            New-Item -ItemType Directory -Path $root | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'photo.jpg') | Out-Null
            $csvPath = Join-Path $TestDrive 'media.csv'
            $jsonPath = Join-Path $TestDrive 'media.json'

            Find-MediaFile -Path $root -MediaType Picture -ExportCSV $csvPath -ExportJSON $jsonPath -Recurse:$false | Out-Null

            Test-Path $csvPath | Should -BeTrue
            Test-Path $jsonPath | Should -BeTrue
        }
    }

    Context 'Find-GraphicsFile' {
        It 'filters by graphics type' {
            $root = Join-Path $TestDrive 'graphics-filter'
            New-Item -ItemType Directory -Path $root | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'art.psd') | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'model.fbx') | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'scan.las') | Out-Null

            (Find-GraphicsFile -Path $root -GraphicsType '2D' -Recurse:$false).Count | Should -Be 1
            (Find-GraphicsFile -Path $root -GraphicsType '3D' -Recurse:$false).Count | Should -Be 1
            (Find-GraphicsFile -Path $root -GraphicsType 'PointCloud' -Recurse:$false).Count | Should -Be 1
            (Find-GraphicsFile -Path $root -GraphicsType 'All' -Recurse:$false).Count | Should -Be 3
        }

        It 'respects recurse for nested directories' {
            $root = Join-Path $TestDrive 'graphics-recurse'
            $nested = Join-Path $root 'nested'
            New-Item -ItemType Directory -Path $nested -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'top.psd') | Out-Null
            New-Item -ItemType File -Path (Join-Path $nested 'deep.obj') | Out-Null

            (Find-GraphicsFile -Path $root -GraphicsType All -Recurse:$false).Count | Should -Be 1
            (Find-GraphicsFile -Path $root -GraphicsType All -Recurse:$true).Count | Should -Be 2
        }
    }
}
