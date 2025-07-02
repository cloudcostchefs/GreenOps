 #Requires -Version 5.1

<#
.SYNOPSIS
    Azure Carbon Emissions Data Collection Script - CloudCostChefs Edition
    
.DESCRIPTION
    This script connects to the Azure Carbon Optimization API to retrieve carbon emissions data
    from single or multiple subscriptions and generates CSV files optimized for dashboard creation.
    
    💡 CloudCostChefs Pro Tip: Carbon data is only available ~19 days after month end due to Azure's
    processing pipeline. Don't expect real-time emissions data - this is for trend analysis!

.PARAMETER SubscriptionId
    Single Azure subscription ID to retrieve carbon data for

.PARAMETER SubscriptionIds
    Array of subscription IDs to process

.PARAMETER AllSubscriptions
    Process all subscriptions you have access to
    🔥 Warning: This can be SLOW with many subscriptions - consider batching for orgs with 50+ subs

.PARAMETER TenantId
    Azure tenant ID (optional if using current logged-in context)

.PARAMETER ClientId
    Service principal client ID (optional if using current logged-in context)

.PARAMETER ClientSecret
    Service principal client secret (optional if using current logged-in context)
    💰 Cost Tip: Use managed identities in production to avoid credential management overhead

.PARAMETER StartDate
    Start date for carbon data retrieval (YYYY-MM-DD format)
    📊 Data Availability: Carbon data typically available 2-3 weeks after month end

.PARAMETER EndDate
    End date for carbon data retrieval (YYYY-MM-DD format)

.PARAMETER ReportType
    Type of carbon emissions report to generate
    🎯 Performance Note: ItemDetailsReport with GetFullDataset can return 10K+ records

.PARAMETER OutputPath
    Output directory for generated CSV files

.PARAMETER MaxConcurrentJobs
    Maximum number of subscriptions to process simultaneously
    ⚡ Rate Limiting: Azure Carbon API has undocumented limits - keep this <= 5

.PARAMETER IncludeDisabledSubscriptions
    Include disabled subscriptions in processing
    💡 Usually skip these - disabled subs won't have recent carbon data anyway

.PARAMETER GetFullDataset
    Enable pagination to retrieve complete dataset
    ⚠️ Performance Warning: Can take 10+ minutes for large tenants with comprehensive data

.EXAMPLE
    .\Get-AzureCarbonEmissions.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789012"

.EXAMPLE
    .\Get-AzureCarbonEmissions.ps1 -AllSubscriptions

.EXAMPLE
    .\Get-AzureCarbonEmissions.ps1 -AllSubscriptions -GetFullDataset
    # 🚨 CloudCostChefs Warning: This can take 15+ minutes for enterprise tenants!
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidatePattern('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory = $false)]
    [string[]]$SubscriptionIds,
    
    [Parameter(Mandatory = $false)]
    [switch]$AllSubscriptions,
    
    [Parameter(Mandatory = $false)]
    [string]$TenantId,
    
    [Parameter(Mandatory = $false)]
    [string]$ClientId,
    
    [Parameter(Mandatory = $false)]
    [string]$ClientSecret,
    
    [Parameter(Mandatory = $false)]
    [ValidatePattern('^\d{4}-\d{2}-\d{2}$')]
    [string]$StartDate = (Get-Date).AddDays(-30).ToString('yyyy-MM-dd'),
    
    [Parameter(Mandatory = $false)]
    [ValidatePattern('^\d{4}-\d{2}-\d{2}$')]
    [string]$EndDate = (Get-Date).ToString('yyyy-MM-dd'),
    
    [Parameter(Mandatory = $false)]
    [ValidateSet('ItemDetailsReport', 'MonthlySummaryReport', 'OverallSummaryReport', 'TopItemsMonthlySummaryReport', 'TopItemsSummaryReport')]
    [string]$ReportType = 'ItemDetailsReport',
    
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ".\CarbonReports",
    
    [Parameter(Mandatory = $false)]
    [int]$MaxConcurrentJobs = 5, # 🎯 CloudCostChefs: Sweet spot for API rate limits
    
    [Parameter(Mandatory = $false)]
    [switch]$IncludeDisabledSubscriptions,
    
    [Parameter(Mandatory = $false)]
    [switch]$GetFullDataset
)

# 🌍 CloudCostChefs Global Variables
# These handle the Azure API authentication and versioning
$script:AccessToken = $null
$script:ApiVersion = "2025-04-01"  # 📅 Latest API version as of script creation
$script:BaseUri = "https://management.azure.com"

