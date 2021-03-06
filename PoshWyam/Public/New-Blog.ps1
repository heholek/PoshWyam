<#
.SYNOPSIS
    Creates a new Wyam project for a blog.
.DESCRIPTION
    Scaffolds a new Wyam project for a blog, based on the Blog recipe.
#>
function New-Blog {
    [CmdletBinding(SupportsShouldProcess = $True)]
    param (
        # The blog title.
        [Parameter(Position = 0, Mandatory = $True)]
        $Title,

        # The host name where the blog will be published to.
        [Parameter(Position = 1, Mandatory = $True)]
        $Host,

        # The path of the project to create.
        [Parameter(Mandatory = $False)]
        $Path,

        # The description of your blog (usually placed on the home page).
        [Parameter(Mandatory = $False)]
        $Description,

        # A short introduction to your blog (usually placed on the home page under the description).
        [Parameter(Mandatory = $False)]
        $Introduction,

        # The theme to use.
        [Parameter(Mandatory = $False)]
        $Theme = "CleanBlog",

        [switch]$CakeBuild
    )

    begin {
    }

    process {
        if (-not $PSBoundParameters.ContainsKey('Path')) {
            $Path = Join-Path (Get-Location) (Get-FileName $Title)
        }

        if (Test-Path $Path) {
            throw "Path '$Path' already exists."
        }

        # Create directories
        $Path = New-Item -Path $Path -ItemType Directory
        Set-Location -Path $Path

        Invoke-Wyam -New -Recipe Blog
        [void](New-Item -Path (Join-Path $Path drafts) -ItemType Directory)

        # Update config.wyam
        $content = @("#recipe Blog", "#theme $Theme", "Settings[Keys.Host] = `"$Host`";", "Settings[BlogKeys.Title] = `"$Title`";")
        if ($Description) {
            $content += "Settings[BlogKeys.Description] = `"$Description`";"
        }
        if ($Introduction) {
            $content += "Settings[BlogKeys.Intro] = `"$Introduction`";"
        }
        Set-Content -Path config.wyam -Value $content

        if ($CakeBuild) {
            # Create build.ps1
            Invoke-WebRequest 'http://cakebuild.net/download/bootstrapper/windows' -OutFile build.ps1
            Set-Content -Path build.ps1 -Value (Get-Content -Path build.ps1 | ForEach-Object { $_ -replace 'build.cake','wyam.cake' })

            # Create wyam.cake
            Set-Content -Path wyam.cake -Value (Get-Content -Path (Join-Path $ModuleRoot wyam.cake) | ForEach-Object { $_ -replace '%THEME%',$Theme })
        }
    }

    end {
    }
}
