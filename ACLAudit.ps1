<#
    .SYNOPSIS
        Script to return files and folders with insecure ownership and permissions.

    .DESCRIPTION
        Runs Get-ACL and returns defined permissions and identities.

    .PARAMETER path
        Folder path to audit.

    .PARAMETER permissions
        Optional. Permissions to find and return. 
        Defaults to Modify, FullControl, CreateFiles

    .PARAMETER identities
        Optional. Identities to find and return.\
        Defaults to Everyone, BUILTIN\Users

    .PARAMETER recurse
        Optional. Folder recurse. 
        Default $true

    .EXAMPLE
        ACLAudit.ps1 -path "C:\" 

    .EXAMPLE
        ACLAudit.ps1 -path "C:\" -identities @("Everyone","Administrator")

    .EXAMPLE
        ACLAudit.ps1 -path "C:\Program Files\" -recurse:$false -permissions @("FullControl")

    .NOTES
        File Name: ACLAudit.ps1
        Author: keyboardcrunch
        Date Created: 2/11/2018
#>

param (
    $path = $(throw "-path is required."),
    $permissions = @("Modify","FullControl","CreateFiles"),
    $identities = @("Everyone","BUILTIN\Users"),
    $recurse = $true
)

ForEach ($directory in $path) {
    Get-ChildItem $path -Recurse:$recurse -ErrorAction SilentlyContinue | ForEach-Object {
        $CurrentPath = $_.FullName
        Try {
            $acl = Get-Acl $CurrentPath -ErrorAction SilentlyContinue
            $acl.Access | ForEach-Object {
                If ( $identities -contains $_.IdentityReference ) {
                    If ( $permissions -contains $_.FileSystemRights ) {
                        $CurrentPath
                        $_
                    }
                }
            }
        } Catch {}
    }
}
