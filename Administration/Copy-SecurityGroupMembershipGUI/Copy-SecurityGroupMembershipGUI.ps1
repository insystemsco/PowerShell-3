#==============================================================================================
# XAML Code - Imported from Visual Studio Express WPF Application
#==============================================================================================
[void][System.Reflection.Assembly]::LoadWithPartialName('PresentationFramework')
[void][System.Reflection.Assembly]::LoadWithPartialName('PresentationCore')
[void][System.Reflection.Assembly]::LoadWithPartialName('WindowsBase')

[xml]$xaml = @'


<Window 
xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
xmlns:local="clr-namespace:WpfApp1"

Title="Copy Security Groups GUI" Height="500" Width="500">
<Grid Margin="0,0,0,-1.5">

<Label Content="Source User" HorizontalAlignment="Center" Margin="158,21,213,0" VerticalAlignment="Top"/>

<TextBox x:Name="SourceUserTextBox" HorizontalAlignment="Center" Height="23" Margin="76,52,146,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="223"/>

<Button x:Name="FindSourceUserButton" HorizontalAlignment="Center" Margin="341,52,0,0" VerticalAlignment="Top" Width="25" ToolTip="Lookup user in Active Directory.">
    <Image Source=" C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WindowsAdministration\adduser.png" />
</Button>

<ListBox x:Name="GroupsListBox" HorizontalAlignment="Center" Height="128" Margin="76,95,146,0" VerticalAlignment="Top" Width="223" SelectionMode="Extended"/>


<Label Content="Target User" HorizontalAlignment="Center" Margin="163,223,213,0" VerticalAlignment="Top"/>

<TextBox x:Name="TargetUserTextBox" HorizontalAlignment="Center" Height="23" Margin="76,255,146,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="223"/>

<Button x:Name="FindTargetUserButton" HorizontalAlignment="Center" Margin="341,255,0,0" VerticalAlignment="Top" Width="25" ToolTip="Lookup user in Active Directory.">
    <Image Source=" C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WindowsAdministration\adduser.png" />
</Button>



<Button x:Name="AddSelectedGroupsButton" Content="Add Selected Groups" Margin="88,286,89,43" Width="154" FontWeight="Bold" FontSize="14" HorizontalAlignment="Center" VerticalAlignment="Center" Height="27">
            <Button.Effect>
                <DropShadowEffect/>
            </Button.Effect>
        </Button>


</Grid>
</Window>



'@


#===========================================================================
# Read XAML
#===========================================================================

$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; exit}


#===========================================================================
# Store Form Objects In PowerShell
#===========================================================================

$SourceUserTextBox = $Form.FindName('SourceUserTextBox')
$FindTargetUserButton = $Form.FindName('FindTargetUserButton')
$TargetUserTextBox = $Form.FindName('TargetUserTextBox')
$FindSourceUserButton = $Form.FindName('FindSourceUserButton')
$GetGroupsButton = $Form.FindName('GetGroupsButton')
$GroupsListBox = $Form.FindName('GroupsListBox')
$AddSelectedGroupsButton = $Form.FindName('AddSelectedGroupsButton')


#===========================================================================
# Add events to Form Objects
#===========================================================================

$FindSourceUserButton.Add_Click({
    $SourceUser = Get-ADUser -Filter * -SearchBase "OU=Users,DC=KARL,DC=LAB" | Out-GridView -PassThru
    $SourceUserTextBox.Text =  $SourceUser.Name
    $SourceSam = $SourceUser.SamAccountName

    $GroupsListBox.Items.Clear()

    $SourceUserGroups = Get-ADUser $SourceSAM -Properties memberof | Select-Object -ExpandProperty memberof
    $SourceUserGroups | Get-ADGroup | ForEach-Object {$GroupsListBox.Items.Add($_.Name)}

})



$FindTargetUserButton.Add_Click({
    $TargetUser = Get-ADUser -Filter * -SearchBase "OU=Users,DC=KARL,DC=LAB" | Out-GridView -PassThru
    $TargetUserTextBox.Text =  $TargetUser.Name
})


$AddSelectedGroupsButton.Add_Click({
    $SelectedGroups = $GroupsListBox.SelectedItems
    $TargetCN = (Get-ADUser -Filter {Name -eq $TargetUserTextBox.Text})
    $SelectedGroups | Add-ADGroupMember -Members $TargetCN -Verbose
})


#===========================================================================
# Shows the form
#===========================================================================
$Form.ShowDialog() | out-null

