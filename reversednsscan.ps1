param (
    [IPAddress]$ip = [System.Net.Dns]::GetHostAddresses($env:COMPUTERNAME)[0],
    [int]$mask = (Get-NetIPAddress -InterfaceAlias (Get-NetRoute -DestinationPrefix 0.0.0.0/0).InterfaceAlias | Where-Object {$_.AddressFamily -eq 'IPv4'}).PrefixLength,
    [String]$server = (Get-DnsClientServerAddress | Where-Object {$_.InterfaceAlias -eq (Get-NetAdapter | Where-Object {$_.Status -eq 'Up'}).InterfaceAlias}).ServerAddresses[0]
)

function Convert-IPToBytes {
    param (
        [IPAddress]$ip
    )
    $bytes = $ip.GetAddressBytes()
    if ([BitConverter]::IsLittleEndian) {
        [Array]::Reverse($bytes)
    }
    return [BitConverter]::ToUInt32($bytes, 0)
}

function Convert-BytesToIP {
    param (
        [uint32]$bytesIP
    )
    $bytes = [BitConverter]::GetBytes($bytesIP)
    if ([BitConverter]::IsLittleEndian) {
        [Array]::Reverse($bytes)
    }
    return [System.Net.IPAddress]::new($bytes).ToString()
}

function Get-MaskBytes {
    param (
        [int]$mask
    )
    if ($mask -lt 0 -or $mask -gt 32) {
        Write-Host "Error mask should be between 0 32."
        return
    }
    return (0xffffffff -shl (32 - $mask))
}

function Get-NetworkBroadcast {
    param (
        [IPAddress]$ip,
        [int]$mask
    )
    $IPBytes = Convert-IPToBytes -ip $ip
    $MaskBytes =  Get-MaskBytes -mask $mask
    $GatewayBytes = $(( $IPBytes -bor (-bnot $MaskBytes)))
    return Convert-BytesToIP -bytesIP $GatewayBytes
}

function Get-NetworkIP {
    param (
        [IPAddress]$ip,
        [int]$mask
    )
    $IPBytes = Convert-IPToBytes -ip $ip
    $MaskBytes =  Get-MaskBytes -mask $mask
    $NetworkBytes = $(( $IPBytes -band ( $MaskBytes)))
    return Convert-BytesToIP -bytesIP $NetworkBytes
}

function Get-AllAdressesInNetwork(){
    param (
        [IPAddress]$ip,
        [int]$mask
    )
    $network = Get-NetworkIP -ip $ip -mask $mask
    $networkBytes = Convert-IPToBytes -ip $network
    $gateway = Get-NetworkBroadcast -ip $ip -mask $mask
    $gatewayBytes = Convert-IPToBytes -ip $gateway
    $start = $networkBytes + 1
    $end = $gatewayBytes -1
    $ipList = @()
    for ($i = $start; $i -le $end; $i++) {
        $ipList += Convert-BytesToIP -bytesIP $i
    }
    return $ipList
}

function ReverseDNSQuery(){
    param (
        [IPAddress]$ip,
        [String]$server = (Get-DnsClientServerAddress | Where-Object {$_.InterfaceAlias -eq (Get-NetAdapter | Where-Object {$_.Status -eq 'Up'}).InterfaceAlias}).ServerAddresses[0]
    
    )
    $dnsResult = Resolve-DnsName $ip -NoRecursion -QuickTimeout -DnsOnly -Server $server 2>$null 
    $nameHost = $dnsResult.NameHost
    if ( $nameHost -ne $null ){
        Write-Host $ip $Tab $nameHost
    }
}

function Scan-ReserseDNS(){
    param (
        [IPAddress]$ip = [System.Net.Dns]::GetHostAddresses($env:COMPUTERNAME)[0],
        [int]$mask = (Get-NetIPAddress -InterfaceAlias (Get-NetRoute -DestinationPrefix 0.0.0.0/0).InterfaceAlias | Where-Object {$_.AddressFamily -eq 'IPv4'}).PrefixLength,
        [String]$server = (Get-DnsClientServerAddress | Where-Object {$_.InterfaceAlias -eq (Get-NetAdapter | Where-Object {$_.Status -eq 'Up'}).InterfaceAlias}).ServerAddresses[0]

    )
    $ipList = Get-AllAdressesInNetwork -ip $ip -mask $mask

    $resultArray = @()
    foreach ($ip in $ipList) {
        $resultArray += ReverseDNSQuery -ip $ip -server $server
    }
    $resultArray | Format-Table -AutoSize
}

if ($MyInvocation.InvocationName -eq ".\reversednsscan.ps1" -or $MyInvocation.InvocationName -eq "reversednsscan.ps1"){
    Scan-ReserseDNS -ip $ip -mask $mask -server $server
}

if ($MyInvocation.MyCommand.CommandType -eq "Module")
{
    Export-ModuleMember -Function ReverseDNSQuery
    Export-ModuleMember -Function Scan-ReserseDNS
}
