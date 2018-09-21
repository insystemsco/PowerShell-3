## Activates Windows with OEM license

$key = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
slmgr.vbs /ipk $key
slmgr /rearm
