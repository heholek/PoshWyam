<#
.SYNOPSIS
    Gets the blog posts in a Wyam blog.
.DESCRIPTION
    Gets the blog posts in a Wyam blog. Posts are assumed to be located in ./input/posts and drafts in ./drafts.
#>
function Get-BlogPost {
    [CmdletBinding()]
    param (
        # The blog title. Wild cards supported. Includes blogs with a matching title.
        [Parameter(Mandatory = $False, Position = 0)]
        [string[]]
        $Title,

        # Include blogs with a Published date newer than the specified date.
        [Parameter(Mandatory = $False)]
        [DateTime]
        $StartDate = [DateTime]::MinValue,

        # Include blogs with a Published date older than the specified date.
        [Parameter(Mandatory = $False)]
        [DateTime]
        $EndDate = [DateTime]::MaxValue,

        # The Wyam project root. If not specified the root is located by searching from the current location up.
        [Parameter(Mandatory = $False)]
        [string]
        $Root = (Get-WyamRoot)
    )

    begin {
    }

    process {
        @(
            Get-ChildItem -Path (Get-BlogPostsLocation) -Filter *.md | Get-BlogObject
            Get-ChildItem -Path (Get-BlogPostsLocation -Draft) -Filter *.md | Get-BlogObject -Draft
        ) | Where-Object {
            $post = $_
            if ($PSBoundParameters.ContainsKey('Title') -and -not ($Title | Test-Any { $post.Title -like $_ })) {
                $false
            }
            elseif ($StartDate -gt $post.Published -or $EndDate -lt $post.Published) {
                $false
            }
            else {
                $true
            }
        } | Sort-Object Published
    }

    end {
    }
}
