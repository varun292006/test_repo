# This script is contains all the methods required for automation of Azure DevOps resources

function Get-TimeStamp {
    
    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
    
}
function addTeamMembers {
    param (
        [String[]]$teamMembersList,
        [String]$org,
        [String]$teamDescriptor
    )

    foreach($member in $teamMembersList)
    {
        $addMember = az devops security group membership add --group-id $teamDescriptor --member-id $member --org $org -o json | ConvertFrom-Json 
        Write-Host "$(Get-TimeStamp) ===Team member $($member) added"
    }
}

function createTeam {
    param (
        [string]$teamName,
        [string]$org,
        [string]$projectID
    )
    Write-Host "`n$(Get-TimeStamp) ===Creating team with name $($teamName) . . . " 
    $createTeam = az devops team create --name $teamName  --org $org -p $projectID -o json | ConvertFrom-Json
    Write-Host "$(Get-TimeStamp) ===Created team with name $($createTeam.name) and Id $($createTeam.id)"
    return $createTeam.id   
}

<# function getFolderId() {
    param (
        [string]$org,
        [string]$projectID
    )
    $pipelineList=az pipelines folder list  --org $org --project  $projectID -o json | ConvertFrom-Json
    foreach ($folder in $pipelineList) {
        $folderpath=$folder.path.Trim('\')
        if ($($folderpath) -eq $folderName) {
            Write-Host "$(Get-TimeStamp) ===Folder found --->  $($folderpath)"
            return $folder.id  
        }
    }
} #>



function getProjectID() {
    param (
        [string]$org,
        [string]$projName
    )
    $listProject=az devops project list  -o json | ConvertFrom-Json
    foreach($proj in $listProject.value) {
        if($proj.name -eq $projName) {
            Write-Host "$(Get-TimeStamp) ===Found a match for project --->  $($proj.name)"
            Write-Host "$(Get-TimeStamp) ===Returning project ID --->  $($proj.id)"
            return $proj.id
        }
    }
}

function getPipelineFolderName() {
    param (
        [string]$org,
        [string]$projectID
    )
        $pipelineFolderList=az pipelines folder list  --org $org --project  $projectID -o json | ConvertFrom-Json
        $fName = $null
        $folderFound = $False
        foreach ($folder in $pipelineFolderList) {
            $folderpath=$folder.path.Trim('\')
            if ($($folderpath) -eq $folderName) {
                $folderFound = $True
                $fName = $folderpath 
            }
        }
        if ($folderFound -eq $True) {
            Write-Host "$(Get-TimeStamp) ======Pipeline folder found: $($fName)"
            return $fName
        }
        else {
            return $fName
        }
}

function getRepoId() {
    param (
        [string]$org,
        [string]$projectID
    )
    $repoFound = $False
    $repoID = $null
    $repoList=az repos list --org $org --project  $projectID -o json | ConvertFrom-Json
    foreach ($repo in $repoList) {
        if ($($repo.Name)  -eq $repoName) {
            Write-Host "$(Get-TimeStamp) ===Repo found --->  $($repo.Name)"
            $repoID = $repo.id
            $repoFound = $True
        }
    }
    if ($repoFound -eq $True) {
        Write-Host "$(Get-TimeStamp) ====Returning team ID $($repoID)"
        return $repoID
    }
    else {
        Write-Host "$(Get-TimeStamp) ====Repo not found. Returning null."
        return $repoID

    }
}

function getTeamID(){
    param (
        [string]$teamName,
        [string]$org,
        [string]$projectID
    )
    Write-Host "`nList all the teams in Project $($projectID) . . . " 
    $listTeam = az devops team list -o json | ConvertFrom-Json
    Write-Host "$($listTeam.name)"
    $teamFound = $False
    $teamID = $null
    foreach ($team in $listTeam) {
        if ($($team.name)  -eq $teamName) {
            Write-Host "$(Get-TimeStamp) ===Team $($team.name) already exists"
            $teamFound = $True
            $teamID = $team.id
        }
    }
    if ($teamFound -eq $True) {
        Write-Host "$(Get-TimeStamp) ====Returning team ID $($teamID)"
        return $teamID
    }
    else {
        return $teamID
    }
}

function updateRepoPermissions {
    param (
        [String]$org,
        [String]$subject,
        [String]$projectID,
        [String]$repoID,
        [int[]]$allowedBit
    )
   # $repoID = '05b6f1f8-ef1f-4439-a7fb-d96424ac376c'
    Write-Host "$(Get-TimeStamp) ===Updating permission for repository --- $($repoID)"
    $tokenStr = 'repoV2' + '/' + $projectID + '/' + $repoID # repoV2/ProjectID/RepoID
    $namespaceId = '2e9eb7ed-3c0a-47d4-87c1-0ffdd275fd87' # Namespace ID of Azure Repo
    foreach($bit in $allowedBit){
        Write-Host "$(Get-TimeStamp) ===Updating permission for bit $($bit)"
        $updatePermissions = az devops security permission update --org $org --id $namespaceId --subject $subject --token $tokenStr --allow-bit $bit -o json | ConvertFrom-Json
    }
    Write-Host "$(Get-TimeStamp) ===Permissions on Repo updated"

}

function updatePipelineFolderPermissions() {
    param (
        [String]$org,
        [String]$subject,
        [String]$projectID,
        [String]$pipelineID,
        [int[]]$allowedPipelineBit
    )
    $buildnamespaceId = '33344d9c-fc72-4d6f-aba5-fa317101a7e9'
    $tokenValue = $projectID + '/' + $pipelineID
    foreach($bit in $allowedPipelineBit){
        Write-Host "$(Get-TimeStamp) ===Updating permission for bit $($bit)"
        $updatePermissions = az devops security permission update --org $org --id $buildnamespaceId --subject $subject --token $tokenValue --allow-bit $bit -o json | ConvertFrom-Json
    }
}