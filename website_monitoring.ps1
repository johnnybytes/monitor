$URL = "infonet.nyp.org" # global var so we are checking only this particular one

try {    
    $testConnection = Test-NetConnection $URL # first, we check the connection 
                                                # POSSIBLE EXCEPTION: non-valid argument like "afaefawefaf"
    $pingTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss" 
    $pingResult = $testConnection.PingSucceeded # boolean for true or false ping 
    if ($pingResult -ne "True") { # if valid argument but cannot ping
        Send-MailMessage -From "Do Not Reply <donotreply@nyp.org>" -To "Zhani Pellumbi <zhp9002@nyp.org>" -Subject "$URL Failed Ping" -Body "The website in the subject failed the ping at roughly $pingTime. `nTest-NetConnection Message: $testConnection"
        return # exit script if we can't even ping it (DNE)
    }
    # if the ping worked, the script won't exit yet
    $response = Invoke-WebRequest -Uri $URL # make the request 
                                            # POSSIBLE EXCEPTION: even though ping works, cannot make a request. Either not correct credentials, locked, etc.
    $statusCode = $response.StatusCode # status code
    $timeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    if ($statusCode -ne 200){ # if no exception but also not HTTP-200
        Send-MailMessage -From 'DO NOT REPLY <donotreply@nyp.org>' -To 'Zhani Pellumbi <zhp9002@nyp.org>'  -Subject "$URL Request Error" -Body "A request to $URL was made that received a status code $statusCode at $timeStamp. Please check out the web server. "   -SmtpServer "smtp.nyp.org"
        return
    } #SmtpServer is the email server from which the DO NOT REPLY email will be sent. Some of these servers will require authentication, like smtp.gmail.com 

    #else, add the success to a "log.txt" file in the file. Still assuming no exception
    else {
        Add-Content -Path "C:\Scripts\log.txt" -Value "SUCCESS! `nTime: $timeStamp `nServer: $URL `nTest-NetConnection Message: $testConnection `n------------------------------" #add-content will append, not overwrite
        return
    }
}
# if ANYTHING in the try block throws an exception...
catch [System.Net.WebException] { # if the web request cannot be made...
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss" 
    $exception = $_.Exception 
    #Add-Content -Path "C:\Scripts\exceptions.txt" -Value "System.Net.WebException! Occurred at $time. This request to infonet.nyp.org cannot be made now"
    Send-MailMessage -From "DO NOT REPLY <donotreply@nyp.org>" -To "Zhani Pellumbi <zhp9002@nyp.org>" -Subject "$URL Web Exception" -Body "A request was made to $URL and an exception at $time was thrown. Error message: $exception" -SmtpServer "smtp.nyp.org" 
}
catch [System.Net.Mail.SmtpException] { # if something wrong with smtp server...
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $exception = $_.Exception
    Add-Content -Path "C:\Scripts\exceptions.txt" -Value "System.Net.Mail.SmtpException With $URL! Occurred at $time. Something is wrong with the SMTP server (e.g. connection, configuration)"
    #Send-MailMessage -From "DO NOT REPLY <donotreply@nyp.org>" -To "Zhani Pellumbi <zhp9002@nyp.org>" -Subject "infonet Smtp Exception!" -Body "Powershell attempted to send an automated message but there is a problem with the SMTP server at $time. Error message: $exception" -SmtpServer "smtp.nyp.org"
}
catch [System.IO.IOException] { #if something is wrong with I/O of writing input to the file... 
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss" 
    $exception = $_.Exception
    #Add-Content -Path "C:\Scripts\exceptions.txt" -Value "IO Exception! Occurred at: $time. Something's wrong with I/O; powershell cannot write to the success log.txt"
    Send-MailMessage -From "DO NOT REPLY <donotreply@nyp.org>" -To "Zhani Pellumbi <zhp9002@nyp.org>" -Subject "Script IO Exception!" -Body "Powershell ran into issues with I/O writing to the log.txt success file at $time. Error message: $exception" -SmtpServer "smtp.nyp.org"
}
catch [System.Exception] {
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $exception = $_.Exception
    Send-MailMessage -From "DO NOT REPLY <donotreply@nyp.org>" -To "Zhani Pellumbi <zhp9002@nyp.org>" -Subject "Other Exception with $URL" -Body "Exception message: $exception" -SmtpServer "smtp.nyp.org"
}


