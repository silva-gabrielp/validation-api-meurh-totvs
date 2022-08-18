$Global:Current_Folder = split-path $MyInvocation.MyCommand.Path

[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')  		| out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 		| out-null
[System.Reflection.Assembly]::LoadFrom("MahApps.Metro.dll")       				| out-null
#[System.Reflection.Assembly]::LoadFrom("MahApps.Metro.IconPacks.dll")           | out-null

### Ocultor console ###
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0)

function LoadXml ($global:filename)
{
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

### Load MainWindow ###
$XamlMainWindow     = LoadXml("$Current_Folder\api.xaml")
$Reader             = (New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form               = [Windows.Markup.XamlReader]::Load($Reader)

[System.Windows.Forms.Application]::EnableVisualStyles()

function TestarRest {

    Param ($protocolo, $dns, $porta, $endereco)

    try {
        $uri = $("{0}://{1}:{2}/{3}" -f $protocolo, $dns, $porta, $endereco)
        $retorno = Invoke-RestMethod -Uri $uri -Method Get
    }
    catch {
        $retorno = "Não foi possível validar a api."
    }

    return $retorno
}

### Variaveis da aba de Informações do Host ###
$yesHost                    = $form.FindName("yesHost")
$noHost                     = $form.FindName("noHost")
$port8051                   = $form.FindName("port8051")
$port8053                   = $form.FindName("port8053")
$port8059                   = $form.FindName("port8059")
$portHostOutra              = $form.FindName("portHostOutra")
$dialogPortOutra            = $form.FindName("dialogPortOutra")
$dialogResultDNSHost        = $form.FindName("dialogResultDNSHost")

### Variaveis da aba de Informações do FrameHTML ###
$installDefaultYes          = $form.FindName("installDefaultYes")
$installDefaultNo           = $form.FindName("installDefaultNo")
$yesFrame                   = $form.FindName("yesFrame")
$noFrame                    = $form.FindName("noFrame")
$port80                     = $form.FindName("port80")
$port443                    = $form.FindName("port443")
$port8080                   = $form.FindName("port8080")
$port8081                   = $form.FindName("port8081")
$portFrameOutra             = $form.FindName("portFrameOutra")
$dialogPortOutraFrame       = $form.FindName("dialogPortOutraFrame")
$dialgResultDNSFrame        = $form.FindName("dialgResultDNSFrame")

### Variaveis do botão de validação ###
$btnTestarConexaoHost       = $form.FindName("btnTestarConexaoHost")
$btnTestarConexaoFrame      = $form.FindName("btnTestarConexaoFrame")

### Variaveis de apresentação do resultado da validacao ###
$showResultHost             = $form.FindName("showResultHost")
$showResultFrame            = $form.FindName("showResultFrame")

### Inicio bloqueio de selecao da porta "Outra" do Host ###
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
### Fim bloqueio de selecao da porta "Outra" do Host ###

### Inicio bloqueio de selecao da porta "Outra" do FrameHTML ###
$port80.Add_Click({
    $dialogPortOutraFrame.IsEnabled = $false
})
$port443.Add_Click({
    $dialogPortOutraFrame.IsEnabled = $false
})
$port8080.Add_Click({
    $dialogPortOutraFrame.IsEnabled = $false
})
$port8081.Add_Click({
    $dialogPortOutraFrame.IsEnabled = $false
})
$portFrameOutra.Add_Click({
    $dialogPortOutraFrame.IsEnabled = $true
})
### Fim bloqueio de selecao da porta "Outra" do FrameHTML ###

### Inicio botão para testar a conexão com as informações do Host ###
$btnTestarConexaoHost.Add_Click({

    ### Inicio selecao de protocolo do Host ###
    if ($yesHost.IsChecked -eq $true) {
        $sslHost = "https"
    }
    elseif ($noHost.IsChecked -eq $true) {
        $sslHost = "http"
    }
    ### Fim selecao de protocolo do Host ###
    
    ### Inicio selecao de porta do Host ###
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
    }
    ### Fim selecao de porta do Host ###

    ### Inicio digitar DNS do Host ###
    if(!$dialgResultDNSFrame) {
        $showResultHost.Content = "Erro! Nenhum informaçao foi digitada no DNS do Host."
    } else {
        $dialgResultDNSFrame.Text = $dialgResultDNSFrame.Text
    }
    ### Fim digitar DNS do Host ###

    ### Validação da API ###
    $validacaoRestHost = TestarRest -protocolo $sslHost -dns $dialogResultDNSHost.Text -porta $selecaoporta -endereco 'api/rh/v1/services/healthcheck'
        
    ### Mensagem do retorno da requisição ###
    if ($validacaoRestHost -eq "Serviço ok!") {
        $showResultHost.Content = "A api do Host esta funcionando."
        $showResultHost.Foreground = "Green"
    } else {
        $showResultHost.Content = "A api do Host esta com problema para se comunicar."
        $showResultHost.Foreground = "Red"
    }

})
### Fim botão para testar a conexão com as informações do Host ###

### Botão para testar a conexão com as informações do FrameHTML ###
$btnTestarConexaoFrame.Add_Click({
    
    ### Inicio selecao de instalacao do Portal RM ###
    if ($installDefaultYes.IsChecked -eq $true) {
        $urlFrame = "FrameHTML/rm/api/rest/new/services/healthcheck"
    }
    elseif ($installDefaultNo.IsChecked -eq $true) {
        $urlFrame = "rm/api/rest/new/services/healthcheck"
    }
    ### Fim selecao de instalacao do Portal RM ###

    ### Inicio selecao de protocolo do Host ###
    if ($yesFrame.IsChecked -eq $true) {
        $sslFrame = "https"
    }
    elseif ($noFrame.IsChecked -eq $true) {
        $sslFrame = "http"
    }
    ### Fim selecao de protocolo do Host ###
    
    ### Inicio selecao de porta do Host ###
    if ($port80.IsChecked -eq $true) {
        $selecaoportaFrame = 80
    }
    elseif ($port443.IsChecked -eq $true) {
        $selecaoportaFrame = 443
    }
    elseif ($port8080.IsChecked -eq $true) {
        $selecaoportaFrame = 8080
    }
    elseif ($port8081.IsChecked -eq $true) {
        $selecaoportaFrame = 8081
    }
    elseif($portFrameOutra.IsChecked -eq $true){
        $selecaoportaFrame = $dialogPortOutraFrame.Text
    }
    ### Fim selecao de porta do Host ###

    ### Inicio digitar DNS do Host ###
    if(!$dialgResultDNSFrame) {
        $showResultFrame.Content = "Erro! Nenhum informacao foi digitada no DNS do Host."
    } else {
        $dialgResultDNSFrame.Text = $dialgResultDNSFrame.Text
    }
    ### Fim digitar DNS do Host ###

    ### Validação da API ###
    $validacaoRestFrame = TestarRest -protocolo $sslFrame -dns $dialgResultDNSFrame.Text -porta $selecaoportaFrame -endereco $urlFrame
        
    ### Mensagem do retorno da requisição ###
    if ($validacaoRestFrame -eq "Serviço ok!") {
        $showResultFrame.Content = "A api do FrameHTML ests funcionando."
        $showResultFrame.Foreground = "Green"
    } else {
        $showResultFrame.Content = "A api do FrameHTML esta com problema para se comunicar."
        $showResultFrame.Foreground = "Red"
    }

})

$Form.ShowDialog() | Out-Null