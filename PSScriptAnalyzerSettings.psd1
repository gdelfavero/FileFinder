@{
    IncludeRules = @(
        'PSUseApprovedVerbs',
        'PSUseConsistentIndentation',
        'PSPlaceOpenBrace',
        'PSUseConsistentWhitespace'
    )

    ExcludeRules = @(
        'PSAvoidUsingWriteHost'  # UI output is intentional in Find-MediaFiles
    )

    Rules = @{
        PSUseConsistentIndentation = @{
            Enable = $true
            IndentationSize = 4
            PipelineIndentation = 'IncreaseIndentationForPipeline'
        }
    }
}