# 🎨 CloudCostChefs Function: Pretty Console Output
# Because nobody likes boring white text when dealing with carbon data!
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# 🔐 CloudCostChefs Function: Azure Token Magic
# Handles multiple auth methods because Azure auth is... complicated
function Get-AzureAccessToken {
    param(
        [string]$TenantId,
        [string]$ClientId,
        [string]$ClientSecret
    )
    
    try {
        Write-ColorOutput "🔐 Obtaining Azure access token..." "Yellow"
        
        # 🏢 Method 1: Service Principal (recommended for automation)
        if ($ClientId -and $ClientSecret -and $TenantId) {
            Write-ColorOutput "   Using service principal authentication" "Gray"
            
            # 💡 CloudCostChefs Tip: Service principals are perfect for scheduled carbon reporting
            $tokenEndpoint = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
            $body = @{
                grant_type    = "client_credentials"
                client_id     = $ClientId
                client_secret = $ClientSecret
                scope         = "https://management.azure.com/.default"
            }
            
            $response = Invoke-RestMethod -Uri $tokenEndpoint -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"
            return $response.access_token
        }
        else {
            # 🖥️ Method 2: Azure CLI (great for interactive use)
            Write-ColorOutput "   Using Azure CLI authentication" "Gray"
            
            $azTokenResult = az account get-access-token --resource https://management.azure.com --query accessToken --output tsv 2>$null
            if ($azTokenResult -and $azTokenResult -ne "") {
                return $azTokenResult
            }
            
            # 🔄 Method 3: Azure PowerShell (fallback option)
            if (Get-Module -ListAvailable -Name Az.Accounts) {
                Write-ColorOutput "   Trying Azure PowerShell context" "Gray"
                Import-Module Az.Accounts -Force
                $context = Get-AzContext
                if ($context) {
                    # 🎯 CloudCostChefs Note: This is the "magic" PowerShell method
                    $token = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate($context.Account, $context.Environment, $context.Tenant.Id, $null, "https://management.azure.com/").AccessToken
                    return $token
                }
            }
            
            throw "No valid authentication method found. Please run 'az login' or provide service principal credentials."
        }
    }
    catch {
        Write-Error "Failed to obtain access token: $($_.Exception.Message)"
        # 💡 CloudCostChefs Troubleshooting Guide
        Write-ColorOutput "💡 Try one of these authentication methods:" "Yellow"
        Write-ColorOutput "   1. Run 'az login' first" "Gray"
        Write-ColorOutput "   2. Install Azure PowerShell and run 'Connect-AzAccount'" "Gray"
        Write-ColorOutput "   3. Provide service principal credentials via parameters" "Gray"
        throw
    }
}

# 🔍 CloudCostChefs Function: Subscription Discovery
# Gets all your Azure subscriptions - the good, the bad, and the disabled
function Get-AccessibleSubscriptions {
    param([string]$AccessToken)
    
    try {
        Write-ColorOutput "🔍 Discovering accessible subscriptions..." "Yellow"
        
        $headers = @{
            'Authorization' = "Bearer $AccessToken"
            'Content-Type'  = 'application/json'
        }
        
        # 📡 CloudCostChefs API Call: Basic subscription enumeration
        $uri = "$BaseUri/subscriptions?api-version=2020-01-01"
        $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers
        
        $subscriptions = @()
        foreach ($sub in $response.value) {
            # 🎯 CloudCostChefs Filter: Skip disabled subs unless explicitly requested
            if ($IncludeDisabledSubscriptions -or $sub.state -eq "Enabled") {
                $subscriptions += [PSCustomObject]@{
                    SubscriptionId   = $sub.subscriptionId
                    DisplayName      = $sub.displayName
                    State            = $sub.state
                    TenantId         = $sub.tenantId
                }
            }
        }
        
        Write-ColorOutput "   ✅ Found $($subscriptions.Count) accessible subscriptions" "Green"
        return $subscriptions
    }
    catch {
        # 🚨 CloudCostChefs Error: Usually means RBAC issues
        Write-Error "Failed to retrieve subscriptions: $($_.Exception.Message)"
        throw
    }
}

# 🧪 CloudCostChefs Function: Service Availability Check
# Tests if Carbon Optimization is even enabled (spoiler: often it's not!)
function Test-CarbonOptimizationService {
    param([string]$AccessToken)
    
    try {
        Write-ColorOutput "🔍 Checking Carbon Optimization service availability..." "Yellow"
        
        $headers = @{
            'Authorization' = "Bearer $AccessToken"
            'Content-Type'  = 'application/json'
        }
        
        # 🔍 CloudCostChefs Check: Verify the Carbon provider is registered
        $uri = "$BaseUri/providers/Microsoft.Carbon?api-version=2020-06-01"
        $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers
        
        if ($response) {
            Write-ColorOutput "   ✅ Carbon Optimization service is available" "Green"
            return $true
        }
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        
        # 🎯 CloudCostChefs Troubleshooting: Common failure scenarios
        switch ($statusCode) {
            404 {
                Write-ColorOutput "   ❌ Carbon Optimization service not found (404)" "Red"
                Write-ColorOutput "   💡 This tenant may not have Carbon Optimization enabled" "Yellow"
            }
            403 {
                Write-ColorOutput "   ❌ Access denied to Carbon Optimization service (403)" "Red"
                Write-ColorOutput "   💡 Check if you have the required permissions" "Yellow"
            }
            default {
                Write-ColorOutput "   ❌ Error checking Carbon Optimization service: HTTP $statusCode" "Red"
            }
        }
        return $false
    }
}

