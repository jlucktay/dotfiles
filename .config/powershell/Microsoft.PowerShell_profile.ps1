$PRLO = @{
    EditMode                   = "Emacs"
    HistoryNoDuplicates        = $true
    # MaximumHistoryCount        = 0
    ShowToolTips               = $true
    HistorySearchCaseSensitive = $false
    HistorySaveStyle           = "SaveIncrementally"
}

Set-PSReadLineOption @PRLO

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
