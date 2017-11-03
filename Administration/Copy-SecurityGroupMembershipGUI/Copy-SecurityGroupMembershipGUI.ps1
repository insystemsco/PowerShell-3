#==============================================================================================
# XAML Code - Imported from Visual Studio Express WPF Application
#==============================================================================================
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = @'


<Window
xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
xmlns:local="clr-namespace:WpfApp1"

Title="Copy Security Groups GUI" Height="400" Width="450">
<Grid Opacity="0.8" Margin="0,0,0,-1.5">
<Button x:Name="GetGroupsButton" Content="Get Groups" HorizontalAlignment="Center" Margin="196,117,51,0" VerticalAlignment="Top" Width="84" Height="42"/>
<Button x:Name="AddSelectedGroupsButton" Content="Add Selected Groups" Margin="88,286,89,43" Width="154" FontWeight="Bold" FontSize="14" HorizontalAlignment="Center" VerticalAlignment="Center" Height="27">
    <Button.Effect>
        <DropShadowEffect/>
    </Button.Effect>
</Button>
<Label Content="Target User" HorizontalAlignment="Center" Margin="66,195,195,0" VerticalAlignment="Top"/>
<TextBox x:Name="TargetUserTextBox" HorizontalAlignment="Center" Height="23" Margin="48,226,222,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120"/>
<TextBlock HorizontalAlignment="Center" Margin="140,230,122,0" TextWrapping="Wrap" Text="@mail.mil" VerticalAlignment="Top" RenderTransformOrigin="2.906,-8.026" Width="59"/>
<Label Content="Source User" HorizontalAlignment="Center" Margin="66,21,192,0" VerticalAlignment="Top"/>
<TextBox x:Name="SourceUserTextBox" HorizontalAlignment="Center" Height="23" Margin="19,52,192,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120"/>
<TextBlock HorizontalAlignment="Center" Margin="140,55,128,0" TextWrapping="Wrap" Text="@mail.mil" VerticalAlignment="Top" RenderTransformOrigin="2.906,-8.026"/>

<Button x:Name="FindSourceUserButton" HorizontalAlignment="Center" Margin="150,50,25,0" VerticalAlignment="Top" Width="25" ToolTip="Lookup user in Active Directory.">
    <Image Source="C:\Users\Rusty Shackleford\GitHub\PowerShell\Administration\Copy-SecurityGroupMembershipGUI\adduser.png" />
</Button>

<Button x:Name="FindTargetUserButton" HorizontalAlignment="Center" Margin="150,225,25,0" VerticalAlignment="Top" Width="25" ToolTip="Lookup user in Active Directory.">
    <Image Source="C:\Users\Rusty Shackleford\GitHub\PowerShell\Administration\Copy-SecurityGroupMembershipGUI\adduser.png" />
</Button>

<ListBox x:Name="GetGrouspListBox" HorizontalAlignment="Center" Height="100" Margin="19,90,150,0" VerticalAlignment="Top" Width="160"/>

</Grid>
</Window>



'@
#Read XAML
$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; exit}

#===========================================================================
# Store Form Objects In PowerShell
#===========================================================================
#$xaml.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}

$SourceUserTextBox = $Form.FindName('SourceUserTextBox')
$TargetUserTextBox = $Form.FindName('TargetUserTextBox')
$FindSourceUserButton = $Form.FindName('FindSourceUserButton')
$GetGroupsButton = $Form.FindName('GetGroupsButton')
$GetGroupsListBlock = $Form.FindName('GetGroupsListBlock')
#
#===========================================================================
# Add events to Form Objects
#===========================================================================
$FindSourceUserButton.Add_Click({
    $user = Get-LocalUser | Out-GridView -PassThru -Title "Name"
    $SourceUserTextBox.Text =  $user
})

$GetGroupsButton.Add_Click({
    $GetGroupsListBlock = 
})



#===========================================================================
# Shows the form
#===========================================================================
$Form.ShowDialog() | out-null