# 🛡️ CloudCostChefs Function: Subscription Access Validation
# The "rubber meets the road" test - can we actually get carbon data?
function Test-SubscriptionCarbonAccess {
    param(
        [string]$AccessToken,
        [array]$Subscriptions
    )
    
    Write-ColorOutput "🔐 Testing Carbon Optimization access for subscriptions..." "Yellow"
    
    $accessibleSubs = @()
    $deniedSubs = @()
    
    foreach ($sub in $Subscriptions) {
        try {
            $headers = @{
                'Authorization' = "Bearer $AccessToken"
                'Content-Type'  = 'application/json'
            }
            
            # 🎯 CloudCostChefs Test: Use minimal OverallSummaryReport for access testing
            $testPayload = @{
                reportType       = "OverallSummaryReport"
                subscriptionList = @($sub.SubscriptionId)
                carbonScopeList  = @("Scope1", "Scope2", "Scope3")
                dateRange        = @{
                    start = $StartDate
                    end   = $EndDate
                }
            } | ConvertTo-Json -Depth 3
            
            $uri = "$BaseUri/providers/Microsoft.Carbon/carbonEmissionReports?api-version=$ApiVersion"
            
            Write-ColorOutput "   Testing: $($sub.DisplayName) ($($sub.SubscriptionId))" "Gray"
            
            try {
                $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $testPayload -ErrorAction Stop
                
                # 🔍 CloudCostChefs Logic: Check API response for access decisions
                if ($response.subscriptionAccessDecisionList) {
                    $accessDecision = $response.subscriptionAccessDecisionList | Where-Object { $_.subscriptionId -eq $sub.SubscriptionId }
                    if ($accessDecision.decision -eq "Allowed") {
                        $accessibleSubs += $sub
                        Write-ColorOutput "   ✅ $($sub.DisplayName) - Access granted" "Green"
                    }
                    else {
                        $deniedSubs += $sub
                        Write-ColorOutput "   ❌ $($sub.DisplayName) - Access denied by API" "Red"
                    }
                }
                else {
                    # 🎉 CloudCostChefs: No explicit denial means we're good to go!
                    $accessibleSubs += $sub
                    Write-ColorOutput "   ✅ $($sub.DisplayName) - API test successful" "Green"
                }
            }
            catch {
                $errorDetails = ""
                if ($_.Exception.Response) {
                    $statusCode = $_.Exception.Response.StatusCode.value__
                    
                    # 🔍 CloudCostChefs Debug: Extract meaningful error messages
                    try {
                        $errorStream = $_.Exception.Response.GetResponseStream()
                        $reader = New-Object System.IO.StreamReader($errorStream)
                        $errorBody = $reader.ReadToEnd()
                        $reader.Close()
                        
                        if ($errorBody) {
                            $errorObj = $errorBody | ConvertFrom-Json
                            if ($errorObj.error.message) {
                                $errorDetails = $errorObj.error.message
                            }
                            elseif ($errorObj.message) {
                                $errorDetails = $errorObj.message
                            }
                            else {
                                $errorDetails = $errorBody
                            }
                        }
                    }
                    catch {
                        $errorDetails = "Could not parse error details"
                    }
                    
                    # 🎯 CloudCostChefs Error Codes: The real-world troubleshooting guide
                    switch ($statusCode) {
                        400 { 
                            Write-ColorOutput "   ❌ $($sub.DisplayName) - Bad Request (400)" "Red"
                            Write-ColorOutput "      Possible causes:" "Yellow"
                            Write-ColorOutput "      • Carbon Optimization not enabled for this subscription" "Gray"
                            Write-ColorOutput "      • Invalid date range (data only available after monthly processing)" "Gray"
                            Write-ColorOutput "      • Subscription has no billable usage" "Gray"
                            if ($errorDetails) {
                                Write-ColorOutput "      • API Error: $errorDetails" "Gray"
                            }
                        }
                        403 { 
                            Write-ColorOutput "   ❌ $($sub.DisplayName) - Access denied (403)" "Red"
                            Write-ColorOutput "      Missing 'Carbon Optimization Reader' role" "Yellow"
                        }
                        404 { 
                            Write-ColorOutput "   ❌ $($sub.DisplayName) - Not found (404)" "Red"
                            Write-ColorOutput "      Carbon Optimization service not available" "Yellow"
                        }
                        default { 
                            Write-ColorOutput "   ❌ $($sub.DisplayName) - HTTP $statusCode" "Red"
                            if ($errorDetails) {
                                Write-ColorOutput "      Error: $errorDetails" "Yellow"
                            }
                        }
                    }
                }
                else {
                    Write-ColorOutput "   ❌ $($sub.DisplayName) - $($_.Exception.Message)" "Red"
                }
                
                $deniedSubs += $sub
            }
        }
        catch {
            Write-ColorOutput "   ❌ $($sub.DisplayName) - Unexpected error: $($_.Exception.Message)" "Red"
            $deniedSubs += $sub
        }
        
        # 😴 CloudCostChefs Rate Limiting: Be nice to the API
        Start-Sleep -Milliseconds 500
    }
    
    Write-ColorOutput "📊 Access Summary: $($accessibleSubs.Count) accessible, $($deniedSubs.Count) denied" "Cyan"
    
    # 💡 CloudCostChefs Troubleshooting Guide: When things go wrong
    if ($deniedSubs.Count -gt 0) {
        Write-ColorOutput "`n💡 Troubleshooting Tips:" "Yellow"
        Write-ColorOutput "   1. Ensure Carbon Optimization is enabled in Azure Portal" "Gray"
        Write-ColorOutput "   2. Check that subscriptions have active billable usage" "Gray"
        Write-ColorOutput "   3. Verify date range (carbon data available ~19 days after month end)" "Gray"
        Write-ColorOutput "   4. Confirm 'Carbon Optimization Reader' role assignment" "Gray"
        Write-ColorOutput "   5. Try with a different date range (e.g., previous month)" "Gray"
    }
    
    return @{
        Accessible = $accessibleSubs
        Denied     = $deniedSubs
    }
}

