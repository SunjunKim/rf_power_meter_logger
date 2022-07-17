# Logger for ImmersionRC RF Power Meter v2

## How to run:
Download processing (https://processing.org/) and install the following libraries:
 * ControlP5
 * meter

## How to use:
 1. Select the serial port.
 2. Select the target frequency.
 3. Press `CONNECT`
 4. Press `RESET_LIMIT` to reset the min/max needles.
 5. Press `RECORD` to log the measured values into a csv file. The format of the values in each row is [timestamp in millisecond, peak RF power in dBm, peak RF power in mW]. Press `RECORD` button again to stop the logging.

## Demonstration
 * Screenshot
 
 ![rf_logger_ss](https://user-images.githubusercontent.com/12195507/179395626-1911ebda-ebc1-4fd3-92d9-97e30fa712c7.png)
 
 * Video: https://youtu.be/S0o81BNo_o4
 
 * measured power graph
 
 ![rf_power_meter_logger](https://user-images.githubusercontent.com/12195507/179361035-a5e9cd7f-90ec-4956-85ea-70325c128098.png)
