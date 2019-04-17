=BEGIN
An example of how to grab some json from powershell and then return it.
if anyone is looking at this specific example, note that there is a gem you can use instead to pull services
ex:
```
require 'win32/service'

# Iterate over the available services
Win32::Service.services do |service|
  p service
end 
```
=END


def get_services_to_monitor
  output = []

  cmd_json = powershell_out("Get-Service | Select-Object Name, Status, StartType | ConvertTo-Json -Compress").stdout.strip.to_s
  all_installed_services = JSON.parse(cmd_json)

  # Retrieve all services which are explicitly mentioned by the SERVICE_ tags
  output += all_installed_services.select { |service| get_services_to_monitor_from_tags.include? service['Name'].upcase }

  # Retrieve all services which match passed in regexes
  node['blah']['services_to_monitor_regexes'].each do |service_regex_str|
    service_regex = Regexp.new(service_regex_str, Regexp::IGNORECASE)
    output += all_installed_services.select { |service| service_regex.match service['Name'] }
  end

  output.uniq
end