# 📊 CloudCostChefs Function: Carbon Data Retrieval with Pagination
# The heavy lifter - where the actual carbon data comes from
function Get-SingleSubscriptionCarbonData {
    param(
        [string]$AccessToken,
        [string]$SubscriptionId,
        [string]$StartDate,
        [string]$EndDate,
        [string]$ReportType,
        [switch]$GetAllRecords
    )
    
    try {
        Write-ColorOutput "📊 Fetching carbon emissions data..." "Yellow"
        Write-ColorOutput "   Subscription: $SubscriptionId" "Gray"
        Write-ColorOutput "   Date Range: $StartDate to $EndDate" "Gray"
        Write-ColorOutput "   Report Type: $ReportType" "Gray"
        if ($GetAllRecords) {
            Write-ColorOutput "   Mode: Full dataset with pagination" "Gray"
            # 🚨 CloudCostChefs Warning: This can take a LONG time!
        }
        
        $headers = @{
            'Authorization' = "Bearer $AccessToken"
            'Content-Type'  = 'application/json'
        }
        
        # 🏗️ CloudCostChefs: Build the API payload based on report type
        $payload = @{
            reportType       = $ReportType
            subscriptionList = @($SubscriptionId)
            carbonScopeList  = @("Scope1", "Scope2", "Scope3")  # All emission scopes
            dateRange        = @{
                start = $StartDate
                end   = $EndDate
            }
        }
        
        # 🎯 CloudCostChefs: Report-specific optimizations
        switch ($ReportType) {
            "ItemDetailsReport" {
                # 📅 For item details, we need specific month data
                $payload.dateRange.end = $StartDate
                $payload.categoryType = "Resource"
                $payload.orderBy = "LatestMonthEmissions"
                $payload.sortDirection = "Desc"
                # 📈 CloudCostChefs: Balance between completeness and API performance
                $payload.pageSize = if ($GetAllRecords) { 5000 } else { 100 }
            }
            "TopItemsMonthlySummaryReport" {
                $payload.categoryType = "Resource"
                # 🏆 CloudCostChefs: Top 10 is usually enough for actionable insights
                $payload.topN = if ($GetAllRecords) { 10 } else { 10 }
            }
            "TopItemsSummaryReport" {
                $payload.dateRange.end = $StartDate
                $payload.categoryType = "Resource"
                $payload.topN = if ($GetAllRecords) { 10 } else { 10 }
            }
        }
        
        # 🔄 CloudCostChefs: Pagination Logic - Because Azure loves to paginate everything
        $allData = @()
        $skipToken = $null
        $pageCount = 0
        
        do {
            $pageCount++
            if ($skipToken) {
                $payload.skipToken = $skipToken
                Write-ColorOutput "   Fetching page $pageCount (continuing from skipToken)..." "Gray"
            } else {
                Write-ColorOutput "   Fetching page $pageCount..." "Gray"
            }
            
            $jsonPayload = $payload | ConvertTo-Json -Depth 3
            $uri = "$BaseUri/providers/Microsoft.Carbon/carbonEmissionReports?api-version=$ApiVersion"
            
            # 🚀 CloudCostChefs: The actual API call
            $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $jsonPayload
            
            # 📦 CloudCostChefs: Collect this page's data
            if ($response.value) {
                $allData += $response.value
                $recordCount = $response.value.Count
                Write-ColorOutput "   ✅ Page $pageCount - Retrieved $recordCount records" "Green"
            }
            
            # 🔄 CloudCostChefs: Check for more pages (the pagination dance)
            $skipToken = $response.skipToken
            
            if ($skipToken -and $GetAllRecords) {
                Write-ColorOutput "   📄 More data available, fetching next page..." "Yellow"
                Start-Sleep -Seconds 1  # 😴 Be respectful to the Azure API gods
            }
            
        } while ($skipToken -and $GetAllRecords -and $pageCount -lt 100)  # 🛡️ Safety limit
        
        # 📊 CloudCostChefs: Create consolidated response
        $consolidatedResponse = @{
            value = $allData
            subscriptionAccessDecisionList = $response.subscriptionAccessDecisionList
        }
        
        $totalRecords = $allData.Count
        Write-ColorOutput "   ✅ Total data retrieved - $totalRecords records across $pageCount pages" "Green"
        return $consolidatedResponse
    }
    catch {
        # 🚨 CloudCostChefs Error Handling: When the API throws a tantrum
        Write-Error "Failed to retrieve carbon emissions data: $($_.Exception.Message)"
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode.value__
            Write-ColorOutput "   HTTP Status: $statusCode" "Red"
        }
        throw
    }
}

