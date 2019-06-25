$PSRLO = @{
    # EditMode                   = "Emacs"
    HistoryNoDuplicates        = $true
    HistorySaveStyle           = "SaveIncrementally"
    HistorySearchCaseSensitive = $false
    # MaximumHistoryCount        = 0
    ShowToolTips               = $true
}

Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineOption @PSRLO

function prompt {
    # The @ sign creates an array in case only one history item exists
    $History = @(Get-History)
    $LastId = 0
    if ($History.Count -gt 0) {
        $LastItem = $History[$History.Count - 1]
        $LastId = $LastItem.Id
    }
    $NextCommand = $LastId + 1

    "PS [$NextCommand] $(($PWD -split '/')[-1])> "
}
