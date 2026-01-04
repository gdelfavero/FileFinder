$here = Split-Path -Parent $PSCommandPath
$modulePath = Join-Path $here '..\PsFindFiles\PsFindFiles.psd1'
Import-Module $modulePath -Force

Describe 'PsFindFiles module' {
    Context 'Module surface' {
        It 'exports the expected functions' {
            $cmds = Get-Command -Module PsFindFiles | Select-Object -ExpandProperty Name
            ($cmds -contains 'Find-MsOfficeFiles') | Should Be $true
            ($cmds -contains 'Find-MediaFiles') | Should Be $true
            ($cmds | Measure-Object).Count | Should Be 2
        }
    }

    Context 'Find-MsOfficeFiles' {
        It 'finds modern formats by default' {
            $root = Join-Path $TestDrive 'office-default'
            New-Item -ItemType Directory -Path $root | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'doc.docx') | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'sheet.xlsm') | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'legacy.doc') | Out-Null

            $results = Find-MsOfficeFiles -Path $root
            ($results.Name -contains 'doc.docx') | Should Be $true
            ($results.Name -contains 'sheet.xlsm') | Should Be $true
            ($results.Name -contains 'legacy.doc') | Should Be $false
        }

        It 'includes legacy formats when IncludeLegacy is set' {
            $root = Join-Path $TestDrive 'office-legacy'
            New-Item -ItemType Directory -Path $root | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'doc.docx') | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'legacy.doc') | Out-Null

            $results = Find-MsOfficeFiles -Path $root -IncludeLegacy
            ($results.Name -contains 'doc.docx') | Should Be $true
            ($results.Name -contains 'legacy.doc') | Should Be $true
        }

        It 'respects recurse for nested directories' {
            $root = Join-Path $TestDrive 'office-recurse'
            $nested = Join-Path $root 'nested'
            New-Item -ItemType Directory -Path $nested -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'top.docx') | Out-Null
            New-Item -ItemType File -Path (Join-Path $nested 'nested.pptx') | Out-Null

            @(Find-MsOfficeFiles -Path $root -Recurse:$false).Count | Should Be 1
            @(Find-MsOfficeFiles -Path $root -Recurse).Count | Should Be 2
        }

        It 'throws when path does not exist' {
            $missing = Join-Path $TestDrive ([guid]::NewGuid().Guid)
            Test-Path $missing | Should Be $false
            $thrown = $false
            try {
                Find-MsOfficeFiles -Path $missing -ErrorAction Stop | Out-Null
            } catch {
                $thrown = $true
            }
            $thrown | Should Be $true
        }
    }

    Context 'Find-MediaFiles' {
        It 'filters by media type' {
            $root = Join-Path $TestDrive 'media-filter'
            New-Item -ItemType Directory -Path $root | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'song.mp3') | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'video.mkv') | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'photo.jpg') | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'vault.kdbx') | Out-Null

            (Find-MediaFiles -Path $root -MediaType Audio -Recurse:$false).Count | Should Be 1
            (Find-MediaFiles -Path $root -MediaType Video -Recurse:$false).Count | Should Be 1
            (Find-MediaFiles -Path $root -MediaType Picture -Recurse:$false).Count | Should Be 1
            (Find-MediaFiles -Path $root -MediaType Vaults -Recurse:$false).Count | Should Be 1
            (Find-MediaFiles -Path $root -MediaType All -Recurse:$false).Count | Should Be 4
        }

        It 'respects recurse for nested directories' {
            $root = Join-Path $TestDrive 'media-recurse'
            $nested = Join-Path $root 'nested'
            New-Item -ItemType Directory -Path $nested -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'top.mp3') | Out-Null
            New-Item -ItemType File -Path (Join-Path $nested 'deep.jpg') | Out-Null

            (Find-MediaFiles -Path $root -MediaType All -Recurse:$false).Count | Should Be 1
            (Find-MediaFiles -Path $root -MediaType All -Recurse:$true).Count | Should Be 2
        }

        It 'exports to CSV and JSON when requested' {
            $root = Join-Path $TestDrive 'media-export'
            New-Item -ItemType Directory -Path $root | Out-Null
            New-Item -ItemType File -Path (Join-Path $root 'photo.jpg') | Out-Null
            $csvPath = Join-Path $TestDrive 'media.csv'
            $jsonPath = Join-Path $TestDrive 'media.json'

            Find-MediaFiles -Path $root -MediaType Picture -ExportCSV $csvPath -ExportJSON $jsonPath -Recurse:$false | Out-Null

            Test-Path $csvPath | Should Be $true
            Test-Path $jsonPath | Should Be $true
        }
    }
}