# 🔄 CloudCostChefs Function: Data Transformation Magic
# Converts Azure's JSON response into clean, dashboardable CSV data
function ConvertTo-CarbonDataTable {
    param(
        [object]$ApiResponse,
        [string]$ReportType,
        [string]$StartDate
    )
    
    $carbonData = @()
    
    if (-not $ApiResponse.value) {
        Write-ColorOutput "   ⚠️ No emission data returned from API" "Yellow"
        # 💡 CloudCostChefs: This is normal for new subscriptions or periods with no usage
        return $carbonData
    }
    
    Write-ColorOutput "📋 Processing $($ApiResponse.value.Count) data items..." "Yellow"
    
    foreach ($item in $ApiResponse.value) {
        # 🎯 CloudCostChefs: Handle different report types with specific data structures
        switch ($ReportType) {
            "ItemDetailsReport" {
                if ($item.dataType -eq "ResourceItemDetailsData") {
                    # 🧮 CloudCostChefs Unit Conversion: API returns metric tonnes, we also want kg
                    $emissionsTonnes = if ($item.latestMonthEmissions) { $item.latestMonthEmissions } else { 0 }
                    # 🚨 CloudCostChefs Bug Fix: The original had a bug here - was multiplying tonnes by 1000 incorrectly
                    $emissionsKg = $emissionsTonnes * 1000  # Convert tonnes to kg
                    
                    # 🎯 CloudCostChefs: Defensive programming - handle missing/null values
                    $serviceValue = if ($item.resourceType) { $item.resourceType } else { "Unknown" }
                    $resourceNameValue = if ($item.itemName) { $item.itemName } else { "N/A" }
                    $resourceGroupValue = if ($item.resourceGroup) { $item.resourceGroup } else { "N/A" }
                    $regionValue = if ($item.location) { $item.location } else { "N/A" }
                    $subscriptionIdValue = if ($item.subscriptionId) { $item.subscriptionId } else { "N/A" }
                    $resourceIdValue = if ($item.resourceId) { $item.resourceId } else { "N/A" }
                    $categoryTypeValue = if ($item.categoryType) { $item.categoryType } else { "N/A" }
                    $previousMonthValue = if ($item.previousMonthEmissions) { $item.previousMonthEmissions } else { 0 }
                    $monthOverMonthValue = if ($item.monthOverMonthEmissionsChangeRatio) { $item.monthOverMonthEmissionsChangeRatio } else { 0 }
                    $monthlyChangeValue = if ($item.monthlyEmissionsChangeValue) { $item.monthlyEmissionsChangeValue } else { 0 }
                    
                    # 🏗️ CloudCostChefs: Build standardized data structure for dashboard consumption
                    $carbonData += [PSCustomObject]@{
                        Provider              = "Azure"
                        Date                  = $StartDate
                        Service               = $serviceValue
                        ResourceName          = $resourceNameValue
                        ResourceGroup         = $resourceGroupValue
                        Region                = $regionValue
                        SubscriptionId        = $subscriptionIdValue
                        ResourceId            = $resourceIdValue
                        CategoryType          = $categoryTypeValue
                        CarbonEmissionsKg     = [math]::Round($emissionsKg, 4)      # 🎯 4 decimal precision for kg
                        CarbonEmissionsTonnes = [math]::Round($emissionsTonnes, 6)   # 🎯 6 decimal precision for tonnes
                        PreviousMonthEmissions = [math]::Round($previousMonthValue, 6)
                        MonthOverMonthChange  = [math]::Round($monthOverMonthValue, 4)  # Percentage change
                        MonthlyChangeValue    = [math]::Round($monthlyChangeValue, 6)
                        Cost                  = 0    # 💰 CloudCostChefs: Carbon API doesn't include cost data
                        Currency              = "USD"
                        ReportType            = $ReportType
                        DataType              = $item.dataType
                    }
                }
            }
            "MonthlySummaryReport" {
                if ($item.dataType -eq "MonthlySummaryData") {
                    $emissionsTonnes = if ($item.totalEmissions) { $item.totalEmissions } else { 0 }
                    $emissionsKg = $emissionsTonnes * 1000
                    $monthValue = if ($item.month) { $item.month } else { $StartDate }
                    
                    # 📊 CloudCostChefs: Monthly summary for trend analysis
                    $carbonData += [PSCustomObject]@{
                        Provider                = "Azure"
                        Date                    = $StartDate
                        Service                 = "All Services"
                        ResourceName            = "Monthly Summary"
                        ResourceGroup           = "All"
                        Region                  = "All Regions"
                        SubscriptionId          = "Multiple"
                        CarbonEmissionsKg       = [math]::Round($emissionsKg, 4)
                        CarbonEmissionsTonnes   = [math]::Round($emissionsTonnes, 6)
                        Cost                    = 0
                        Currency                = "USD"
                        ReportType              = $ReportType
                        DataType                = $item.dataType
                        Month                   = $monthValue
                    }
                }
            }
            "OverallSummaryReport" {
                if ($item.dataType -eq "OverallSummaryData") {
                    $emissionsTonnes = if ($item.latestMonthEmissions) { $item.latestMonthEmissions } else { 0 }
                    $emissionsKg = $emissionsTonnes * 1000
                    $previousMonthValue = if ($item.previousMonthEmissions) { $item.previousMonthEmissions } else { 0 }
                    $monthOverMonthValue = if ($item.monthOverMonthEmissionsChangeRatio) { $item.monthOverMonthEmissionsChangeRatio } else { 0 }
                    $monthlyChangeValue = if ($item.monthlyEmissionsChangeValue) { $item.monthlyEmissionsChangeValue } else { 0 }
                    
                    # 📈 CloudCostChefs: Perfect for executive dashboards
                    $carbonData += [PSCustomObject]@{
                        Provider                     = "Azure"
                        Date                         = $StartDate
                        Service                      = "All Services"
                        ResourceName                 = "Overall Summary"
                        ResourceGroup                = "All"
                        Region                       = "All Regions"
                        SubscriptionId               = "Multiple"
                        CarbonEmissionsKg            = [math]::Round($emissionsKg, 4)
                        CarbonEmissionsTonnes        = [math]::Round($emissionsTonnes, 6)
                        PreviousMonthEmissions       = [math]::Round($previousMonthValue, 6)
                        MonthOverMonthChange         = [math]::Round($monthOverMonthValue, 4)
                        MonthlyEmissionsChangeValue  = [math]::Round($monthlyChangeValue, 6)
                        Cost                         = 0
                        Currency                     = "USD"
                        ReportType                   = $ReportType
                        DataType                     = $item.dataType
                    }
                }
            }
            default {
                # 🔧 CloudCostChefs: Generic handler for other report types
                $emissionsTonnes = if ($item.latestMonthEmissions) { $item.latestMonthEmissions } elseif ($item.carbonEmissions) { $item.carbonEmissions } else { 0 }
                $emissionsKg = $emissionsTonnes * 1000
                
                # 🛡️ CloudCostChefs: More defensive programming for variable API responses
                $serviceValue = if ($item.resourceType) { $item.resourceType } elseif ($item.service) { $item.service } else { "Unknown" }
                $resourceNameValue = if ($item.itemName) { $item.itemName } elseif ($item.resourceName) { $item.resourceName } else { "N/A" }
                $resourceGroupValue = if ($item.resourceGroup) { $item.resourceGroup } else { "N/A" }
                $regionValue = if ($item.location) { $item.location } else { "N/A" }
                $subscriptionIdValue = if ($item.subscriptionId) { $item.subscriptionId } else { "N/A" }
                $dataTypeValue = if ($item.dataType) { $item.dataType } else { "Unknown" }
                
                $carbonData += [PSCustomObject]@{
                    Provider              = "Azure"
                    Date                  = $StartDate
                    Service               = $serviceValue
                    ResourceName          = $resourceNameValue
                    ResourceGroup         = $resourceGroupValue
                    Region                = $regionValue
                    SubscriptionId        = $subscriptionIdValue
                    CarbonEmissionsKg     = [math]::Round($emissionsKg, 4)
                    CarbonEmissionsTonnes = [math]::Round($emissionsTonnes, 6)
                    Cost                  = 0
                    Currency              = "USD"
                    ReportType            = $ReportType
                    DataType              = $dataTypeValue
                }
            }
        }
    }
    
    Write-ColorOutput "   ✅ Processed $($carbonData.Count) carbon emission records" "Green"
    return $carbonData
}

