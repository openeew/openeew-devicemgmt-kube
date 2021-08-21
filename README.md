# OpenEEW Device Management - Node-RED

===========

This set of Node-RED flows control the on-boarding and activation of OpenEEW
sensors, orchestrates the provisioning of sensors and provides a simple dashboard
for excerising the various MQTT command messages.

## Onboarding and Activation

Every time an OpenEEW sensor powers up it calls an API asking for its MQTT broker.
This Device Management service endpoint API is implemented by a Node-RED flow in this repo.
It replies with the MQTT hostname, the
[most current firmware version](https://github.com/openeew/openeew-firmware/releases)
and a URL where that firmware can be [downloaded](https://github.com/openeew/openeew-download) from.

The [OpenEEW sensor firmware](https://github.com/openeew/openeew-firmware) determines
if it needs to upgrade its firmware, otherwise, it makes a connection to the MQTT
broker.

Todos:

- Screenshot of the Node-RED flow
- Architectural diagram of how this Node-RED flow interacts with the OpenEEW sensors
- Describe the sections of the Node-RED flow and how they write data to Cloudant
- API implementation details

## Provisioning

When a new OpenEEW sensor is activated by the
[OpenEEW Provisioning mobile application](https://github.com/openeew/openeew-provisioner),
it collects geolocation information and ownership information from the mobile app and owner.
This information is sent to an API implemented by a Node-RED flow in this repo.
The metadata details are written / updated in a Cloudant database by this Node-RED flow.

Todos:

- Screenshot of the Node-RED flow
- Architectural diagram of how this Node-RED flow interacts with the OpenEEW Provisioner app
- Describe the sections of the Node-RED flow and how they write data to Cloudant
- API implementation details

## Send MQTT Commands to OpenEEW Sensors

This repo and Node-RED flow implements a simple Node-RED Dashboard to send MQTT commands
to the selected OpenEEW Sensor.  It excerises the MQTT topics described in the
[OpenEEW Firmware and MQTT readme](https://github.com/openeew/openeew-firmware/blob/main/FIRMWARE.md)

Todos:

- Screenshot of the Node-RED flow
- Describe the sections of the Node-RED flow and how it sends MQTT commands
- Screenshot of the Node-RED Dashboard

## OpenEEW Earthquake Accelometer Display

The main [OpenEEW Dashboard](https://dashboard.openeew.com/) is quite a bit more sophisticated but this
Node-RED flow implements a simple Node-RED dashboard to display accelometer readings from a selected
OpenEEW sensor.

Todos:

- Screenshot of the Node-RED flow
- Screenshot of the Node-RED dashboard

## Kubernetes Implementation

This repository contains a Makefile and Dockerfile which builds a Node-RED container that is
deployed to the OpenEEW infrastructure hosted by IBM Cloud Kubernetes Service (IKS).

### MQTT Secrets

Various MQTT secrets are required to run this containerized Node-RED flow.

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
