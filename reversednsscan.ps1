param (
    [IPAddress]$ip,
    [int]$mask,
    [String]$server
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
        [int]$prefixLength
    )
    if ($prefixLength -lt 0 -or $prefixLength -gt 32) {
        Write-Host "Error mask should be between 0 32."
        return
    }
    return (0xffffffff -shl (32 - $prefixLength))
}

function Get-NetworkBroadcast {
    param (
        [IPAddress]$ip,
        [int]$prefixLength
    )
    $IPBytes = Convert-IPToBytes -ip $ip
    $MaskBytes =  Get-MaskBytes -prefixLength $prefixLength
    $GatewayBytes = $(( $IPBytes -bor (-bnot $MaskBytes)))
    return Convert-BytesToIP -bytesIP $GatewayBytes
}

function Get-NetworkIP {
    param (
        [IPAddress]$ip,
        [int]$prefixLength
    )
    $IPBytes = Convert-IPToBytes -ip $ip
    $MaskBytes =  Get-MaskBytes -prefixLength $prefixLength
    $NetworkBytes = $(( $IPBytes -band ( $MaskBytes)))
    return Convert-BytesToIP -bytesIP $NetworkBytes
}

function Get-AllAdressesInNetwork(){
    param (
        [IPAddress]$ip,
        [int]$prefixLength
    )
    $network = Get-NetworkIP -ip $ip -prefixLength $mask
    $networkBytes = Convert-IPToBytes -ip $network
    $gateway = Get-NetworkBroadcast -ip $ip -prefixLength $mask
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
        [String]$server
    
    )
    $dnsResult = Resolve-DnsName $ip -NoRecursion -QuickTimeout -DnsOnly -Server $server 2>$null 
    $nameHost = $dnsResult.NameHost
    if ( $nameHost -ne $null ){
        Write-Host $ip $Tab $nameHost
    }
}

function Scan-ReserseDNSNetwork(){
    param (
        [IPAddress]$ip,
        [int]$prefixLength,
        [String]$server
    )
    $ipList = Get-AllAdressesInNetwork -ip $ip -prefixLength $mask

    $resultArray = @()
    foreach ($ip in $ipList) {
        $resultArray += ReverseDNSQuery -ip $ip -server $server
    }
    $resultArray | Format-Table -AutoSize
}

Scan-ReserseDNSNetwork -ip $ip -prefixLength $mask -server $server