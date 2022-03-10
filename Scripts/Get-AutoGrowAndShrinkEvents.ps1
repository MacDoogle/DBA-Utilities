<#
	.DESCRIPTION
		This script will display all the autogrow/autoshrink events for data and log files for a SQL Server.

		You will need to have dbatools installed (https://dbatools.io/download/)

	.PARAMETER ServerInstance
		[string] The server to display the autogrow/autoshrink events from.

		Defaults to: TNTDB1

	.PARAMETER HoursSince
		[int] The number of hours to look back.

		Defaults to 24

	.OUTPUTS
		Displays the list of autogrow/autoshrink log and data file events, sorted by StartTime descending.
#>
param(
	[string] $SQLInstance = "TNTDB1",
	[int] $HoursSince = 24
)
Set-StrictMode -Version Latest

# Get all the log*.trc files for the passed instance.
[string] $logDir = ('\\{0}\d$\mssql\log' -f $SQLInstance)
[object[]] $logs = get-childitem -path $logDir -filter 'log*.trc'

# Create a lookup for the trace_event_id to to sys.trace.events.Name so we can display the event name in the output.
[hashtable] $eventNames = @{}
# The key is sys.trace_events.trace_event_id
# The value is sys.trace_events.name
$eventNames.Add(92,'Data File Auto Grow')
$eventNames.Add(93,'Log File Auto Grow')
$eventNames.Add(94,'Data File Auto Shrink')
$eventNames.Add(95,'Log File Auto Shrink')

# This array will hold the rows from each of the trace files.
[object[]] $traceData = @()
# Read in each of the trace files for the events we are looking for.
foreach ($log in $logs) {
	write-host "    reading $($log.Fullname)"
	# Get the data from this log file and append it to the array.
	# (these are System.Data.DataRow objects)
	# 92,93,94,95 are the log/data autogrow/autoshrink events.
	$traceData += Read-DbaTraceFile -SQLInstance $SQLInstance -Path $log.Fullname -EventClass ("92","93","94","95")
}

# Display all the data to the console, sorted by StartTime descending, and filtered by the $HoursSince parameter.
$traceData | Sort-Object StartTime -Descending | Where-Object {$_.StartTime -gt [DateTime]::Now.AddHours(($HoursSince * -1))}| format-table -Property `
	DatabaseName, `
	@{Label="Event Name";Expression={$eventNames[$_.EventClass]}}, `
	Filename, `
	@{Label="TimeTakenInSeconds";Expression={$_.Duration/1000000.0}}, `
	@{Label="StartTime";Expression={$_.StartTime.ToString("yyyy-MM-dd HH:mm:ss")}}, `
	@{Label="EndTime";Expression={$_.EndTime.ToString("yyyy-MM-dd HH:mm:ss")}}, `
	@{Label="ChangeInSize MB";Expression={($_.IntegerData * 8.0/1024.0)}}, `
	ApplicationName, `
	HostName, `
	ServerName, `
	LoginName

