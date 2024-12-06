#!/bin/bash

echo "Compiling and building project..."
echo ""

pdc source builds/particles-lab

PLAYDATE_SDK_SIMULATOR_PATH="/Developer/PlaydateSDK-2.6.0/bin/Playdate Simulator.app"

SIMULATOR_PATH="$HOME/$PLAYDATE_SDK_SIMULATOR_PATH"
OUTPUT_PATH="builds/particles-lab.pdx"

echo "Opening simulator..."

open "$SIMULATOR_PATH" "$OUTPUT_PATH"