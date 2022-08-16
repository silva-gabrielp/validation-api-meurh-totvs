$Global:Current_Folder = split-path $MyInvocation.MyCommand.Path

[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')  		| out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 		| out-null
[System.Reflection.Assembly]::LoadFrom("MahApps.Metro.dll")       				| out-null
#[System.Reflection.Assembly]::LoadFrom("MahApps.Metro.IconPacks.dll")           | out-null

function LoadXml ($global:filename)
{
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

# Load MainWindow
$XamlMainWindow=LoadXml("$Current_Folder\api.xaml")
$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form=[Windows.Markup.XamlReader]::Load($Reader)

[System.Windows.Forms.Application]::EnableVisualStyles()

function TestarRest {

    Param ($protocolo, $dns, $porta, $endereco)

    # $inputResultHost = [System.Windows.MessageBox]::Show('A Api do Host está com SSL?', 'API do Host', [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Question)
    #if ($inputResultHost -eq "no") {

        try {
            $uri = $("{0}://{1}:{2}/{3}" -f $protocolo, $dns, $porta, $endereco)
            $retorno = Invoke-RestMethod -Uri $uri -Method Get
        }
        catch {
            $retorno = "Não foi possível validar a api."
        }
    return $retorno
}

$yesHost                    = $form.FindName("yesHost")
$noHost                     = $form.FindName("noHost")
$dialogResultDNSHost        = $form.FindName("dialogResultDNSHost")
$yesFrame                   = $form.FindName("yesFrame")
$noFrame                    = $form.FindName("noFrame")
$dialgResultDNSFrame        = $form.FindName("dialgResultDNSFrame")
$btnTestarConexaoHost       = $form.FindName("btnTestarConexaoHost")
$btnTestarConexaoFrame      = $form.FindName("btnTestarConexaoFrame")
$showResultHost             = $form.FindName("showResultHost")
$showResultFrame            = $form.FindName("showResultFrame")
$port8051                   = $form.FindName("port8051")
$port8053                   = $form.FindName("port8053")
$port8059                   = $form.FindName("port8059")
$portHostOutra              = $form.FindName("portHostOutra")
$dialogPortOutra            = $form.FindName("dialogPortOutra")

$port8051.Add_Click({
    $dialogPortOutra.IsEnabled = $false
})
$port8053.Add_Click({
    $dialogPortOutra.IsEnabled = $false
})
$port8059.Add_Click({
    $dialogPortOutra.IsEnabled = $false
})
$portHostOutra.Add_Click({
    $dialogPortOutra.IsEnabled = $true
})

### Botão para testar a conexão com as informações do Host ###
$btnTestarConexaoHost.Add_Click({

    ### Inicio selecao de protocolo ###
    if ($yesHost.IsChecked -eq $true) {
        $sslHost = "https"
    }
    elseif ($noHost.IsChecked -eq $true) {
        $sslHost = "http"
    }
    ### Fim selecao de protocolo ###
    
    ### Inicio selecao de porta ###
    if ($port8051.IsChecked -eq $true) {
        $selecaoporta = 8051
    }
    elseif ($port8053.IsChecked -eq $true) {
        $selecaoporta = 8053
    }
    elseif ($port8059.IsChecked -eq $true) {
        $selecaoporta = 8059
    }
    elseif($portHostOutra.IsChecked -eq $true){
        $selecaoporta = $dialogPortOutra.Text
        Write-Host = $dialogPortOutra.Text
    }
    
    ### Fim selecao de porta ###

    ### Inicio digitar DNS ###
    if(!$dialogResultDNSHost) {
        $showResultHost.Content = "Erro! Nenhum informaçao foi digitada no DNS do Host."
    } else {
        $dialogResultDNSHost.Text = $dialogResultDNSHost.Text
    }
    ### Fim digitar DNS ###

    $validacao = TestarRest -protocolo $sslHost -dns $dialogResultDNSHost.Text -porta $selecaoporta -endereco 'api/rh/v1/services/healthcheck'
        
    if ($validacao -eq "Serviço ok!") {
        $showResultHost.Content = "Api funcionando!"
    } else {
        $showResultHost.Content = "Api com problema!"
    }

})

# Botão para testar a conexão com as informações do FrameHTML
$btnTestarConexaoFrame.Add_Click({
    if ($yesFrame.IsChecked -eq $true) {
        $sslFrameYes = "https"
    }
    elseif ($noFrame.IsChecked -eq $true) {
        $sslFrameNo = "http"
    }
    
    if(!$dialgResultDNSFrame) {
        $showResultFrame = "Erro! Nenhum informaçao foi digitada no DNS do FrameHTML."
    } else {
        $dialgResultDNSFrame.Text = $dialgResultDNSFrame.Text
    }
})

$Form.ShowDialog() | Out-Null