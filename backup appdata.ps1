# fixed double folder is copied in source
# fixed space: last checkbox is not seen
# Added: zip folder + auto delete of backed-up folder

Add-Type -AssemblyName System.Windows.Forms

# Create a form
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Folder Selection"
$Form.Size = New-Object System.Drawing.Size(400, 650)
$Form.StartPosition = "CenterScreen"
$Form.BackColor = [System.Drawing.Color]::LightGray  # Set form background color to gray

# Create a panel to hold the checkboxes
$Panel = New-Object System.Windows.Forms.Panel
$Panel.Dock = [System.Windows.Forms.DockStyle]::Fill

# Create a flow layout panel to hold the checkboxes
$FlowLayoutPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$FlowLayoutPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$FlowLayoutPanel.WrapContents = $false
$FlowLayoutPanel.AutoScroll = $true
$FlowLayoutPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$FlowLayoutPanel.Padding = New-Object System.Windows.Forms.Padding(0, 16, 0, 0) #  dimm fix  ==> Left,Top,Right,Bottom 






# Create a search box
$SearchBox = New-Object System.Windows.Forms.TextBox
$SearchBox.Dock = [System.Windows.Forms.DockStyle]::Top
$SearchBox.Height = 30  # Increase the height of the search box
$SearchBox.Add_TextChanged({
    $searchText = $SearchBox.Text.ToLower().Trim()
    $FlowLayoutPanel.Controls.Clear()  # Clear existing checkboxes

    foreach ($Folder in $Folders) {
        if ($Folder.Name.ToLower().Contains($searchText)) {
            $CheckBox = New-Object System.Windows.Forms.CheckBox
            $CheckBox.Text = $Folder.Name
            $CheckBox.AutoSize = $true
            $CheckBox.Add_KeyDown({
                if ($_.KeyCode -eq "Return") {
                    $CheckBox.Checked = !$CheckBox.Checked
                }
            })
            $FlowLayoutPanel.Controls.Add($CheckBox)
        }
    }
        # Add an empty label to ensure the last checkbox is always visible
        $FlowLayoutPanel.Controls.Add($EmptyLabel)
})

# Function to load folders
function LoadFolders {
    $AppDataPath = [Environment]::GetFolderPath("ApplicationData")
    return Get-ChildItem -Path $AppDataPath -Directory
}

# Load folders initially
$Folders = LoadFolders

# Call the function to load folders
foreach ($Folder in $Folders) {
    $CheckBox = New-Object System.Windows.Forms.CheckBox
    $CheckBox.Text = $Folder.Name
    $CheckBox.AutoSize = $true
    $CheckBox.Padding = New-Object System.Windows.Forms.Padding(0, 5, 0, 5) #checkbox padding
    $CheckBox.Add_KeyDown({
        if ($_.KeyCode -eq "Return") {
            $CheckBox.Checked = !$CheckBox.Checked
        }
    })
    $FlowLayoutPanel.Controls.Add($CheckBox)
}

# Create an empty label
$EmptyLabel = New-Object System.Windows.Forms.Label
$EmptyLabel.Text = " "
$EmptyLabel.AutoSize = $true
$EmptyLabel.Padding =  New-Object System.Windows.Forms.Padding(0, 50, 0, 0) #dimm space push from down  to up !!! fix for last item
# Add the empty label to the flow layout panel
$FlowLayoutPanel.Controls.Add($EmptyLabel)

# Add the search box to the panel
$Panel.Controls.Add($SearchBox)
$SearchBox.Padding = New-Object System.Windows.Forms.Padding(10, 10, 10, 50)  # Adjust bottom padding
# Add the flow layout panel to the panel
$Panel.Controls.Add($FlowLayoutPanel)

# Create a button to select/unselect all items
$SelectAllButton = New-Object System.Windows.Forms.Button
$SelectAllButton.Text = "Select All"
$SelectAllButton.BackColor = [System.Drawing.Color]::LightBlue  # Set button background color to light blue
$SelectAllButton.Dock = [System.Windows.Forms.DockStyle]::Bottom
$SelectAllButton.Padding =  New-Object System.Windows.Forms.Padding(0, 0, 0, 0) #dimm space

# Event handler for Select All button click
$SelectAllButton.Add_Click({
    $isChecked = $FlowLayoutPanel.Controls | ForEach-Object { $_.Checked }
    $newState = -not ($isChecked -contains $true)
    $FlowLayoutPanel.Controls | Where-Object { $_ -is [System.Windows.Forms.CheckBox] } | ForEach-Object { $_.Checked = $newState }

    
    $SelectAllButton.Text = if ($newState) { "Deselect All" } else { "Select All" }
})

# Create a Backup button
$BackupButton = New-Object System.Windows.Forms.Button
$BackupButton.Text = "Backup"
$BackupButton.BackColor = [System.Drawing.Color]::Green  # Set button background color to green
$BackupButton.Dock = [System.Windows.Forms.DockStyle]::Bottom

# Event handler for Backup button click
$BackupButton.Add_Click({
    $SelectedFolders = $FlowLayoutPanel.Controls | Where-Object { $_.Checked } | ForEach-Object { $_.Text }
    if ($SelectedFolders.Count -gt 0) {
        $DestinationPath = Join-Path -Path "C:\Backup" -ChildPath (Get-Date -Format "dd_MM_yyyy")
        if (-not (Test-Path -Path $DestinationPath)) {
            New-Item -Path $DestinationPath -ItemType Directory | Out-Null
        }
        foreach ($Folder in $SelectedFolders) {
            $SourcePath = [System.IO.Path]::Combine([Environment]::GetFolderPath("ApplicationData"), $Folder)
            $DestinationFolder = Join-Path -Path $DestinationPath -ChildPath .
            $ZipPath = Join-Path -Path $DestinationFolder -ChildPath "$Folder.zip"
            Compress-Archive -Path $SourcePath\ -DestinationPath $ZipPath -Force  # dimm zip only checked folder.

        }
        [System.Windows.Forms.MessageBox]::Show("Backup completed.", "Backup", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } else {
        [System.Windows.Forms.MessageBox]::Show("No folders selected for backup.", "Backup", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    }
})

# Add the Select All button to the form
$Form.Controls.Add($SelectAllButton)

# Add the Backup button to the form
$Form.Controls.Add($BackupButton)

# Add the panel to the form
$Form.Controls.Add($Panel)

# Display the form
$Form.ShowDialog()
