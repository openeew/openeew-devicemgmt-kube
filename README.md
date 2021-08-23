# OpenEEW Device Management - Node-RED

This set of Node-RED flows control the on-boarding and activation of OpenEEW
sensors, orchestrate the provisioning of sensors, monitor the status of sensors,
and provide a simple dashboard for exercising the various MQTT command messages.

## Activation

Every time an OpenEEW sensor powers up it calls an API asking for its MQTT broker.
This Device Management service endpoint API is implemented by a Node-RED flow in this repo.
It replies with the MQTT hostname, the
[most current firmware version](https://github.com/openeew/openeew-firmware/releases)
and a URL where that firmware can be [downloaded](https://github.com/openeew/openeew-download) from.

The [OpenEEW sensor firmware](https://github.com/openeew/openeew-firmware) determines
if it needs to upgrade its firmware, otherwise, it makes a connection to the MQTT
broker.

![Node-RED Flow of OpenEEW Device Management](screenshots/Flow-OpenEEW-DeviceMgmt-Activation.png)

### Description of Node-RED flow Sections

Activation performs a variety of device management tasks in this flow.  The API service endpoint replies with the MQTT broker, updates the Cloudant DB, and, if necessary, creates a new Watson IoT Platform device.

- **Globals** :
- **OpenEEW Activation Endpoint (ESP32 Sensor Board)** :
- **Watson IoT Activation Endpoint v1** :
- **VerneMQ Activation Endpoint v2** :
- **Store / Update Device Details in Cloudant DB** :

Todos:

- Architectural diagram of how this Node-RED flow interacts with the OpenEEW sensors
- API implementation details

## Provisioning

When a new OpenEEW sensor is activated by the
[OpenEEW Provisioning mobile application](https://github.com/openeew/openeew-provisioner),
it collects geolocation information and ownership information from the mobile app and owner.
This information is sent to an API implemented by a Node-RED flow in this repo.
The metadata details are written / updated in a Cloudant database by this Node-RED flow.

![Node-RED Flow of OpenEEW Device Management](screenshots/Flow-OpenEEW-DeviceMgmt-Provisioning.png)

### Description of Node-RED flow Sections

- **OpenEEW User Account Endpoint (Mobile App)** :
- **OpenEEW Registration Endpoint (Mobile App)** :
- **Manual Import of Devices to Cloudant** :
- **Respond to HTTP Request** :
- **Store / Update Device Location / Owner Details in Cloudant DB** :

Todos:

- Architectural diagram of how this Node-RED flow interacts with the OpenEEW Provisioner app
- API implementation details

## Monitoring

OpenEEW Device Status can be monitored by subscribing to a Watson IoT MQTT topic
`iot-2/type/OpenEEW/id/+/mon` and then writing the
Connect / Disconnect messages and timestamps to the Cloudant DB. This allows the various Dashboards to query the DB and show status of the devices without keeping state of when a device was last on-line / connected. The device status metadata details are written / updated in a Cloudant database by this Node-RED flow.

![Node-RED Flow of OpenEEW Device Management](screenshots/Flow-OpenEEW-DeviceMgmt-Monitoring.png)

### Description of Node-RED flow Sections

- **Update Device Connect / Disconnect status in Cloudant DB** :
- **Debug - List OpenEEW Devices Registered to Watson IoT Platform** :
- **List Cloudant OpenEEW Device Database** :

## Send MQTT Commands to OpenEEW Sensors

This repo and Node-RED flow implements a simple Node-RED Dashboard to send MQTT commands
to the selected OpenEEW Sensor.  It exercises the MQTT topics described in the
[OpenEEW Firmware and MQTT readme](https://github.com/openeew/openeew-firmware/blob/main/FIRMWARE.md)

![Node-RED Flow of OpenEEW Control Sensors](screenshots/Flow-OpenEEW-ControlSensors-via-MQTT.png)

### Description of Node-RED flow Sections

- **Load List of OpenEEW Devices** : Read the online / offline status of the devices from the Cloudant DB, build a table array using JSONata, display the table of sensors, store the selected sensor in a flow variable.
- **Control OpenEEW Device** : Send the command via MQTT to the selected sensor.
- **Earthquake Alert Test** : Send `iot-2/type/OpenEEW/id/mac-address/cmd/earthquake/fmt/json` to the selected sensor.
- **Firmware Check** : Send `iot-2/type/OpenEEW/id/mac-address/cmd/firmwarecheck/fmt/json` to the selected sensor.
- **Send 10 second History** : Send `iot-2/type/OpenEEW/id/mac-address/cmd/10secondhistory/fmt/json` to the selected sensor.
- **Send Live Data** : Send `iot-2/type/OpenEEW/id/mac-address/cmd/sendacceldata/fmt/json` to the selected sensor.
- **Change Sample Rate** : Send `iot-2/type/OpenEEW/id/mac-address/cmd/samplerate/fmt/json` to the selected sensor.
- **Restart the Sensor** : Send `iot-2/type/OpenEEW/id/mac-address/cmd/forcerestart/fmt/json` to the selected sensor.
- **Factory Reset** : Send `iot-2/type/OpenEEW/id/mac-address/cmd/factoryreset/fmt/json` to the selected sensor.
- **Override STA / LTA Threshold** : Send `iot-2/type/OpenEEW/id/mac-address/cmd/threshold/fmt/json` to the selected sensor.

### Screenshot of the **Control OpenEEW Devices** dashboard

![Control OpenEEW Devices Node-RED Dashboard](screenshots/Dashboard-OpenEEW-ControlSensors-via-MQTT.png)

## OpenEEW Earthquake Accelometer Display

The main [OpenEEW Dashboard](https://dashboard.openeew.com/) is quite a bit more sophisticated but this
Node-RED flow implements a simple Node-RED dashboard to display accelometer readings from a selected
OpenEEW sensor.

![Node-RED Flow of OpenEEW Sensor Plot](screenshots/Flow-OpenEEW-SensorPlot.png)

### Description of Node-RED flow Sections

- **Enable / Disable Seismic Sensor Charts** : Display a switch that the admin can toggle on/off to control the graph and reset the chart.
- **Load List of OpenEEW Devices** : Read the online / offline status of the devices and build a table array using JSONata.
- **Select an OpenEEW Sensor Network sensor to plot** : Store the selected sensor in a flow variable if it has changed. Reset the chart.
- **Chart Scale Switch State** : a bunch of toggles that lets the admin choose the scale of the graph.
- **Plot selected real-time sensor data** : filter the incoming MQTT events for the selected sensor, transform the X/Y/Z arrays, split them into individual messages, reduce the volume of data, plot the seismic waveform on one graph (instead of three graphs)
- **Send Live Data** - Send a MQTT command to the selected sensor to start transmiting live data.

### Screenshot of the **Real Time OpenEEW Device Plot** dashboard

![Node-RED OpenEEW Sensor Plot Dashboard](screenshots/Dashboard-OpenEEW-SensorPlot.png)

## Kubernetes Implementation

This repository contains a Makefile and Dockerfile which builds a Node-RED container that is
deployed to the OpenEEW infrastructure hosted by IBM Cloud Kubernetes Service (IKS).

### MQTT Secrets

Various MQTT secrets are required to run this containerized Node-RED flow.

## Building the openeew-devicemgmt Node-RED container

To build, run, test the OpenEEW DeviceMgmt Node-RED container on your local system:

```bash
make build
make run
make test
make ui
```

To push the Node-RED container to us.icr.io for deployment to the Kubernetes cluster:

```bash
make login
make push
make kube
```

### Contributors

<a href="https://github.com/openeew/openeew-devicemgmt-kube/graphs/contributors">
  <img src="https://contributors-img.web.app/image?repo=openeew/openeew-devicemgmt-kube" />
</a>
___

Enjoy! Give us [feedback](https://github.com/openeew/openeew-devicemgmt-kube/issues) if you have suggestions on how to improve this information.

## Contributing and Developer information

The community welcomes your involvement and contributions to this project. Please read the OpenEEW [contributing](https://github.com/openeew/openeew/blob/master/CONTRIBUTING.md) document for details on our code of conduct, and the process for submitting pull requests to the community.

## License

The OpenEEW sensor is licensed under the Apache Software License, Version 2. Separate third party code objects invoked within this code pattern are licensed by their respective providers pursuant to their own separate licenses. Contributions are subject to the [Developer Certificate of Origin, Version 1.1 (DCO)](https://developercertificate.org/) and the [Apache Software License, Version 2](http://www.apache.org/licenses/LICENSE-2.0.txt).
