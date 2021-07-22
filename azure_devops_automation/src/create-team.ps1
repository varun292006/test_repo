Param
(
    [string]$PAT,
    [String]$filePath
)

. (Join-Path $PSScriptRoot .\utils.ps1)


#get input params
if (!$filePath) {
    Write-Host("`nFile input not provided so switching the script to interactive mode to ask default parameters.")
    $org = Read-host("`nOrganization URL ")
    $projectName = Read-host("Project Name ")
    $repoName = Read-host("Repo Name ")
    $teamNameInput = Read-host("Team Name ")
    $teamName = if ($teamNameInput) { $teamNameInput.split(",") }
    $teamName = Read-host("Team Name ")
    $teamMembersInput = Read-host("Team Members(Comma separated EMail IDs) ")
    $teamMembers = if ($teamMembersInput) { $teamMembersInput.split(",") }

    Write-Host("`nThanks for providing all the required details. Now just sit back and relax, script is in action now . . . ")
}
else {
    $values = Get-Content $filePath | Out-String | ConvertFrom-StringData
    $org = $values.org
    $projectName = $values.projectName
    $repoName = $values.repoName
    $folderName = $values.folderName
    $teamName = if ($values.teamName) { $values.teamName.split(",") }
    $allowBit = if ($values.allowBit) { $values.allowBit.split(",") }
    $allowPipelineBit = if ($values.allowPipelineBit) { $values.allowPipelineBit.split(",") }
    $teamMembers = if ($values.teamMembers) { $values.teamMembers.split(",") }
    $teamAdminMembers = if ($values.teamAdminMembers) { $values.teamAdminMembers.split(",") }

    Write-Host("`nAll the required parameters are read from file at $($filePath).  Now just sit back and relax, script is in action now . . . ")
}

# Login to Azure DevOps
#echo $PAT | az devops login --org $org

# Get project ID
$project_details = getProjectID -org $org -projName $projectName
Write-Host "$(Get-TimeStamp) ===Value of Project name is --->  $($project_details)"

# Create Repository if does not exists
if ($repoName) {
    Write-Host "===Checking if Repository $($repoName) already exists"
    $repositoryID = getRepoId -org $org -projectID $project_details

    if ($null -eq $repositoryID) {
        Write-Host '$(Get-TimeStamp) ===Repository does not exists. Creating repo now'
        $repoID = createRepo  -repoName $repoName -org $org -projectID $project_details
        $policyApproverCount = az repos policy approver-count create --allow-downvotes false --blocking true --branch 'master' --creator-vote-counts false --enabled true --minimum-approver-count 2 --repository-id $repoID.id --reset-on-source-push false  --project $project_details --organization $org | ConvertFrom-Json
        Write-Host "$(Get-TimeStamp) ===Created PR policy for master branch"
    }
}

# Create Folder in Azure pipelines
if ($folderName) {
    Write-Host "===Getting the project ID"
    $pipelineList=getPipelineFolderName -org $org -teamName $teamName -projectID $project_details

    if ($null -eq $pipelineList) {
        Write-Host "$(Get-TimeStamp) ===Pipeline folder does not exists. Creating folder now"
        $pipelineID = createPipelineFolder  -folderName $folderName -org $org -projectID $project_details.value.id
    }
    else {
        Write-Host "$(Get-TimeStamp) ===Folder already exists. No action needed"
    }
}


# Create Team if does not exists
if ($teamName) {
    $teamID = getTeamID -org $org -teamName $teamName -projectID $project_details
    if($null -eq $teamID) {
        $teamID = createTeam -org $org -teamName $teamName -projectID $project_details
    }
    
    if ($teamMembers) {
        $listGroups = az devops security group list --org $org -p $project_details -o json | ConvertFrom-Json

        # Add team members to the newly created team
        foreach ($grp in $listGroups.graphGroups) {
            if ($grp.displayName -eq $teamName) {
                 Write-Host "$(Get-TimeStamp) ===Add team member $($teamMembers)"
                 addTeamMembers -org $org -teamMembersList $teamMembers -teamDescriptor $grp.descriptor
                }
        }

        # Add newly created team to the Custom Contributor group
        foreach ($grp in $listGroups.graphGroups) {
            if ($grp.displayName -eq "Custom Contributor") {
                 Write-Host "$(Get-TimeStamp) ===Add team member $($teamName) to Custom Contributor group"
                 addTeamMembers -org $org -teamMembersList $teamName -teamDescriptor $grp.descriptor
                }
        }
        
        # Add newly created team to the repository
        $repositoryID = getRepoId -org $org -projectID $project_details
        foreach ($grp in $listGroups.graphGroups) {
            if ($grp.displayName -eq $teamName) {
                 Write-Host "$(Get-TimeStamp) ===Add repository permission to the team $($teamName)"
                 updateRepoPermissions -org $org -projectID $project_details -repoID $repositoryID -allowedBit $allowBit -subject $grp.descriptor
                }
        }

<#         # Add newly created team to the build folder
        $folderID = getFolderId -org $org -projectID $project_details
        foreach ($grp in $listGroups.graphGroups) {
            if ($grp.displayName -eq $teamName) {
                 Write-Host "$(Get-TimeStamp) ===Add build pipeline folder $($folderID) permission to the team $($teamName)"
                 updatePipelineFolderPermissions -org $org -projectID $project_details -repoID $repositoryID -allowedBit $allowPipelineBit -subject $grp.descriptor
                }
        } #>
    }
}
