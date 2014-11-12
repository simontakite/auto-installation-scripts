#!/bin/bash

sudo apt-get install -y debconf-utils

# create answer file
sudo debconf-set-selections <<\EOF
msttcorefonts msttcorefonts/defoma note
ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula boolean true
ttf-mscorefonts-installer msttcorefonts/present-mscorefonts-eula note
EOF

sudo apt-get install -y ubuntu-restricted-extras
