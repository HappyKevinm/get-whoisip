Function Get-whoisIP() 
{
<#
.SYNOPSIS
    Makes REST calls to ARIN, RIPE, and APNIC, and base webcalls to AFRINIC, and LACNIC then returns IP ownership information
 
.DESCRIPTION
    Makes REST calls to ARIN, RIPE, and APNIC, and base webcalls to AFRINIC, and LACNIC then returns IP ownership information
 
.PARAMETER IP
    Provide an IP address to lookup
 
 .EXAMPLE
    APNIC   = get-whoisIP 203.2.218.208
    AFRINIC = get-whoisIP 105.1.1.1
    LACNIC  = get-whoisIP 200.40.119.162
    Get-whoisIP 2001:13c7:7002:4000::10

.NOTES
    Author:  Kevin Miller kevinm@wlkmmas.org

#>
[CmdletBinding()]
Param(
    [parameter(Position=0,Mandatory,HelpMessage="Enter an IP Address. Both IPv4 and IPv6 are supported",
    ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [ValidateScript({$_ -match [IPAddress]$_ })]
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
$ArinObject = New-Object psobject -Property @{
    NetRange = "$($r.net.startAddress) - $($r.net.endAddress)";
    Handle = $r.net.orgRef.Handle;
    Name = $r.net.name;
    Organisation = $r.net.orgRef.name;
    OrginAS = $r.net.originASes.originAS;
    Registration = $r.net.registrationDate;
    LastModified =$r.net.updateDate;
}
$ArinObject
if ($R.net.orgRef.handle -ne "ripe" -and $R.net.orgRef.handle -ne "APNIC" -and $R.net.orgRef.handle -ne "AFRINIC" -and $R.net.orgRef.handle -ne "LACNIC")
    {
        write-host "===================================="
        Write-Host -ForegroundColor red "IP block is owned by ARIN - Obtaining more specific org data from $($r.net.orgRef.'#text')"
        write-host -ForegroundColor yellow "     Org level data"
        write-host "===================================="
        $rr = Invoke-RestMethod -Uri $r.net.orgRef.'#text'
        $ArinOrgObjectHash = [Ordered]@{
            OrgName = $rr.org.name;
            OrgID = $rr.org.handle;
            Address = $rr.org.streetAddress.line.'#text';
            City = $rr.org.city;
            State = $rr.org.'iso3166-2';
            Country = $rr.org.'iso3166-1'.code3;
            Registration = $rr.org.registrationDate;
            LastModified = $rr.org.updateDate;
        }
        $ArinOrgObject = New-Object psobject -Property $ArinOrgObjectHash
        $ArinOrgObject
        write-host "===================================="
        Write-Host -ForegroundColor red "Obtaining Primary Contact information from" "https://whois.arin.net/rest/org/$($rr.org.handle)/pocs"
        Write-host -ForegroundColor yellow "     Admin contact data"
        write-host "===================================="
        $poc = Invoke-RestMethod -Uri "https://whois.arin.net/rest/org/$($rr.org.handle)/pocs"
        $POCadmin = Invoke-RestMethod -uri ($poc.pocs.poclinkref | ? {$_.description -eq "admin"}).'#text'
        $PocAdminHash = [Ordered]@{
            Handle = $pocadmin.poc.handle;
            FirstName = $pocadmin.poc.firstname;
            LastName = $pocadmin.poc.lastname;
            Address = $pocadmin.poc.streetAddress.line.'#text';
            City = $pocadmin.poc.city;
            State = $pocadmin.poc.'iso3166-2';
            Country = $pocadmin.poc.'iso3166-1'.code3;
            Registration = $pocadmin.poc.registrationDate;
            LastModified = $pocadmin.poc.updateDate;
        }
        $POCAdminObject = New-Object psobject -Property $PocAdminHash
        $POCAdminObject
        write-host "===================================="
        Write-host -ForegroundColor yellow "     Technical contact data"
        write-host "===================================="
        $POCtech = Invoke-RestMethod -uri ($poc.pocs.poclinkref | ? {$_.description -eq "tech"}).'#text'
        $POCtechObjectHash = [Ordered]@{
            Handle = $poctech.poc.handle;
            FirstName = $poctech.poc.firstname;
            LastName = $poctech.poc.lastname;
            Address = $poctech.poc.streetAddress.line.'#text';
            City = $poctech.poc.city;
            State = $poctech.poc.'iso3166-2';
            Country = $poctech.poc.'iso3166-1'.code3;
            Registration = $poctech.poc.registrationDate;
            LastModified = $poctech.poc.updateDate;
        }
        $POCtechObject = New-Object psobject -Property $POCtechObjectHash
        $POCtechObject
        write-host "===================================="
        Write-host -ForegroundColor yellow "     Abuse contact data"
        write-host "===================================="
        $POCabuse = Invoke-RestMethod -uri ($poc.pocs.poclinkref | ? {$_.description -eq "abuse"}).'#text'
        $POCabuseObjectHash = [Ordered]@{
            Handle = $pocabuse.poc.handle;
            FirstName = $pocabuse.poc.firstname;
            LastName = $pocabuse.poc.lastname;
            Address = $pocabuse.poc.streetAddress.line.'#text';
            City = $pocabuse.poc.city;
            State = $pocabuse.poc.'iso3166-2';
            Country = $pocabuse.poc.'iso3166-1'.code3;
            Registration = $pocabuse.poc.registrationDate;
            LastModified = $pocabuse.poc.updateDate;
        }
        $POCabuseObject = New-Object psobject -Property $POCabuseObjectHash
        $POCabuseObject
       
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
        $DescrCount = ($rr.'whois-resources'.objects.object[0].attributes.attribute | ? {$_.name -eq "descr"})
        foreach($desc in $descrCount) 
            {
                $RipeOrgdescription += "$($desc.value) //"
            }
        $RipeObjectHash = [Ordered]@{
            NetworkRange = ($rr.'whois-resources'.objects.object[0].attributes.attribute | ? {$_.name -eq "inetnum"}).value;
            NetworkName = ($rr.'whois-resources'.objects.object[0].attributes.attribute | ? {$_.name -eq "netname"}).value;
            Description = $RipeOrgdescription;
            Country = ($rr.'whois-resources'.objects.object[0].attributes.attribute | ? {$_.name -eq "country"}).value;
            Orginisation = ($rr.'whois-resources'.objects.object[0].attributes.attribute | ? {$_.name -eq "org"}).value;
            AdminContact = ($rr.'whois-resources'.objects.object[0].attributes.attribute | ? {$_.name -eq "admin-c"}).value;
            TechContact = ($rr.'whois-resources'.objects.object[0].attributes.attribute | ? {$_.name -eq "tech-c"}).value;
            Created = ($rr.'whois-resources'.objects.object[0].attributes.attribute | ? {$_.name -eq "created"}).value;
            LastModified = ($rr.'whois-resources'.objects.object[0].attributes.attribute | ? {$_.name -eq "last-modified"}).value;
        }
        $RipeObject = New-Object psobject -Property $RipeObjectHash
        $RipeObject
        if ($rr.'whois-resources'.objects.object[1].attributes)
        {
            $Addresscount = ($rr.'whois-resources'.objects.object[1].attributes.attribute | ? {$_.name -eq "address"})
            foreach($address in $addressCount) 
                {
                    $RipeAddress1 += "$($address.value) // "
                }
            write-host "===================================="
            $RipeObjectHash1 = [Ordered]@{
                Role = ($rr.'whois-resources'.objects.object[1].attributes.attribute | ? {$_.name -eq "role"}).value;
                NICHandle = ($rr.'whois-resources'.objects.object[1].attributes.attribute | ? {$_.name -eq "nic-hdl"}).value;
                Address = $RipeAddress1;
                AdminContact = ($rr.'whois-resources'.objects.object[1].attributes.attribute | ? {$_.name -eq "admin-c"}).value;
                TechContact = ($rr.'whois-resources'.objects.object[1].attributes.attribute | ? {$_.name -eq "tech-c"}).value;
                Remarks = ($rr.'whois-resources'.objects.object[1].attributes.attribute | ? {$_.name -eq "remarks"}).value;
                Person = ($rr.'whois-resources'.objects.object[1].attributes.attribute | ? {$_.name -eq "person"}).value;
                Phone = ($rr.'whois-resources'.objects.object[1].attributes.attribute | ? {$_.name -eq "phone"}).value;
                Created = ($rr.'whois-resources'.objects.object[1].attributes.attribute | ? {$_.name -eq "created"}).value;
                LastModified = ($rr.'whois-resources'.objects.object[1].attributes.attribute | ? {$_.name -eq "last-modified"}).value;
            }
            $RipeObject1 = New-Object psobject -Property $RipeObjectHash1
            $RipeObject1
        }
        if ($rr.'whois-resources'.objects.object[2].attributes)
        {
            write-host "===================================="
            $Addresscount = ($rr.'whois-resources'.objects.object[2].attributes.attribute | ? {$_.name -eq "address"})
            $DescrCount = ($rr.'whois-resources'.objects.object[2].attributes.attribute | ? {$_.name -eq "descr"})
            foreach($desc in $descrCount) 
            {
                $RipeDescription2 = "$($desc.value) // "
            }
            foreach($address in $addressCount) 
                {
                    $ripeAddress2 += "$($address.value) // "
                }
            $RipeObjectHash2 = [Ordered]@{
                Role = ($rr.'whois-resources'.objects.object[2].attributes.attribute | ? {$_.name -eq "role"}).value;
                NICHandle = ($rr.'whois-resources'.objects.object[2].attributes.attribute | ? {$_.name -eq "nic-hdl"}).value;
                Description = $RipeDescription2;
                Address = $RipeAddress2;
                AdminContact = ($rr.'whois-resources'.objects.object[2].attributes.attribute | ? {$_.name -eq "admin-c"}).value;
                TechContact = ($rr.'whois-resources'.objects.object[2].attributes.attribute | ? {$_.name -eq "tech-c"}).value;
                Remarks = ($rr.'whois-resources'.objects.object[2].attributes.attribute | ? {$_.name -eq "remarks"}).value;
                Person = ($rr.'whois-resources'.objects.object[2].attributes.attribute | ? {$_.name -eq "person"}).value;
                Phone = ($rr.'whois-resources'.objects.object[2].attributes.attribute | ? {$_.name -eq "phone"}).value;
                Created = ($rr.'whois-resources'.objects.object[2].attributes.attribute | ? {$_.name -eq "created"}).value;
                LastModified = ($rr.'whois-resources'.objects.object[2].attributes.attribute | ? {$_.name -eq "last-modified"}).value;
            }
            $RipeObject2 = New-Object psobject -Property $RipeObjectHash2
            $RipeObject2
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
        $AddressCount = ($aa[5].attributes | ? {$_.name -eq "address"})
        foreach($addr in $addressCount) 
            {
                $ApnicOrgAddress += "$($addr.values) // "
            }
        $ApnicOrgObjectHash = [Ordered]@{
            IRT = ($aa[5].attributes | ? {$_.name -eq "irt"}).values;
            Address = $ApnicOrgAddress;
            EmailAddress = ($aa[5].attributes | ? {$_.name -eq "e-mail"}).values;
            AbuseAddress = ($aa[5].attributes | ? {$_.name -eq "abuse-mailbox"}).values;
            AdminContact = ($aa[5].attributes | ? {$_.name -eq "admin-c"}).values;
            TechContact = ($aa[5].attributes | ? {$_.name -eq "tech-c"}).values;
            LastModified  = ($aa[5].attributes | ? {$_.name -eq "last-modified"}).values;
            Source = ($aa[5].attributes | ? {$_.name -eq "source"}).values;          
            }
        $ApnicOrgObject = New-Object psobject -Property $ApnicOrgObjectHash
        $ApnicOrgObject
        write-host "===================================="
        Write-host -ForegroundColor yellow "     Company level data"
        write-host "===================================="
        $AddressCount = ($aa[6].attributes | ? {$_.name -eq "address"})
        foreach($addr in $addressCount) 
            {
                $ApnicComAddress = "$($addr.values) // "
            }   
        $ApnicComObjectHash = [Ordered]@{
            Organisation = ($aa[6].attributes | ? {$_.name -eq "orginisation"}).values;
            OrgName =($aa[6].attributes | ? {$_.name -eq "org-name"}).values;
            Country = ($aa[6].attributes | ? {$_.name -eq "country"}).values;
            Address = $ApnicComAddress;
            Phone = ($aa[6].attributes | ? {$_.name -eq "phone"}).values;
            EmailAddress = ($aa[6].attributes | ? {$_.name -eq "e-mail"}).values;
            LastModified = ($aa[6].attributes | ? {$_.name -eq "last-modified"}).values;
            Source = ($aa[6].attributes | ? {$_.name -eq "source"}).values;
        }
        $ApnicComObject = New-Object psobject -Property $ApnicComObjectHash
        $ApnicComObject
        write-host "===================================="
        Write-host -ForegroundColor yellow "     Admin contact data"
        write-host "===================================="
        $AddressCount = ($aa[7].attributes | ? {$_.name -eq "address"})
        foreach($addr in $addressCount) 
            {
                $ApnicPerAddress = "$($addr.values) // "
            }
        $ApnicPerObjectHash = [Ordered]@{
            Person = ($aa[7].attributes | ? {$_.name -eq "person"}).values;
            Address = $apnicPerAddress;
            Country = ($aa[7].attributes | ? {$_.name -eq "country"}).values;
            Phone = ($aa[7].attributes | ? {$_.name -eq "phone"}).values;
            EmailAddress = ($aa[7].attributes | ? {$_.name -eq "e-mail"}).values;
            NICHandle = ($aa[7].attributes | ? {$_.name -eq "nic-hdl"}).values;
            LastModified = ($aa[7].attributes | ? {$_.name -eq "last-modified"}).values;
            Source = ($aa[7].attributes | ? {$_.name -eq "source"}).values;
        }
        $ApnicPerObject = New-Object psobject -Property $ApnicPerObjectHash
        $ApnicPerObject
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