# 📁 CloudCostChefs Function: Export Data to Dashboard-Ready Files
# Creates CSV files optimized for Power BI, Tableau, and Excel consumption
function Export-CarbonReports {
    param(
        [array]$CarbonData,
        [hashtable]$Summary,
        [string]$OutputPath,
        [string]$ReportType
    )
    
    # 🏗️ CloudCostChefs: Ensure output directory exists
    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    }
    
    # 📅 CloudCostChefs: Smart file naming for organized carbon reporting
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"  # For unique files
    $dateStamp = Get-Date -Format "yyyyMMdd"         # For daily aggregation
    
    Write-ColorOutput "📁 Exporting reports to: $OutputPath" "Yellow"
    
    $exportedFiles = @{}
    
    # 📊 CloudCostChefs: Main CSV export - the star of the show
    if ($CarbonData.Count -gt 0) {
        $mainFile = Join-Path $OutputPath "Azure_Carbon_Emissions_$dateStamp.csv"
        $CarbonData | Export-Csv -Path $mainFile -NoTypeInformation -Encoding UTF8
        Write-ColorOutput "   ✅ Main report: $mainFile" "Green"
        # 💡 CloudCostChefs Tip: This CSV format is optimized for Power BI auto-detect
        $exportedFiles.MainFile = $mainFile
    }
    
    # 📋 CloudCostChefs: Summary JSON for programmatic consumption
    $summaryFile = Join-Path $OutputPath "Azure_Carbon_Summary_$timestamp.json"
    $Summary | ConvertTo-Json -Depth 3 | Out-File -FilePath $summaryFile -Encoding UTF8
    Write-ColorOutput "   ✅ Summary JSON: $summaryFile" "Green"
    # 🔧 CloudCostChefs: Perfect for feeding into monitoring systems
    $exportedFiles.SummaryFile = $summaryFile
    
    return $exportedFiles
}

# 📈 CloudCostChefs Function: Statistical Summary Generation
# Creates executive-friendly summary stats from raw carbon data
function Get-CarbonSummaryStats {
    param([array]$CarbonData)
    
    if ($CarbonData.Count -eq 0) {
        # 🚨 CloudCostChefs: Handle the "no data" scenario gracefully
        return @{}
    }
    
    # 🧮 CloudCostChefs: Calculate key metrics for C-suite reporting
    $totalEmissions = ($CarbonData | Measure-Object -Property CarbonEmissionsTonnes -Sum).Sum
    $totalCost = ($CarbonData | Measure-Object -Property Cost -Sum).Sum
    
    # 📊 CloudCostChefs: Build comprehensive summary object
    $summary = @{
        TotalRecords         = $CarbonData.Count
        TotalCarbonTonnes    = [math]::Round($totalEmissions, 6)     # High precision for compliance reporting
        TotalCarbonKg        = [math]::Round($totalEmissions * 1000, 2)  # More intuitive for smaller values
        TotalCost            = [math]::Round($totalCost, 2)         # Standard currency precision
        DateRange            = @{
            Start = ($CarbonData | Sort-Object Date | Select-Object -First 1).Date
            End   = ($CarbonData | Sort-Object Date | Select-Object -Last 1).Date
        }
        # 💡 CloudCostChefs: Additional metadata for dashboard context
        GeneratedAt          = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"
        ApiVersion          = $script:ApiVersion
        ReportType          = $ReportType
    }
    
    return $summary
}

# 🎨 CloudCostChefs Function: Pretty Summary Report Display
# Console output that doesn't make your eyes bleed
function Show-SummaryReport {
    param([hashtable]$Summary, [hashtable]$ExportedFiles)
    
    # 🎨 CloudCostChefs: ASCII art for executive presence
    Write-ColorOutput "`n================================================================" "Cyan"
    Write-ColorOutput "🌱 AZURE CARBON EMISSIONS SUMMARY REPORT - CloudCostChefs Edition" "Cyan"
    Write-ColorOutput "================================================================" "Cyan"
    
    # 📊 CloudCostChefs: Key metrics in executive-friendly format
    Write-ColorOutput "📅 Date Range: $($Summary.DateRange.Start) to $($Summary.DateRange.End)" "White"
    Write-ColorOutput "📊 Total Records: $($Summary.TotalRecords)" "White"
    Write-ColorOutput "🌍 Total Carbon Emissions: $($Summary.TotalCarbonTonnes) tonnes CO₂e" "Green"
    Write-ColorOutput "⚖️  That's equivalent to: $($Summary.TotalCarbonKg) kg CO₂e" "Green"
    Write-ColorOutput "💰 Total Associated Cost: `$($Summary.TotalCost)" "White"
    # 💡 CloudCostChefs Note: Cost is usually $0 since Carbon API doesn't provide cost data
    
    Write-ColorOutput "`n📁 Generated Files:" "Cyan"
    foreach ($file in $ExportedFiles.Values) {
        if ($file -and (Test-Path $file)) {
            $fileSize = (Get-Item $file).Length
            $fileSizeKB = [math]::Round($fileSize / 1024, 1)
            Write-ColorOutput "   📄 $file ($fileSizeKB KB)" "Gray"
        }
    }
    
    # 🎯 CloudCostChefs: Actionable next steps (the real value!)
    Write-ColorOutput "`n💡 CloudCostChefs Next Steps:" "Yellow"
    Write-ColorOutput "   1. 📊 Import CSV into Power BI using our carbon dashboard template" "Gray"
    Write-ColorOutput "   2. 📈 Set up automated monthly carbon tracking" "Gray"
    Write-ColorOutput "   3. 🎯 Identify top carbon emitters for optimization" "Gray"
    Write-ColorOutput "   4. 💚 Implement right-sizing recommendations to reduce emissions" "Gray"
    Write-ColorOutput "   5. 📝 Create executive carbon reporting for ESG compliance" "Gray"
    
    # 🔗 CloudCostChefs: Shameless plug for more resources
    Write-ColorOutput "`n🌐 Get more carbon optimization tips at cloudcostchefs.com" "Cyan"
    Write-ColorOutput "================================================================" "Cyan"
}

