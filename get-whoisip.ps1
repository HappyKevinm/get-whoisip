Function Get-whoisIP() 
{
<#
.SYNOPSIS
    Makes REST calls to ARIN, RIPE, and APNIC, and base webcalls to AFRINIC, and LACNIC then returns IP ownership information
 
.DESCRIPTION
    Makes REST calls to ARIN, RIPE, and APNIC, and base webcalls to AFRINIC, and LACNIC then returns IP ownership information
 
.PARAMETER IP
    Provide an IPv4 address to lookup
 
 .EXAMPLE
    APNIC   = get-whoisIP 203.2.218.208
    AFRINIC = get-whoisIP 105.1.1.1
    LACNIC  = get-whoisIP 200.40.119.162

.NOTES
    Author:  kemi (Exodops)
    Add note to line 79 of whatsthisip to advertise this command
#>
[CmdletBinding()]
Param(
    [parameter(Position=0,Mandatory,HelpMessage="Enter an IPv4 Address.",
    ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [ValidatePattern("^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$")]
    [string]$IP

)
# Base urls used to lookup IP ownership data
$baseURL = 'http://whois.arin.net/rest'
$ripeBaseURL = 'http://rest.db.ripe.net/search?query-string='
$apnicBaseURL = 'https://wq.apnic.net/query?searchtext='
$LacNicBaseURL = "http://lacnic.net/cgi-bin/lacnic/whois?lg=EN"
$AFRINicbaseurl = "https://www.afrinic.net/en/services/whois-query"

# Build the ARIN url base + IP for ARIN query
$ArinURL = "$baseUrl/ip/$ip"

$r = Invoke-RestMethod -uri $ArinURL
Write-host -ForegroundColor green "Arin IP ownership results for the IP $($ip) URL used $($ArinURL)"
write-host "===================================="
Write-host "Net Range     - $($r.net.startAddress) - $($r.net.endAddress)"
Write-host "Handle        - $($r.net.orgRef.Handle)"
write-host "Name          - $($r.net.name)"
Write-host "Orginization  - $($r.net.orgRef.name)"
Write-host "Orgin AS      - $($r.net.originASes.originAS)"
Write-host "Registration  - $($r.net.registrationDate)"
Write-host "Last Modified - $($r.net.updateDate)"
if ($R.net.orgRef.handle -ne "ripe" -and $R.net.orgRef.handle -ne "APNIC" -and $R.net.orgRef.handle -ne "AFRINIC" -and $R.net.orgRef.handle -ne "LACNIC")
    {
        write-host "===================================="
        Write-Host -ForegroundColor red "IP block is owned by ARIN - Obtaining more specific org data from $($r.net.orgRef.'#text')"
        write-host -ForegroundColor yellow "     Org level data"
        write-host "===================================="
        $rr = Invoke-RestMethod -Uri $r.net.orgRef.'#text'
        Write-host "Org Name      - $($rr.org.name)"
        Write-host "Org ID        - $($rr.org.handle)"
        write-host "Address       - $($rr.org.streetAddress.line.'#text')"
        write-host "City          - $($rr.org.city)"
        Write-host "State Prov    - $($rr.org.'iso3166-2')"
        Write-host "Country       - $($rr.org.'iso3166-1'.code3)"
        Write-host "Registration  - $($rr.org.registrationDate)"
        Write-host "Last Modified - $($rr.org.updateDate)"
        write-host "===================================="
        Write-Host -ForegroundColor red "Obtaining Primary Contact information from" "https://whois.arin.net/rest/org/$($rr.org.handle)/pocs"
        Write-host -ForegroundColor yellow "     Admin contact data"
        write-host "===================================="
        $poc = Invoke-RestMethod -Uri "https://whois.arin.net/rest/org/$($rr.org.handle)/pocs"
        $POCadmin = Invoke-RestMethod -uri ($poc.pocs.poclinkref | ? {$_.description -eq "admin"}).'#text'
        Write-host "Handle        - $($pocadmin.poc.handle)"
        Write-host "First name    - $($pocadmin.poc.firstname)"
        Write-host "Last name     - $($pocadmin.poc.lastname)"
        write-host "Address       - $($pocadmin.poc.streetAddress.line.'#text')"
        write-host "City          - $($pocadmin.poc.city)"
        Write-host "State Prov    - $($pocadmin.poc.'iso3166-2')"
        Write-host "Country       - $($pocadmin.poc.'iso3166-1'.code3)"
        Write-host "Registration  - $($pocadmin.poc.registrationDate)"
        Write-host "Last Modified - $($pocadmin.poc.updateDate)"
        write-host "===================================="
        Write-host -ForegroundColor yellow "     Technical contact data"
        write-host "===================================="
        $POCtech = Invoke-RestMethod -uri ($poc.pocs.poclinkref | ? {$_.description -eq "tech"}).'#text'
        Write-host "Handle        - $($poctech.poc.handle)"
        Write-host "First name    - $($poctech.poc.firstname)"
        Write-host "Last name     - $($poctech.poc.lastname)"
        write-host "Address       - $($poctech.poc.streetAddress.line.'#text')"
        write-host "City          - $($poctech.poc.city)"
        Write-host "State Prov    - $($poctech.poc.'iso3166-2')"
        Write-host "Country       - $($poctech.poc.'iso3166-1'.code3)"
        Write-host "Registration  - $($poctech.poc.registrationDate)"
        Write-host "Last Modified - $($poctech.poc.updateDate)"
        write-host "===================================="
        Write-host -ForegroundColor yellow "     Abuse contact data"
        write-host "===================================="
        $POCabuse = Invoke-RestMethod -uri ($poc.pocs.poclinkref | ? {$_.description -eq "abuse"}).'#text'
        Write-host "Handle        - $($pocabuse.poc.handle)"
        Write-host "First name    - $($pocabuse.poc.firstname)"
        Write-host "Last name     - $($pocabuse.poc.lastname)"
        write-host "Address       - $($pocabuse.poc.streetAddress.line.'#text')"
        write-host "City          - $($pocabuse.poc.city)"
        Write-host "State Prov    - $($pocabuse.poc.'iso3166-2')"
        Write-host "Country       - $($pocabuse.poc.'iso3166-1'.code3)"
        Write-host "Registration  - $($pocabuse.poc.registrationDate)"
        Write-host "Last Modified - $($pocabuse.poc.updateDate)"
       
    }
# if the ARIN return indicates RIPE owns the IP check RIPE
if ($R.net.orgRef.handle -eq "ripe")
    {
        # build the RIPE URL base + IP
        $RipeURL = "$ripeBaseURL$ip"
        write-host "===================================="
        Write-Host -ForegroundColor red "IP block is owned by Ripe - Obtaining more specific data from Ripe @ $($ripeurl) "
        write-host "===================================="
        $rr = Invoke-RestMethod  $Ripeurl
        # output base RIPE IP ownership information
        write-host "Net Range     - $(($rr.'whois-resources'.objects.object[0].attributes.attribute | ? {$_.name -eq "inetnum"}).value)"
        write-host "Net Name      - $(($rr.'whois-resources'.objects.object[0].attributes.attribute | ? {$_.name -eq "netname"}).value)"
        $DescrCount = ($rr.'whois-resources'.objects.object[0].attributes.attribute | ? {$_.name -eq "descr"})
        foreach($desc in $descrCount) 
            {
                write-host "Description   - $($desc.value)"
            }
        write-host "Country       - $(($rr.'whois-resources'.objects.object[0].attributes.attribute | ? {$_.name -eq "country"}).value)"
        write-host "Orginisation  - $(($rr.'whois-resources'.objects.object[0].attributes.attribute | ? {$_.name -eq "org"}).value)"
        write-host "Admin Contact - $(($rr.'whois-resources'.objects.object[0].attributes.attribute | ? {$_.name -eq "admin-c"}).value)"
        write-host "Tech Contact  - $(($rr.'whois-resources'.objects.object[0].attributes.attribute | ? {$_.name -eq "tech-c"}).value)"
        write-host "Created       - $(($rr.'whois-resources'.objects.object[0].attributes.attribute | ? {$_.name -eq "created"}).value)"
        write-host "Last Modified - $(($rr.'whois-resources'.objects.object[0].attributes.attribute | ? {$_.name -eq "last-modified"}).value)"
        if ($rr.'whois-resources'.objects.object[1].attributes)
        {
            write-host "===================================="
            write-host "Role          - $(($rr.'whois-resources'.objects.object[1].attributes.attribute | ? {$_.name -eq "role"}).value)"
            write-host "NIC Handle    - $(($rr.'whois-resources'.objects.object[1].attributes.attribute | ? {$_.name -eq "nic-hdl"}).value)"
            $Addresscount = ($rr.'whois-resources'.objects.object[1].attributes.attribute | ? {$_.name -eq "address"})
            foreach($address in $addressCount) 
                {
                    write-host "Address       - $($address.value)"
                }
            write-host "Admin Contact - $(($rr.'whois-resources'.objects.object[1].attributes.attribute | ? {$_.name -eq "admin-c"}).value)"
            write-host "Tech Contact  - $(($rr.'whois-resources'.objects.object[1].attributes.attribute | ? {$_.name -eq "tech-c"}).value)"
            write-host "Remarks       - $(($rr.'whois-resources'.objects.object[1].attributes.attribute | ? {$_.name -eq "remarks"}).value)"
            write-host "Person        - $(($rr.'whois-resources'.objects.object[1].attributes.attribute | ? {$_.name -eq "person"}).value)"
            write-host "Phone         - $(($rr.'whois-resources'.objects.object[1].attributes.attribute | ? {$_.name -eq "phone"}).value)"
            write-host "Created       - $(($rr.'whois-resources'.objects.object[1].attributes.attribute | ? {$_.name -eq "created"}).value)"
            write-host "Last Modified - $(($rr.'whois-resources'.objects.object[1].attributes.attribute | ? {$_.name -eq "last-modified"}).value)"
        }
        if ($rr.'whois-resources'.objects.object[2].attributes)
        {
            write-host "===================================="
            write-host "Role          - $(($rr.'whois-resources'.objects.object[2].attributes.attribute | ? {$_.name -eq "role"}).value)"
            write-host "NIC Handle    - $(($rr.'whois-resources'.objects.object[2].attributes.attribute | ? {$_.name -eq "nic-hdl"}).value)"
            $Addresscount = ($rr.'whois-resources'.objects.object[2].attributes.attribute | ? {$_.name -eq "address"})
            $DescrCount = ($rr.'whois-resources'.objects.object[2].attributes.attribute | ? {$_.name -eq "descr"})
            foreach($desc in $descrCount) 
            {
                write-host "Description   - $($desc.value)"
            }
            foreach($address in $addressCount) 
                {
                    write-host "Address       - $($address.value)"
                }
            write-host "Admin Contact - $(($rr.'whois-resources'.objects.object[2].attributes.attribute | ? {$_.name -eq "admin-c"}).value)"
            write-host "Tech Contact  - $(($rr.'whois-resources'.objects.object[2].attributes.attribute | ? {$_.name -eq "tech-c"}).value)"
            write-host "Remarks       - $(($rr.'whois-resources'.objects.object[2].attributes.attribute | ? {$_.name -eq "remarks"}).value)"
            write-host "Person        - $(($rr.'whois-resources'.objects.object[2].attributes.attribute | ? {$_.name -eq "person"}).value)"
            write-host "Phone         - $(($rr.'whois-resources'.objects.object[2].attributes.attribute | ? {$_.name -eq "phone"}).value)"
            write-host "Created       - $(($rr.'whois-resources'.objects.object[2].attributes.attribute | ? {$_.name -eq "created"}).value)"
            write-host "Last Modified - $(($rr.'whois-resources'.objects.object[2].attributes.attribute | ? {$_.name -eq "last-modified"}).value)"
        }
    }
# if the ARIN return indicates APNIC owns the IP check APNIC
if ($R.net.orgRef.handle -eq "apnic")
    {
        # build the APNIC URL base + IP
        $ApnicURL = "$apnicBaseURL$ip"
        write-host "===================================="
        Write-Host -ForegroundColor red "IP block is owned by APNIC - Obtaining more specific data from APNIC @ $($apnicurl) "
        write-host "===================================="
        $aa = Invoke-RestMethod  $ApnicURL
        # output the three levels of IP ownership Org / company / admin
        write-host -ForegroundColor yellow "     Org level data"
        write-host "===================================="
        write-host "IRT           - $(($aa[5].attributes | ? {$_.name -eq "irt"}).values)"
        $AddressCount = ($aa[5].attributes | ? {$_.name -eq "address"})
        foreach($addr in $addressCount) 
            {
                write-host "Address       - $($addr.values)"
            }
        write-host "Email Address - $(($aa[5].attributes | ? {$_.name -eq "e-mail"}).values)"
        write-host "Abuse Address - $(($aa[5].attributes | ? {$_.name -eq "abuse-mailbox"}).values)"
        write-host "Admin Contact - $(($aa[5].attributes | ? {$_.name -eq "admin-c"}).values)"
        write-host "Tech Contact  - $(($aa[5].attributes | ? {$_.name -eq "tech-c"}).values)"
        write-host "Last Modified - $(($aa[5].attributes | ? {$_.name -eq "last-modified"}).values)"
        write-host "Source        - $(($aa[5].attributes | ? {$_.name -eq "source"}).values)"
        write-host "===================================="
        Write-host -ForegroundColor yellow "     Company level data"
        write-host "===================================="
        write-host "Organisation  - $(($aa[6].attributes | ? {$_.name -eq "orginisation"}).values)"
        write-host "Org Name      - $(($aa[6].attributes | ? {$_.name -eq "org-name"}).values)"
        write-host "Country       - $(($aa[6].attributes | ? {$_.name -eq "country"}).values)"
        $AddressCount = ($aa[6].attributes | ? {$_.name -eq "address"})
        foreach($addr in $addressCount) 
            {
                write-host "Address       - $($addr.values)"
            }   
        write-host "Phone         - $(($aa[6].attributes | ? {$_.name -eq "phone"}).values)"
        write-host "Email Address - $(($aa[6].attributes | ? {$_.name -eq "e-mail"}).values)"
        write-host "Last Modified - $(($aa[6].attributes | ? {$_.name -eq "last-modified"}).values)"
        write-host "Source        - $(($aa[6].attributes | ? {$_.name -eq "source"}).values)"
        write-host "===================================="
        Write-host -ForegroundColor yellow "     Admin contact data"
        write-host "===================================="
        write-host "Person        - $(($aa[7].attributes | ? {$_.name -eq "person"}).values)"
        $AddressCount = ($aa[7].attributes | ? {$_.name -eq "address"})
        foreach($addr in $addressCount) 
            {
                write-host "Address       - $($addr.values)"
            }
        write-host "Country       - $(($aa[7].attributes | ? {$_.name -eq "country"}).values)"
        write-host "Phone         - $(($aa[7].attributes | ? {$_.name -eq "phone"}).values)"
        write-host "Email Address - $(($aa[7].attributes | ? {$_.name -eq "e-mail"}).values)"
        write-host "NIC Handle    - $(($aa[7].attributes | ? {$_.name -eq "nic-hdl"}).values)"
        write-host "Last Modified - $(($aa[7].attributes | ? {$_.name -eq "last-modified"}).values)"
        write-host "Source        - $(($aa[7].attributes | ? {$_.name -eq "source"}).values)"
    }
# if the ARIN return indicates LACNIC owns the IP check LACNIC 
if ($R.net.orgRef.handle -eq "Lacnic")
    {
    # Query LACNIC webpage. Return is not as pretty as above; because it was not simple to parse the web return
        write-host "===================================="
        Write-Host -ForegroundColor red "IP block is owned by LACNIC - Obtaining more specific data from LACNIC @ $($LacNicbaseurl) "
        write-host "===================================="
        $lac = Invoke-WebRequest -Uri $LacNicBaseURL -Body "query=$($ip)" -Method post
        write-host -ForegroundColor yellow " RAW UnParsed LACNIC Return"
        write-host "===================================="
        $lac.ParsedHtml.body.innerText
    }
# if the ARIN return indicates AFRNIC owns the IP check AFRNIC
if ($R.net.orgRef.handle -eq "AFRINIC")
    {
    # Query AFRNIC webpage. Return is not as pretty as above; because it was not simple to parse the web return
        write-host "===================================="
        Write-Host -ForegroundColor red "IP block is owned by AFRINIC - Obtaining more specific data from AFRINIC @ $($AFRINicbaseurl) "
        write-host "===================================="
        $afn = Invoke-WebRequest $AFRINicbaseurl -Method post -Body "key=$($ip)+&action=get_search_result&ajax=true&source=AFRINIC"
        write-host -ForegroundColor yellow " RAW UnParsed AFRINIC Return"
        write-host "===================================="
        ($afn.ParsedHtml.body.innerText | ConvertFrom-Json).SyncRoot
    }
}
