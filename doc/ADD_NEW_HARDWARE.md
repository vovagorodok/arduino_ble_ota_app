# Add new hardware

## Staps
1. Create your hardware json
2. Add link to your hardware json in `resources/hardwares.json`
3. Push change in  `resources/hardwares.json` to this repo

## Hardware json
Example in https://github.com/vovagorodok/ArduinoBleOTA/tree/main/tools/release_builder.  
Required fields:
```
{
    "hardware_name": ...,
    ...
    "softwares": [
        {
            
            "software_name": ...,
            "software_version": ...,
            "software_path": ...,
            ...
        }
        ...
    ]
}
```

General fields:
- required `hardware_name` - string
- required `softwares` - list
- optional `hardware_icon` - string contains path to icon
- optional `hardware_text` - string contains path to text about hardware in markdown

Software fields:
- required `software_name` - string
- required `software_version` - list of ints contains \[major, minor, patch\]
- required `software_path` - string contains path to bin file
- optional `software_icon` - string contains path to icon
- optional `software_text` - string contains path to text about software in markdown
- optional `hardware_version` - specific version of hardware that software is for
- optional `min_hardware_version` - min version of hardware that software is for
- optional `max_hardware_version` - max version of hardware that software is for