# 🚀 CloudCostChefs Function: Main Execution Engine
# The conductor orchestrating this carbon symphony
function Main {
    try {
        # 🎬 CloudCostChefs: Opening credits
        Write-ColorOutput "🌱 Azure Carbon Emissions Data Collection Script - CloudCostChefs Edition" "Green"
        Write-ColorOutput "💡 For more Azure cost optimization tips, visit cloudcostchefs.com" "Cyan"
        
        # 🕐 CloudCostChefs: Future date validation (common user error)
        if ($EndDate -gt (Get-Date).ToString('yyyy-MM-dd')) {
            Write-ColorOutput "⚠️ Warning: End date is in the future. Carbon data is only available for past periods." "Yellow"
            Write-ColorOutput "   Adjusting end date to today..." "Yellow"
            $EndDate = (Get-Date).ToString('yyyy-MM-dd')
        }
        
        # 🎯 CloudCostChefs: Parameter validation and user guidance
        if ($AllSubscriptions) {
            Write-ColorOutput "🔍 Processing ALL accessible subscriptions..." "White"
            Write-ColorOutput "   💡 CloudCostChefs Tip: This can take 5+ minutes for large organizations" "Yellow"
        }
        elseif ($SubscriptionIds -and $SubscriptionIds.Count -gt 0) {
            Write-ColorOutput "🔍 Processing specified list of $($SubscriptionIds.Count) subscriptions..." "White"
        }
        elseif ($SubscriptionId) {
            Write-ColorOutput "🔍 Processing single subscription: $SubscriptionId" "White"
            $SubscriptionIds = @($SubscriptionId)
        }
        else {
            throw "Please specify either -SubscriptionId, -SubscriptionIds, or -AllSubscriptions parameter"
        }
        
        # 📅 CloudCostChefs: Date range validation (another common gotcha)
        $startDateTime = [DateTime]::ParseExact($StartDate, 'yyyy-MM-dd', $null)
        $endDateTime = [DateTime]::ParseExact($EndDate, 'yyyy-MM-dd', $null)
        
        if ($endDateTime -le $startDateTime) {
            throw "End date must be after start date"
        }
        
        # 🔐 CloudCostChefs: Authentication - the first hurdle
        $script:AccessToken = Get-AzureAccessToken -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret
        
        # 🧪 CloudCostChefs: Service availability check (often the show-stopper)
        $serviceAvailable = Test-CarbonOptimizationService -AccessToken $script:AccessToken
        if (-not $serviceAvailable) {
            Write-ColorOutput "`n🚨 Carbon Optimization Service Issues Detected" "Red"
            Write-ColorOutput "💡 CloudCostChefs Troubleshooting Guide:" "Yellow"
            Write-ColorOutput "1. Enable Carbon Optimization in Azure Portal:" "Gray"
            Write-ColorOutput "   • Go to portal.azure.com" "Gray"
            Write-ColorOutput "   • Search for 'Carbon optimization'" "Gray"
            Write-ColorOutput "   • Follow the setup wizard" "Gray"
            Write-ColorOutput "2. Wait for tenant registration (can take 30-60 minutes on first access)" "Gray"
            Write-ColorOutput "3. Contact your Azure administrator to enable the service" "Gray"
            Write-ColorOutput "`nContinuing with subscription testing..." "Yellow"
        }
        
        # 🔍 CloudCostChefs: Target subscription discovery
        $targetSubscriptions = @()
        if ($AllSubscriptions) {
            $allSubs = Get-AccessibleSubscriptions -AccessToken $script:AccessToken
            $targetSubscriptions = $allSubs
        }
        else {
            # 🏗️ CloudCostChefs: Build subscription objects from provided IDs
            foreach ($subId in $SubscriptionIds) {
                $targetSubscriptions += [PSCustomObject]@{
                    SubscriptionId = $subId
                    DisplayName    = "Unknown"
                    State          = "Unknown"
                    TenantId       = $TenantId
                }
            }
            
            # 🔍 CloudCostChefs: Try to enrich with subscription details
            try {
                $allSubs = Get-AccessibleSubscriptions -AccessToken $script:AccessToken
                foreach ($targetSub in $targetSubscriptions) {
                    $matchingSub = $allSubs | Where-Object { $_.SubscriptionId -eq $targetSub.SubscriptionId }
                    if ($matchingSub) {
                        $targetSub.DisplayName = $matchingSub.DisplayName
                        $targetSub.State = $matchingSub.State
                        $targetSub.TenantId = $matchingSub.TenantId
                    }
                }
            }
            catch {
                Write-ColorOutput "   ⚠️ Could not retrieve subscription details, proceeding with IDs only" "Yellow"
            }
        }
        
        if ($targetSubscriptions.Count -eq 0) {
            throw "No subscriptions found to process"
        }
        
        # 📋 CloudCostChefs: Subscription inventory report
        Write-ColorOutput "📋 Found $($targetSubscriptions.Count) subscription(s) to process:" "Cyan"
        foreach ($sub in $targetSubscriptions) {
            Write-ColorOutput "   • $($sub.DisplayName) ($($sub.SubscriptionId)) - $($sub.State)" "Gray"
        }
        
        # 🛡️ CloudCostChefs: Access validation - the moment of truth
        $accessResults = Test-SubscriptionCarbonAccess -AccessToken $script:AccessToken -Subscriptions $targetSubscriptions
        
        if ($accessResults.Accessible.Count -eq 0) {
            throw "No subscriptions have Carbon Optimization access. Please check permissions and service enablement."
        }
        
        # 📊 CloudCostChefs: Data collection phase
        $carbonData = @()
        $subscriptionResults = @()
        
        Write-ColorOutput "📊 Processing $($accessResults.Accessible.Count) accessible subscription(s)..." "Yellow"
        
        # 🔄 CloudCostChefs: Process each accessible subscription
        foreach ($sub in $accessResults.Accessible) {
            try {
                # 🚀 CloudCostChefs: The main data retrieval call
                $apiResponse = Get-SingleSubscriptionCarbonData -AccessToken $script:AccessToken -SubscriptionId $sub.SubscriptionId -StartDate $StartDate -EndDate $EndDate -ReportType $ReportType -GetAllRecords:$GetFullDataset
                $subData = ConvertTo-CarbonDataTable -ApiResponse $apiResponse -ReportType $ReportType -StartDate $StartDate
                
                # 🏷️ CloudCostChefs: Enrich data with subscription metadata
                foreach ($record in $subData) {
                    $record | Add-Member -NotePropertyName "SubscriptionName" -NotePropertyValue $sub.DisplayName -Force
                    if (-not $record.SubscriptionId -or $record.SubscriptionId -eq "N/A") {
                        $record | Add-Member -NotePropertyName "SubscriptionId" -NotePropertyValue $sub.SubscriptionId -Force
                    }
                }
                
                $carbonData += $subData
                
                # 📈 CloudCostChefs: Track processing results for summary
                $subscriptionResults += [PSCustomObject]@{
                    SubscriptionId   = $sub.SubscriptionId
                    SubscriptionName = $sub.DisplayName
                    RecordCount      = $subData.Count
                    TotalEmissions   = ($subData | Measure-Object -Property CarbonEmissionsTonnes -Sum).Sum
                    TotalCost        = ($subData | Measure-Object -Property Cost -Sum).Sum
                    Status           = if ($subData.Count -gt 0) { "Success" } else { "No Data" }
                }
                
                Write-ColorOutput "   ✅ $($sub.DisplayName): $($subData.Count) records" "Green"
            }
            catch {
                # 🚨 CloudCostChefs: Individual subscription failure handling
                Write-ColorOutput "   ❌ $($sub.DisplayName): Failed - $($_.Exception.Message)" "Red"
                $subscriptionResults += [PSCustomObject]@{
                    SubscriptionId   = $sub.SubscriptionId
                    SubscriptionName = $sub.DisplayName
                    RecordCount      = 0
                    TotalEmissions   = 0
                    TotalCost        = 0
                    Status           = "Failed: $($_.Exception.Message)"
                }
            }
        }
        
        # 🎯 CloudCostChefs: Handle the "no data" scenario gracefully
        if ($carbonData.Count -eq 0) {
            Write-ColorOutput "⚠️ No carbon emissions data found for any subscription in the specified period" "Yellow"
            Write-ColorOutput "💡 CloudCostChefs Common Causes:" "Yellow"
            Write-ColorOutput "   • No Azure resources were used during this period" "Gray"
            Write-ColorOutput "   • Carbon data is not yet available (check if it's been 19 days since month end)" "Gray"
            Write-ColorOutput "   • The subscriptions have no emissions to report" "Gray"
            Write-ColorOutput "   • Date range is too recent (try previous month)" "Gray"
            
            # 📁 CloudCostChefs: Still export subscription results for troubleshooting
            if ($subscriptionResults.Count -gt 0) {
                $emptyResultsFile = Join-Path $OutputPath "Azure_Subscription_Results_$(Get-Date -Format 'yyyyMMdd').csv"
                if (-not (Test-Path $OutputPath)) { New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null }
                $subscriptionResults | Export-Csv -Path $emptyResultsFile -NoTypeInformation -Encoding UTF8
                Write-ColorOutput "📁 Subscription results exported to: $emptyResultsFile" "Cyan"
            }
            return
        }
        
        # 📊 CloudCostChefs: Generate executive summary
        $summary = Get-CarbonSummaryStats -CarbonData $carbonData
        
        # 📁 CloudCostChefs: Export all the good stuff
        $exportedFiles = Export-CarbonReports -CarbonData $carbonData -Summary $summary -OutputPath $OutputPath -ReportType $ReportType
        
        # 🎨 CloudCostChefs: Show off our beautiful results
        Show-SummaryReport -Summary $summary -ExportedFiles $exportedFiles
        
        # 🎉 CloudCostChefs: Victory lap!
        Write-ColorOutput "`n✅ Carbon emissions analysis completed successfully!" "Green"
        Write-ColorOutput "📊 Processed $($subscriptionResults.Count) subscriptions with $($carbonData.Count) total records" "Green"
        Write-ColorOutput "🌐 For more Azure optimization tips, visit cloudcostchefs.com" "Cyan"
        
    }
    catch {
        # 🚨 CloudCostChefs: Global error handler
        Write-ColorOutput "`n❌ Script execution failed: $($_.Exception.Message)" "Red"
        Write-ColorOutput "📧 Need help? Email the CloudCostChefs team!" "Yellow"
        Write-ColorOutput "Stack trace: $($_.ScriptStackTrace)" "DarkRed"
        exit 1
    }
}

# 🚀 CloudCostChefs: Execute the main function and let the carbon magic begin!
# Remember: This script is about understanding your environmental impact,
# not just your cloud costs. Every optimization you make helps the planet! 🌍
Main 
