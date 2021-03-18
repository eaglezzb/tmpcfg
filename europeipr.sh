#!/bin/bash
sudo ip r a 10.0.0.0/8 via 10.52.36.1
sudo ip r r a 192.168.0.0/16 via 10.52.36.1