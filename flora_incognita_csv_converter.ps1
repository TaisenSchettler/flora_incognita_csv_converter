# Define input and output folder paths
$inputFolder = "$psscriptroot\input"
$outputFolder = "$psscriptroot\output"

# Ensure the input and output folders exist
if (!(Test-Path $inputFolder)) {
    Write-Error "Input folder does not exist. Please create a folder named 'input' and place your file in it."
    New-Item -ItemType Directory -Path $InputFolder | Out-Null
    exit
}
if (!(Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder | Out-Null
}

# Find the CSV file in the input folder
$inputFile = Get-ChildItem -Path $inputFolder -Filter *.csv | Select-Object -First 1

if (!$inputFile) {
    Write-Error "No CSV file found in the input folder."
    exit
}

# Import the CSV data
$data = Import-Csv -Path $inputFile.FullName

# Select and transform the required columns
$processedData = $data | ForEach-Object {
    [PSCustomObject]@{
        id              = [array]::IndexOf($data, $_) + 1 # Convert UUID to incrementing integer
        "scientific name" = $_."scientific name"
        latitude        = $_.latitude
        longitude       = $_.longitude
        processedDate   = ($_.date -split 'T')[0] # Extract only the date in yyyy-mm-dd format
    }
}

# Define the output file path
$outputFile = Join-Path -Path $outputFolder -ChildPath "ProcessedData.csv"

# Export the processed data to the output folder
$processedData | Export-Csv -Path $outputFile -NoTypeInformation

Write-Host "Processing complete. The file has been saved to $outputFile."
